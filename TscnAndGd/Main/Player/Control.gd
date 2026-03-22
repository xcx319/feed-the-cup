extends Node

var input_vector = Vector2.ZERO
var input_vector_save = Vector2.ZERO
var _Vector_Save = Vector2.DOWN
var IsRoll: bool
var CanRoll: bool = true
var input_joy = Vector2.ZERO
var input_key = Vector2.ZERO
var velocity = Vector2.ZERO
var _RollTime: float = 0

onready var base_vel = Vector2.ZERO
var Keyboard_bool: bool
var Joy_bool: bool
var JoyDevice: int
var KeyboardType: int
var CanControl: bool
var IsPause: bool
var CanMove: bool = true
var cur_UI

onready var Stat = get_parent().get_node("Stat")
onready var playerNode = get_parent().get_parent()

onready var GameUI = GameLogic.GameUI

var state = GameLogic.NPC.STATE.IDLE_EMPTY setget call_state
var ArmState = GameLogic.NPC.STATE.IDLE_EMPTY setget call_ArmState
var IsHold: bool
var IsMixing: bool
var NeedPush: bool
var HoldInsId: int
var HoldObj
var JOYCONTROL: Dictionary
var KEYCONTROL: Dictionary
var BUT: Dictionary = {
	A = - 1,
	B = - 1,
	X = - 1,
	Y = - 1,
	UP = - 1,
	DOWN = - 1,
	LEFT = - 1,
	RIGHT = - 1,
	L1 = - 1,
	L2 = - 1,
	L3 = - 1,
	R1 = - 1,
	R2 = - 1,
	R3 = - 1,
	BACK = - 1,
	START = - 1,
}

var stateSave = GameLogic.NPC.STATE.IDLE_EMPTY
func call_ArmState(_ARMSTATE):
	ArmState = _ARMSTATE
	playerNode.call_StatChange()
func call_state(_STATE):
	if stateSave != _STATE:
		stateSave = _STATE
	state = _STATE
	playerNode.call_StatChange()

func _ready() -> void :
	set_physics_process(false)
	JoyDevice = - 1
	CanControl = true
	call_deferred("_connect_init")

func call_WORK():
	call_ArmState(GameLogic.NPC.STATE.WORK)

func call_SHAKE():
	call_ArmState(GameLogic.NPC.STATE.SHAKE)

func call_STIR():

	call_ArmState(GameLogic.NPC.STATE.STIR)

	yield(get_tree().create_timer(1.0), "timeout")
	call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

var SQUEEZESPEED: float = 1
func call_SQUEEZE(_SpeedMult: float):

	call_ArmState(GameLogic.NPC.STATE.SQUEEZE)

	SQUEEZESPEED = _SpeedMult

func call_resetArm_puppet():
	call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

func call_reset_ArmState():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_resetArm_puppet")

	call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

func _keyboard_set():

	match KeyboardType:
		1:
			KEYCONTROL = GameLogic.Con.P1KEYBOARD

		2:
			KEYCONTROL = GameLogic.Con.P2KEYBOARD

		_:
			KEYCONTROL = GameLogic.Con.P1KEYBOARD

func _joy_set():

	if playerNode.cur_Player in [1, SteamLogic.STEAM_ID]:
		JOYCONTROL = GameLogic.Con.P1JOY


		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

			GameLogic.Con.connect("P1_Control", self, "call_SteamControl_Logic")
		else:

			GameLogic.Con.connect("P1_Control", self, "_control_logic")
	elif playerNode.cur_Player == 2:
		JOYCONTROL = GameLogic.Con.P2JOY
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

			pass
		else:

			GameLogic.Con.connect("P2_Control", self, "_control_logic")
	else:
		if playerNode.IsStaff:
			return
		JOYCONTROL = GameLogic.Con.P1JOY

func _connect_init():

	if playerNode.cur_Player in [1, SteamLogic.STEAM_ID]:
		GameLogic.Con.connect("P1_Control_init", self, "_P1_Control_Set")

		Keyboard_bool = true
		KeyboardType = 1
		_keyboard_set()
		if GameLogic.Con.player1P_Joy > - 1:
			Joy_bool = true
		JoyDevice = GameLogic.Con.player1P_Joy
		_joy_set()

	elif playerNode.cur_Player == 2:

		GameLogic.Con.connect("P2_Control_init", self, "_P2_Control_Set")

		Keyboard_bool = true
		KeyboardType = 2
		_keyboard_set()
		if GameLogic.Con.player2P_Joy > - 1:
			Joy_bool = true
		JoyDevice = GameLogic.Con.player2P_Joy
		_joy_set()

	else:

		KeyboardType = - 1
		_joy_set()

	set_physics_process(true)

func call_PlayerSYNC(_Type: String, _Data: Array):
	var _Pos = _Data[1]
	match _Type:
		"Move":
			var _Input = _Data[0]
			input_vector = _Input
			playerNode.FaceRay_Cast()
		"PuppetBut":
			if SteamLogic.LOBBY_IsMaster:
				var _but = _Data[2]
				var _value = _Data[3]
				var _type = _Data[4]
				var _NodePos = _Data[1]
				var _NodeFace = _Data[5]
				playerNode.position = _NodePos
				playerNode.AVATAR.FACE = _NodeFace
				playerNode.FaceRay_Cast()
				_control_logic(_but, _value, _type)
		"PlayerBut":
			if not SteamLogic.LOBBY_IsMaster:
				var _Path = _Data[0]
				if not has_node(_Path):
					return
				var _OBJ = get_node(_Path)
				var _TYPE = _Data[1]
				var _But = _Data[2]
				if is_instance_valid(_OBJ):
					match _TYPE:
						"Call_CheckLogic":
							var _check = GameLogic.Device.Call_CheckLogic(_But, playerNode, _OBJ)
						"call_TouchDev_Logic":
							var _return = GameLogic.Device.call_TouchDev_Logic( - 1, playerNode, _OBJ)
						"return_SQUEEZE_start":
							var _Mix_bool = _OBJ.return_SQUEEZE_start(playerNode, 1.0)
							if _Mix_bool:
								call_ArmState(GameLogic.NPC.STATE.SQUEEZE)

								return "SQUEEZE"
							else:

								call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						"return_STIR_start":
							var _Mix_bool = _OBJ.return_STIR_start(playerNode)
							if _Mix_bool:
								call_ArmState(GameLogic.NPC.STATE.STIR)

								return "STIR"
							else:

								call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						"return_SHAKE_start":
							var _Mix_bool = _OBJ.return_SHAKE_start(playerNode)
							if _Mix_bool:
								call_ArmState(GameLogic.NPC.STATE.SHAKE)

								return "SHAKE"
							else:

								call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						"return_Shovel_start":
							var _Mix_bool = _OBJ.return_Shovel_start(playerNode, 1.0)
							if _Mix_bool:
								call_ArmState(GameLogic.NPC.STATE.SHOVEL)

								return "WORK"
							else:
								call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						"return_WORK_start":

							var _Mix_bool = _OBJ.return_WORK_start(playerNode, 1.0)
							if _Mix_bool:
								call_ArmState(GameLogic.NPC.STATE.WORK)

								return "WORK"
							else:

								call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						"return_CanMix":

							var _Mix_bool = _OBJ.return_CanMix(playerNode)
							if _Mix_bool:
								playerNode.call_Mix_Start(_OBJ)
								return "MIX"
						"ItemLogic_PutOnGround":

							var _check = GameLogic.Device.ItemLogic_PutOnGround(JOYCONTROL.Y.BUT, playerNode, _OBJ)
						"call_esc":

							GameUI.call_esc(_But)
func _P1_Control_Set():

	if GameLogic.Con.player1P_Keyboard:
		Keyboard_bool = true
	else:
		Keyboard_bool = false
	if GameLogic.Con.player1P_Joy > - 1:
		Joy_bool = true
		JoyDevice = GameLogic.Con.player1P_Joy
	else:
		Joy_bool = false
		JoyDevice = - 1
	playerNode.call_control(0)


	cur_UI = null

func _P2_Control_Set():
	if GameLogic.Con.player2P_Keyboard:
		Keyboard_bool = true
	else:
		Keyboard_bool = false
	if GameLogic.Con.player2P_Joy > - 1:
		Joy_bool = true
		JoyDevice = GameLogic.Con.player2P_Joy
	else:
		Joy_bool = false
		JoyDevice = - 1
	if GameLogic.Player2_bool:
		playerNode.call_control(0)
	else:
		playerNode.call_control(1)

	cur_UI = null

func call_SteamControl_Logic(_but, _value, _type):

	if _but in ["START", "L1", "R1"]:
		if _but in ["R1"]:
			if not CanControl or IsPause:
				return
		_control_logic(_but, _value, _type)
	elif is_instance_valid(playerNode.cur_RayObj):
		if not CanControl or IsPause:
			return
		if playerNode.cur_RayObj.has_method("call_home_device"):
			var _RETURN = playerNode.cur_RayObj.call_home_device(_but, _value, _type, playerNode)
			if _RETURN:
				return

	if _but in ["A", "B", "X", "Y", "UP", "DOWN", "LEFT", "RIGHT", "R1"] and _value == 0:
		pass
	if _but in ["A", "B", "X", "Y", "UP", "DOWN", "LEFT", "RIGHT", "R1"]:
		SteamLogic.call_master_node_sync(self, "call_master_control_logic", [playerNode.global_position, playerNode.cur_face, _but, _value, _type])

	pass
func call_master_control_logic(_POS, _FACE, _but, _value, _type):
	print("呼叫主机操作：", _POS, _FACE, _but, _value, _type)
	playerNode.position = _POS
	playerNode.cur_face = _FACE
	playerNode.FaceRay_Cast()
	_control_logic(_but, _value, _type)
func call_PlayerNode_Set(_POS):
	playerNode.position = _POS

func _control_logic(_but, _value, _type):

	match _but:

		"A":
			if not CanControl or IsPause:
				return
			if _IsSKILL and Stat.Skills.has("技能-穿透"):
				return

			_Button_Pressed(JOYCONTROL.A.BUT, _type, _value)
		"B":
			if not CanControl or IsPause:
				return
			if _IsSKILL and Stat.Skills.has("技能-穿透"):
				return
			var _MainMenuSHOW = GameLogic.GameUI.MainMenu.visible
			var _NAME = playerNode.cur_Player
			if _MainMenuSHOW and _NAME == SteamLogic.STEAM_ID:
				return

			_Button_Pressed(JOYCONTROL.B.BUT, _type, _value)
		"X":
			if not CanControl or IsPause:
				if IsHold:
					var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
					if _HoldObj.has_method("call_WORKING_end") and _value == 0:
						_HoldObj.call_WORKING_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
				return

			if _IsSKILL and Stat.Skills.has("技能-穿透"):
				return

			_Button_Pressed(JOYCONTROL.X.BUT, _type, _value)
		"Y":
			if not CanControl or IsPause:
				if IsHold:
					var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
					if _HoldObj.has_method("call_WORKING_end") and _value == 0:
						_HoldObj.call_WORKING_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
				return
			if _IsSKILL and Stat.Skills.has("技能-穿透"):
				return

			_Button_Pressed(JOYCONTROL.Y.BUT, _type, _value)
		"UP":
			if not CanControl or IsPause:
				return
			_Button_Pressed(JOYCONTROL.UP.BUT, _type, _value)
		"dOWN":
			if not CanControl or IsPause:
				return
			_Button_Pressed(JOYCONTROL.DOWN.BUT, _type, _value)
		"LEFT":
			if not CanControl or IsPause:
				return
			_Button_Pressed(JOYCONTROL.LEFT.BUT, _type, _value)
		"RIGHT":
			if not CanControl or IsPause:
				return
			_Button_Pressed(JOYCONTROL.RIGHT.BUT, _type, _value)

		"L1":
			if IsPause:
				return
			_Button_Pressed(JOYCONTROL.L1.BUT, _type, _value)
		"R1":
			if not CanControl or IsPause:
				return
			_Button_Pressed(JOYCONTROL.R1.BUT, _type, _value)
		"START":


			_Button_Pressed(JOYCONTROL.START.BUT, _type, _value)

func return_Move_Control():

	if not playerNode.visible:
		return Vector2.ZERO
	if not CanControl or IsPause:
		return Vector2.ZERO

	if Joy_bool:
		var _move_l: float = 0
		var _move_r: float = 0
		var _move_u: float = 0
		var _move_d: float = 0
		var _type
		_type = JOYCONTROL.L_LEFT.TYPE
		match _type:
			GameLogic.Con.TYPE.AXIS:
				_move_l = Input.get_joy_axis(JoyDevice, JOYCONTROL.L_LEFT.BUT)
				if JOYCONTROL.L_LEFT.RE < 0:
					if _move_l > - GameLogic.Con.DEADZONE:
						_move_l = 0
				else:
					if _move_l < GameLogic.Con.DEADZONE:
						_move_l = 0
			GameLogic.Con.TYPE.BUTTON:
				var _pressed_bool = Input.is_joy_button_pressed(JoyDevice, JOYCONTROL.L_LEFT.BUT)
				if _pressed_bool:
					_move_l = - 1
				else:
					_move_l = 0
		_type = JOYCONTROL.L_RIGHT.TYPE
		match _type:
			GameLogic.Con.TYPE.AXIS:
				_move_r = Input.get_joy_axis(JoyDevice, JOYCONTROL.L_RIGHT.BUT)
				if JOYCONTROL.L_RIGHT.RE < 0:
					if _move_r > - GameLogic.Con.DEADZONE:
						_move_r = 0
				else:
					if _move_r < GameLogic.Con.DEADZONE:
						_move_r = 0
			GameLogic.Con.TYPE.BUTTON:
				var _pressed_bool = Input.is_joy_button_pressed(JoyDevice, JOYCONTROL.L_RIGHT.BUT)
				if _pressed_bool:
					_move_r = 1
				else:
					_move_r = 0
		_type = JOYCONTROL.L_UP.TYPE
		match _type:
			GameLogic.Con.TYPE.AXIS:
				_move_u = Input.get_joy_axis(JoyDevice, JOYCONTROL.L_UP.BUT)
				if JOYCONTROL.L_UP.RE < 0:
					if _move_u > - GameLogic.Con.DEADZONE:
						_move_u = 0
				else:
					if _move_u < GameLogic.Con.DEADZONE:
						_move_u = 0
			GameLogic.Con.TYPE.BUTTON:
				var _pressed_bool = Input.is_joy_button_pressed(JoyDevice, JOYCONTROL.L_UP.BUT)
				if _pressed_bool:
					_move_u = - 1
				else:
					_move_u = 0
		_type = JOYCONTROL.L_DOWN.TYPE
		match _type:
			GameLogic.Con.TYPE.AXIS:
				_move_d = Input.get_joy_axis(JoyDevice, JOYCONTROL.L_DOWN.BUT)
				if JOYCONTROL.L_DOWN.RE < 0:
					if _move_d > - GameLogic.Con.DEADZONE:
						_move_d = 0
				else:
					if _move_d < GameLogic.Con.DEADZONE:
						_move_d = 0
			GameLogic.Con.TYPE.BUTTON:
				var _pressed_bool = Input.is_joy_button_pressed(JoyDevice, JOYCONTROL.L_DOWN.BUT)
				if _pressed_bool:
					_move_d = 1
				else:
					_move_d = 0
		input_joy.x = _move_l + _move_r
		input_joy.y = _move_u + _move_d
	else:
		input_joy = Vector2.ZERO


	if Keyboard_bool:
		var _r = 0
		var _l = 0
		if Input.is_key_pressed(int(KEYCONTROL.L_RIGHT.BUT)):

			_r = 1
		if Input.is_key_pressed(int(KEYCONTROL.L_LEFT.BUT)):
			_l = 1
		input_key.x = _r - _l

		var _u = 0
		var _d = 0
		if Input.is_key_pressed(int(KEYCONTROL.L_UP.BUT)):
			_u = 1
		if Input.is_key_pressed(int(KEYCONTROL.L_DOWN.BUT)):
			_d = 1
		input_key.y = _d - _u

	else:
		input_key = Vector2.ZERO

	input_vector = input_joy + input_key

	var Ix = abs(input_vector.x)
	var Iy = abs(input_vector.y)
	if Ix + Iy > 1:
		input_vector = input_vector.normalized()


	return input_vector

func call_puppet_move(_input_vector, _POS):
	playerNode.position = _POS
	input_vector = _input_vector
	playerNode.FaceRay_Cast()
	playerNode.call_StatChange()

func call_return_fall():
	if SteamLogic.IsMultiplay and SteamLogic.STEAM_ID == playerNode.cur_Player:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_move", [input_vector, playerNode.position])
func call_velocity():
	velocity = input_vector * Stat.Ins_MAXSPEED * float(Stat.Ins_SpeedMult)
	playerNode.call_StatChange()
func _physics_process(_delta: float) -> void :

	if Stat.Ins_MAXSPEED == null:
		printerr("statistics.MAX_SPEED = null")
		return

	else:
		if playerNode.IsDead:
			state = GameLogic.NPC.STATE.DEAD
			input_vector = Vector2.ZERO
			velocity = Vector2.ZERO
			return

		if state in [GameLogic.NPC.STATE.RUBBING,
		GameLogic.NPC.STATE.DUMPING,
		GameLogic.NPC.STATE.FALLDOWN,
		GameLogic.NPC.STATE.EATTING, GameLogic.NPC.STATE.SMASH,
		GameLogic.NPC.STATE.CUTE,
		GameLogic.NPC.STATE.SIT,
		GameLogic.NPC.STATE.SITDOWN]:
			input_vector = Vector2.ZERO
			velocity = Vector2.ZERO
			return

		if not CanControl:
			if stateSave != GameLogic.NPC.STATE.IDLE_EMPTY:

				input_vector = Vector2.ZERO
				velocity = Vector2.ZERO
				call_state(GameLogic.NPC.STATE.IDLE_EMPTY)

				if input_vector_save != input_vector:
					input_vector_save = input_vector

					if SteamLogic.IsMultiplay and str(SteamLogic.STEAM_ID) == playerNode.name:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_move", [input_vector, playerNode.position])
			return

		if CanMove and KeyboardType != - 1:
			input_vector = return_Move_Control()



		if CanControl:
			playerNode.FaceRay_Cast()

		if input_vector != _Vector_Save and input_vector != Vector2.ZERO:
			_Vector_Save = input_vector



		if input_vector_save != input_vector:
			call_velocity()

			if velocity != Vector2.ZERO:
				if input_vector_save != input_vector:

					call_state(GameLogic.NPC.STATE.MOVE)

					get_parent().get_node("Timer").stop()
			else:
				if not state in [GameLogic.NPC.STATE.IDLE_ACT]:
					if stateSave != GameLogic.NPC.STATE.IDLE_EMPTY:
						call_state(GameLogic.NPC.STATE.IDLE_EMPTY)

						if get_parent().get_node("Timer").is_stopped():
							get_parent().get_node("Timer").start()

			input_vector_save = input_vector
			if SteamLogic.IsMultiplay and SteamLogic.STEAM_ID == playerNode.cur_Player:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_move", [input_vector, playerNode.position])
var _IsSKILL: bool
func call_Skill(_value):

	if not CanControl:
		return
	if Stat.Skills.has("技能-滑箱子"):
		if _value == 1:
			call_Throw()
	elif Stat.Skills.has("技能-卖萌"):
		if _value == 1:
			call_Cute()
	elif Stat.Skills.has("技能-冲刺"):
		if _value == 1:
			call_Roll()
	elif Stat.Skills.has("技能-穿透"):
		call_Pass(_value)
	elif Stat.Skills.has("技能-搓手手"):

		if _value == 1:
			call_Rubbing()
	elif Stat.Skills.has("技能-倾倒"):
		if _value == 1:
			call_Dumping()
	elif Stat.Skills.has("技能-吞食"):
		if _value == 1:
			call_Eating()
	if _value == 0 and _IsSKILL:
		_IsSKILL = false

func call_FallDown():
	if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		CanControl = false
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.FALLDOWN)

	call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

func call_IDLEANI():
	if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		return

	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.IDLE_ANI_1)

func call_Cute_puppet():
	pass
func call_SitEnd():
	call_state(GameLogic.NPC.STATE.IDLE_EMPTY)

func call_SitUp():
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.SITUP)
func call_SitDown():
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.SITDOWN)
func call_SitLeft():
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.SITLEFT)
func call_SitRight():
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.SITRIGHT)

func call_Sit():
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.SIT)

func call_Cute():
	if not IsHold:

		input_vector = Vector2.ZERO
		call_state(GameLogic.NPC.STATE.CUTE)

		CanControl = false
		var _TIME: float = 4
		if GameLogic.cur_Rewards.has("熊猫强化"):
			_TIME = 2
		playerNode.get_node("LogicNode/RollCD").wait_time = _TIME
		playerNode.get_node("LogicNode/RollCD").start(0)
func call_Eating():
	if IsHold:
		var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
		if not is_instance_valid(_HoldObj):
			return
		if _HoldObj.get("FuncType") in ["Trashbag"] and ArmState == 0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if SteamLogic.IsMultiplay:
				SteamLogic.call_puppet_node_sync(self, "call_Eating_puppet")

			input_vector = Vector2.ZERO
			call_state(GameLogic.NPC.STATE.EATTING)

			CanControl = false
			playerNode.get_node("LogicNode/RollCD").wait_time = 2
			playerNode.get_node("LogicNode/RollCD").start(0)
func call_Eating_puppet():
	var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
	if not is_instance_valid(_HoldObj):
		return

	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.EATTING)

	CanControl = false
	playerNode.get_node("LogicNode/RollCD").wait_time = 2
	playerNode.get_node("LogicNode/RollCD").start(0)
	pass
func call_Dumping():
	if IsHold:
		var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
		if not is_instance_valid(_HoldObj):
			return
		if _HoldObj.get("FuncType") in ["DrinkCup", "SuperCup", "EggRollCup", "SodaCan"] and ArmState == 0:
			if _HoldObj.get("FuncType") in ["SodaCan"]:
				if _HoldObj.get("IsPack"):
					return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if SteamLogic.IsMultiplay:
				SteamLogic.call_puppet_node_sync(self, "call_Dumping_puppet")

			playerNode.get_node("LogicNode/AudioStreamPlayer2D/AnimationPlayer").play("Dumping")

			_HoldObj.call_clear()
			_HoldObj.call_CupInfo_Switch(false)
			input_vector = Vector2.ZERO
			call_state(GameLogic.NPC.STATE.DUMPING)

			call_ArmState(GameLogic.NPC.STATE.DEAD)

			CanControl = false
			playerNode.get_node("LogicNode/RollCD").wait_time = 2
			playerNode.get_node("LogicNode/RollCD").start(0)

func call_Dumping_puppet():
	var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
	if not is_instance_valid(_HoldObj):
		return
	_HoldObj.call_clear()
	input_vector = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.DUMPING)

	call_ArmState(GameLogic.NPC.STATE.DEAD)

	CanControl = false
	playerNode.get_node("LogicNode/RollCD").wait_time = 2
	playerNode.get_node("LogicNode/RollCD").start(0)
func call_Rubbing():
	if not IsHold:

		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		if SteamLogic.IsMultiplay:
			SteamLogic.call_puppet_node_sync(self, "call_Rubbing_puppet")
		input_vector = Vector2.ZERO
		call_state(GameLogic.NPC.STATE.RUBBING)

		call_ArmState(GameLogic.NPC.STATE.DEAD)

		CanControl = false
		var _TIME: float = 2
		var _FOOT: int = 15
		if GameLogic.cur_Rewards.has("海狸强化"):
			_TIME = 0.5
			_FOOT = 30
		playerNode.get_node("LogicNode/RollCD").wait_time = _TIME
		playerNode.get_node("LogicNode/RollCD").start(0)
		if playerNode.FootPrint < _FOOT:
			playerNode.FootPrint = _FOOT
			playerNode.FootWaterColor = Color8(137, 228, 245, 100)
		Stat.Ins_Beaver = 1
		Stat._speed_change_logic()

	elif IsHold:
		if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			playerNode.call_Say_NeedEmptyHand()
func call_Rubbing_puppet():
	input_vector = Vector2.ZERO
	velocity = Vector2.ZERO
	call_state(GameLogic.NPC.STATE.RUBBING)

	call_ArmState(GameLogic.NPC.STATE.DEAD)

	CanControl = false
	playerNode.get_node("LogicNode/RollCD").wait_time = 2
	playerNode.get_node("LogicNode/RollCD").start(0)
	playerNode.FootPrint += 20
	if playerNode.FootPrint > 100:
		playerNode.FootPrint = 100
	Stat.Ins_Beaver = 1
	Stat._speed_change_logic()
func call_Pass_vibration():
	if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.Con.call_vibration(playerNode.cur_Player, 0.12, 0.12, 0.1)
	if playerNode.get_node("LogicNode/AnimationPlayer").assigned_animation != "PassLoop":
		playerNode.get_node("LogicNode/AnimationPlayer").play("PassLoop")

func call_Pass(_value):
	if _value == 0 and _IsSKILL:
		_IsSKILL = false
	if not IsHold:
		if not playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			return
		if _value == 1 and not _IsSKILL:
			_IsSKILL = true

	else:
		if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			if _value == 1:
				playerNode.call_Say_NeedEmptyHand()

	if _IsSKILL:

		playerNode.get_node("LogicNode/AnimationPlayer").play("PassIn")
		if Stat.has_node("CollisionAni"):
			Stat.get_node("CollisionAni").play("Pass")
		playerNode.call_Pressure_Logic()
		playerNode.get_node("LogicNode/AudioStreamPlayer2D/AnimationPlayer").play("Pass")

	else:

		playerNode.get_node("LogicNode/AnimationPlayer").play("PassOut")
		if Stat.Skills.has("技能-幽灵基础"):
			if Stat.Skills.has("技能-穿越"):
				if Stat.has_node("CollisionAni"):
					Stat.get_node("CollisionAni").play("ghost2")
			else:
				if Stat.has_node("CollisionAni"):
					Stat.get_node("CollisionAni").play("ghost")
		else:
			if Stat.has_node("CollisionAni"):
				Stat.get_node("CollisionAni").play("init")
		playerNode.call_Pressure_Logic()
		playerNode.get_node("LogicNode/AudioStreamPlayer2D/AnimationPlayer").play("init")
	if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		if SteamLogic.IsMultiplay:
			SteamLogic.call_puppet_node_sync(self, "call_Pass_puppet", [_IsSKILL])
func call_Pass_puppet(_SKILL: bool):
	_IsSKILL = _SKILL
	if _IsSKILL:
		playerNode.get_node("LogicNode/AnimationPlayer").play("PassIn")
		if Stat.has_node("CollisionAni"):
			Stat.get_node("CollisionAni").play("Pass")
		playerNode.call_Pressure_Logic()
	else:
		playerNode.get_node("LogicNode/AnimationPlayer").play("PassOut")
		if Stat.Skills.has("技能-幽灵基础"):
			if Stat.Skills.has("技能-穿越"):
				if Stat.has_node("CollisionAni"):
					Stat.get_node("CollisionAni").play("ghost2")
			else:
				if Stat.has_node("CollisionAni"):
					Stat.get_node("CollisionAni").play("ghost")
		else:
			if Stat.has_node("CollisionAni"):
				Stat.get_node("CollisionAni").play("init")
		playerNode.call_Pressure_Logic()
func call_Throw():
	if _IsSKILL == false:
		_IsSKILL = true
	else:
		return
	if IsHold:
		var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
		if not is_instance_valid(_HoldObj):
			return
		if GameLogic.cur_Rewards.has("熊熊强化"):
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _VECTOR = _Vector_Save.normalized()
			var _POS = playerNode.global_position + _Vector_Save * 20
			if SteamLogic.IsMultiplay:
				var _OBJPATH = _HoldObj.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Throw_puppet", [_OBJPATH, _VECTOR, _POS])
			if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				GameLogic.Con.call_vibration(playerNode.cur_Player, 0.3, 0.3, 0.2)
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _THROWOBJ = GameLogic.TSCNLoad.ThrowObj_TSCN.instance()
			if _HoldObj.get("HasItem"):
				_THROWOBJ.mass = 4
			else:
				if GameLogic.Config.DeviceConfig.has(_HoldObj.TypeStr):
					_THROWOBJ.mass = 1
				else:
					_THROWOBJ.mass = 10
			_THROWOBJ.position = _POS
			_THROWOBJ._PLAYER = playerNode
			playerNode.WeaponNode.remove_child(_HoldObj)
			var _Audio = GameLogic.Audio.return_Effect(_HoldObj.AudioPut)
			_Audio.play(0)
			_HoldObj.position = Vector2.ZERO
			playerNode.Stat.call_carry_off()
			get_tree().get_root().get_node("Level").Ysort_Items.add_child(_THROWOBJ)
			_THROWOBJ.ObjNode.add_child(_HoldObj)
			_THROWOBJ.OBJ = _HoldObj
			if _HoldObj.has_method("But_Hold"):
				_HoldObj.But_Hold(playerNode)
			if _HoldObj.has_method("call_CupInfo_Hide"):
					_HoldObj.call_CupInfo_Hide()

			_THROWOBJ.call_Throw(_VECTOR)
			return
		if _HoldObj.get("TypeStr") in ["Box_M_Paper"]:


			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			var _VECTOR = _Vector_Save.normalized()
			var _POS = playerNode.global_position + _Vector_Save * 20
			if SteamLogic.IsMultiplay:
				var _OBJPATH = _HoldObj.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Throw_puppet", [_OBJPATH, _VECTOR, _POS])
			if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				GameLogic.Con.call_vibration(playerNode.cur_Player, 0.3, 0.3, 0.2)
			var _THROWOBJ = GameLogic.TSCNLoad.ThrowObj_TSCN.instance()
			if _HoldObj.HasItem:
				_THROWOBJ.mass = 4
			else:
				_THROWOBJ.mass = 1
			_THROWOBJ.position = _POS
			_THROWOBJ._PLAYER = playerNode
			playerNode.WeaponNode.remove_child(_HoldObj)
			var _Audio = GameLogic.Audio.return_Effect(_HoldObj.AudioPut)
			_Audio.play(0)
			_HoldObj.position = Vector2.ZERO
			playerNode.Stat.call_carry_off()
			get_tree().get_root().get_node("Level").Ysort_Items.add_child(_THROWOBJ)
			_THROWOBJ.ObjNode.add_child(_HoldObj)
			_THROWOBJ.OBJ = _HoldObj
			_HoldObj.But_Hold(playerNode)


			_THROWOBJ.call_Throw(_VECTOR)
		else:
			if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				playerNode.call_Say_NoPassBox()
func call_Throw_puppet(_OBJPATH, _VECTOR, _POS):

	if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.Con.call_vibration(playerNode.cur_Player, 0.3, 0.3, 0.2)
	var _HoldObj = get_node(_OBJPATH)
	if not is_instance_valid(_HoldObj):
		return
	var _THROWOBJ = GameLogic.TSCNLoad.ThrowObj_TSCN.instance()

	if _HoldObj.HasItem:
		_THROWOBJ.mass = 4
	else:
		_THROWOBJ.mass = 1
	_THROWOBJ.position = _POS
	_THROWOBJ._PLAYER = playerNode
	playerNode.WeaponNode.remove_child(_HoldObj)
	var _Audio = GameLogic.Audio.return_Effect(_HoldObj.AudioPut)
	_Audio.play(0)
	_HoldObj.position = Vector2.ZERO
	playerNode.Stat.call_carry_off()
	get_tree().get_root().get_node("Level").Ysort_Items.add_child(_THROWOBJ)
	_THROWOBJ.ObjNode.add_child(_HoldObj)
	_THROWOBJ.OBJ = _HoldObj
	_HoldObj.But_Hold(playerNode)
	_THROWOBJ.call_Throw(_VECTOR)
func call_Roll():

	if IsRoll:
		return

	if CanRoll:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		if SteamLogic.IsMultiplay:
			SteamLogic.call_puppet_node_sync(self, "call_Roll_puppet")
		if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			GameLogic.Con.call_vibration(playerNode.cur_Player, 0.25, 0.25, 0.2)
		playerNode.get_node("LogicNode/AnimationPlayer").play("Roll")
		CanRoll = false
		CanControl = false
		IsRoll = true



		var _TIME: float = 2.5

		if SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
			_TIME = 0.2
		playerNode.get_node("LogicNode/RollCD").wait_time = _TIME
		playerNode.get_node("LogicNode/RollCD").start(0)
		var _Effect_TSCN = GameLogic.TSCNLoad.SmokeEffect_TSCN
		var _Effect = _Effect_TSCN.instance()
		_Effect.position = playerNode.position
		var _AUDIO = GameLogic.Audio.return_Effect("狼冲刺")
		_AUDIO.play(0)
		if get_tree().get_root().has_node("Home"):
			get_tree().get_root().get_node("Home").Ysort_Outdoor.add_child(_Effect)
		elif get_tree().get_root().has_node("Level"):
			get_tree().get_root().get_node("Level").Ysort_Update.add_child(_Effect)

		yield(get_tree().create_timer(0.2), "timeout")
		IsRoll = false
		CanControl = true

	else:
		if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			playerNode.call_Say_NeedBreak()

func call_Roll_puppet():
	if not CanControl:
		return
	if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.Con.call_vibration(playerNode.cur_Player, 0.25, 0.25, 0.2)
	CanRoll = false
	CanControl = false
	IsRoll = true
	playerNode.get_node("LogicNode/AnimationPlayer").play("Roll")
	var _Effect_TSCN = GameLogic.TSCNLoad.SmokeEffect_TSCN
	var _Effect = _Effect_TSCN.instance()
	_Effect.position = playerNode.position
	if get_tree().get_root().has_node("Home"):
		get_tree().get_root().get_node("Home").Ysort_Outdoor.add_child(_Effect)
	elif get_tree().get_root().has_node("Level"):
		get_tree().get_root().get_node("Level").Ysort_Update.add_child(_Effect)
	yield(get_tree().create_timer(0.2), "timeout")

	CanControl = true
	IsRoll = false
func _Button_Pressed(_button, _type, _value):
	var _pressed: bool = false
	if _value == 1:
		_pressed = true

	if get_tree().is_paused():
		return
	match _button:
		JOYCONTROL.A.BUT:

			if ArmState in [GameLogic.NPC.STATE.SHOVEL]:
				return
			if _pressed:

				if GameLogic.GlobalData.globalini.Touch == 0:
					if is_instance_valid(playerNode.cur_TouchObj):
						if playerNode.cur_TouchObj in playerNode.cur_Touch_List:

							SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 0)
							var _check = GameLogic.Device.Call_CheckLogic(0, playerNode, playerNode.cur_TouchObj)

							if _check != null:
								GameLogic.Device.call_teach(0, playerNode, playerNode.cur_TouchObj, _check)
								return
							if playerNode.cur_RayObj != null:
								if playerNode.WeaponNode.get_child_count():
									SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "call_TouchDev_Logic", 0)
									var _return = GameLogic.Device.call_TouchDev_Logic( - 1, playerNode, playerNode.cur_RayObj)
					if is_instance_valid(playerNode.cur_RayObj):
						if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							if playerNode.cur_RayObj.has_method("call_home_device"):

								var _RETURN = playerNode.cur_RayObj.call_home_device(0, _value, _type, playerNode)
								if _RETURN:
									return
						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("move"):
								pass
							else:

								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 0)
								var _check = GameLogic.Device.Call_CheckLogic(0, playerNode, playerNode.cur_RayObj)


								if _check != null:
									GameLogic.Device.call_teach(0, playerNode, playerNode.cur_RayObj, _check)
									return
				else:
					if is_instance_valid(playerNode.cur_RayObj):
						if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							if playerNode.cur_RayObj.has_method("call_home_device"):
								var _RETURN = playerNode.cur_RayObj.call_home_device(0, _value, _type, playerNode)
								if _RETURN:
									return
						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("move"):
								pass
							else:

								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 0)
								var _check = GameLogic.Device.Call_CheckLogic(0, playerNode, playerNode.cur_RayObj)


								if _check != null:
									GameLogic.Device.call_teach(0, playerNode, playerNode.cur_RayObj, _check)
									return
					if is_instance_valid(playerNode.cur_TouchObj):
						if playerNode.cur_TouchObj in playerNode.cur_Touch_List:

							SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 0)
							var _check = GameLogic.Device.Call_CheckLogic(0, playerNode, playerNode.cur_TouchObj)

							if _check != null:
								GameLogic.Device.call_teach(0, playerNode, playerNode.cur_TouchObj, _check)
								return
							if playerNode.cur_RayObj != null:
								if playerNode.WeaponNode.get_child_count():
									SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "call_TouchDev_Logic", 0)
			else:
				if is_instance_valid(playerNode.cur_RayObj):

					if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						if playerNode.cur_RayObj.has_method("call_home_device"):
							var _RETURN = playerNode.cur_RayObj.call_home_device(0, _value, _type, playerNode)
							if _RETURN:
								return
		JOYCONTROL.B.BUT:
			if ArmState in [GameLogic.NPC.STATE.STIR,
			GameLogic.NPC.STATE.WORK,
			GameLogic.NPC.STATE.SQUEEZE,
			GameLogic.NPC.STATE.SHAKE,
			GameLogic.NPC.STATE.SHOVEL]:
				return

			if _pressed:
				if GameLogic.GlobalData.globalini.Interaction == 0:
					if is_instance_valid(playerNode.cur_TouchObj):
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 1)
						var _check = GameLogic.Device.Call_CheckLogic(1, playerNode, playerNode.cur_TouchObj)
						if _check != null:
							GameLogic.Device.call_teach(1, playerNode, playerNode.cur_TouchObj, _check)
							return
					if is_instance_valid(playerNode.cur_RayObj):
						if playerNode.cur_RayObj.has_method("_ready"):
							SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 1)
							var _check = GameLogic.Device.Call_CheckLogic(1, playerNode, playerNode.cur_RayObj)
							if _check != null:
								GameLogic.Device.call_teach(1, playerNode, playerNode.cur_RayObj, _check)
								return
				else:
					if is_instance_valid(playerNode.cur_RayObj):
						if playerNode.cur_RayObj.has_method("_ready"):
							SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 1)
							var _check = GameLogic.Device.Call_CheckLogic(1, playerNode, playerNode.cur_RayObj)
							if _check != null:
								GameLogic.Device.call_teach(1, playerNode, playerNode.cur_RayObj, _check)
								return
					if is_instance_valid(playerNode.cur_TouchObj):
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 1)
						var _check = GameLogic.Device.Call_CheckLogic(1, playerNode, playerNode.cur_TouchObj)
						if _check != null:
							GameLogic.Device.call_teach(1, playerNode, playerNode.cur_TouchObj, _check)
							return
		JOYCONTROL.X.BUT:


			if is_instance_valid(playerNode.cur_RayObj):

				if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					if playerNode.cur_RayObj.has_method("call_home_device") and _pressed:
						var _RETURN = playerNode.cur_RayObj.call_home_device(2, _value, _type, playerNode)
						if _RETURN:
							return
			if _pressed:
				if IsHold:
					var _HoldObj = instance_from_id(HoldInsId)
					if not _HoldObj:
						HoldInsId = 0
						return
					if playerNode.cur_RayObj != null:

						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("move"):
								pass
							elif playerNode.cur_RayObj.get("FuncType") in ["Shelf", "FreezerBox", "Freezer", "FruitShelf", "FreezerBig", "IceCreamMachine", "BreakMachine", "BeerMachine", "Shelf_GlassCup"]:
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 2)
								var _check = GameLogic.Device.Call_CheckLogic(2, playerNode, playerNode.cur_RayObj)

								if _check != null:

									return true
							elif playerNode.cur_RayObj.get("FuncType") in ["Table", "PickUp", "WorkBench_Immovable", "WorkBench"]:
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 2)
								var _check = GameLogic.Device.Call_CheckLogic(2, playerNode, playerNode.cur_RayObj)

								if _check != null:
									GameLogic.Device.call_teach(2, playerNode, playerNode.cur_RayObj, _check)
									return _check

					if _HoldObj.has_method("return_SQUEEZE_start"):
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _HoldObj, "return_SQUEEZE_start", 2)
						var _Mix_bool = _HoldObj.return_SQUEEZE_start(playerNode, 1.0)
						if _Mix_bool:
							call_ArmState(GameLogic.NPC.STATE.SQUEEZE)

							return "SQUEEZE"
						else:

							ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
					if _HoldObj.has_method("return_STIR_start"):
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _HoldObj, "return_STIR_start", 2)
						var _Mix_bool = _HoldObj.return_STIR_start(playerNode)
						if _Mix_bool:
							call_ArmState(GameLogic.NPC.STATE.STIR)

							return "STIR"
						else:

							call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

					if _HoldObj.has_method("return_WORK_start"):

						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _HoldObj, "return_WORK_start", 2)
						var _Mix_bool = _HoldObj.return_WORK_start(playerNode, 1.0)
						if _Mix_bool:
							call_ArmState(GameLogic.NPC.STATE.WORK)

							return "WORK"
						else:

							call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

					if _HoldObj.has_method("return_SHAKE_start"):

						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _HoldObj, "return_SHAKE_start", 2)
						var _Mix_bool = _HoldObj.return_SHAKE_start(playerNode, 1.0)
						if _Mix_bool:
							call_ArmState(GameLogic.NPC.STATE.SHAKE)

							return "SHAKE"
						else:

							call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

					if _HoldObj.has_method("return_CanMix"):

						if ArmState in [GameLogic.NPC.STATE.SQUEEZE,
						GameLogic.NPC.STATE.STIR,
						GameLogic.NPC.STATE.WORK,
						GameLogic.NPC.STATE.SHAKE,
						GameLogic.NPC.STATE.ORDER]:
							return

						var _Mix_bool = _HoldObj.return_CanMix(playerNode)
						if _Mix_bool:
							playerNode.call_Mix_Start(_HoldObj)
							return "MIX"
					if _HoldObj.has_method("return_Shovel_start"):

						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _HoldObj, "return_Shovel_start", 2)
						var _Mix_bool = _HoldObj.return_Shovel_start(playerNode, 1.0)
						if _Mix_bool:
							call_ArmState(GameLogic.NPC.STATE.SHOVEL)

							return "WORK"
						else:

							call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

				else:

					if GameLogic.GlobalData.globalini.Interaction == 0:
						if playerNode.cur_RayObj != null:
							if playerNode.cur_RayObj.has_method("call_OnTable"):
								var _Obj = playerNode.cur_RayObj.OnTableObj
								if _Obj != null:
									if _Obj.get("SelfDev") == "InductionCooker":
										var _COOKER = _Obj.OnTableObj
										if is_instance_valid(_COOKER):
											if _COOKER.has_method("return_STIR_start"):
												SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _COOKER, "return_STIR_start", 2)
												var _Mix_bool = _COOKER.return_STIR_start(playerNode)
												if _Mix_bool:
													call_ArmState(GameLogic.NPC.STATE.STIR)

													return

									if _Obj.has_method("return_SQUEEZE_start"):
										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_SQUEEZE_start", 2)
										var _Mix_bool = _Obj.return_SQUEEZE_start(playerNode, 1.0)
										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.SQUEEZE)

											return
									if _Obj.has_method("return_STIR_start"):
										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_STIR_start", 2)
										var _Mix_bool = _Obj.return_STIR_start(playerNode)
										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.STIR)

											return
									if _Obj.has_method("return_SHAKE_start"):
										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_SHAKE_start", 2)
										var _Mix_bool = _Obj.return_SHAKE_start(playerNode)
										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.SHAKE)

											return
									if _Obj.has_method("return_WORK_start"):

										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_WORK_start", 2)
										var _Mix_bool = _Obj.return_WORK_start(playerNode, 1.0)

										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.WORK)



											return true
										else:
											call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						if playerNode.cur_RayObj != null:
							if playerNode.cur_RayObj.has_method("_ready"):
								if playerNode.cur_RayObj.has_method("call_Staff_Study"):


									if playerNode.cur_RayObj.FollowPlayer == playerNode:
										playerNode.cur_RayObj.call_Staff_Study(playerNode)

										return
					else:
						if playerNode.cur_RayObj != null:
							if playerNode.cur_RayObj.has_method("_ready"):
								if playerNode.cur_RayObj.has_method("call_Staff_Study"):


									if playerNode.cur_RayObj.FollowPlayer == playerNode:
										playerNode.cur_RayObj.call_Staff_Study(playerNode)

										return
						if playerNode.cur_RayObj != null:
							if playerNode.cur_RayObj.has_method("call_OnTable"):
								var _Obj = playerNode.cur_RayObj.OnTableObj
								if _Obj != null:
									if _Obj.get("SelfDev") == "InductionCooker":
										var _COOKER = _Obj.OnTableObj
										if is_instance_valid(_COOKER):
											if _COOKER.has_method("return_STIR_start"):
												SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _COOKER, "return_STIR_start", 2)
												var _Mix_bool = _COOKER.return_STIR_start(playerNode)
												if _Mix_bool:
													call_ArmState(GameLogic.NPC.STATE.STIR)

													return

									if _Obj.has_method("return_SQUEEZE_start"):
										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_SQUEEZE_start", 2)
										var _Mix_bool = _Obj.return_SQUEEZE_start(playerNode, 1.0)
										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.SQUEEZE)

											return
									if _Obj.has_method("return_STIR_start"):
										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_STIR_start", 2)
										var _Mix_bool = _Obj.return_STIR_start(playerNode)
										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.STIR)

											return
									if _Obj.has_method("return_SHAKE_start"):
										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_SHAKE_start", 2)
										var _Mix_bool = _Obj.return_SHAKE_start(playerNode)
										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.SHAKE)

											return
									if _Obj.has_method("return_WORK_start"):

										SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "return_WORK_start", 2)
										var _Mix_bool = _Obj.return_WORK_start(playerNode, 1.0)

										if _Mix_bool:
											call_ArmState(GameLogic.NPC.STATE.WORK)


											return "WORK"
										else:
											call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

											return

				if GameLogic.GlobalData.globalini.Interaction == 0:
					if playerNode.cur_TouchObj != null:
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 2)
						var _check = GameLogic.Device.Call_CheckLogic(2, playerNode, playerNode.cur_TouchObj)

						if _check != null:
							GameLogic.Device.call_teach(2, playerNode, playerNode.cur_TouchObj, _check)
							return _check
					if playerNode.cur_RayObj != null:
						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("move"):
								pass
							else:
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 2)
								var _check = GameLogic.Device.Call_CheckLogic(2, playerNode, playerNode.cur_RayObj)

								if _check != null:
									GameLogic.Device.call_teach(2, playerNode, playerNode.cur_RayObj, _check)
									return _check
				else:
					if playerNode.cur_RayObj != null:
						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("move"):
								pass
							else:
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 2)
								var _check = GameLogic.Device.Call_CheckLogic(2, playerNode, playerNode.cur_RayObj)

								if _check != null:
									GameLogic.Device.call_teach(2, playerNode, playerNode.cur_RayObj, _check)
									return _check
					if playerNode.cur_TouchObj != null:
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 2)
						var _check = GameLogic.Device.Call_CheckLogic(2, playerNode, playerNode.cur_TouchObj)

						if _check != null:
							GameLogic.Device.call_teach(2, playerNode, playerNode.cur_TouchObj, _check)
							return _check
			else:

				if IsHold:
					var _HoldObj = instance_from_id(HoldInsId)

					if _HoldObj.has_method("call_SQUEEZE_end"):

						_HoldObj.call_SQUEEZE_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
					elif _HoldObj.has_method("call_STIR_end"):

						_HoldObj.call_STIR_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
					if _HoldObj.has_method("call_SHAKE_end"):

						_HoldObj.call_SHAKE_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
					if _HoldObj.has_method("call_WORKING_end"):

						_HoldObj.call_WORKING_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
					if _HoldObj.has_method("call_Shovel_end"):

						_HoldObj.call_Shovel_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return
				else:

					if playerNode.cur_RayObj != null:
						if playerNode.cur_RayObj.has_method("call_OnTable"):
							var _Obj = playerNode.cur_RayObj.OnTableObj
							if _Obj != null:
								if _Obj.get("SelfDev") == "InductionCooker":
									var _COOKER = _Obj.OnTableObj
									if not is_instance_valid(_COOKER):
										return
									if _COOKER.has_method("call_STIR_end"):
										_COOKER.call_STIR_end(playerNode)
										call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

										return
								if _Obj.has_method("call_SQUEEZE_end"):
									_Obj.call_SQUEEZE_end(playerNode)

									call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

									return
								if _Obj.has_method("call_STIR_end"):
									_Obj.call_STIR_end(playerNode)

									call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

									return
								if _Obj.has_method("call_SHAKE_end"):
									_Obj.call_SHAKE_end(playerNode)

									call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

									return
		JOYCONTROL.Y.BUT:
			if ArmState in [GameLogic.NPC.STATE.STIR,
			GameLogic.NPC.STATE.WORK,
			GameLogic.NPC.STATE.SQUEEZE,
			GameLogic.NPC.STATE.SHOVEL]:
				return
			if _pressed:
				if GameLogic.GlobalData.globalini.Interaction == 0:
					if is_instance_valid(playerNode.cur_TouchObj):
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 3)
						var _check = GameLogic.Device.Call_CheckLogic(3, playerNode, playerNode.cur_TouchObj)

						if _check != null:
							GameLogic.Device.call_teach(3, playerNode, playerNode.cur_TouchObj, _check)
							return _check
					if is_instance_valid(playerNode.cur_RayObj):

						if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							if playerNode.cur_RayObj.has_method("call_home_device"):
								var _RETURN = playerNode.cur_RayObj.call_home_device(3, _value, _type, playerNode)
								if _RETURN:
									return
						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("call_Staff_Study"):


								if not IsHold and playerNode.StaffNode == null:
									playerNode.cur_RayObj.call_follow(playerNode)

									return
								elif not IsHold:
									SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 3)
									var _check = GameLogic.Device.Call_CheckLogic(3, playerNode, playerNode.cur_RayObj)
									return _check
							else:
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 3)
								var _check = GameLogic.Device.Call_CheckLogic(3, playerNode, playerNode.cur_RayObj)

								if _check != null:
									GameLogic.Device.call_teach(3, playerNode, playerNode.cur_RayObj, _check)
									return _check
				else:
					if is_instance_valid(playerNode.cur_RayObj):

						if playerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							if playerNode.cur_RayObj.has_method("call_home_device"):
								var _RETURN = playerNode.cur_RayObj.call_home_device(3, _value, _type, playerNode)
								if _RETURN:
									return
						if playerNode.cur_RayObj.has_method("_ready"):
							if playerNode.cur_RayObj.has_method("call_Staff_Study"):


								if not IsHold and playerNode.StaffNode == null:
									playerNode.cur_RayObj.call_follow(playerNode)

									return
								elif not IsHold:
									SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 3)
									var _check = GameLogic.Device.Call_CheckLogic(3, playerNode, playerNode.cur_RayObj)
									return _check
							else:
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 3)
								var _check = GameLogic.Device.Call_CheckLogic(3, playerNode, playerNode.cur_RayObj)

								if _check != null:
									GameLogic.Device.call_teach(3, playerNode, playerNode.cur_RayObj, _check)
									return _check
					if is_instance_valid(playerNode.cur_TouchObj):
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_TouchObj, "Call_CheckLogic", 3)
						var _check = GameLogic.Device.Call_CheckLogic(3, playerNode, playerNode.cur_TouchObj)

						if _check != null:
							GameLogic.Device.call_teach(3, playerNode, playerNode.cur_TouchObj, _check)
							return _check

				if IsHold:

					var _Obj = instance_from_id(HoldInsId)

					if _Obj.IsItem:
						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "ItemLogic_PutOnGround", 3)
						var _check = GameLogic.Device.ItemLogic_PutOnGround(3, playerNode, _Obj)
						if _check != null:
							GameLogic.Device.call_teach(3, playerNode, _Obj, _check)

						if is_instance_valid(playerNode.cur_RayObj):

							SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "call_TouchDev_Logic", 3)
							var _return = GameLogic.Device.call_TouchDev_Logic( - 1, playerNode, playerNode.cur_RayObj)

						return
					if _Obj.CanGround:


						SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, _Obj, "ItemLogic_PutOnGround", 3)
						var _check = GameLogic.Device.ItemLogic_PutOnGround(3, playerNode, _Obj)
						if _check != null:
							GameLogic.Device.call_teach(3, playerNode, _Obj, _check)
						if is_instance_valid(playerNode.cur_RayObj):

							SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "call_TouchDev_Logic", 3)
							var _return = GameLogic.Device.call_TouchDev_Logic( - 1, playerNode, playerNode.cur_RayObj)
						return
			else:

				if IsHold:
					var _HoldObj = instance_from_id(HoldInsId)
					if _HoldObj.has_method("call_WORKING_end"):

						_HoldObj.call_WORKING_end(playerNode)
						call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

						return

		JOYCONTROL.START.BUT:

			GameUI.call_esc(_value)

			pass
		JOYCONTROL.LEFT.BUT:
			if CanControl:

				pass

		JOYCONTROL.RIGHT.BUT:

			pass
		JOYCONTROL.UP.BUT:
			pass
		JOYCONTROL.DOWN.BUT:
			pass

		JOYCONTROL.L1.BUT:
			if playerNode.CanQTE:
				playerNode.call_QTE_press()

		JOYCONTROL.R1.BUT:

			if Stat.Skills.has("技能-无法下单"):

				if ArmState in [GameLogic.NPC.STATE.STIR,
					GameLogic.NPC.STATE.WORK,
					GameLogic.NPC.STATE.SQUEEZE,
					GameLogic.NPC.STATE.SHOVEL]:
						return
				if _pressed:
					if GameLogic.GlobalData.globalini.Interaction == 0:
						if is_instance_valid(playerNode.cur_RayObj):
							if playerNode.cur_RayObj.has_method("_ready"):
								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 10)
								var _check = GameLogic.Device.Call_CheckLogic(10, playerNode, playerNode.cur_RayObj)

								if _check != null:
									return _check
					else:
						if is_instance_valid(playerNode.cur_RayObj):

							if playerNode.cur_RayObj.has_method("_ready"):

								SteamLogic.call_Puppet_But_SYNC(playerNode.cur_Player, playerNode.cur_RayObj, "Call_CheckLogic", 10)
								var _check = GameLogic.Device.Call_CheckLogic(10, playerNode, playerNode.cur_RayObj)

								if _check != null:
									return _check
			else:
				call_Skill(_value)


func call_Mix_End():
	call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

	var _HoldObj = instance_from_id(HoldInsId)
	if is_instance_valid(_HoldObj):
		if _HoldObj.has_method("call_CanMix_Finish"):
			var _check = _HoldObj.call_CanMix_Finish()


func _on_RollCD_timeout():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_on_RollCD_timeout")
	if Stat.Skills.has("技能-冲刺"):
		CanRoll = true

	elif Stat.Skills.has("技能-搓手手"):
		CanControl = true
		call_state(GameLogic.NPC.STATE.IDLE_EMPTY)

		call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

		if not playerNode.BuffList.has("技能-手速"):
			playerNode.BuffList.append("技能-手速")

		if playerNode.AvatarNode.has_node("css"):
			var _EFFECT = playerNode.AvatarNode.get_node("css")
			_EFFECT.call_init("技能-手速", 1, 25)
		else:
			var _SPEEDUP_EFFECT = GameLogic.TSCNLoad.SpeedEffect_TSCN.instance()
			_SPEEDUP_EFFECT.name = "css"
			playerNode.AvatarNode.add_child(_SPEEDUP_EFFECT)
			_SPEEDUP_EFFECT.call_init("技能-手速", 1, 25)
		playerNode.Stat.Update_Check()
	elif Stat.Skills.has("技能-倾倒"):
		CanControl = true
		call_state(GameLogic.NPC.STATE.IDLE_EMPTY)
		call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

		var _HoldObj = instance_from_id(playerNode.Con.HoldInsId)
		if is_instance_valid(_HoldObj):
			_HoldObj.call_CupInfo_Switch(true)
	elif Stat.Skills.has("技能-吞食"):
		CanControl = true
		call_state(GameLogic.NPC.STATE.IDLE_EMPTY)
		call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

	elif Stat.Skills.has("技能-卖萌"):
		CanControl = true
		call_state(GameLogic.NPC.STATE.IDLE_EMPTY)
		call_ArmState(GameLogic.NPC.STATE.IDLE_EMPTY)

		GameLogic.call_NPCLOGIC(playerNode.cur_Player, 1, playerNode.global_position)
