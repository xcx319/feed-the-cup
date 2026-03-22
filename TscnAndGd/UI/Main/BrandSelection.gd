extends Control

var MainFormula
var JoinCost
var DecorateCost
var BrandPopularity
var Trend
var PurchaseMult
var Stores
var RankList = [20, 20, 20, 20, 20]

var Rand_list: Array

onready var Brand_0 = get_node("SceneHBox/0")
onready var Brand_1
onready var Brand_2
onready var MoneyLabel = $money / MoneyLabel
onready var CostLabel = get_node("money/TotalCost")
onready var FinalMoneyLabel = get_node("money/FinalMoney")

func _ready() -> void :
	self.hide()
	_BrandBut_init()

func call_money_changed() -> void :

	var _cur_But_list = Brand_0.group.get_buttons()
	var _cur_But
	for i in _cur_But_list.size():
		var _But = _cur_But_list[i]
		if _But.has_focus():
			_cur_But = _But
			break
	JoinCost = int(_cur_But.get_node("BaseInfo/JoinCost/Label").text)
	DecorateCost = int(_cur_But.get_node("BaseInfo/DecorateCost/Label").text)
	BrandPopularity = int(_cur_But.get_node("BarInfo/BrandPopularity/Progress").value)
	Trend = int(_cur_But.get_node("BarInfo/Trend/Progress").value)
	PurchaseMult = int(_cur_But.get_node("BarInfo/PurchaseMult/Progress").value)

	Stores = int(_cur_But.get_node("BaseInfo/Stores/Label").text)

	MoneyLabel.text = str(GameLogic.cur_money)
	var _Dec_Cost = DecorateCost * GameLogic.cur_size
	var _Cost = JoinCost + _Dec_Cost
	CostLabel.text = str(_Cost)
	var _FinalMoney = int(GameLogic.cur_money) - int(_Cost)
	FinalMoneyLabel.text = str(_FinalMoney)

func _BrandBut_init():
	Brand_1 = Brand_0.duplicate()
	get_node("SceneHBox").add_child(Brand_1)
	Brand_1.name = "1"
	Brand_2 = Brand_0.duplicate()
	get_node("SceneHBox").add_child(Brand_2)
	Brand_2.name = "2"
func call_MainFormula_Set():
	var TSCN_Keys = GameLogic.Config.PlayerConfig.keys()
	MainFormula = GameLogic.Config.PlayerConfig[TSCN_Keys[GameLogic.player_1P]].MainFormula

	var Brand_But
	for i in 3:
		Rand_list.clear()
		match i:
			0:
				Brand_But = Brand_0
			1:
				Brand_But = Brand_1
			2:
				Brand_But = Brand_2
		var _Rank = _return_Rank()
		var BrandPopular_Min = 5 * _Rank
		var BrandPopular_Max = 20 * _Rank
		var _BrandPop_Rand = GameLogic.return_randi() % (BrandPopular_Max - BrandPopular_Min)
		if _BrandPop_Rand > 0:
			Rand_list.append(float(float(_BrandPop_Rand) / float(BrandPopular_Max - BrandPopular_Min - 1)))

		BrandPopularity = BrandPopular_Min + _BrandPop_Rand
		Brand_But.get_node("BarInfo/BrandPopularity/Progress").value = BrandPopularity
		Trend = GameLogic.return_randi() % 3
		Brand_But.get_node("BarInfo/Trend/Progress").value = Trend * 50
		Rand_list.append(float(Trend) / float(2))
		var _join = GameLogic.return_randi() % 5 + 1
		JoinCost = BrandPopularity * (_Rank * (100 * _join))
		Brand_But.get_node("BaseInfo/JoinCost/Label").text = str(JoinCost)
		Rand_list.append(float(_join) / float(5))
		var _Dec = int(rand_range(100, _Rank * 1000) / 10) * 10
		Rand_list.append(float(_Dec) / float(_Rank * 1000 - 1))
		DecorateCost = _Dec
		Brand_But.get_node("BaseInfo/DecorateCost/Label").text = str(DecorateCost)



		var _Pur_Rand = rand_range(_Rank * 0.5, _Rank * 1.5)

		var _Pur = float(int(_Pur_Rand * 100)) / 100

		Rand_list.append(1 - (float(_Pur) / (float(_Rank) * 1.5)))
		PurchaseMult = _Pur
		Brand_But.get_node("BarInfo/PurchaseMult/Progress").min_value = (1 * 0.5) * 100
		Brand_But.get_node("BarInfo/PurchaseMult/Progress").max_value = (5 * 1.5) * 100
		Brand_But.get_node("BarInfo/PurchaseMult/Progress").value = _Pur * 100

		var _Store_Rand = (JoinCost / 1000 + DecorateCost / 200) * BrandPopularity
		Stores = int(rand_range(_Store_Rand / 10, _Store_Rand))
		Rand_list.append(float(Stores) / float(_Store_Rand - 1))
		Brand_But.get_node("BaseInfo/Stores/Label").text = str(Stores)


		var _Point: float = 0
		var _RandSize = Rand_list.size()
		for y in _RandSize:
			_Point += Rand_list[y]
		var Grade: float = 0
		if _Point != 0:
			Grade = _Point / float(_RandSize)

		if Grade <= 0.4:
			Brand_But.get_node("TypeAni").play("1")
		elif Grade <= 0.67:
			Brand_But.get_node("TypeAni").play("2")
		else:
			Brand_But.get_node("TypeAni").play("3")

		_Brand_rand(Brand_But)

func _Brand_rand(Brand_But):

	var Brand_keys = GameLogic.Config.BrandConfig.keys()
	var _BrandList: Array
	for i in Brand_keys.size():
		if GameLogic.Config.BrandConfig[Brand_keys[i]].Rank == str(1):
			_BrandList.append(Brand_keys[i])

	_BrandList.shuffle()
	var _Brand = _BrandList.front()
	Brand_But.get_node("BaseInfo/FormulaType/Label").text = GameLogic.Config.BrandConfig[_Brand].Name
	Brand_But.editor_description = _Brand

func _return_Rank():
	var _rand_Rank = GameLogic.return_randi() % 100 + 1
	for i in RankList.size():
		if _rand_Rank <= RankList[i]:
			return i + 1
		else:
			_rand_Rank -= RankList[i]

func _on_brand_pressed() -> void :

	var _pressed = Brand_0.group.get_pressed_button()
	var _money = int(GameLogic.cur_money) - int(JoinCost + DecorateCost * GameLogic.cur_size)
	if _money >= 0:
		GameLogic.cur_money = _money
		GameLogic.cur_Brand = _pressed.editor_description
		GameLogic.cur_BrandPopularity = _pressed.get_node("BarInfo/BrandPopularity/Progress").value
		GameLogic.cur_Trend = _pressed.get_node("BarInfo/Trend/Progress").value
		GameLogic.cur_PurchaseMult = _pressed.get_node("BarInfo/PurchaseMult/Progress").value / 100

		GameLogic.Order.call_brand_init()
