extends Button

export (int) var buyMax = 1
var CanBuy: bool
var cur_type: String setget _But_Init
var buy_base: int = 1
var buy_num: int
var order_num: int
var buy_moneyCount: int
var cur_max: int
var buy_money: int setget buy_set
var cur_num: int setget num_set
var cur_info: String setget info_set

var DevInfo: Dictionary
var DevInfoKeys: Array
var DevTotalMoney: int
onready var NumAni = get_node("Node/BuyAni")
onready var CurNumAni = get_node("Node/NumAni")
onready var SentAni = get_node("Node/SentAni")
onready var DevAni = get_node("Node/DevAni")

onready var NumShow = get_node("NumNode/NumLabel")
onready var SellLabel = get_node("SellNode/SellLabel")
onready var InfoLabel = get_node("InfoNode/Label")
onready var NumLabel = get_node("CurNode/curNum")
onready var NumMaxLabel = NumLabel.get_node("MaxNum")
onready var SentLabel = get_node("SentNode/SentNum")
onready var BuyMaxLabel = get_node("NumNode/MaxLabel")
onready var SentMaxLabel = get_node("SentNode/MaxLabel")
onready var ButAni = get_node("Node/ButAni")
onready var GameUI = GameLogic.GameUI
onready var OrderNode
onready var ApplyBut = get_node("Button")

onready var Left = get_node("NumNode/L")
onready var Right = get_node("NumNode/R")

onready var PlusNode = get_node("SellNode/Plus")
onready var MinusNode = get_node("SellNode/Minus")

func _ready():
	var _CON = GameLogic.connect("Delivery", self, "number_show")
func _But_Init(_Type: String):
	cur_type = _Type
	if get_node("IconNode/IconAni").has_animation(cur_type):
		get_node("IconNode/IconAni").play(cur_type)
	else:
		pass

	if cur_type == "ICE":
		buy_set(25)
		info_set("信息-冰块")
		call_BuyNum_set(1)
		number_show()
		return
	elif cur_type == "GAS":
		buy_set(25)
		info_set("信息-补气")
		call_BuyNum_set(1)
		number_show()
		return
	elif cur_type == "BEER":
		buy_set(5)
		info_set("信息-取桶")
		call_BuyNum_set(1)
		number_show()
		return
	if GameLogic.Config.ItemConfig.has(cur_type):
		var _SingleMoney: int = int(GameLogic.Config.ItemConfig[cur_type].Sell)
		var _BuyNum: int = int(GameLogic.Config.ItemConfig[cur_type].BuyNum)
		buy_base = _BuyNum
		var _FinalMoney = _SingleMoney * _BuyNum
		buy_set(_FinalMoney)

		info_set(GameLogic.Config.ItemConfig[cur_type]["ShowInfoID"])



		call_BuyNum_set(1)


		number_show()
	else:
		pass
func call_sent_init():
	order_num = 0
	BuyMaxLabel.hide()


	for i in GameLogic.Buy.buy_Array.size():
		var _buyInfo = GameLogic.Buy.buy_Array[i][1]
		if _buyInfo.has(cur_type):
			order_num += int(_buyInfo[cur_type])
	if order_num > 0:
		CanBuy = false

	else:
		CanBuy = true

	number_show()
func call_ICE(_Obj):
	buyMax = GameLogic.cur_OrderMax
	OrderNode = _Obj
	NumShow.text = "-"
	cur_max = buy_base * 2
	call_sent_init()
	CurNumAni.play("normal")

	if SentLabel.text == "无":
		SentAni.play("none")
	else:
		SentAni.play("sent")
	_but_check()
	$CurNode / curNum.text = "-"
func call_init(_Obj):

	buyMax = GameLogic.cur_OrderMax
	OrderNode = _Obj
	NumShow.text = "+" + str(buy_num * buy_base)
	cur_max = buy_base * 2
	call_sent_init()
	if cur_num > 0:
		CurNumAni.play("normal")
	else:
		CurNumAni.play("low")
	if SentLabel.text == "无":
		SentAni.play("none")
	else:
		SentAni.play("sent")

	CanBuy_Logic()


	_but_check()
func call_dev_init(_Obj):
	OrderNode = _Obj
	DevAni.play("show")

	var _INFO = GameLogic.Config.DeviceConfig[cur_type]

	if not GameLogic.cur_Item_List.has(cur_type):
		num_set(0)
	else:
		num_set(int(GameLogic.cur_Item_List[cur_type]))

	var _NextMoney = int(_INFO.Sell)


	buy_set(int(_NextMoney))
	info_set(_INFO["ShowInfoID"])

	if GameLogic.cur_Dev_Info.has(cur_type):
		DevInfo = GameLogic.cur_Dev_Info[cur_type]
	DevInfoKeys = DevInfo.keys()

	for i in DevInfoKeys.size():
		var _n = DevInfoKeys.size() - i - 1
		var _info = DevInfo[DevInfoKeys[_n]]

		if GameLogic.cur_Menu.size() > int(_info["Menu"]):
			if GameLogic.cur_Day > int(_info["Day"]):
				if GameLogic.cur_StoreStar >= int(_info["Popular"]):
					cur_max = int(DevInfoKeys[_n])

					buyMax = cur_max - cur_num
					call_BuyNum_set(1)
					call_sent_init()




					number_show()

					break
		if _info.Start:
			pass

	CanBuy_Logic()
	_but_check()

func call_BuyNum_set(_value):
	buy_base = int(_value)
	Left.text = "-" + str(buy_base)
	Right.text = "+" + str(buy_base)

func _Num_Show_Switch(_switch):
	match _switch:
		true:
			NumAni.play("show")
		false:
			NumAni.play("hide")

func _on_self_toggled(button_pressed: bool) -> void :
	_Num_Show_Switch(button_pressed)

	CanBuy_Logic()

	_but_check()
func num_set(_num):
	cur_num = _num
	if cur_type in ["ICE", "GAS", "BEER"]:
		$CurNode / curNum / AnimationPlayer.play("init")
		NumLabel.text = str("-")
	else:

		NumLabel.text = str(_num)
		if _num == 0:
			$CurNode / curNum / AnimationPlayer.play("red")
		else:
			$CurNode / curNum / AnimationPlayer.play("init")
func buy_set(_value):

	buy_money = int(_value)
	var _Mult: float = 1

	if GameLogic.cur_Rewards.has("物料供应"):
		if not DevInfoKeys.size():
			_Mult -= 0.25
	if GameLogic.cur_Rewards.has("物料供应+"):
		if not DevInfoKeys.size():
			_Mult -= 0.5
	if GameLogic.cur_Challenge.has("物价上涨"):
		_Mult += 0.5
	if GameLogic.cur_Challenge.has("物价上涨+"):
		_Mult += 1
	if GameLogic.cur_Event == "进货折扣":
		_Mult -= 0.25
	if GameLogic.cur_Event == "进货折扣+":
		_Mult -= 0.5
	if GameLogic.cur_Event == "进货折扣++":
		_Mult -= 1

	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Achievement.cur_EquipList.has("进货降价"):
			_Mult -= 0.2
		if GameLogic.Save.gameData.HomeDevList.has("菜篮"):
			_Mult -= 0.05
		if GameLogic.Save.gameData.HomeDevList.has("小菜园"):
			_Mult -= 0.05
	if _Mult < 0:
		_Mult = 0

	buy_money = int(float(buy_money) * _Mult)
	if buy_money < 1:
		buy_money = 1

	SellLabel.text = str(buy_money)
	if _Mult > 1:
		PlusNode.hide()
		MinusNode.show()
	elif _Mult < 1:
		PlusNode.show()
		MinusNode.hide()
	else:
		PlusNode.hide()
		MinusNode.hide()
func info_set(_str: String):
	var _INFO_Base = GameLogic.CardTrans.get_message(_str)

	var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)
	var _Info = "[fill][center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center]"

	InfoLabel.bbcode_text = _Info

func CanBuy_Logic():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		CanBuy = true
		for _Array in GameLogic.Buy.buy_Array:
			var _Dic = _Array[1]
			var _Keys = _Dic.keys()
			if _Keys[0] == cur_type:
				CanBuy = false
				break
		return
	CanBuy = true
	if not GameLogic.Buy.buy_Array:
		CanBuy = true
	else:
		for _Array in GameLogic.Buy.buy_Array:
			var _Dic = _Array[1]
			var _Keys = _Dic.keys()
			if _Keys[0] == cur_type:
				CanBuy = false
				break

func number_show():

	var _name
	match cur_type:
		"GAS", "BEER":

			pass
		"DrinkCup_S":
			_name = "DrinkCup_Group_S"
		"DrinkCup_M":
			_name = "DrinkCup_Group_M"
		"DrinkCup_L":
			_name = "DrinkCup_Group_L"
		_:
			_name = cur_type
	if GameLogic.cur_Item_List.has(_name):
		var _num = GameLogic.cur_Item_List[_name]

		num_set(int(_num))

	_but_check()

func _but_check():

	match CanBuy:
		true:
			ButAni.play("Base")
		false:
			ButAni.play("Cancel")
func buy_num_set():
	if ((buy_num * buy_base) + order_num) > (buyMax * buy_base):
		buy_num -= 1
	elif buy_num < 0:
		buy_num = 0
	if SentMaxLabel.visible:
		buy_num = 0
	if (order_num * buy_base) >= (buyMax * buy_base):
		buy_num = 0
	number_show()

	buy_moneyCount = (buy_num * buy_base) * buy_money

	if GameLogic.cur_Dev_Info.has(cur_type):
		OrderNode.sellCount_Show(DevTotalMoney)
	else:
		OrderNode.sellCount_ShowLogic()

	if buy_num > 0 and ((buy_num * buy_base) + order_num) >= (buyMax * buy_base):
		BuyMaxLabel.show()
	elif buy_num <= 0:
		BuyMaxLabel.hide()

func _on_Plus_pressed() -> void :
	var _curNum: int
	buy_num += 1
	_curNum = buy_num
	buy_num_set()
	if GameLogic.cur_Dev_Info.has(cur_type):
		var _NextMoney = GameLogic.cur_Dev_Info[cur_type][(cur_num + buy_num + 1)]["Money"]
		buy_set(int(_NextMoney))
		if _curNum == buy_num:
			DevTotalMoney += GameLogic.cur_Dev_Info[cur_type][(cur_num + buy_num)]["Money"]
			OrderNode.sellCount_Show(DevTotalMoney)
	if cur_max <= (cur_num + order_num):
		BuyMaxLabel.show()
func _on_Reduce_pressed() -> void :
	var _curNum: int
	buy_num -= 1
	_curNum = buy_num
	buy_num_set()
	if GameLogic.cur_Dev_Info.has(cur_type):
		var _NextMoney = GameLogic.cur_Dev_Info[cur_type][(cur_num + buy_num + 1)]["Money"]
		buy_set(int(_NextMoney))
		if _curNum == buy_num:
			DevTotalMoney -= GameLogic.cur_Dev_Info[cur_type][(cur_num + buy_num + 1)]["Money"]
			OrderNode.sellCount_Show(DevTotalMoney)
	if cur_max <= (cur_num + order_num):
		BuyMaxLabel.show()

func _on_focus_entered() -> void :

	_but_check()

func _on_Button_pressed():
	get_node("Button/Ani").play("press")
	self.set_pressed(true)

func _on_self_pressed():

	CanBuy = false
