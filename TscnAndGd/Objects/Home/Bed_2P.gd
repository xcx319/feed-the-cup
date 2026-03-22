extends Head_Object

var Keyboard_bool: bool
var Joy_bool: bool
var _playerNode = null

onready var ControlAni = get_node("AniNode/BedLogicAni")
onready var ApplyAni = get_node("ControlNode/AniNode/ApplyAni")
onready var KeyboardAni = get_node("ControlNode/AniNode/KeyboardAni")
onready var JoyAni = get_node("ControlNode/AniNode/JoyAni")

onready var KeyBoardLabel = get_node("ControlNode/Keyboard/Control")

onready var ButShow = get_node("Button/A")
func _ready() -> void :
	set_process_input(false)
	call_deferred("_control_init")

func _control_init():
	if GameLogic.Con.player2P_Keyboard:
		Keyboard_bool = true
		KeyboardAni.play("join")
	if GameLogic.Con.player1P_Keyboard:
		KeyBoardLabel.text = "键盘被1P使用中"
		KeyBoardLabel.get_node("Sprite").hide()
	else:
		KeyBoardLabel.text = ""
		KeyBoardLabel.get_node("Sprite").show()
	if GameLogic.Con.player2P_Joy > - 1:
		Joy_bool = true
		JoyAni.play("join")


	_ApplyAni_logic()
func _input(event: InputEvent) -> void :

	if GameLogic.Con.player1P_Keyboard:
		if not Keyboard_bool and not Joy_bool:
			if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.X.BUT):
				_set_check()
	if not GameLogic.Con.player1P_Keyboard:
		if Keyboard_bool:
			if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.B.BUT):
				call_set( - 1, 1)
			if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.X.BUT):
				_set_check()
		else:
			if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.A.BUT):

				call_set( - 1, 0)
	if event is InputEventJoypadButton:
		if event.device == GameLogic.Con.player1P_Joy:
			match event.button_index:
				GameLogic.Con.P1JOY.X.BUT:
					if not Keyboard_bool and not Joy_bool:
						_set_check()
			return

		if Joy_bool:
			if event.device == GameLogic.Con.player2P_Joy and event.pressed:
				match event.button_index:
					GameLogic.Con.P2JOY.B.BUT:
						_joy_set(false)
						GameLogic.Con.player2P_Joy = - 1
					GameLogic.Con.P2JOY.X.BUT:
						_set_check()
		else:
			match event.button_index:
				GameLogic.Con.P2JOY.A.BUT:
					_joy_set(true)
					GameLogic.Con.player2P_Joy = event.device

	pass

func call_set(_joy, _button):

	match _joy:
		- 1:
			match _button:
				0:
					_keyboard_set(true)
				1:
					_keyboard_set(false)
		_:
			match _button:
				0:
					_joy_set(true)
				1:
					_joy_set(false)
func call_home_device(_butID, _Player):

	match _butID:
		- 1:
			if GameLogic.Player2_bool and _Player.cur_Player == 2:
				ButShow.call_player_in(_Player.cur_Player)
				_control_init()
			if not GameLogic.Player2_bool:
				ButShow.call_player_in(_Player.cur_Player)
				_control_init()
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		0:
			if is_instance_valid(GameLogic.player_1P) and is_instance_valid(GameLogic.player_1P):
				if _Player.cur_Player == 1 and GameLogic.player_1P.Con.CanControl:
					if GameLogic.Player2_bool:
						return

					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						pass
					else:
						GameLogic.player_1P.call_control(2)
						GameLogic.player_2P.call_control(2)
					ControlAni.play("show")
					set_process_input(true)
				if _Player.cur_Player == 2 and GameLogic.player_2P.Con.CanControl:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						pass
					else:
						GameLogic.player_1P.call_control(2)
						GameLogic.player_2P.call_control(2)
					_Player.Con.cur_UI = self
					ControlAni.play("show")
					set_process_input(true)

func _set_check():

	if not Keyboard_bool and not Joy_bool:
		GameLogic.Player2_bool = false
		GameLogic.player_2P.hide()
		GameLogic.player_2P.Collision.disabled = true

	else:
		if not GameLogic.Player2_bool:
			GameLogic.Con.call_player2P_set()
			GameLogic.Player2_bool = true
			GameLogic.player_2P.show()
			GameLogic.player_2P.Collision.disabled = false

			get_parent().get_parent().get_parent().call_camera_init()
			get_parent().get_parent().get_parent().set_process(true)

		else:
			GameLogic.player_2P.call_control(0)
			GameLogic.player_2P.Con.cur_UI = null
			GameLogic.Con.call_player2P_set()
	GameLogic.player_1P.call_control(0)
	ControlAni.play_backwards("show")
	set_process_input(false)
func _joy_set(_switch):
	Joy_bool = _switch
	if Joy_bool:
		JoyAni.play("join")
	else:
		JoyAni.play("none")
	_ApplyAni_logic()

func _keyboard_set(_switch):
	Keyboard_bool = _switch
	if Keyboard_bool:
		if not GameLogic.Con.player1P_Keyboard:
			KeyboardAni.play("join")
			GameLogic.Con.player2P_Keyboard = true
	else:
		KeyboardAni.play("none")
		GameLogic.Con.player2P_Keyboard = false
	_ApplyAni_logic()

func _ApplyAni_logic():
	if Joy_bool and Keyboard_bool:
		ApplyAni.play("both")
		return
	else:
		if Joy_bool:
			ApplyAni.play("joy")
		elif Keyboard_bool:
			ApplyAni.play("keybord")
		else:
			ApplyAni.play("none")
