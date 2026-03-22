extends Control
onready var EscAni = get_node("Ani")

onready var ResumeBut = get_node("VBoxContainer/ResumeBut")
onready var GiveUpButton = get_node("VBoxContainer/GiveUpButton")
onready var CheckCardsBut = get_node("VBoxContainer/CheckCardsBut")
onready var ResetBut = get_node("VBoxContainer/Reset")
onready var CardNode = get_node("Cards")
onready var TutorialNode = get_node("Tutorial")

var Tutorial = null
var _paused: bool
var cur_pressed: bool
var cur_UI = UI.MAIN
enum UI{
	MAIN
	CARD
	TUTORIAL
	OPTION
	KEYSETTING
	GIVEUPSECOND
	EXITSECOND
}

func call_reset():
	EscAni.play("init")
	GameLogic.Can_ESC = true
	_paused = false
func call_init():
	if is_instance_valid(Tutorial):
		Tutorial.queue_free()
		Tutorial = null
	if not GameLogic.DEMO_bool:
		$VBoxContainer / WishList.hide()

func call_CardOff():
	EscAni.play("show")
	cur_UI = UI.MAIN

func call_grabfocus():

	ResumeBut.grab_focus()

func call_releasefocus():
	pass
func _on_Exit_pressed():
	call_esc_logic()
	SteamLogic.call_LeaveLobby(false, SteamLogic.LOBBY_ID)
	GameLogic.GameUI.get_node("HomeInfo").hide()
	GameLogic.LoadingUI.mainUILoad()
func _on_ExitButton_pressed() -> void :

	$VBoxContainer / ExitButton / Second / AnimationPlayer.play("play")


func _on_ResumeBut_pressed() -> void :
	call_esc_logic()

func _on_KeySettingBut_pressed():
	GameLogic.GameUI.KeySettingNode.call_Show(true)
	GameLogic.GameUI.call_PanelAni(true)
	cur_UI = UI.KEYSETTING
	EscAni.play("hide")
	GameLogic.Audio.But_Apply.play(0)
	if not GameLogic.GameUI.KeySettingNode.get_node("ButControl/BackBut").is_connected("pressed", self, "_on_KeySettingBut_Back"):
		GameLogic.GameUI.KeySettingNode.get_node("ButControl/BackBut").connect("pressed", self, "_on_KeySettingBut_Back")

func _on_KeySettingBut_Back():
	EscAni.play("show")
	cur_UI = UI.MAIN
	GameLogic.Audio.But_Back.play(0)
	GameLogic.GameUI.KeySettingNode.call_Show(false)

func _on_Options_Back():
	cur_UI = UI.MAIN
	GameLogic.Audio.But_Back.play(0)
	GameLogic.GameUI.OptionNode.call_Show(false)
	EscAni.play("optionoff")
	cur_UI = UI.MAIN
func _on_OptionsBut_pressed() -> void :
	cur_UI = UI.OPTION
	EscAni.play("options")
	GameLogic.GameUI.OptionNode.call_Show(true)
	if not GameLogic.GameUI.OptionNode.BackBut.is_connected("pressed", self, "_on_Options_Back"):
		GameLogic.GameUI.OptionNode.BackBut.connect("pressed", self, "_on_Options_Back")
func call_CardNode(_Switch: bool):
	match _Switch:
		true:
			if not GameLogic.LoadingUI.IsLevel:
				CardNode.hide()
			else:

				CardNode.show()
				CardNode.call_init()
		false:
			CardNode.hide()
func call_esc_logic():

	if not GameLogic.DEMO_bool:
		$VBoxContainer / WishList.hide()
	else:
		$VBoxContainer / WishList.show()

	if not EscAni.assigned_animation in ["show", "TutorialOff", "optionoff", "CardOff"]:
		_paused = true

		EscAni.play("show")
		if is_instance_valid(GameLogic.player_1P):
			GameLogic.player_1P.call_SetPause(true)
		if GameLogic.Player2_bool:
			if is_instance_valid(GameLogic.player_2P):
				GameLogic.player_2P.call_SetPause(true)
		$VBoxContainer / ExitButton / Label.hide()
		if GameLogic.cur_level != "":
			if GameLogic.Save.levelData.has("cur_Devil"):
				if GameLogic.Save.levelData.cur_Devil > 1:
					$VBoxContainer / ExitButton / Label.show()
		Choose_Init()
		cur_UI = UI.MAIN
		call_CardNode(true)
		GameLogic.GameUI.call_PanelAni(true)
		if not SteamLogic.IsMultiplay:
			get_tree().set_pause(true)


		if not GameLogic.cur_level:
			GiveUpButton.hide()

			CheckCardsBut.hide()

		else:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				GiveUpButton.hide()

			else:
				if get_tree().get_root().has_node("1_4"):
					GiveUpButton.hide()
				else:
					GiveUpButton.show()



		if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.connect("P1_Control", self, "_control_logic")

		if GameLogic.player_2P:

			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.connect("P2_Control", self, "_control_logic")
	elif EscAni.assigned_animation in ["show", "TutorialOff", "optionoff", "CardOff"]:
		_paused = false
		GameLogic.GameUI.cur_paused = false
		EscAni.play("hide")
		GameLogic.GameUI.call_PanelAni(false)

		get_tree().set_pause(false)

		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if GameLogic.player_2P:

			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
		GameLogic.GameUI.call_esc(0)
		GameLogic.call_SYNC()
func call_ESC_hide():
	if EscAni.assigned_animation in ["show", "TutorialOff", "optionoff", "CardOff"]:
		EscAni.play("hide")
		GameLogic.GameUI.call_PanelAni(false)
		_paused = false
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.player_2P:
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.call_pause(false)
func call_ESC_Logic():
	GameLogic.Can_ESC = true
func _control_logic(_but, _value, _type):

	if not self.visible:
		return

	if _value < 1 and _value > - 1:
		cur_pressed = false
	match _but:
		"START", "B":

			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true
					match cur_UI:
						UI.GIVEUPSECOND, UI.EXITSECOND:
							_on_SecondBack_pressed()
							GameLogic.Audio.But_Back.play(0)
						UI.MAIN:
							call_esc_logic()
							GameLogic.Audio.But_Back.play(0)
						UI.CARD:
							EscAni.play("CardOff")
							call_CardNode(true)
							cur_UI = UI.MAIN
							GameLogic.Audio.But_Back.play(0)

						UI.TUTORIAL:
							EscAni.play("TutorialOff")
							call_CardNode(true)
							cur_UI = UI.MAIN
							TutorialNode.call_info_init()
							GameLogic.Audio.But_Back.play(0)


		"A":
			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true
					match cur_UI:
						UI.EXITSECOND:
							_on_Exit_pressed()
							return
						UI.GIVEUPSECOND:
							_on_GiveUp_pressed()
							return
						UI.TUTORIAL:
							TutorialNode._on_ApplyBut_pressed()
							return
						UI.CARD:
							return
						UI.KEYSETTING:


							return
					var _input = InputEventAction.new()
					_input.action = "ui_accept"
					if _value == 1:
						_input.pressed = true
						Input.parse_input_event(_input)
						cur_pressed = true

		"U", "u":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					cur_pressed = true

					match cur_UI:
						UI.MAIN:
							if not CardNode.call_up():
								var _input = InputEventAction.new()
								_input.action = "ui_up"
								_input.pressed = true
								cur_pressed = true
								Input.parse_input_event(_input)
						UI.CARD:
							CardNode.call_up()
						UI.KEYSETTING:
							return
						_:
							var _input = InputEventAction.new()
							_input.action = "ui_up"
							_input.pressed = true
							cur_pressed = true
							Input.parse_input_event(_input)
		"D", "d":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					cur_pressed = true

					match cur_UI:
						UI.MAIN:
							if not CardNode.call_down():
								var _input = InputEventAction.new()
								_input.action = "ui_down"
								_input.pressed = true
								cur_pressed = true
								Input.parse_input_event(_input)
								yield(get_tree().create_timer(0.1), "timeout")
								if ResumeBut.has_focus():
									CardNode.call_release_focus()
						UI.CARD:
							CardNode.call_down()
						UI.KEYSETTING:
							return
						_:
							var _input = InputEventAction.new()
							_input.action = "ui_down"
							_input.pressed = true
							cur_pressed = true
							Input.parse_input_event(_input)
							yield(get_tree().create_timer(0.1), "timeout")
							if ResumeBut.has_focus():
								CardNode.call_release_focus()

		"L", "l":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			match cur_UI:
				UI.KEYSETTING:
					return

			cur_pressed = true
			var _input = InputEventAction.new()
			_input.action = "ui_left"
			_input.pressed = true
			Input.parse_input_event(_input)
		"R", "r":
			if _value != 1 and _value != - 1:
				cur_pressed = false
				return
			if cur_pressed:
				return
			match cur_UI:
				UI.KEYSETTING:
					return
			cur_pressed = true
			var _input = InputEventAction.new()
			_input.action = "ui_right"
			_input.pressed = true
			Input.parse_input_event(_input)
	if _type == 0:
		cur_pressed = false
func _on_SecondBack_pressed():
	if cur_UI in [UI.GIVEUPSECOND, UI.EXITSECOND]:
		cur_UI = UI.MAIN
	$VBoxContainer / GiveUpButton / Second / AnimationPlayer.play("init")
	$VBoxContainer / ExitButton / Second / AnimationPlayer.play("init")
func _on_GiveUp_pressed():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.cur_level:
		return
	_paused = false
	GameLogic.Can_ESC = false
	GameLogic.Can_Card = false
	GameLogic.GameOverType = 3

	EscAni.play("init")
	GameLogic.call_SYNC()
	if not GameLogic.InHome_Bool:
		GameLogic.call_save()
		GameLogic.call_dayover()
	if not SteamLogic.STEAM_BOOL:
		return
	var _SetLevel = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Level", "")
	var _SetDevil = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Devil", "")
	var _SetDay = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Day", "0")
func _on_GiveUpButton_pressed() -> void :

	$VBoxContainer / GiveUpButton / Second / AnimationPlayer.play("show")

func call_puppet_GiveUp(_cur_levelInfo):
	GameLogic.cur_levelInfo = _cur_levelInfo
	GameLogic.GameOverType = 3
	GameLogic.call_SYNC()
	if not GameLogic.InHome_Bool:
		GameLogic.call_dayover()
func Tutorial_grab_focus():
	TutorialNode.grab_focus()

func _on_CheckCardsBut_pressed() -> void :
	cur_UI = UI.CARD
	get_node("Cards").call_init()
	EscAni.play("CardShow")

func _on_TutorialBut_pressed() -> void :
	cur_UI = UI.TUTORIAL
	EscAni.play("Tutorial")
func _on_TutorialBack_pressed() -> void :
	EscAni.play("TutorialOff")

func _on_ResumeBut_focus_entered():
	CardNode.call_ShowInfo_Hide()

func _on_WishList_pressed():
	if Steam.loggedOn():

		Steam.activateGameOverlayToStore(2336220)

	else:

		var _RETURN = OS.shell_open("https://store.steampowered.com/app/2336220/")

func call_GiveUpSecond():
	cur_UI = UI.GIVEUPSECOND

func call_ExitSecond():
	cur_UI = UI.EXITSECOND
func _on_Reset_pressed():
	var _POS
	var _POS_2
	if GameLogic.LoadingUI.IsHome:
		if get_tree().get_root().has_node("Home"):
			_POS = get_tree().get_root().get_node("Home/PlayerPos2D/1").position
			_POS_2 = get_tree().get_root().get_node("Home/PlayerPos2D/2").position
	elif GameLogic.LoadingUI.IsLevel:
		if get_tree().get_root().has_node("Level"):
			_POS = get_tree().get_root().get_node("Level/PlayerPos2D/1").position
			_POS_2 = get_tree().get_root().get_node("Level/PlayerPos2D/2").position
	else:
		return

	var _x = GameLogic.player_1P.Con.state
	if not GameLogic.player_1P.Con.state in [25, 26, 27]:
		GameLogic.player_1P.call_reset_Pos(_POS)

	if GameLogic.Player2_bool:
		if is_instance_valid(GameLogic.player_2P):
			if not GameLogic.player_2P.Con.state in [25, 26, 27]:

				GameLogic.player_2P.call_reset_Pos(_POS_2)

func Choose_Init():

	var _HBox = $HBox
	for _Node in _HBox.get_children():
		_HBox.remove_child(_Node)
		_Node.queue_free()
	if GameLogic.LoadingUI.IsHome:
		return
	if GameLogic.cur_levelInfo.has("DevilList"):
		var _DEVILLIST = GameLogic.cur_levelInfo.DevilList
		var Devil_Max = _DEVILLIST.size()

		if Devil_Max > GameLogic.cur_Devil:
			Devil_Max = GameLogic.cur_Devil
		for i in Devil_Max:
			var _DevilIcon = GameLogic.TSCNLoad.DevilIcon_TSCN.instance()
			_DevilIcon.name = str(i)
			_HBox.add_child(_DevilIcon)
			_HBox.move_child(_DevilIcon, 0)
			_DevilIcon.call_type(i)

			if i >= 0 and _DEVILLIST.size() > (i):

				_DevilIcon.call_Str(_DEVILLIST[i])
			_DevilIcon.get_node("Ani").play("select")
