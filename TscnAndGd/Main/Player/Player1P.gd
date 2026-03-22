extends KinematicBody2D

var IsStaff: bool
var IsWorking: bool
var IsDead: bool
var IsJoy: bool
var JoyDevice: int
var velocity = Vector2.ZERO
var GearList: Array
var Touch_Old
var input_vector: Vector2
var StaffNode = null
onready var Stat = get_node("LogicNode/Stat")
onready var Con = get_node("LogicNode/Control")
onready var AVATAR
onready var WeaponNode

var cur_Player
var cur_ID
var cur_RayObj
var cur_TouchObj
var cur_Touch_Count: int
var cur_Touch_List: Array
var cur_face
var Can_PressA: bool
var cur_Pressure: int = 0
var cur_PressureMax: int
onready var FaceRay = get_node("RayCast2D")
onready var FaceRayAniPlayer = FaceRay.get_node("AnimationPlayer")
onready var CameraNode = get_node("Camera2D")
onready var Collision = get_node("CollisionShape2D")
onready var EffectNode = get_node("EffectNode")
onready var InfoAni = get_node("InfoLabel/Ani")

var _Pressure_1_Bool: bool
var FootPrint: int = 0
var FootWaterColor

onready var PressurePro = get_node("PressureNode")
onready var PressureNode

func _PlayerNode():
	pass
func call_control(_type: int):
	if cur_Player == 2 and not GameLogic.Player2_bool:
		InfoAni.play("0")
		return
	match _type:
		0:
			Con.CanControl = true
			InfoAni.play("0")
		1:
			Con.CanControl = false
		2:
			Con.CanControl = false
			InfoAni.play("2")
		3:
			Con.CanControl = false
		4:
			Con.CanControl = false

func call_touch():
	if cur_Touch_List:
		var _Obj = cur_Touch_List.front()
		if is_instance_valid(_Obj):
			if is_instance_valid(cur_TouchObj):
				GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_TouchObj)
			cur_TouchObj = _Obj
			GameLogic.Device.call_TouchDev_Logic( - 1, self, cur_TouchObj)
	else:
		if is_instance_valid(cur_TouchObj):
			GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_TouchObj)
		cur_TouchObj = null
func _ready():

	var _check = GameLogic.connect("Pressure_Set", self, "call_pressure_set")
	var _PressureMultCheck = GameLogic.connect("Pressure_Mult", self, "call_Pressure_Mult")
	var _con = GameLogic.connect("Pressure_reset", self, "call_pressure_reset")
	var _Reset = GameLogic.connect("NewDay", self, "call_reset")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _Reward = GameLogic.connect("Reward", self, "Update_Check")
	if not cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		if not SteamLogic.is_connected("DelNetPlayer", self, "DelNetPlayer"):
			var _SteamCon = SteamLogic.connect("DelNetPlayer", self, "DelNetPlayer")

	set_process(false)

func Update_Check():
	call_Pressure_init()
func call_reset():
	_Pressure_1_Bool = false
	call_Pressure_init()
func call_change_avatar(_ID):

	if has_node(str(cur_ID)):
		var _oldAvatar = get_node(str(cur_ID))
		_oldAvatar.hide()
	cur_ID = int(_ID)
	if has_node(str(_ID)):
		var _Avatar = get_node(str(_ID))

		call_Pressure_init()
		_Avatar.PressureNode.call_init(cur_Pressure, cur_PressureMax)

		_Avatar.show()
	Stat.call_player_init(_ID)

func call_pressure_reset():


	GameLogic.P1_Pressure = 0
	GameLogic.P2_Pressure = 0
	cur_Pressure = 0
	call_Pressure_init()
	if has_node(str(cur_ID)):
		var _Avatar = get_node(str(cur_ID))
		_Avatar.PressureNode.call_set(cur_Pressure, cur_PressureMax)


func call_Pressure_Mult(_Mult: int):

	if _Mult != 0:
		var _value = int(float(cur_PressureMax) * (float(_Mult) / 100))
		cur_Pressure += _value
		if cur_Pressure < 0:
			cur_Pressure = 0

		_Pressure_Show(_value)
func call_pressure_set(_value):



	if _value != 0:
		if _value > 0 and GameLogic.cur_Event == "无压":
			return
		elif _value > 0 and GameLogic.cur_Event == "抗压":
			_value = int(float(_value) * 0.75)
		elif _value > 0 and GameLogic.cur_Event == "抗压+":
			_value = int(float(_value) * 0.5)
		if _value > 0 and GameLogic.cur_Challenge.has("压力增高"):
			GameLogic.call_Info(2, "压力增高")
			_value += int(float(_value) * 0.5 + 0.5)
		if _value > 0 and GameLogic.cur_Challenge.has("压力增高+"):
			GameLogic.call_Info(2, "压力增高+")
			_value += int(float(_value) + 0.5)
		if _value > 0:
			if GameLogic.cur_Event == "开店长队":

				if GameLogic.GameUI.CurTime >= GameLogic.cur_OpenTime - 0.1 and GameLogic.GameUI.CurTime <= GameLogic.cur_OpenTime + 1:
					GameLogic.call_Info(1, "开店长队")
					return
			if GameLogic.cur_Event == "关店长队":
				if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime - 1 and GameLogic.GameUI.CurTime <= GameLogic.cur_CloseTime:
					GameLogic.call_Info(1, "关店长队")
					return
		if _value != 0:
			cur_Pressure += _value
			if cur_Pressure < 0:
				cur_Pressure = 0
			_Pressure_Show(_value)



func _Pressure_Show(_value):
	GameLogic.Mult_PressureDic[cur_Player] = cur_Pressure


	var _Effect = GameLogic.TSCNLoad.PressureEffect_TSCN.instance()
	_Effect.Num = _value
	EffectNode.add_child(_Effect)
	_Effect._Skill_logic()

	PressureNode.call_set(cur_Pressure, cur_PressureMax)
	PressurePro.call_PressurePro_Set(cur_Pressure, cur_PressureMax)
	if cur_Pressure >= cur_PressureMax:

		if not GameLogic.is_connected("Pressure_Set", self, "call_pressure_set"):
			GameLogic.disconnect("Pressure_Set", self, "call_pressure_set")

		if GameLogic.LoadingUI.IsLevel:
			Con._control_logic("L2", 1, - 1)


			if not IsDead:
				IsDead = true
				Con.state = Con.STATE.DEAD


	if GameLogic.cur_Challenge.has("身体不适+"):
		if cur_Pressure >= int(float(cur_PressureMax) * 0.5):
			if GameLogic.cur_Challenge.has("身体不适"):
				Stat.Ins_ChallengeMult = 0.9
			else:
				Stat.Ins_ChallengeMult = 0.8
		else:
			Stat.Ins_ChallengeMult = 1
		Stat._speed_change_logic()
	if GameLogic.cur_Challenge.has("身体不适"):
		if cur_Pressure >= int(float(cur_PressureMax) * 0.5):
			Stat.Ins_ChallengeMult = 0.9
		else:
			Stat.Ins_ChallengeMult = 1
		Stat._speed_change_logic()

func call_init():
	Stat.call_player_init(cur_ID)
	call_note_set()
func call_Pressure_init():

	cur_PressureMax = int(GameLogic.Config.PlayerConfig[str(cur_ID)].Pressure)

	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Save.gameData.HomeDevList.has("猫猫照片"):
			cur_PressureMax += 5
		if GameLogic.Save.gameData.HomeDevList.has("狐狸照片"):
			cur_PressureMax += 5
		if GameLogic.Save.gameData.HomeDevList.has("灰狼照片"):
			cur_PressureMax += 5
		if GameLogic.Save.gameData.HomeDevList.has("熊熊照片"):
			cur_PressureMax += 5

	if GameLogic.cur_Rewards.has("员工帽"):
		cur_PressureMax = cur_PressureMax + int(float(cur_PressureMax) * 0.25)
	elif GameLogic.cur_Rewards.has("员工帽+"):
		cur_PressureMax = cur_PressureMax + int(float(cur_PressureMax) * 0.5)


	var _Mult: float = 1
	if GameLogic.cur_Challenge.has("抗压力差"):
		_Mult -= 0.1

	if GameLogic.cur_Challenge.has("抗压力差+"):
		_Mult -= 0.2

	if _Mult != 1:
		cur_PressureMax = int(float(cur_PressureMax) * _Mult)

	if GameLogic.Mult_PressureDic.has(cur_Player):
		cur_Pressure = GameLogic.Mult_PressureDic[cur_Player]
	PressureNode.call_init(cur_Pressure, cur_PressureMax)

func call_note_set():

	AVATAR = get_node("Avatar")
	WeaponNode = AVATAR.get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note")
	PressureNode = AVATAR.PressureNode
	call_Pressure_init()
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
	if AVATAR == null:
		return
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

	if FaceRay.is_colliding():
		if cur_RayObj != FaceRay.get_collider():
			var collider = FaceRay.get_collider()

			if is_instance_valid(cur_RayObj):
				if Con.ArmState == Con.STATE.SQUEEZE:
					if cur_RayObj.has_method("call_OnTable"):
						var _Obj = cur_RayObj.OnTableObj
						if _Obj != null:
							if _Obj.has_method("call_SQUEEZE_end"):
								_Obj.call_SQUEEZE_end(self)
								Con.ArmState = Con.STATE.IDLE_EMPTY

				if cur_RayObj.has_method("call_PickFruitInCup"):

					cur_RayObj.call_PickFruitInCup( - 2, Con.HoldObj, self)
				if cur_RayObj.has_method("call_home_device"):
					cur_RayObj.call_home_device( - 2, 1, 0, self)
				if cur_RayObj.has_method("call_Staff_Study"):
					cur_RayObj.But_Switch(false, self)
				else:
					GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_RayObj)
				if cur_RayObj.has_method("ButInfo_Switch"):
					cur_RayObj.ButInfo_Switch( - 2, - 2)

				if cur_RayObj.has_method("call_OnTable"):
					if cur_RayObj.OnTableObj != null:
						if cur_RayObj.OnTableObj.has_method("call_STIR_end"):
							cur_RayObj.OnTableObj.call_STIR_end(self)
							Con.call_reset_ArmState()
						if cur_RayObj.OnTableObj.has_method("call_OrderPoint"):
							if GameLogic.OrderStaff.has(self):
								GameLogic.OrderStaff.erase(self)



			cur_RayObj = collider

			if cur_RayObj.has_method("call_home_device"):
				cur_RayObj.call_home_device( - 1, 1, 0, self)
				return
			if cur_RayObj.has_method("call_notouch"):
				return

			if cur_RayObj.has_method("call_OnTable"):
				if cur_RayObj.OnTableObj != null:
					if cur_RayObj.OnTableObj.has_method("call_OrderPoint"):
						if not GameLogic.OrderStaff.has(self):
							GameLogic.OrderStaff.append(self)

			if is_instance_valid(cur_RayObj):
				if cur_RayObj.has_method("call_Staff_Study"):

					if not Con.IsHold and StaffNode == null:
						cur_RayObj.But_Switch(true, self)
				else:
					GameLogic.Device.call_TouchDev_Logic( - 1, self, cur_RayObj)

	else:
		if is_instance_valid(cur_RayObj):
			if Con.ArmState == Con.STATE.SQUEEZE:
				if cur_RayObj.has_method("call_OnTable"):
					var _Obj = cur_RayObj.OnTableObj
					if _Obj != null:
						if _Obj.has_method("call_SQUEEZE_end"):
							_Obj.call_SQUEEZE_end(self)
							Con.ArmState = Con.STATE.IDLE_EMPTY
			if cur_RayObj.has_method("call_PickFruitInCup"):

				cur_RayObj.call_PickFruitInCup( - 2, Con.HoldObj, self)
			if cur_RayObj.has_method("call_OnTable"):
				if is_instance_valid(cur_RayObj.OnTableObj):
					if cur_RayObj.OnTableObj.has_method("call_STIR_end"):
						cur_RayObj.OnTableObj.call_STIR_end(self)
						Con.call_reset_ArmState()
			if cur_RayObj.has_method("call_home_device"):
				cur_RayObj.call_home_device( - 2, 1, 0, self)
				cur_RayObj = null
				return
			if cur_RayObj.has_method("call_notouch"):
				cur_RayObj = null
				return

			if cur_RayObj.has_method("call_OnTable"):
				if cur_RayObj.OnTable_InstanceId != 0:
					var _Obj = instance_from_id(cur_RayObj.OnTable_InstanceId)
					if _Obj:
						if _Obj.has_method("call_OrderPoint"):
							if GameLogic.OrderStaff.has(self):
								GameLogic.OrderStaff.erase(self)

			if cur_RayObj.has_method("_ready"):
				if cur_RayObj.has_method("call_Staff_Study"):
					cur_RayObj.But_Switch(false, self)
				else:
					GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_RayObj)
		cur_RayObj = null

func move(_velocity):
	match IsWorking:
		true:
			return

	if GearList:
		var GearVelocity: Vector2 = Vector2.ZERO
		if GearList:
			GearVelocity = GearList.back().Direction

		velocity = _velocity + GearVelocity
	else:
		velocity = _velocity
	if velocity == Vector2.ZERO:
		return

	get_node("RigidBody2D").set_linear_velocity(velocity)

	for _i in get_slide_count():
		var _Touch = get_slide_collision(_i)

		if _Touch.collider.has_method("_thief_run_away"):

			if _Touch.collider.SpecialType == 1:
				_Touch.collider._thief_run_away()

			if GameLogic.cur_Challenge.has("鲁莽"):
				if not _Touch.collider.IsTouched and _Touch.collider.SpecialType == 0:
					GameLogic.call_Info(2, "鲁莽")
					_Touch.collider.call_touched()

					call_pressure_set(1)
			if GameLogic.cur_Challenge.has("鲁莽+"):
				if not _Touch.collider.IsTouched and _Touch.collider.SpecialType == 0:
					GameLogic.call_Info(2, "鲁莽+")

					_Touch.collider.call_touched()
					call_pressure_set(2)

func slide_move(_input_vector, delta):
	if _input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(_input_vector * Stat.Ins_MAXSPEED, Stat.Ins_ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Stat.Ins_FRICTION * delta)
	move(velocity)

func call_reset_stat():

	Con.state = Con.STATE.IDLE_EMPTY
	Con.ArmState = Con.STATE.IDLE_EMPTY
	Con.IsMixing = false
func _on_MixTimer_timeout():
	Con.IsMixing = false
	Con.call_Mix_End()
	var _Audio = GameLogic.Audio.return_Effect("搅拌杯子")
	_Audio.stop()
func call_Mix_Start(_HoldObj):
	Con.IsMixing = true
	if _HoldObj.TypeStr == "ShakeCup":
		Con.ArmState = Con.STATE.SHAKE
	else:
		Con.ArmState = Con.STATE.STIR

func DelNetPlayer(_SteamID):
	if cur_Player == _SteamID:
		if Con.IsHold:

			var _Obj = instance_from_id(Con.HoldInsId)
			var _check = GameLogic.Device.call_PutOnGround(3, self, _Obj)
		self.queue_free()
