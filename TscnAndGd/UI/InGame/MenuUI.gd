extends Control

var cur_pressed: bool
var cur_Select_For
var cur_Extra_Bool: bool
onready var Ani
onready var Menu
onready var NewMenuVBox
onready var But_0
onready var But_1
onready var But_2
onready var AddNewLabel
onready var ReplaceLabel
onready var BlockAni
onready var ValueNode
onready var AverAgeValue: float = 0
onready var Value_Array: Array

var Can_Re: bool

enum STATE{
	MAIN
	ADDNEW
	REPLACE
	CHECK
	ANI
}
var cur_STATE = STATE.MAIN

func But_0_grabfocus():

	if But_0:
		But_0.grab_focus()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		if not SteamLogic.is_connected("PlayerSYNC", self, "_PlayerSYNC"):
			var _SteamCon = SteamLogic.connect("PlayerSYNC", self, "_PlayerSYNC")
		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
		return
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.connect("P2_Control", self, "_control_logic")

func But_Init():
	BlockAni = get_node("BlockMouse/Ani")
	AddNewLabel = get_node("NewMenu/AddNewLabel")
	ReplaceLabel = get_node("NewMenu/ReplaceLabel")
	Ani = get_node("Ani")
	Menu = get_node("Menu")
	ValueNode = Menu.get_node("CurMenu/BG/Popularity/TextureProgress")
	NewMenuVBox = get_node("NewMenu/VBox")
	But_0 = NewMenuVBox.get_node("0")
	But_1 = NewMenuVBox.get_node("1")
	But_2 = NewMenuVBox.get_node("2")
	Menu.Call_ButControl(false)

func call_Value_set():
	Value_Array.clear()
	var _but_Array = Menu.get_node("CurMenu/MenuScroll/MenuVBox").get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		var _ForName = _but.ForName
		var _Data = GameLogic.Config.FormulaConfig[_ForName]

	AverAgeValue = 0
	for i in Value_Array.size():
		AverAgeValue += float(Value_Array[i]) * 10.0
	if Value_Array.size() > 0 and AverAgeValue > 0:
		AverAgeValue = AverAgeValue / float(Value_Array.size())
	ValueNode.value = AverAgeValue

func call_init():

	But_Init()
	match GameLogic.cur_DayType:
		"小料", "配方":
			AddNewLabel.show()
			ReplaceLabel.hide()
		"换饮品", "换小料":
			AddNewLabel.hide()
			ReplaceLabel.show()
		_:
			AddNewLabel.hide()
			ReplaceLabel.hide()
	Menu.call_init()
	get_node("Re/RandomCoin/Label").text = str(GameLogic.cur_ReDrawCoin)
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if GameLogic.cur_DayType == "小料":
		call_New_Extra_Set()
	elif GameLogic.cur_DayType == "配方":
		call_New_Formula_Set()
	elif GameLogic.cur_Event == "换饮品":
		call_New_Formula_Set()
	elif GameLogic.cur_Event == "换小料":
		call_New_Extra_Set()
	elif GameLogic.cur_DayType == "随机":
		call_New_Formula_Set()
	_set_OrderBut_focus()

	var _MenuButList = Menu.MenuBut_Node.get_children()
	for i in _MenuButList.size():
		var _But = _MenuButList[i]
		var _con = _But.connect("pressed", self, "call_add_formula")
	if int(GameLogic.cur_ReDrawCoin) > 0:
		get_node("Re").visible = true
	else:

		get_node("Re").visible = false

func _set_OrderBut_focus():




	var _but_Array = NewMenuVBox.get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		var _butpath = _but.get_path()
		if _but_Array.size() > 1:
			if i == 0:
				_but.set_focus_neighbour(MARGIN_TOP, _butpath)
				Menu.call_left_focus(_butpath)
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

func call_show():

	cur_STATE = STATE.MAIN
	call_Block_Bool(0)
	Ani.play("show")
	_CHOOSETIME = 0
	GameLogic.Can_ESC = false
	Menu.call_show_num()

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_Master_Switch(true)
func call_New_Extra_Set():
	GameLogic.call_StoreStar_Logic()
	var _ExtraList: Array = GameLogic.Order.cur_ExtraMenu.keys()
	var _List: Array
	for _Extra in _ExtraList:

		if int(GameLogic.Config.FormulaConfig[_Extra].Rank) <= GameLogic.cur_StoreStar:

			if not GameLogic.cur_Menu.has(_Extra):

				_List.append(_Extra)
	var _Num = _List.size()
	_List.shuffle()

	if _Num > 3:
		_Num = 3
		Can_Re = true
	else:
		Can_Re = false
	for i in _Num:
		if i > 2:
			break
		NewMenuVBox.get_node(str(i)).ForName = _List.pop_back()
		NewMenuVBox.get_node(str(i))._MenuButton_set()

	if _Num == 0:
		NewMenuVBox.get_node("0").hide()
		NewMenuVBox.get_node("1").hide()
		NewMenuVBox.get_node("2").hide()

	elif _Num == 1:
		NewMenuVBox.get_node("1").hide()
		NewMenuVBox.get_node("2").hide()
	elif _Num == 2:
		NewMenuVBox.get_node("2").disabled = true
		NewMenuVBox.get_node("2").hide()
		NewMenuVBox.get_node("1").show()
	else:
		NewMenuVBox.get_node("1").show()
		NewMenuVBox.get_node("2").show()
		NewMenuVBox.get_node("2").disabled = false


	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Puppet_But_Set", [_Num, But_0.ForName, But_1.ForName, But_2.ForName])
func call_Puppet_But_Set(_Num, _For1, _For2, _For3):
	NewMenuVBox.get_node("0").ForName = _For1
	NewMenuVBox.get_node("1").ForName = _For2
	NewMenuVBox.get_node("2").ForName = _For3
	if _For1 != "":
		NewMenuVBox.get_node("0")._MenuButton_set()
	if _For2 != "":
		NewMenuVBox.get_node("1")._MenuButton_set()
	if _For3 != "":
		NewMenuVBox.get_node("2")._MenuButton_set()
	if _Num == 0:
		NewMenuVBox.get_node("0").hide()
		NewMenuVBox.get_node("1").hide()
		NewMenuVBox.get_node("2").hide()
	elif _Num == 1:
		NewMenuVBox.get_node("1").hide()
		NewMenuVBox.get_node("2").hide()
	elif _Num == 2:
		NewMenuVBox.get_node("2").disabled = true
		NewMenuVBox.get_node("2").hide()
		NewMenuVBox.get_node("1").show()
	else:
		NewMenuVBox.get_node("1").show()
		NewMenuVBox.get_node("2").show()
		NewMenuVBox.get_node("2").disabled = false
	_set_OrderBut_focus()
func call_New_Formula_Set():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.cur_DayType in ["小料", "换小料"]:
		call_New_Extra_Set()
		return
	GameLogic.call_new_formula(3)

	GameLogic.call_StoreStar_Logic()
	var _Num = GameLogic.cur_NewFormulaList.size()

	if GameLogic.cur_level:
		if GameLogic.cur_Day == 1:
			GameLogic.cur_NewFormulaList.clear()
			for _Menu in GameLogic.cur_levelInfo.Menu:

				GameLogic.cur_NewFormulaList.append(_Menu)
			_Num = GameLogic.cur_NewFormulaList.size()


	GameLogic.cur_NewFormulaList.shuffle()

	if _Num <= 3:
		Can_Re = true
	else:
		Can_Re = false
	for i in _Num:

		if i > 2:
			break
		NewMenuVBox.get_node(str(i)).ForName = GameLogic.cur_NewFormulaList[i]
		NewMenuVBox.get_node(str(i))._MenuButton_set()

	if _Num == 0:
		NewMenuVBox.get_node("0").hide()
		NewMenuVBox.get_node("1").hide()
		NewMenuVBox.get_node("2").hide()
	elif _Num == 1:
		NewMenuVBox.get_node("1").hide()
		NewMenuVBox.get_node("2").hide()
	elif _Num == 2:
		NewMenuVBox.get_node("2").disabled = true
		NewMenuVBox.get_node("2").hide()
		NewMenuVBox.get_node("1").show()
	else:
		NewMenuVBox.get_node("1").show()
		NewMenuVBox.get_node("2").show()
		NewMenuVBox.get_node("2").disabled = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Puppet_But_Set", [_Num, But_0.ForName, But_1.ForName, But_2.ForName])
func call_add_formula():

	if GameLogic.cur_Menu.size() < GameLogic.cur_MenuNum:
		var _pressedBut = But_0.group.get_pressed_button()
		if _pressedBut:
			var _ForName = _pressedBut.ForName

			GameLogic.cur_Menu.append(_ForName)

			var _Data = _pressedBut._Data

			Menu.call_init()
			call_New_Formula_Set()

func _puppet_SYNC(_EXTRA, _MENU, _SELL1, _SELL2, _SELL3, _SELL4):
	GameLogic.cur_Extra = _EXTRA
	GameLogic.cur_Menu = _MENU
	GameLogic.Buy.Sell_1 = _SELL1
	GameLogic.Buy.Sell_2 = _SELL2
	GameLogic.Buy.Sell_3 = _SELL3
	GameLogic.Buy.Sell_4 = _SELL4

var _CHOOSETIME: int = 0
func call_select_again():
	GameLogic.Audio.But_Apply.play(0)

	cur_STATE = STATE.ANI
	call_Block_Bool(0)
	Ani.play("selectagain")

	GameLogic.Can_ESC = false
	Menu.call_show_num()

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_Master_Switch(true)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_select_again_puppet")

func call_main():
	cur_STATE = STATE.MAIN
	But_0_grabfocus()
func call_select_again_puppet():
	GameLogic.Audio.But_Apply.play(0)
	cur_STATE = STATE.ANI

	call_Block_Bool(0)
	Ani.play("selectagain")
	GameLogic.Can_ESC = false
	Menu.call_show_num()

func _on_BackBut_pressed():

	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.Audio.But_Apply.play(0)
	Ani.play("hide")

	var LevelNode = get_parent().get_parent()
	if LevelNode.has_method("_LEVELSTAT_LOGIC"):

		LevelNode._LEVELSTAT_LOGIC(2)
	self.queue_free()

func _PlayerSYNC(_Type, _id, _Data):

	match _Type:
		"PuppetBut":
			var _ButData = _Data[1]
			var _But = _ButData[0]
			var _Value = _ButData[1]
			var _ButType = _ButData[2]
			_control_logic(_But, _Value, _ButType)

func _control_logic(_but, _value, _type):

	if _value != 1 and _value != - 1:
		cur_pressed = false
	match _but:
		"X":
			if _value == 1 or _value == - 1:
				if int(GameLogic.cur_ReDrawCoin) > 0:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						var _PLAYER: int = 0
						match SteamLogic.STEAM_ID:
							SteamLogic.SLOT_2:
								_PLAYER = 2
							SteamLogic.SLOT_3:
								_PLAYER = 3
							SteamLogic.SLOT_4:
								_PLAYER = 4
						call_NetChoose(_PLAYER)
						return

				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

					SteamLogic.call_everybody_node_sync(self, "_on_Re_pressed")
				else:
					_on_Re_pressed()
		"B", "START":
			if _value == 1 or _value == - 1:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_everybody_node_sync(self, "_on_Back_pressed")
				else:
					_on_Back_pressed()

		"A":
			if _value == 1 or _value == - 1:


				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					if cur_STATE == STATE.MAIN:
						var _PLAYER: int = 0
						match SteamLogic.STEAM_ID:
							SteamLogic.SLOT_2:
								_PLAYER = 2
							SteamLogic.SLOT_3:
								_PLAYER = 3
							SteamLogic.SLOT_4:
								_PLAYER = 4
						var _NewButList = NewMenuVBox.get_children()
						for i in _NewButList.size():
							var _SelectBut = _NewButList[i]
							if _SelectBut.has_focus():
								_SelectBut.call_NetChoose(_PLAYER)
								break
					return
				if cur_STATE == STATE.ANI:
					return
				if cur_STATE == STATE.CHECK:
					_on_FinalCheck_pressed()


				elif cur_STATE == STATE.MAIN:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						pass

					else:
						_on_NewMenu_pressed()
				else:

					call_NewFormula_Logic()

		"U", "u":

			if _value == 1 or _value == - 1:
				if cur_pressed:
					return
				cur_pressed = true

				_udlf_logic("ui_up")
		"D", "d":
			if _value == 1 or _value == - 1:
				if cur_pressed:
					return
				cur_pressed = true

				_udlf_logic("ui_down")
		"L", "l":
			if _value == 1 or _value == - 1:
				if cur_pressed:
					return
				cur_pressed = true

				_udlf_logic("ui_left")
		"R", "r":
			if _value == 1 or _value == - 1:
				if cur_pressed:
					return
				cur_pressed = true

				_udlf_logic("ui_right")
	if _type == 0:
		cur_pressed = false
func _udlf_logic(_action: String):
	var _input = InputEventAction.new()
	_input.action = _action
	_input.pressed = true
	Input.parse_input_event(_input)

func call_Block_Bool(_Type: int):
	match _Type:
		1:
			BlockAni.play("select")
		0:
			BlockAni.play("init")
		2:
			BlockAni.play("all")

func call_NewFormula_Logic():

	if Ani.current_animation == "selectagain":
		return
	var _CurBut = Menu.return_cur_focus()

	if not is_instance_valid(_CurBut):
		return
	var _REPLACEBOOL: bool = false
	var _EXTRANUM: int = 0
	for _MENU in GameLogic.cur_Menu:

		var _MenuTag = GameLogic.Config.FormulaConfig[_MENU].Tag

		for _TAG in GameLogic.Order.EXTRATAGLIST:
			if _TAG in _MenuTag:
				_EXTRANUM += 1
	if cur_Extra_Bool and GameLogic.cur_Extra.size() >= GameLogic.cur_ExtraNum:
		_REPLACEBOOL = true
	elif not cur_Extra_Bool and GameLogic.cur_MenuNum <= GameLogic.cur_Menu.size() - _EXTRANUM:
		_REPLACEBOOL = true
	if not _REPLACEBOOL:


		GameLogic.cur_Menu.append(cur_Select_For)

		var _INFO = GameLogic.Config.FormulaConfig[cur_Select_For]
		if _INFO.Extra_1 != "":
			if not GameLogic.cur_Extra.has(_INFO.Extra_1):
				GameLogic.cur_Extra.append(_INFO.Extra_1)
			if _INFO.Extra_2 != "":
				if not GameLogic.cur_Extra.has(_INFO.Extra_2):
					GameLogic.cur_Extra.append(_INFO.Extra_2)
				if _INFO.Extra_3 != "":
					if not GameLogic.cur_Extra.has(_INFO.Extra_3):
						GameLogic.cur_Extra.append(_INFO.Extra_3)
		GameLogic.CustomerCheck()

	else:

		if cur_Extra_Bool:
			var _CHECKBOOL: bool = false
			for _TAG in GameLogic.Order.EXTRATAGLIST:
				if _TAG in _CurBut._Data.Tag:
					_CHECKBOOL = true
			if not _CHECKBOOL:
				print("选择的不是罐头。需要弹出相关提示")
				$Re / RandomCoin / InfoLabel / Ani.play("Wrong_1")
				var _AUDIO = GameLogic.Audio.return_Effect("错误1")
				_AUDIO.play(0)
				return

		else:
			var _CHECKBOOL: bool = true
			for _TAG in GameLogic.Order.EXTRATAGLIST:
				if _TAG in _CurBut._Data.Tag:
					_CHECKBOOL = false
			if not _CHECKBOOL:
				print("选择的是小料。需要弹出相关提示")
				$Re / RandomCoin / InfoLabel / Ani.play("Wrong_2")
				var _AUDIO = GameLogic.Audio.return_Effect("错误1")
				_AUDIO.play(0)
				return

		if GameLogic.cur_Menu.has(_CurBut.ForName):
			var _SelectInt = GameLogic.cur_Menu.find(_CurBut.ForName)

			GameLogic.cur_Menu.insert(_SelectInt, cur_Select_For)
			var _INFO = GameLogic.Config.FormulaConfig[cur_Select_For]
			if _INFO.Extra_1 != "":
				if not GameLogic.cur_Extra.has(_INFO.Extra_1):
					GameLogic.cur_Extra.append(_INFO.Extra_1)
				if _INFO.Extra_2 != "":
					if not GameLogic.cur_Extra.has(_INFO.Extra_2):
						GameLogic.cur_Extra.append(_INFO.Extra_2)
					if _INFO.Extra_3 != "":
						if not GameLogic.cur_Extra.has(_INFO.Extra_3):
							GameLogic.cur_Extra.append(_INFO.Extra_3)
			GameLogic.cur_Menu.erase(_CurBut.ForName)

	if cur_Extra_Bool:
		if not GameLogic.cur_Extra.has(_CurBut.ForName):
			GameLogic.cur_Extra.append(_CurBut.ForName)



	cur_STATE = STATE.ANI
	Menu.call_init()
	GameLogic.Can_Formula = false
	GameLogic.call_Formula()




	GameLogic.Audio.But_Apply.play(0)
	Ani.play("select")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_everybody_node_sync(self, "call_New_Puppet", [GameLogic.cur_Menu, GameLogic.cur_Extra])

func call_New_Puppet(_MENU, _EXTRA):
	GameLogic.cur_Menu = _MENU
	GameLogic.cur_Extra = _EXTRA
	cur_STATE = STATE.ANI
	Menu.call_init()
	GameLogic.Can_Formula = false
	GameLogic.call_Formula()

	GameLogic.Audio.But_Apply.play(0)
	Ani.play("select")

func call_CanCheck():
	cur_STATE = STATE.CHECK

func call_puppet_pressed(_SELECTFORNAME: String, _EXTRA: bool, _TYPE: String):
	cur_Select_For = _SELECTFORNAME
	cur_Extra_Bool = _EXTRA
	GameLogic.Audio.But_Apply.play(0)
	if _TYPE == "ADD":
		cur_STATE = STATE.ADDNEW
		call_Block_Bool(2)
		Menu.call_ButInfo(1)

		Menu.call_NewFormulaForCheck(cur_Select_For, true)
	elif _TYPE == "RE":
		cur_STATE = STATE.REPLACE
		call_Block_Bool(1)
		Menu.call_ButInfo(2)

		if Menu.But_0.has_method("grab_focus"):
			Menu.But_0.grab_focus()
func _on_NewMenu_pressed() -> void :

	var _NewButList = NewMenuVBox.get_children()
	cur_Extra_Bool = false
	for i in _NewButList.size():
		var _SelectBut = _NewButList[i]
		if _SelectBut.has_focus():
			cur_Select_For = _SelectBut.ForName
			for _TAG in GameLogic.Order.EXTRATAGLIST:
				if _TAG in _SelectBut._Data.Tag:
					cur_Extra_Bool = true

		elif i == 0:
			cur_Select_For = _SelectBut.ForName
			var _x = _SelectBut._Data
			for _TAG in GameLogic.Order.EXTRATAGLIST:
				if _TAG in _SelectBut._Data.Tag:
					cur_Extra_Bool = true

	GameLogic.Audio.But_Apply.play(0)


	var _REPLACEBOOL: bool = false
	var _EXTRANUM: int = 0
	for _MENU in GameLogic.cur_Menu:

		var _MenuTag = GameLogic.Config.FormulaConfig[_MENU].Tag
		for _TAG in GameLogic.Order.EXTRATAGLIST:
			if _TAG in _MenuTag:
				_EXTRANUM += 1

	if cur_Extra_Bool and GameLogic.cur_Extra.size() >= GameLogic.cur_ExtraNum:
		_REPLACEBOOL = true
	elif not cur_Extra_Bool and GameLogic.cur_MenuNum <= GameLogic.cur_Menu.size() - _EXTRANUM:

		_REPLACEBOOL = true
	if not _REPLACEBOOL:

		SteamLogic.call_puppet_node_sync(self, "call_puppet_pressed", [cur_Select_For, cur_Extra_Bool, "ADD"])
		cur_STATE = STATE.ADDNEW
		call_Block_Bool(2)
		Menu.call_ButInfo(1)

		Menu.call_NewFormulaForCheck(cur_Select_For, true)
	else:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_pressed", [cur_Select_For, cur_Extra_Bool, "RE"])
		cur_STATE = STATE.REPLACE
		call_Block_Bool(1)
		Menu.call_ButInfo(2)
		Menu.But_0.grab_focus()


func _on_Back_pressed() -> void :

	var _LEVELINFO = GameLogic.cur_levelInfo

	if GameLogic.curLevelList.has("难度-配方双选") or _LEVELINFO.GamePlay.has("难度-配方双选") or GameLogic.curLevelList.has("难度-小料双选") or _LEVELINFO.GamePlay.has("难度-小料双选"):
		if _CHOOSETIME <= 1:
			return
	GameLogic.Audio.But_Back.play(0)
	if cur_STATE == STATE.ADDNEW:
		Menu.call_NewFormulaForCheck(cur_Select_For, false)

	match cur_STATE:
		STATE.CHECK:
			_on_BackBut_pressed()

		STATE.ADDNEW, STATE.REPLACE:
			cur_STATE = STATE.MAIN
			call_Block_Bool(0)
			But_0.grab_focus()

func _on_FinalCheck_pressed() -> void :

	if cur_STATE == STATE.CHECK:
		_CHOOSETIME += 1
		var _LEVELINFO = GameLogic.cur_levelInfo
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

			return
		var _x = GameLogic.curLevelList
		var _y = _LEVELINFO.GamePlay
		var _z = GameLogic.cur_Day
		if GameLogic.curLevelList.has("难度-配方双选") or _LEVELINFO.GamePlay.has("难度-配方双选"):
			if GameLogic.cur_DayType in ["配方"]:
				if _CHOOSETIME <= 1 and GameLogic.cur_Day > 1:
					call_select_again()


					return
		if GameLogic.curLevelList.has("难度-双选小料") or _LEVELINFO.GamePlay.has("难度-双选小料"):
			if GameLogic.cur_DayType in ["小料"]:
				if _CHOOSETIME <= 1 and GameLogic.cur_Day > 1:
					call_select_again()
					return
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "_on_BackBut_pressed")
		_on_BackBut_pressed()

func _on_Re_pressed() -> void :

	var _CHECK = GameLogic.return_CanPick()
	if not Can_Re:
		var _Audio = GameLogic.Audio.return_Effect("错误1")
		_Audio.play(0)
		get_node("Re/RandomCoin/InfoLabel/Ani").play("show")
		return

	if _CHECK:
		if SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
			GameLogic.cur_ReDrawCoin += 1
		if GameLogic.cur_ReDrawCoin > 0:

			if cur_STATE == STATE.MAIN:

				if GameLogic.cur_DayType == "小料":
					call_New_Extra_Set()
				elif GameLogic.cur_DayType in ["配方", "随机"]:
					GameLogic.call_Formula_new(3)
					call_New_Formula_Set()
				But_0_grabfocus()
				GameLogic.cur_ReDrawCoin -= 1
				get_node("Re/RandomCoin/Label").text = str(GameLogic.cur_ReDrawCoin)
				GameLogic.call_ReDrawCoinChange()
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_Re_puppet", [GameLogic.cur_ReDrawCoin])
	else:
		var _Audio = GameLogic.Audio.return_Effect("错误1")
		_Audio.play(0)
		get_node("Re/RandomCoin/InfoLabel/Ani").play("show")
func _Select():
	pass
func call_Re_puppet(_RECOIN):

	GameLogic.cur_ReDrawCoin = _RECOIN
	get_node("Re/RandomCoin/Label").text = str(GameLogic.cur_ReDrawCoin)
	GameLogic.call_ReDrawCoinChange()

onready var NetChooseTSCN = preload("res://TscnAndGd/Effects/NetChoose.tscn")

func call_NetChoose(_PLAYER: int):
	var _ChooseTSCN = NetChooseTSCN.instance()
	var _randx = GameLogic.return_RANDOM() % 60 - 30
	var _randy = GameLogic.return_RANDOM() % 40 - 20
	var _POS: Vector2 = Vector2(_randx, _randy)
	var _NUM = $Re / X.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	_ChooseTSCN.position = _POS
	$Re / X.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)

	if SteamLogic.IsMultiplay:
		SteamLogic.call_puppet_node_sync(self, "call_NetChoose_puppet", [_PLAYER, _POS])
func call_NetChoose_puppet(_PLAYER, _POS):
	var _ChooseTSCN = NetChooseTSCN.instance()
	_ChooseTSCN.position = _POS
	var _NUM = $Re / X.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	$Re / X.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)
