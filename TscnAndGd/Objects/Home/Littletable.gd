extends Head_Object

var cur_pressed: bool
var cur_A_Pressed: bool
var cur_Tab: String = "0"
var cur_Used: bool = false

onready var ButShow = get_node("Button/A")
onready var HomeUpdateUI = get_node("HomeUpdateUI")
onready var Ani = HomeUpdateUI.get_node("Ani")
onready var TypeAni = HomeUpdateUI.get_node("TypeAni")
onready var TabNode = HomeUpdateUI.get_node("Control/Tab/HBox")
onready var ApplyBut = HomeUpdateUI.get_node("Control/ButControl/ApplyBut")
onready var A_But = ApplyBut.get_node("A")
onready var TabBut = TabNode.get_node("0")
onready var LButton = HomeUpdateUI.get_node("Control/Tab/L")
onready var RButton = HomeUpdateUI.get_node("Control/Tab/R")
onready var BackBut = HomeUpdateUI.get_node("Control/ButControl/BackBut")
onready var InfoButNode = HomeUpdateUI.get_node("Control/Info/BG/Scroll/VBox")
onready var Home_UnLock = HomeUpdateUI.get_node("Control/InfoControl/Home/UnlockLabel")
onready var Home_Info = HomeUpdateUI.get_node("Control/InfoControl/Home/InfoLabel")
onready var Home_Area = HomeUpdateUI.get_node("Control/InfoControl/Home/AreaLabel")
onready var Home_PNG = HomeUpdateUI.get_node("Control/InfoControl/Home/HomeSprite")
onready var Furniture_Info = HomeUpdateUI.get_node("Control/InfoControl/Furniture/Info")
onready var Furniture_Sprite = HomeUpdateUI.get_node("Control/InfoControl/Furniture/Control/FurnitureSprite")
onready var TutorialAni = HomeUpdateUI.get_node("GuideNode/AnimationPlayer")
onready var UpdateAni = get_node("GuideNode/AnimationPlayer")
onready var HomeUpdateBut = preload("res://TscnAndGd/Buttons/HomeUpdateButton.tscn")
onready var CurButGroup
onready var HomeUpdateGroups = preload("res://TscnAndGd/Buttons/HomeButton_buttongroup.tres")

onready var HomeBut
onready var aniPlayer = $AniNode / Ani

var IsBuy: bool
func _ready() -> void :
	match GameLogic.GlobalData.LoadingType:
		1:
			_HomeUpdateUI_Load()

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:

		var _HMK = GameLogic.return_FullHMK()
		if _HMK >= 50:
			if GameLogic.Save.gameData["HomeUpdate"] == 0:
				UpdateAni.play("show")
func _on_L_pressed() -> void :
	var _PressBut = TabBut.group.get_pressed_button()
	if int(_PressBut.name) > 0:
		var _butName = str(int(_PressBut.name) - 1)
		var _parNode = TabBut.get_parent()
		var _But = _parNode.get_node(_butName)

		_But.pressed = true
	_But_Logic()
	_on_Tab_pressed()
	call_HomeButton_pressed(true)
	_Buy_Check()
func _on_R_pressed() -> void :
	var _PressBut = TabBut.group.get_pressed_button()
	if int(_PressBut.name) < 3:
		var _butName = str(int(_PressBut.name) + 1)
		var _parNode = TabBut.get_parent()
		var _But = _parNode.get_node(_butName)

		_But.pressed = true
	_Tab_Click()

func _Tab_Click():

	GameLogic.Audio.But_EasyClick.play(0)
	_TypwShow_logic()
	_But_Logic()
	_on_Tab_pressed()
	_Buy_Check()
func _on_Tab_pressed() -> void :
	var _PressBut = TabBut.group.get_pressed_button()
	if _PressBut:
		var _NAME = _PressBut.name
		if _PressBut.name != "":

			cur_Tab = _PressBut.name
		_TypwShow_logic()

func _TypwShow_logic():
	match cur_Tab:
		"0":
			TypeAni.play("Home")

		"1", "2", "3":
			var _NAME = "Furniture_" + cur_Tab
			TypeAni.play(_NAME)

	_del_all_InfoButton()
	_add_InfoButton()
	var _test = GameLogic.cur_money_home * GameLogic.HomeMoneyKey
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	elif _test < 50:
		TutorialAni.play("init")
		UpdateAni.play("init")
		return
	elif GameLogic.Save.gameData["HomeUpdate"] == 0:
		if not GameLogic.Save.gameData.HomeDevList.has("书架"):

			if cur_Tab == "1":
				TutorialAni.play("Buy")
			else:
				TutorialAni.play("BuyChoose")
		elif cur_Tab == "0":
			TutorialAni.play("Update")
		else:
			TutorialAni.play("ChooseHouse")
		UpdateAni.play("show")

func _But_Logic():
	var _PressBut = TabBut.group.get_pressed_button()
	var _L = LButton.get_node("L")
	var _R = RButton.get_node("R")
	if int(_PressBut.name) <= 0:
		LButton.disabled = true
		_L.call_disabled(true)
	else:
		LButton.disabled = false
		_L.call_disabled(false)
	if int(_PressBut.name) >= 3:
		RButton.disabled = true
		_R.call_disabled(true)
	else:
		var _nextBut = str(int(_PressBut.name) + 1)
		if TabNode.get_node(_nextBut).disabled:
			RButton.disabled = true
			_R.call_disabled(true)
		else:
			RButton.disabled = false
			_R.call_disabled(false)

func _L_But():
	_control_logic("l", 1, 0)
func _R_But():
	_control_logic("r", 1, 0)
func call_Demo_Switch(_Switch: bool):
	if HomeUpdateUI.has_node("Control/DemoLabel"):
		HomeUpdateUI.get_node("Control/DemoLabel").visible = _Switch
func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		if cur_pressed or cur_A_Pressed:
			return
		match _but:
			"L", "l":
				cur_pressed = true
				if not LButton.disabled:
					LButton.call_pressed()
					_on_L_pressed()
			"R", "r":
				cur_pressed = true
				if not RButton.disabled:
					RButton.call_pressed()
					_on_R_pressed()
					call_Demo_Switch(false)
			"B", "START":
				BackBut.on_pressed()
				call_closed()
			"A":

				if not cur_pressed and ApplyBut.visible:
					if GameLogic.DEMO_bool:
						if cur_Tab == "0":
							if is_instance_valid(HomeBut):
								var _But = HomeBut.group.get_pressed_button()
								if int(_But.name) > 1:
									call_Demo_Switch(true)
									var _Audio = GameLogic.Audio.return_Effect("错误1")
									_Audio.play(0)
									return
					cur_pressed = true
					cur_A_Pressed = true
					_on_Apply_button_down()
			"u", "U":
				if not cur_pressed:
					cur_pressed = true
					if not is_instance_valid(HomeBut):
						return
					var _But = HomeBut.group.get_pressed_button()
					if int(_But.name) != 0:
						if InfoButNode.has_node(str(int(_But.name) - 1)):
							InfoButNode.get_node(str(int(_But.name) - 1)).set_pressed(true)
							InfoButNode.get_node(str(int(_But.name) - 1)).grab_focus()
							GameLogic.Audio.But_EasyClick.play(0)

			"d", "D":
				if not cur_pressed:
					cur_pressed = true
					if not is_instance_valid(HomeBut):
						return
					var _But = HomeBut.group.get_pressed_button()
					if int(_But.name) < InfoButNode.get_child_count():
						if InfoButNode.has_node(str(int(_But.name) + 1)):
							InfoButNode.get_node(str(int(_But.name) + 1)).set_pressed(true)
							InfoButNode.get_node(str(int(_But.name) + 1)).grab_focus()
							GameLogic.Audio.But_EasyClick.play(0)


	elif _value < 1 and _value > - 1:
		cur_pressed = false
		match _but:
			"A":
				_on_Apply_button_up()
				cur_A_Pressed = false
	if _type == 0:

		cur_pressed = false
func _on_Apply_button_down() -> void :
	A_But.call_holding(true)
	ApplyBut.call_down()

func _on_Apply_button_up() -> void :
	A_But.call_holding(false)
	ApplyBut.call_up()

func _Apply_Logic():

	if not is_instance_valid(HomeBut):
		return
	var _But = HomeBut.group.get_pressed_button()

	var _HMK = GameLogic.return_FullHMK()

	match cur_Tab:
		"0":
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.JOIN.call_BuyError_Info()
				return
	if _HMK >= _But.Cost:
		var _r = GameLogic.call_MoneyHomeChange(_But.Cost * - 1, GameLogic.HomeMoneyKey)
		if not _r:
			return
		match cur_Tab:
			"0":
				GameLogic.Save.gameData["HomeUpdate"] = int(_But.NameInfo)
				GameLogic.call_save()
				GameLogic.LoadingUI.call_HomeLoad()
			"1", "2", "3":

				if not GameLogic.Save.gameData.has("HomeDevList"):
					GameLogic.Save.gameData["HomeDevList"] = []
				if not GameLogic.Save.gameData.HomeDevList.has(_But.NameInfo):
					GameLogic.Save.gameData.HomeDevList.append(_But.NameInfo)
				_But._check_logic()
				_Buy_Check()
				GameLogic.call_save()
		call_But_BuyCheck()


func call_But_BuyCheck():
	var _But = HomeBut.group.get_pressed_button()
	if is_instance_valid(_But):
		var _NODE = _But.get_parent()
		for _BUTTON in _NODE.get_children():
			_BUTTON.call_CanBuy_Check()


func _Buy_Check():
	yield(get_tree().create_timer(0.1), "timeout")
	if not is_instance_valid(HomeBut):
		call_None_Show()
		return
	var _But = HomeBut.group.get_pressed_button()
	if not is_instance_valid(_But):
		call_None_Show()
		return

	IsBuy = _But.CheckBool

	match cur_Tab:
		"0":

			_HomeMoney_Check(_But)
		"1", "2", "3":
			_HomeMoney_Check(_But)
	if GameLogic.DEMO_bool:
		if cur_Tab == "0":
			var _CurBut = HomeBut.group.get_pressed_button()

			if int(_CurBut.name) > 1:
				call_Demo_Switch(true)
			else:
				call_Demo_Switch(false)
func _HomeMoney_Check(_But):

	var _HMK = GameLogic.return_FullHMK()
	if _HMK >= _But.Cost:

		match IsBuy:
			true:

				ApplyBut.hide()
			false:

				if _But.IsUnlock:
					ApplyBut.hide()
					A_But.hide()
				else:

					ApplyBut.show()
					A_But.show()
	else:

		ApplyBut.hide()
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		0, "A":
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				_Player.call_Say_NoUse()
				return
			if not cur_Used:
				if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
					GameLogic.Con.connect("P1_Control", self, "_control_logic")
				if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
					GameLogic.Con.connect("P2_Control", self, "_control_logic")
				if is_instance_valid(GameLogic.player_1P):
					GameLogic.player_1P.call_control(1)
				if is_instance_valid(GameLogic.player_2P):
					GameLogic.player_2P.call_control(1)
				match GameLogic.GlobalData.LoadingType:
					0:
						_HomeUpdateUI_Load()
				cur_Used = true
				GameLogic.Audio.But_SwitchOn.play(0)
				GameLogic.Achievement.call_Logic_Check()
				Ani.play("show")
				GameLogic.Can_ESC = false
				_TypwShow_logic()
				TabBut.pressed = true
				_on_Tab_pressed()
				_Buy_Check()
				call_HomeButton_pressed(true)
				_But_Logic()
				return true

func _HomeUpdateUI_Load():
	if A_But.is_connected("HoldFinish", self, "_Apply_Logic"):
		return
	for _Node in TabNode.get_children():
		var _Check = _Node.connect("pressed", self, "_Tab_Click")
	var _con1 = A_But.connect("HoldFinish", self, "_Apply_Logic")
	var _con2 = BackBut.connect("pressed", self, "call_closed")
	var _PressBut = TabBut.group.get_pressed_button()
	var _ConL = LButton.connect("pressed", self, "_L_But")
	var _ConR = RButton.connect("pressed", self, "_R_But")
	ApplyBut.hide()
	if not GameLogic.DEMO_bool:
		HomeUpdateUI.get_node("Control/DemoLabel").hide()
	else:
		HomeUpdateUI.get_node("Control/DemoLabel").show()

func call_closed():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

	BackBut.call_down()

	HomeUpdateUI.get_node("Ani").play("hide")
	cur_Used = false

	GameLogic.call_SYNC()
	GameLogic.Tutorial.call_Check_Level2()

func call_CanControl():
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(0)
	if is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(0)
	GameLogic.Can_ESC = true
func _del_all_InfoButton():

	var _child_array = InfoButNode.get_children()
	for i in _child_array.size():
		var _but = _child_array[i]
		var _butPar = _but.get_parent()
		_butPar.remove_child(_but)
		_but.queue_free()

func return_CanBuyCheck(_FURNITURENAME):
	match _FURNITURENAME:
		"保险柜":
			if not GameLogic.Achievement.AchievementReward_Array.has("钞票2"):
				return false
		"电视机":
			if not SteamLogic.STEAM_BOOL:
				return false
	return true

func _add_InfoButton():

	var _Data_Array: Array
	var _Check_Array: Array
	match cur_Tab:
		"0":
			_Data_Array = GameLogic.Config.HomeConfig.keys()
		"1", "2", "3":
			if GameLogic.Save.gameData.has("HomeUpdate"):
				var _HomeUpdate = GameLogic.Save.gameData.HomeUpdate

				var _HomeKeys = GameLogic.Config.HomeConfig.keys()
				for _ID in _HomeKeys.size():
					if _ID == _HomeUpdate:
						var _ARRAY: Array = GameLogic.Config.HomeConfig[str(_ID)].FurnitureList
						for _FURNITURENAME in _ARRAY:
							if return_CanBuyCheck(_FURNITURENAME):
								var _INFO = GameLogic.Config.HomeDevConfig[_FURNITURENAME]

								if _INFO.SellType == cur_Tab:
									if not _Data_Array.has(_FURNITURENAME):
										if GameLogic.Save.gameData.has("HomeDevList"):
											if GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
												_Check_Array.append(_FURNITURENAME)

											else:
												_Data_Array.append(_FURNITURENAME)
										else:
											_Data_Array.append(_FURNITURENAME)
						break

	for i in _Data_Array.size():
		var _But = HomeUpdateBut.instance()
		_But.name = str(InfoButNode.get_child_count())
		InfoButNode.add_child(_But)
		_But.connect("toggled", self, "call_HomeButton_pressed")

		if i == 0:
			CurButGroup = HomeUpdateGroups
			HomeBut = _But
			_But.set_button_group(CurButGroup)
			_But.grab_focus()
		else:
			_But.set_button_group(CurButGroup)
		match cur_Tab:
			"0":
				_But.call_init(_But.name)
			"1", "2", "3":
				_But.call_init(_Data_Array[i])
		if i == 0:
			_But.set_pressed(true)

	for i in _Check_Array.size():
		var _But = HomeUpdateBut.instance()
		_But.name = str(InfoButNode.get_child_count())
		InfoButNode.add_child(_But)
		_But.connect("toggled", self, "call_HomeButton_pressed")

		match cur_Tab:
			"0":
				_But.call_init(_But.name)
			"1", "2", "3":
				_But.call_init(_Check_Array[i])
		if i == 0 and not _Data_Array.size():
			CurButGroup = HomeUpdateGroups
			HomeBut = _But

			_But.set_button_group(CurButGroup)
			_But.set_pressed(true)
			_But.grab_focus()
		else:
			_But.set_button_group(CurButGroup)


	_set_OrderBut_focus()

func call_None_Show():
	TypeAni.play("None")

func call_HomeButton_pressed(_pressed: bool):
	if _pressed:

		var _NAME = "0"
		if is_instance_valid(HomeBut):

			var _But = HomeBut.group.get_pressed_button()

			if is_instance_valid(_But):
				_NAME = _But.NameInfo

		match cur_Tab:
			"0":

				call_HomeInfo_Show(_NAME)
			"1", "2", "3":
				call_DevInfo_Show(_NAME)
		_Buy_Check()
func call_HomeInfo_Show(_HomeID: String):

	if not _HomeID:
		_HomeID = "0"
	if GameLogic.Config.HomeConfig.has(_HomeID):
		var _INFO = GameLogic.Config.HomeConfig[_HomeID]

		var _TexPath = "res://Resources/Home/home_pack.sprites/" + _INFO.PNG + ".tres"

		var _Tex = load(_TexPath)
		Home_PNG.set_texture(_Tex)
		Home_UnLock.text = GameLogic.CardTrans.get_message(_INFO.Unlock)
		Home_Area.text = _INFO.Area

		var _INFO_Base = GameLogic.CardTrans.get_message(_INFO.Info)
		var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)

		var _Info = "[fill][center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center]"
		Home_Info.bbcode_text = _Info

func call_DevInfo_Show(_DevID: String):

	if _DevID == "0":
		call_None_Show()
		return
	if GameLogic.Config.HomeDevConfig.has(_DevID):
		var _INFO = GameLogic.Config.HomeDevConfig[_DevID]


		var _INFO_Base = GameLogic.CardTrans.get_message(_INFO.Info)

		var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)
		var _Info = "[fill][center]" + _Info_1.format(GameLogic.Info.Info_Name) + "[/center]"

		Furniture_Info.bbcode_text = _Info

		var TexPath = "res://Resources/Home/home_pack.sprites/" + _INFO.Tres + ".tres"
		var _Check = ResourceLoader.exists(TexPath)
		if not _Check:
			TexPath = "res://Resources/Home/home2_pack.sprites/" + _INFO.Tres + ".tres"
		_Check = ResourceLoader.exists(TexPath)
		if _Check:
			var _Tex = load(TexPath)
			Furniture_Sprite.set_texture(_Tex)

func _set_OrderBut_focus():




	var _but_Array = InfoButNode.get_children()
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

func _on_Tab_toggled(button_pressed: bool) -> void :
	if button_pressed:
		var _PressBut = TabBut.group.get_pressed_button()
		if _PressBut:
			if _PressBut.name != "":
				if _PressBut.name != cur_Tab:
					cur_Tab = _PressBut.name
				_TypwShow_logic()

func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")
