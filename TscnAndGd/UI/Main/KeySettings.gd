extends Control

var ISKEY: bool = true
var cur_pressed: bool
var SettingBool: bool

onready var P1KeyBoard = get_node("P1KeyBoard")
onready var P2KeyBoard = get_node("P2KeyBoard")
onready var P1Joy = get_node("P1Joy")
onready var P2Joy = get_node("P2Joy")
onready var FirstBut = get_node("P1KeyBoard/MoveU")
onready var Ani = get_node("Ani")

func call_Show(_Switch: bool):

	match _Switch:
		true:
			ISKEY = false
			call_Setting_Ani(true)
			Ani.play("show")
		false:
			Ani.play("hide")
func _ready():
	call_deferred("call_init")
	if not GameLogic.is_connected("NewNetInfo", self, "_Join_Check"):
		var _RETURN = GameLogic.connect("NewNetInfo", self, "_Join_Check")

func call_grabfocus():


	call_Key_grabfocus()
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")

func call_Key_grabfocus():
	FirstBut.grab_focus()
func call_Joy_grabfocus():
	$P1Joy / MoveU.grab_focus()
func _Join_Check(_Type, _Info, _SteamID):

	if _Type == 3 and _Info == "网络-正在进入房间":

		if Ani.assigned_animation == "show":
			get_node("ButControl/BackBut").emit_signal("pressed")
			_Back_Logic()
			SettingBool = false
			call_Show(false)
			GameLogic.GameUI.PanelAni.play("hide")

var _CURBUT
func call_get_focus_owner():

	var _BUT = get_focus_owner()
	if not is_instance_valid(_CURBUT):
		_CURBUT = _BUT
	elif _CURBUT != _BUT:
		GameLogic.call_OPTIONSYNC()
	_CURBUT = _BUT
	_BUT.get_node("But").call_waiting(true)
	SettingBool = true
	get_node("ButControl/ApplyBut").call_pressed()

func _input(event):
	if SettingBool:

		var _BUT = get_focus_owner()
		if not is_instance_valid(_BUT):
			return
		if not _BUT.get_parent().name in ["P1KeyBoard", "P2KeyBoard", "P1Joy", "P2Joy"]:
			return
		if _BUT.get_parent().name in ["P1KeyBoard", "P2KeyBoard"]:
			if event is InputEventKey:
				if event.is_pressed():
					cur_pressed = true
					_But_Setting(_BUT, GameLogic.Con.TYPE.KEY, event.scancode, 1)
		elif _BUT.get_parent().name in ["P1Joy", "P2Joy"]:
			if event is InputEventJoypadButton:
				if event.is_pressed():

					cur_pressed = true
					_But_Setting(_BUT, GameLogic.Con.TYPE.BUTTON, event.button_index, 1)
			elif event is InputEventJoypadMotion:
				var _RE
				if event.axis_value >= 1:
					_RE = 1
				elif event.axis_value <= - 1:
					_RE = - 1
				if _RE:

					cur_pressed = true
					_But_Setting(_BUT, GameLogic.Con.TYPE.AXIS, event.axis, _RE)

func call_Setting_Ani(_ISKEY: bool):
	if ISKEY != _ISKEY:
		ISKEY = _ISKEY
		match ISKEY:
			true:
				$"控制/TYPE/Ani".play("Key")
				$"控制/TYPE/L1".disabled = true
				$"控制/TYPE/L1/L1".call_disabled(true)
				$"控制/TYPE/R1".disabled = false
				$"控制/TYPE/R1/R1".call_disabled(false)

			false:
				$"控制/TYPE/Ani".play("Joy")
				$"控制/TYPE/L1".disabled = false
				$"控制/TYPE/L1/L1".call_disabled(false)
				$"控制/TYPE/R1".disabled = true
				$"控制/TYPE/R1/R1".call_disabled(true)

func _Back_Logic():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.call_OPTIONSYNC()
func call_Back_Logic():
	_Back_Logic()

	if not SettingBool:
		get_node("ButControl/BackBut").call_pressed()

	else:
		if is_instance_valid(_CURBUT):
			_CURBUT.get_node("But").call_waiting(false)
			yield(get_tree().create_timer(0.1), "timeout")
			SettingBool = false
func _control_logic(_but, _value, _type):

	if not self.visible:
		return


	if _value < 1 and _value > - 1:
		cur_pressed = false
	if not SettingBool:
		match _but:
			"A":
				if (_value == 1 or _value == - 1) and not cur_pressed:

					call_get_focus_owner()
			"L1":
				if (_value == 1 or _value == - 1) and not cur_pressed:
					if not ISKEY:

						call_Setting_Ani(true)

			"R1":
				if (_value == 1 or _value == - 1) and not cur_pressed:
					if ISKEY:

						call_Setting_Ani(false)

			"B", "START":
				if (_value == 1 or _value == - 1) and not cur_pressed:

					get_node("ButControl/BackBut").call_pressed()
					get_node("ButControl/BackBut").emit_signal("pressed")
			"X":
				if (_value == 1 or _value == - 1) and not cur_pressed:
					get_node("ButControl/ResetBut").call_pressed()
					_Reset_All()
			"U", "u":
				if (_value == 1 or _value == - 1):
					if not cur_pressed:
						GameLogic.Audio.But_EasyClick.play(0)
						var _input = InputEventAction.new()
						_input.action = "ui_up"
						_input.pressed = true
						cur_pressed = true
						Input.parse_input_event(_input)
			"D", "d":
				if (_value == 1 or _value == - 1):
					if not cur_pressed:
						GameLogic.Audio.But_EasyClick.play(0)
						var _input = InputEventAction.new()
						_input.action = "ui_down"
						_input.pressed = true
						cur_pressed = true
						Input.parse_input_event(_input)
			"L", "l":
				if (_value == 1 or _value == - 1):
					if not cur_pressed:
						GameLogic.Audio.But_EasyClick.play(0)
						var _input = InputEventAction.new()
						_input.action = "ui_left"
						_input.pressed = true
						cur_pressed = true
						Input.parse_input_event(_input)
			"R", "r":
				if (_value == 1 or _value == - 1):
					if not cur_pressed:
						GameLogic.Audio.But_EasyClick.play(0)
						var _input = InputEventAction.new()
						_input.action = "ui_right"
						_input.pressed = true
						cur_pressed = true
						Input.parse_input_event(_input)
		if _type == 0:
			cur_pressed = false
func call_init():
	_P1KeyBoard_Set()
	_P2KeyBoard_Set()
	_P1Joy_Set()
	_P2Joy_Set()

	GameLogic.call_OPTIONSYNC()
	_Connect()
func _Connect():
	for _But in P1KeyBoard.get_children():

		if not _But.is_connected("focus_entered", _But.get_node("But"), "_on_focus_entered"):
			_But.connect("focus_entered", _But.get_node("But"), "_on_focus_entered")
		if not _But.is_connected("focus_exited", _But.get_node("But"), "_on_focus_exited"):
			_But.connect("focus_exited", _But.get_node("But"), "_on_focus_exited")

func _But_Setting(_BUT, _TYPE, _CODE, _RE):

	var _ININame: String
	var _Player: int
	if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
		_Player = 1
	if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
		_Player = 2
	var _Name = _BUT.name
	match _Name:
		"MoveU":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_move_up"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_move_up"
		"MoveD":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_move_down"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_move_down"
		"MoveL":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_move_left"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_move_left"
		"MoveR":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_move_right"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_move_right"
		"U":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_up"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_up"
		"D":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_down"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_down"
		"L":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_left"

			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_left"
		"R":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_right"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_right"
		"A":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_A"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_A"
		"B":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_B"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_B"
		"X":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_X"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_X"
		"Y":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_Y"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_Y"
		"L1":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_L1"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_L1"
		"R1":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_R1"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_R1"
		"START":
			if _BUT.get_parent().name in ["P1KeyBoard", "P1Joy"]:
				_ININame = "P1_Start"
			if _BUT.get_parent().name in ["P2KeyBoard", "P2Joy"]:
				_ININame = "P2_Start"
	if _ININame:

		match _TYPE:
			GameLogic.Con.TYPE.KEY:

				for _BUTINFO in GameLogic.GlobalData.keyboardini:

					var _CHECK: bool
					if _BUTINFO == _ININame:
						_CHECK = true

					match _ININame:
						"P1_move_up", "P1_up":
							if _BUTINFO in ["P1_move_up", "P1_up"]:
								_CHECK = true
						"P2_move_up", "P2_up":
							if _BUTINFO in ["P2_move_up", "P2_up"]:
								_CHECK = true
						"P1_move_down", "P1_down":
							if _BUTINFO in ["P1_move_down", "P1_down"]:
								_CHECK = true
						"P2_move_down", "P2_down":
							if _BUTINFO in ["P2_move_down", "P2_down"]:
								_CHECK = true
						"P1_move_left", "P1_left":
							if _BUTINFO in ["P1_move_left", "P1_left"]:
								_CHECK = true
						"P2_move_left", "P2_left":
							if _BUTINFO in ["P2_move_left", "P2_left"]:
								_CHECK = true
						"P1_move_right", "P1_right":
							if _BUTINFO in ["P1_move_right", "P1_right"]:

								_CHECK = true
						"P2_move_right", "P2_right":
							if _BUTINFO in ["P2_move_right", "P2_right"]:
								_CHECK = true
					if not _CHECK:
						if GameLogic.GlobalData.keyboardini[_BUTINFO].BUT == _CODE:
							if GameLogic.GlobalData.keyboardini[_BUTINFO].TYPE == _TYPE:
								if GameLogic.GlobalData.keyboardini[_BUTINFO].RE == _RE:
									_BUT.get_node("But").call_waiting_wrong()

									return
				GameLogic.Audio.But_Apply.play(0)

				_BUT.get_node("But").BUT = _CODE
				_BUT.get_node("But").BUT_TYPE = _TYPE
				_BUT.get_node("But").RE = _RE
				GameLogic.GlobalData.keyboardini[_ININame].BUT = _CODE
				GameLogic.GlobalData.keyboardini[_ININame].TYPE = _TYPE
				GameLogic.GlobalData.keyboardini[_ININame].RE = _RE


				GameLogic.call_OPTIONSYNC()
				GameLogic.GlobalData.globalinisave()
				cur_pressed = false
				yield(get_tree().create_timer(0.2), "timeout")
				SettingBool = false

			GameLogic.Con.TYPE.BUTTON, GameLogic.Con.TYPE.AXIS:

				for _BUTINFO in GameLogic.GlobalData.joyini:

					var _CHECK: bool
					if _ININame.left(2) != _BUTINFO.left(2):

						_CHECK = true
					if _BUTINFO == _ININame:
						_CHECK = true

					match _ININame:
						"P1_move_up", "P1_up":
							if _BUTINFO in ["P1_move_up", "P1_up"]:
								_CHECK = true
						"P2_move_up", "P2_up":
							if _BUTINFO in ["P2_move_up", "P2_up"]:
								_CHECK = true
						"P1_move_down", "P1_down":
							if _BUTINFO in ["P1_move_down", "P1_down"]:
								_CHECK = true
						"P2_move_down", "P2_down":
							if _BUTINFO in ["P2_move_down", "P2_down"]:
								_CHECK = true
						"P1_move_left", "P1_left":
							if _BUTINFO in ["P1_move_left", "P1_left"]:
								_CHECK = true
						"P2_move_left", "P2_left":
							if _BUTINFO in ["P2_move_left", "P2_left"]:
								_CHECK = true
						"P1_move_right", "P1_right":
							if _BUTINFO in ["P1_move_right", "P1_right"]:

								_CHECK = true
						"P2_move_right", "P2_right":
							if _BUTINFO in ["P2_move_right", "P2_right"]:
								_CHECK = true

					if not _CHECK:
						if GameLogic.GlobalData.joyini[_BUTINFO].BUT == _CODE:
							if GameLogic.GlobalData.joyini[_BUTINFO].TYPE == _TYPE:
								if GameLogic.GlobalData.joyini[_BUTINFO].RE == _RE:
									_BUT.get_node("But").call_waiting_wrong()

									return
				_BUT.get_node("But").BUT = _CODE
				_BUT.get_node("But").BUT_TYPE = _TYPE
				_BUT.get_node("But").RE = _RE
				GameLogic.GlobalData.joyini[_ININame].BUT = _CODE
				GameLogic.GlobalData.joyini[_ININame].TYPE = _TYPE
				GameLogic.GlobalData.joyini[_ININame].RE = _RE

				GameLogic.call_OPTIONSYNC()
				GameLogic.GlobalData.globalinisave()
				cur_pressed = false
				yield(get_tree().create_timer(0.2), "timeout")
				SettingBool = false

func _Reset_All():

	GameLogic.Audio.But_Apply.play(0)
	if SettingBool:
		SettingBool = false
	GameLogic.Con._Reset_All()
	call_init()
	GameLogic.call_OPTIONSYNC()
	GameLogic.GlobalData.globalinisave()
func _P1KeyBoard_Set():
	P1KeyBoard.get_node("MoveU/But").BUT = GameLogic.GlobalData.keyboardini["P1_move_up"].BUT
	P1KeyBoard.get_node("MoveD/But").BUT = GameLogic.GlobalData.keyboardini["P1_move_down"].BUT
	P1KeyBoard.get_node("MoveL/But").BUT = GameLogic.GlobalData.keyboardini["P1_move_left"].BUT
	P1KeyBoard.get_node("MoveR/But").BUT = GameLogic.GlobalData.keyboardini["P1_move_right"].BUT
	P1KeyBoard.get_node("U/But").BUT = GameLogic.GlobalData.keyboardini["P1_up"].BUT
	P1KeyBoard.get_node("D/But").BUT = GameLogic.GlobalData.keyboardini["P1_down"].BUT
	P1KeyBoard.get_node("L/But").BUT = GameLogic.GlobalData.keyboardini["P1_left"].BUT
	P1KeyBoard.get_node("R/But").BUT = GameLogic.GlobalData.keyboardini["P1_right"].BUT
	P1KeyBoard.get_node("A/But").BUT = GameLogic.GlobalData.keyboardini["P1_A"].BUT
	P1KeyBoard.get_node("B/But").BUT = GameLogic.GlobalData.keyboardini["P1_B"].BUT
	P1KeyBoard.get_node("X/But").BUT = GameLogic.GlobalData.keyboardini["P1_X"].BUT
	P1KeyBoard.get_node("Y/But").BUT = GameLogic.GlobalData.keyboardini["P1_Y"].BUT
	P1KeyBoard.get_node("L1/But").BUT = GameLogic.GlobalData.keyboardini["P1_L1"].BUT
	P1KeyBoard.get_node("R1/But").BUT = GameLogic.GlobalData.keyboardini["P1_R1"].BUT
	P1KeyBoard.get_node("START/But").BUT = GameLogic.GlobalData.keyboardini["P1_Start"].BUT

	P1KeyBoard.get_node("MoveU/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_move_up"].TYPE
	P1KeyBoard.get_node("MoveD/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_move_down"].TYPE
	P1KeyBoard.get_node("MoveL/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_move_left"].TYPE
	P1KeyBoard.get_node("MoveR/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_move_right"].TYPE
	P1KeyBoard.get_node("U/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_up"].TYPE
	P1KeyBoard.get_node("D/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_down"].TYPE
	P1KeyBoard.get_node("L/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_left"].TYPE
	P1KeyBoard.get_node("R/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_right"].TYPE
	P1KeyBoard.get_node("A/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_A"].TYPE
	P1KeyBoard.get_node("B/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_B"].TYPE
	P1KeyBoard.get_node("X/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_X"].TYPE
	P1KeyBoard.get_node("Y/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_Y"].TYPE
	P1KeyBoard.get_node("L1/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_L1"].TYPE
	P1KeyBoard.get_node("R1/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_R1"].TYPE
	P1KeyBoard.get_node("START/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_Start"].TYPE

func _P2KeyBoard_Set():
	P2KeyBoard.get_node("MoveU/But").BUT = GameLogic.GlobalData.keyboardini["P2_move_up"].BUT
	P2KeyBoard.get_node("MoveD/But").BUT = GameLogic.GlobalData.keyboardini["P2_move_down"].BUT
	P2KeyBoard.get_node("MoveL/But").BUT = GameLogic.GlobalData.keyboardini["P2_move_left"].BUT
	P2KeyBoard.get_node("MoveR/But").BUT = GameLogic.GlobalData.keyboardini["P2_move_right"].BUT
	P2KeyBoard.get_node("U/But").BUT = GameLogic.GlobalData.keyboardini["P2_up"].BUT
	P2KeyBoard.get_node("D/But").BUT = GameLogic.GlobalData.keyboardini["P2_down"].BUT
	P2KeyBoard.get_node("L/But").BUT = GameLogic.GlobalData.keyboardini["P2_left"].BUT
	P2KeyBoard.get_node("R/But").BUT = GameLogic.GlobalData.keyboardini["P2_right"].BUT
	P2KeyBoard.get_node("A/But").BUT = GameLogic.GlobalData.keyboardini["P2_A"].BUT
	P2KeyBoard.get_node("B/But").BUT = GameLogic.GlobalData.keyboardini["P2_B"].BUT
	P2KeyBoard.get_node("X/But").BUT = GameLogic.GlobalData.keyboardini["P2_X"].BUT
	P2KeyBoard.get_node("Y/But").BUT = GameLogic.GlobalData.keyboardini["P2_Y"].BUT
	P2KeyBoard.get_node("L1/But").BUT = GameLogic.GlobalData.keyboardini["P2_L1"].BUT
	P2KeyBoard.get_node("R1/But").BUT = GameLogic.GlobalData.keyboardini["P2_R1"].BUT
	P2KeyBoard.get_node("START/But").BUT = GameLogic.GlobalData.keyboardini["P2_Start"].BUT

	P2KeyBoard.get_node("MoveU/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_move_up"].TYPE
	P2KeyBoard.get_node("MoveD/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_move_down"].TYPE
	P2KeyBoard.get_node("MoveL/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_move_left"].TYPE
	P2KeyBoard.get_node("MoveR/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_move_right"].TYPE
	P2KeyBoard.get_node("U/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_up"].TYPE
	P2KeyBoard.get_node("D/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_down"].TYPE
	P2KeyBoard.get_node("L/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_left"].TYPE
	P2KeyBoard.get_node("R/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_right"].TYPE
	P2KeyBoard.get_node("A/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_A"].TYPE
	P2KeyBoard.get_node("B/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_B"].TYPE
	P2KeyBoard.get_node("X/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_X"].TYPE
	P2KeyBoard.get_node("Y/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_Y"].TYPE
	P2KeyBoard.get_node("L1/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_L1"].TYPE
	P2KeyBoard.get_node("R1/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_R1"].TYPE
	P2KeyBoard.get_node("START/But").BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_Start"].TYPE
func _P1Joy_Set():
	P1Joy.get_node("MoveU/But").BUT = GameLogic.GlobalData.joyini["P1_move_up"].BUT
	P1Joy.get_node("MoveD/But").BUT = GameLogic.GlobalData.joyini["P1_move_down"].BUT
	P1Joy.get_node("MoveL/But").BUT = GameLogic.GlobalData.joyini["P1_move_left"].BUT
	P1Joy.get_node("MoveR/But").BUT = GameLogic.GlobalData.joyini["P1_move_right"].BUT
	P1Joy.get_node("U/But").BUT = GameLogic.GlobalData.joyini["P1_up"].BUT
	P1Joy.get_node("D/But").BUT = GameLogic.GlobalData.joyini["P1_down"].BUT
	P1Joy.get_node("L/But").BUT = GameLogic.GlobalData.joyini["P1_left"].BUT
	P1Joy.get_node("R/But").BUT = GameLogic.GlobalData.joyini["P1_right"].BUT
	P1Joy.get_node("A/But").BUT = GameLogic.GlobalData.joyini["P1_A"].BUT
	P1Joy.get_node("B/But").BUT = GameLogic.GlobalData.joyini["P1_B"].BUT
	P1Joy.get_node("X/But").BUT = GameLogic.GlobalData.joyini["P1_X"].BUT
	P1Joy.get_node("Y/But").BUT = GameLogic.GlobalData.joyini["P1_Y"].BUT
	P1Joy.get_node("L1/But").BUT = GameLogic.GlobalData.joyini["P1_L1"].BUT
	P1Joy.get_node("R1/But").BUT = GameLogic.GlobalData.joyini["P1_R1"].BUT
	P1Joy.get_node("START/But").BUT = GameLogic.GlobalData.joyini["P1_Start"].BUT

	P1Joy.get_node("MoveU/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_move_up"].TYPE
	P1Joy.get_node("MoveD/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_move_down"].TYPE
	P1Joy.get_node("MoveL/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_move_left"].TYPE
	P1Joy.get_node("MoveR/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_move_right"].TYPE
	P1Joy.get_node("U/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_up"].TYPE
	P1Joy.get_node("D/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_down"].TYPE
	P1Joy.get_node("L/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_left"].TYPE
	P1Joy.get_node("R/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_right"].TYPE
	P1Joy.get_node("A/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_A"].TYPE
	P1Joy.get_node("B/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_B"].TYPE
	P1Joy.get_node("X/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_X"].TYPE
	P1Joy.get_node("Y/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_Y"].TYPE
	P1Joy.get_node("L1/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_L1"].TYPE
	P1Joy.get_node("R1/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_R1"].TYPE
	P1Joy.get_node("START/But").BUT_TYPE = GameLogic.GlobalData.joyini["P1_Start"].TYPE

	P1Joy.get_node("MoveU/But").RE = GameLogic.GlobalData.joyini["P1_move_up"].RE
	P1Joy.get_node("MoveD/But").RE = GameLogic.GlobalData.joyini["P1_move_down"].RE
	P1Joy.get_node("MoveL/But").RE = GameLogic.GlobalData.joyini["P1_move_left"].RE
	P1Joy.get_node("MoveR/But").RE = GameLogic.GlobalData.joyini["P1_move_right"].RE
	P1Joy.get_node("U/But").RE = GameLogic.GlobalData.joyini["P1_up"].RE
	P1Joy.get_node("D/But").RE = GameLogic.GlobalData.joyini["P1_down"].RE
	P1Joy.get_node("L/But").RE = GameLogic.GlobalData.joyini["P1_left"].RE
	P1Joy.get_node("R/But").RE = GameLogic.GlobalData.joyini["P1_right"].RE
	P1Joy.get_node("A/But").RE = GameLogic.GlobalData.joyini["P1_A"].RE
	P1Joy.get_node("B/But").RE = GameLogic.GlobalData.joyini["P1_B"].RE
	P1Joy.get_node("X/But").RE = GameLogic.GlobalData.joyini["P1_X"].RE
	P1Joy.get_node("Y/But").RE = GameLogic.GlobalData.joyini["P1_Y"].RE
	P1Joy.get_node("L1/But").RE = GameLogic.GlobalData.joyini["P1_L1"].RE
	P1Joy.get_node("R1/But").RE = GameLogic.GlobalData.joyini["P1_R1"].RE
	P1Joy.get_node("START/But").RE = GameLogic.GlobalData.joyini["P1_Start"].RE

func _P2Joy_Set():
	P2Joy.get_node("MoveU/But").BUT = GameLogic.GlobalData.joyini["P2_move_up"].BUT
	P2Joy.get_node("MoveD/But").BUT = GameLogic.GlobalData.joyini["P2_move_down"].BUT
	P2Joy.get_node("MoveL/But").BUT = GameLogic.GlobalData.joyini["P2_move_left"].BUT
	P2Joy.get_node("MoveR/But").BUT = GameLogic.GlobalData.joyini["P2_move_right"].BUT
	P2Joy.get_node("U/But").BUT = GameLogic.GlobalData.joyini["P2_up"].BUT
	P2Joy.get_node("D/But").BUT = GameLogic.GlobalData.joyini["P2_down"].BUT
	P2Joy.get_node("L/But").BUT = GameLogic.GlobalData.joyini["P2_left"].BUT
	P2Joy.get_node("R/But").BUT = GameLogic.GlobalData.joyini["P2_right"].BUT
	P2Joy.get_node("A/But").BUT = GameLogic.GlobalData.joyini["P2_A"].BUT
	P2Joy.get_node("B/But").BUT = GameLogic.GlobalData.joyini["P2_B"].BUT
	P2Joy.get_node("X/But").BUT = GameLogic.GlobalData.joyini["P2_X"].BUT
	P2Joy.get_node("Y/But").BUT = GameLogic.GlobalData.joyini["P2_Y"].BUT
	P2Joy.get_node("L1/But").BUT = GameLogic.GlobalData.joyini["P2_L1"].BUT
	P2Joy.get_node("R1/But").BUT = GameLogic.GlobalData.joyini["P2_R1"].BUT
	P2Joy.get_node("START/But").BUT = GameLogic.GlobalData.joyini["P2_Start"].BUT

	P2Joy.get_node("MoveU/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_move_up"].TYPE
	P2Joy.get_node("MoveD/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_move_down"].TYPE
	P2Joy.get_node("MoveL/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_move_left"].TYPE
	P2Joy.get_node("MoveR/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_move_right"].TYPE
	P2Joy.get_node("U/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_up"].TYPE
	P2Joy.get_node("D/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_down"].TYPE
	P2Joy.get_node("L/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_left"].TYPE
	P2Joy.get_node("R/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_right"].TYPE
	P2Joy.get_node("A/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_A"].TYPE
	P2Joy.get_node("B/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_B"].TYPE
	P2Joy.get_node("X/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_X"].TYPE
	P2Joy.get_node("Y/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_Y"].TYPE
	P2Joy.get_node("L1/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_L1"].TYPE
	P2Joy.get_node("R1/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_R1"].TYPE
	P2Joy.get_node("START/But").BUT_TYPE = GameLogic.GlobalData.joyini["P2_Start"].TYPE

	P2Joy.get_node("MoveU/But").RE = GameLogic.GlobalData.joyini["P2_move_up"].RE
	P2Joy.get_node("MoveD/But").RE = GameLogic.GlobalData.joyini["P2_move_down"].RE
	P2Joy.get_node("MoveL/But").RE = GameLogic.GlobalData.joyini["P2_move_left"].RE
	P2Joy.get_node("MoveR/But").RE = GameLogic.GlobalData.joyini["P2_move_right"].RE
	P2Joy.get_node("U/But").RE = GameLogic.GlobalData.joyini["P2_up"].RE
	P2Joy.get_node("D/But").RE = GameLogic.GlobalData.joyini["P2_down"].RE
	P2Joy.get_node("L/But").RE = GameLogic.GlobalData.joyini["P2_left"].RE
	P2Joy.get_node("R/But").RE = GameLogic.GlobalData.joyini["P2_right"].RE
	P2Joy.get_node("A/But").RE = GameLogic.GlobalData.joyini["P2_A"].RE
	P2Joy.get_node("B/But").RE = GameLogic.GlobalData.joyini["P2_B"].RE
	P2Joy.get_node("X/But").RE = GameLogic.GlobalData.joyini["P2_X"].RE
	P2Joy.get_node("Y/But").RE = GameLogic.GlobalData.joyini["P2_Y"].RE
	P2Joy.get_node("L1/But").RE = GameLogic.GlobalData.joyini["P2_L1"].RE
	P2Joy.get_node("R1/But").RE = GameLogic.GlobalData.joyini["P2_R1"].RE
	P2Joy.get_node("START/But").RE = GameLogic.GlobalData.joyini["P2_Start"].RE
