extends Head_Object
var SelfDev = "ShakeCup"
var _DeltaTime: int
var TYPE

var SugarType: int
var LIQUIDTYPE_ARRAY: Array
var LIQUID_DIR: Dictionary
var WaterCelcius: int
var Celcius: String
var cur_ID: int
var Liquid_Max: int = 6
var Liquid_Count: int
var HasWater: bool

var IsPassDay: bool
var IsPickUp: bool

onready var DrinkCup = get_node("DrinkCup")
onready var CupAni = DrinkCup.get_node("AniNode/CupAni")
onready var CupTypeAni = DrinkCup.get_node("AniNode/CupTypeAni")
onready var CupTempratureAni = DrinkCup.get_node("AniNode/CupTempratureAni")
onready var IceAni = DrinkCup.get_node("AniNode/IceAni")

onready var CupInfoAni

onready var CupCelciusAni
onready var SugarIcon
onready var CupInfoNode

onready var FreshlessSprite
onready var ButNode = get_node("But")
var CanOut: bool
func call_finish(_switch: bool):
	match _switch:
		true:
			DrinkCup.get_node("AniNode/FinishAni").play("Right")
		false:
			DrinkCup.get_node("AniNode/FinishAni").play("Wrong")
func But_Hold():

	if get_parent().name == "Weapon_note" and DrinkCup.Can_Mix:
		DrinkCup.get_node("Hold").show()
	else:
		DrinkCup.get_node("Hold").hide()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if Liquid_Count > 0:
		ButNode.show()
	else:
		ButNode.hide()
	But_Hold()

	if _Player.Con.IsHold:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)

	else:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)

	.But_Switch(_bool, _Player)

func _DayClosedCheck():

	if GameLogic.cur_FreshBool:
		IsPassDay = true

func _ready() -> void :
	call_init(SelfDev)


	_onready_init()

	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")

func call_load(_info):
	print("雪克杯加载：", _info)
	_SELFID = int(_info.NAME)
	name = _info.NAME
	.call_Ins_Save(_SELFID)

	call_CupType_init("DrinkCup_L", false, - 1)


	DrinkCup.Is_Mix = true
	DrinkCup.SugarType = _info.SugarType
	DrinkCup.Liquid_Count = _info.Liquid_Count
	if DrinkCup.Liquid_Count > 0:
		DrinkCup.LIQUIDTYPE_ARRAY = _info.LIQUIDTYPE_ARRAY
	print("液体加载：", LIQUIDTYPE_ARRAY, _info)
	DrinkCup.WaterCelcius = _info.WaterCelcius
	DrinkCup.cur_ID = _info.cur_ID



	IsPassDay = _info.IsPassDay

	if IsPassDay and Liquid_Count:
		FreshlessSprite.show()
	if Liquid_Count == 0:
		IsPassDay = false
	_load_show()
	call_mix()
func _load_show():
	if Liquid_Count > 0:
		HasWater = true
		WaterCelcius = 25
		Celcius = "Normal"
		CupCelciusAni.play("Normal")
		CupTempratureAni.play("Normal")
		CupInfoNode.CupTempratureAni.play("Normal")
		_Mix_Check()
		for _TYPE in LIQUIDTYPE_ARRAY:
			if LIQUIDTYPE_ARRAY.count(_TYPE) > 0:
				var _float = float(LIQUIDTYPE_ARRAY.count(_TYPE)) / float(LIQUIDTYPE_ARRAY.size())

				LIQUID_DIR[_TYPE] = _float
		if LIQUID_DIR.size() == 1 or DrinkCup.Is_Mix:
			CanOut = true
		else:
			CanOut = false
		for i in Liquid_Count:
			var _Layer = "Layer" + str(i + 1)
			CupAni.play(_Layer)
			CupInfoNode.CupAni.play(_Layer)

			var _WaterType = LIQUIDTYPE_ARRAY[i]
			var _LayerSprite = DrinkCup.get_node("TexNode/Tex/Layer").get_node(_Layer)
			var _Layer0 = DrinkCup.get_node("TexNode/Tex/Layer/Layer0")
			var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node(_Layer)
			var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")

			var _color8 = GameLogic.Liquid.return_color_set(_WaterType)
			_LayerSprite.set_modulate(_color8)
			_Layer0.set_modulate(_color8)
			_InfoLayerSpr.set_modulate(_color8)
			_InfoLayer0.set_modulate(_color8)

func _onready_init():
	if DrinkCup.has_node("CupInfo/CupInfoAni"):
		CupInfoAni = DrinkCup.get_node("CupInfo/CupInfoAni")
	if DrinkCup.has_node("CupInfo/CupCelciusAni"):
		CupCelciusAni = DrinkCup.get_node("CupInfo/CupCelciusAni")
	if DrinkCup.has_node("CupInfo/bg/tiplist/sweet"):
		SugarIcon = DrinkCup.get_node("CupInfo/bg/tiplist/sweet")
	if DrinkCup.has_node("CupInfo/bg/DrinkCup"):
		CupInfoNode = DrinkCup.get_node("CupInfo/bg/DrinkCup")

	if DrinkCup.has_node("Freshless"):
		FreshlessSprite = DrinkCup.get_node("Freshless")
func call_CupType_init(_Type, _InfoShow: bool, _PlayerID: int):
	TYPE = _Type

	CupTypeAni.play(TYPE)
	CupInfoNode.CupTypeAni.play(TYPE)

	if _InfoShow:
		CupInfoAni.play("show")

func call_cleanID():
	if GameLogic.Order.cur_CupArray.has(cur_ID):

		GameLogic.Order.cur_CupArray.erase(cur_ID)
		GameLogic.Order.call_del_cup_logic(cur_ID)
func _config_SYCN():
	Liquid_Max = int(FuncTypePara)

func call_CupInfo_Switch(_Switch):
	match _Switch:
		true:
			CupInfoAni.play("show")
		false:
			call_CupInfo_Hide()

func call_CupInfo_Hide():
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
func call_Drop():
	if Liquid_Count > 0:
		call_Water_Out(Liquid_Count)
func call_Water_Out(_OutNum):
	if Liquid_Count >= _OutNum:
		Liquid_Count -= _OutNum



	else:
		print("错误，倒出液体大于当前液体。")
	if not Liquid_Count:
		IsPassDay = false
		FreshlessSprite.hide()
		HasWater = false
		LIQUIDTYPE_ARRAY.clear()
		LIQUID_DIR.clear()
		CanOut = false
		CupAni.play("init")
		CupInfoNode.CupAni.play("init")
		CupCelciusAni.play("init")
		CupTempratureAni.play("Normal")
		CupInfoNode.CupTempratureAni.play("Normal")
		SugarType = 0
		WaterCelcius = 20
	else:
		var _Layer = "Layer" + str(Liquid_Count)
		CupAni.play(_Layer)
		CupInfoNode.CupAni.play(_Layer)
	Weight = Liquid_Count
	_Mix_Check()
	print("雪克杯液体组：", LIQUIDTYPE_ARRAY)

func call_Water_In(_ButID, _OutObj):
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)

	match _ButID:
		- 1:

			call_CupInfo_Switch(true)
		0:
			if _OutObj.IsPassDay:
				return
			Water_In_Logic(_OutObj)
			print("液体组：", LIQUIDTYPE_ARRAY)








func _Mix_Check():
	DrinkCup.get_node("Hold/X").hide()
	var _LiquidNum = LIQUIDTYPE_ARRAY.size()
	if _LiquidNum > 1:
		var _CanMix: bool
		var _L = null
		for i in _LiquidNum:
			if _L == null:
				_L = LIQUIDTYPE_ARRAY[i]
			elif _L != LIQUIDTYPE_ARRAY[i]:
				DrinkCup.Is_Mix = false
				DrinkCup.Can_Mix = true

				DrinkCup.get_node("Hold/X").show()
				But_Hold()
				return
func _Liquid_Logic(_WaterType):

	for _TYPE in LIQUIDTYPE_ARRAY:
		if LIQUIDTYPE_ARRAY.count(_TYPE) > 0:
			var _float = float(LIQUIDTYPE_ARRAY.count(_TYPE)) / float(LIQUIDTYPE_ARRAY.size())

			LIQUID_DIR[_TYPE] = _float

	if LIQUID_DIR.size() == 1 or DrinkCup.Is_Mix:
		CanOut = true
	else:
		CanOut = false

func Water_In_Logic(_OutObj):

	if IsPassDay:
		return
	if _OutObj.HasWater:
		if Liquid_Count < Liquid_Max:
			if _OutObj.Liquid_Count > 0:
				HasWater = true
				Liquid_Count += 1
				Weight += 1
				if Celcius == "Cold":
					if Liquid_Count in [3, 5]:
						call_AddNormal()
						WaterCelcius += 5

				LIQUIDTYPE_ARRAY.append(_OutObj.WaterType)
				_Mix_Check()
				_Liquid_Logic(_OutObj.WaterType)
				var _Layer = "Layer" + str(Liquid_Count)
				CupAni.play(_Layer)
				CupInfoNode.CupAni.play(_Layer)
				if _OutObj.WaterCelcius > 50:
					if WaterCelcius == 0:
						WaterCelcius = _OutObj.WaterCelcius
						Celcius = "Hot"
						CupCelciusAni.play("Hot")
						CupTempratureAni.play("Hot")
						CupInfoNode.CupTempratureAni.play("Hot_Info")
				elif _OutObj.WaterCelcius < 20:
					if CupCelciusAni.assigned_animation != "Cold":
						WaterCelcius = 5
						Celcius = "Cold"
						CupCelciusAni.play("Cold")
						CupTempratureAni.play("Cold")
						CupInfoNode.CupTempratureAni.play("Cold")
				else:
					if WaterCelcius == 0 or WaterCelcius > 5:
						if CupCelciusAni.assigned_animation != "Normal":
							WaterCelcius = 25
							Celcius = "Normal"
							CupCelciusAni.play("Normal")
							CupTempratureAni.play("Normal")
							CupInfoNode.CupTempratureAni.play("Normal")
				var _WaterType = _OutObj.WaterType
				var _LayerSprite = DrinkCup.get_node("TexNode/Tex/Layer").get_node(_Layer)
				var _Layer0 = DrinkCup.get_node("TexNode/Tex/Layer/Layer0")
				var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node(_Layer)
				var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")

				var _color8 = GameLogic.Liquid.return_color_set(_WaterType)
				_LayerSprite.set_modulate(_color8)
				_Layer0.set_modulate(_color8)
				_InfoLayerSpr.set_modulate(_color8)
				_InfoLayer0.set_modulate(_color8)

				if _OutObj.has_method("call_Water_Out"):
					_OutObj.call_Water_Out(1)
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

func return_CanMix(_Player):

	if DrinkCup.Can_Mix:
		var _Speed: float = 1
		var _Mult: float = 1

		_Speed = _Speed / GameLogic.return_Multiplier_Division()
		if not _Player.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("一次性手套"):
				_Mult += 0.5
			if GameLogic.cur_Rewards.has("一次性手套+"):
				_Mult += 1.5

		if _Player.Stat.Skills.has("技能-灵巧"):
			_Mult += 1.5
		if GameLogic.cur_Event == "手速":
			_Mult = 20
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		DrinkCup.get_node("MixNode/MixAni").playback_speed = _Speed * _Mult

		DrinkCup.get_node("MixNode/MixAni").play("Mixd")
		if not DrinkCup.PlayerList.has(_Player):
			DrinkCup.PlayerList.append(_Player)
		return true
	return false

func return_Liquid_Ani():

	if DrinkCup.Is_Mix:
		var _LiquidNum = LIQUIDTYPE_ARRAY.size()
		var _MenuNum = GameLogic.cur_Menu.size()

		for m in _MenuNum:
			var _INFO = GameLogic.Config.FormulaConfig[GameLogic.cur_Menu[m]]

			var _TYPECHECK: bool
			match Liquid_Count:
				2:

					_TYPECHECK = true
				4:

					_TYPECHECK = true
				6:

					_TYPECHECK = true
			var _ForList: Array
			if _TYPECHECK:

				var _ForMax = int(_INFO.FormulaNum)
				for f in _ForMax:
					var FORID = "For_" + str(f + 1)
					var FORNUM = FORID + "_Num"
					var _ForNum = int(_INFO[FORNUM])
					for _Num in _ForNum:
						_ForList.append(_INFO[FORID])


				if LIQUIDTYPE_ARRAY.size() != _ForList.size():
					print("return_Liquid_Ani不同。", LIQUIDTYPE_ARRAY, _ForList)

				for l in _LiquidNum:
					if LIQUIDTYPE_ARRAY[l] in _ForList:
						_ForList.erase(LIQUIDTYPE_ARRAY[l])

				if _ForList.size() == 0:
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

	for i in 7:
		var _LayerSprite = DrinkCup.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i))
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i))
		if i <= Liquid_Count:

			_LayerSprite.set_modulate(_color8)
			_InfoLayerSpr.set_modulate(_color8)

func _Color_Mixed():
	var _modulate_Mix: Color
	for i in (Liquid_Count):
		var _LayerSprite = DrinkCup.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		var _modulate = _LayerSprite.modulate

		if _modulate == Color8(137, 228, 245, 100):

			_modulate = Color8(255, 255, 255, 100)
		if not _modulate_Mix:
			_modulate_Mix = _modulate
		else:
			_modulate_Mix += _modulate
	_modulate_Mix = _modulate_Mix / Liquid_Count
	DrinkCup.get_node("TexNode/Tex/Layer").get_node("Layer0").modulate = _modulate_Mix
	for i in (Liquid_Count):
		var _LayerSprite = DrinkCup.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		_LayerSprite.modulate = _modulate_Mix
		var _InfoLayerSpr = CupInfoNode.get_node("TexNode/Tex/Layer").get_node("Layer" + str(i + 1))
		var _InfoLayer0 = CupInfoNode.get_node("TexNode/Tex/Layer/Layer0")
		_InfoLayer0.modulate = _modulate_Mix
		_InfoLayerSpr.modulate = _modulate_Mix

func return_DropCount():
	var _Drop_Count = 0
	if HasWater:
		_Drop_Count += Liquid_Count

	return _Drop_Count
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)

func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
