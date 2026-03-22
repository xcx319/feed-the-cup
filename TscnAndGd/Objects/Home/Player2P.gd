extends KinematicBody2D

var IsStaff: bool
var IsWorking: bool
var IsJoy: bool
var JoyDevice: int
var velocity = Vector2.ZERO
var Touch_Old
var input_vector: Vector2

onready var Stat = get_node("LogicNode/Stat")
onready var Con = get_node("LogicNode/Control")
onready var AVATAR
onready var WeaponNode

var cur_Player = 2
var cur_ID
var cur_RayObj
var cur_TouchObj
var cur_Touch_Count: int
var cur_face
var Can_PressA: bool
var cur_Pressure: int = 0
var cur_PressureMax: int
onready var FaceRay = get_node("RayCast2D")
onready var FaceRayAniPlayer = FaceRay.get_node("AnimationPlayer")
onready var CameraNode = get_node("Camera2D")

onready var EffectNode = get_node("EffectNode")

onready var PressureNode

func _ready():

	pass

func call_pressure_set(_value):

	cur_Pressure += _value

	var _Effect = GameLogic.TSCNLoad.PressureEffect_TSCN.instance()
	_Effect.Num = _value
	EffectNode.add_child(_Effect)

	PressureNode.call_set(cur_Pressure, cur_PressureMax)

func call_init():
	Stat.call_player_init(cur_ID)

	call_note_set()

func call_note_set():
	AVATAR = get_node("Avatar")
	WeaponNode = AVATAR.get_node("SpriteTex/Top_note/All_note/Body_note/Arm_Hold/Weapon_note")

	cur_PressureMax = int(GameLogic.Config.PlayerConfig[cur_ID].Pressure)
	PressureNode = AVATAR.PressureNode
	PressureNode.call_init(cur_Pressure, cur_PressureMax)


func return_Move_Control():
	if IsJoy == true:
		input_vector.x = Input.get_joy_axis(JoyDevice, JOY_AXIS_0)
		input_vector.y = Input.get_joy_axis(JoyDevice, JOY_AXIS_1)
	else:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	var Ix = abs(input_vector.x)
	var Iy = abs(input_vector.y)
	if Ix + Iy > 1:
		input_vector = input_vector.normalized()

	return input_vector

func FaceRay_Cast():
	cur_face = AVATAR.FACE

	match AVATAR.FACE:
		AVATAR.face_up:
			FaceRayAniPlayer.play("up")
		AVATAR.face_down:
			FaceRayAniPlayer.play("down")
		AVATAR.face_right:
			FaceRayAniPlayer.play("right")
		AVATAR.face_left:
			FaceRayAniPlayer.play("left")

	FaceRay.force_raycast_update()
	if FaceRay.is_colliding():
		var collider = FaceRay.get_collider()

		if cur_RayObj != collider:

			if is_instance_valid(cur_RayObj):
				if cur_RayObj.has_method("call_home_device"):
					cur_RayObj.call_home_device( - 2, self)
					return
				GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_RayObj)
				if cur_RayObj.has_method("ButInfo_Switch"):
					cur_RayObj.ButInfo_Switch( - 2, - 2)

				if cur_RayObj.has_method("call_OnTable"):
					if cur_RayObj.OnTableObj != null:
						if cur_RayObj.OnTableObj.has_method("call_OrderPoint"):
							if GameLogic.OrderStaff.has(self):
								GameLogic.OrderStaff.erase(self)




			cur_RayObj = collider
			if cur_RayObj.has_method("call_home_device"):
				cur_RayObj.call_home_device( - 1, self)
				return
			if cur_RayObj.has_method("call_notouch"):
				return

			if cur_RayObj.has_method("call_OnTable"):
				if cur_RayObj.OnTableObj != null:
					if cur_RayObj.OnTableObj.has_method("call_OrderPoint"):
						GameLogic.OrderStaff.append(self)


			if is_instance_valid(cur_RayObj):
				GameLogic.Device.call_TouchDev_Logic( - 1, self, cur_RayObj)


	else:
		if is_instance_valid(cur_RayObj):
			if cur_RayObj.has_method("call_home_device"):
				cur_RayObj.call_home_device( - 2, self)
				cur_RayObj = null
				return
			if cur_RayObj.has_method("call_notouch"):
				cur_RayObj = null
				return

			if cur_RayObj.has_method("call_OnTable"):
				if cur_RayObj.OnTableObj != null:
					if cur_RayObj.OnTableObj.has_method("call_OrderPoint"):
						if GameLogic.OrderStaff.has(self):
							GameLogic.OrderStaff.erase(self)


			if cur_RayObj.has_method("_ready"):
				cur_RayObj.ButInfo_Switch( - 2, - 2)
				GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_RayObj)
		cur_RayObj = null

func move(_velocity):
	match IsWorking:
		true:
			return


	velocity = move_and_slide(_velocity)


func slide_move(_input_vector, delta):

	if _input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(_input_vector * Stat.Ins_MAXSPEED, Stat.Ins_ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Stat.Ins_FRICTION * delta)
	move(velocity)
