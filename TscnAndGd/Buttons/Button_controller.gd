extends Control

export var ZINDEX: int = 1
var playerList: Array
var cur_But: String
export var ButSetting: bool
export var ButPlayer: int
export var KeyBoard: bool
export var IsKeyBoard: bool
export var bool_Hold: bool
export var bool_Small: bool
export var bool_Static: bool
export var BUT: int
export var BUT_TYPE: int
export var RE: int
export var Info_Str: String
export var Info_1: String
export var Info_2: String
export var OnBut: bool = true
export var TopInfo: String
signal HoldFinish()

onready var ShowAni = get_node("ShowEnd")
onready var ButTypeAni = get_node("ButtonType")
onready var IdleAni = get_node("Idle")
onready var InfoLabel = get_node("Texture/Button/InfoLabel")
onready var Key_Label = get_node("Texture/Key")
onready var DisabledAni = get_node("DisabledAni")
onready var TopLabel = get_node("Texture/TopLabel")
func call_OutLine(_Switch: bool):

	match _Switch:
		true:
			if has_node("OutLineAni"):
				get_node("OutLineAni").play("show")
		false:
			if has_node("OutLineAni"):
				get_node("OutLineAni").play("init")

func _ready() -> void :
	if not cur_But:
		cur_But = self.name
	if not GameLogic.is_connected("OPTIONSYNC", self, "_Tr_Set"):
		var _con = GameLogic.connect("OPTIONSYNC", self, "_Tr_Set")
	call_deferred("call_init")
	get_node("Texture").z_index = ZINDEX

func _Tr_Set():
	call_init()
	InfoLabel.text = GameLogic.CardTrans.get_message(Info_Str)
	call_Button_Show()
	call_waiting(false)
func _Conncet():
	if ButSetting:
		pass
	if not ButSetting:
		if not GameLogic.Con.is_connected("P1_Control", self, "_But_Show_1P"):
			GameLogic.Con.connect("P1_Control", self, "_But_Show_1P")
		if not GameLogic.Con.is_connected("P2_Control", self, "_But_Show_2P"):
			GameLogic.Con.connect("P2_Control", self, "_But_Show_2P")

func _But_Show_1P(_But, _value, _type):
	if not is_visible_in_tree():
		return
	if IsKeyBoard and GameLogic.Con.player1P_IsJoy:
		show_logic(1)
	elif not IsKeyBoard and not GameLogic.Con.player1P_IsJoy:
		show_logic(1)
func _But_Show_2P(_But, _value, _type):
	if not is_visible_in_tree():
		return
	if IsKeyBoard and GameLogic.Con.player2P_IsJoy:
		show_logic(2)
	elif not IsKeyBoard and not GameLogic.Con.player2P_IsJoy:
		show_logic(2)

func call_disabled(_bool):
	match _bool:
		true:
			DisabledAni.play("disabled")
			GameLogic.Audio.But_Hold.stop()
		false:
			DisabledAni.play("init")
			GameLogic.Audio.But_Hold.stop()

func call_init():

	if TopInfo:
		TopLabel.call_Tr_TEXT(TopInfo)
		TopLabel.show()
	else:
		TopLabel.hide()

	if bool_Hold:
		if bool_Static:
			ShowAni.play("Hold_Init")
	else:
		if bool_Static:
			ShowAni.play("Press_Init")
		else:
			ShowAni.play("init")
			GameLogic.Audio.But_Hold.stop()
	if OnBut:
		if not get_parent().visible:
			self.hide()
		else:
			self.show()
	if Info_Str:
		InfoLabel.text = GameLogic.CardTrans.get_message(Info_Str)
		InfoLabel.show()
	else:
		InfoLabel.hide()
	_Conncet()

	show_logic(0)

func call_clean():

	for i in playerList:

		call_player_out(i)
func call_player_in(_playerID):

	if not _playerID in [1, 2, SteamLogic.STEAM_ID]:
		return

	if not playerList.has(_playerID):
		playerList.append(_playerID)

	if _playerID in [1, SteamLogic.STEAM_ID]:
		show_logic(1)
	elif _playerID in [2]:
		show_logic(2)
	call_show()
func call_player_out(_playerID):

	if playerList.has(_playerID):
		playerList.erase(_playerID)
		call_hide()
func call_player_hide(_playerID):

	if playerList.has(_playerID):
		playerList.erase(_playerID)
		_hide_init()
func call_show():

	if playerList.size() == 1:
		if bool_Hold:
			if not bool_Static:
				ShowAni.play("Hold_Show")
		else:
			if not bool_Static:
				ShowAni.play("Press_Show")

func call_hide():

	if not playerList.size():
		if bool_Hold:
			if not bool_Static:
				ShowAni.play_backwards("Hold_Show")
				GameLogic.Audio.But_Hold.stop()
		else:
			if not bool_Static:
				ShowAni.play_backwards("Press_Show")
				GameLogic.Audio.But_Hold.stop()

func _hide_init():

	if not playerList.size():
		if bool_Hold:
			if not bool_Static:
				ShowAni.play("init")
				GameLogic.Audio.But_Hold.stop()
		else:
			if not bool_Static:
				ShowAni.play("init")
				GameLogic.Audio.But_Hold.stop()
func call_holding(_pressed):

	match _pressed:
		true:
			if ShowAni.assigned_animation != "Hold_holding" and ShowAni.assigned_animation != "Hold_end":
				ShowAni.play("Hold_holding")

		false:
			if ShowAni.assigned_animation in ["Hold_holding", "Hold_end"]:
				ShowAni.play("Hold_Init")

func call_holdfinished():
	ShowAni.play("Hold_end")

	emit_signal("HoldFinish")

func show_player(_PlayerID: int):

	playerList.clear()
	playerList.append(_PlayerID)
	show_logic(0)
func show_logic(_PlayerID: int):

	if ButSetting:

		match ButPlayer:
			1, SteamLogic.STEAM_ID:
				if IsKeyBoard:
					call_but_set(false, ButPlayer)
					call_Button_Show()
				else:
					call_but_set(true, ButPlayer)
					call_Button_Show()
			2:

				if IsKeyBoard:
					call_but_set(false, ButPlayer)
					call_Button_Show()
				else:
					call_but_set(true, ButPlayer)
					call_Button_Show()
		return

	if ButPlayer:
		match ButPlayer:
			1, SteamLogic.STEAM_ID:
				if GameLogic.Con.player1P_Keyboard and not GameLogic.Con.player1P_IsJoy:
					IsKeyBoard = true
					call_but_set(false, ButPlayer)
					call_Button_Show()
				elif GameLogic.Con.player1P_Joy > - 1:

					IsKeyBoard = false
					call_but_set(true, ButPlayer)

					call_Button_Show()

			2:

				if KeyBoard:
					IsKeyBoard = true
					call_but_set(false, ButPlayer)
					call_Button_Show()
					return
				else:
					if GameLogic.Con.player2P_Keyboard and not GameLogic.Con.player2P_IsJoy:
						IsKeyBoard = true
						call_but_set(false, ButPlayer)
						call_Button_Show()
					elif GameLogic.Con.player2P_Joy > - 1:
						IsKeyBoard = false
						call_but_set(true, ButPlayer)

						call_Button_Show()

		return
	if playerList.size():

		var _ID = playerList.front()
		match _ID:
			1, SteamLogic.STEAM_ID:

				if GameLogic.Con.player1P_Keyboard and not GameLogic.Con.player1P_IsJoy:

					IsKeyBoard = true
					call_but_set(false, _ID)
					call_Button_Show()
				elif GameLogic.Con.player1P_Joy > - 1:

					IsKeyBoard = false
					call_but_set(true, _ID)

					call_Button_Show()

			2:

				if GameLogic.Con.player2P_Keyboard and not GameLogic.Con.player2P_IsJoy:
					IsKeyBoard = true
					call_but_set(false, _ID)
					call_Button_Show()
				elif GameLogic.Con.player2P_Joy > - 1:
					IsKeyBoard = false
					call_but_set(true, _ID)

					call_Button_Show()

	else:
		match _PlayerID:
			0, 1, SteamLogic.STEAM_ID:
				if GameLogic.Con.player1P_Keyboard and not GameLogic.Con.player1P_IsJoy:
					IsKeyBoard = true
					call_but_set(false, 1)
					call_Button_Show()
				elif GameLogic.Con.player1P_Joy > - 1:
					IsKeyBoard = false
					call_but_set(true, 1)
					var _CHECK = GameLogic.Con.player1P_Joy

					call_Button_Show()
			2:
				if GameLogic.Con.player2P_Keyboard and not GameLogic.Con.player2P_IsJoy:
					IsKeyBoard = true
					call_but_set(false, 2)
					call_Button_Show()
				elif GameLogic.Con.player2P_Joy > - 1:
					IsKeyBoard = false
					call_but_set(true, 2)

					call_Button_Show()

func call_but_set(_Joy_bool, _ID):



	match cur_But:
		"A":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_A"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_A"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_A"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_A"].RE

			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_A"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_A"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_A"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_A"].RE
		"B":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_B"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_B"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_B"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_B"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_B"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_B"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_B"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_B"].RE
		"X":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_X"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_X"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_X"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_X"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_X"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_X"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_X"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_X"].RE

		"Y":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_Y"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_Y"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_Y"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_Y"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_Y"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_Y"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_Y"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_Y"].RE
		"L1":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_L1"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_L1"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_L1"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_L1"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_L1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_L1"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_L1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_L1"].RE

		"R1":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_R1"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_R1"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_R1"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_R1"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_R1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_R1"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_R1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_R1"].RE

		"L2":
			if bool_Small:
				pass
			else:
				ButTypeAni.play("LT")
		"R2":
			if bool_Small:
				pass
			else:
				ButTypeAni.play("RT")
		"UP":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_up"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_up"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_up"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_up"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_up"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_up"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_up"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_up"].RE
		"DOWN":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_down"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_down"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_down"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_down"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_down"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_down"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_down"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_down"].RE
		"LEFT", "L":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_left"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_left"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_left"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_left"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_left"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_left"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_left"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_left"].RE
		"RIGHT", "R":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_right"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_right"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_right"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_right"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_right"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_right"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_right"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_right"].RE
		"START":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_Start"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_Start"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_Start"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_Start"].RE

			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_Start"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_Start"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_Start"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_Start"].RE
func call_Button_Show(_CONTROLTYPE: int = 0):


	call_waiting(false)
	$Texture / Little.hide()
	if IsKeyBoard:

		match BUT:
			KEY_ESCAPE:
				ButTypeAni.play("Esc")
				Key_Label.hide()
			KEY_TAB:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Tab"
				Key_Label.show()
			KEY_BACKTAB:
				ButTypeAni.play("Key_L")
				Key_Label.text = "B-T"
				Key_Label.show()
			KEY_BACKSPACE:
				ButTypeAni.play("Backspace")
				Key_Label.hide()
			KEY_ENTER:
				ButTypeAni.play("Enter")
				Key_Label.hide()
			KEY_KP_ENTER:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Ent"
				Key_Label.show()
				$Texture / Little.show()
			KEY_INSERT:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Ins"
				Key_Label.show()
			KEY_DELETE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Del"
				Key_Label.show()
			KEY_PAUSE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Pau"
				Key_Label.show()
			KEY_PRINT:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Pri"
				Key_Label.show()
			KEY_SYSREQ:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Sys"
				Key_Label.show()
			KEY_CLEAR:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Cle"
				Key_Label.show()
			KEY_HOME:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Hom"
				Key_Label.show()
			KEY_END:
				ButTypeAni.play("Key_L")
				Key_Label.text = "End"
				Key_Label.show()
			KEY_LEFT:
				ButTypeAni.play("Key")
				Key_Label.text = "←"
				Key_Label.show()
			KEY_UP:
				ButTypeAni.play("Key")
				Key_Label.text = "↑"
				Key_Label.show()
			KEY_RIGHT:
				ButTypeAni.play("Key")
				Key_Label.text = "→"
				Key_Label.show()
			KEY_DOWN:
				ButTypeAni.play("Key")
				Key_Label.text = "↓"
				Key_Label.show()
			KEY_PAGEUP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Pg Up"
				Key_Label.show()
			KEY_PAGEDOWN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Pg Dn"
				Key_Label.show()
			KEY_SHIFT:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Shift"
				Key_Label.show()
			KEY_CONTROL:
				ButTypeAni.play("Ctrl")
				Key_Label.hide()
			KEY_META:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Meta"
				Key_Label.show()
			KEY_ALT:
				ButTypeAni.play("Alt")
				Key_Label.hide()
			KEY_CAPSLOCK:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Caps"
				Key_Label.show()
			KEY_NUMLOCK:
				ButTypeAni.play("Key_L")
				Key_Label.text = "NumL"
				Key_Label.show()
			KEY_SCROLLLOCK:
				ButTypeAni.play("Key_L")
				Key_Label.text = "ScrL"
				Key_Label.show()
			KEY_F1:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F1"
				Key_Label.show()
			KEY_F2:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F2"
				Key_Label.show()
			KEY_F3:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F3"
				Key_Label.show()
			KEY_F4:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F4"
				Key_Label.show()
			KEY_F5:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F5"
				Key_Label.show()
			KEY_F6:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F6"
				Key_Label.show()
			KEY_F7:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F7"
				Key_Label.show()
			KEY_F8:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F8"
				Key_Label.show()
			KEY_F9:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F9"
				Key_Label.show()
			KEY_F10:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F10"
				Key_Label.show()
			KEY_F11:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F11"
				Key_Label.show()
			KEY_F12:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F12"
				Key_Label.show()
			KEY_F13:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F13"
				Key_Label.show()
			KEY_F14:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F14"
				Key_Label.show()
			KEY_F15:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F15"
				Key_Label.show()
			KEY_F16:
				ButTypeAni.play("Key_L")
				Key_Label.text = "F16"
				Key_Label.show()
			KEY_KP_MULTIPLY:
				ButTypeAni.play("Key")
				Key_Label.text = "*"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_DIVIDE:
				ButTypeAni.play("Key")
				Key_Label.text = "/"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_SUBTRACT:
				ButTypeAni.play("Key")
				Key_Label.text = "-"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_PERIOD:
				ButTypeAni.play("Key")
				Key_Label.text = "."
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_ADD:
				ButTypeAni.play("Key")
				Key_Label.text = "+"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_0:
				ButTypeAni.play("Key")
				Key_Label.text = "0"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_1:
				ButTypeAni.play("Key")
				Key_Label.text = "1"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_2:
				ButTypeAni.play("Key")
				Key_Label.text = "2"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_3:
				ButTypeAni.play("Key")
				Key_Label.text = "3"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_4:
				ButTypeAni.play("Key")
				Key_Label.text = "4"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_5:
				ButTypeAni.play("Key")
				Key_Label.text = "5"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_6:
				ButTypeAni.play("Key")
				Key_Label.text = "6"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_7:
				ButTypeAni.play("Key")
				Key_Label.text = "7"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_8:
				ButTypeAni.play("Key")
				Key_Label.text = "8"
				Key_Label.show()
				$Texture / Little.show()
			KEY_KP_9:
				ButTypeAni.play("Key")
				Key_Label.text = "9"
				Key_Label.show()
				$Texture / Little.show()
			KEY_SUPER_L:
				ButTypeAni.play("Key_L")
				Key_Label.text = "SupL"
				Key_Label.show()
			KEY_SUPER_R:
				ButTypeAni.play("Key_L")
				Key_Label.text = "SupR"
				Key_Label.show()
			KEY_MENU:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Menu"
				Key_Label.show()
			KEY_HYPER_L:
				ButTypeAni.play("Key_L")
				Key_Label.text = "HypL"
				Key_Label.show()
			KEY_HYPER_R:
				ButTypeAni.play("Key_L")
				Key_Label.text = "HypR"
				Key_Label.show()
			KEY_HELP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "help"
				Key_Label.show()
			KEY_DIRECTION_L:
				ButTypeAni.play("Key_L")
				Key_Label.text = "DirL"
				Key_Label.show()
			KEY_DIRECTION_R:
				ButTypeAni.play("Key_L")
				Key_Label.text = "DirR"
				Key_Label.show()
			KEY_BACK:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Back"
				Key_Label.show()
			KEY_FORWARD:
				ButTypeAni.play("Key_L")
				Key_Label.text = "ForW"
				Key_Label.show()
			KEY_STOP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Stop"
				Key_Label.show()
			KEY_REFRESH:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Ref"
				Key_Label.show()
			KEY_VOLUMEDOWN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "VolD"
				Key_Label.show()
			KEY_VOLUMEMUTE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "VolM"
				Key_Label.show()
			KEY_VOLUMEUP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "VolU"
				Key_Label.show()
			KEY_BASSBOOST:
				ButTypeAni.play("Key_L")
				Key_Label.text = "BasB"
				Key_Label.show()
			KEY_BASSUP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "BasU"
				Key_Label.show()
			KEY_BASSDOWN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "BasD"
				Key_Label.show()
			KEY_TREBLEUP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "TreU"
				Key_Label.show()
			KEY_TREBLEDOWN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "TreD"
				Key_Label.show()
			KEY_MEDIAPLAY:
				ButTypeAni.play("Key_L")
				Key_Label.text = "MedP"
				Key_Label.show()
			KEY_MEDIASTOP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "MedS"
				Key_Label.show()
			KEY_MEDIAPREVIOUS:
				ButTypeAni.play("Key_L")
				Key_Label.text = "MedPr"
				Key_Label.show()
			KEY_MEDIANEXT:
				ButTypeAni.play("Key_L")
				Key_Label.text = "MedN"
				Key_Label.show()
			KEY_MEDIARECORD:
				ButTypeAni.play("Key_L")
				Key_Label.text = "MedRe"
				Key_Label.show()
			KEY_HOMEPAGE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Ho Pa"
				Key_Label.show()
			KEY_FAVORITES:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Fav"
				Key_Label.show()
			KEY_SEARCH:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Sear"
				Key_Label.show()
			KEY_STANDBY:
				ButTypeAni.play("Key_L")
				Key_Label.text = "St By"
				Key_Label.show()
			KEY_OPENURL:
				ButTypeAni.play("Key_L")
				Key_Label.text = "URL"
				Key_Label.show()
			KEY_LAUNCHMAIL:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La Ma"
				Key_Label.show()
			KEY_LAUNCHMEDIA:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La Me"
				Key_Label.show()
			KEY_LAUNCH0:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 0"
				Key_Label.show()
			KEY_LAUNCH1:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 1"
				Key_Label.show()
			KEY_LAUNCH2:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 2"
				Key_Label.show()
			KEY_LAUNCH3:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 3"
				Key_Label.show()
			KEY_LAUNCH4:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 4"
				Key_Label.show()
			KEY_LAUNCH5:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 5"
				Key_Label.show()
			KEY_LAUNCH6:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 6"
				Key_Label.show()
			KEY_LAUNCH7:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 7"
				Key_Label.show()
			KEY_LAUNCH8:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 8"
				Key_Label.show()
			KEY_LAUNCH9:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La 9"
				Key_Label.show()
			KEY_LAUNCHA:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La A"
				Key_Label.show()
			KEY_LAUNCHB:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La B"
				Key_Label.show()
			KEY_LAUNCHC:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La C"
				Key_Label.show()
			KEY_LAUNCHD:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La D"
				Key_Label.show()
			KEY_LAUNCHE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La E"
				Key_Label.show()
			KEY_LAUNCHF:
				ButTypeAni.play("Key_L")
				Key_Label.text = "La F"
				Key_Label.show()
			KEY_UNKNOWN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Unknown"
				Key_Label.show()
			KEY_SPACE:
				ButTypeAni.play("Space")
				Key_Label.hide()
			KEY_EXCLAM:
				ButTypeAni.play("Key")
				Key_Label.text = "!"
				Key_Label.show()
			KEY_QUOTEDBL:
				ButTypeAni.play("Key")
				Key_Label.text = "”"
				Key_Label.show()
			KEY_NUMBERSIGN:
				ButTypeAni.play("Key")
				Key_Label.text = "#"
				Key_Label.show()
			KEY_DOLLAR:
				ButTypeAni.play("Key")
				Key_Label.text = "$"
				Key_Label.show()
			KEY_PERCENT:
				ButTypeAni.play("Key")
				Key_Label.text = "%"
				Key_Label.show()
			KEY_AMPERSAND:
				ButTypeAni.play("Key")
				Key_Label.text = "&"
				Key_Label.show()
			KEY_APOSTROPHE:
				ButTypeAni.play("Key")
				Key_Label.text = "'"
				Key_Label.show()
			KEY_PARENLEFT:
				ButTypeAni.play("Key")
				Key_Label.text = "("
				Key_Label.show()
			KEY_PARENRIGHT:
				ButTypeAni.play("Key")
				Key_Label.text = ")"
				Key_Label.show()
			KEY_ASTERISK:
				ButTypeAni.play("Key")
				Key_Label.text = "*"
				Key_Label.show()
			KEY_PLUS:
				ButTypeAni.play("Key")
				Key_Label.text = "+"
				Key_Label.show()
			KEY_COMMA:
				ButTypeAni.play("Key")
				Key_Label.text = ","
				Key_Label.show()
			KEY_MINUS:
				ButTypeAni.play("Key")
				Key_Label.text = "-"
				Key_Label.show()
			KEY_PERIOD:
				ButTypeAni.play("Key")
				Key_Label.text = "."
				Key_Label.show()
			KEY_SLASH:
				ButTypeAni.play("Key")
				Key_Label.text = "/"
				Key_Label.show()
			KEY_0:
				ButTypeAni.play("Key")
				Key_Label.text = "0"
				Key_Label.show()
			KEY_1:
				ButTypeAni.play("Key")
				Key_Label.text = "1"
				Key_Label.show()
			KEY_2:
				ButTypeAni.play("Key")
				Key_Label.text = "2"
				Key_Label.show()
			KEY_3:
				ButTypeAni.play("Key")
				Key_Label.text = "3"
				Key_Label.show()
			KEY_4:
				ButTypeAni.play("Key")
				Key_Label.text = "4"
				Key_Label.show()
			KEY_5:
				ButTypeAni.play("Key")
				Key_Label.text = "5"
				Key_Label.show()
			KEY_6:
				ButTypeAni.play("Key")
				Key_Label.text = "6"
				Key_Label.show()
			KEY_7:
				ButTypeAni.play("Key")
				Key_Label.text = "7"
				Key_Label.show()
			KEY_8:
				ButTypeAni.play("Key")
				Key_Label.text = "8"
				Key_Label.show()
			KEY_9:
				ButTypeAni.play("Key")
				Key_Label.text = "9"
				Key_Label.show()
			KEY_COLON:
				ButTypeAni.play("Key")
				Key_Label.text = ":"
				Key_Label.show()
			KEY_SEMICOLON:
				ButTypeAni.play("Key")
				Key_Label.text = ";"
				Key_Label.show()
			KEY_LESS:
				ButTypeAni.play("Key")
				Key_Label.text = "<"
				Key_Label.show()
			KEY_EQUAL:
				ButTypeAni.play("Key")
				Key_Label.text = "="
				Key_Label.show()
			KEY_GREATER:
				ButTypeAni.play("Key")
				Key_Label.text = ">"
				Key_Label.show()
			KEY_QUESTION:
				ButTypeAni.play("Key_L")
				Key_Label.text = "QUEST"
				Key_Label.show()
			KEY_AT:
				ButTypeAni.play("Key")
				Key_Label.text = "@"
				Key_Label.show()
			KEY_A:
				ButTypeAni.play("Key")
				Key_Label.text = "A"
				Key_Label.show()
			KEY_B:
				ButTypeAni.play("Key")
				Key_Label.text = "B"
				Key_Label.show()
			KEY_C:
				ButTypeAni.play("Key")
				Key_Label.text = "C"
				Key_Label.show()
			KEY_D:
				ButTypeAni.play("Key")
				Key_Label.text = "D"
				Key_Label.show()
			KEY_E:
				ButTypeAni.play("Key")
				Key_Label.text = "E"
				Key_Label.show()
			KEY_F:
				ButTypeAni.play("Key")
				Key_Label.text = "F"
				Key_Label.show()
			KEY_G:
				ButTypeAni.play("Key")
				Key_Label.text = "G"
				Key_Label.show()
			KEY_H:
				ButTypeAni.play("Key")
				Key_Label.text = "H"
				Key_Label.show()
			KEY_I:
				ButTypeAni.play("Key")
				Key_Label.text = "I"
				Key_Label.show()
			KEY_J:
				ButTypeAni.play("Key")
				Key_Label.text = "J"
				Key_Label.show()
			KEY_K:
				ButTypeAni.play("Key")
				Key_Label.text = "K"
				Key_Label.show()
			KEY_L:
				ButTypeAni.play("Key")
				Key_Label.text = "L"
				Key_Label.show()
			KEY_M:
				ButTypeAni.play("Key")
				Key_Label.text = "M"
				Key_Label.show()
			KEY_N:
				ButTypeAni.play("Key")
				Key_Label.text = "N"
				Key_Label.show()
			KEY_O:
				ButTypeAni.play("Key")
				Key_Label.text = "O"
				Key_Label.show()
			KEY_P:
				ButTypeAni.play("Key")
				Key_Label.text = "P"
				Key_Label.show()
			KEY_Q:
				ButTypeAni.play("Key")
				Key_Label.text = "Q"
				Key_Label.show()
			KEY_R:
				ButTypeAni.play("Key")
				Key_Label.text = "R"
				Key_Label.show()
			KEY_S:
				ButTypeAni.play("Key")
				Key_Label.text = "S"
				Key_Label.show()
			KEY_T:
				ButTypeAni.play("Key")
				Key_Label.text = "T"
				Key_Label.show()
			KEY_U:
				ButTypeAni.play("Key")
				Key_Label.text = "U"
				Key_Label.show()
			KEY_V:
				ButTypeAni.play("Key")
				Key_Label.text = "V"
				Key_Label.show()
			KEY_W:
				ButTypeAni.play("Key")
				Key_Label.text = "W"
				Key_Label.show()
			KEY_X:
				ButTypeAni.play("Key")
				Key_Label.text = "X"
				Key_Label.show()
			KEY_Y:
				ButTypeAni.play("Key")
				Key_Label.text = "Y"
				Key_Label.show()
			KEY_Z:
				ButTypeAni.play("Key")
				Key_Label.text = "Z"
				Key_Label.show()
			KEY_BRACKETLEFT:
				ButTypeAni.play("Key")
				Key_Label.text = "["
				Key_Label.show()
			KEY_BACKSLASH:
				ButTypeAni.play("Key")
				Key_Label.text = "|"
				Key_Label.show()
			KEY_BRACKETRIGHT:
				ButTypeAni.play("Key")
				Key_Label.text = "]"
				Key_Label.show()
			KEY_ASCIICIRCUM:
				ButTypeAni.play("Key")
				Key_Label.text = "^"
				Key_Label.show()
			KEY_UNDERSCORE:
				ButTypeAni.play("Key")
				Key_Label.text = "_"
				Key_Label.show()
			KEY_QUOTELEFT:
				ButTypeAni.play("Key")
				Key_Label.text = "`"
				Key_Label.show()
			KEY_BRACELEFT:
				ButTypeAni.play("Key")
				Key_Label.text = "{"
				Key_Label.show()
			KEY_BAR:
				ButTypeAni.play("Key")
				Key_Label.text = "|"
				Key_Label.show()
			KEY_BRACERIGHT:
				ButTypeAni.play("Key")
				Key_Label.text = "}"
				Key_Label.show()
			KEY_ASCIITILDE:
				ButTypeAni.play("Key")
				Key_Label.text = "~"
				Key_Label.show()
			KEY_NOBREAKSPACE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "NBS"
				Key_Label.show()
			KEY_EXCLAMDOWN:
				ButTypeAni.play("Key")
				Key_Label.text = "?"
				Key_Label.show()
			KEY_CENT:
				ButTypeAni.play("Key")
				Key_Label.text = "￠"
				Key_Label.show()
			KEY_STERLING:
				ButTypeAni.play("Key")
				Key_Label.text = "￡"
				Key_Label.show()
			KEY_CURRENCY:
				ButTypeAni.play("Key")
				Key_Label.text = "¤"
				Key_Label.show()
			KEY_YEN:
				ButTypeAni.play("Key")
				Key_Label.text = ""
				Key_Label.show()
			KEY_BROKENBAR:
				ButTypeAni.play("Key")
				Key_Label.text = "|"
				Key_Label.show()
			KEY_SECTION:
				ButTypeAni.play("Key")
				Key_Label.text = "§"
				Key_Label.show()
			KEY_DIAERESIS:
				ButTypeAni.play("Key")
				Key_Label.text = "¨"
				Key_Label.show()
			KEY_COPYRIGHT:
				ButTypeAni.play("Key")
				Key_Label.text = "?"
				Key_Label.show()
			KEY_ORDFEMININE:
				ButTypeAni.play("Key")
				Key_Label.text = "a"
				Key_Label.show()
			KEY_GUILLEMOTLEFT:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Guil"
				Key_Label.show()
			KEY_NOTSIGN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "NotS"
				Key_Label.show()
			KEY_HYPHEN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Hyph"
				Key_Label.show()
			KEY_REGISTERED:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Regi"
				Key_Label.show()
			KEY_MACRON:
				ButTypeAni.play("Key")
				Key_Label.text = "ˉ"
				Key_Label.show()
			KEY_DEGREE:
				ButTypeAni.play("Key")
				Key_Label.text = "°"
				Key_Label.show()
			KEY_PLUSMINUS:
				ButTypeAni.play("Key")
				Key_Label.text = "±"
				Key_Label.show()
			KEY_TWOSUPERIOR:
				ButTypeAni.play("Key")
				Key_Label.text = "2"
				Key_Label.show()
			KEY_THREESUPERIOR:
				ButTypeAni.play("Key")
				Key_Label.text = "3"
				Key_Label.show()
			KEY_ACUTE:
				ButTypeAni.play("Key")
				Key_Label.text = "′"
				Key_Label.show()
			KEY_MU:
				ButTypeAni.play("Key")
				Key_Label.text = "μ"
				Key_Label.show()
			KEY_PARAGRAPH:
				ButTypeAni.play("Key")
				Key_Label.text = "?"
				Key_Label.show()
			KEY_PERIODCENTERED:
				ButTypeAni.play("Key")
				Key_Label.text = "·"
				Key_Label.show()
			KEY_CEDILLA:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Cedi"
				Key_Label.show()
			KEY_ONESUPERIOR:
				ButTypeAni.play("Key")
				Key_Label.text = "1"
				Key_Label.show()
			KEY_MASCULINE:
				ButTypeAni.play("Key")
				Key_Label.text = "o"
				Key_Label.show()
			KEY_GUILLEMOTRIGHT:
				ButTypeAni.play("Key_L")
				Key_Label.text = "GUIR"
				Key_Label.show()
			KEY_ONEQUARTER:
				ButTypeAni.play("Key")
				Key_Label.text = "1Q"
				Key_Label.show()
			KEY_ONEHALF:
				ButTypeAni.play("Key")
				Key_Label.text = "1H"
				Key_Label.show()
			KEY_THREEQUARTERS:
				ButTypeAni.play("Key")
				Key_Label.text = "3Q"
				Key_Label.show()
			KEY_QUESTIONDOWN:
				ButTypeAni.play("Key")
				Key_Label.text = "QD"
				Key_Label.show()
			KEY_AGRAVE:
				ButTypeAni.play("Key")
				Key_Label.text = "à"
				Key_Label.show()
			KEY_AACUTE:
				ButTypeAni.play("Key")
				Key_Label.text = "á"
				Key_Label.show()
			KEY_ACIRCUMFLEX:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Acir"
				Key_Label.show()
			KEY_ATILDE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Ati"
				Key_Label.show()
			KEY_ADIAERESIS:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Adi"
				Key_Label.show()
			KEY_ARING:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Aring"
				Key_Label.show()
			KEY_AE:
				ButTypeAni.play("Key")
				Key_Label.text = "AE"
				Key_Label.show()
			KEY_CCEDILLA:
				ButTypeAni.play("Key_L")
				Key_Label.text = "CCED"
				Key_Label.show()
			KEY_EGRAVE:
				ButTypeAni.play("Key")
				Key_Label.text = "è"
				Key_Label.show()
			KEY_EACUTE:
				ButTypeAni.play("Key")
				Key_Label.text = "é"
				Key_Label.show()
			KEY_ECIRCUMFLEX:
				ButTypeAni.play("Key")
				Key_Label.text = "ê"
				Key_Label.show()
			KEY_EDIAERESIS:
				ButTypeAni.play("Key_L")
				Key_Label.text = "Edia"
				Key_Label.show()
			KEY_IGRAVE:
				ButTypeAni.play("Key")
				Key_Label.text = "ì"
				Key_Label.show()
			KEY_IACUTE:
				ButTypeAni.play("Key")
				Key_Label.text = "í"
				Key_Label.show()
			KEY_ICIRCUMFLEX:
				ButTypeAni.play("Key_L")
				Key_Label.text = "ICIR"
				Key_Label.show()
			KEY_IDIAERESIS:
				ButTypeAni.play("Key_L")
				Key_Label.text = "IDIA"
				Key_Label.show()
			KEY_ETH:
				ButTypeAni.play("Key_L")
				Key_Label.text = "ETH"
				Key_Label.show()
			KEY_NTILDE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "NTIL"
				Key_Label.show()
			KEY_OGRAVE:
				ButTypeAni.play("Key")
				Key_Label.text = "ò"
				Key_Label.show()
			KEY_OACUTE:
				ButTypeAni.play("Key")
				Key_Label.text = "ó"
				Key_Label.show()
			KEY_OCIRCUMFLEX:
				ButTypeAni.play("Key_L")
				Key_Label.text = "OCIR"
				Key_Label.show()
			KEY_OTILDE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "OTIL"
				Key_Label.show()
			KEY_ODIAERESIS:
				ButTypeAni.play("Key_L")
				Key_Label.text = "ODIA"
				Key_Label.show()
			KEY_MULTIPLY:
				ButTypeAni.play("Key_L")
				Key_Label.text = "MULT"
				Key_Label.show()
			KEY_OOBLIQUE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "OOBL"
				Key_Label.show()
			KEY_UGRAVE:
				ButTypeAni.play("Key")
				Key_Label.text = "ù"
				Key_Label.show()
			KEY_UACUTE:
				ButTypeAni.play("Key")
				Key_Label.text = "ú"
				Key_Label.show()
			KEY_UCIRCUMFLEX:
				ButTypeAni.play("Key_L")
				Key_Label.text = "UCIR"
				Key_Label.show()
			KEY_UDIAERESIS:
				ButTypeAni.play("Key")
				Key_Label.text = "ü"
				Key_Label.show()
			KEY_YACUTE:
				ButTypeAni.play("Key_L")
				Key_Label.text = "YACU"
				Key_Label.show()
			KEY_THORN:
				ButTypeAni.play("Key_L")
				Key_Label.text = "THOR"
				Key_Label.show()
			KEY_SSHARP:
				ButTypeAni.play("Key_L")
				Key_Label.text = "SSHA"
				Key_Label.show()
			KEY_DIVISION:
				ButTypeAni.play("Key_L")
				Key_Label.text = "DIVI"
				Key_Label.show()
			KEY_YDIAERESIS:
				ButTypeAni.play("Key_L")
				Key_Label.text = "YDIA"
				Key_Label.show()

	else:
		Key_Label.hide()

		match BUT_TYPE:
			GameLogic.Con.TYPE.AXIS:

				match BUT:
					JOY_AXIS_0:
						if RE == - 1:
							ButTypeAni.play("Axis_L")
						elif RE == 1:
							ButTypeAni.play("Axis_R")
					JOY_AXIS_1:
						if RE == - 1:
							ButTypeAni.play("Axis_U")
						elif RE == 1:
							ButTypeAni.play("Axis_D")
					JOY_AXIS_2:
						if RE == - 1:
							ButTypeAni.play("Axis_L")
						elif RE == 1:
							ButTypeAni.play("Axis_R")
					JOY_AXIS_3:
						if RE == - 1:
							ButTypeAni.play("Axis_U")
						elif RE == 1:
							ButTypeAni.play("Axis_D")
					JOY_AXIS_4:
						ButTypeAni.play("But")
						Key_Label.text = "Axis 4"
						Key_Label.show()
					JOY_AXIS_5:
						ButTypeAni.play("But")
						Key_Label.text = "Axis 5"
						Key_Label.show()

					JOY_AXIS_6:

						ButTypeAni.play("LT")
					JOY_AXIS_7:
						ButTypeAni.play("RT")
					JOY_AXIS_8:
						ButTypeAni.play("But")
						Key_Label.text = "Axis 8"
						Key_Label.show()
					JOY_AXIS_9:
						ButTypeAni.play("But")
						Key_Label.text = "Axis 9"
						Key_Label.show()
					JOY_AXIS_MAX:
						ButTypeAni.play("But")
						Key_Label.text = "Axis Max"
						Key_Label.show()
					JOY_ANALOG_LX:
						ButTypeAni.play("But")
						Key_Label.text = "Axis LX"
						Key_Label.show()
					JOY_ANALOG_LY:
						ButTypeAni.play("But")
						Key_Label.text = "Axis LY"
						Key_Label.show()
					JOY_ANALOG_RX:
						ButTypeAni.play("But")
						Key_Label.text = "Axis RX"
						Key_Label.show()
					JOY_ANALOG_RY:
						ButTypeAni.play("But")
						Key_Label.text = "Axis RY"
						Key_Label.show()
					JOY_ANALOG_L2:
						ButTypeAni.play("But")
						Key_Label.text = "L2"
						Key_Label.show()
					JOY_ANALOG_R2:
						ButTypeAni.play("But")
						Key_Label.text = "R2"
						Key_Label.show()

			GameLogic.Con.TYPE.BUTTON:

				match BUT:

					JOY_XBOX_B:
						if not GameLogic.GlobalData.globalini.has("ButShow"):
							ButTypeAni.play("B")
							return
						if GameLogic.GlobalData.globalini.ButShow == 1:
							ButTypeAni.play("圈")
						else:
							ButTypeAni.play("B")
					JOY_XBOX_A:

						if not GameLogic.GlobalData.globalini.has("ButShow"):
							ButTypeAni.play("A")
							return
						if GameLogic.GlobalData.globalini.ButShow == 1:
							ButTypeAni.play("叉")
						else:
							ButTypeAni.play("A")
					JOY_XBOX_X:
						if not GameLogic.GlobalData.globalini.has("ButShow"):
							ButTypeAni.play("X")
							return
						if GameLogic.GlobalData.globalini.ButShow == 1:
							ButTypeAni.play("方")
						else:
							ButTypeAni.play("X")
					JOY_XBOX_Y:
						if not GameLogic.GlobalData.globalini.has("ButShow"):
							ButTypeAni.play("Y")
							return
						if GameLogic.GlobalData.globalini.ButShow == 1:
							ButTypeAni.play("三角")
						else:
							ButTypeAni.play("Y")

					JOY_VR_GRIP:
						ButTypeAni.play("But")
						Key_Label.text = "GRIP"
						Key_Label.show()

					JOY_SELECT:
						if _CONTROLTYPE == 4:
							ButTypeAni.play("Share")
						else:
							ButTypeAni.play("Back")

					JOY_START:
						if _CONTROLTYPE == 4:
							ButTypeAni.play("Option")
						else:
							ButTypeAni.play("Start")

					JOY_DPAD_UP:
						ButTypeAni.play("Dpad_Up")
					JOY_DPAD_DOWN:
						ButTypeAni.play("Dpad_Down")
					JOY_DPAD_LEFT:

						ButTypeAni.play("Dpad_Left")
					JOY_DPAD_RIGHT:
						ButTypeAni.play("Dpad_Right")
					JOY_GUIDE:
						ButTypeAni.play("But")
						Key_Label.text = "Guide"
						Key_Label.show()
					JOY_MISC1:
						ButTypeAni.play("But")
						Key_Label.text = "Misc1"
						Key_Label.show()
					JOY_PADDLE1:
						ButTypeAni.play("But")
						Key_Label.text = "Pad 1"
						Key_Label.show()
					JOY_PADDLE2:
						ButTypeAni.play("But")
						Key_Label.text = "Pad 2"
						Key_Label.show()
					JOY_PADDLE3:
						ButTypeAni.play("But")
						Key_Label.text = "Pad 3"
						Key_Label.show()
					JOY_PADDLE4:
						ButTypeAni.play("But")
						Key_Label.text = "Pad 4"
						Key_Label.show()
					JOY_TOUCHPAD:
						ButTypeAni.play("But")
						Key_Label.text = "Touch"
						Key_Label.show()
					JOY_L:
						if _CONTROLTYPE == 4:
							ButTypeAni.play("L1")
						else:
							ButTypeAni.play("LB")

					JOY_L2:
						if _CONTROLTYPE == 4:
							ButTypeAni.play("L2")
						else:
							ButTypeAni.play("LT")

					JOY_L3:
						ButTypeAni.play("Axis_L3")
					JOY_R:
						if _CONTROLTYPE == 4:
							ButTypeAni.play("R1")
						else:
							ButTypeAni.play("RB")

					JOY_R2:
						if _CONTROLTYPE == 4:
							ButTypeAni.play("R2")
						else:
							ButTypeAni.play("RT")

					JOY_R3:
						ButTypeAni.play("Axis_R3")

func _on_focus_entered():

	call_OutLine(true)

func _on_focus_exited():
	call_OutLine(false)

func call_waiting(_Switch: bool):
	if not ButSetting:
		return
	match _Switch:
		true:
			get_node("Texture").hide()
			get_node("WaitingLabel/Ani").play("wait")

		false:
			get_node("Texture").show()

			get_node("WaitingLabel/Ani").play("init")
func call_waiting_wrong():
	if has_node("WaitingLabel"):
		if get_node("WaitingLabel/Ani").assigned_animation != "init":
			get_node("WaitingLabel/Ani").play("wrong")

func test():

	get_godot_controllers()

var godot_controllers: Array
func get_godot_controllers() -> void :

	godot_controllers = Input.get_connected_joypads()

	if godot_controllers.size() > 0:
		for this_controller in godot_controllers:
			var _this_controller_name: String = Input.get_joy_name(this_controller)
			print(" 测试，godot手柄名字 button：", _this_controller_name)
