extends Control
var MouseBool = false
var MousePos: Vector2

var Show: bool
var cur_used: bool
var cur_menu: Array
var cur_PlayerID: int

onready var MenuBut_Node = get_node("CurMenu/MenuScroll/MenuVBox")
onready var ButControl
onready var DayClosedBut
onready var CloseAni
onready var _ButGroup = preload("res://TscnAndGd/Buttons/MenuButton_buttongroup.tres")
onready var ValueNode
onready var MenuAni = get_node("MenuAni")
var But_0
onready var AverAgeValue: float = 0
onready var Value_Array: Array
onready var MENUSCROLL = $CurMenu / MenuScroll
var ButControlSwitch: bool = true

func _ready() -> void :
	call_deferred("_Onready_Set")

func Call_ButControl(_Switch: bool):
	ButControlSwitch = _Switch
	if ButControl:
		ButControl.visible = _Switch

func _Onready_Set():
	if has_node("CurMenu"):
		if has_node("CurMenu/ButControl"):
			ButControl = get_node("CurMenu/ButControl")
			ButControl.visible = ButControlSwitch
			if ButControl.has_node("CloseShop"):
				DayClosedBut = ButControl.get_node("CloseShop")
		if has_node("CurMenu/Control/Close/CloseAni"):
			CloseAni = get_node("CurMenu/Control/Close/CloseAni")
		if has_node("CurMenu/BG/Popularity/TextureProgress"):
			ValueNode = get_node("CurMenu/BG/Popularity/TextureProgress")

	var _CON = GameLogic.connect("DayStart", self, "call_init")
	var _CON_CLOSE = GameLogic.Tutorial.connect("Closed", self, "_ClosedButShow")
	GameLogic.GameUI.MenuUIShow = false

func _ClosedButShow():
	DayClosedBut.show()
func call_grabfocus():

	But_0.grab_focus()

func return_cur_focus():
	var _but_Array = MenuBut_Node.get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		if _but.has_focus():
			return _but

	return

func call_NewFormulaForCheck(_ForMulaName, _NewBool: bool):

	match _NewBool:
		true:
			var MenuBut = GameLogic.TSCNLoad.MenuBut
			var _But = MenuBut.instance()
			_But.name = str(GameLogic.cur_Menu.size() + 1)
			_But.ForName = str(_ForMulaName)
			MenuBut_Node.add_child(_But)

			var _butpath = _But.get_path()
			_But.set_focus_neighbour(MARGIN_TOP, _butpath)
			_But.set_focus_neighbour(MARGIN_LEFT, _butpath)
			_But.set_focus_neighbour(MARGIN_RIGHT, _butpath)
			_But.set_focus_neighbour(MARGIN_BOTTOM, _butpath)


			_But.call_ButInfo(1)
			yield(get_tree().create_timer(0.1), "timeout")
			if is_instance_valid(_But):
				_But.grab_focus()

		false:
			var _but_Array = MenuBut_Node.get_children()
			for i in _but_Array.size():
				var _but = _but_Array[i]
				if _but.ForName == _ForMulaName:
					MenuBut_Node.remove_child(_but)
					_but.queue_free()
			pass
	pass
func call_ButInfo(_Type: int):
	var _but_Array = MenuBut_Node.get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		_but.call_ButInfo(_Type)

func call_init():
	var MenuBut = GameLogic.TSCNLoad.MenuBut
	Value_Array.clear()
	_del_MenuBut()

	cur_menu = GameLogic.cur_Menu

	for i in cur_menu.size():
		var _But = MenuBut.instance()
		_But.name = str(i + 1)
		_But.ForName = str(cur_menu[i])
		MenuBut_Node.add_child(_But)
		_But.set_button_group(_ButGroup)
		if i == 0:
			But_0 = _But
		Value_Array.append(0)
	_set_OrderBut_focus()
	if has_node("CurMenu"):
		call_show_num()
	cur_used = true

func call_left_focus(_LeftButPath):

	pass
func _set_OrderBut_focus():




	var _but_Array = MenuBut_Node.get_children()
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
func call_show_num():
	var _Count = GameLogic.cur_Menu.size()

	if has_node("CurMenu/BG/CurNum/Info/Num"):
		var _NumLabel = get_node("CurMenu/BG/CurNum/Info/Num")

		if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
			var _INFO = GameLogic.Config.SceneConfig[GameLogic.cur_level]
			if _INFO.has("MenuMax"):
				GameLogic.cur_MenuNum = int(_INFO.MenuMax)
				var _LEVELINFO = GameLogic.cur_levelInfo
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					_LEVELINFO = SteamLogic.LevelDic.cur_levelInfo

				if GameLogic.curLevelList.has("难度-菜单上限+1"):
					GameLogic.cur_MenuNum += 1
				if GameLogic.curLevelList.has("难度-菜单上限无限"):
					GameLogic.cur_MenuNum = 99


			if _INFO.has("ExtraMax"):
				GameLogic.cur_ExtraNum = int(_INFO.ExtraMax)
		if GameLogic.cur_MenuNum >= 99:
			_NumLabel.text = "∞"
		else:
			_NumLabel.text = str(GameLogic.cur_MenuNum)
		get_node("CurMenu/BG/CurNum/Extra/Num").text = str(GameLogic.cur_ExtraNum)
func _del_MenuBut():

	var _ButArray = MenuBut_Node.get_children()
	for i in _ButArray.size():
		var _but = _ButArray[i]
		MenuBut_Node.remove_child(_but)
		_but.queue_free()
func call_Value_set():
	AverAgeValue = 0
	for i in Value_Array.size():
		AverAgeValue += float(Value_Array[i]) * 10.0
	if AverAgeValue > 0:
		AverAgeValue = AverAgeValue / float(Value_Array.size())
		ValueNode.value = AverAgeValue
func _PowerBut_Logic(_switch: bool):
	match _switch:
		false:
			DayClosedBut.get_node("A").InfoLabel.text = GameLogic.CardTrans.get_message(DayClosedBut.get_node("A").Info_Str)
		true:
			DayClosedBut.get_node("A").InfoLabel.text = GameLogic.CardTrans.get_message(DayClosedBut.get_node("A").Info_1)
func call_show(_curPlayerID):




	if DayClosedBut:

		if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:
			_PowerBut_Logic(false)
			DayClosedBut.show()

		elif GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime and not GameLogic.GameUI.Is_Open:
			_PowerBut_Logic(true)
			DayClosedBut.show()
		else:
			DayClosedBut.hide()
	if not _curPlayerID in [SteamLogic.STEAM_ID, 1, 2]:
		get_node("CurMenu/ButControl/CloseUI/B").ButPlayer = _curPlayerID
		get_node("CurMenu/ButControl/CloseShop/A").ButPlayer = _curPlayerID
		return
	cur_PlayerID = int(_curPlayerID)
	match cur_PlayerID:
		1, SteamLogic.STEAM_ID:
			if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.connect("P1_Control", self, "_control_logic")
		2:
			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.connect("P2_Control", self, "_control_logic")
		_:
			if SteamLogic.LOBBY_IsMaster and cur_PlayerID == SteamLogic.STEAM_ID:
				if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
					GameLogic.Con.connect("P1_Control", self, "_control_logic")
	get_node("CurMenu/ButControl/CloseUI/B").ButPlayer = cur_PlayerID
	get_node("CurMenu/ButControl/CloseShop/A").ButPlayer = cur_PlayerID
	MenuAni.play("show")
	Show = true
	GameLogic.GameUI.MenuUIShow = true

func call_hide():
	if Show:
		MenuAni.play("hide")


		Show = false

		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
		match cur_PlayerID:
			1, SteamLogic.STEAM_ID:
				if is_instance_valid(GameLogic.player_1P):
					GameLogic.player_1P.call_control(0)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(GameLogic.player_1P, "call_control", [0])
			2:
				if is_instance_valid(GameLogic.player_2P):
					GameLogic.player_2P.call_control(0)
		GameLogic.Audio.But_Back.play(0)
		yield(get_tree().create_timer(0.1), "timeout")
		GameLogic.GameUI.MenuUIShow = false

func _control_logic(_but, _value, _type):


	if not cur_used:
		return
	match _but:
		"B", "START":
			if get_parent().name == "LevelNode":
				return
			else:
				if _value == 1 or _value == - 1:
					call_hide()
		"U", "u":
			if _value == 1 or _value == - 1:

				MENUSCROLL.scroll_vertical = round(MENUSCROLL.scroll_vertical / 170) * 170 - 170
				pass
		"D", "d":
			if _value == 1 or _value == - 1:

				MENUSCROLL.scroll_vertical += 170

				pass
		"A":

			call_Power_logic()
func call_Power_puppet():
	if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
		if not GameLogic.Order.return_CanClosed():

			CloseAni.play("close")
		elif GameLogic.Buy.buy_Array.size():
			CloseAni.play("delivery")
		else:
			var _PlayerArray = get_tree().get_root().get_node("Level/YSort/Players").get_children()
			for _PLAYER in _PlayerArray:
				if is_instance_valid(_PLAYER):

					if is_instance_valid(instance_from_id(_PLAYER.Con.HoldInsId)):
						CloseAni.play("holding")
						return
					if _PLAYER.IsDead:
						CloseAni.play("dead")
						return

			var _CouriersList = get_tree().get_nodes_in_group("Couriers")
			var _CheckList: Array
			for _Courier in _CouriersList:
				_CheckList.append(_Courier.return_Courier_Check())
			if false in _CheckList:
				CloseAni.play("delivery")
				return
			else:
				GameLogic.call_dayover()
	pass
func call_Power_logic():

	if get_parent().name == "LevelNode":
		return

	if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:

		if GameLogic.Order.cur_OrderList.size():

			CloseAni.play("close")
		elif GameLogic.Buy.buy_Array.size():
			CloseAni.play("delivery")
		else:
			var _PlayerArray = get_tree().get_root().get_node("Level/YSort/Players").get_children()
			for _PLAYER in _PlayerArray:
				if is_instance_valid(_PLAYER):
					if is_instance_valid(instance_from_id(_PLAYER.Con.HoldInsId)):
						CloseAni.play("holding")
						return
					if _PLAYER.IsDead:
						CloseAni.play("dead")
						return

			var _CouriersList = get_tree().get_nodes_in_group("Couriers")
			var _CheckList: Array
			for _Courier in _CouriersList:
				_CheckList.append(_Courier.return_Courier_Check())
			if false in _CheckList:
				CloseAni.play("delivery")
				return
			else:
				call_hide()
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_master_node_sync(self, "call_Power_puppet")
				else:
					GameLogic.call_dayover()
	if not GameLogic.GameUI.Is_Open and GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:

		call_hide()
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_master_node_sync(self, "call_OpenLogic")
		else:
			call_OpenLogic()


func call_OpenLogic():


	if GameLogic.GameUI.Is_Open:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	GameLogic.GameUI.call_Open()
	DayClosedBut.hide()
