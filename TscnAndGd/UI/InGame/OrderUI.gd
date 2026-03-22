extends Control

var _Name: String
var _Celcius: String
var _Sugar: int
var _Pop: int
var _BEER: int
var _data
var _ID: int
var _ExtraArray: Array
var Condiment_1: String
var RefundTime: int
var Del_Bool: bool
var _Ready: bool
var _TYPE

onready var WaterAni = get_node("TexNode/Sprite/CupInfo/CupWaterAni")
onready var CelciusAni = get_node("TexNode/Sprite/CupInfo/CupCelciusAni")
onready var OrderUIAni = get_node("OrderUIAni")
onready var OrderAni = $OrderAni
onready var SweetAni = get_node("TexNode/Sprite/CupInfo/CupSweetAni")
onready var IDLabel = get_node("TexNode/Sprite/IDLabel")
onready var RefundTimeBar = get_node("TexNode/RefundTimeBar")
onready var _RefundTimer = RefundTimeBar.get_node("Timer")

onready var FormulaNode = get_node("TexNode/Formula/SpriteTex/Top_note/Element")
onready var UIAct1 = get_node("TexNode/Formula/SpriteTex/Top_note/Act/UiAct1")
onready var UIAct2 = get_node("TexNode/Formula/SpriteTex/Top_note/Act/UiAct2")
onready var ExtraNode = $TexNode / Formula / SpriteTex / Top_note / Extra
onready var CondNode = $TexNode / Formula / SpriteTex / Top_note / Condiment
onready var BGAni = get_node("BGAni")

onready var TypeAni = $TypeAni

onready var Audio_Refund
onready var Audio_Show
func _ready() -> void :
	Audio_Refund = GameLogic.Audio.return_Effect("退单")
	Audio_Show = GameLogic.Audio.return_Effect("下单")

func return_cupani_aniname(_CupType):
	match _CupType:
		"S":
			return "Layer2"
		"M":
			return "Layer4"
		"L":
			return "Layer6"
func return_cuptype_aniname(_CupType):
	match _CupType:
		"S":
			return "DrinkCup_S"
		"M":
			return "DrinkCup_M"
		"L":
			return "DrinkCup_L"

func _on_RefundTimer_timeout() -> void :


	if RefundTimeBar.value > 0:
		RefundTimeBar.value -= 1

		call_Logic()



func call_Logic():
	_Quick_Logic()
	_Limit_Logic()
func _Limit_Logic():
	var _LimitMult: float = 0.2
	if GameLogic.cur_Rewards.has("灭蚊灯"):
		_LimitMult = 0.3
	if GameLogic.cur_Rewards.has("灭蚊灯+"):
		_LimitMult = 0.5
	if float(RefundTimeBar.value) < float(RefundTimeBar.max_value) * _LimitMult and RefundTimeBar.value != 0:
		if OrderUIAni.current_animation != "shake":
			OrderUIAni.play("shake")
	else:
		if OrderUIAni.current_animation == "shake":
			OrderUIAni.play("normal")
func _Quick_Logic():
	var _QuickMult = 0.8
	if GameLogic.cur_Rewards.has("延时抹布"):
		_QuickMult = 0.7
	if GameLogic.cur_Rewards.has("延时抹布+"):
		_QuickMult = 0.5
	var _LimitMult: float = 0.2
	if GameLogic.cur_Rewards.has("灭蚊灯"):
		_LimitMult = 0.3
	if GameLogic.cur_Rewards.has("灭蚊灯+"):
		_LimitMult = 0.5
	if float(RefundTimeBar.value) < float(RefundTimeBar.max_value) * _LimitMult:
		RefundTimeBar.tint_progress.r8 = 255
		RefundTimeBar.tint_progress.g8 = 0
		RefundTimeBar.tint_progress.b8 = 0
	elif float(RefundTimeBar.value) < float(RefundTimeBar.max_value) * _QuickMult:
		RefundTimeBar.tint_progress.r8 = 255
		RefundTimeBar.tint_progress.g8 = 255
		RefundTimeBar.tint_progress.b8 = 0
	else:
		RefundTimeBar.tint_progress.r8 = 0
		RefundTimeBar.tint_progress.g8 = 255
		RefundTimeBar.tint_progress.b8 = 0

func call_RefundTime_puppet(_RETIME):
	RefundTimeBar.value = _RETIME
	call_Logic()
func call_RefundTime_Set(_RETIME):


	RefundTimeBar.value = _RETIME
	call_Logic()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_RefundTime_puppet", [_RETIME])

func call_PopShow():
	match _Pop:
		1:
			$TexNode / Sprite / CupInfo / CupPopAni.play("pop1")
		2:
			$TexNode / Sprite / CupInfo / CupPopAni.play("pop2")
		3:
			$TexNode / Sprite / CupInfo / CupPopAni.play("pop3")
		_:
			$TexNode / Sprite / CupInfo / CupPopAni.play("init")
func call_BeerShow():
	var _BEERANI = $TexNode / Sprite / CupInfo / BeerAni
	if _BEERANI.has_animation(str(_BEER)):
		_BEERANI.play(str(_BEER))
	else:
		_BEERANI.play("init")
func call_init(_orderID, _info, _WAITTIME):

	_ID = _orderID
	self.name = str(_ID)
	IDLabel.text = str(_ID)
	_Name = _info["Name"]
	_Celcius = _info["Celcius"]
	_Sugar = _info["Sugar"]
	_Pop = _info["Pop"]
	call_PopShow()
	_ExtraArray = _info["ExtraArray"]
	var _CUPNODE
	var _CUPNAME: String = "DrinkCup"
	if _info.has("MakeType"):
		_TYPE = _info.MakeType

		match _TYPE:
			1:
				_CUPNAME = "SodaCan"
			3:
				_CUPNAME = "BeerCup"
			4:
				_CUPNAME = "SuperCup"
			5:
				_CUPNAME = "EggRoll_white"
			6:
				_CUPNAME = "EggRoll_black"
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_CUPNAME)
		_CUPNODE = _TSCN.instance()
		$TexNode / CUPNODE.add_child(_CUPNODE)

	RefundTime = _WAITTIME

	RefundTimeBar.max_value = RefundTime
	RefundTimeBar.value = RefundTime

	if not GameLogic.Config.FormulaConfig.has(_Name):
		return
	_data = GameLogic.Config.FormulaConfig[_Name]
	if GameLogic.cur_Menu.has(_Name):
		BGAni.play(str(GameLogic.cur_Menu.find(_Name)))

	var _LiquidName = _data["LiquidName"]

	if _CUPNAME in ["SodaCan"]:
		_CUPNODE.IsPack = true
		_CUPNODE._IsPack_Logic()
	match _info.MakeType:
		0, 1, 2, 3:
			var _CupType = return_cuptype_aniname(_data["CupType"])
			var _layer = return_cupani_aniname(_data["CupType"])

			_CUPNODE.CupAni.play(_layer)
			_CUPNODE.CupTypeAni.play(_CupType)

		4:
			var _CupType = return_cuptype_aniname(_data["CupType"])
			var _layer = return_cupani_aniname(_data["CupType"])

			_CUPNODE.CupAni.play(_layer)
			_CUPNODE.CupTypeAni.play("SuperCup_M")

		5:
			_CUPNODE.CupTypeAni.play("EggRoll_white")

			match _data["CupType"]:
				"S":

					_CUPNODE.CupAni.play("ball1")
				"M":

					_CUPNODE.CupAni.play("ball2")
				"L":

					_CUPNODE.CupAni.play("ball3")
		6:
			_CUPNODE.CupTypeAni.play("EggRoll_black")
			match _data["CupType"]:
				"S":
					_CUPNODE.CupAni.play("ball1")
				"M":
					_CUPNODE.CupAni.play("ball2")
				"L":
					_CUPNODE.CupAni.play("ball3")
	match _data["CupType"]:
		"S":
			_CUPNODE.Liquid_Count = 2

		"M":
			_CUPNODE.Liquid_Count = 4

		"L":
			_CUPNODE.Liquid_Count = 6

	var _BEERTOP = _info["BeerPop"]
	var _TOP = int(_data["BeerPop"])

	_BEER = _TOP - int(_BEERTOP)
	call_BeerShow()
	if _TOP > 0:
		var _LiquidArray: Array
		var _DATAFORNUM = int(_data.FormulaNum)
		var _TOPNUM: int = 0
		for _i in _DATAFORNUM:
			var _NAME = "For_" + str(_i + 1)
			var _WATERTYPE = _data[_NAME]
			var _NAMENUM = _NAME + str("_Num")
			var _FORNUM = int(_data[_NAMENUM])
			for _j in _FORNUM:
				if _i == _DATAFORNUM - 1:
					if _j >= _FORNUM - _BEERTOP:
						_LiquidArray.append("啤酒泡")
						_TOPNUM += 1
					else:
						if int(_data["Mixd"]) == 2:
							_LiquidArray.append(_WATERTYPE)
						else:
							_LiquidArray.append(_data.LiquidName)
				else:
					if int(_data["Mixd"]) == 2:
						_LiquidArray.append(_WATERTYPE)
					else:
						_LiquidArray.append(_data.LiquidName)

		_CUPNODE.call_Liquid_Array(_LiquidArray)

		_CUPNODE.BEERTOPSAVE = _TOP

		_CUPNODE._BeerTop_Show(_TOPNUM)
	elif int(_data.Mixd) in [0, 2]:
		if int(_data.FormulaNum) == 1 and not _info.MakeType in [5, 6]:
			match _info.MakeType:
				0:
					_CUPNODE.call_Liquid_Set(_LiquidName, int(_data.IceCreamBool))
				1, 2, 3, 4:
					_CUPNODE.call_Liquid_Set(_LiquidName)
		else:
			var _LiquidCount: int = 0
			for _i in int(_data.FormulaNum):
				var _NAME = "For_" + str(_i + 1)
				var _WATERTYPE = _data[_NAME]
				var _FORNUMNAME = _NAME + "_Num"
				var _FORNUM = int(_data[_FORNUMNAME])
				if _FORNUM == 0:

					printerr(" 错误，配方液体配置为0")
				for i in _FORNUM:
					_LiquidCount += 1

					_CUPNODE.Liquid_Count = _LiquidCount
					_CUPNODE._ColorShow(_WATERTYPE)

	elif int(_data.Mixd) in [3]:
		var _LiquidArray: Array
		for _i in int(_data.FormulaNum):
			var _NAME = "For_" + str(_i + 1)
			var _NAMENUM = _NAME + str("_Num")
			var _FORNUM = int(_data[_NAMENUM])
			for _j in _FORNUM:
				if _i == int(_data.FormulaNum) - 1:
					if _j == _FORNUM - 1:
						_LiquidArray.append(_data[_NAME])
					else:
						_LiquidArray.append(_data.LiquidName)
				else:
					_LiquidArray.append(_data.LiquidName)

		_CUPNODE.call_Liquid_Array(_LiquidArray)
	elif int(_data.Mixd) in [4]:
		var _LiquidArray: Array
		var _NUM: int = 0
		for _i in int(_data.FormulaNum):
			var _NAME = "For_" + str(_i + 1)
			var _NAMENUM = _NAME + str("_Num")
			var _FORNUM = int(_data[_NAMENUM])
			for _j in _FORNUM:
				_NUM += 1
		var _CHECKNUM: int = 0
		for _i in int(_data.FormulaNum):
			var _NAME = "For_" + str(_i + 1)
			var _NAMENUM = _NAME + str("_Num")
			var _FORNUM = int(_data[_NAMENUM])
			for _j in _FORNUM:
				if _CHECKNUM >= _NUM - 2:
					_LiquidArray.append(_data[_NAME])
				else:
					_LiquidArray.append(_data.LiquidName)
				_CHECKNUM += 1
		_CUPNODE.call_Liquid_Array(_LiquidArray)

	else:
		match _info.MakeType:
			0:
				_CUPNODE.call_Liquid_Set(_LiquidName, int(_data.IceCreamBool))
			_:
				_CUPNODE.call_Liquid_Set(_LiquidName)


	for i in 7:
		if i == 6:
			var _Icon_Name = "For_Icon_" + str(i + 1)
			var _Icon = _data[_Icon_Name]
			_Icon_set_texture(_Icon, UIAct1)
		else:
			var _Icon_Name = "For_Icon_" + str(i + 1)
			var _Icon = _data[_Icon_Name]
			var _Sprite = FormulaNode.get_node(str(i + 1))
			_Icon_set_texture(_Icon, _Sprite)

	if _CUPNODE.CupTempratureAni.has_animation(_Celcius):
		_CUPNODE.CupTempratureAni.play(_Celcius)

	CelciusAni.play(_Celcius)
	match _Sugar:
		GameLogic.Order.SUGARTYPE.SUGAR:
			if _TYPE in [5, 6]:
				SweetAni.play("Choco")

				_CUPNODE.call_Choco()
			else:
				SweetAni.play("sugar")
		GameLogic.Order.SUGARTYPE.FREE:
			SweetAni.play("free")

	for _i in 5:
		if _i < 5:
			if ExtraNode.has_node(str(_i + 1)):
				var _Node = ExtraNode.get_node(str(_i + 1))
				_Icon_set_texture("", _Node)

	if _ExtraArray.size() > 0:
		for _i in _ExtraArray.size():
			var _ExtraName = _ExtraArray[_i]
			match _i:
				0:
					if _CUPNODE.Extra_1_Ani.has_animation(_ExtraArray[_i]):
						_CUPNODE.Extra_1_Ani.play(_ExtraArray[_i])

				1:
					if _CUPNODE.Extra_2_Ani.has_animation(_ExtraArray[_i]):
						_CUPNODE.Extra_2_Ani.play(_ExtraArray[_i])

				2:
					if _CUPNODE.Extra_3_Ani.has_animation(_ExtraArray[_i]):
						_CUPNODE.Extra_3_Ani.play(_ExtraArray[_i])


				3:
					if _CUPNODE.has_node("AniNode/Extra_4"):
						_CUPNODE.get_node("AniNode/Extra_4").play(_ExtraArray[_i])

				4:
					if _CUPNODE.has_node("AniNode/Extra_5"):
						_CUPNODE.get_node("AniNode/Extra_5").play(_ExtraArray[_i])

			if _i < 5:
				match _ExtraName:
					"小熊软糖":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_gummy"
						_Icon_set_texture(_Icon, _Node)
					"鸡蛋液":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_hademade_egg"
						_Icon_set_texture(_Icon, _Node)
					"话梅":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_plum"
						_Icon_set_texture(_Icon, _Node)
					"花生":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_peanut"
						_Icon_set_texture(_Icon, _Node)
					"葡萄干", "葡萄干碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_raisin"
						_Icon_set_texture(_Icon, _Node)

					"黑曲奇块", "黑曲奇碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_blackbear"
						_Icon_set_texture(_Icon, _Node)
					"布朗尼碎", "布朗尼块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_browny"
						_Icon_set_texture(_Icon, _Node)
					"葡萄块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_grape"
						_Icon_set_texture(_Icon, _Node)
					"葡萄酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_grape_smash"
						_Icon_set_texture(_Icon, _Node)

					"西柚块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_grapefruit"
						_Icon_set_texture(_Icon, _Node)
					"西柚酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_grapefruit_smash"
						_Icon_set_texture(_Icon, _Node)
					"奇亚籽":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_jelly"
						_Icon_set_texture(_Icon, _Node)
					"西瓜块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_melon"
						_Icon_set_texture(_Icon, _Node)
					"西瓜酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_melon_smash"
						_Icon_set_texture(_Icon, _Node)
					"桃子块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_peach"
						_Icon_set_texture(_Icon, _Node)
					"桃子酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_peach_smash"
						_Icon_set_texture(_Icon, _Node)
					"凤梨块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_pineapple"
						_Icon_set_texture(_Icon, _Node)
					"凤梨酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_pineapple_smash"
						_Icon_set_texture(_Icon, _Node)
					"桑葚":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_mulberry"
						_Icon_set_texture(_Icon, _Node)
					"草莓":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_strawberry"
						_Icon_set_texture(_Icon, _Node)
					"草莓酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_strawberry_smash"
						_Icon_set_texture(_Icon, _Node)
					"火龙果块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_dragon"
						_Icon_set_texture(_Icon, _Node)
					"牛油果块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_avocado"
						_Icon_set_texture(_Icon, _Node)
					"芒果块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_mango"
						_Icon_set_texture(_Icon, _Node)
					"芒果酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_mango_smash"
						_Icon_set_texture(_Icon, _Node)
					"杨梅块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_bayberry"
						_Icon_set_texture(_Icon, _Node)
					"杨梅酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_bayberry_smash"
						_Icon_set_texture(_Icon, _Node)
					"香蕉块":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_banana"
						_Icon_set_texture(_Icon, _Node)
					"香蕉酱":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_banana_smash"
						_Icon_set_texture(_Icon, _Node)
					"百香果肉":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_hademade_passion"
						_Icon_set_texture(_Icon, _Node)
					"黑糖珍珠":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_bobabrown"
						_Icon_set_texture(_Icon, _Node)
					"原味珍珠":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_bobawhite"
						_Icon_set_texture(_Icon, _Node)

					"栗子", "栗子碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_chestnut"
						_Icon_set_texture(_Icon, _Node)
					"椰果", "椰果碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_coconut"
						_Icon_set_texture(_Icon, _Node)
					"仙草冻", "仙草冻碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_grassjelly"
						_Icon_set_texture(_Icon, _Node)
					"脆波波", "脆波波碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_konjac"
						_Icon_set_texture(_Icon, _Node)
					"红豆", "红豆碎":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_redbean"
						_Icon_set_texture(_Icon, _Node)
					"酒酿":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_ricewine"
						_Icon_set_texture(_Icon, _Node)
					"西米":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_sago"
						_Icon_set_texture(_Icon, _Node)
					"鲜芋":
						var _Node = ExtraNode.get_node(str(_i + 1))
						var _Icon = "Icon_Extra_taro"
						_Icon_set_texture(_Icon, _Node)
					_:
						var _Node = ExtraNode.get_node(str(_i + 1))
						_Icon_set_texture("", _Node)

	if _data.Condiment_1:

		_CUPNODE.call_Condiment_play(_data.Condiment_1)

		match _data.Condiment_1:
			"糖渍樱桃":
				var _Icon = "糖渍樱桃"
				_Icon_set_texture(_Icon, CondNode.get_node("1"))
			"薄荷叶":
				var _Icon = "薄荷叶"
				_Icon_set_texture(_Icon, CondNode.get_node("1"))
			"黑曲奇完整":
				var _Icon = "Icon_deco_blackbear"
				_Icon_set_texture(_Icon, CondNode.get_node("1"))
			"青桔块":
				var _Icon = "Icon_deco_lemon"
				_Icon_set_texture(_Icon, CondNode.get_node("1"))
			"柠檬片":
				var _Icon = "Icon_deco_lime"
				_Icon_set_texture(_Icon, CondNode.get_node("1"))
			"芝士片":
				var _Icon = "Icon_deco_cheeze"
				_Icon_set_texture(_Icon, CondNode.get_node("1"))
	else:
		_Icon_set_texture("", CondNode.get_node("1"))
	if _data.Top != "":
		_CUPNODE.TopAni.play(_data.Top)

		match _data.Top:
			"奶油顶可可":
				var _Icon = "Icon_deco_cream_coco"
				_Icon_set_texture(_Icon, CondNode.get_node("2"))
			"奶油顶草莓":
				var _Icon = "Icon_deco_cream_berry"
				_Icon_set_texture(_Icon, CondNode.get_node("2"))
	else:
		_Icon_set_texture("", CondNode.get_node("2"))
	if _data.Hang != "":
		_CUPNODE.HangAni.play(_data.Hang)



		match _data.Hang:
			"挂壁巧克力":
				var _Icon = "Icon_syrup_chocolate_up"
				_Icon_set_texture(_Icon, UIAct2)
			"上层巧克力":
				var _Icon = "Icon_syrup_chocolate_down"
				_Icon_set_texture(_Icon, UIAct2)
			"挂壁焦糖":
				var _Icon = "Icon_syrup_caramel_up"
				_Icon_set_texture(_Icon, UIAct2)
			"上层焦糖":
				var _Icon = "Icon_syrup_caramel_down"
				_Icon_set_texture(_Icon, UIAct2)
	else:
		_Icon_set_texture("", UIAct2)

func _Icon_set_texture(_Icon, _Sprite):
	match _Icon:

		"糖渍樱桃":
			var _tex = "res://Resources/Item/item_pack.sprites/item_deco_cherry.tres"
			var _texload = load(_tex)
			_Sprite.set_texture(_texload)
			_Sprite.show()
		"薄荷叶":
			var _tex = "res://Resources/Item/item_pack.sprites/item_deco_mint.tres"
			var _texload = load(_tex)
			_Sprite.set_texture(_texload)
			_Sprite.show()
		"Icon_deco_blackbear":
			var _tex = "res://Resources/Item/item_pack.sprites/item_deco_blackbear.tres"
			var _texload = load(_tex)
			_Sprite.set_texture(_texload)
			_Sprite.show()
		"柠檬汁":
			var _tex = "res://Resources/Item/item_pack.sprites/fruit_lemon_single_1.tres"
			var _texload = load(_tex)
			_Sprite.set_texture(_texload)
			_Sprite.show()
		"":
			_Sprite.hide()
		_:
			if _Icon != "":
				var _tex = "res://Resources/UI/GameUI/ui_pack.sprites/" + _Icon + ".tres"
				var _texload = load(_tex)
				_Sprite.set_texture(_texload)
				_Sprite.show()
			else:
				_Sprite.hide()

func call_Formula_show():
	if not Del_Bool:
		OrderAni.play("check")
		Audio_Show.play(0)

func call_Formula_hide():
	if not Del_Bool:
		OrderAni.play("normal")

func call_refund():

	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_refund_puppet", [RefundTimeBar.value, RefundTimeBar.max_value])
	Del_Bool = true
	OrderUIAni.play("refund")
	Audio_Refund.play(0)
func call_refund_puppet(_VALUE, _MAX):
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	RefundTimeBar.max_value = _MAX
	RefundTimeBar.value = _VALUE
	Del_Bool = true
	OrderUIAni.play("refund")
	Audio_Refund.play(0)
func call_PickUp_ready():
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PickUp_Ready_puppet", [RefundTimeBar.value, RefundTimeBar.max_value])
	_Ready = true
	OrderUIAni.play("pickup_ready")
	_RefundTimer.set_paused(true)

func call_PickUp_Ready_puppet(_VALUE, _MAX):
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	RefundTimeBar.max_value = _MAX
	RefundTimeBar.value = _VALUE
	_Ready = true
	OrderUIAni.play("pickup_ready")
	_RefundTimer.set_paused(true)
func call_PickUp_NotReady():
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PickUp_NotReady_puppet", [RefundTimeBar.value, RefundTimeBar.max_value])
	_Ready = false
	if OrderUIAni.assigned_animation in ["pickup_ready"]:
		OrderUIAni.play_backwards("pickup_ready")
	_RefundTimer.set_paused(false)

func call_PickUp_NotReady_puppet(_VALUE, _MAX):
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	RefundTimeBar.max_value = _MAX
	RefundTimeBar.value = _VALUE
	_Ready = false
	OrderUIAni.play_backwards("pickup_ready")
	_RefundTimer.set_paused(false)
func call_PickUp():
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PickUp_puppet", [RefundTimeBar.value, RefundTimeBar.max_value])
	OrderUIAni.play("pickup")

func call_PickUp_puppet(_VALUE, _MAX):
	if OrderUIAni.assigned_animation in ["pickup", "refund"]:
		return
	RefundTimeBar.max_value = _MAX
	RefundTimeBar.value = _VALUE
	OrderUIAni.play("pickup")
func call_queue_free():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_queue_puppet")
	self.queue_free()
func call_queue_puppet():
	self.queue_free()
func call_Order_OutLine(_Type: int):
	match _Type:
		0:
			get_node("OutLineAni").play("init")
		1, SteamLogic.STEAM_ID:
			get_node("OutLineAni").play("1")
		2:
			get_node("OutLineAni").play("2")
