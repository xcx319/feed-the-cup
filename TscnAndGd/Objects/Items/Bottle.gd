extends Head_Object

onready var typeAni = get_node("AniNode/typeAni")
onready var BottleAni = get_node("AniNode/BottleAni")
onready var FreshAni = $Effect_flies / Ani
onready var UseAni = get_node("AniNode/Use")
onready var MixAni = get_node("MixNode/MixAni")

onready var NumLabel = get_node("Icon/NumLabel")

onready var FrozenSprite = $TexNode / PoolAni / Frozen
onready var FrozenAni = $AniNode / FrozenAni

var PlayerList: Array

var IsOpen: bool
var Liquid_Count: int = 10
var WaterType
var WaterCelcius: int = 25
var HasWater: bool
var Freshness: int = - 1
var Can_Freshless: bool
var Freshless_bool: bool
var FrozenBool: bool
var IsFrozen: bool
var IsPassDay: bool
var Is_Storage: bool

signal OPENED()

onready var HoldBut = get_node("Hold")
onready var HoldX_But = HoldBut.get_node("X")
onready var But_X = get_node("But/X")
onready var Audio_Water
onready var AUDIO_OPEN

func call_Defrost_Logic():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Defrost_Logic")
	IsFrozen = false
	FrozenAni.play("init")
	FrozenSprite.hide()

	pass

func call_Defrost_Switch(_TYPE: int):
	match _TYPE:
		- 1:
			FrozenAni.play("Frozen")
		0:
			FrozenAni.play("Normal")
		1:
			FrozenAni.play("Freezer")
		2, 3:
			FrozenAni.play("Defrost")

func call_Frozen():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		FrozenAni.play("init")
		return
	if IsFrozen:
		if WaterCelcius > - 20:
			WaterCelcius -= 1
			_Frozen_modulate_logic()
		if WaterCelcius <= - 20:
			FrozenAni.play("init")

func call_Defrost():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		FrozenAni.play("init")
		return

	if get_tree().paused:
		return
	if IsFrozen:
		if WaterCelcius < 0:
			WaterCelcius += 1
			_Frozen_modulate_logic()
		if WaterCelcius == 0:
			call_Defrost_Logic()
func call_F_M_puppet(_WATERC):
	WaterCelcius = _WATERC
	_Frozen_modulate_logic()
func _Frozen_modulate_logic():
	if WaterCelcius >= - 20 and WaterCelcius <= 0:
		FrozenSprite.modulate.a8 = 255 - (WaterCelcius + 20) * 10
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_F_M_puppet", [WaterCelcius])
func call_Frozen_init():
	IsFrozen = true
	BottleAni.play("frozen")
	WaterCelcius = - 20
	FrozenSprite.show()
	FrozenAni.play("Freezer")

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func But_Hold(_Player):
	if not is_instance_valid(get_parent()):
		return
	if get_parent().name == "Weapon_note" and not IsOpen and not IsFrozen:
		HoldX_But.show_player(_Player.cur_Player)
		HoldBut.show()
	else:
		HoldBut.hide()
		HoldX_But.call_clean()
	if IsOpen:
		But_X.hide()
	else:
		if get_parent().name == "Items" or IsFrozen:
			But_X.hide()
		else:
			But_X.show()
func But_Switch(_bool, _Player):


	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
		.But_Switch(false, _Player)
		But_Hold(_Player)
		return
	if _Player.Con.IsHold:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	else:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	if IsOpen or not _Player.Con.IsHold:
		.But_Switch(_bool, _Player)
	else:
		.But_Switch(false, _Player)
	But_Hold(_Player)
func _ready() -> void :
	call_deferred("_fresh_init")
func call_Freezer_Switch(_Switch):
	Is_Storage = _Switch
func call_Frozen_Switch(_Switch: bool):
	FrozenBool = _Switch
	match _Switch:
		true:
			call_Defrost_Switch( - 1)
		false:
			call_Defrost_Switch(0)
func _fresh_init():
	if get_parent().name == "Items":
		call_deferred("call_Collision_Switch", true)
	else:
		call_deferred("call_Collision_Switch", false)
	IsItem = true
	Audio_Water = GameLogic.Audio.return_Effect("加水")
	AUDIO_OPEN = GameLogic.Audio.return_Effect("开罐")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")

func call_Broken():

	var _FreshBool: bool
	match FreshType:
		1:
			if IsOpen:
				_FreshBool = true
		2:
			if not Is_Storage:
				_FreshBool = true
		3:
			if not IsOpen and Is_Storage:
				_FreshBool = false
			elif not IsOpen:
				_FreshBool = true
			elif IsOpen and Is_Storage:
				_FreshBool = true
			else:
				Freshless_bool = true
		4:
			Freshless_bool = true
		5:


			if not FrozenBool and Is_Storage:
				if not IsPassDay:
					IsPassDay = true
				else:
					Freshless_bool = true
			elif not FrozenBool and not Is_Storage:
				Freshless_bool = true


	if _FreshBool:
		if IsPassDay and not Freshless_bool:
			Freshless_bool = true
		elif not IsPassDay:
			IsPassDay = true
	_freshless_logic()
func _freshless_logic():
	if Freshless_bool and Liquid_Count > 0:
		FreshAni.play("Flies")
	elif IsPassDay and Liquid_Count > 0:
		FreshAni.play("OverDay")
	else:
		FreshAni.play("init")
		if FrozenBool:
			IsFrozen = true
			BottleAni.play("frozen")



func _DayClosedCheck():
	if self.is_inside_tree():
		if get_parent().name == "Items":
			if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.ITEM):
				GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.ITEM)
	if Liquid_Count > 0:
		call_Broken()

func _typeAni_set():

	if has_node("AniNode/typeAni"):
		typeAni = get_node("AniNode/typeAni")
	else:
		printerr(" Bottle typeAni:", typeAni)

func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()

func call_load(_Info):
	self.name = _Info.NAME
	_SELFID = int(_Info.NAME)
	.call_Ins_Save(_SELFID)
	if not TypeStr:
		call_init(_Info.TSCN)
	if _Info.has("FrozenBool"):
		FrozenBool = _Info.FrozenBool
	if _Info.has("Liquid_Count"):
		Liquid_Count = int(_Info.get("Liquid_Count"))
	if Liquid_Count:
		HasWater = true
	NumLabel.text = str(Liquid_Count)
	if _Info.has("IsOpen"):
		IsOpen = _Info.IsOpen
	if _Info.has("Is_Storage"):
		Is_Storage = _Info.Is_Storage
	if _Info.has("Freshless_bool"):
		Freshless_bool = _Info.Freshless_bool
		IsPassDay = _Info.IsPassDay
		call_deferred("_freshless_logic")
	if _Info.has("WaterCelcius"):
		WaterCelcius = _Info.WaterCelcius

	if IsOpen:
		call_Open()
	if not Liquid_Count:
		call_Empty()
	call_bag_tex_set()
	if get_parent().name in ["A", "B", "X", "Y"]:
		call_Info_Switch(false)
func call_bag_tex_set():
	IsItem = true

	if typeAni:
		if typeAni.has_animation(TypeStr):
			typeAni.play(TypeStr)
		elif typeAni.has_animation(FuncTypePara):
			typeAni.play(FuncTypePara)
		else:
			printerr("           Bottle type错误：", TypeStr, FuncTypePara)
	Weight = GameLogic.TSCNLoad.return_weight(FuncType)
	WaterType = TypeStr

func call_player_leave(_Player):

	if PlayerList.has(_Player):
		call_SQUEEZE_end(_Player)

func call_puppet_SQUEEZE_start(_MIXSPEED, _ISOPEN):
	IsOpen = _ISOPEN
	MixAni.playback_speed = _MIXSPEED
	MixAni.play("Mixd")

func return_SQUEEZE_SPEED():
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()

	var _Mult: float = 0
	for _Player in PlayerList:
		_Mult += 1
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

	if _Mult <= 0:
		_Mult = 1
	_SPEED = _SPEED * _Mult
	return _SPEED
func return_SQUEEZE_start(_Player, _Speed):
	if IsFrozen:

		return
	if not IsOpen:
		if not PlayerList.has(_Player):
			PlayerList.append(_Player)
		MixAni.playback_speed = return_SQUEEZE_SPEED()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_SQUEEZE_start", [MixAni.playback_speed, IsOpen])
		MixAni.play("Mixd")
		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			GameLogic.Con.call_vibration(_Player.cur_Player, 0.23, 0.23, 0.1)
		return true
	return false
func call_puppet_SQUEEZE_end(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)

	_Player.call_reset_stat()
	if not GameLogic.cur_Challenge.has("手笨"):
		if MixAni.assigned_animation == "Mixd":
			MixAni.stop(false)
			CanMove = true
			return
	if MixAni.get_assigned_animation() == "Mixd":
		MixAni.play("hide")

func call_SQUEEZE_end(_Player):

	if PlayerList.has(_Player):
		PlayerList.erase(_Player)
		_Player.call_reset_stat()

	if not PlayerList.size():


		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_SQUEEZE_end", [_PLAYERPATH])
		if not GameLogic.cur_Challenge.has("手笨"):
			if MixAni.assigned_animation == "Mixd":
				MixAni.stop(false)
				CanMove = true
				return
		if MixAni.get_assigned_animation() == "Mixd":
			MixAni.play("hide")
	if get_parent().name == "Weapon_note" and not IsOpen:

		if not GameLogic.cur_Challenge.has("手笨"):

			if MixAni.assigned_animation == "Mixd":
				MixAni.stop(false)
				CanMove = true
				return
		if MixAni.get_assigned_animation() == "Mixd":
			MixAni.play("hide")
func call_puppet_Mix_Finished():
	emit_signal("OPENED")
	if FuncType in ["Pop"]:

		NumLabel.text = str(Liquid_Count)
	call_Open()
	CanMove = true
	call_Info_Switch(true)
func _Mix_Finished() -> void :

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_Mix_Finished")
	emit_signal("OPENED")
	if FuncType in ["Pop"]:

		NumLabel.text = str(Liquid_Count)
	call_Open()
	call_Info_Switch(true)
	for i in PlayerList.size():
		var _Player = PlayerList[i]
		if _Player.has_method("call_reset_stat"):
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(_Player, "call_reset_stat")
			_Player.call_reset_stat()
			GameLogic.Device.call_teach(2, _Player, self, "开盖")
			But_Switch(false, _Player)
	PlayerList.clear()
	CanMove = true

func call_Open():
	if GameLogic.cur_Day == 1:
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.GamePlay.has("新手引导1"):
			if not GameLogic.Tutorial.CheckList.has(self):
				GameLogic.Tutorial.CheckList.append(self)
	if not IsOpen:
		MixAni.play("hide")
		IsOpen = true
		if GameLogic.Config.ItemConfig.has(TypeStr):
			var _Sell = int(GameLogic.Config.ItemConfig[TypeStr].Sell)
			call_Open_Money(_Sell)

		BottleAni.play("opened")
		AUDIO_OPEN.play(0)
	else:
		BottleAni.play("opened")
	HoldBut.hide()
	HoldX_But.call_clean()

func call_WaterInDrinkCup_puppet(_TYPE, _CUPID):

	if not SteamLogic.OBJECT_DIC.has(_CUPID):
		printerr(" Plate_pup OBJECT_DIC 无_PLATEID：", _CUPID)
		return
	var _CupObj = SteamLogic.OBJECT_DIC[_CUPID]
	match _TYPE:
		"Bottle":
			HasWater = true

			call_Liquid_Out()
			if Liquid_Count > 0:
				HasWater = true
			else:
				HasWater = false
		"Hang":
			_CupObj.call_Hang(self)
			call_Liquid_Out()
		"Top":
			_CupObj.call_Top(self)
			call_Liquid_Out()

func call_WaterInDrinkCup(_ButID, _CupObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
			_CupObj.call_CupInfo_Switch(false)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			match FuncType:
				"Bottle":
					if _CupObj.Liquid_Count < _CupObj.Liquid_Max:
						But_Switch(true, _Player)
					else:
						But_Switch(false, _Player)
				"Hang":
					But_Switch(true, _Player)
				"Top":
					if _CupObj.Liquid_Count < _CupObj.Liquid_Max:
						But_Switch(false, _Player)
					else:
						But_Switch(true, _Player)
			_CupObj.call_CupInfo_Switch(true)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _CupObj.get("IsDirty"):
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NeedWash()
				return
			if FuncType in ["Hang"]:

				if not IsOpen:
					return
				if _CupObj.Hang == "" and Liquid_Count > 0:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

						SteamLogic.call_puppet_id_sync(_SELFID, "call_WaterInDrinkCup_puppet", ["Hang", _CupObj._SELFID])
					_CupObj.call_Hang(self)
					call_Liquid_Out()
					But_Switch(false, _Player)

					return "加挂壁"
				else:
					return
			if FuncType in ["Top"]:
				if not IsOpen:
					return

				if _CupObj.Top == "" and Liquid_Count > 0 and _CupObj.Liquid_Count >= _CupObj.Liquid_Max:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

						SteamLogic.call_puppet_id_sync(_SELFID, "call_WaterInDrinkCup_puppet", ["Top", _CupObj._SELFID])
					_CupObj.call_Top(self)
					call_Liquid_Out()
					But_Switch(false, _Player)

					return "加顶"
				else:
					return
			elif Liquid_Count > 0 and not Freshless_bool and IsOpen and _CupObj.Liquid_Count < _CupObj.Liquid_Max and _CupObj.Top == "":
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

					SteamLogic.call_puppet_id_sync(_SELFID, "call_WaterInDrinkCup_puppet", ["Bottle", _CupObj._SELFID])
				HasWater = true
				_CupObj.call_Water_In(_ButID, self)

				call_Liquid_Out()
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 2, WaterType, _Player)
				if Liquid_Count > 0:
					HasWater = true
				else:
					HasWater = false
				if Liquid_Count > 0 and _CupObj.Liquid_Count < _CupObj.Liquid_Max:
					But_Switch(true, _Player)
				else:
					But_Switch(false, _Player)
				return "瓶子倒入杯子"
			elif Liquid_Count > 0 and not Freshless_bool and IsOpen and _CupObj.LIQUID_DIR.has("啤酒泡"):
				if _CupObj.LIQUID_DIR["啤酒泡"] > 0:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

						SteamLogic.call_puppet_id_sync(_SELFID, "call_WaterInDrinkCup_puppet", ["Bottle", _CupObj._SELFID])
					_CupObj.Beer_In_Logic(self)
					call_Liquid_Out()
					GameLogic.Liquid.call_WaterStain(_Player.global_position, 2, WaterType, _Player)
					if Liquid_Count > 0:
						HasWater = true
					else:
						HasWater = false
					if Liquid_Count > 0 and _CupObj.LIQUID_DIR["啤酒泡"] > 0:
						But_Switch(true, _Player)
					else:
						But_Switch(false, _Player)

func call_Milk_Show():
	NumLabel.text = str(Liquid_Count)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Show_puppet", [Liquid_Count])
func call_Show_puppet(_COUNT):
	Liquid_Count = _COUNT
	NumLabel.text = str(Liquid_Count)
func call_Empty():
	if not Liquid_Count:
		HasWater = false
		BottleAni.play("out")
		NumLabel.hide()
		Freshless_bool = false
		IsPassDay = false
		_freshless_logic()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Empty_puppet")
func call_Empty_puppet():
	Liquid_Count = 0
	HasWater = false
	BottleAni.play("out")
	NumLabel.hide()
	Freshless_bool = false
	IsPassDay = false
	_freshless_logic()
func call_Num_Out(_NUM: int):
	if Liquid_Count >= _NUM:
		Liquid_Count -= _NUM
		UseAni.play("init")
		UseAni.play("use")

		Audio_Water.play(0)
	NumLabel.text = str(Liquid_Count)
	if not Liquid_Count:
		HasWater = false
		BottleAni.play("out")
func call_Liquid_Out():
	if Liquid_Count:
		Liquid_Count -= 1
		UseAni.play("init")
		UseAni.play("use")
		if FuncType in ["Hang"]:
			var _AUDIO = GameLogic.Audio.return_Effect("挤瓶")
			_AUDIO.play(0)
		elif FuncType in ["Top"]:
			var _AUDIO = GameLogic.Audio.return_Effect("喷奶油")
			_AUDIO.play(0)
		else:
			Audio_Water.play(0)
	NumLabel.text = str(Liquid_Count)
	if not Liquid_Count:
		HasWater = false
		BottleAni.play("out")

func call_broken():
	Freshless_bool = true
	_freshless_logic()
func _on_body_entered(body: Node) -> void :
	if not IsOpen and not Freshless_bool:
		var _BOOL = return_MoneyBool(body)
		if _BOOL:
			call_broken()

	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func CanMove_Switch(_bool: bool):
	CanMove = _bool

func call_Info_Switch(_Switch: bool):
	match _Switch:
		true:
			$MixNode.show()
			if Liquid_Count > 0 and IsOpen:
				$Icon.show()

		false:
			$Icon.hide()
			$MixNode.hide()
