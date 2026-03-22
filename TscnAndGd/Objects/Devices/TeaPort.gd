extends Head_Object
var SelfDev = "TeaPort"
onready var LiquidAni = get_node("AniNode/LiquidAni")
onready var ContentAni = get_node("AniNode/ContentAni")
onready var TeaColorAni = get_node("AniNode/TeaColorAni")
onready var LogicAni = get_node("AniNode/LogicAni")
onready var ShowAni = get_node("AniNode/ShowAni")
onready var TypeAni = get_node("AniNode/TypeAni")
onready var CelciusBar = get_node("DrawTeaNode/Celcius")
onready var Liquid = get_node("TexNode/liquid")
onready var WaterTimer = get_node("Timer")
onready var MixAni = get_node("MixNode/MixAni")
onready var MixShowAni = $MixNode / MixShowAni

onready var IconSprite = get_node("IconNode/IconSprite")

onready var FreshAni = $Effect_flies / Ani
onready var Liquid_Label = get_node("IconNode/IconSprite/LiquidLabel")
var HasTeaLeaf: bool
var HasContent: bool
var CanContent: bool = true
var HasWater: bool
var CanMix: bool
var _MixShow: bool
var WaterType
var TeaType
var ContentType
var CanWaterOut: bool
var WaterCelcius: int
var IsDrawTea: bool

var Liquid_Max: int
var Liquid_Count: int
var CON
var IsCooking: bool
var IsFreezer: bool
var IsPassDay: bool
var IsBroken: bool

onready var A_But = get_node("But/A")
onready var HoldBut = get_node("Hold")
onready var X_But = get_node("Hold/X")
onready var Y_But = get_node("Hold/X")

onready var Audio_Water
onready var Audio_Content
var PlayerList: Array

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func call_Freezer_Switch(_Switch: bool):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	IsFreezer = _Switch
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(self, "IsFreezer", IsFreezer)
func _ready() -> void :
	$IconNode.hide()
	IconSprite.hide()
	X_But.hide()
	call_init(SelfDev)
	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Audio_Water = GameLogic.Audio.return_Effect("倒水")
	Audio_Content = GameLogic.Audio.return_Effect("倒粉末")
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
func _DayClosedCheck():
	if Liquid_Count > 0:
		if WaterType != "water":
			if not IsFreezer:
				IsBroken = true
			else:
				if not IsPassDay:
					IsPassDay = true
				else:
					IsBroken = true
			if not IsFreezer:
				if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.TEAPORT):
					GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.TEAPORT)
func _fressless_check():
	if IsBroken:
		FreshAni.play("Flies")
	elif IsPassDay:
		FreshAni.play("OverDay")
	else:
		FreshAni.play("init")

func But_Hold(_Player):

	if not is_instance_valid(get_parent()):
		return
	if get_parent().name == "Weapon_note":

		HoldBut.show()
	else:
		HoldBut.hide()
	if CanMix and WaterCelcius > 85:
		X_But.show()
	else:
		X_But.hide()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	But_Hold(_Player)
	if _bool:
		if _Player.Con.IsHold:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			HoldBut.show()
		else:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
			HoldBut.hide()
	else:
		But_hide(_bool, _Player)
		return
	.But_Switch(_bool, _Player)

func _Mix_Show():
	if CanMix and WaterCelcius > 85:
		if not _MixShow:
			MixShowAni.play("show")
			_MixShow = true
	elif _MixShow:
		MixShowAni.play("hide")
		_MixShow = false

func _collision_check():
	var _parentName = get_parent().name
	if _parentName == "Devices":
		call_Collision_Switch(true)
	elif _parentName == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	HasContent = _Info.HasContent
	HasWater = _Info.HasWater
	CanMix = _Info.CanMix
	_MixShow = _Info.MixShow
	WaterType = _Info.WaterType
	TeaType = _Info.TeaType
	if TeaType != null:
		ContentAni.play(TeaType)
	ContentType = _Info.ContentType
	CanWaterOut = _Info.CanWaterOut
	IsDrawTea = _Info.IsDrawTea
	Liquid_Count = _Info.Liquid_Count
	if Liquid_Count > 0:
		LiquidAni.play("water")
		_DrawTea_Check()
		Liquid_Label.text = str(Liquid_Count)
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
	WaterCelcius = _Info.WaterCelcius
	MixAni.play("init")
	_Mix_Show()

	if HasWater:
		if not HasContent:
			ContentAni.play("init")
			ShowAni.play("CShow")
			call_WaterCelcius_change()
		else:
			match ContentType:
				"Tealeaf":
					ShowAni.play("CShow")
					call_WaterCelcius_change()
				"Powder":
					ShowAni.play("CShow")
					if WaterCelcius > 99:
						TypeAni.play("boiling")
					elif WaterCelcius > 85:
						TypeAni.play("hot")
					elif WaterCelcius <= 85:
						TypeAni.play("cold")
					elif WaterCelcius <= 5:
						TypeAni.play("ice")
				_:
					ShowAni.play("CShow")
	else:
		if not HasContent:
			ContentAni.play("init")
	IsPassDay = _Info.IsPassDay
	if _Info.has("IsBroken"):
		IsBroken = _Info.IsBroken
	if _Info.has("IsFreezer"):
		IsFreezer = _Info.IsFreezer
	_fressless_check()

	if WaterType != null and WaterType != "water":
		_call_DrawTea_Logic()

		var _color8 = GameLogic.Liquid.return_color_set(WaterType)
		Liquid.set_modulate(_color8)

func call_WaterInTeaPort(_ButID, _PortObj, _Player):

	if LiquidAni.is_playing():
		return
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			call_Water_In(_ButID, _PortObj)
			_PortObj.call_Water_Out(_PortObj.Liquid_Count)
			But_Switch(false, _Player)
			_PortObj.But_Switch(true, _Player)
			_Mix_Show()
			return true

func call_TeaInTeaPort(_ButID, _TeaObj, _Player):



	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if CanContent:
				But_Switch(true, _Player)
		0:

			if _TeaObj.Used:
				return
			if CanContent:
				if _TeaObj.has_method("call_used"):
					_TeaObj.call_used()
				call_Content_In(_TeaObj.TypeStr, _TeaObj.FuncType)
func call_Content_In(_typeStr, _funcType):
	TeaType = _typeStr
	ContentType = _funcType



	ContentAni.play(TeaType)


	HasContent = true
	CanWaterOut = false
	_DrawTea_Check()
	_weight_logic()
	CanContent = false
	Audio_Content.play(0)
	MixAni.play("init")

func return_DropCount():
	var _Drop_Count = 0
	if HasWater:
		_Drop_Count += Liquid_Count
	if HasContent:
		_Drop_Count += 1
	return _Drop_Count
func call_Drop():

	if HasWater:
		call_Water_Out(Liquid_Count)

	if HasContent:
		LiquidAni.play("drop")
		HasContent = false
		ContentType = null
		CanContent = true
		ContentAni.play("init")
		TeaType = null
		if not IconSprite.visible:
			ShowAni.play_backwards("CShow")
	Liquid_Count = 0
	IsDrawTea = false
	HasWater = false
	CanMix = false
	IsPassDay = false
	MixAni.play("init")
	But_Hold(null)
	_Mix_Show()
	_fressless_check()
	_weight_logic()

func _weight_logic():
	var _Con: int = 0
	if HasContent:
		_Con = 1
	Weight = 1 + _Con + int(Liquid_Count)

func call_Water_In(_ButReturnBool, _WaterObj):
	if LiquidAni.is_playing():
		LiquidAni.play("init")

	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
	WaterType = _WaterObj.WaterType
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	Liquid.set_modulate(_color8)
	if WaterType == "water":
		$IconNode.hide()
		TeaColorAni.play("water")
	WaterCelcius = _WaterObj.WaterCelcius
	CelciusBar.value = WaterCelcius
	LiquidAni.play("water")
	HasWater = true
	WaterTimer.start(0)
	_DrawTea_Check()
	_weight_logic()
	Liquid_Count = Liquid_Max
	ShowAni.play("CShow")
	if not HasContent:
		call_WaterCelcius_change()
	else:

		match ContentType:
			"Tealeaf":

				call_WaterCelcius_change()
			"Powder":
				if WaterCelcius > 99:
					TypeAni.play("boiling")
				elif WaterCelcius > 85:
					TypeAni.play("hot")
				elif WaterCelcius <= 85:
					TypeAni.play("cold")
				elif WaterCelcius <= 5:
					TypeAni.play("ice")
			_:
				ShowAni.play("CShow")
	_fressless_check()



func call_Water_Out_puppet(_WEIGHT, _COUNT):
	if IsDrawTea:
		LogicAni.stop()
		TeaColorAni.stop()
		ShowAni.play_backwards("bar_show")
	if not IconSprite.visible:
		ShowAni.play_backwards("CShow")
	Weight = _WEIGHT
	Liquid_Count = _COUNT
	Liquid_Label.text = str(Liquid_Count)
	IconSprite.hide()
	IsPassDay = false
	_fressless_check()
	LiquidAni.play("empty")
	Audio_Water.play(0)
	HasWater = false
	WaterCelcius = 0
	WaterType = null
	CanWaterOut = false
	CanContent = true
func call_Water_Out(_OutNum):


	if IsDrawTea:
		LogicAni.stop()
		TeaColorAni.stop()
		ShowAni.play_backwards("bar_show")





	_weight_logic()
	Liquid_Count -= _OutNum
	if Liquid_Count <= 0:
		Liquid_Count = 0

	IsBroken = false
	IsPassDay = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_Out_puppet", [Weight, Liquid_Count])

	Liquid_Label.text = str(Liquid_Count)
	if not HasContent:

		if not IconSprite.visible:
			ShowAni.play_backwards("CShow")
	IconSprite.hide()

	_fressless_check()
	LiquidAni.play("empty")
	ContentAni.play("init")
	Audio_Water.play(0)
	HasWater = false
	WaterCelcius = 0
	WaterType = null
	CanWaterOut = false
	CanContent = true

func _DrawTea_Check():

	if HasWater and HasContent:

		CanWaterOut = false
		match ContentType:
			"TeaLeaf":
				IsDrawTea = true
				TeaColorAni.play(TeaType)

				call_WaterCelcius_change()
			"Powder":
				CanMix = true
				_Mix_Show()

func call_STIR_start_puppet(_SPEED):

	MixAni.playback_speed = _SPEED
	TeaColorAni.playback_speed = _SPEED

	MixAni.play("Mixd")

	TeaColorAni.play(TeaType)

func return_STIR_start(_Player):

	if get_parent().name != "Weapon_note":
		return false
	if CanMix:
		if WaterCelcius > 85:

			if not PlayerList.has(_Player):
				PlayerList.append(_Player)
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				CON = _Player.Con
				return true
			var _Speed: float = 1
			var _Mult: float = 1
			_Speed = _Speed / GameLogic.return_Multiplier_Division()
			if _Player.BuffList.has("技能-手速"):
				_Mult += 0.5


			if _Player.Stat.Skills.has("技能-灵巧"):
				_Mult += 1.5
			if not _Player.Stat.Skills.has("技能-幽灵基础"):
				if GameLogic.cur_Rewards.has("一次性手套"):
					_Mult += 0.5
				if GameLogic.cur_Rewards.has("一次性手套+"):
					_Mult += 1.5
				if GameLogic.cur_Challenge.has("手笨+"):
					_Mult = _Mult * 0.75
			if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
				_Mult += GameLogic.Skill.HandWorkMult
			if GameLogic.cur_Event == "手速":
				_Mult = 20
			var _SPEED: float = _Speed * _Mult

			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_STIR_start_puppet", [_SPEED])
			MixAni.playback_speed = _SPEED
			TeaColorAni.playback_speed = _SPEED
			MixAni.play("Mixd")
			TeaColorAni.play(TeaType)
			CON = _Player.Con
			return true
	return false
func call_STIR_end(_Player):
	if CanMix:
		if MixAni.get_current_animation_position() >= 1.9:
			_Mix_Finished()
		else:

			TeaColorAni.stop(false)
			MixAni.stop(false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				if PlayerList.has(_Player):
					PlayerList.erase(_Player)
				var _PLAYERPATH = _Player.get_path()
				SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PLAYERPATH])
	else:
		_Player.call_reset_stat()

func call_player_leave(_Player):

	if PlayerList.has(_Player):
		call_STIR_end(_Player)
func call_puppet_STIR_end(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	if PlayerList.has(_Player):
		PlayerList.erase(_Player)
	_Player.Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY

	TeaColorAni.stop(false)
	MixAni.stop(false)

func call_puppet_Mix_Finished():
	CON.state = GameLogic.NPC.STATE.IDLE_EMPTY
	_call_DrawTea_Logic()
	HasContent = false
	ContentType = null
	CanMix = false
	MixAni.play("init")
	_Mix_Show()
	But_Hold(null)
func _Mix_Finished():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	elif SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_Mix_Finished")
	for i in PlayerList.size():
		var _Player = PlayerList[i]

		if _Player.has_method("call_reset_stat"):
			_Player.call_reset_stat()
	CON.state = GameLogic.NPC.STATE.IDLE_EMPTY
	_call_DrawTea_Logic()
	HasContent = false
	ContentType = null
	CanMix = false
	MixAni.play("init")
	_Mix_Show()
	But_Hold(null)
func call_mix():

	if WaterCelcius > 85:
		TeaColorAni.play(TeaType)

		HasContent = false
	pass
func call_WaterCelcius_change():
	if WaterCelcius > 99:
		DrawTea_Boiling()
	elif WaterCelcius > 85:
		DrawTea_Hot()

	elif WaterCelcius <= 85:
		DrawTea_Cold()
	elif WaterCelcius <= 5:
		DrawTea_Ice()

	CelciusBar.value = WaterCelcius
	_Mix_Show()
func DrawTea_Ice():
	CelciusBar.max_value = 25
	CelciusBar.min_value = - 5
	TypeAni.play("ice")

func DrawTea_Cold():
	CelciusBar.max_value = 85
	CelciusBar.min_value = 25
	TypeAni.play("cold")





	pass
func DrawTea_Hot():

	CelciusBar.max_value = 99
	CelciusBar.min_value = 85
	TypeAni.play("hot")
	match ContentType:
		"TeaLeaf":
			if LogicAni.assigned_animation != "drawtea":
				LogicAni.play("drawtea")

	pass
func DrawTea_Boiling():

	CelciusBar.max_value = 100
	CelciusBar.min_value = 100
	TypeAni.play("boiling")

	pass

func _DrawTea_FewLess():


	pass
func _DrawTea_Perfect():


	pass
func _DearTea_FewOver():


	pass
func _DrawTea_Over():


	pass

func _call_DrawTea_Logic():
	CanWaterOut = true
	WaterType = TeaType
	if not IconSprite.visible:
		ShowAni.play_backwards("CShow")

	var _IconName = GameLogic.Config.LiquidConfig[WaterType].IconName
	var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
	var _Icon = load(_path)
	IconSprite.set_texture(_Icon)
	IconSprite.show()
	$IconNode.show()
	Liquid_Label.text = str(Liquid_Count)


func _on_Timer_timeout() -> void :
	if not HasContent:
		if HasWater:
			CanWaterOut = true

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)






func call_Celcius_puppet(_Celcius):
	WaterCelcius = _Celcius
	call_WaterCelcius_change()

func call_ColdTimer():

	IsCooking = false
	if WaterCelcius >= 85:
		$ColdTimer.wait_time = 6
	else:
		$ColdTimer.wait_time = 3
	$ColdTimer.start(0)
func call_Freezer_ColdTimer():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	IsFreezer = true
	$ColdTimer.wait_time = 0.2
	$ColdTimer.start(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(self, "IsFreezer", IsFreezer)
func _on_ColdTimer_timeout():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		$ColdTimer.stop()
		return

	if MixAni.assigned_animation == "Mixd":
		return
	if not CanMix:
		$ColdTimer.stop()
		return
	if Liquid_Count > 0 and not IsCooking:
		if WaterCelcius > 25:
			WaterCelcius -= 1
			if WaterCelcius >= 85:
				$ColdTimer.wait_time = 0.4
			else:
				$ColdTimer.wait_time = 0.2
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Celcius_puppet", [WaterCelcius])
			call_WaterCelcius_change()
		else:
			$ColdTimer.stop()
func call_Info_Switch(_Switch: bool):
	match _Switch:
		true:
			$MixNode.show()
			$DrawTeaNode.show()
			if Liquid_Count > 0:
				$IconNode.show()
		false:
			$IconNode.hide()
			$DrawTeaNode.hide()
			$MixNode.hide()
