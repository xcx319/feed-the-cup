extends Node

var player1P_Keyboard = true
var player1P_Joy = 0
var player1P_IsJoy: bool
var player2P_Keyboard = false
var player2P_Joy = - 1
var player2P_IsJoy: bool

var DEADZONE: float = 0.25

enum TYPE{
	AXIS
	BUTTON
	KEY
}
var P1KEYBOARD = {
	L_UD_REVERSE = - 1,
	L_LR_REVERSE = - 1,
	L_UP = - 1,
	L_DOWN = - 1,
	L_LEFT = - 1,
	L_RIGHT = - 1,
	R_UD_REVERSE = - 1,
	R_LR_REVERSE = - 1,
	R_UP = - 1,
	R_DOWN = - 1,
	R_LEFT = - 1,
	R_RIGHT = - 1,
	UP = - 1,
	DOWN = - 1,
	LEFT = - 1,
	RIGHT = - 1,
	A = - 1,
	B = - 1,
	X = - 1,
	Y = - 1,
	L1 = - 1,
	L2 = - 1,
	L3 = - 1,
	R1 = - 1,
	R2 = - 1,
	R3 = - 1,
	BACK = - 1,
	START = - 1,
}
var P2KEYBOARD = {
	L_UD_REVERSE = - 1,
	L_LR_REVERSE = - 1,
	L_UP = - 1,
	L_DOWN = - 1,
	L_LEFT = - 1,
	L_RIGHT = - 1,
	R_UD_REVERSE = - 1,
	R_LR_REVERSE = - 1,
	R_UP = - 1,
	R_DOWN = - 1,
	R_LEFT = - 1,
	R_RIGHT = - 1,
	UP = - 1,
	DOWN = - 1,
	LEFT = - 1,
	RIGHT = - 1,
	A = - 1,
	B = - 1,
	X = - 1,
	Y = - 1,
	L1 = - 1,
	L2 = - 1,
	L3 = - 1,
	R1 = - 1,
	R2 = - 1,
	R3 = - 1,
	BACK = - 1,
	START = - 1,
}
var P1JOY = {
	L_UD_REVERSE = - 1,
	L_LR_REVERSE = - 1,
	L_UP = - 1,
	L_DOWN = - 1,
	L_LEFT = - 1,
	L_RIGHT = - 1,
	R_UD_REVERSE = - 1,
	R_LR_REVERSE = - 1,
	R_UP = - 1,
	R_DOWN = - 1,
	R_LEFT = - 1,
	R_RIGHT = - 1,
	UP = - 1,
	DOWN = - 1,
	LEFT = - 1,
	RIGHT = - 1,
	A = - 1,
	B = - 1,
	X = - 1,
	Y = - 1,
	L1 = - 1,
	L2 = - 1,
	L3 = - 1,
	R1 = - 1,
	R2 = - 1,
	R3 = - 1,
	BACK = - 1,
	START = - 1,
}
var P2JOY = {
	L_UD_REVERSE = - 1,
	L_LR_REVERSE = - 1,
	L_UP = - 1,
	L_DOWN = - 1,
	L_LEFT = - 1,
	L_RIGHT = - 1,
	R_UD_REVERSE = - 1,
	R_LR_REVERSE = - 1,
	R_UP = - 1,
	R_DOWN = - 1,
	R_LEFT = - 1,
	R_RIGHT = - 1,
	UP = - 1,
	DOWN = - 1,
	LEFT = - 1,
	RIGHT = - 1,
	A = - 1,
	B = - 1,
	X = - 1,
	Y = - 1,
	L1 = - 1,
	L2 = - 1,
	L3 = - 1,
	R1 = - 1,
	R2 = - 1,
	R3 = - 1,
	BACK = - 1,
	START = - 1,
}

signal P1_Control_init()
signal P2_Control_init()
signal P1_Control(_but, _value)
signal P2_Control(_but, _value)

func _ready() -> void :
	set_process_input(false)
	call_deferred("_call_init")
	if SteamLogic.STEAM_BOOL:
		var _return = Steam.inputInit()

	connect_godot_signals("joy_connection_changed", "_on_joy_connection_changed")

func connect_godot_signals(this_signal: String, this_function: String) -> void :
	var signal_connect: int = Input.connect(this_signal, self, this_function)
	if signal_connect > OK:
		printerr("Connecting %s to %s failed: %s" % [this_signal, this_function, signal_connect])
func connect_steam_signals(this_signal: String, this_function: String) -> void :
	var signal_connect: int = Steam.connect(this_signal, self, this_function)
	if signal_connect > OK:
		printerr("Connecting %s to %s failed: %s" % [this_signal, this_function, signal_connect])

func _on_joy_connection_changed(_device_id: int, _connected: bool) -> void :

	get_steam_controllers(true)
	get_godot_controllers()

func call_player1P_set():
	emit_signal("P1_Control_init")

func call_player2P_set():
	emit_signal("P2_Control_init")

func call_default():
	_default_set()
	_load_control_set()

func _call_init():

	if not GameLogic.GlobalData.joyini or not GameLogic.GlobalData.keyboardini:
		_Reset_All()
	_load_control_set()
	set_process_input(true)

var P1_Pos_0: bool
var P2_Pos_0: bool
func _input(event: InputEvent) -> void :



	var _type
	var _stickID: int = - 1
	var _P1_bool: bool
	var _P2_bool: bool

	if event is InputEventJoypadButton:

		_stickID = event.button_index
		_type = TYPE.BUTTON
		if event.device == player1P_Joy:

			_P1_bool = true
			if not player1P_IsJoy:
				player1P_IsJoy = true

		if event.device == player2P_Joy:

			_P2_bool = true
			if not player2P_IsJoy:
				player2P_IsJoy = true

	if event is InputEventJoypadMotion:
		_stickID = event.axis
		_type = TYPE.AXIS

		if event.device == player1P_Joy:

			_P1_bool = true
			if not player1P_IsJoy:
				player1P_IsJoy = true

		if event.device == player2P_Joy:

			_P2_bool = true
			if not player2P_IsJoy:
				player2P_IsJoy = true

	if event is InputEventKey:

		_stickID = event.scancode
		_type = TYPE.KEY
		if player1P_Keyboard:
			_P1_bool = true
			if player1P_IsJoy:
				player1P_IsJoy = false

		if player2P_Keyboard:

			_P2_bool = true
			if player2P_IsJoy:
				player2P_IsJoy = false

	if not _P1_bool and not _P2_bool:
		return
	if _stickID > - 1:
		match _type:
			TYPE.AXIS:
				var _Axis = event.axis_value

				if PressedDic[1].device == event.device:
					if _stickID == PressedDic[1].But and _type == PressedDic[1].type:
						if abs(_Axis) < DEADZONE:
							_Axis = 0
				if event.device in [PressedDic[2].device]:
					if _stickID != PressedDic[2].But and _type == PressedDic[2].type:
						if abs(_Axis) < DEADZONE:
							_Axis = 0

				if _Axis > 0.85:
					_Axis = 1
					if PressedDic[1].device == event.device:
						P1_Pos_0 = false
					if PressedDic[2].device == event.device:
						P2_Pos_0 = false

				elif _Axis < - 0.85:

					_Axis = - 1
				if not _Axis in [ - 1, 1, 0]:
					return

				if _stickID == P1JOY.L_LEFT.BUT and _type == P1JOY.L_LEFT.TYPE:
					if _Axis == 0 or _Axis == P1JOY.L_LEFT.RE:
						if _P1_bool:
							_type_logic(1, "l", event.device, P1JOY.L_LEFT, int(event.is_pressed()))
				if _stickID == P2JOY.L_LEFT.BUT and _type == P2JOY.L_LEFT.TYPE:
					if _Axis == 0 or _Axis == P2JOY.L_LEFT.RE:
						if _P2_bool:
							_type_logic(2, "l", event.device, P2JOY.L_LEFT, int(event.is_pressed()))
				if _stickID == P1JOY.L_RIGHT.BUT and _type == P1JOY.L_RIGHT.TYPE:
					if _Axis == 0 or _Axis == P1JOY.L_RIGHT.RE:
						if _P1_bool:
							_type_logic(1, "r", event.device, P1JOY.L_RIGHT, int(event.is_pressed()))
				if _stickID == P2JOY.L_RIGHT.BUT and _type == P2JOY.L_RIGHT.TYPE:
					if _Axis == 0 or _Axis == P2JOY.L_RIGHT.RE:
						if _P2_bool:
							_type_logic(2, "r", event.device, P2JOY.L_RIGHT, int(event.is_pressed()))
				if _stickID == P1JOY.L_UP.BUT and _type == P1JOY.L_UP.TYPE:
					if _Axis == 0 or _Axis == P1JOY.L_UP.RE:

						if _P1_bool:
							_type_logic(1, "u", event.device, P1JOY.L_UP, int(event.is_pressed()))
				if _stickID == P2JOY.L_UP.BUT and _type == P2JOY.L_UP.TYPE:
					if _Axis == 0 or _Axis == P2JOY.L_UP.RE:
						if _P2_bool:
							_type_logic(2, "u", event.device, P2JOY.L_UP, int(event.is_pressed()))
				if _stickID == P1JOY.L_DOWN.BUT and _type == P1JOY.L_DOWN.TYPE:
					if _Axis == 0 or _Axis == P1JOY.L_DOWN.RE:
						if _P1_bool:
							_type_logic(1, "d", event.device, P1JOY.L_DOWN, int(event.is_pressed()))
				if _stickID == P2JOY.L_DOWN.BUT and _type == P2JOY.L_DOWN.TYPE:
					if _Axis == 0 or _Axis == P2JOY.L_DOWN.RE:
						if _P2_bool:
							_type_logic(2, "d", event.device, P2JOY.L_DOWN, int(event.is_pressed()))

				if _stickID == P1JOY.A.BUT and _type == P1JOY.A.TYPE:
					if _Axis == 0 or _Axis == P1JOY.A.RE:
						if _P1_bool:
							_type_logic(1, "A", event.device, P1JOY.A, int(event.is_pressed()))
				if _stickID == P2JOY.A.BUT and _type == P2JOY.A.TYPE:
					if _Axis == 0 or _Axis == P2JOY.A.RE:
						if _P2_bool:
							_type_logic(2, "A", event.device, P2JOY.A, int(event.is_pressed()))
				if _stickID == P1JOY.B.BUT and _type == P1JOY.B.TYPE:
					if _Axis == 0 or _Axis == P1JOY.B.RE:

						if _P1_bool:

							_type_logic(1, "B", event.device, P1JOY.B, int(event.is_pressed()))
				if _stickID == P2JOY.B.BUT and _type == P2JOY.B.TYPE:
					if _Axis == 0 or _Axis == P2JOY.B.RE:
						if _P2_bool:
							_type_logic(2, "B", event.device, P2JOY.B, int(event.is_pressed()))
				if _stickID == P1JOY.X.BUT and _type == P1JOY.X.TYPE:
					if _Axis == 0 or _Axis == P1JOY.X.RE:
						if _P1_bool:
							_type_logic(1, "X", event.device, P1JOY.X, int(event.is_pressed()))
				if _stickID == P2JOY.X.BUT and _type == P2JOY.X.TYPE:
					if _Axis == 0 or _Axis == P2JOY.X.RE:
						if _P2_bool:
							_type_logic(2, "X", event.device, P2JOY.X, int(event.is_pressed()))
				if _stickID == P1JOY.Y.BUT and _type == P1JOY.Y.TYPE:
					if _Axis == 0 or _Axis == P1JOY.Y.RE:
						if _P1_bool:
							_type_logic(1, "Y", event.device, P1JOY.Y, int(event.is_pressed()))
				if _stickID == P2JOY.Y.BUT and _type == P2JOY.Y.TYPE:
					if _Axis == 0 or _Axis == P2JOY.Y.RE:
						if _P2_bool:
							_type_logic(2, "Y", event.device, P2JOY.Y, int(event.is_pressed()))
				if _stickID == P1JOY.UP.BUT and _type == P1JOY.UP.TYPE:
					if _Axis == 0 or _Axis == P1JOY.UP.RE:
						if _P1_bool:
							_type_logic(1, "U", event.device, P1JOY.UP, int(event.is_pressed()))
				if _stickID == P2JOY.UP.BUT and _type == P2JOY.UP.TYPE:
					if _Axis == 0 or _Axis == P2JOY.UP.RE:
						if _P2_bool:
							_type_logic(2, "U", event.device, P2JOY.UP, int(event.is_pressed()))
				if _stickID == P1JOY.DOWN.BUT and _type == P1JOY.DOWN.TYPE:
					if _Axis == 0 or _Axis == P1JOY.DOWN.RE:
						if _P1_bool:
							_type_logic(1, "D", event.device, P1JOY.DOWN, int(event.is_pressed()))
				if _stickID == P2JOY.DOWN.BUT and _type == P2JOY.DOWN.TYPE:
					if _Axis == 0 or _Axis == P2JOY.DOWN.RE:
						if _P2_bool:
							_type_logic(2, "D", event.device, P2JOY.DOWN, int(event.is_pressed()))
				if _stickID == P1JOY.LEFT.BUT and _type == P1JOY.LEFT.TYPE:
					if _Axis == 0 or _Axis == P1JOY.LEFT.RE:
						if _P1_bool:
							_type_logic(1, "L", event.device, P1JOY.LEFT, int(event.is_pressed()))
				if _stickID == P2JOY.LEFT.BUT and _type == P2JOY.LEFT.TYPE:
					if _Axis == 0 or _Axis == P2JOY.LEFT.RE:
						if _P2_bool:
							_type_logic(2, "L", event.device, P2JOY.LEFT, int(event.is_pressed()))
				if _stickID == P1JOY.RIGHT.BUT and _type == P1JOY.RIGHT.TYPE:
					if _Axis == 0 or _Axis == P1JOY.RIGHT.RE:
						if _P1_bool:
							_type_logic(1, "R", event.device, P1JOY.RIGHT, int(event.is_pressed()))
				if _stickID == P2JOY.LEFT.BUT and _type == P2JOY.LEFT.TYPE:
					if _Axis == 0 or _Axis == P2JOY.LEFT.RE:
						if _P2_bool:
							_type_logic(2, "R", event.device, P2JOY.RIGHT, int(event.is_pressed()))
				if _stickID == P1JOY.START.BUT and _type == P1JOY.START.TYPE:
					if _Axis == 0 or _Axis == P1JOY.START.RE:
						if _P1_bool:
							_type_logic(1, "START", event.device, P1JOY.START, int(event.is_pressed()))
				if _stickID == P2JOY.START.BUT and _type == P2JOY.START.TYPE:
					if _Axis == 0 or _Axis == P2JOY.START.RE:
						if _P2_bool:
							_type_logic(2, "START", event.device, P2JOY.START, int(event.is_pressed()))
				if _stickID == P1JOY.L1.BUT and _type == P1JOY.L1.TYPE:
					if _Axis == 0 or _Axis == P1JOY.L1.RE:
						if _P1_bool:
							_type_logic(1, "L1", _stickID, P1JOY.L1, int(event.is_pressed()))
				if _stickID == P2JOY.L1.BUT and _type == P2JOY.L1.TYPE:
					if _Axis == 0 or _Axis == P2JOY.L1.RE:
						if _P2_bool:
							_type_logic(2, "L1", _stickID, P2JOY.L1, int(event.is_pressed()))
				if _stickID == P1JOY.R1.BUT and _type == P1JOY.R1.TYPE:
					if _Axis == 0 or _Axis == P1JOY.R1.RE:
						if _P1_bool:
							_type_logic(1, "R1", _stickID, P1JOY.R1, int(event.is_pressed()))
				if _stickID == P2JOY.R1.BUT and _type == P2JOY.R1.TYPE:
					if _Axis == 0 or _Axis == P2JOY.R1.RE:
						if _P2_bool:
							_type_logic(2, "R1", _stickID, P2JOY.R1, int(event.is_pressed()))

			TYPE.BUTTON:

				if _stickID == P1JOY.A.BUT and _type == P1JOY.A.TYPE:
					if _P1_bool:

						_type_logic(1, "A", _stickID, P1JOY.A, int(event.is_pressed()))
				if _stickID == P2JOY.A.BUT and _type == P2JOY.A.TYPE:
					if _P2_bool:

						_type_logic(2, "A", _stickID, P2JOY.A, int(event.is_pressed()))
				if _stickID == P1JOY.B.BUT and _type == P1JOY.B.TYPE:
					if _P1_bool:
						_type_logic(1, "B", _stickID, P1JOY.B, int(event.is_pressed()))
				if _stickID == P1JOY.B.BUT and _type == P2JOY.B.TYPE:
					if _P2_bool:
						_type_logic(2, "B", _stickID, P2JOY.B, int(event.is_pressed()))
				if _stickID == P1JOY.X.BUT and _type == P1JOY.X.TYPE:
					if _P1_bool:
						_type_logic(1, "X", _stickID, P1JOY.X, int(event.is_pressed()))
				if _stickID == P2JOY.X.BUT and _type == P2JOY.X.TYPE:
					if _P2_bool:
						_type_logic(2, "X", _stickID, P2JOY.X, int(event.is_pressed()))
				if _stickID == P1JOY.Y.BUT and _type == P1JOY.Y.TYPE:
					if _P1_bool:
						_type_logic(1, "Y", _stickID, P1JOY.Y, int(event.is_pressed()))
				if _stickID == P2JOY.Y.BUT and _type == P2JOY.Y.TYPE:
					if _P2_bool:
						_type_logic(2, "Y", _stickID, P2JOY.Y, int(event.is_pressed()))
				if _stickID == P1JOY.UP.BUT and _type == P1JOY.UP.TYPE:
					if _P1_bool:
						_type_logic(1, "U", _stickID, P1JOY.UP, int(event.is_pressed()))
				if _stickID == P2JOY.UP.BUT and _type == P2JOY.UP.TYPE:
					if _P2_bool:
						_type_logic(2, "U", _stickID, P2JOY.UP, int(event.is_pressed()))
				if _stickID == P1JOY.DOWN.BUT and _type == P1JOY.DOWN.TYPE:
					if _P1_bool:
						_type_logic(1, "D", _stickID, P1JOY.DOWN, int(event.is_pressed()))
				if _stickID == P2JOY.DOWN.BUT and _type == P2JOY.DOWN.TYPE:
					if _P2_bool:
						_type_logic(2, "D", _stickID, P2JOY.DOWN, int(event.is_pressed()))
				if _stickID == P1JOY.LEFT.BUT and _type == P1JOY.LEFT.TYPE:
					if _P1_bool:
						_type_logic(1, "L", _stickID, P1JOY.LEFT, int(event.is_pressed()))
				if _stickID == P2JOY.LEFT.BUT and _type == P2JOY.LEFT.TYPE:
					if _P2_bool:
						_type_logic(2, "L", _stickID, P2JOY.LEFT, int(event.is_pressed()))
				if _stickID == P1JOY.RIGHT.BUT and _type == P1JOY.RIGHT.TYPE:
					if _P1_bool:
						_type_logic(1, "R", _stickID, P1JOY.RIGHT, int(event.is_pressed()))
				if _stickID == P2JOY.RIGHT.BUT and _type == P2JOY.RIGHT.TYPE:
					if _P2_bool:
						_type_logic(2, "R", _stickID, P2JOY.RIGHT, int(event.is_pressed()))
				if _stickID == P1JOY.L1.BUT and _type == P1JOY.L1.TYPE:
					if _P1_bool:
						_type_logic(1, "L1", _stickID, P1JOY.L1, int(event.is_pressed()))
					if _P2_bool:
						_type_logic(2, "L1", _stickID, P2JOY.L1, int(event.is_pressed()))

				if _stickID == P1JOY.R1.BUT and _type == P1JOY.R1.TYPE:
					if _P1_bool:
						_type_logic(1, "R1", _stickID, P1JOY.R1, int(event.is_pressed()))
					if _P2_bool:
						_type_logic(2, "R1", _stickID, P2JOY.R1, int(event.is_pressed()))

				if _stickID == P1JOY.START.BUT and _type == P1JOY.START.TYPE:
					if _P1_bool:
						_type_logic(1, "START", _stickID, P1JOY.START, int(event.is_pressed()))
				if _stickID == P2JOY.START.BUT and _type == P2JOY.START.TYPE:
					if _P2_bool:
						_type_logic(2, "START", _stickID, P2JOY.START, int(event.is_pressed()))
			TYPE.KEY:

				if _stickID == P1KEYBOARD.A.BUT and _type == P1KEYBOARD.A.TYPE:
					if _P1_bool:
						_type_logic(1, "A", _stickID, P1KEYBOARD.A, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.A.BUT and _type == P2KEYBOARD.A.TYPE:
					if _P2_bool:
						_type_logic(2, "A", _stickID, P2KEYBOARD.A, int(event.is_pressed()))
				if _stickID == P1KEYBOARD.B.BUT and _type == P1KEYBOARD.B.TYPE:
					if _P1_bool:
						_type_logic(1, "B", _stickID, P1KEYBOARD.B, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.B.BUT and _type == P2KEYBOARD.B.TYPE:
					if _P2_bool:
						_type_logic(2, "B", _stickID, P2KEYBOARD.B, int(event.is_pressed()))
				if _stickID == P1KEYBOARD.X.BUT and _type == P1KEYBOARD.X.TYPE:
					if _P1_bool:
						_type_logic(1, "X", _stickID, P1KEYBOARD.X, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.X.BUT and _type == P2KEYBOARD.X.TYPE:
					if _P2_bool:
						_type_logic(2, "X", _stickID, P2KEYBOARD.X, int(event.is_pressed()))
				if _stickID == P1KEYBOARD.Y.BUT and _type == P1KEYBOARD.Y.TYPE:
					if _P1_bool:
						_type_logic(1, "Y", _stickID, P1KEYBOARD.Y, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.Y.BUT and _type == P2KEYBOARD.Y.TYPE:
					if _P2_bool:
						_type_logic(2, "Y", _stickID, P2KEYBOARD.Y, int(event.is_pressed()))

				if _stickID == P1KEYBOARD.LEFT.BUT and _type == P1KEYBOARD.LEFT.TYPE:
					if _P1_bool:
						_type_logic(1, "L", _stickID, P1KEYBOARD.LEFT, int(event.is_pressed()))
						return
				if _stickID == P2KEYBOARD.LEFT.BUT and _type == P2KEYBOARD.LEFT.TYPE:
					if _P2_bool:
						_type_logic(2, "L", _stickID, P2KEYBOARD.LEFT, int(event.is_pressed()))
						return
				if _stickID == P1KEYBOARD.RIGHT.BUT and _type == P1KEYBOARD.RIGHT.TYPE:
					if _P1_bool:
						_type_logic(1, "R", _stickID, P1KEYBOARD.RIGHT, int(event.is_pressed()))
						return
				if _stickID == P2KEYBOARD.RIGHT.BUT and _type == P2KEYBOARD.RIGHT.TYPE:
					if _P2_bool:
						_type_logic(2, "R", _stickID, P2KEYBOARD.RIGHT, int(event.is_pressed()))
						return
				if _stickID == P1KEYBOARD.UP.BUT and _type == P1KEYBOARD.UP.TYPE:
					if _P1_bool:
						_type_logic(1, "U", _stickID, P1KEYBOARD.UP, int(event.is_pressed()))
						return
				if _stickID == P2KEYBOARD.UP.BUT and _type == P2KEYBOARD.UP.TYPE:
					if _P2_bool:
						_type_logic(2, "U", _stickID, P2KEYBOARD.UP, int(event.is_pressed()))
						return
				if _stickID == P1KEYBOARD.DOWN.BUT and _type == P1KEYBOARD.DOWN.TYPE:
					if _P1_bool:
						_type_logic(1, "D", _stickID, P1KEYBOARD.DOWN, int(event.is_pressed()))
						return
				if _stickID == P2KEYBOARD.DOWN.BUT and _type == P2KEYBOARD.DOWN.TYPE:
					if _P2_bool:
						_type_logic(2, "D", _stickID, P2KEYBOARD.DOWN, int(event.is_pressed()))
						return
				if _stickID == P1KEYBOARD.START.BUT and _type == P1KEYBOARD.START.TYPE:
					if _P1_bool:
						_type_logic(1, "START", _stickID, P1KEYBOARD.START, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.START.BUT and _type == P2KEYBOARD.START.TYPE:
					if _P2_bool:
						_type_logic(2, "START", _stickID, P2KEYBOARD.START, int(event.is_pressed()))
				if _stickID == P1KEYBOARD.L1.BUT and _type == P1KEYBOARD.L1.TYPE:
					if _P1_bool:
						_type_logic(1, "L1", _stickID, P1KEYBOARD.L1, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.L1.BUT and _type == P2KEYBOARD.L1.TYPE:
					if _P2_bool:
						_type_logic(2, "L1", _stickID, P2KEYBOARD.L1, int(event.is_pressed()))
				if _stickID == P1KEYBOARD.R1.BUT and _type == P1KEYBOARD.R1.TYPE:
					if _P1_bool:
						_type_logic(1, "R1", _stickID, P1KEYBOARD.R1, int(event.is_pressed()))
				if _stickID == P2KEYBOARD.R1.BUT and _type == P2KEYBOARD.R1.TYPE:
					if _P2_bool:
						_type_logic(2, "R1", _stickID, P2KEYBOARD.R1, int(event.is_pressed()))

func _Keyboard_Logic(_PLAYER, _INFO):
	if _INFO.TYPE == 2:
		match _PLAYER:
			1:
				if player1P_Keyboard:
					if player1P_IsJoy:
						player1P_IsJoy = false
			2:
				if player2P_Keyboard:
					if player2P_IsJoy:
						player2P_IsJoy = false

var PressedDic: Dictionary = {
	1: {"ButID": "", "device": - 1, "But": "", "value": - 1, "type": - 1},
	2: {"ButID": "", "device": - 1, "But": "", "value": - 1, "type": - 1}
}

func _type_logic(_Player, _But, _device, _butInfo, _value):
	_Keyboard_Logic(_Player, _butInfo)
	var _type = _butInfo.TYPE


	if _But == PressedDic[_Player].ButID and PressedDic[_Player].device == _device and PressedDic[_Player].But == _butInfo.BUT and PressedDic[_Player].value == _value and PressedDic[_Player].type == _type:

		return
	else:

		if PressedDic[_Player].device == _device and PressedDic[_Player].type == _type:
			if PressedDic[_Player].ButID != _But and _value == 0:
				return
			if PressedDic[_Player].value == 0 and _value == 0:
				return

		PressedDic[_Player].ButID = _But
		PressedDic[_Player].device = _device
		PressedDic[_Player].But = _butInfo.BUT
		PressedDic[_Player].value = _value
		PressedDic[_Player].type = _type

	match _Player:
		1:
			emit_signal("P1_Control", _But, _value, _type)

		2:
			emit_signal("P2_Control", _But, _value, _type)

func _load_control_set():


	P1KEYBOARD.L_UP = GameLogic.GlobalData.keyboardini["P1_move_up"]
	P1KEYBOARD.L_DOWN = GameLogic.GlobalData.keyboardini["P1_move_down"]
	P1KEYBOARD.L_LEFT = GameLogic.GlobalData.keyboardini["P1_move_left"]
	P1KEYBOARD.L_RIGHT = GameLogic.GlobalData.keyboardini["P1_move_right"]

	P1KEYBOARD.UP = GameLogic.GlobalData.keyboardini["P1_up"]
	P1KEYBOARD.DOWN = GameLogic.GlobalData.keyboardini["P1_down"]
	P1KEYBOARD.LEFT = GameLogic.GlobalData.keyboardini["P1_left"]
	P1KEYBOARD.RIGHT = GameLogic.GlobalData.keyboardini["P1_right"]
	P1KEYBOARD.A = GameLogic.GlobalData.keyboardini["P1_A"]
	P1KEYBOARD.B = GameLogic.GlobalData.keyboardini["P1_B"]
	P1KEYBOARD.X = GameLogic.GlobalData.keyboardini["P1_X"]
	P1KEYBOARD.Y = GameLogic.GlobalData.keyboardini["P1_Y"]
	if not GameLogic.GlobalData.keyboardini.has("P1_L1"):
		_Reset_All()
	P1KEYBOARD.L1 = GameLogic.GlobalData.keyboardini["P1_L1"]

	P1KEYBOARD.R1 = GameLogic.GlobalData.keyboardini["P1_R1"]

	P1KEYBOARD.START = GameLogic.GlobalData.keyboardini["P1_Start"]

	P2KEYBOARD.L_UP = GameLogic.GlobalData.keyboardini["P2_move_up"]
	P2KEYBOARD.L_DOWN = GameLogic.GlobalData.keyboardini["P2_move_down"]
	P2KEYBOARD.L_LEFT = GameLogic.GlobalData.keyboardini["P2_move_left"]
	P2KEYBOARD.L_RIGHT = GameLogic.GlobalData.keyboardini["P2_move_right"]

	P2KEYBOARD.UP = GameLogic.GlobalData.keyboardini["P2_up"]
	P2KEYBOARD.DOWN = GameLogic.GlobalData.keyboardini["P2_down"]
	P2KEYBOARD.LEFT = GameLogic.GlobalData.keyboardini["P2_left"]
	P2KEYBOARD.RIGHT = GameLogic.GlobalData.keyboardini["P2_right"]
	P2KEYBOARD.A = GameLogic.GlobalData.keyboardini["P2_A"]
	P2KEYBOARD.B = GameLogic.GlobalData.keyboardini["P2_B"]
	P2KEYBOARD.X = GameLogic.GlobalData.keyboardini["P2_X"]
	P2KEYBOARD.Y = GameLogic.GlobalData.keyboardini["P2_Y"]
	P2KEYBOARD.L1 = GameLogic.GlobalData.keyboardini["P2_L1"]

	P2KEYBOARD.R1 = GameLogic.GlobalData.keyboardini["P2_R1"]

	P2KEYBOARD.START = GameLogic.GlobalData.keyboardini["P2_Start"]

	P1JOY.L_UP = GameLogic.GlobalData.joyini["P1_move_up"]
	P1JOY.L_DOWN = GameLogic.GlobalData.joyini["P1_move_down"]
	P1JOY.L_LEFT = GameLogic.GlobalData.joyini["P1_move_left"]
	P1JOY.L_RIGHT = GameLogic.GlobalData.joyini["P1_move_right"]

	P1JOY.UP = GameLogic.GlobalData.joyini["P1_up"]
	P1JOY.DOWN = GameLogic.GlobalData.joyini["P1_down"]
	P1JOY.LEFT = GameLogic.GlobalData.joyini["P1_left"]
	P1JOY.RIGHT = GameLogic.GlobalData.joyini["P1_right"]
	P1JOY.A = GameLogic.GlobalData.joyini["P1_A"]
	P1JOY.B = GameLogic.GlobalData.joyini["P1_B"]
	P1JOY.X = GameLogic.GlobalData.joyini["P1_X"]
	P1JOY.Y = GameLogic.GlobalData.joyini["P1_Y"]
	P1JOY.L1 = GameLogic.GlobalData.joyini["P1_L1"]

	P1JOY.R1 = GameLogic.GlobalData.joyini["P1_R1"]

	P1JOY.START = GameLogic.GlobalData.joyini["P1_Start"]

	P2JOY.L_UP = GameLogic.GlobalData.joyini["P2_move_up"]
	P2JOY.L_DOWN = GameLogic.GlobalData.joyini["P2_move_down"]
	P2JOY.L_LEFT = GameLogic.GlobalData.joyini["P2_move_left"]
	P2JOY.L_RIGHT = GameLogic.GlobalData.joyini["P2_move_right"]

	P2JOY.UP = GameLogic.GlobalData.joyini["P2_up"]
	P2JOY.DOWN = GameLogic.GlobalData.joyini["P2_down"]
	P2JOY.LEFT = GameLogic.GlobalData.joyini["P2_left"]
	P2JOY.RIGHT = GameLogic.GlobalData.joyini["P2_right"]
	P2JOY.A = GameLogic.GlobalData.joyini["P2_A"]
	P2JOY.B = GameLogic.GlobalData.joyini["P2_B"]
	P2JOY.X = GameLogic.GlobalData.joyini["P2_X"]
	P2JOY.Y = GameLogic.GlobalData.joyini["P2_Y"]
	P2JOY.L1 = GameLogic.GlobalData.joyini["P2_L1"]

	P2JOY.R1 = GameLogic.GlobalData.joyini["P2_R1"]

	P2JOY.START = GameLogic.GlobalData.joyini["P2_Start"]

func _Reset_All():

	GameLogic.GlobalData.keyboardini["P1_move_up"] = {"TYPE": TYPE.KEY, "BUT": KEY_W, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_move_down"] = {"TYPE": TYPE.KEY, "BUT": KEY_S, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_move_left"] = {"TYPE": TYPE.KEY, "BUT": KEY_A, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_move_right"] = {"TYPE": TYPE.KEY, "BUT": KEY_D, "RE": 1}

	GameLogic.GlobalData.keyboardini["P1_up"] = {"TYPE": TYPE.KEY, "BUT": KEY_W, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_down"] = {"TYPE": TYPE.KEY, "BUT": KEY_S, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_left"] = {"TYPE": TYPE.KEY, "BUT": KEY_A, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_right"] = {"TYPE": TYPE.KEY, "BUT": KEY_D, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_A"] = {"TYPE": TYPE.KEY, "BUT": KEY_SPACE, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_B"] = {"TYPE": TYPE.KEY, "BUT": KEY_L, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_X"] = {"TYPE": TYPE.KEY, "BUT": KEY_J, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_Y"] = {"TYPE": TYPE.KEY, "BUT": KEY_K, "RE": 1}
	GameLogic.GlobalData.keyboardini["P1_R1"] = {"TYPE": TYPE.KEY, "BUT": KEY_E, "RE": 1}

	GameLogic.GlobalData.keyboardini["P1_L1"] = {"TYPE": TYPE.KEY, "BUT": KEY_Q, "RE": 1}

	GameLogic.GlobalData.keyboardini["P1_Start"] = {"TYPE": TYPE.KEY, "BUT": KEY_ESCAPE, "RE": 1}

	GameLogic.GlobalData.keyboardini["P2_move_up"] = {"TYPE": TYPE.KEY, "BUT": KEY_UP, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_move_down"] = {"TYPE": TYPE.KEY, "BUT": KEY_DOWN, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_move_left"] = {"TYPE": TYPE.KEY, "BUT": KEY_LEFT, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_move_right"] = {"TYPE": TYPE.KEY, "BUT": KEY_RIGHT, "RE": 1}

	GameLogic.GlobalData.keyboardini["P2_up"] = {"TYPE": TYPE.KEY, "BUT": KEY_UP, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_down"] = {"TYPE": TYPE.KEY, "BUT": KEY_DOWN, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_left"] = {"TYPE": TYPE.KEY, "BUT": KEY_LEFT, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_right"] = {"TYPE": TYPE.KEY, "BUT": KEY_RIGHT, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_A"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_0, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_B"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_1, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_X"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_2, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_Y"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_3, "RE": 1}
	GameLogic.GlobalData.keyboardini["P2_R1"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_5, "RE": 1}

	GameLogic.GlobalData.keyboardini["P2_L1"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_4, "RE": 1}

	GameLogic.GlobalData.keyboardini["P2_Start"] = {"TYPE": TYPE.KEY, "BUT": KEY_KP_ENTER, "RE": 1}

	GameLogic.GlobalData.joyini["P1_move_up"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_1, "RE": - 1}
	GameLogic.GlobalData.joyini["P1_move_down"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_1, "RE": 1}
	GameLogic.GlobalData.joyini["P1_move_left"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_0, "RE": - 1}
	GameLogic.GlobalData.joyini["P1_move_right"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_0, "RE": 1}

	GameLogic.GlobalData.joyini["P1_up"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_UP, "RE": 1}
	GameLogic.GlobalData.joyini["P1_down"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_DOWN, "RE": 1}
	GameLogic.GlobalData.joyini["P1_left"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_LEFT, "RE": 1}
	GameLogic.GlobalData.joyini["P1_right"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_RIGHT, "RE": 1}
	GameLogic.GlobalData.joyini["P1_A"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_A, "RE": 1}
	GameLogic.GlobalData.joyini["P1_B"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_B, "RE": 1}
	GameLogic.GlobalData.joyini["P1_X"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_X, "RE": 1}
	GameLogic.GlobalData.joyini["P1_Y"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_Y, "RE": 1}
	GameLogic.GlobalData.joyini["P1_R1"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_R, "RE": 1}

	GameLogic.GlobalData.joyini["P1_L1"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_L, "RE": 1}

	GameLogic.GlobalData.joyini["P1_Start"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_START, "RE": 1}

	GameLogic.GlobalData.joyini["P2_move_up"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_1, "RE": - 1}
	GameLogic.GlobalData.joyini["P2_move_down"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_1, "RE": 1}
	GameLogic.GlobalData.joyini["P2_move_left"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_0, "RE": - 1}
	GameLogic.GlobalData.joyini["P2_move_right"] = {"TYPE": TYPE.AXIS, "BUT": JOY_AXIS_0, "RE": 1}

	GameLogic.GlobalData.joyini["P2_up"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_UP, "RE": 1}
	GameLogic.GlobalData.joyini["P2_down"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_DOWN, "RE": 1}
	GameLogic.GlobalData.joyini["P2_left"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_LEFT, "RE": 1}
	GameLogic.GlobalData.joyini["P2_right"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_DPAD_RIGHT, "RE": 1}
	GameLogic.GlobalData.joyini["P2_A"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_A, "RE": 1}
	GameLogic.GlobalData.joyini["P2_B"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_B, "RE": 1}
	GameLogic.GlobalData.joyini["P2_X"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_X, "RE": 1}
	GameLogic.GlobalData.joyini["P2_Y"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_XBOX_Y, "RE": 1}
	GameLogic.GlobalData.joyini["P2_R1"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_R, "RE": 1}

	GameLogic.GlobalData.joyini["P2_L1"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_L, "RE": 1}

	GameLogic.GlobalData.joyini["P2_Start"] = {"TYPE": TYPE.BUTTON, "BUT": JOY_START, "RE": 1}
	_load_control_set()
	GameLogic.GlobalData.globalinisave()
func _default_set():












	var _info: Dictionary

	GameLogic.GlobalData.globalini["joyini"] = GameLogic.GlobalData.joyini
	GameLogic.GlobalData.globalini["keyboardini"] = GameLogic.GlobalData.keyboardini
	GameLogic.GlobalData.globalinisave()

func call_vibration_Type(_playerID: int, _Type: int):
	if _playerID in [1, 2, SteamLogic.STEAM_ID]:
		match _Type:
			0:
				call_vibration(_playerID, 0, 0.8, 0.07)
			1:
				call_vibration(_playerID, 0, 0.8, 0.07)

func call_vibration(_playerID: int, _WeakPower: float, _StrongPower: float, _Time: float):
	if not GameLogic.GlobalData.globalini.Vibration:
		return

	var _device: int = - 1
	match _playerID:
		1, SteamLogic.STEAM_ID:
			if not player1P_IsJoy:
				return
			_device = player1P_Joy
		2:
			if not player2P_IsJoy:
				return
			_device = player2P_Joy
	if _device >= 0:
		Input.start_joy_vibration(_device, _WeakPower, _StrongPower, _Time)

var godot_controllers: Array
func get_godot_controllers() -> void :

	godot_controllers = Input.get_connected_joypads()


	if 1 in godot_controllers:
		pass
	if godot_controllers.size() > 0:
		for this_controller in godot_controllers:
			var _this_controller_name: String = Input.get_joy_name(this_controller)

var steam_controllers: Array
func get_steam_controllers(check_for_controllers: bool) -> void :
	if not SteamLogic.STEAM_BOOL:
		return
	if check_for_controllers:

		steam_controllers = Steam.getConnectedControllers()



	if steam_controllers.size() > 0:


		for this_controller in steam_controllers:
			var this_controller_name: String = str(Steam.getInputTypeForHandle(this_controller))
			match this_controller_name:
				"0":
					print("unknown\n!");
				"1":
					print("Steam controller\n!");
				"2":
					print("XBox 360 controller\n!");
				"3":
					print("XBox One controller\n!");
				"4":
					print("Generic XInput\n!");
				"5":
					print("PS4 controller\n!");

func test():

	steam_controllers = Steam.getConnectedControllers()

	for this_controller in steam_controllers:
		var this_controller_name: String = str(Steam.getInputTypeForHandle(this_controller))
		match this_controller_name:
			"0":
				print("unknown\n!");
			"1":
				print("Steam controller\n!");
			"2":
				print("XBox 360 controller\n!");
			"3":
				print("XBox One controller\n!");
			"4":
				print("Generic XInput\n!");
			"5":
				print("PS4 controller\n!");
	godot_controllers = Input.get_connected_joypads()


	if godot_controllers.size() > 0:
		for this_controller in godot_controllers:
			var _this_controller_name: String = Input.get_joy_name(this_controller)
			print(" 测试，godot手柄名称：", godot_controllers, _this_controller_name)
