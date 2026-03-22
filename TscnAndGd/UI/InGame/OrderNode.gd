extends NinePatchRect

var _PLAYER
var cur_Player
var _pressed: bool
var cur_pressed: bool
var cur_used: bool
var CurSelect: String

var Order_SellCount: int

onready var OrderButNode = get_node("OrderScrollCon/OrderButCon")
onready var _SellCountLabel = get_node("CountSell/MoneyLabel")
onready var Sell_1_But = get_node("HBoxContainer/Sell_1")

onready var OrderAni = get_node("OrderAni")

onready var CurButGroup
onready var _ButGroup = preload("res://TscnAndGd/Buttons/OrderButton_buttongroup.tres")

onready var LButton = get_node("L/L")
onready var RButton = get_node("R/R")

onready var Audio_Close

signal CallClose

func _ready() -> void :
	call_deferred("_but_init")

func _but_init():
	Audio_Close = GameLogic.Audio.return_Effect("挂电话")

	LButton.cur_But = "L"
	LButton.bool_Hold = false
	LButton.bool_Small = true
	LButton.bool_Static = true
	LButton.call_init()
	RButton.cur_But = "R"
	RButton.bool_Hold = false
	RButton.bool_Small = true
	RButton.bool_Static = true
	RButton.call_init()

func _control_logic(_but, _value, _type):

	match _but:



		_:
			call_control(_but, _value, _type)

func call_control(_but, _value, _type):

	if _value == 0:
		cur_pressed = false
	if cur_used:

		match _but:
			"B", "START":
				if _value == 1 or _value == - 1 and not cur_pressed:
					cur_pressed = true
					GameLogic.GameUI._on_BuyButton_toggled(false)
					call_closed()
			"A":
				if _value == 1 or _value == - 1 and not cur_pressed:
					var _BUT = _ButGroup.get_pressed_button()
					if is_instance_valid(_BUT):
						if _BUT.CanBuy:
							cur_pressed = true
							_BUT._on_Button_pressed()
							_Apply_Logic()


			"U", "u":
				if cur_pressed:
					return
				if _value == 1 or _value == - 1 and not cur_pressed:
					var _Select = _ButGroup.get_pressed_button()

					if not _Select:
						return
					cur_pressed = true
					GameLogic.Audio.But_EasyClick.play(0)
					var _selectName = _Select.name

					if int(_selectName) > 0:
						var _PressedButID = str(int(_selectName) - 1)
						var _ButList = _ButGroup.get_buttons()
						for i in _ButList.size():
							var _But = _ButList[i]
							if _But.name == _PressedButID:
								_But.set_pressed(true)
								_But.number_show()
								_But.grab_focus()
			"D", "d":
				if cur_pressed:
					return
				if _value == 1 or _value == - 1 and not cur_pressed:
					var _Select = _ButGroup.get_pressed_button()
					if not _Select:
						return
					cur_pressed = true
					GameLogic.Audio.But_EasyClick.play(0)
					var _selectName = _Select.name
					var _ButList = _ButGroup.get_buttons()
					if int(_selectName) < _ButList.size():
						var _PressedButID = str(int(_selectName) + 1)
						for i in _ButList.size():
							var _But = _ButList[i]
							if _But.name == _PressedButID:
								_But.set_pressed(true)
								_But.number_show()
								_But.grab_focus()

			"L", "l":
				if _value == 1 or _value == - 1:
					if cur_pressed == false:
						cur_pressed = true
						get_node("L").call_pressed()
						_on_L_pressed()
						GameLogic.Audio.But_EasyClick.play(0)
			"R", "r":
				if _value == 1 or _value == - 1:
					if cur_pressed == false:

						cur_pressed = true
						get_node("R").call_pressed()
						_on_R_pressed()
						GameLogic.Audio.But_EasyClick.play(0)

	if _type == 0:
		cur_pressed = false
func call_by_player(_Player):
	if cur_used:
		return
	_PLAYER = _Player
	cur_Player = _Player.cur_Player
	cur_used = true
	Sell_1_But.pressed = true
	_on_OrderTypeButton_toggled(true)

	CurSelect = Sell_1_But.name
	_del_all_OrderButton()
	_add_OrderButton(CurSelect)
	LButton.ButPlayer = cur_Player
	RButton.ButPlayer = cur_Player
	get_node("CloseBut/B").ButPlayer = cur_Player
	match cur_Player:
		1, SteamLogic.STEAM_ID:
			if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.connect("P1_Control", self, "_control_logic")
		2:
			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.connect("P2_Control", self, "_control_logic")


func call_init():

	cur_used = true
	Sell_1_But.pressed = true

	var _Select = get_node("HBoxContainer/Sell_1").group.get_pressed_button()
	CurSelect = _Select.name
	_del_all_OrderButton()
	_add_OrderButton(CurSelect)

func _on_OrderTypeButton_toggled(button_pressed: bool) -> void :
	if button_pressed:
		var _Select = get_node("HBoxContainer/Sell_1").group.get_pressed_button()
		if CurSelect != _Select.name:
			CurSelect = _Select.name
			_del_all_OrderButton()
			_add_OrderButton(CurSelect)

func _del_all_OrderButton():

	sellCount_ShowLogic()
	var _child_array = OrderButNode.get_children()
	for i in _child_array.size():
		var _but = _child_array[i]
		var _butPar = _but.get_parent()
		_butPar.remove_child(_but)
		_but.queue_free()

func sellCount_ShowLogic():
	if Order_SellCount <= 0:
		Order_SellCount = 0
	_SellCountLabel.text = str(Order_SellCount)
	GameLogic.GameUI.Order_SellCount = Order_SellCount
	if SteamLogic.IsMultiplay:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_sellCountLogic", [GameLogic.GameUI.Order_SellCount])
	GameLogic.GameUI.sellCount_ShowLogic()
func call_puppet_sellCountLogic(_SELLCOUNT):
	Order_SellCount = _SELLCOUNT
	GameLogic.GameUI.Order_SellCount = _SELLCOUNT
	_SellCountLabel.text = str(Order_SellCount)
	GameLogic.GameUI.sellCount_ShowLogic()
func sellCount_Show(_TotalMoney: int):
	Order_SellCount = _TotalMoney
	_SellCountLabel.text = str(Order_SellCount)

func _add_OrderButton(_Type):
	var _Sell_Array: Array
	match _Type:
		"Sell_1":
			_Sell_Array = GameLogic.Buy.Sell_1

		"Sell_2":
			_Sell_Array = GameLogic.Buy.Sell_2

		"Sell_3":
			_Sell_Array = GameLogic.Buy.Sell_3
		"Sell_4":

			_Sell_Array = GameLogic.Buy.Sell_4

	for i in _Sell_Array.size():
		var _objName = _Sell_Array[i]
		if _objName:
			var _but = GameLogic.TSCNLoad.BuyButton_TSCN.instance()
			_but.name = str(OrderButNode.get_child_count())
			OrderButNode.add_child(_but)

			if i == 0:
				CurButGroup = _ButGroup
				_but.set_pressed(true)
				_but.grab_focus()
			_but.set_button_group(CurButGroup)

			_but.cur_type = _objName

			if _objName in ["ICE", "GAS", "BEER"]:
				_but.call_ICE(self)
			elif GameLogic.Config.ItemConfig.has(_objName):

				_but.call_init(self)
			elif GameLogic.Config.DeviceConfig.has(_objName):

				_but.call_dev_init(self)
			_but.ApplyBut.connect("pressed", self, "_Apply_Logic")
	_set_OrderBut_focus()

func _set_OrderBut_focus():




	var _but_Array = OrderButNode.get_children()
	var _FIRSTBUT
	var _LASTBUT
	for i in _but_Array.size():
		var _but = _but_Array[i]
		var _butpath = _but.get_path()
		if _but_Array.size() > 1:
			if i == 0:
				_FIRSTBUT = _but
				var _nextbut = _but_Array[i + 1]
				var _nextbutpath = _nextbut.get_path()
				_but.set_focus_neighbour(MARGIN_BOTTOM, _nextbutpath)

			elif i != _but_Array.size() - 1:
				var _upbut = _but_Array[i - 1]
				var _upbutpath = _upbut.get_path()
				_but.set_focus_neighbour(MARGIN_TOP, _upbutpath)
				var _nextbut = _but_Array[i + 1]
				var _nextbutpath = _nextbut.get_path()
				_but.set_focus_neighbour(MARGIN_BOTTOM, _nextbutpath)
			elif i == _but_Array.size() - 1:
				_LASTBUT = _but
				var _FIRSTBUTPATH = _FIRSTBUT.get_path()
				_but.set_focus_neighbour(MARGIN_BOTTOM, _FIRSTBUTPATH)
				_FIRSTBUT.set_focus_neighbour(MARGIN_TOP, _butpath)

		else:
			_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
		_but.set_focus_neighbour(MARGIN_LEFT, _butpath)
		_but.set_focus_neighbour(MARGIN_RIGHT, _butpath)

func call_closed():

	if is_instance_valid(_PLAYER):
		_PLAYER.call_control(0)
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if is_instance_valid(GameLogic.player_1P):
			GameLogic.player_1P.call_control(0)
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
		if is_instance_valid(GameLogic.player_2P):
			GameLogic.player_2P.call_control(0)

	Audio_Close.play(0)
	cur_used = false
	emit_signal("CallClose")

func call_master(_MONEY, _TYPE, _BASE):
	GameLogic.level_ProfitTotal += _MONEY
	GameLogic.Cost_Items += _MONEY
	Order_SellCount += _MONEY
	sellCount_ShowLogic()
	var _Order: Array
	var _objinfo: Dictionary
	_objinfo[_TYPE] = _BASE
	_Order.append(_objinfo)
	GameLogic.Buy.call_new_buy(_Order, 0)
	GameLogic.cur_Buy = GameLogic.Buy.buy_Array
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(GameLogic.Buy, "buy_Array", GameLogic.Buy.buy_Array)
func _Apply_Logic() -> void :

	var _BUT = _ButGroup.get_pressed_button()
	if _BUT.CanBuy:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			var _MONEY = _BUT.buy_money
			var _TYPE = _BUT.cur_type
			var _BASE = _BUT.buy_base
			SteamLogic.call_master_node_sync(self, "call_master", [_MONEY, _TYPE, _BASE])
			_BUT.CanBuy = false

			_BUT.number_show()
			var _Audio = GameLogic.Audio.return_Effect("气泡")
			_Audio.play(0)
			return
		var _Money = _BUT.buy_money

		GameLogic.level_ProfitTotal += _Money
		GameLogic.Cost_Items += _Money
		Order_SellCount += _Money
		sellCount_ShowLogic()
		var _Order: Array
		var _objinfo: Dictionary
		_objinfo[_BUT.cur_type] = _BUT.buy_base
		_Order.append(_objinfo)

		GameLogic.Buy.call_new_buy(_Order, 0)
		GameLogic.cur_Buy = GameLogic.Buy.buy_Array
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_set_sync(GameLogic.Buy, "buy_Array", GameLogic.Buy.buy_Array)
		_BUT.CanBuy = false

		_BUT.number_show()
		var _Audio = GameLogic.Audio.return_Effect("气泡")
		_Audio.play(0)
	else:
		print("BuyLogic 不能购买:", _BUT.CanBuy)

func _call_buy_Logic_Old():
	var _Order: Array
	var _but_array = OrderButNode.get_children()
	var _objinfo: Dictionary
	for i in _but_array.size():
		var _but = _but_array[i]
		if _but.buy_num > 0:
			_objinfo[_but.cur_type] = _but.buy_num

			_but.buy_num = 0
			_but.buy_moneyCount = 0
			_but.number_show()
	_Order.append(_objinfo)

	GameLogic.Buy.call_new_buy(_Order, 0)
	GameLogic.cur_Buy = GameLogic.Buy.buy_Array

	for i in _but_array.size():
		var _but = _but_array[i]
		_but.call_sent_init()

func _on_L_pressed() -> void :
	var _CurSelect = Sell_1_But.group.get_pressed_button()
	match _CurSelect.name:
		"Sell_1":
			pass
		"Sell_2":
			_CurSelect.get_parent().get_node("Sell_1").set_pressed(true)
		"Sell_3":
			_CurSelect.get_parent().get_node("Sell_2").set_pressed(true)
		"Sell_4":
			_CurSelect.get_parent().get_node("Sell_3").set_pressed(true)
func _on_R_pressed() -> void :
	var _CurSelect = Sell_1_But.group.get_pressed_button()
	match _CurSelect.name:
		"Sell_1":
			_CurSelect.get_parent().get_node("Sell_2").set_pressed(true)
		"Sell_2":
			_CurSelect.get_parent().get_node("Sell_3").set_pressed(true)
		"Sell_3":
			_CurSelect.get_parent().get_node("Sell_4").set_pressed(true)
		"Sell_4":
			pass

func call_hide():
	cur_used = false

func _on_CloseBut_pressed():
	GameLogic.GameUI._on_BuyButton_toggled(false)

	call_closed()
