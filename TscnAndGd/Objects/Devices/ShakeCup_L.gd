extends Head_Object
var SelfDev = "ShakeCup"
var _DeltaTime: int
var TYPE
var Is_Mix: bool
var Can_Mix: bool
var CanOut: bool
var CanJoin: bool = true
var SugarType: int

var LIQUID_DIR: Dictionary
var WaterCelcius: int
var Celcius: String
var cur_ID: int
var Liquid_Max: int
var Liquid_Count: int
var Extra_1: String
var Extra_2: String
var Extra_3: String
var Condiment_1: String
var Condiment_2: String
var Condiment_3: String
var IsPassDay: bool
var IsPickUp: bool
var PlayerList: Array

onready var CupAni = get_node("AniNode/CupAni")
onready var CupTypeAni = get_node("AniNode/CupTypeAni")
onready var CupTempratureAni = get_node("AniNode/CupTempratureAni")
onready var IceAni = get_node("AniNode/IceAni")

onready var CupInfoAni

onready var CupCelciusAni
onready var SugarIcon
onready var CupInfoNode

onready var Extra_1_Ani = get_node("AniNode/Extra_1")
onready var Extra_2_Ani = get_node("AniNode/Extra_2")
onready var Extra_3_Ani = get_node("AniNode/Extra_3")
onready var Condiment_1_Ani = get_node("AniNode/CondimentAni")
onready var Condiment_1_Sprite = get_node("TexNode/Tex/Condiment/Sprite")
onready var FreshlessSprite
onready var ButNode
onready var Audio_Water

func Animation_Call_WRONG_Audio():
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
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
		1:
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
	if GameLogic.cur_Rewards.has("隔温杯套"):
		if has_node("AniNode/Up_Mat"):
			get_node("AniNode/Up_Mat").play("1")
	if GameLogic.cur_Rewards.has("隔温杯套+"):
		if has_node("AniNode/Up_Mat"):
			get_node("AniNode/Up_Mat").play("2")
	if GameLogic.cur_Rewards.has("吸管"):
		if has_node("AniNode/Up_Straw"):
			get_node("AniNode/Up_Straw").play("1")
	if GameLogic.cur_Rewards.has("吸管+"):
		if has_node("AniNode/Up_Straw"):
			get_node("AniNode/Up_Straw").play("2")
	if GameLogic.cur_Rewards.has("跳单补偿"):
		if has_node("AniNode/Up_Straw"):
			get_node("AniNode/Up_Straw").play("1")

func call_finish(_switch: bool):
	match _switch:
		true:
			get_node("AniNode/FinishAni").play("Right")
			call_FinishUpdate()
		false:
			get_node("AniNode/FinishAni").play("Wrong")
func call_OverID():
	get_node("AniNode/FinishAni").play("OverID")
func But_Hold(_Player):

	if not is_instance_valid(_Player):
		return
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if get_parent().name == "Weapon_note" and Can_Mix:
		if has_node("Hold/X") and _Player != null:
			get_node("Hold/X").ButPlayer = _Player.cur_Player
			get_node("Hold").show()
	else:
		get_node("Hold").hide()

func call_out_switch(_switch):
	match _switch:
		true:
			var B_But = get_node("But/B")
			B_But.show()
		false:
			var B_But = get_node("But/B")
			B_But.hide()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	ButNode.show()
	But_Hold(_Player)
	if not _bool:
		call_out_switch(false)
	if Liquid_Count < Liquid_Max:
		var A_But = get_node("But/A")
		A_But.show()
	elif Liquid_Count >= Liquid_Max:
		var A_But = get_node("But/A")
		A_But.hide()
	if _Player.Con.IsHold:
		var A_But = get_node("But/A")


		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)

	else:
		var A_But = get_node("But/A")

		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)

	.But_Switch(_bool, _Player)

func _DayClosedCheck():

	if cur_ID <= 0:
		return
	if IsPickUp:
		return
	if LIQUID_DIR.size() or SugarType or Extra_1 != null:
		IsPassDay = true
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.DRINKCUP):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.DRINKCUP)

func _ready() -> void :
	call_init(SelfDev)

	_onready_init()

	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Liquid_Max = 6
	CupTypeAni.play("DrinkCup_L")
	if not get_parent().name in ["Devices", "Items"]:
		call_Collision_Switch(false)
	Audio_Water = GameLogic.Audio.return_Effect("加水")

func _Color_Logic(_LiquidArray: Array):
	if _LiquidArray.size():
		for i in _LiquidArray.size():
			var _Layer = "Layer" + str(i + 1)
			var _Color = _LiquidArray[i]
			var _LayerSprite = get_node("TexNode/Tex/Layer").get_node(_Layer)
			var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node(_Layer)
			CupAni.play(_Layer)
			CupInfoNode.CupAni.play(_Layer)
			_LayerSprite.set_modulate(_Color)
			_InfoLayerSpr.set_modulate(_Color)
			if i == _LiquidArray.size() - 1:
				var _Layer0 = get_node("TexNode/Tex/Layer/Layer0")
				var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")
				_Layer0.set_modulate(_Color)
				_InfoLayer0.set_modulate(_Color)


func call_load(_info):

	_SELFID = int(_info.NAME)
	self.name = _info.NAME
	match _info.TSCN:
		"DrinkCup_S":
			call_CupType_init("DrinkCup_S", false, - 1)
		"DrinkCup_M":
			call_CupType_init("DrinkCup_M", false, - 1)
		"DrinkCup_L":
			call_CupType_init("DrinkCup_L", false, - 1)

	Is_Mix = _info.Is_Mix
	SugarType = _info.SugarType
	if SugarType:
		call_Sugar_In(SugarType)

	if _info.has("LIQUID_DIR"):
		LIQUID_DIR = _info.LIQUID_DIR

	WaterCelcius = _info.WaterCelcius
	cur_ID = _info.cur_ID

	Liquid_Count = int(_info.Liquid_Count)

	if _info.has("Extra_1"):
		Extra_1 = _info.Extra_1
		Extra_2 = _info.Extra_2
		Extra_3 = _info.Extra_3
	if _info.has("Condiment_1"):
		Condiment_1 = _info.Condiment_1
		Condiment_2 = _info.Condiment_2
		Condiment_3 = _info.Condiment_3
	IsPassDay = _info.IsPassDay
	if IsPassDay:
		FreshlessSprite.show()
	if _info.has("Liquid_Array"):
		_Color_Logic(_info.Liquid_Array)
	if Is_Mix:
		call_CanMix_Finish()
		CanOut = true
		Can_Mix = false
	else:
		Can_Mix = true
	_WaterCelcius_Show()

func _onready_init():
	if self.has_node("CupInfo/CupInfoAni"):
		CupInfoAni = get_node("CupInfo/CupInfoAni")
	if self.has_node("CupInfo/CupCelciusAni"):
		CupCelciusAni = get_node("CupInfo/CupCelciusAni")
	if self.has_node("CupInfo/bg/tiplist/sweet"):
		SugarIcon = get_node("CupInfo/bg/tiplist/sweet")
	if self.has_node("CupInfo/bg/DrinkCup"):
		CupInfoNode = get_node("CupInfo/bg/DrinkCup")
	if self.has_node("But"):
			ButNode = get_node("But")
	if self.has_node("Freshless"):
		FreshlessSprite = get_node("Freshless")
func call_CupType_init(_Type, _InfoShow: bool, _PlayerID: int):
	TYPE = _Type
	call_init(TYPE)
	CupTypeAni.play(TYPE)
	CupInfoNode.CupTypeAni.play(TYPE)
	_config_SYCN()
	if _InfoShow:
		CupInfoAni.play("show")

func call_cleanID():
	if GameLogic.Order.cur_CupArray.has(cur_ID):

		GameLogic.Order.cur_CupArray.erase(cur_ID)
		GameLogic.Order.call_del_cup_logic(cur_ID)
func _config_SYCN():
	Liquid_Max = int(FuncTypePara)
func call_Drop():
	if Liquid_Count > 0:
		call_Water_Out(Liquid_Count)
func call_CupInfo_Switch(_Switch):
	match _Switch:
		true:
			CupInfoAni.play("show")
		false:
			call_CupInfo_Hide()

func call_CupInfo_Hide():

	if self.is_inside_tree():
		if get_parent().name == "Weapon_note":
			return
	if CupInfoAni.assigned_animation != "hide":
		if CupInfoAni.assigned_animation != "init":
			CupInfoAni.play("hide")

func call_Sugar_In(_TYPE):
	SugarType = _TYPE
	SugarIcon.visible = true

func call_wait_water_in(_Wait: float, _OutObj):
	yield(get_tree().create_timer(_Wait), "timeout")
	call_Water_In(0, _OutObj)
	_OutObj.call_del()
func call_Water_In(_ButID, _OutObj):
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)

	match _ButID:
		- 1:

			call_CupInfo_Switch(true)
		0:
			if not _OutObj.IsPassDay:
				Water_In_Logic(_OutObj)
			else:

				pass








func _Mix_Check(_BeforeInDir):
	get_node("Hold/X").hide()

	if LIQUID_DIR.size() > _BeforeInDir.size() and LIQUID_DIR.size() > 1:
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
			Can_Mix = true
			Is_Mix = false
			get_node("Hold/X").show()
			But_Hold(null)
			return
	elif LIQUID_DIR.size() == 1:
		Can_Mix = false
		Is_Mix = true

func call_Shelf_Logic(_ButID, _Player, _Obj):
	if IsPassDay:
		return
	if _ButID >= 0:

		match _Obj.FuncType:
			"Can":
				return _Obj.call_add_extra(0, _Player, self)
			"Bottle":

				return _Obj.call_WaterInDrinkCup(0, self, _Player)
			"ShakeCup":
				if _Obj.CanOut and Liquid_Count < Liquid_Max:
					return _Shake_In_Drink(_Obj)
func call_ShakeCup_In_DrinkCup(_ButID, _Player, _ShakeObj):
	if IsPassDay:
		return
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_ShakeObj.But_Switch(false, _Player)
			_ShakeObj.call_CupInfo_Switch(false)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_ShakeObj.But_Switch(true, _Player)
			_ShakeObj.call_CupInfo_Switch(true)
		0:
			if _ShakeObj.CanOut and Liquid_Count < Liquid_Max and not IsPassDay:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				_Shake_In_Drink(_ShakeObj)
func _Shake_In_Drink(_ShakeObj):
	if IsPassDay:
		return
	if not Liquid_Count:
		Is_Mix = true
		Can_Mix = false

	var _JoinNum: int = Liquid_Max - Liquid_Count
	if _ShakeObj.Liquid_Count < _JoinNum:
		_JoinNum = _ShakeObj.Liquid_Count

	var _ShakeLiquidCount = _ShakeObj.LIQUID_DIR.size()

	for _TYPE in _ShakeObj.LIQUID_DIR:
		var _Num = float(_ShakeObj.LIQUID_DIR[_TYPE]) / _ShakeLiquidCount * _JoinNum
		if LIQUID_DIR.has(_TYPE):
			LIQUID_DIR[_TYPE] += _Num
		else:
			LIQUID_DIR[_TYPE] = _Num
		_ShakeObj.LIQUID_DIR[_TYPE] -= _Num
		if _ShakeObj.LIQUID_DIR[_TYPE] <= 0:
			_ShakeObj.LIQUID_DIR.erase(_TYPE)

	var _BaseLiquid: int = Liquid_Count
	Liquid_Count += _JoinNum
	Weight += _JoinNum

	if _ShakeObj.SugarType and not SugarType:
		call_Sugar_In(_ShakeObj.SugarType)
	_WaterShow(_ShakeObj)

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
	_ShakeObj.call_Water_Out(0)
	return true

func _WaterCelcius_Show():
	if WaterCelcius == 0:
		WaterCelcius = 25
	if WaterCelcius >= 20 and WaterCelcius < 50:
		if Celcius != "Normal":
			Celcius = "Normal"
		if CupCelciusAni.assigned_animation != "Normal":
			CupCelciusAni.play("Normal")
		if CupTempratureAni.assigned_animation != "Normal":
			CupTempratureAni.play("Normal")
		if CupInfoNode.CupTempratureAni.assigned_animation != "Normal":
			CupInfoNode.CupTempratureAni.play("Normal")
	elif WaterCelcius < 20:
		if Celcius != "Cold":
			Celcius = "Cold"
		if CupCelciusAni.assigned_animation != "Cold":
			CupCelciusAni.play("Cold")
		if CupTempratureAni.assigned_animation != "Cold":
			CupTempratureAni.play("Cold")
		if CupInfoNode.CupTempratureAni.assigned_animation != "Cold":
			CupInfoNode.CupTempratureAni.play("Cold")
	elif WaterCelcius >= 50:
		if Celcius != "Hot":
			Celcius = "Hot"
		if CupCelciusAni.assigned_animation != "Hot":
			CupCelciusAni.play("Hot")
		if CupTempratureAni.assigned_animation != "Hot":
			CupTempratureAni.play("Hot")
		if CupInfoNode.CupTempratureAni.assigned_animation != "Hot":
			CupInfoNode.CupTempratureAni.play("Hot")
func _WaterShow(_OutObj):
	var _Layer = "Layer" + str(Liquid_Count)
	CupAni.play(_Layer)
	CupInfoNode.CupAni.play(_Layer)
	if _OutObj.WaterCelcius >= 50:
		if WaterCelcius < 20:
			WaterCelcius = 25
		elif _OutObj.WaterCelcius < 50:
			WaterCelcius = 85
	elif _OutObj.WaterCelcius > 0 and _OutObj.WaterCelcius < 20:
		if WaterCelcius >= 50:
			WaterCelcius = 25
		elif WaterCelcius < 50:
			WaterCelcius = 5
	_WaterCelcius_Show()

func _ColorShow(_OutObj):
	var _Layer = "Layer" + str(Liquid_Count)
	var _WaterType = _OutObj.WaterType
	var _LayerSprite = get_node("TexNode/Tex/Layer").get_node(_Layer)
	var _Layer0 = get_node("TexNode/Tex/Layer/Layer0")
	var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node(_Layer)
	var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")

	var _color8 = GameLogic.Liquid.return_color_set(_WaterType)
	_LayerSprite.set_modulate(_color8)
	_Layer0.set_modulate(_color8)
	_InfoLayerSpr.set_modulate(_color8)
	_InfoLayer0.set_modulate(_color8)

	if _OutObj.has_method("call_Water_Out"):
		_OutObj.call_Water_Out(1)

func call_Water_Out_puppet(_COUNT, _DIR):
	Audio_Water.play(0)
	Liquid_Count = _COUNT
	LIQUID_DIR = _DIR
	if Liquid_Count <= 0:
		IsPassDay = false
		FreshlessSprite.hide()

		LIQUID_DIR.clear()

		CupAni.play("init")
		CupInfoNode.CupAni.play("init")
		CupCelciusAni.play("init")
		CupTempratureAni.play("Normal")
		CupInfoNode.CupTempratureAni.play("Normal")
		SugarType = 0
		CanJoin = true
		Celcius = "Normal"
		WaterCelcius = 25
	else:
		var _Layer = "Layer" + str(Liquid_Count)
		CupAni.play(_Layer)
		CupInfoNode.CupAni.play(_Layer)

		if SugarType:
			CanJoin = false
		if Celcius in ["Cold", "Hot"]:
			CanJoin = false
	Weight = Liquid_Count
func call_Water_Out(_OutNum):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if Liquid_Count >= _OutNum:
		Audio_Water.play(0)
		get_node("AniNode/OutAni").play("show")
		if Liquid_Count <= 0:
			LIQUID_DIR.clear()
		for _TYPE in LIQUID_DIR:
			var _Num = float(LIQUID_DIR[_TYPE]) / Liquid_Count * _OutNum

			LIQUID_DIR[_TYPE] -= _Num
			if LIQUID_DIR[_TYPE] <= 0:
				LIQUID_DIR[_TYPE] = 0
		Liquid_Count -= _OutNum
	else:
		print("错误，倒出液体大于当前液体。")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_Out_puppet", [Liquid_Count, LIQUID_DIR])

	if Liquid_Count <= 0:
		IsPassDay = false
		FreshlessSprite.hide()

		LIQUID_DIR.clear()

		CupAni.play("init")
		CupInfoNode.CupAni.play("init")
		CupCelciusAni.play("init")
		CupTempratureAni.play("Normal")
		CupInfoNode.CupTempratureAni.play("Normal")
		SugarType = 0
		CanJoin = true
		Celcius = "Normal"
		WaterCelcius = 25
	else:
		var _Layer = "Layer" + str(Liquid_Count)
		CupAni.play(_Layer)
		CupInfoNode.CupAni.play(_Layer)

		if SugarType:
			CanJoin = false
		if Celcius in ["Cold", "Hot"]:
			CanJoin = false
	Weight = Liquid_Count

	print("雪克杯液体组：")
func return_DropCount():
	var _Drop_Count = Liquid_Count

	call_Water_Out(Liquid_Count)
	return _Drop_Count
func Water_In_Logic(_OutObj):

	if IsPassDay:
		return
	if not CanJoin:
		if SugarType:
			$EffectNode / AnimationPlayer.play("Play")
			return
		elif Celcius == "Cold":
			if _OutObj.WaterCelcius >= 25:
				$EffectNode / AnimationPlayer.play("Play")
				return
		elif Celcius == "Hot":
			if _OutObj.WaterCelcius < 85:
				$EffectNode / AnimationPlayer.play("Play")
				return
	if _OutObj.HasWater:
		if Liquid_Count < Liquid_Max:
			if _OutObj.Liquid_Count > 0:

				var _BeforeInDir: Dictionary
				var _Keys = LIQUID_DIR.keys()
				for i in _Keys.size():
					var _Name = _Keys[i]
					_BeforeInDir[_Name] = LIQUID_DIR[_Name]

				call_Liquid_Logic(_OutObj.WaterType)
				_Mix_Check(_BeforeInDir)


				_WaterShow(_OutObj)
				_ColorShow(_OutObj)
func call_Liquid_Logic(_Type):
	print("雪克杯加入液体", LIQUID_DIR)
	get_node("Hold/X").hide()
	var _LIQUID_DIC: Dictionary


	for _TYPE in LIQUID_DIR:
		_LIQUID_DIC[_TYPE] = float(LIQUID_DIR[_TYPE]) / Liquid_Count
	if not LIQUID_DIR.has(_Type):
		LIQUID_DIR[_Type] = 1
	else:
		LIQUID_DIR[_Type] += 1
		print("雪克杯加入液体", LIQUID_DIR)
	Liquid_Count += 1
	Weight += 1

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
		get_node("Hold/X").show()
		But_Hold(null)




func call_AddIce():

	if IsPassDay:
		return
	if Celcius != "Cold":
		WaterCelcius = 5
		Celcius = "Cold"
		IceAni.play("addice")
		CupCelciusAni.play("Cold")
		CupTempratureAni.play("Cold")


func call_AddNormal():
	if IsPassDay:
		return
	if Celcius != "Normal":
		WaterCelcius = 25
		Celcius = "Hot"
		IceAni.play("init")
		CupCelciusAni.play("Normal")
		CupTempratureAni.play("Normal")
		CupInfoNode.CupTempratureAni.play("Normal")

func call_AddHot():
	if IsPassDay:
		return
	if Celcius != "Hot":
		WaterCelcius = 85
		Celcius = "Hot"
		IceAni.play("init")
		CupCelciusAni.play("Hot")
		CupTempratureAni.play("Hot")
		CupInfoNode.CupTempratureAni.play("Hot")

func return_CanMix_old(_Con):
	if Can_Mix:
		return true
	return false
func return_CanMix(_Player):

	if IsPassDay:
		return false
	if Can_Mix:
		var _Speed: float = 1
		var _Mult: float = 1

		_Speed = _Speed / GameLogic.return_Multiplier_Division()
		if _Player.Stat.Skills.has("技能-麻利"):
			_Mult += 0.5
		if not _Player.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("一次性手套"):
				_Mult += 0.5
			if GameLogic.cur_Rewards.has("一次性手套+"):
				_Mult += 3
			if GameLogic.cur_Challenge.has("手笨+"):
				_Mult = _Mult * 0.75
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		if GameLogic.cur_Event == "手速":
			_Mult = 20
		get_node("MixNode/MixAni").playback_speed = _Speed * _Mult

		get_node("MixNode/MixAni").play("Mixd")
		if not PlayerList.has(_Player):
			PlayerList.append(_Player)
		return true
	return false

func call_CanMix_Finish():

	if Can_Mix:
		Is_Mix = true
		Can_Mix = false
		CanOut = true
		But_Hold(null)
		call_mix()

		get_node("MixNode/MixAni").play("hide")
		for i in PlayerList.size():
			var _Player = PlayerList[i]

			if _Player.has_method("call_reset_stat"):

				_Player.call_reset_stat()

		return "摇匀"
	return
func return_Liquid_Ani():

	if Is_Mix:

		var _MenuNum = GameLogic.cur_Menu.size()

		for m in _MenuNum:
			var _INFO = GameLogic.Config.FormulaConfig[GameLogic.cur_Menu[m]]

			var _TYPECHECK: bool = true
			match TYPE:
				"DrinkCup_S":
					if _INFO.CupType == "S":
						_TYPECHECK = true
				"DrinkCup_M":
					if _INFO.CupType == "M":
						_TYPECHECK = true
				"DrinkCup_L":
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
	if IsPassDay:
		return
	var _LiquidName = return_Liquid_Ani()

	if _LiquidName != null:

		call_Liquid_Set(_LiquidName)
	else:
		_Color_Mixed()
func call_Liquid_Set(_LiquidName):
	var _color8 = GameLogic.Liquid.return_color_set(_LiquidName)

	for i in 7:
		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(i))
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i))
		if i <= Liquid_Count:

			_LayerSprite.set_modulate(_color8)
			_InfoLayerSpr.set_modulate(_color8)

func _Color_Mixed():
	var _modulate_Mix: Color
	for i in (Liquid_Count):
		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		var _modulate = _LayerSprite.modulate

		if _modulate == Color8(137, 228, 245, 100):

			_modulate = Color8(255, 255, 255, 100)
		if not _modulate_Mix:
			_modulate_Mix = _modulate
		else:
			_modulate_Mix += _modulate
	_modulate_Mix = _modulate_Mix / Liquid_Count
	get_node("TexNode/Tex/Layer").get_node("Layer0").modulate = _modulate_Mix
	for i in (Liquid_Count):
		var _LayerSprite = get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		_LayerSprite.modulate = _modulate_Mix
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")
		_InfoLayer0.modulate = _modulate_Mix
		_InfoLayerSpr.modulate = _modulate_Mix

func call_add_extra():
	if IsPassDay:
		return
	if Extra_1 != null:
		Extra_1_Ani.play(Extra_1)
		CupInfoNode.get_node("AniNode/Extra_1").play(Extra_1)
	if Extra_2 != null:
		Extra_2_Ani.play(Extra_2)
		CupInfoNode.get_node("AniNode/Extra_2").play(Extra_2)
	if Extra_3 != null:
		Extra_3_Ani.play(Extra_3)
		CupInfoNode.get_node("AniNode/Extra_3").play(Extra_3)

func call_add_condiment(_Condiment: String):
	if IsPassDay:
		return
	if not Condiment_1:
		Condiment_1 = _Condiment
		Condiment_1_Sprite.offset += Vector2(randi() % 10 - 5, randi() % 10 - 5)
		Condiment_1_Sprite.offset += Vector2(randi() % 10 - 5, randi() % 10 - 5)
		call_Condiment_play(Condiment_1)

func call_Condiment_play(_AniName):
	Condiment_1_Ani.play(_AniName)
	CupInfoNode.Condiment_1_Ani.play(_AniName)

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
	if not body.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	call_CupInfo_Switch(true)

func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
	yield(get_tree().create_timer(0.1), "timeout")
	if not body.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	call_CupInfo_Switch(false)
