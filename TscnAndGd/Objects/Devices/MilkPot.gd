extends Head_Object
var SelfDev = "MilkPot"

var HasMilk: bool
var HasContent
var ContentType: String
var WaterCelcius: int = 25
var IsCooking: bool
var HasWater: bool
var OverCooked: bool
var CanMix: bool
var MixPlayer
var Liquid_Count: int
var WaterType
var IsBroken: bool
var IsPassDay: bool
var IsMixing: bool

onready var WaterANI = $AniNode / WaterAni
onready var CookANI = $AniNode / CookAni
onready var A_But = $But / A
onready var X_But = $But / X
onready var CelciusBar = $Celcius
onready var TypeANI = $AniNode / TypeAni
onready var NeedMixANI = $AniNode / NeedMix
onready var FreshANI = $Effect_flies / Ani

var CanInList: Array = ["芝士", "棉花糖", "巧克力块", "黑糖", "白糖"]

func _ready() -> void :
	call_init(SelfDev)
	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():
	if HasMilk or HasContent:
		if WaterType in ["water"] and not HasContent:
			return

		if not IsPassDay:
			IsPassDay = true
		else:
			IsBroken = true
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.MILKPOT):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.MILKPOT)
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
	self.position = _Info.pos
	HasMilk = _Info.HasMilk
	HasContent = _Info.HasContent
	ContentType = _Info.ContentType
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay
		IsBroken = _Info.IsBroken
	WaterCelcius = _Info.WaterCelcius
	if _Info.has("WaterType"):
		WaterType = _Info.WaterType
		if WaterType in ["water"]:
			call_water_puppet()
	if HasMilk and WaterType in ["milk"]:
		WaterANI.play("Milk_In")
	if HasContent:
		var _NAME = ContentType + "_加入"
		CookANI.play(_NAME)
		IsMixing = false
	if HasMilk or HasContent:
		if WaterType in ["water"] and not HasContent:
			pass
		else:
			OverCooked = true
			TypeANI.play("overcook")
			NeedMixANI.play("init")

	call_Water_Logic()
	_freshless_logic()
func _freshless_logic():
	if not HasMilk and not HasContent:
		IsBroken = false
		IsPassDay = false
	if IsBroken:
		FreshANI.play("Flies")
	elif IsPassDay:
		FreshANI.play("OverDay")
	else:
		FreshANI.play("init")
func call_Cooker_Logic():
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _bool:
		if _Player.Con.IsHold:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		else:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	if CanMix:
		X_But.show()
	else:
		X_But.hide()
	.But_Switch(_bool, _Player)

func call_Milk_In(_ButID, _MilkOBJ, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not HasMilk:
				if _MilkOBJ.FuncTypePara == "milk":
					if _MilkOBJ.IsOpen:
						if _MilkOBJ.Liquid_Count == 10:
							But_Switch(true, _Player)
		0, "A":

			if not HasMilk:
				if _MilkOBJ.FuncTypePara == "milk":
					if _MilkOBJ.IsOpen:
						if _MilkOBJ.Liquid_Count == 10:
							if HasContent:
								match ContentType:
									"黑糖", "白糖":
										if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
											_Player.call_Say_FormulaWrong()
										return
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							call_Milk_Logic(_MilkOBJ, _Player)
						else:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoFullMilk()

func call_Milk_Logic(_MilkOBJ, _Player):
	HasMilk = true
	WaterType = "milk"
	NeedMixANI.play("init")
	if _MilkOBJ.get("Freshless_bool"):
		IsBroken = true
	if _MilkOBJ.get("IsPassDay"):
		IsPassDay = true
	_freshless_logic()


	WaterANI.play("Milk_In")
	WaterCelcius = 25
	_MilkOBJ.Liquid_Count = 0
	_MilkOBJ.call_Empty()

	call_Water_Logic()
	But_Switch(false, _Player)
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _MILKPATH = _MilkOBJ.get_path()
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Milk_puppet", [_MILKPATH, _PLAYERPATH])
func call_Milk_puppet(_MILKPATH, _PLAYERPATH):
	HasMilk = true
	var _MilkOBJ = get_node(_MILKPATH)
	var _Player = get_node(_PLAYERPATH)
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
	WaterANI.play("Milk_In")
	_MilkOBJ.Liquid_Count = 0
	_MilkOBJ.call_Empty()
	call_Water_Logic()
	But_Switch(false, _Player)
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
func call_Pot_In(_ButID, _PotObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _PotObj.get("Used"):
				return
			if not HasContent:
				if _PotObj.FuncTypePara in CanInList:
					if _PotObj.get("Freshless_bool"):

						return
					But_Switch(true, _Player)
		0, "A":

			if not HasContent:
				if _PotObj.FuncTypePara in CanInList:
					match _PotObj.FuncTypePara:
						"白糖", "黑糖":
							if WaterType != "water":
								if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
									_Player.call_Say_FormulaWrong()
								return
						"芝士", "棉花糖", "巧克力块":
							if Liquid_Count > 0 and WaterType != "milk":
								if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
									_Player.call_Say_FormulaWrong()
								return
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if _PotObj.get("Freshless_bool"):

						return
					if _PotObj.get("Used"):
						return
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Content_Logic", [_PotObj.FuncTypePara, _PotObj.IsPassDay])
					call_Content_Logic(_PotObj.FuncTypePara, _PotObj.IsPassDay)
					_PotObj.call_used()


func call_Content_Logic(_TYPE, _IsPassDay):
	if _IsPassDay:
		IsPassDay = true
	HasContent = true
	ContentType = _TYPE
	NeedMixANI.play("init")
	_freshless_logic()
	var _NAME = ContentType + "_加入"
	CookANI.play(_NAME)
	call_Water_Logic()
	IsMixing = false
	var _AUDIO = GameLogic.Audio.return_Effect("轻微掉落")
	_AUDIO.play(0)
func call_Water_Logic():
	if HasMilk and HasContent:
		HasWater = true
	else:
		HasWater = false
	if HasWater:
		if get_parent().name == "SavedNode":
			get_parent().get_parent().call_Cooked()
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func call_WaterCelcius_change():

	if TypeANI.assigned_animation in ["overcook"]:
		return
	if WaterCelcius >= 85:
		WaterCelcius = 85
	CelciusBar.value = WaterCelcius
	if IsCooking:
		$AniNode / Loop.play("1")
	else:
		$AniNode / Loop.play("init")
	if WaterCelcius < 85:
		TypeANI.play("cold")
	elif WaterCelcius >= 85:

		if TypeANI.assigned_animation == "cold":
			TypeANI.play("hot")
			NeedMixANI.play("NeedMix")
			CanMix = true
			X_But.show()

	if NeedMixANI.playback_speed < 0:
		return_SQUEEZE_SPEED()

	if get_parent().name == "SavedNode":
		if TypeANI.assigned_animation == "hot":
			X_But.show()
		else:
			X_But.hide()
	else:
		X_But.hide()

	pass
func call_OverCooked_puppet():
	CanMix = false
	OverCooked = true
	TypeANI.play("overcook")
func call_OverCooked():
	if not HasMilk or not HasContent:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_OverCooked_puppet")
	CanMix = false
	OverCooked = true
	TypeANI.play("overcook")
	NeedMixANI.play("init")
func call_Drop():
	if HasMilk or HasContent:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Drop")
		OverCooked = false
		HasMilk = false
		HasContent = false
		HasWater = false
		IsBroken = false
		IsPassDay = false
		IsMixing = false
		WaterType = ""
		CanMix = false
		Liquid_Count = 0
		CookANI.play("init")
		TypeANI.play("init")
		WaterANI.play("Milk_Out")
		NeedMixANI.play("init")
		var _AUDIO = GameLogic.Audio.return_Effect("倒入水槽")
		_AUDIO.play(0)
		_freshless_logic()
func call_SQUEEZE_SPEED_puppet(_SPEED, _ANIPOS):
	NeedMixANI.playback_speed = _SPEED
	NeedMixANI.play("init")
	NeedMixANI.play("NeedMix")
	NeedMixANI.advance(_ANIPOS)
	NeedMixANI.playback_speed = _SPEED


func return_SQUEEZE_SPEED():
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()
	NeedMixANI.playback_speed = _SPEED
	NeedMixANI.play("NeedMix")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_SQUEEZE_SPEED_puppet", [_SPEED, NeedMixANI.current_animation_position])
	var _Mult: float = 1
	if is_instance_valid(MixPlayer):
		if MixPlayer.BuffList.has("技能-手速"):
			_Mult += 1
		if MixPlayer.Stat.Skills.has("技能-熟练"):
			_Mult += 1
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		if not MixPlayer.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("工作手套"):
				_Mult += 1
			if GameLogic.cur_Rewards.has("工作手套+"):
				_Mult += 2
		if GameLogic.cur_Event == "手速":
			_Mult = 5

	if _Mult <= 0:
		_Mult = 1
	_SPEED = _SPEED * _Mult
	return _SPEED
func return_STIR_start(_Player):
	if get_parent().name != "SavedNode":
		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			_Player.call_Say_MixOnCooker()
		return
	if CanMix:

		if is_instance_valid(MixPlayer):
			return
		MixPlayer = _Player
		CookANI.playback_speed = return_SQUEEZE_SPEED()
		var _NAME = ContentType + "_搅拌"
		CookANI.play(_NAME)
		IsMixing = true

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_start", [CookANI.playback_speed, _NAME, IsMixing])
		return true
	return false
func call_puppet_STIR_start(_MIXSPEED, _NAME, _ISMIX):
	IsMixing = _ISMIX
	CookANI.playback_speed = _MIXSPEED
	CookANI.play(_NAME)
func call_STIR_end(_Player):

	if MixPlayer == _Player:
		MixPlayer = null
		_Player.call_reset_stat()
		CookANI.stop(false)
		IsMixing = false
		if TypeANI.assigned_animation != "finish":
			NeedMixANI.play("NeedMix")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH, NeedMixANI.current_animation_position, NeedMixANI.playback_speed])
func call_puppet_STIR_end(_PATH, _TIME, _SPEED):
	var _Player = get_node(_PATH)
	_Player.call_reset_stat()
	CookANI.stop(false)
	IsMixing = false
	if TypeANI.assigned_animation != "finish":
		NeedMixANI.playback_speed = _SPEED
		NeedMixANI.play("init")
		NeedMixANI.play("NeedMix")
		NeedMixANI.advance(_TIME)
func call_Mix_end():
	if OverCooked:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix_end_puppet")
	match ContentType:
		"芝士":
			WaterType = "芝士牛奶"
		"黑糖":
			WaterType = "黑糖水"
		"白糖":
			WaterType = "白糖水"
	TypeANI.play("finish")
	CanMix = false
	call_STIR_end(MixPlayer)
	HasWater = false
	Liquid_Count = 10
	NeedMixANI.play("init")
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
func call_Mix_end_puppet():
	match ContentType:
		"芝士":
			WaterType = "芝士牛奶"
	TypeANI.play("finish")
	CanMix = false
	call_STIR_end(MixPlayer)
	HasWater = false
	Liquid_Count = 10
	NeedMixANI.play("init")
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
func call_player_leave(_PLAYER):
	if MixPlayer == _PLAYER:
		call_STIR_end(MixPlayer)

func call_Water_Out(_NUM):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_Out_puppet")
	Liquid_Count = 0
	HasWater = false
	HasContent = false
	HasMilk = false
	IsBroken = false
	IsPassDay = false
	_freshless_logic()
	WaterANI.play("Milk_Out")
	TypeANI.play("init")
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
func call_Water_Out_puppet():
	Liquid_Count = 0
	HasWater = false
	HasContent = false
	HasMilk = false
	WaterANI.play("Milk_Out")
	TypeANI.play("init")
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
func call_ColdTimer_puppet(_CURTIME):
	NeedMixANI.play("init")
	NeedMixANI.play("NeedMix")
	NeedMixANI.advance(_CURTIME)
	NeedMixANI.playback_speed = - 1


	pass
func call_ColdTimer():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if TypeANI.assigned_animation == "hot":
		if NeedMixANI.assigned_animation == "NeedMix":
			NeedMixANI.playback_speed = - 1
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ColdTimer_puppet", [NeedMixANI.current_animation_position])
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func call_Water_In(_ButID, _DevOBJ, _Player):
	match _ButID:
		- 2:
			_DevOBJ.call_WaterInPort( - 2, self, _Player)

		- 1:

			_DevOBJ.call_WaterInPort( - 1, self, _Player)

		0:
			if not HasMilk:
				if HasContent:
					match ContentType:
						"黑糖", "白糖":
							pass
						_:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_FormulaWrong()
							return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					_DevOBJ.call_WaterInPort( - 1, self, _Player)
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "call_water_puppet")
				_DevOBJ.call_Water_Out(10)
				call_water_puppet()
				_DevOBJ.call_WaterInPort( - 1, self, _Player)
				return true
		3:
			if HasMilk or HasContent:
				var _return = _DevOBJ.call_WaterDrop(_ButID, self, _Player)
				_DevOBJ.call_WaterInPort( - 1, self, _Player)
				return _return
func call_water_puppet():
	HasMilk = true
	WaterCelcius = 25
	Liquid_Count = 10
	WaterType = "water"
	WaterANI.play("water_In")
	call_Water_Logic()
func call_Sugar_In(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not HasContent:
				match _HoldObj.FuncTypePara:
					"黑糖", "白糖":
						But_Switch(true, _Player)
		0:
			if not HasContent:
				match _HoldObj.FuncTypePara:
					"黑糖":
						if _HoldObj.Used:
							return
						CookANI.play("黑糖_加入")
						HasContent = true
						ContentType = _HoldObj.FuncTypePara
						_HoldObj.call_used()
						call_Water_Logic()
						call_Sugar_In( - 2, _HoldObj, _Player)
					"白糖":
						if _HoldObj.Used:
							return
						CookANI.play("白糖_加入")
						HasContent = true
						ContentType = _HoldObj.FuncTypePara
						_HoldObj.call_used()
						call_Water_Logic()
						call_Sugar_In( - 2, _HoldObj, _Player)
					_:
						return
