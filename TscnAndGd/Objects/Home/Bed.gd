extends Head_Object

var FirstJoy: int = - 1
var CanInput: bool

onready var ControlAni = get_node("AniNode/BedLogicAni")
onready var KeyboardAni = get_node("AniNode/KeyboardAni")
onready var Joy1Ani = get_node("AniNode/Joy1Ani")
onready var Joy2Ani = get_node("AniNode/Joy2Ani")
onready var Joy1Stick = get_node("PlayerSet/BG/P1/Joystick2")
onready var Joy2Stick = get_node("PlayerSet/BG/P2/Joystick2")

onready var ButShow = get_node("Button/A")
var Control_1_mot: bool
var OpenAudio
func _ready() -> void :

	call_deferred("_ApplyAni_logic")
	call_deferred("_Audio_init")

func _Audio_init():
	OpenAudio = GameLogic.Audio.return_Effect("气泡")
	pass
func _ApplyAni_logic():

	if FirstJoy == - 1:
		if GameLogic.Con.player1P_Joy >= 0:
			FirstJoy = GameLogic.Con.player1P_Joy
		elif GameLogic.Con.player2P_Joy >= 0:
			FirstJoy = GameLogic.Con.player2P_Joy
	if GameLogic.Con.player2P_Keyboard:
		KeyboardAni.play("P2")
		get_node("PlayerSet/BG/P2/Keyboard/Back/Y").show()
	else:
		KeyboardAni.play("P1")

	var JoyList = Input.get_connected_joypads()
	if JoyList.size() < 2:
		Joy1Stick.hide()
		Joy2Stick.hide()
	else:
		Joy1Stick.show()
		Joy2Stick.show()
	if FirstJoy != - 1 and GameLogic.Con.player1P_Joy == FirstJoy:
		Joy1Ani.play("P1")
	elif FirstJoy != - 1 and GameLogic.Con.player2P_Joy == FirstJoy:
		Joy1Ani.play("P2")
	else:
		Joy1Ani.play("none")
	if GameLogic.Con.player1P_Joy > - 1 and GameLogic.Con.player1P_Joy != FirstJoy:
		Joy2Ani.play("P1")
	elif GameLogic.Con.player2P_Joy > - 1 and GameLogic.Con.player2P_Joy != FirstJoy:
		Joy2Ani.play("P2")
	else:
		Joy2Ani.play("none")

func can_input():
	CanInput = true
var _COOPQUICKBOOL: bool
func _input(event: InputEvent) -> void :

	if not CanInput and _COOPQUICKBOOL:
		if not SteamLogic.IsMultiplay:
			if not GameLogic.Player2_bool:
				if Input.is_key_pressed(GameLogic.Con.P2KEYBOARD.A.BUT):
					GameLogic.Con.player2P_Keyboard = true
					GameLogic.Player2_bool = true
					GameLogic.player_2P.show()
					GameLogic.player_2P.Collision.disabled = false
					GameLogic.Con.call_player2P_set()
				if event is InputEventJoypadButton:

					if event.device != GameLogic.Con.player1P_Joy and GameLogic.Con.player2P_Joy == - 1:

						match event.button_index:
							0:
								GameLogic.Con.player2P_Joy = event.device
								GameLogic.Con.player2P_Keyboard = true
								GameLogic.Player2_bool = true
								GameLogic.player_2P.show()
								GameLogic.player_2P.Collision.disabled = false
								GameLogic.Con.call_player2P_set()
								_ApplyAni_logic()
								return
			else:
				if Input.is_key_pressed(GameLogic.Con.P2KEYBOARD.Y.BUT):
					GameLogic.Con.player2P_Keyboard = false
					GameLogic.Player2_bool = false
					GameLogic.player_2P.hide()
					GameLogic.player_2P.Collision.disabled = true
					GameLogic.Con.call_player2P_set()
				if event is InputEventJoypadButton:
					if event.device == GameLogic.Con.player2P_Joy and event.device != GameLogic.Con.player1P_Joy:
						match event.button_index:
							3:
								GameLogic.Con.player2P_Joy = - 1
								GameLogic.Con.player2P_Keyboard = false
								GameLogic.Player2_bool = false
								GameLogic.player_2P.hide()
								GameLogic.player_2P.Collision.disabled = true
								GameLogic.Con.call_player2P_set()
								_ApplyAni_logic()
	if not CanInput:
		return


	if Input.is_key_pressed(GameLogic.Con.P2KEYBOARD.X.BUT):
		if not GameLogic.Con.player2P_Keyboard:
			GameLogic.Con.player2P_Keyboard = true
			GameLogic.Audio.But_SwitchOff.play(0)
	elif Input.is_key_pressed(GameLogic.Con.P2KEYBOARD.Y.BUT):
		if GameLogic.Con.player2P_Keyboard:
			GameLogic.Con.player2P_Keyboard = false
			GameLogic.Audio.But_SwitchOn.play(0)
	if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.B.BUT):
		get_node("PlayerSet/BG/Apply").call_pressed()
		_check()
	if Input.is_key_pressed(GameLogic.Con.P1KEYBOARD.START.BUT):
		get_node("PlayerSet/BG/Apply").call_pressed()
		_check()
	if Input.is_key_pressed(GameLogic.Con.P2KEYBOARD.B.BUT):
		get_node("PlayerSet/BG/Apply").call_pressed()
		_check()
	if Input.is_key_pressed(GameLogic.Con.P2KEYBOARD.START.BUT):
		get_node("PlayerSet/BG/Apply").call_pressed()
		_check()
	if event is InputEventJoypadMotion:

		if event.axis_value == 0:
			Control_1_mot = false

		if event.axis_value >= 0.5 and not Control_1_mot:
			Control_1_mot = true
			if GameLogic.Con.player2P_Joy != event.device:

				GameLogic.Con.player2P_Joy = event.device
				if GameLogic.Con.player1P_Joy == event.device:
					GameLogic.Con.player1P_Joy = - 1
				GameLogic.Audio.But_SwitchOn.play(0)
			else:
				pass
		elif event.axis_value <= - 0.5 and not Control_1_mot:
			Control_1_mot = true
			if GameLogic.Con.player2P_Joy == event.device:
				GameLogic.Con.player1P_Joy = event.device
				GameLogic.Con.player2P_Joy = - 1
				GameLogic.Audio.But_SwitchOn.play(0)
			elif GameLogic.Con.player1P_Joy != event.device:
				GameLogic.Con.player1P_Joy = event.device
				GameLogic.Audio.But_SwitchOn.play(0)

	if event is InputEventJoypadButton:

		if FirstJoy < 0:
			if GameLogic.Con.player1P_Joy == - 1 and GameLogic.Con.player2P_Joy == - 1:
				match event.button_index:
					14:
						GameLogic.Con.player1P_Joy = event.device
						FirstJoy = event.device
						GameLogic.Audio.But_SwitchOn.play(0)
					15:
						GameLogic.Con.player2P_Joy = event.device
						FirstJoy = event.device
						GameLogic.Audio.But_SwitchOn.play(0)
		else:
			match event.button_index:
				14:
					if event.device == GameLogic.Con.player2P_Joy and event.device != GameLogic.Con.player1P_Joy:

						GameLogic.Con.player1P_Joy = event.device
						GameLogic.Con.player2P_Joy = - 1
						GameLogic.Audio.But_SwitchOn.play(0)
					elif event.device != GameLogic.Con.player2P_Joy and event.device != GameLogic.Con.player1P_Joy:

						GameLogic.Con.player1P_Joy = event.device
						GameLogic.Audio.But_SwitchOn.play(0)
				3:
					if event.device == GameLogic.Con.player1P_Joy and event.device != GameLogic.Con.player2P_Joy:

						GameLogic.Con.player1P_Joy = - 1
						GameLogic.Audio.But_SwitchOff.play(0)
					elif event.device != GameLogic.Con.player1P_Joy and event.device == GameLogic.Con.player2P_Joy:

						GameLogic.Con.player2P_Joy = - 1
						GameLogic.Audio.But_SwitchOff.play(0)
					if GameLogic.Con.player1P_Joy == - 1 and GameLogic.Con.player2P_Joy == - 1:
						FirstJoy = - 1
						GameLogic.Audio.But_SwitchOff.play(0)
				1:

					_check()

				15:
					if event.device == GameLogic.Con.player1P_Joy and event.device != GameLogic.Con.player2P_Joy:

						GameLogic.Con.player2P_Joy = event.device
						GameLogic.Con.player1P_Joy = - 1
						GameLogic.Audio.But_SwitchOn.play(0)
					elif event.device != GameLogic.Con.player2P_Joy and event.device != GameLogic.Con.player1P_Joy:

						GameLogic.Con.player2P_Joy = event.device
						GameLogic.Audio.But_SwitchOn.play(0)

	_ApplyAni_logic()

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			if not CanInput:
				ButShow.call_player_in(_Player.cur_Player)
		- 2:
			if not CanInput:
				ButShow.call_player_out(_Player.cur_Player)
		0, "A":

			if SteamLogic.IsMultiplay:
				_Player.call_Say_NoUse()
				get_node("2P/Ani").play("init")
				return
			else:
				get_node("2P/Ani").play("play")
			if is_instance_valid(GameLogic.player_1P):
				if GameLogic.player_1P.Con.CanControl:

					GameLogic.player_1P.call_control(2)
					GameLogic.player_2P.call_control(2)
					_Player.Con.cur_UI = self
					ControlAni.play("show")
					GameLogic.Can_ESC = false
					_ApplyAni_logic()

					set_process_input(true)
					OpenAudio.play(0)
					call_But_init()

					return true
func call_But_init():
	var _ININame = "P2_A"
	if _ININame:
		var _INFO = GameLogic.GlobalData.keyboardini[_ININame]

	_ININame = "P2_B"
	if _ININame:
		var _INFO = GameLogic.GlobalData.keyboardini[_ININame]

func _check():
	if not CanInput:
		return

	GameLogic.Audio.But_Apply.play(0)
	ControlAni.play("hide")
	CanInput = false

	GameLogic.player_1P.call_control(0)
	GameLogic.player_2P.call_control(0)

	GameLogic.Con.call_player1P_set()
	GameLogic.Con.call_player2P_set()
	if GameLogic.Con.player2P_Joy == - 1 and not GameLogic.Con.player2P_Keyboard:
		if GameLogic.Player2_bool:
			GameLogic.Player2_bool = false
			GameLogic.player_2P.hide()
			GameLogic.player_2P.Collision.disabled = true
	elif GameLogic.Con.player2P_Joy > - 1 or GameLogic.Con.player2P_Keyboard:

		if not GameLogic.Player2_bool:
			if not SteamLogic.IsMultiplay:
				GameLogic.Player2_bool = true
				GameLogic.player_2P.show()
				GameLogic.player_2P.Collision.disabled = false

				var _Par = get_parent().get_parent().get_parent()
				if _Par.has_method("call_camera_init"):
					_Par.call_camera_init()
					_Par.set_process(true)

	if GameLogic.Player2_bool:
		get_node("2P/Ani").play("init")
	yield(get_tree().create_timer(0.1), "timeout")
	GameLogic.Can_ESC = true
