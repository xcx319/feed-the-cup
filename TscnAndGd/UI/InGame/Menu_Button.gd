extends Button

onready var NameLabel = get_node("Label")

onready var TemperatureNode = get_node("Info/Temperature/ScrollContainer/HBoxContainer")
onready var DayNode = get_node("Info/Day/ScrollContainer/HBoxContainer")
onready var DrinkCup = get_node("Info/DrinkCup")
onready var SodaCan = $SodaCan / SodaCan
onready var SuperCup = $SuperCup / SuperCup
onready var EggRoll = $EggRoll / EggRoll
onready var BeerCup = $BeerCup / BeerCup
onready var Bag = get_node("CanInfo/Bag")
onready var ValueNode = get_node("TextureProgress")
onready var SelectAni = get_node("Ani/SelectAni")
onready var SugarNode = get_node("Info/Sugar")

onready var FreeNode = $Info / Free
onready var PopAni = $Info / Pop / Ani
onready var ItemNode = get_node("Info/ScrollContainer/HBoxContainer")
onready var PriceLabel = get_node("PriceLabel")
onready var ApplyBut = get_node("Apply")
onready var StarHBox = get_node("HBox")

onready var But_A = get_node("Apply/A")

onready var TypeAni = get_node("Ani/TypeAni")
onready var BGAni = get_node("Ani/BGAni")

onready var CanLabel = $CanInfo / Label

var ForName: String
var _Data

var ButType: int = 0

var WeatherValue: int = 0
var Dayvalue: int = 0
var Value: int = 0
var _pressed: bool

var _SelectBool: bool
var AlwaysShow: bool
func _ready() -> void :

	set_process(false)
	call_deferred("_MenuButton_set")


func call_ButInfo(_Type: int):
	ButType = _Type
	match _Type:
		0:
			But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_Str)
		1:
			But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_1)
		2:
			But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_2)

func _on_focus_entered() -> void :

	call_button_switch(true)

	GameLogic.Audio.But_EasyClick.play(0)
	pass
func _on_focus_exited() -> void :

	call_button_switch(false)

	pass

func _MenuButton_set():

	if not GameLogic.GameUI.is_connected("TimeChange", self, "_TimeChange_Logic"):
		GameLogic.GameUI.connect("TimeChange", self, "_TimeChange_Logic")
	if not ForName or not GameLogic.Config.FormulaConfig.has(ForName):

		return

	if GameLogic.cur_Menu.has(ForName):
		BGAni.play(str(GameLogic.cur_Menu.find(ForName)))
	DrinkCup.call_Hang_Reset()
	SodaCan.call_Hang_Reset()
	SuperCup.call_Hang_Reset()
	BeerCup.call_Hang_Reset()
	_MenuButton_init()
	_Data = GameLogic.Config.FormulaConfig[ForName]
	NameLabel.call_Tr_TEXT(_Data.Name)

	$Info / Label.text = _Data.RatioString


	StarHBox.get_node("1").show()
	StarHBox.get_node("1/TextureProgress").value = 2
	StarHBox.get_node("2").show()
	StarHBox.get_node("2/TextureProgress").value = 2
	StarHBox.get_node("3").show()
	StarHBox.get_node("3/TextureProgress").value = 2
	StarHBox.get_node("4").show()
	StarHBox.get_node("4/TextureProgress").value = 2
	StarHBox.get_node("5").show()
	StarHBox.get_node("5/TextureProgress").value = 2
	var _StarNum = int(_Data.Rank)
	if _StarNum == 1:
		StarHBox.get_node("1/TextureProgress").value = 1
	if _StarNum == 3:
		StarHBox.get_node("2/TextureProgress").value = 1
	if _StarNum == 5:
		StarHBox.get_node("3/TextureProgress").value = 1
	if _StarNum == 7:
		StarHBox.get_node("4/TextureProgress").value = 1
	if _StarNum == 9:
		StarHBox.get_node("5/TextureProgress").value = 1
	if _StarNum < 9:
		StarHBox.get_node("5").hide()
	if _StarNum < 7:
		StarHBox.get_node("4").hide()
	if _StarNum < 5:
		StarHBox.get_node("3").hide()
	if _StarNum < 3:
		StarHBox.get_node("2").hide()
	DrinkCup.TopAni.play("init")
	SodaCan.TopAni.play("init")
	SuperCup.TopAni.play("init")
	EggRoll.TopAni.play("init")
	BeerCup.TopAni.play("init")

	PriceLabel.text = str(_Data.Price)
	if "CAN" in _Data.Type:
		TypeAni.play("Can")
		if $Type / TypeAni.has_animation(_Data.LiquidName):
			$Type / TypeAni.play(_Data.LiquidName)
		print(" Can Ani:", _Data)
		Bag.typeAni.play(_Data.Ani)
		match _Data.Ani:
			"can_chestnut":
				CanLabel.text = GameLogic.CardTrans.get_message("信息-捏碎说明")
			"芋头":
				CanLabel.text = GameLogic.CardTrans.get_message("信息-芋头说明")
			_:
				CanLabel.text = GameLogic.CardTrans.get_message("信息-小料说明")
	else:

		match _Data.MakeType:
			"1":
				TypeAni.play("SodaCan")
			"2":
				TypeAni.play("DrinkAndSodaCan")
			"3":
				TypeAni.play("BeerCup")
			"4":
				TypeAni.play("SuperCup")

			"5", "6":
				TypeAni.play("EggRoll")
			_:
				TypeAni.play("Drink")
		EggRoll.Extra_1_Ani.play("init")
		EggRoll.Extra_2_Ani.play("init")
		EggRoll.Extra_3_Ani.play("init")
		SuperCup.Extra_1_Ani.play("init")
		SuperCup.Extra_2_Ani.play("init")
		SuperCup.Extra_3_Ani.play("init")
		if SuperCup.has_node("AniNode/Extra_4"):
			SuperCup.get_node("AniNode/Extra_4").play("init")
		if SuperCup.has_node("AniNode/Extra_5"):
			SuperCup.get_node("AniNode/Extra_5").play("init")
		if $Size / Ani.has_animation(_Data.CupType):
			$Size / Ani.play(_Data.CupType)

			if $Type / TypeAni.has_animation(_Data.Type[0]):
				$Type / TypeAni.play(_Data.Type[0])


			if _Data.Extra_1 != "":

				if EggRoll.Extra_1_Ani.has_animation(_Data.Extra_1):
					EggRoll.Extra_1_Ani.play(_Data.Extra_1)
				if DrinkCup.Extra_1_Ani.has_animation(_Data.Extra_1):
					DrinkCup.Extra_1_Ani.play(_Data.Extra_1)

				if SodaCan.Extra_1_Ani.has_animation(_Data.Extra_1):
					SodaCan.Extra_1_Ani.play(_Data.Extra_1)
				if SuperCup.Extra_1_Ani.has_animation(_Data.Extra_1):
					SuperCup.Extra_1_Ani.play(_Data.Extra_1)
				if BeerCup.Extra_1_Ani.has_animation(_Data.Extra_1):
					BeerCup.Extra_1_Ani.play(_Data.Extra_1)

				if _Data.Extra_2 != "":

					if BeerCup.Extra_2_Ani.has_animation(_Data.Extra_1):
						BeerCup.Extra_2_Ani.play(_Data.Extra_1)
						if _Data.Extra_3 != "":
							if BeerCup.Extra_3_Ani.has_animation(_Data.Extra_3):
								BeerCup.Extra_3_Ani.play(_Data.Extra_3)
						else:
							BeerCup.Extra_3_Ani.play("init")
					if EggRoll.Extra_2_Ani.has_animation(_Data.Extra_1):
						EggRoll.Extra_2_Ani.play(_Data.Extra_1)
						if _Data.Extra_3 != "":
							if EggRoll.Extra_3_Ani.has_animation(_Data.Extra_3):
								EggRoll.Extra_3_Ani.play(_Data.Extra_3)
						else:
							EggRoll.Extra_3_Ani.play("init")
					if SuperCup.Extra_2_Ani.has_animation(_Data.Extra_1):
						SuperCup.Extra_2_Ani.play(_Data.Extra_1)
						if _Data.Extra_3 != "":
							if SuperCup.Extra_3_Ani.has_animation(_Data.Extra_3):
								SuperCup.Extra_3_Ani.play(_Data.Extra_3)
						else:
							SuperCup.Extra_3_Ani.play("init")
					if DrinkCup.Extra_2_Ani.has_animation(_Data.Extra_2):
						DrinkCup.Extra_2_Ani.play(_Data.Extra_2)
						if _Data.Extra_3 != "":
							if DrinkCup.Extra_3_Ani.has_animation(_Data.Extra_3):
								DrinkCup.Extra_3_Ani.play(_Data.Extra_3)
						else:
							DrinkCup.Extra_3_Ani.play("init")
					if SodaCan.Extra_2_Ani.has_animation(_Data.Extra_2):
						SodaCan.Extra_2_Ani.play(_Data.Extra_2)
						if _Data.Extra_3 != "":

							if SodaCan.Extra_3_Ani.has_animation(_Data.Extra_3):
								SodaCan.Extra_3_Ani.play(_Data.Extra_3)

						else:
							SodaCan.Extra_3_Ani.play("init")
				else:
					EggRoll.Extra_3_Ani.play("init")
					EggRoll.Extra_2_Ani.play("init")
					DrinkCup.Extra_3_Ani.play("init")
					DrinkCup.Extra_2_Ani.play("init")
					SodaCan.Extra_3_Ani.play("init")
					SodaCan.Extra_2_Ani.play("init")
					SuperCup.Extra_3_Ani.play("init")
					SuperCup.Extra_2_Ani.play("init")
					BeerCup.Extra_3_Ani.play("init")
					BeerCup.Extra_2_Ani.play("init")

			else:
				EggRoll.Extra_1_Ani.play("init")
				EggRoll.Extra_2_Ani.play("init")
				EggRoll.Extra_3_Ani.play("init")
				DrinkCup.Extra_1_Ani.play("init")
				DrinkCup.Extra_2_Ani.play("init")
				DrinkCup.Extra_3_Ani.play("init")
				SodaCan.Extra_1_Ani.play("init")
				SodaCan.Extra_2_Ani.play("init")
				SodaCan.Extra_3_Ani.play("init")
				SuperCup.Extra_1_Ani.play("init")
				SuperCup.Extra_2_Ani.play("init")
				SuperCup.Extra_3_Ani.play("init")
				BeerCup.Extra_1_Ani.play("init")
				BeerCup.Extra_2_Ani.play("init")
				BeerCup.Extra_3_Ani.play("init")

			EggRoll.Condiment_1_Ani.play("init")
			EggRoll.CupTempratureAni.play("Normal")
			DrinkCup.Condiment_1_Ani.play("init")
			DrinkCup.CupTempratureAni.play("Normal")
			SodaCan.Condiment_1_Ani.play("init")
			SodaCan.CupTempratureAni.play("Normal")
			SuperCup.Condiment_1_Ani.play("init")
			SuperCup.CupTempratureAni.play("Normal")
			BeerCup.Condiment_1_Ani.play("init")
			BeerCup.CupTempratureAni.play("Normal")
			match _Data.CupType:
				"S":
					match int(_Data.MakeType):
						0, 1:
							DrinkCup.CupTypeAni.play("DrinkCup_S")
							DrinkCup.CupAni.play("Layer2")
							DrinkCup.Liquid_Count = 2
							SodaCan.CupTypeAni.play("DrinkCup_S")
							SodaCan.CupAni.play("Layer2")
							SodaCan.Liquid_Count = 2
						2:
							SodaCan.CupTypeAni.play("DrinkCup_S")
							SodaCan.CupAni.play("Layer2")
							SodaCan.Liquid_Count = 2
						3:
							BeerCup.CupTypeAni.play("BeerCup_S")
							BeerCup.CupAni.play("Layer2")
							BeerCup.Liquid_Count = 2
						5:
							EggRoll.CupTypeAni.play("EggRoll_white")
							EggRoll.CupAni.play("ball1")
							EggRoll.Liquid_Count = 2
						6:
							EggRoll.CupTypeAni.play("EggRoll_black")
							EggRoll.CupAni.play("ball1")
							EggRoll.Liquid_Count = 2

				"M":
					var _x = int(_Data.MakeType)
					match int(_Data.MakeType):
						0, 1:
							DrinkCup.CupTypeAni.play("DrinkCup_M")
							DrinkCup.CupAni.play("Layer4")
							DrinkCup.Liquid_Count = 4
							SodaCan.CupTypeAni.play("DrinkCup_M")
							SodaCan.CupAni.play("Layer4")
							SodaCan.Liquid_Count = 4
						2:
							SodaCan.CupTypeAni.play("DrinkCup_M")
							SodaCan.CupAni.play("Layer4")
							SodaCan.Liquid_Count = 4
						3:
							BeerCup.CupTypeAni.play("BeerCup_M")
							BeerCup.CupAni.play("Layer4")
							BeerCup.Liquid_Count = 4
						4:
							SuperCup.CupTypeAni.play("SuperCup_M")
							SuperCup.CupAni.play("Layer4")
							SuperCup.Liquid_Count = 4
						5:
							EggRoll.CupTypeAni.play("EggRoll_white")
							EggRoll.CupAni.play("ball2")
							EggRoll.Liquid_Count = 4
						6:
							EggRoll.CupTypeAni.play("EggRoll_black")
							EggRoll.CupAni.play("ball2")
							EggRoll.Liquid_Count = 4
				"L":
					match int(_Data.MakeType):
						0, 1:
							DrinkCup.CupTypeAni.play("DrinkCup_L")
							DrinkCup.CupAni.play("Layer6")
							DrinkCup.Liquid_Count = 6
							SodaCan.CupTypeAni.play("DrinkCup_L")
							SodaCan.CupAni.play("Layer6")
							SodaCan.Liquid_Count = 6
						2:
							SodaCan.CupTypeAni.play("DrinkCup_L")
							SodaCan.CupAni.play("Layer6")
							SodaCan.Liquid_Count = 6
						3:
							BeerCup.CupTypeAni.play("BeerCup_L")
							BeerCup.CupAni.play("Layer6")
							BeerCup.Liquid_Count = 6
						5:
							EggRoll.CupTypeAni.play("EggRoll_white")
							EggRoll.CupAni.play("ball3")
							EggRoll.Liquid_Count = 6
						6:
							EggRoll.CupTypeAni.play("EggRoll_black")
							EggRoll.CupAni.play("ball3")
							EggRoll.Liquid_Count = 6

			if int(_Data.Mixd) in [0, 1] and not int(_Data.MakeType) in [5, 6]:
				EggRoll.call_Liquid_Set(_Data.LiquidName)
				DrinkCup.call_Liquid_Set(_Data.LiquidName, int(_Data.IceCreamBool))
				SodaCan.call_Liquid_Set(_Data.LiquidName)
				SuperCup.call_Liquid_Set(_Data.LiquidName)
				BeerCup.call_Liquid_Set(_Data.LiquidName)
			elif int(_Data.Mixd) in [3]:
				var _LiquidArray: Array
				for _i in int(_Data.FormulaNum):
					var _NAME = "For_" + str(_i + 1)
					var _NAMENUM = _NAME + str("_Num")
					var _FORNUM = int(_Data[_NAMENUM])
					for _j in _FORNUM:
						if _i == int(_Data.FormulaNum) - 1:
							if _j == _FORNUM - 1:
								_LiquidArray.append(_Data[_NAME])
							else:
								_LiquidArray.append(_Data.LiquidName)
						else:
							_LiquidArray.append(_Data.LiquidName)
				EggRoll.call_Liquid_Array(_LiquidArray)
				DrinkCup.call_Liquid_Array(_LiquidArray)
				SodaCan.call_Liquid_Array(_LiquidArray)
				SuperCup.call_Liquid_Array(_LiquidArray)
				BeerCup.call_Liquid_Array(_LiquidArray)
			elif int(_Data.Mixd) in [4]:
				var _LiquidArray: Array
				var _NUM: int = 0
				for _i in int(_Data.FormulaNum):
					var _NAME = "For_" + str(_i + 1)
					var _NAMENUM = _NAME + str("_Num")
					var _FORNUM = int(_Data[_NAMENUM])
					for _j in _FORNUM:
						_NUM += 1
				var _CHECKNUM: int = 0
				for _i in int(_Data.FormulaNum):
					var _NAME = "For_" + str(_i + 1)
					var _NAMENUM = _NAME + str("_Num")
					var _FORNUM = int(_Data[_NAMENUM])
					for _j in _FORNUM:
						if _CHECKNUM >= _NUM - 2:
							_LiquidArray.append(_Data[_NAME])
						else:
							_LiquidArray.append(_Data.LiquidName)
						_CHECKNUM += 1
				EggRoll.call_Liquid_Array(_LiquidArray)
				DrinkCup.call_Liquid_Array(_LiquidArray)
				SodaCan.call_Liquid_Array(_LiquidArray)
				SuperCup.call_Liquid_Array(_LiquidArray)
				BeerCup.call_Liquid_Array(_LiquidArray)
			else:
				var _LiquidArray: Array
				for _i in int(_Data.FormulaNum):
					var _NAME = "For_" + str(_i + 1)
					var _NAMENUM = _NAME + str("_Num")
					var _NUM = int(_Data[_NAMENUM])
					for _j in _NUM:
						_LiquidArray.append(_Data[_NAME])
				EggRoll.call_Liquid_Array(_LiquidArray)
				DrinkCup.call_Liquid_Array(_LiquidArray)
				SodaCan.call_Liquid_Array(_LiquidArray)
				SuperCup.call_Liquid_Array(_LiquidArray)
				BeerCup.call_Liquid_Array(_LiquidArray)
		else:
			DrinkCup.CupTypeAni.play("DrinkCup_S")
			BeerCup.CupTypeAni.play("BeerCup_S")
			if _Data.Name in ["桑葚", "草莓",
				"百香果肉",
				"香蕉块",
				"西瓜块",
				"凤梨块",
				"杨梅块",
				"芒果块",
				"牛油果块",
				"桃子块",
				"西柚块",
				"葡萄块",
				"草莓酱",
				"香蕉酱",
				"西瓜酱",
				"凤梨酱",
				"杨梅酱",
				"芒果酱",
				"桃子酱",
				"西柚酱",
				"葡萄酱",
				"西米", "原味珍珠", "黑糖珍珠",
				]:

				if DrinkCup.Extra_1_Ani.has_animation(_Data.Name):
					DrinkCup.Extra_1_Ani.play(_Data.Name)
				if BeerCup.Extra_1_Ani.has_animation(_Data.Name):
					BeerCup.Extra_1_Ani.play(_Data.Name)

		if _Data.Finish in ["沙冰"]:
			TemperatureNode.get_node("Ice2").show()
			TemperatureNode.get_node("Ice3").show()
		else:
			if _Data.CanHot:
				TemperatureNode.get_node("Hot").show()
			if _Data.CanCold:
				TemperatureNode.get_node("Ice").show()
			if _Data.CanNormal:
				TemperatureNode.get_node("Normal").show()

		var _SUGERTYPE: int = int(_Data.SugarType)
		match _SUGERTYPE:
			1:
				if int(_Data.MakeType) in [5, 6]:
					get_node("Info/Choco").show()
				else:
					SugarNode.show()
			2:
				FreeNode.show()

			3:
				SugarNode.show()
				FreeNode.show()

		var _POPNUM: int = int(_Data.PopMax)
		match _POPNUM:
			1:
				PopAni.play("pop1")
			2:
				PopAni.play("pop2")
			3:
				PopAni.play("pop3")
			_:
				PopAni.play("init")


	var _BeerPop: int = int(_Data.BeerPop)
	if _BeerPop > 0:
		BeerCup.call_BeerTop(_BeerPop)
	var _ExNum: int = 1
	var _ExList: Array
	var _HasMilk: bool
	var _ShowBool: bool
	if int(_Data.ShowNum) > 0:
		_ShowBool = true

	for i in 6:
		if _ShowBool:

			var _BAGID = i + 1

			var _For_Name = "Bag_" + str(_BAGID)

			var _For = _Data[_For_Name]

			var _Node = ItemNode.get_node(str(_BAGID))
			if _For != "":
				ItemNode.get_node(str(_BAGID)).show()
			else:
				ItemNode.get_node(str(_BAGID)).hide()

			if _For != "" and not _HasMilk:
				if _For == "coffeemaker_milkfoam":
					if not _HasMilk:
						_HasMilk = true
						_Node.get_node("Bag/AniNode/typeAni").play("ice_milk")
				elif _For == "ice_milk":
					if not _HasMilk:
						_HasMilk = true
						_Node.get_node("Bag/AniNode/typeAni").play("ice_milk")
				else:
					_Node.get_node("Bag/AniNode/typeAni").play(_For)
				EggRoll.Condiment_1_Ani.play(_Data.Condiment_1)
				DrinkCup.Condiment_1_Ani.play(_Data.Condiment_1)
				if SodaCan.Condiment_1_Ani.has_animation(_Data.Condiment_1):
					SodaCan.Condiment_1_Ani.play(_Data.Condiment_1)
				if SuperCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
					SuperCup.Condiment_1_Ani.play(_Data.Condiment_1)
				if BeerCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
					BeerCup.Condiment_1_Ani.play(_Data.Condiment_1)

			else:
				if _For == "coffeemaker_milkfoam" and _HasMilk:
					_Node.hide()

					pass
				elif _Node.get_node("Bag/AniNode/typeAni").has_animation(_For):
					_Node.get_node("Bag/AniNode/typeAni").play(_For)
				else:

					if GameLogic.Config.FormulaConfig.has(_For):
						var _ANINAME = GameLogic.Config.FormulaConfig[_For].For_1
						if _Node.get_node("Bag/AniNode/typeAni").has_animation(_ANINAME):
							_Node.get_node("Bag/AniNode/typeAni").play(_ANINAME)
				if _BAGID == int(_Data.ShowNum) + _ExNum and _Data.Condiment_1 and not _ExList.has(_Data.Condiment_1):

					_ExList.append(_Data.Condiment_1)
					_ExNum += 1

					EggRoll.Condiment_1_Ani.play(_Data.Condiment_1)
					DrinkCup.Condiment_1_Ani.play(_Data.Condiment_1)
					if SodaCan.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						SodaCan.Condiment_1_Ani.play(_Data.Condiment_1)
					if SuperCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						SuperCup.Condiment_1_Ani.play(_Data.Condiment_1)
					if BeerCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						BeerCup.Condiment_1_Ani.play(_Data.Condiment_1)
				elif _BAGID == int(_Data.ShowNum) + _ExNum and _Data.Top != "" and not _ExList.has(_Data.Top):
					_ExList.append(_Data.Top)
					_ExNum += 1

					EggRoll.TopAni.play(_Data.Top)
					DrinkCup.TopAni.play(_Data.Top)
					if SodaCan.TopAni.has_animation(_Data.Top):
						SodaCan.TopAni.play(_Data.Top)
					if SuperCup.TopAni.has_animation(_Data.Top):
						SuperCup.TopAni.play(_Data.Top)
					if BeerCup.TopAni.has_animation(_Data.Top):
						BeerCup.TopAni.play(_Data.Top)
				elif _BAGID == int(_Data.ShowNum) + _ExNum and _Data.Hang != "" and not _ExList.has(_Data.Hang):
					_ExList.append(_Data.Hang)
					_ExNum += 1

					EggRoll.HangAni.play(_Data.Hang)
					DrinkCup.HangAni.play(_Data.Hang)
					if SodaCan.HangAni.has_animation(_Data.Hang):
						SodaCan.HangAni.play(_Data.Hang)
					if SuperCup.HangAni.has_animation(_Data.Hang):
						SuperCup.HangAni.play(_Data.Hang)
					if BeerCup.HangAni.has_animation(_Data.Hang):
						BeerCup.HangAni.play(_Data.Hang)
				elif _BAGID == int(_Data.ShowNum) + _ExNum and _Data.Extra_1 != "" and not _ExList.has(_Data.Extra_1):
					_ExList.append(_Data.Extra_1)
					_ExNum += 1
					var _AniName: String = GameLogic.Config.FormulaConfig[_Data.Extra_1].Ani

					EggRoll.Extra_1_Ani.play(_Data.Extra_1)
					DrinkCup.Extra_1_Ani.play(_Data.Extra_1)
					if SodaCan.Extra_1_Ani.has_animation(_Data.Extra_1):
						SodaCan.Extra_1_Ani.play(_Data.Extra_1)
					if SuperCup.Extra_1_Ani.has_animation(_Data.Extra_1):
						SuperCup.Extra_1_Ani.play(_Data.Extra_1)
					if BeerCup.Extra_1_Ani.has_animation(_Data.Extra_1):
						BeerCup.Extra_1_Ani.play(_Data.Extra_1)


				elif _BAGID == int(_Data.ShowNum) + _ExNum and _Data.Extra_2 != "" and not _ExList.has(_Data.Extra_2):
					_ExList.append(_Data.Extra_2)
					_ExNum += 1
					var _ExtraList: Array
					_ExtraList.append(_Data.Extra_1)
					if not _ExtraList.has(_Data.Extra_2):
						var _AniName: String = GameLogic.Config.FormulaConfig[_Data.Extra_2].Ani

						EggRoll.Extra_2_Ani.play(_Data.Extra_2)
						DrinkCup.Extra_2_Ani.play(_Data.Extra_2)
						if SodaCan.Extra_2_Ani.has_animation(_Data.Extra_2):
							SodaCan.Extra_2_Ani.play(_Data.Extra_2)
						if SuperCup.Extra_2_Ani.has_animation(_Data.Extra_2):
							SuperCup.Extra_2_Ani.play(_Data.Extra_2)
						if BeerCup.Extra_2_Ani.has_animation(_Data.Extra_2):
							BeerCup.Extra_2_Ani.play(_Data.Extra_2)



				elif _BAGID == int(_Data.ShowNum) + _ExNum and _Data.Extra_3 != "" and not _ExList.has(_Data.Extra_3):
					_ExList.append(_Data.Extra_3)
					var _ExtraList: Array
					_ExtraList.append(_Data.Extra_1)
					_ExtraList.append(_Data.Extra_2)
					if not _ExtraList.has(_Data.Extra_3):
						var _AniName: String = GameLogic.Config.FormulaConfig[_Data.Extra_3].Ani

						if EggRoll.Extra_3_Ani.has_animation(_Data.Extra_3):
							EggRoll.Extra_3_Ani.play(_Data.Extra_3)
						if DrinkCup.Extra_3_Ani.has_animation(_Data.Extra_3):
							DrinkCup.Extra_3_Ani.play(_Data.Extra_3)
						if SodaCan.Extra_3_Ani.has_animation(_Data.Extra_3):
							SodaCan.Extra_3_Ani.play(_Data.Extra_3)
						if SuperCup.Extra_3_Ani.has_animation(_Data.Extra_3):
							SuperCup.Extra_3_Ani.play(_Data.Extra_3)
						if BeerCup.Extra_3_Ani.has_animation(_Data.Extra_3):
							BeerCup.Extra_3_Ani.play(_Data.Extra_3)

		elif not _ShowBool:
			var _BAGID = i + 1
			ItemNode.get_node(str(_BAGID)).show()
			var _For_Name = "For_" + str(_BAGID)
			var _For_Num_Name = _For_Name + "_Num"
			var _For = _Data[_For_Name]
			var _For_Num = _Data[_For_Num_Name]
			var _Node = ItemNode.get_node(str(_BAGID))

			if _For != "" and not _HasMilk:
				if _For == "coffeemaker_milkfoam":
					if not _HasMilk:
						_HasMilk = true
						_Node.get_node("Bag/AniNode/typeAni").play("ice_milk")
				elif _For == "ice_milk":
					if not _HasMilk:
						_HasMilk = true
						_Node.get_node("Bag/AniNode/typeAni").play("ice_milk")
				else:
					_Node.get_node("Bag/AniNode/typeAni").play(_For)
			else:
				if _For == "coffeemaker_milkfoam" and _HasMilk:
					_Node.hide()

					pass
				elif _Node.get_node("Bag/AniNode/typeAni").has_animation(_For):
					_Node.get_node("Bag/AniNode/typeAni").play(_For)


			if _BAGID > int(_Data.FormulaNum):
				if _BAGID == int(_Data.FormulaNum) + _ExNum and _Data.Condiment_1 and not _ExList.has(_Data.Condiment_1):

					_ExList.append(_Data.Condiment_1)
					_ExNum += 1
					if _Node.get_node("Bag/AniNode/typeAni").has_animation(_Data.Condiment_1):
						_Node.get_node("Bag/AniNode/typeAni").play(_Data.Condiment_1)
					if EggRoll.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						EggRoll.Condiment_1_Ani.play(_Data.Condiment_1)
					if DrinkCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						DrinkCup.Condiment_1_Ani.play(_Data.Condiment_1)
					if SodaCan.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						SodaCan.Condiment_1_Ani.play(_Data.Condiment_1)
					if SuperCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						SuperCup.Condiment_1_Ani.play(_Data.Condiment_1)
					if BeerCup.Condiment_1_Ani.has_animation(_Data.Condiment_1):
						BeerCup.Condiment_1_Ani.play(_Data.Condiment_1)
				elif _BAGID == int(_Data.FormulaNum) + _ExNum and _Data.Top != "" and not _ExList.has(_Data.Top):
					_ExList.append(_Data.Top)
					_ExNum += 1
					if _Node.get_node("Bag/AniNode/typeAni").has_animation(_Data.Top):
						_Node.get_node("Bag/AniNode/typeAni").play(_Data.Top)
					if EggRoll.TopAni.has_animation(_Data.Top):
						EggRoll.TopAni.play(_Data.Top)
					if DrinkCup.TopAni.has_animation(_Data.Top):
						DrinkCup.TopAni.play(_Data.Top)
					if SodaCan.TopAni.has_animation(_Data.Top):
						SodaCan.TopAni.play(_Data.Top)
					if SuperCup.TopAni.has_animation(_Data.Top):
						SuperCup.TopAni.play(_Data.Top)
					if BeerCup.TopAni.has_animation(_Data.Top):
						BeerCup.TopAni.play(_Data.Top)
				elif _BAGID == int(_Data.FormulaNum) + _ExNum and _Data.Hang != "" and not _ExList.has(_Data.Hang):
					_ExList.append(_Data.Hang)
					_ExNum += 1
					if _Node.get_node("Bag/AniNode/typeAni").has_animation(_Data.Hang):
						_Node.get_node("Bag/AniNode/typeAni").play(_Data.Hang)
					if EggRoll.HangAni.has_animation(_Data.Hang):
						EggRoll.HangAni.play(_Data.Hang)
					if DrinkCup.HangAni.has_animation(_Data.Hang):
						DrinkCup.HangAni.play(_Data.Hang)
					if SodaCan.HangAni.has_animation(_Data.Hang):
						SodaCan.HangAni.play(_Data.Hang)
					if SuperCup.HangAni.has_animation(_Data.Hang):
						SuperCup.HangAni.play(_Data.Hang)
					if BeerCup.HangAni.has_animation(_Data.Hang):
						BeerCup.HangAni.play(_Data.Hang)
				elif _BAGID == int(_Data.FormulaNum) + _ExNum and _Data.Extra_1 != "" and not _ExList.has(_Data.Extra_1):
					_ExList.append(_Data.Extra_1)
					_ExNum += 1
					if GameLogic.Config.FormulaConfig.has(_Data.Extra_1):
						var _AniName: String = GameLogic.Config.FormulaConfig[_Data.Extra_1].Ani
						_Node.get_node("Bag/AniNode/typeAni").play(_AniName)
					else:
						printerr(" 配方中未添加 Extra_1,无法读取Ani:", _Data.Extra_1)
					if EggRoll.Extra_1_Ani.has_animation(_Data.Extra_1):
						EggRoll.Extra_1_Ani.play(_Data.Extra_1)
					if DrinkCup.Extra_1_Ani.has_animation(_Data.Extra_1):
						DrinkCup.Extra_1_Ani.play(_Data.Extra_1)
					if SodaCan.Extra_1_Ani.has_animation(_Data.Extra_1):
						SodaCan.Extra_1_Ani.play(_Data.Extra_1)
					if SuperCup.Extra_1_Ani.has_animation(_Data.Extra_1):
						SuperCup.Extra_1_Ani.play(_Data.Extra_1)
					if BeerCup.Extra_1_Ani.has_animation(_Data.Extra_1):
						BeerCup.Extra_1_Ani.play(_Data.Extra_1)
				elif _BAGID == int(_Data.FormulaNum) + _ExNum and _Data.Extra_2 != "" and not _ExList.has(_Data.Extra_2):
					_ExList.append(_Data.Extra_2)
					_ExNum += 1
					var _ExtraList: Array
					_ExtraList.append(_Data.Extra_1)
					if not _ExtraList.has(_Data.Extra_2):
						var _AniName: String = GameLogic.Config.FormulaConfig[_Data.Extra_2].Ani
						_Node.get_node("Bag/AniNode/typeAni").play(_AniName)
						if EggRoll.Extra_2_Ani.has_animation(_Data.Extra_2):
							EggRoll.Extra_2_Ani.play(_Data.Extra_2)
						if DrinkCup.Extra_2_Ani.has_animation(_Data.Extra_2):
							DrinkCup.Extra_2_Ani.play(_Data.Extra_2)
						if SodaCan.Extra_2_Ani.has_animation(_Data.Extra_2):
							SodaCan.Extra_2_Ani.play(_Data.Extra_2)
						if SuperCup.Extra_2_Ani.has_animation(_Data.Extra_2):
							SuperCup.Extra_2_Ani.play(_Data.Extra_2)
						if BeerCup.Extra_2_Ani.has_animation(_Data.Extra_2):
							BeerCup.Extra_2_Ani.play(_Data.Extra_2)
					else:
						ItemNode.get_node(str(_BAGID)).hide()


				elif _BAGID == int(_Data.FormulaNum) + _ExNum and _Data.Extra_3 != "" and not _ExList.has(_Data.Extra_3):
					_ExList.append(_Data.Extra_3)
					var _ExtraList: Array
					_ExtraList.append(_Data.Extra_1)
					_ExtraList.append(_Data.Extra_2)
					if not _ExtraList.has(_Data.Extra_3):
						var _AniName: String = GameLogic.Config.FormulaConfig[_Data.Extra_3].Ani
						_Node.get_node("Bag/AniNode/typeAni").play(_AniName)
						if EggRoll.Extra_3_Ani.has_animation(_Data.Extra_3):
							EggRoll.Extra_3_Ani.play(_Data.Extra_3)
						if DrinkCup.Extra_3_Ani.has_animation(_Data.Extra_3):
							DrinkCup.Extra_3_Ani.play(_Data.Extra_3)
						if SodaCan.Extra_3_Ani.has_animation(_Data.Extra_3):
							SodaCan.Extra_3_Ani.play(_Data.Extra_3)
						if SuperCup.Extra_3_Ani.has_animation(_Data.Extra_3):
							SuperCup.Extra_3_Ani.play(_Data.Extra_3)
						if BeerCup.Extra_3_Ani.has_animation(_Data.Extra_3):
							BeerCup.Extra_3_Ani.play(_Data.Extra_3)
					else:
						ItemNode.get_node(str(_BAGID)).hide()

				else:


					ItemNode.get_node(str(_BAGID)).hide()

	_TimeChange_Logic()

	call_ButInfo(ButType)
func _TimeChange_Logic():
	if not _Data:
		return



func _MenuButton_init():


	$Size / Ani.play("init")
	$Type / TypeAni.play("init")

	for i in TemperatureNode.get_child_count():
		var _Sprite = TemperatureNode.get_child(i)
		_Sprite.hide()
	SugarNode.hide()
	FreeNode.hide()
	if has_node("Info/Choco"):
		get_node("Info/Choco").hide()
func call_button_switch(_switch):
	if _pressed == _switch:
		return
	_pressed = _switch

	match _switch:
		true:
			match get_parent().name:
				"MenuVBox":
					SelectAni.play("SelectOrBack")
				_:
					SelectAni.play("select")
		false:
			SelectAni.play("init")

func call_always():
	AlwaysShow = true
	SelectAni.play("always")

func call_NetChoose(_PLAYER: int):
	var NetChooseTSCN = load("res://TscnAndGd/Effects/NetChoose.tscn")
	var _ChooseTSCN = NetChooseTSCN.instance()
	var _randx = GameLogic.return_RANDOM() % 90 - 45
	var _randy = GameLogic.return_RANDOM() % 50 - 25
	var _POS: Vector2 = Vector2(_randx, _randy)
	var _NUM = $Net.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	_ChooseTSCN.position = _POS
	$Net.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)

	if SteamLogic.IsMultiplay:
		SteamLogic.call_puppet_node_sync(self, "call_NetChoose_puppet", [_PLAYER, _POS])
func call_NetChoose_puppet(_PLAYER, _POS):
	var NetChooseTSCN = load("res://TscnAndGd/Effects/NetChoose.tscn")
	var _ChooseTSCN = NetChooseTSCN.instance()
	_ChooseTSCN.position = _POS
	var _NUM = $Net.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	$Net.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)
