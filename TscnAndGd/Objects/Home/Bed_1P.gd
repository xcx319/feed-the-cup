extends Head_Object

var Keyboard_bool: bool
var Joy_bool: bool
var _PlayerNode
var CanInput: bool

onready var ControlAni = get_node("AniNode/BedLogicAni")
onready var ApplyAni = get_node("ControlNode/AniNode/ApplyAni")
onready var KeyboardAni = get_node("ControlNode/AniNode/KeyboardAni")
onready var JoyAni = get_node("ControlNode/AniNode/JoyAni")

onready var ButShow = get_node("Button/A")
func _ready() -> void :
	set_process_input(false)
	call_deferred("_control_init")

func _control_init():
	if GameLogic.Con.player1P_Keyboard:
		Keyboard_bool = true
		KeyboardAni.play("join")
	if GameLogic.Con.player1P_Joy > - 1:
		Joy_bool = true
		JoyAni.play("join")
	_ApplyAni_logic()

func _input(event: InputEvent) -> void :

	if Keyboard_bool:
		if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.B.BUT):
			call_set( - 1, 1)
		if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.X.BUT):
			_set_check()
	else:
		if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.A.BUT):
			call_set( - 1, 0)
	if event is InputEventJoypadButton:
		if Joy_bool:
			if event.device == GameLogic.Con.player1P_Joy:
				match event.button_index:
					1:
						_joy_set(false)
						GameLogic.Con.player1P_Joy = - 1
					2:
						_set_check()
		else:
			match event.button_index:
				0:
					_joy_set(true)
					GameLogic.Con.player1P_Joy = event.device

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
			if not CanInput and _Player.cur_Player == 1:
				ButShow.call_player_in(_Player.cur_Player)
		- 2:
			if not CanInput and _Player.cur_Player == 1:
				ButShow.call_player_out(_Player.cur_Player)
		0:

			if _Player.cur_Player == 1:
				if is_instance_valid(GameLogic.player_1P) and is_instance_valid(GameLogic.player_2P):
					if GameLogic.player_1P.Con.CanControl:

						GameLogic.player_1P.call_control(2)
						GameLogic.player_2P.call_control(2)
						_Player.Con.cur_UI = self
						ControlAni.play("show")
						CanInput = true
						ButShow.call_player_out(_Player.cur_Player)
						_PlayerNode = _Player
						set_process_input(true)
	pass
func _set_check():
	if not Keyboard_bool and not Joy_bool:
		return
	GameLogic.Con.call_player1P_set()
	GameLogic.player_1P.call_control(0)
	GameLogic.player_2P.call_control(0)
	ControlAni.play_backwards("show")
	CanInput = false
	ButShow.call_player_in(_PlayerNode.cur_Player)
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
		if not GameLogic.Con.player2P_Keyboard:
			KeyboardAni.play("join")
			GameLogic.Con.player1P_Keyboard = true
	else:
		KeyboardAni.play("none")
		GameLogic.Con.player1P_Keyboard = false
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
