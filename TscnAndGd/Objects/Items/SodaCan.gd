extends Head_Object

var _DeltaTime: int
var TYPE
var Is_Mix: bool
var MixInt: int = 0
var Can_Mix: bool
var SugarType: int
var Pop: int = 0
var HasIce: bool
var HasHot: bool
var Top: String = ""
var Hang: String = ""

var LIQUID_DIR: Dictionary
var LIQUID_ARRAY: Array
var WaterCelcius: int = 25
var Celcius: String
var cur_ID: int
var Liquid_Max: int
var Liquid_Count: int
var Extra_1: String
var Extra_2: String
var Extra_3: String
var Extra_4: String
var Extra_5: String
var Condiment_1: String
var Condiment_2: String
var Condiment_3: String
var IsPassDay: bool
var IsPickUp: bool
var PlayerList: Array

var IsStale: bool
var IsPack: bool

onready var CupAni = get_node("AniNode/CupAni")
onready var CupTypeAni = get_node("AniNode/CupTypeAni")
onready var CupTempratureAni = get_node("AniNode/CupTempratureAni")

onready var CupInfoAni

onready var CupCelciusAni
onready var SugarAni
onready var SugarIcon
onready var CupInfoNode

onready var Extra_1_Ani = get_node("AniNode/Extra_1")
onready var Extra_2_Ani = get_node("AniNode/Extra_2")
onready var Extra_3_Ani = get_node("AniNode/Extra_3")
onready var Condiment_1_Ani = get_node("AniNode/CondimentAni")
onready var TopAni = $AniNode / Top
onready var HangAni = $AniNode / HangCup
onready var PackAni = $AniNode / PackAni

onready var FreshlessSprite
onready var ButNode

var _TouchedPlayer: Array
var SELLPLAYER
var TipBonus: int = 0

func call_touch(_Player):
	if not _TouchedPlayer.has(_Player.cur_Player):
		if _TouchedPlayer.size():
			if _Player.Stat.Skills.has("技能-接替"):
				TipBonus += 5
		_TouchedPlayer.append(_Player.cur_Player)

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func call_PlayerOutLine(_Type: int):
	match _Type:
		0:
			get_node("CupInfo/OutLineAni").play("init")
		1, SteamLogic.STEAM_ID:
			get_node("CupInfo/OutLineAni").play("1")
		2:
			get_node("CupInfo/OutLineAni").play("2")
func call_FinishUpdate():
	if GameLogic.cur_Rewards.has("退单COMBO"):
		if has_node("AniNode/Up_Lid"):
			get_node("AniNode/Up_Lid").play("1")
	if GameLogic.cur_Rewards.has("退单COMBO+"):
		if has_node("AniNode/Up_Lid"):
			get_node("AniNode/Up_Lid").play("2")
	if GameLogic.cur_Rewards.has("杯套"):
		if has_node("AniNode/Up_Mat"):
			get_node("AniNode/Up_Mat").play("1")
	if GameLogic.cur_Rewards.has("杯套+"):
		if has_node("AniNode/Up_Mat"):
			get_node("AniNode/Up_Mat").play("2")
	if GameLogic.cur_Rewards.has("吸管"):
		if has_node("AniNode/Up_Straw"):
			get_node("AniNode/Up_Straw").play("1")
	if GameLogic.cur_Rewards.has("吸管+"):
		if has_node("AniNode/Up_Straw"):
			get_node("AniNode/Up_Straw").play("2")
	if GameLogic.cur_Rewards.has("跳单补偿"):
		if has_node("AniNode/Up_Logo"):
			get_node("AniNode/Up_Logo").play("1")
	if GameLogic.cur_Rewards.has("跳单补偿+"):
		if has_node("AniNode/Up_Logo"):
			get_node("AniNode/Up_Logo").play("2")
func call_table():
	var _AUDIO = GameLogic.Audio.return_Effect("错误出单")
	_AUDIO.play(0)
	get_node("AniNode/FinishAni").play("Table")
	if has_node("Sell"):
		$Sell / AnimationPlayer.play("Table")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_table")
func call_finish(_switch: bool):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_finish", [_switch])
	match _switch:
		true:
			var _AUDIO = GameLogic.Audio.return_Effect("正确出单")
			_AUDIO.play(0)
			get_node("AniNode/FinishAni").play("Right")
			call_FinishUpdate()
			get_node("Hold").hide()
		false:
			var _AUDIO = GameLogic.Audio.return_Effect("错误出单")
			_AUDIO.play(0)
			get_node("AniNode/FinishAni").play("Wrong")

func call_OverID():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_OverID")
	get_node("AniNode/FinishAni").play("OverID")

func But_Hold(_Player):
	if not is_instance_valid(get_parent()):
		get_node("Hold").hide()
		return
	if get_parent().name == "Weapon_note" and Can_Mix:
		if has_node("Hold/X") and _Player != null:
			get_node("Hold/X").ButPlayer = _Player.cur_Player
			get_node("Hold").show()
	else:
		get_node("Hold").hide()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	ButNode.show()
	But_Hold(_Player)
	if _Player.Con.IsHold:
		var A_But = get_node("But/A")
		var Y_But = get_node("But/Y")

		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)

		Y_But.hide()

	else:
		var A_But = get_node("But/A")
		var Y_But = get_node("But/Y")

		Y_But.hide()

		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		if Liquid_Count == Liquid_Max and get_parent().get_parent().editor_description == "WorkBench_Immovable":
			Y_But.show()
	.But_Switch(_bool, _Player)

func _DayClosedCheck():
	if not is_instance_valid(self):
		return

	if not IsPack:
		Pop = 0
	if _FREEZERBOOL:
		WaterCelcius = 1
	else:
		WaterCelcius = 25
var _FREEZERBOOL: bool
func call_Freezer_Switch(_Switch: bool):
	_FREEZERBOOL = _Switch

func _TimeChange_Logic():
	if _FREEZERBOOL:
		if Liquid_Count > 0:
			if WaterCelcius > 10:
				WaterCelcius -= 10
	else:
		if not IsPack:
			if WaterCelcius < 25:
				WaterCelcius += 1
	_WaterCelcius_Show()

func _ready() -> void :
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	IsItem = true
	Weight = 1
	_onready_init()
	if has_node("B"):
		get_node("B").hide()
	FuncType = "SodaCan"
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")

	call_deferred("Update_Check")
func Update_Check():
	if not GameLogic.GameUI.is_connected("TimeChange", self, "_TimeChange_Logic"):
		var _check = GameLogic.GameUI.connect("TimeChange", self, "_TimeChange_Logic")
	if not is_instance_valid(get_parent()):
		return
	if get_parent().name in ["TexNode", "Info"]:
		return
	if GameLogic.cur_Rewards.has("包装升级"):
		if has_node("AniNode/Up_Cup"):
			get_node("AniNode/Up_Cup").play("1")
	if GameLogic.cur_Rewards.has("包装升级+"):
		if has_node("AniNode/Up_Cup"):
			get_node("AniNode/Up_Cup").play("2")

func call_load_TSCN(_TSCN):

	call_CupType_Init(_TSCN)
	.call_Ins_Save(_SELFID)

func call_CupType_Init(_TSCN):
	match _TSCN:
		"SodaCan_S":
			call_CupType_init("SodaCan_S", false, - 1)
		"SodaCan_M":
			call_CupType_init("SodaCan_M", false, - 1)
		"SodaCan_L":
			call_CupType_init("SodaCan_L", false, - 1)

func call_load(_info):

	_SELFID = int(_info.NAME)
	self.name = _info.NAME
	self.position = _info.pos
	SteamLogic.OBJECT_DIC[_SELFID] = self
	match _info.TSCN:
		"SodaCan_S":
			call_CupType_init("SodaCan_S", false, - 1)
		"SodaCan_M":
			call_CupType_init("SodaCan_M", false, - 1)
		"SodaCan_L":
			call_CupType_init("SodaCan_L", false, - 1)

	Is_Mix = _info.Is_Mix
	SugarType = int(_info.SugarType)
	if SugarType:
		call_Sugar_In(SugarType)

	if _info.has("LIQUID_DIR"):
		LIQUID_DIR = _info.LIQUID_DIR
	WaterCelcius = _info.WaterCelcius
	_WaterCelcius_Show()
	cur_ID = _info.cur_ID

	Liquid_Count = _info.Liquid_Count
	Extra_1 = _info.Extra_1
	Extra_2 = _info.Extra_2
	Extra_3 = _info.Extra_3
	if _info.has("Extra_4"):
		Extra_4 = _info.Extra_4
	if _info.has("Extra_5"):
		Extra_5 = _info.Extra_5
	call_add_extra()
	if _info.has("Condiment_1"):
		Condiment_1 = _info.Condiment_1
		Condiment_2 = _info.Condiment_2
		Condiment_3 = _info.Condiment_3
		call_Condiment_play(Condiment_1)
	IsPassDay = _info.IsPassDay
	if IsPassDay:
		FreshlessSprite.show()
	if Liquid_Count > 0:
		var _NAME = "Layer" + str(Liquid_Count)
		CupAni.play(_NAME)
		CupInfoNode.CupAni.play(_NAME)
		var _ColorArray: Array = _info.LayerArray
		for _i in _ColorArray.size():
			var _LayerNAME = "Layer" + str(_i)
			var _COLOR: Color
			if _ColorArray[_i]:
				_COLOR = _ColorArray[_i]
			get_node("TexNode/Tex/Layer").get_node(_LayerNAME).self_modulate = _COLOR
			get_node("CupInfo/bg/DrinkCup/TexNode/Tex/Layer").get_node(_LayerNAME).self_modulate = _COLOR
	if _info.has("IsPack"):
		IsPack = _info.IsPack
		if IsPack:
			Can_Mix = false
		_IsPack_Logic()
	if _info.has("Pop"):
		Pop = _info.Pop
		call_Pop_Logic()
	if _info.has("_FREEZERBOOL"):
		_FREEZERBOOL = _info._FREEZERBOOL
	if _info.has("IsPassDay"):
		IsPassDay = _info.IsPassDay
	if _info.has("IsStale"):
		IsStale = _info.IsStale
	if IsPassDay:
		IsStale = true
	if IsStale:
		FreshlessSprite.show()
		$Effect_flies / Ani.play("Flies")
	elif IsPassDay:
		$Effect_flies / Ani.play("OverDay")
	Update_Check()

func _IsPack_Logic():
	match IsPack:
		true:
			PackAni.play("Pack")

func call_pack():
	if not IsPack:
		IsPack = true
		Can_Mix = false
		_IsPack_Logic()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_pack")
func call_Ticket(_ID: int, _Player):

	if GameLogic.Order.cur_CupArray.has(_ID):

		return
	if cur_ID > 0:
		if GameLogic.Order.cur_CupArray.has(cur_ID):
			GameLogic.Order.cur_CupArray.erase(cur_ID)
		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			GameLogic.Order.call_del_cup_logic(cur_ID)
	GameLogic.Order.call_pickup_cup_logic(_ID, _Player.cur_Player)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "_Ticket_Show", [_ID])
	_Ticket_Show(_ID)

func _Ticket_Show(_ID):

	cur_ID = _ID
	get_node("CupInfo/IDLabel").text = str(cur_ID)

func return_color_layer(_LayerNum: int):
	var _LayerName = "Layer" + str(_LayerNum)
	return get_node("TexNode/Tex/Layer").get_node(_LayerName).self_modulate




func call_reset_pickup():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var CurSelect = cur_ID
	call_Sell_hide()
	var _NPC = GameLogic.Order.return_Picker_Order_PickUp(CurSelect)
	if is_instance_valid(_NPC):
		if _NPC.IsPickUp:
			_NPC.call_pickUp_false()

func _onready_init():
	if self.has_node("CupInfo/CupInfoAni"):
		CupInfoAni = get_node("CupInfo/CupInfoAni")
	if self.has_node("CupInfo/CupCelciusAni"):
		CupCelciusAni = get_node("CupInfo/CupCelciusAni")
	if self.has_node("CupInfo/SugarAni"):
		SugarAni = get_node("CupInfo/SugarAni")

	if self.has_node("CupInfo/bg/DrinkCup"):
		CupInfoNode = get_node("CupInfo/bg/DrinkCup")
	if self.has_node("But"):
			ButNode = get_node("But")
	if self.has_node("Freshless"):
		FreshlessSprite = get_node("Freshless")
func call_CupType_init(_Type, _InfoShow: bool, _PLAYERID: int):
	TYPE = _Type
	call_init(TYPE)
	CupTypeAni.play(TYPE)
	CupInfoNode.CupTypeAni.play(TYPE)
	_config_SYCN()
	if _InfoShow:
		if _PLAYERID in [1, 2, SteamLogic.STEAM_ID]:
			if CupInfoAni.assigned_animation != "show":
				CupInfoAni.play("show")

		pass
func call_cleanID():

	if GameLogic.Order.cur_CupArray.has(cur_ID):
		GameLogic.Order.cur_CupArray.erase(cur_ID)

func _config_SYCN():
	if FuncTypePara != null:
		Liquid_Max = int(FuncTypePara)

func call_CupInfo_Switch(_Switch):
	match _Switch:
		true:
			if CupInfoAni.assigned_animation != "show":
				CupInfoAni.play("show")

		false:
			call_CupInfo_Hide()

func call_CupInfo_Hide():
	if CupInfoAni.assigned_animation != "hide":
		if CupInfoAni.assigned_animation != "init":
			CupInfoAni.play("hide")
	if has_node("B"):
		get_node("B").hide()
func call_Sugar_In(_TYPE: int):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Sugar_In", [_TYPE])
	SugarType = _TYPE

	match SugarType:
		1:
			SugarAni.play("Sugar")
		2:
			SugarAni.play("Free")

func call_Water_In(_ButID, _OutObj):
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)

	match _ButID:
		- 1:

			call_CupInfo_Switch(true)
		0:

			Water_In_Logic(_OutObj)









func _Mix_Check(_BeforeInDir):
	get_node("Hold/X").hide()
	if IsPack:
		Can_Mix = false
		return
	if LIQUID_DIR.size() > _BeforeInDir.size() and LIQUID_DIR.size() > 1:
		if Top != "" or Hang in ["上层焦糖", "上层巧克力"]:
			Can_Mix = false
		else:
			Can_Mix = true

		Is_Mix = false

		get_node("Hold/X").show()
		But_Hold(null)
		return
	elif LIQUID_DIR.size() > 1:
		var _Keys = LIQUID_DIR.keys()
		var _bool: bool = false
		for i in _Keys.size():
			var _Num: float = float(LIQUID_DIR[_Keys[i]]) / Liquid_Count
			var _BeforeNum: float = float(_BeforeInDir[_Keys[i]]) / (Liquid_Count - 1)

			if _BeforeNum != _Num:
				_bool = true

		if _bool:
			if Top != "" or Hang in ["上层焦糖", "上层巧克力"]:
				Can_Mix = false
			else:
				Can_Mix = true
			Is_Mix = false
			get_node("Hold/X").show()
			But_Hold(null)
			return
	elif LIQUID_DIR.size() == 1:
		Can_Mix = false
		Is_Mix = true

func call_Shelf_Logic(_ButID, _Player, _Obj):
	if _ButID >= 0:
		if GameLogic.Device.return_CanUse_bool(_Player):
			return

		if Top != "":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_NoUse()
				return
		var _CHECK = _Obj.FuncType
		match _Obj.FuncType:
			"Con_Liquid", "TeaBarrel", "PopCap", "PopWaterMachine":
				return _Obj.call_WaterInDrinkCup(0, self, _Player)
			"Can":
				return _Obj.call_add_extra(0, _Player, self)
			"Bottle", "Hang", "Top":

				return _Obj.call_WaterInDrinkCup(0, self, _Player)
			"ShakeCup":

				if _Obj.CanOut and Liquid_Count < Liquid_Max and _Obj.Liquid_Count > 0:
					return _Shake_In_Drink(_Obj)
func call_ShakeCup_In_DrinkCup(_ButID, _Player, _ShakeObj):
	if not _ShakeObj.Is_Mix:
		return
	match _ButID:
		- 2:

			_ShakeObj.But_Switch(false, _Player)
			_ShakeObj.call_CupInfo_Switch(false)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_ShakeObj.But_Switch(true, _Player)
			_ShakeObj.call_CupInfo_Switch(true)
		0:
			if _ShakeObj.Liquid_Count > 0 and Liquid_Count < Liquid_Max:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if Top != "":
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
						return
				_Shake_In_Drink(_ShakeObj)
func _Shake_In_Drink(_ShakeObj):
	var _LIQUID_DIC: Dictionary
	for _TYPE in LIQUID_DIR:
		_LIQUID_DIC[_TYPE] = float(LIQUID_DIR[_TYPE]) / Liquid_Count

	var _JoinNum: int = Liquid_Max - Liquid_Count
	if _ShakeObj.Liquid_Count < _JoinNum:
		_JoinNum = _ShakeObj.Liquid_Count


	for _TYPE in _ShakeObj.LIQUID_DIR:
		var _Num = float(_ShakeObj.LIQUID_DIR[_TYPE]) / _ShakeObj.Liquid_Count * _JoinNum
		if LIQUID_DIR.has(_TYPE):
			LIQUID_DIR[_TYPE] += _Num
		else:
			LIQUID_DIR[_TYPE] = _Num

	var _BaseLiquid: int = Liquid_Count
	Liquid_Count += _JoinNum
	Weight += _JoinNum

	if Liquid_Count == _JoinNum:
		Is_Mix = true
		Can_Mix = false
	else:
		var _MixCheck: bool = false
		for _TYPE in LIQUID_DIR:
			if _LIQUID_DIC.has(_TYPE):
				if _LIQUID_DIC[_TYPE] != float(LIQUID_DIR[_TYPE]) / Liquid_Count:
					_MixCheck = true
			else:
				_MixCheck = true
		if _MixCheck:
			Is_Mix = false
			Can_Mix = true

	if _ShakeObj.SugarType > 0 and not SugarType:
		call_Sugar_In(_ShakeObj.SugarType)
	var _FUNCTYPE = _ShakeObj.get("FuncType")
	var _CELCIUS = _ShakeObj.WaterCelcius
	_WaterShow(_FUNCTYPE, _CELCIUS)
	var _modulate_Mix = _ShakeObj.get_node("TexNode/Tex/Layer").get_node("Layer0").modulate
	get_node("TexNode/Tex/Layer").get_node("Layer0").modulate = _modulate_Mix
	for i in (Liquid_Count):

		if i >= _BaseLiquid:
			var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
			_LayerSprite.modulate = _modulate_Mix
			var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
			var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")
			_InfoLayer0.modulate = _modulate_Mix
			_InfoLayerSpr.modulate = _modulate_Mix
	_ShakeObj.call_Water_Out(_JoinNum)

func return_add_Extra(_EXTRATYPE):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if IsPack:
		return
	var _CheckExtra: int = 0
	if Extra_1 == "":
		_CheckExtra = 1
	elif Extra_2 == "" and TYPE in ["SodaCan_M", "SodaCan_L"]:
		_CheckExtra = 2
	elif Extra_3 == "" and TYPE in ["SodaCan_L"]:
		_CheckExtra = 3
	if _CheckExtra > 0:

		match _CheckExtra:
			1:
				Extra_1 = _EXTRATYPE
			2:
				Extra_2 = _EXTRATYPE
			3:
				Extra_3 = _EXTRATYPE
		call_add_extra()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_add_Extra_puppet", [_CheckExtra, _EXTRATYPE])
		return true
	return false
func call_add_Extra_puppet(_TYPE, _EXTRA):
	match _TYPE:
		1:
			Extra_1 = _EXTRA
		2:
			Extra_2 = _EXTRA
		3:
			Extra_3 = _EXTRA
	call_add_extra()

func _WaterCelcius_Show():
	if WaterCelcius == 0:
		WaterCelcius = 25
	if WaterCelcius >= 20 and WaterCelcius < 50:
		if Celcius != "Normal":
			Celcius = "Normal"
		HasIce = false
		HasHot = false
		if CupCelciusAni.assigned_animation != "Normal":
			CupCelciusAni.play("Normal")
		if CupTempratureAni.assigned_animation != "Normal":
			CupTempratureAni.play("Normal")
		if CupInfoNode.CupTempratureAni.assigned_animation != "Normal":
			CupInfoNode.CupTempratureAni.play("Normal")
	elif WaterCelcius < 20:
		if Celcius != "Cold":
			Celcius = "Cold"
		HasIce = true
		HasHot = false
		if CupCelciusAni.assigned_animation != "Cold":
			CupCelciusAni.play("Cold")
		if CupTempratureAni.assigned_animation != "Cold":
			CupTempratureAni.play("Cold")
		if CupInfoNode.CupTempratureAni.assigned_animation != "Cold":
			CupInfoNode.CupTempratureAni.play("Cold")
	elif WaterCelcius >= 50:
		if Celcius != "Hot":
			Celcius = "Hot"
		HasIce = false
		HasHot = true
		if CupCelciusAni.assigned_animation != "Hot":
			CupCelciusAni.play("Hot")
		if CupTempratureAni.assigned_animation != "Hot":
			CupTempratureAni.play("Hot")
		if CupInfoNode.CupTempratureAni.assigned_animation != "Hot":
			CupInfoNode.CupTempratureAni.play("Hot")
func _WaterShow(_FUNCTYPE, _CELCIUS):
	var _Layer = "Layer" + str(Liquid_Count)
	CupAni.play(_Layer)
	CupInfoNode.CupAni.play(_Layer)
	match _FUNCTYPE:
		"HotWaterMachine":
			if HasIce:
				HasIce = false
				WaterCelcius = 25
			else:
				HasHot = true
				WaterCelcius = 85
		"IceMachine":
			if HasHot:
				HasHot = false
				WaterCelcius = 25
			else:
				HasIce = true
				WaterCelcius = 5
		_:
			if not HasIce and not HasHot:
				if _CELCIUS >= 50:
					if WaterCelcius < 20 and WaterCelcius > 0:
						WaterCelcius = 25


					else:
						WaterCelcius = 85
				elif _CELCIUS > 0 and _CELCIUS < 20:
					if WaterCelcius >= 50:
						WaterCelcius = 25
					elif WaterCelcius < 50:
						WaterCelcius = 5
	_WaterCelcius_Show()

func _ColorShow(_WATERTYPE):
	var _Layer = "Layer" + str(Liquid_Count)
	var _WaterType = _WATERTYPE
	var _LayerSprite = get_node("TexNode/Tex/Layer").get_node(_Layer)
	var _Layer0 = get_node("TexNode/Tex/Layer/Layer0")
	var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node(_Layer)
	var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")

	var _color8 = GameLogic.Liquid.return_color_set(_WaterType)

	_Layer0.set_self_modulate(_color8)
	_InfoLayer0.set_self_modulate(_color8)

	_LayerSprite.set_self_modulate(_color8)
	_InfoLayerSpr.set_self_modulate(_color8)



func water_In_puppet(_COUNT, _WEIGHT, _WATERTYPE, _WATERDIR, _FUNCTYPE, _CELCIUS):
	Liquid_Count = _COUNT
	Weight = _WEIGHT
	call_Liquid_Logic(_WATERTYPE)
	_Mix_Check(_WATERDIR)
	_WaterShow(_FUNCTYPE, _CELCIUS)
	_ColorShow(_WATERTYPE)
func call_CoffeeMachine_In(_WATERTYPE, _FUNCTYPE, _CELCIUS):
	if Liquid_Count < Liquid_Max:
		Liquid_Count += 1
		Weight += 1

		var _BeforeInDir: Dictionary
		var _Keys = LIQUID_DIR.keys()
		for i in _Keys.size():
			var _Name = _Keys[i]
			_BeforeInDir[_Name] = LIQUID_DIR[_Name]

		call_Liquid_Logic(_WATERTYPE)
		_Mix_Check(_BeforeInDir)

		_WaterShow(_FUNCTYPE, _CELCIUS)
		_ColorShow(_WATERTYPE)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "water_In_puppet", [Liquid_Count, Weight, _WATERTYPE, _BeforeInDir, _FUNCTYPE, _CELCIUS])

func Water_In_Logic(_OutObj):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if _OutObj.HasWater:
		if Liquid_Count < Liquid_Max:
			if _OutObj.Liquid_Count > 0:
				Liquid_Count += 1
				if _OutObj.IsPassDay:
					call_add_PassDay()
				var _BeforeInDir: Dictionary
				var _Keys = LIQUID_DIR.keys()
				for i in _Keys.size():
					var _Name = _Keys[i]
					_BeforeInDir[_Name] = LIQUID_DIR[_Name]
				var _WATERTYPE = _OutObj.get("WaterType")
				call_Liquid_Logic(_WATERTYPE)
				_Mix_Check(_BeforeInDir)
				var _FUNCTYPE = _OutObj.get("FuncType")
				var _CELCIUS = _OutObj.WaterCelcius
				_WaterShow(_FUNCTYPE, _CELCIUS)
				_ColorShow(_WATERTYPE)
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "water_In_puppet", [Liquid_Count, Weight, _WATERTYPE, _BeforeInDir, _FUNCTYPE, _CELCIUS])
				if _OutObj.has_method("call_Water_Out"):
					_OutObj.call_Water_Out(1)
				if _OutObj.FuncType in ["PopCap", "PopWaterMachine"]:
					if Pop == 0 and _OutObj.Pop > 0:
						Pop = _OutObj.Pop
						call_Pop_Logic()
					elif Pop > _OutObj.Pop:
						Pop = _OutObj.Pop
						call_Pop_Logic()
				if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
					if GameLogic.cur_Day == 1 and Liquid_Count == Liquid_Max:
						GameLogic.Tutorial.NeedSell = true

func call_Water_AllIn_puppet(_NeedLiquid, _WATERTYPE, _FUNCTYPE, _CELCIUS):
	for _i in _NeedLiquid:
		Liquid_Count += 1
		var _BeforeInDir: Dictionary
		var _Keys = LIQUID_DIR.keys()
		for i in _Keys.size():
			var _Name = _Keys[i]
			_BeforeInDir[_Name] = LIQUID_DIR[_Name]

		call_Liquid_Logic(_WATERTYPE)
		_Mix_Check(_BeforeInDir)

		_WaterShow(_FUNCTYPE, _CELCIUS)
		_ColorShow(_WATERTYPE)

func call_Water_AllIn(_OutObj):

	if _OutObj.HasWater:
		if Liquid_Count < Liquid_Max:
			var _NeedLiquid: int = Liquid_Max - Liquid_Count
			if _OutObj.Liquid_Count < _NeedLiquid:
				_NeedLiquid = _OutObj.Liquid_Count
			var _WATERTYPE = _OutObj.get("WaterType")
			var _FUNCTYPE = _OutObj.get("FuncType")
			var _CELCIUS = _OutObj.WaterCelcius
			var _BeforeInDir: Dictionary
			for _i in _NeedLiquid:
				Liquid_Count += 1
				var _Keys = LIQUID_DIR.keys()
				for i in _Keys.size():
					var _Name = _Keys[i]
					_BeforeInDir[_Name] = LIQUID_DIR[_Name]

				call_Liquid_Logic(_WATERTYPE)
				_Mix_Check(_BeforeInDir)

				_WaterShow(_FUNCTYPE, _CELCIUS)
				_ColorShow(_WATERTYPE)




			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_AllIn_puppet", [_NeedLiquid, _WATERTYPE, _FUNCTYPE, _CELCIUS])
			if _OutObj.IsPassDay:
				call_add_PassDay()
			call_PopIn(_OutObj)
			if _OutObj.has_method("call_Water_Out"):
				_OutObj.call_Water_Out(_NeedLiquid)
func call_PopIn(_OutObj):
	if _OutObj.FuncType in ["PopCap", "PopWaterMachine"]:
		if Pop == 0 and _OutObj.Pop > 0:
			Pop = _OutObj.Pop
			call_Pop_Logic()
		elif Pop > _OutObj.Pop:
			Pop = _OutObj.Pop
			call_Pop_Logic()

func call_Pop_puppet(_POPNUM):
	Pop = _POPNUM
	call_Pop_Logic()

func call_Info_Switch(_Switch: bool):
	call_CupInfo_Switch(_Switch)

func call_Pop_Logic():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Pop_puppet", [Pop])
	var _CUPINFOPOP = $CupInfo / PopIconAni
	match Pop:
		1:
			_CUPINFOPOP.play("pop1")
			$AniNode / PopAni.play("pop1")
			$CupInfo / bg / DrinkCup / AniNode / PopAni.play("pop1")
		2:
			_CUPINFOPOP.play("pop2")
			$AniNode / PopAni.play("pop2")
			$CupInfo / bg / DrinkCup / AniNode / PopAni.play("pop2")
		3:
			_CUPINFOPOP.play("pop3")
			$AniNode / PopAni.play("pop3")
			$CupInfo / bg / DrinkCup / AniNode / PopAni.play("pop3")
		_:
			_CUPINFOPOP.play("init")
			$AniNode / PopAni.play("init")
			$CupInfo / bg / DrinkCup / AniNode / PopAni.play("init")
func call_Liquid_Logic(_Type):
	if not LIQUID_DIR.has(_Type):
		LIQUID_DIR[_Type] = 1
	else:
		LIQUID_DIR[_Type] += 1
	LIQUID_ARRAY.append(_Type)



func call_AddIce():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_AddIce")
	HasHot = false
	HasIce = true
	if IsPassDay:
		return
	if Celcius != "Cold":
		WaterCelcius = 5
		Celcius = "Cold"
		CupCelciusAni.play("Cold")
		CupTempratureAni.play("Cold")


func call_AddNormal():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_AddNormal")

	HasHot = false
	HasIce = false
	if Celcius != "Normal":
		WaterCelcius = 25
		Celcius = "Normal"
		CupCelciusAni.play("Normal")
		CupTempratureAni.play("Normal")
		CupInfoNode.CupTempratureAni.play("Normal")

func call_AddHot():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_AddHot")

	HasHot = true
	HasIce = false
	if Celcius != "Hot":
		WaterCelcius = 85
		Celcius = "Hot"
		CupCelciusAni.play("Hot")
		CupTempratureAni.play("Hot")
		CupInfoNode.CupTempratureAni.play("Hot")

func return_CanMix_old(_Con):
	if Can_Mix:
		return true
	return false
func return_CanMix_Puppet(_SPEED):

	get_node("MixNode/MixAni").playback_speed = _SPEED
	get_node("MixNode/MixAni").play("Mixd")

func return_CanMix(_Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return false
	if Can_Mix and Top == "":

		var _Speed: float = 1
		var _Mult: float = 1

		_Speed = _Speed / GameLogic.return_Multiplier_Division()
		if _Player.BuffList.has("技能-手速"):
			_Mult += 0.5
		if not _Player.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("一次性手套"):
				_Mult += 0.5
			if GameLogic.cur_Rewards.has("一次性手套+"):
				_Mult += 1.5
			if GameLogic.cur_Challenge.has("手笨+"):
				_Mult = _Mult * 0.75

		if _Player.Stat.Skills.has("技能-灵巧"):
			_Mult += 1.5
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		if GameLogic.cur_Event == "手速":
			_Mult = 20

		var _SPEED: float = _Speed * _Mult
		get_node("MixNode/MixAni").playback_speed = _SPEED
		get_node("MixNode/MixAni").play("Mixd")
		if not PlayerList.has(_Player):
			PlayerList.append(_Player)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "return_CanMix_Puppet", [_SPEED])
		return true
	return false

func call_CanMix_Finish():

	if Can_Mix:
		Is_Mix = true
		Can_Mix = false
		But_Hold(null)
		call_mix()

		get_node("MixNode/MixAni").play("hide")
		for i in PlayerList.size():
			var _Player = PlayerList[i]

			if is_instance_valid(_Player):
				if _Player.has_method("call_reset_stat"):
					_Player.call_reset_stat()

		return "摇匀"
	return
func return_Liquid_Ani():

	if Is_Mix:

		var _MenuNum = GameLogic.cur_Menu.size()

		for m in _MenuNum:

			if not GameLogic.Config.FormulaConfig.has(GameLogic.cur_Menu[m]):
				return
			var _INFO = GameLogic.Config.FormulaConfig[GameLogic.cur_Menu[m]]

			var _TYPECHECK: bool
			match TYPE:
				"SodaCan_S":
					if _INFO.CupType == "S":
						_TYPECHECK = true
				"SodaCan_M":
					if _INFO.CupType == "M":
						_TYPECHECK = true
				"SodaCan_L":
					if _INFO.CupType == "L":
						_TYPECHECK = true

			var _ForDic: Dictionary
			if _TYPECHECK:
				var _ForMax = int(_INFO.FormulaNum)
				for f in _ForMax:
					var FORID = "For_" + str(f + 1)
					var FORNUM = FORID + "_Num"
					var _FORTYPE = _INFO[FORID]
					var _FORNUM = _INFO[FORNUM]
					_ForDic[_FORTYPE] = _FORNUM
				var _Keys = LIQUID_DIR.keys()
				var _Checkbool: bool = true
				for _TypeName in _Keys:
					if _ForDic.has(_TypeName):
						var _ForLiquid: float = float(_ForDic[_TypeName])
						var _CupLiquid: float = float(LIQUID_DIR[_TypeName])
						if _CupLiquid != _ForLiquid:
							_Checkbool = false
					else:
						_Checkbool = false
				if _Checkbool:

					return _INFO.LiquidName


	return null
func call_mix():
	var _LiquidName = return_Liquid_Ani()

	if _LiquidName != null:
		call_Liquid_Set(_LiquidName)
	else:
		_Color_Mixed()
func call_Liquid_Set(_LiquidName):

	var _color8 = GameLogic.Liquid.return_color_set(_LiquidName)

	for i in Liquid_Count:
		var _LayerNum: int = i + 1
		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(_LayerNum))
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(_LayerNum))
		if _LayerNum <= Liquid_Count:
			if _LayerNum == Liquid_Count:
				get_node("TexNode/Tex/Layer").get_node("Layer0").set_self_modulate(_color8)
				CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer0").set_self_modulate(_color8)





			_LayerSprite.set_self_modulate(_color8)
			_InfoLayerSpr.set_self_modulate(_color8)




func call_Liquid_Array(_Array: Array):
	var _NUM: int = 1
	var _Alpha: float = 0
	for _LiquidName in _Array:
		var _color8 = GameLogic.Liquid.return_color_set(_LiquidName)
		if _Alpha < _color8.a:
			_Alpha = _color8.a

		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(_NUM))
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(_NUM))

		_LayerSprite.set_self_modulate(_color8)
		_InfoLayerSpr.set_self_modulate(_color8)
		get_node("TexNode/Tex/Layer").get_node("Layer0").set_self_modulate(_color8)
		CupInfoNode.get_node("TexNode/Tex/Layer/Layer0").set_self_modulate(_color8)


		_NUM += 1
func _Color_Mixed():
	var _modulate_Mix: Color
	for i in (Liquid_Count):
		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		var _modulate = _LayerSprite.self_modulate

		if _modulate == Color8(137, 228, 245, 100):

			_modulate = Color8(255, 255, 255, 100)
		if not _modulate_Mix:
			_modulate_Mix = _modulate
		else:
			_modulate_Mix += _modulate
	_modulate_Mix = _modulate_Mix / Liquid_Count
	get_node("TexNode/Tex/Layer").get_node("Layer0").self_modulate = _modulate_Mix
	for i in (Liquid_Count):
		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		_LayerSprite.self_modulate = _modulate_Mix
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")
		_InfoLayer0.self_modulate = _modulate_Mix
		_InfoLayerSpr.self_modulate = _modulate_Mix

func call_add_Stale():
	if not IsStale:
		IsStale = true
		FreshlessSprite.show()
		$Effect_flies / Ani.play("Flies")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_add_Stale")
func call_add_PassDay():
	if not IsPassDay:
		IsPassDay = true

		$Effect_flies / Ani.play("OverDay")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_add_PassDay")
func call_Extra_puppet(_1, _2, _3):
	Extra_1 = _1
	Extra_2 = _2
	Extra_3 = _3
	if Extra_1 != null:
		if Extra_1_Ani.assigned_animation != Extra_1:
			Extra_1_Ani.play(Extra_1)
			CupInfoNode.get_node("AniNode/Extra_1").play(Extra_1)
	if Extra_2 != null:
		if Extra_2_Ani.assigned_animation != Extra_2:
			Extra_2_Ani.play(Extra_2)
			CupInfoNode.get_node("AniNode/Extra_2").play(Extra_2)
	if Extra_3 != null:
		if Extra_3_Ani.assigned_animation != Extra_3:
			Extra_3_Ani.play(Extra_3)
			CupInfoNode.get_node("AniNode/Extra_3").play(Extra_3)
func call_add_extra():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if IsPassDay:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Extra_puppet", [Extra_1, Extra_2, Extra_3])
	if Extra_1 != null:
		if Extra_1_Ani.assigned_animation != Extra_1:
			Extra_1_Ani.play(Extra_1)
			CupInfoNode.get_node("AniNode/Extra_1").play(Extra_1)
	if Extra_2 != null:
		if Extra_2_Ani.assigned_animation != Extra_2:
			Extra_2_Ani.play(Extra_2)
			CupInfoNode.get_node("AniNode/Extra_2").play(Extra_2)
	if Extra_3 != null:
		if Extra_3_Ani.assigned_animation != Extra_3:
			Extra_3_Ani.play(Extra_3)
			CupInfoNode.get_node("AniNode/Extra_3").play(Extra_3)
func _Extra_LogicCheck(_Extra):
	if GameLogic.Order.cur_OrderList.has(cur_ID):
		var _cur_Order = GameLogic.Order.cur_OrderList[cur_ID]
		if _cur_Order.has("ExtraArray"):
			GameLogic.Order.cur_OrderList[cur_ID].ExtraArray.append(_Extra)
func call_add_condiment(_Condiment: String):
	if not Condiment_1:
		Condiment_1 = _Condiment

		call_Condiment_play(Condiment_1)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "Condiment_puppet", [Condiment_1])
func Condiment_puppet(_CONDIMENT):
	Condiment_1 = _CONDIMENT
	call_Condiment_play(Condiment_1)
func call_Condiment_play(_AniName):
	Condiment_1_Ani.play(_AniName)
	if CupInfoNode.Condiment_1_Ani.has_animation(_AniName):
		CupInfoNode.Condiment_1_Ani.play(_AniName)
func call_ChangeID(_ButID, _Obj, _Player):

	match _ButID:
		- 2:
			if CupInfoAni.assigned_animation == "show":
				CupInfoAni.play("hide")
			get_node("B").hide()
		- 1:
			if _Player.cur_Player == SteamLogic.STEAM_ID and SteamLogic.IsMultiplay:
				CupInfoAni.play("show")
			elif not SteamLogic.IsMultiplay:
				CupInfoAni.play("show")

			if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				if _Obj.TYPE == self.TYPE:

					get_node("B").show()

		1:
			if IsPassDay:
				return
			if _Obj.TYPE == self.TYPE:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				change_Number(_Obj, _Player)
func call_changeNumber_puppet(_OBJPATH, _playerID):
	var _Obj = get_node(_OBJPATH)
	var _SelfID = cur_ID
	cur_ID = _Obj.cur_ID
	_Obj.cur_ID = _SelfID
	get_node("CupInfo/IDLabel").text = str(cur_ID)
	get_node("CupInfo/ChangeIDAni").play("play")
	_Obj.get_node("CupInfo/IDLabel").text = str(_Obj.cur_ID)
	_Obj.get_node("CupInfo/ChangeIDAni").play("play")
	var _Audio = GameLogic.Audio.return_Effect("气泡")
	_Audio.play(0)
	GameLogic.Order.call_pickup_cup_logic(_Obj.cur_ID, _playerID)
	GameLogic.Order.call_del_cup_logic(cur_ID)
	GameLogic.Order.call_OutLine(_Obj.cur_ID, _playerID)
	GameLogic.Order.call_OutLine(cur_ID, 0)
	get_node("AniNode/FinishAni").play("init")
	_Obj.get_node("AniNode/FinishAni").play("init")
func change_Number(_Obj, _Player):
	if _Obj.TYPE == self.TYPE:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _OBJPATH = _Obj.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_changeNumber_puppet", [_OBJPATH, _Player.cur_Player])
		var _SelfID = cur_ID
		cur_ID = _Obj.cur_ID
		_Obj.cur_ID = _SelfID
		get_node("CupInfo/IDLabel").text = str(cur_ID)
		get_node("CupInfo/ChangeIDAni").play("play")
		_Obj.get_node("CupInfo/IDLabel").text = str(_Obj.cur_ID)
		_Obj.get_node("CupInfo/ChangeIDAni").play("play")
		var _Audio = GameLogic.Audio.return_Effect("气泡")
		_Audio.play(0)
		GameLogic.Order.call_pickup_cup_logic(_Obj.cur_ID, _Player.cur_Player)
		GameLogic.Order.call_del_cup_logic(cur_ID)
		GameLogic.Order.call_OutLine(_Obj.cur_ID, _Player.cur_Player)
		GameLogic.Order.call_OutLine(cur_ID, 0)
		get_node("AniNode/FinishAni").play("init")
		_Obj.get_node("AniNode/FinishAni").play("init")

func call_Sell_hide():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Sell_hide")
	get_node("Sell").hide()
func call_Sell_Show():
	$Sell / AnimationPlayer.play("show")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Sell_Show")
	pass

func call_Sell_Logic():

	pass
func call_Top(_OBJ):

	Top = _OBJ.FuncTypePara
	TopAni.play(Top)
	get_node("CupInfo/bg/DrinkCup").TopAni.play(Top)
	if _OBJ.IsPassDay:
		call_add_PassDay()
	if Top != "" or Hang in ["上层焦糖", "上层巧克力"]:
		Can_Mix = false
	else:
		Can_Mix = true

func call_Hang_Reset():
	HangAni.play("init")
func call_Hang(_OBJ):
	Hang = _OBJ.FuncTypePara
	if Liquid_Count == 0:

		HangAni.play(Hang)
		get_node("CupInfo/bg/DrinkCup").HangAni.play(Hang)
		if _OBJ.IsPassDay:
			call_add_PassDay()
	else:
		var _WRONGNAME = Hang + "_wrong"
		match Hang:
			"挂壁焦糖":
				_WRONGNAME = "上层焦糖"
			"挂壁巧克力":
				_WRONGNAME = "上层巧克力"
		HangAni.play(_WRONGNAME)
		get_node("CupInfo/bg/DrinkCup").HangAni.play(_WRONGNAME)
		Hang = _WRONGNAME
		if _OBJ.IsPassDay:
			call_add_PassDay()
	if Top != "" or Hang in ["上层焦糖", "上层巧克力"]:
		Can_Mix = false
	else:
		if Liquid_Count == 0:
			Can_Mix = false
		else:
			Can_Mix = true
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
func call_clear():
	LIQUID_DIR.clear()
	Liquid_Count = 0
	WaterCelcius = 25
	Extra_1 = ""
	Extra_2 = ""
	Extra_3 = ""
	Condiment_1 = ""
	Condiment_2 = ""
	Condiment_2 = ""
	Top = ""
	Hang = ""
	Celcius = ""
	Pop = 0
	SugarType = 0
	HasIce = false
	HasHot = false
	IsPassDay = false
	IsStale = false
	Extra_1_Ani.play("init")
	Extra_2_Ani.play("init")
	Extra_3_Ani.play("init")
	Condiment_1_Ani.play("init")
	HangAni.play("init")
	TopAni.play("init")
	CupAni.play("init")
	CupTempratureAni.play("Normal")
	get_node("CupInfo/bg/DrinkCup").CupAni.play("init")
	get_node("CupInfo/bg/DrinkCup").HangAni.play("init")
	get_node("CupInfo/bg/DrinkCup").TopAni.play("init")
	get_node("CupInfo/CupCelciusAni").play("init")
	get_node("CupInfo/SugarAni").play("init")
	get_node("CupInfo/bg/DrinkCup").Condiment_1_Ani.play("init")
	get_node("CupInfo/bg/DrinkCup").CupTempratureAni.play("Normal")
	get_node("CupInfo/bg/DrinkCup").Extra_1_Ani.play("init")
	get_node("CupInfo/bg/DrinkCup").Extra_2_Ani.play("init")
	get_node("CupInfo/bg/DrinkCup").Extra_3_Ani.play("init")
	call_Pop_Logic()
