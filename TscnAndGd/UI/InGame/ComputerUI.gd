extends Control

var cur_pressed: bool
var _pressed: bool
var cur_UI = CUI.NONE
var Ani_bool: bool
enum CUI{
	NONE
	MAIN
	BANK
	FINALCHECK
	LEVEL
	BUYDEV
	ORDER
	MENU
	FORMULA
	FORMULASELECT
}
var BankList: Array
var Loan_Money: int
var Loan_ReBaseMoney: int
var Loan_Usury: float
var Loan_ReplayEarly: bool
var TYPE: int

var LoadLevel_bool: bool
var _Level_Path = "res://TscnAndGd/Main/Level/"
var loader
var item_count: int
var now_count: int
onready var view = get_node("LevelNode/ViewportContainer/Viewport")
var LevelCamera
var LevelNode

onready var Ani = get_node("AniNode/Ani")
onready var UIAni = get_node("AniNode/UIAni")

onready var BankBut = get_node("MainNode/MainUI/BankBut")
onready var LoanBut = get_node("BankNode/Loan/Pressed/LoanBut")
onready var RepayBut = get_node("BankNode/Repayment/Pressed/RepaymentBut")
onready var FinalCheckBut = get_node("FinalCheck/BG/Apply")

onready var StoreBut = get_node("MainNode/MainUI/StoreBut")
onready var StoreButAni = get_node("MainNode/MainUI/StoreBut/Ani")
onready var MenuBut = get_node("MainNode/MainUI/MenuBut")
onready var MenuButAni = get_node("MainNode/MainUI/MenuBut/Ani")
onready var Store_Name = get_node("MainNode/MainUI/StoreBut/ShopNode/TitleLabel")
onready var Store_Value = get_node("MainNode/MainUI/StoreBut/ShopNode/Value/MoneyLabel")

onready var Store_OrderNode = get_node("LevelNode/OrderNode")
onready var Store_BuyNode = get_node("LevelNode/DevBuy")

onready var Store_Type = get_node("LevelNode/Type")
onready var Store_TypeDevBut = Store_Type.get_node("VBoxContainer/DevBuyBut")

onready var AddNewLabel = get_node("MenuNode/NewMenu/Button/AddNewLabel")
onready var ReplaceLabel = get_node("MenuNode/NewMenu/Button/ReplaceLabel")
onready var MyComputerLabel = get_node("MainNode/TitleName/Label")

onready var Bank_DeltNode = get_node("MainNode/MainUI/BankBut/DebtNode")
onready var Bank_InfoNode = get_node("MainNode/MainUI/BankBut/InfoNode")
onready var Bank_RepayTotal = get_node("MainNode/MainUI/BankBut/DebtNode/Debt/MoneyLabel")
onready var BankUI_RepayTotal = get_node("BankNode/Repayment/Pressed/VBox/Debt/MoneyLabel")
onready var Bank_RepayDay = get_node("MainNode/MainUI/BankBut/DebtNode/PayBack/DayLabel")
onready var BankUI_RepayDay = get_node("BankNode/Repayment/Pressed/VBox/Repayment/DayLabel")

onready var CheckUI_Money = get_node("FinalCheck/BG/money/MoneyLabel")
onready var CheckUI_Cost = get_node("FinalCheck/BG/money/TotalCost")
onready var CheckUI_Final = get_node("FinalCheck/BG/money/FinalMoney")

onready var Bank_TypeAni = get_node("BankNode/AniNode/TypeAni")
onready var Loan_RepayDay = get_node("BankNode/Loan/Pressed/VBox/Repayment/DayLabel")

onready var MoneyLabel = get_node("MainNode/TitleName/money/MoneyLabel")
onready var MoneyPlusLabel = get_node("MainNode/TitleName/money/MoneyLabel/MoneyPlus")
onready var MoneyPlusAni = get_node("MainNode/TitleName/money/MoneyLabel/MoneyPlusAni")

onready var BankAni = get_node("BankNode/AniNode/Ani")
onready var FinalCheckAni = get_node("BankNode/AniNode/FinalCheckAni")

onready var MenuNode = get_node("MenuNode")
onready var CurMenuNode
onready var NewMenuNode = MenuNode.get_node("NewMenu")
onready var NewMenuApplyBut = NewMenuNode.get_node("Button")
onready var MenuAni = MenuNode.get_node("Ani")

onready var FormulaBut = MenuNode.get_node("BG/Button")

func _ready() -> void :
	call_deferred("call_init")
	var _check = GameLogic.connect("MoneyChange", self, "_money_logic")
	var _check_Hold = FormulaBut.get_node("Y").connect("HoldFinish", self, "_on_Formula_pressed")

func _set_OrderBut_focus():




	var _but_Array = NewMenuNode.get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		var _butpath = _but.get_path()
		if _but_Array.size() > 1:
			if i == 0:
				_but.set_focus_neighbour(MARGIN_TOP, _butpath)
			else:
				var _upbut = _but_Array[i - 1]
				var _upbutpath = _upbut.get_path()
				_but.set_focus_neighbour(MARGIN_TOP, _upbutpath)
			if i == _but_Array.size() - 1:
				_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
			else:
				var _nextbut = _but_Array[i + 1]
				var _nextbutpath = _nextbut.get_path()
				_but.set_focus_neighbour(MARGIN_BOTTOM, _nextbutpath)
		else:
			_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
		_but.set_focus_neighbour(MARGIN_LEFT, _butpath)
		_but.set_focus_neighbour(MARGIN_RIGHT, _butpath)

func _money_logic(_Num):
	var _Total = GameLogic.cur_money
	MoneyLabel.text = str(_Total)

	MoneyPlusLabel.text = str(_Num)
	if MoneyPlusAni.is_playing():
		MoneyPlusAni.stop(true)
	if _Num > 0:
		MoneyPlusAni.play("plus")
	elif _Num < 0:
		MoneyPlusAni.play("reduce")


func call_loan_logic(_loanMoney: int, _loanBaseMoney: int, _usury: float, _repayEarly: bool):
	Loan_Money = _loanMoney
	Loan_ReBaseMoney = _loanBaseMoney
	Loan_Usury = _usury
	Loan_ReplayEarly = _repayEarly
func menu_init():
	var _label = get_node("MainNode/MainUI/MenuBut/ShopNode/OrderMax/Label")

	_label.text = str(GameLogic.cur_Menu.size()) + "/" + str(GameLogic.cur_MenuNum)
	if GameLogic.cur_Menu.size() > GameLogic.cur_MenuNum:
		MenuAni.play("init")
func call_init():
	_set_OrderBut_focus()

	menu_init()
	MoneyLabel.text = str(GameLogic.cur_money)




func call_type_init():

	if GameLogic.cur_Bank:
		Bank_TypeAni.play(GameLogic.cur_Bank)
		return
	BankList.clear()

	if GameLogic.cur_money < 150000:
		BankList.append("开店宝")
	else:
		BankList.append("紧急资金")
	Bank_TypeAni.play(BankList.front())

func call_show():
	call_init()
	Ani.play("show")
	BankBut.grab_focus()
	GameLogic.Con.connect("P1_Control", self, "_control_logic")
	GameLogic.Con.connect("P2_Control", self, "_control_logic")
	cur_UI = CUI.MAIN

func call_add_formula():

	if GameLogic.cur_Menu.size() < GameLogic.cur_MenuNum:
		var _pressedBut = NewMenuNode.get_node("0").group.get_pressed_button()
		if _pressedBut:
			var _ForName = _pressedBut.ForName

			GameLogic.cur_Menu.append(_ForName)

			var _Data = _pressedBut._Data
			if _Data.Type == "CAN":
				GameLogic.cur_Extra.append(_ForName)

			CurMenuNode.call_init()
			call_New_Formula_Set()
			MenuAni.play("hide")
			cur_UI = CUI.MENU
	menu_init()
	GameLogic.call_save()

	pass
func _control_logic(_but, _value, _type):

	Store_OrderNode.call_control(_but, _value)
	Store_BuyNode.call_control(_but, _value)
	match _but:
		"B":
			if _value == 1:
				_on_BackBut_pressed()
		"A":
			if cur_UI == CUI.FORMULA:
				if _value == 1:
					if GameLogic.cur_Menu.size() < int(GameLogic.cur_MenuNum):
						call_add_formula()

				pass
			elif cur_UI != CUI.ORDER:
				var _input = InputEventAction.new()
				_input.action = "ui_accept"
				if _value == 1:
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
				elif _value == 0:
					_input.pressed = false
					cur_pressed = false
					Input.parse_input_event(_input)
		"U":
			if _value < 0.5 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_up"
			_input.pressed = true
			Input.parse_input_event(_input)
		"D":
			if cur_UI == CUI.FORMULA or cur_UI == CUI.MENU:
				if _value != 1:
					return
				var _pressedBut = NewMenuNode.get_node("0").group.get_pressed_button()
				var _pressedMenuBut = CurMenuNode.But_0.group.get_pressed_button()

				if _pressedBut:
					var _Name = _pressedBut.name
					var _UpName = str(int(_Name) + 1)
					if NewMenuNode.has_node(_UpName):
						var _UpBut = NewMenuNode.get_node(_UpName)
						_UpBut.grab_focus()
				elif _pressedMenuBut:
					var _Name = _pressedMenuBut.name
					var _UpName = str(int(_Name) + 1)
					if CurMenuNode.has_node(_UpName):
						var _UpBut = CurMenuNode.get_node(_UpName)
						_UpBut.grab_focus()
				else:
					if _value < 0.5 or cur_pressed:
						return
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					Input.parse_input_event(_input)
			else:
				if _value < 0.5 or cur_pressed:
					return
				var _input = InputEventAction.new()
				_input.action = "ui_down"
				_input.pressed = true
				Input.parse_input_event(_input)

		"L":
			if _value < 0.5 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_left"
			_input.pressed = true
			Input.parse_input_event(_input)
		"R":
			if _value < 0.5 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_right"
			_input.pressed = true
			Input.parse_input_event(_input)
		"u":
			if _value > - 1 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_up"
			_input.pressed = true
			Input.parse_input_event(_input)
		"d":
			if _value < 1 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_down"
			_input.pressed = true
			Input.parse_input_event(_input)
		"l":
			if _value > - 1 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_left"
			_input.pressed = true
			Input.parse_input_event(_input)
		"r":
			if _value < 1 or cur_pressed:
				return
			var _input = InputEventAction.new()
			_input.action = "ui_right"
			_input.pressed = true
			Input.parse_input_event(_input)
		"Ru":
			if cur_UI == CUI.ORDER or cur_UI == CUI.BUYDEV or cur_UI == CUI.LEVEL:
				if abs(_value) == 1:
					_on_UP_pressed(abs(_value))
		"Rd":
			if cur_UI == CUI.ORDER or cur_UI == CUI.BUYDEV or cur_UI == CUI.LEVEL:
				if abs(_value) == 1:
					_on_DOWN_pressed(abs(_value))
		"Rl":
			if cur_UI == CUI.ORDER or cur_UI == CUI.BUYDEV or cur_UI == CUI.LEVEL:
				if abs(_value) == 1:
					_on_LEFT_pressed(abs(_value))
		"Rr":
			if cur_UI == CUI.ORDER or cur_UI == CUI.BUYDEV or cur_UI == CUI.LEVEL:
				if abs(_value) == 1:
					_on_RIGHT_pressed(abs(_value))
		"X":
			if cur_UI == CUI.ORDER or cur_UI == CUI.BUYDEV or cur_UI == CUI.LEVEL:
				if abs(_value) == 1:
					_on_IN_pressed(abs(_value))
		"Y":
			if cur_UI == CUI.ORDER or cur_UI == CUI.BUYDEV or cur_UI == CUI.LEVEL:
				if abs(_value) == 1:
					_on_OUT_pressed(abs(_value))
			if cur_UI == CUI.MENU:
				if _value == 1 or _value == - 1:
					if not _pressed:
						_pressed = true
						FormulaBut.get_node("Y").call_holding(true)

				else:
					FormulaBut.get_node("Y").call_holding(false)
					_pressed = false

func _on_UP_pressed(_value) -> void :

	if LoadLevel_bool:
		return
	if LevelCamera.position.y > LevelCamera.limit_top + 500:
		LevelCamera.position.y -= (_value * 500)
func _on_DOWN_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.y < LevelCamera.limit_bottom - 500:
		LevelCamera.position.y += (_value * 500)
func _on_LEFT_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.x > LevelCamera.limit_left + 500:
		LevelCamera.position.x -= (_value * 500)
func _on_RIGHT_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.position.x < LevelCamera.limit_right - 500:
		LevelCamera.position.x += (_value * 500)
func _on_IN_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.zoom < Vector2(1.5, 1.5):
		LevelCamera.zoom += Vector2(0.1, 0.1)
func _on_OUT_pressed(_value) -> void :
	if LoadLevel_bool:
		return
	if LevelCamera.zoom > Vector2(1, 1):
		LevelCamera.zoom -= Vector2(0.1, 0.1)

func call_ani(_switch: bool):
	Ani_bool = _switch

func _on_BackBut_pressed() -> void :


	match cur_UI:
		CUI.MAIN:
			_del_view()
			cur_UI = CUI.NONE
			Ani.play_backwards("show")
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
			GameLogic.player_1P.call_control(0)
			GameLogic.player_2P.call_control(0)
			BankBut.release_focus()
		CUI.BANK:
			if Ani_bool:
				return
			cur_UI = CUI.MAIN
			UIAni.play("show")
		CUI.FINALCHECK:
			_on_FinalCheck_BackBut_pressed()
		CUI.LEVEL:
			cur_UI = CUI.MAIN
			UIAni.play("show")

		CUI.BUYDEV:
			if Ani_bool:
				return
			cur_UI = CUI.LEVEL
			Store_BuyNode.call_butlist_del()
			Store_BuyNode.cur_used = false
			UIAni.play("LevelUIShow")
		CUI.ORDER:
			if Ani_bool:
				return
			cur_UI = CUI.LEVEL
			Store_OrderNode.cur_used = false
			UIAni.play("LevelUIShow")
		CUI.MENU:
			cur_UI = CUI.MAIN
			UIAni.play("show")

		CUI.FORMULA:
			cur_UI = CUI.MENU
			MenuAni.play("hide")

			CurMenuNode.But_0.grab_focus()

		CUI.FORMULASELECT:
			cur_UI = CUI.FORMULA
			NewMenuNode.get_node("0").grab_focus()
func _on_FinalCheck_BackBut_pressed() -> void :
	cur_UI = CUI.BANK
	FinalCheckAni.play("init")

	yield(get_tree().create_timer(0.1), "timeout")
	call_Bank_GrabFocus()

func _on_FinalCheck_Apply_pressed() -> void :
	match TYPE:
		0:
			GameLogic.cur_Bank = Bank_TypeAni.get_assigned_animation()
			GameLogic.cur_LoanDay = 0
			GameLogic.cur_RepaymentDay = int(Loan_RepayDay.text)
			GameLogic.cur_LoanUsury = Loan_Usury
			GameLogic.cur_RepaymentTotal = Loan_Money + Loan_ReBaseMoney
		1:
			GameLogic.cur_Bank = ""
			GameLogic.cur_LoanDay = 0
			GameLogic.cur_RepaymentDay = 0
			GameLogic.cur_LoanUsury = 0
			GameLogic.cur_RepaymentTotal = 0

	var _BankAni = BankAni.get_assigned_animation()
	if _BankAni == "loan":
		GameLogic.call_MoneyChange(Loan_Money, GameLogic.HomeMoneyKey)
		BankAni.play("repayment")
	elif _BankAni == "repayment":
		var _RepayTotal = - (Loan_Money + Loan_ReBaseMoney)
		GameLogic.call_MoneyChange(_RepayTotal, GameLogic.HomeMoneyKey)
		BankAni.play("loan")
	call_init()
	_on_FinalCheck_BackBut_pressed()
	GameLogic._save()

func _on_BankBut_pressed() -> void :

	pass
func _on_StoreBut_pressed() -> void :
	if cur_UI == CUI.MAIN:
		cur_UI = CUI.LEVEL

		StoreBut.release_focus()
		GameLogic.ComputerLevel_bool = true
		UIAni.play("LevelUIShow")
		call_level_logic()

func _on_LoanBut_pressed() -> void :
	if cur_UI == CUI.BANK:
		cur_UI = CUI.FINALCHECK
		LoanBut.release_focus()
		FinalCheckAni.play("loan")
		TYPE = 0

func _on_RepaymentBut_pressed() -> void :
	if cur_UI == CUI.BANK:
		cur_UI = CUI.FINALCHECK
		RepayBut.release_focus()
		FinalCheckAni.play("repayment")
		TYPE = 1

func call_Bank_GrabFocus():

	Ani_bool = false
	match cur_UI:
		CUI.MAIN:
			BankBut.grab_focus()
			CurMenuNode.hide()
		CUI.BANK:
			if GameLogic.cur_Bank:
				if not RepayBut.disabled:
					RepayBut.grab_focus()
			else:
				LoanBut.grab_focus()
		CUI.FINALCHECK:

			FinalCheckBut.grab_focus()
		CUI.LEVEL:
			Store_TypeDevBut.grab_focus()
	call_init()
func call_level_logic():
	GameLogic.cur_Item_List.clear()
	var _Effect = GameLogic.TSCNLoad.LoadingEffect.instance()
	view.add_child(_Effect)









	loader = GameLogic.TSCNLoad.loader
	var _SceneName = GameLogic.cur_levelInfo.TSCN
	var _path = _Level_Path + _SceneName + ".tscn"
	var _check = ResourceLoader.exists(_path)
	if not _check:
		print("LoadingUI 错误，MainUILoad 地址不存在。")
		return

	if ResourceLoader.has_cached(_path):
		var _TSCN = loader.get_resource()

		var _TSCN_Instance = _TSCN.instance()
		_del_view()
		view.add_child(_TSCN_Instance)
		LevelNode = _TSCN_Instance
		LevelCamera = _TSCN_Instance.get_node("Camera2D")

	elif not LoadLevel_bool:
		loader = ResourceLoader.load_interactive(_path)
		if loader != null:
			item_count = loader.get_stage_count()
			LoadLevel_bool = true
			set_process(true)

func _del_view():
	var _viewArray = view.get_children()
	for i in _viewArray.size():
		var _Obj = _viewArray[i]
		_Obj.queue_free()

func _process(_delta):
	if loader != null:
		now_count = loader.get_stage()

		var _check = loader.poll()
		if _check == ERR_FILE_EOF:
			var _TSCN = loader.get_resource()

			var _TSCN_Instance = _TSCN.instance()
			_del_view()
			view.add_child(_TSCN_Instance)
			LevelNode = _TSCN_Instance
			LevelCamera = _TSCN_Instance.get_node("Camera2D")


			LoadLevel_bool = false
			set_process(false)
			GameLogic.TSCNLoad.loader = loader
			if cur_UI == CUI.ORDER:

				Store_OrderNode.call_init()
			if cur_UI == CUI.BUYDEV:
				Store_BuyNode.call_init()
		elif _check != OK:
			printerr("start loader check error:", _check, " loader:", loader.get_stage(), " count:", loader.get_stage_count())

func _on_DevBuyBut_pressed() -> void :
	cur_UI = CUI.BUYDEV
	UIAni.play("BuyUIShow")
	if LoadLevel_bool == false:
		Store_BuyNode.call_init()

func _on_OrderBut_pressed() -> void :
	cur_UI = CUI.ORDER
	UIAni.play("OrderUIShow")
	if LoadLevel_bool == false:
		Store_OrderNode.call_init()

func _on_MenuBut_pressed() -> void :
	GameLogic.call_StoreStar_Logic()
	cur_UI = CUI.MENU
	UIAni.play("MenuUIShow")
	CurMenuNode.call_init()
	CurMenuNode.show()
	call_New_Formula_Set()

func call_New_Formula_Set():
	var _Num = GameLogic.cur_NewFormulaList.size()

	for i in _Num:
		NewMenuNode.get_node(str(i)).ForName = GameLogic.cur_NewFormulaList[i]
		NewMenuNode.get_node(str(i))._MenuButton_set()
	if _Num < 3:
		NewMenuNode.get_node("2").hide()
		NewMenuNode.get_node("1").show()
	if _Num < 2:
		NewMenuNode.get_node("1").hide()
	else:
		NewMenuNode.get_node("1").show()
		NewMenuNode.get_node("2").show()

func call_butfocus_set(_switch):
	match _switch:
		true:
			var _but_Array = CurMenuNode.MenuBut_Node.get_children()
			var _butpath = NewMenuNode.get_node("0").get_path()
			for i in _but_Array.size():
				var _but = _but_Array[i]
				_but.set_focus_neighbour(MARGIN_LEFT, _butpath)
			_butpath = CurMenuNode.But_0.get_path()
			NewMenuNode.get_node("0").set_focus_neighbour(MARGIN_RIGHT, _butpath)
			NewMenuNode.get_node("1").set_focus_neighbour(MARGIN_RIGHT, _butpath)
			NewMenuNode.get_node("2").set_focus_neighbour(MARGIN_RIGHT, _butpath)
		false:
			var _but_Array = CurMenuNode.MenuBut_Node.get_children()
			for i in _but_Array.size():
				var _but = _but_Array[i]
				var _butpath = _but.get_path()
				_but.set_focus_neighbour(MARGIN_LEFT, _butpath)



func call_NewMenu_GrabFocus():
	NewMenuNode.get_node("0").grab_focus()

func call_Show_NewFormula():
	if GameLogic.cur_Menu.size() < GameLogic.cur_MenuNum:
		AddNewLabel.show()
		ReplaceLabel.hide()
	else:
		AddNewLabel.hide()
		ReplaceLabel.show()
	MenuAni.play("show")

	cur_UI = CUI.FORMULA
	FormulaBut.get_node("Y").call_holding(false)
	_pressed = false
func _on_Formula_pressed() -> void :

	GameLogic.call_new_formula(3)
	call_New_Formula_Set()
	call_Show_NewFormula()
	call_butfocus_set(true)

func _on_AddFormula_pressed() -> void :
	call_add_formula()
