extends Node2D

var Show_bool: bool
var type = 0
var _speedscale
var input_vector
enum {
	face_up,
	face_down,
	face_left,
	face_right
}

var FACE = face_down
var idleAni = "IdleDown"
onready var aniPlayer = get_node("AnimationPlayer")
onready var body = get_parent()
onready var Controller
onready var Stat
onready var Con
onready var WeaponNode = get_node("SpriteTex/Top_note/All_note/Body_note/Arm_Hold/Weapon_note")
onready var PressureNode

onready var FaceAni = null

var MoveBool: bool
var IdleBool: bool = true
var _SaveState
func call_Audio_Move():
	if IdleBool:
		IdleBool = false
func call_Audio_Left():
	if MoveBool:
		MoveBool = false
		_Audio_Play()
func call_Audio_Right():
	MoveBool = true
	_Audio_Play()
func call_Audio_Idle():
	if not IdleBool:
		IdleBool = true
		MoveBool = false
		_Audio_Play()
func _Audio_Play():
	var _Audio = GameLogic.Audio.return_FootSteps(self.global_position)
	if _Audio:
		_Audio.play(0)

func _ready() -> void :
	set_process(false)
	set_physics_process(false)
	call_deferred("start")
	if has_node("FaceAni"):
		FaceAni = get_node("FaceAni")
	if body.has_method("call_pressure_set"):
		PressureNode = get_node("SpriteTex/Top_note/All_note/Body_note/Body/Head/Texturenode")
	if body.has_node("LogicNode/Control"):
		Controller = body.get_node("LogicNode/Control")
	if body.has_node("LogicNode/Stat"):
		Stat = body.get_node("LogicNode/Stat")
	if body.has_node("LogicNode/Control"):
		Con = body.get_node("LogicNode/Control")
	if SteamLogic.DAYTYPE == "Halloween":
		if has_node("AniNode/DrinkAni"):
			if get_node("AniNode/DrinkAni").has_animation("Halloween"):
				get_node("AniNode/DrinkAni").play("Halloween")

func start():
	if not Show_bool:

		set_physics_process(true)

func call_personality_init(_id):
	var PersonalityAni = get_node("AniNode/PersonalityAni")
	if PersonalityAni.has_animation(str(_id)):
		PersonalityAni.play(str(_id))

func _urge_ani():
	aniPlayer.playback_speed = 1
	aniPlayer.play("Urge_2Down")
	pass

func _physics_process(_delta: float) -> void :
	input_vector = Con.input_vector

	match Con.state:
		GameLogic.NPC.STATE.URGE:
			_urge_ani()
		GameLogic.NPC.STATE.SIT:
			_sit_ani()
		GameLogic.NPC.STATE.MOVE:
			_face_logic()
			_move_ani()
		GameLogic.NPC.STATE.IDLE_EMPTY:
			_face_logic()
			_idle_ani()
		GameLogic.NPC.STATE.WORK:
			_work_ani()
		GameLogic.NPC.STATE.SHOW:
			_show_ani()
		GameLogic.NPC.STATE.DISABLE:
			aniPlayer.stop(true)
		GameLogic.NPC.STATE.STIR:

			_stir_ani()
		GameLogic.NPC.STATE.DEAD:
			aniPlayer.playback_speed = 1
			FaceAni.play("down")
			aniPlayer.play("Dead")






func _show_ani():
	aniPlayer.play("WaveDown")

func _work_ani():

	var _speed: float
	match body.behavior:
		body.BEHAVIOR.ORDER:
			_speed = float(body.Lv_Order) / 4 + 0.25
		_:
			_speed = 1.0

	aniPlayer.playback_speed = _speed
	match FACE:
		face_up:
			aniPlayer.play("WorkUp")
		face_down:
			aniPlayer.play("WorkDown")
		face_left:
			aniPlayer.play("WorkLeft")
		face_right:
			aniPlayer.play("WorkRight")
func _face_logic():



	if input_vector != Vector2.ZERO:
		if input_vector.y < 0 and abs(input_vector.y) > abs(input_vector.x):
			FACE = face_up
			if FaceAni != null:
				FaceAni.play("up")
		elif input_vector.y > 0 and abs(input_vector.y) > abs(input_vector.x):
			FACE = face_down
			if FaceAni != null:
				FaceAni.play("down")
		elif input_vector.x < 0:
			FACE = face_left
			if FaceAni != null:
				FaceAni.play("left")
		elif input_vector.x > 0:
			FACE = face_right
			if FaceAni != null:
				FaceAni.play("right")

func _move_ani():
	if aniPlayer.playback_speed != _return_ani_speed():
		aniPlayer.playback_speed = _speedscale

	match FACE:
		face_up:
			if Controller.IsHold:
				if Controller.NeedPush:
					aniPlayer.play("RunUp_Push")
				else:
					aniPlayer.play("RunUp_Hold")
			else:
				aniPlayer.play("RunUp")
		face_down:
			if Controller.IsHold:
				if Controller.NeedPush:
					aniPlayer.play("RunDown_Push")
				else:
					aniPlayer.play("RunDown_Hold")
			else:
				aniPlayer.play("RunDown")
		face_left:
			if Controller.IsHold:
				if Controller.NeedPush:
					aniPlayer.play("RunLeft_Push")
				else:
					aniPlayer.play("RunLeft_Hold")
			else:
				aniPlayer.play("RunLeft")
		face_right:
			if Controller.IsHold:
				if Controller.NeedPush:
					aniPlayer.play("RunRight_Push")
				else:
					aniPlayer.play("RunRight_Hold")
			else:
				aniPlayer.play("RunRight")

func _return_ani_speed():


	var velocity = Con.velocity

	var _Mult: float = (float(Stat.Ins_MAXSPEED) / 350)
	var _x = abs(velocity.x / Stat.Ins_MAXSPEED)
	var _y = abs(velocity.y / Stat.Ins_MAXSPEED)

	if _x >= _y:
		_speedscale = float(int(_x * 100)) / 100 * _Mult
	else:
		_speedscale = float(int(_y * 100)) / 100 * _Mult
	if _speedscale == 0:
		_speedscale = 1
	var _check = Vector2(_x, _y)
	_check = _check.normalized()

	return _speedscale
func _sit_ani():
	aniPlayer.playback_speed = 1
	match FACE:
		face_up:
			aniPlayer.play("SitUp")
		face_down:
			aniPlayer.play("SitDown")
		face_left:
			aniPlayer.play("SitLeft")
		face_right:
			aniPlayer.play("SitRight")
func _stir_ani():
	aniPlayer.playback_speed = 1
	match FACE:
		face_up:
			aniPlayer.play("StirUp")
		face_down:
			aniPlayer.play("StirDown")
		face_left:
			aniPlayer.play("StirLeft")
		face_right:
			aniPlayer.play("StirRight")
	pass
var _SaveANI: String
func call_Uper_Angry():

	if aniPlayer.assigned_animation != "Uper_angry":
		_SaveANI = aniPlayer.assigned_animation
	set_physics_process(false)
	body.set_physics_process(false)
	aniPlayer.play("Uper_angry")
func _Uper_Angry_End():

	aniPlayer.play(_SaveANI)
	set_physics_process(true)
	body.set_physics_process(true)
func _idle_ani():
	aniPlayer.playback_speed = 1
	if body.editor_description == "NPC":
		if body.OrderWait_bool:
			aniPlayer.play("Urge_1Down")
		else:
			match FACE:
				face_down:
					if Controller.IsHold:
						if Controller.NeedPush:
							aniPlayer.play("IdleDown_Push")
						else:
							aniPlayer.play("IdleDown_Hold")
					else:
						aniPlayer.play("IdleDown")
				face_left:
					if Controller.IsHold:
						if Controller.NeedPush:
							aniPlayer.play("IdleLeft_Push")
						else:
							aniPlayer.play("IdleLeft_Hold")
					else:
						aniPlayer.play("IdleLeft")
				face_up:
					if Controller.IsHold:
						if Controller.NeedPush:
							aniPlayer.play("IdleUp_Push")
						else:
							aniPlayer.play("IdleUp_Hold")
					else:
						aniPlayer.play("IdleUp")
				face_right:
					if Controller.IsHold:
						if Controller.NeedPush:
							aniPlayer.play("IdleRight_Push")
						else:
							aniPlayer.play("IdleRight_Hold")
					else:
						aniPlayer.play("IdleRight")
	else:
		match FACE:
			face_down:
				if Controller.IsHold:
					if Controller.NeedPush:
						aniPlayer.play("IdleDown_Push")
					else:
						aniPlayer.play("IdleDown_Hold")
				else:
					aniPlayer.play("IdleDown")
			face_left:
				if Controller.IsHold:
					if Controller.NeedPush:
						aniPlayer.play("IdleLeft_Push")
					else:
						aniPlayer.play("IdleLeft_Hold")
				else:
					aniPlayer.play("IdleLeft")
			face_up:
				if Controller.IsHold:
					if Controller.NeedPush:
						aniPlayer.play("IdleUp_Push")
					else:
						aniPlayer.play("IdleUp_Hold")
				else:
					aniPlayer.play("IdleUp")
			face_right:
				if Controller.IsHold:
					if Controller.NeedPush:
						aniPlayer.play("IdleRight_Push")
					else:
						aniPlayer.play("IdleRight_Hold")
				else:
					aniPlayer.play("IdleRight")
func _Control_Ani(_type):
	if type != _type:
		type = _type

func _rand_idle_ani(_OnlyIdle: bool):
	var _RandIdle
	if _OnlyIdle == false:
		match FACE:
			face_down:
				idleAni = "IdleDown"
			face_left:
				idleAni = "IdleLeft"
			face_up:
				idleAni = "IdleUp"
			face_right:
				idleAni = "IdleRight"
	else:
		_RandIdle = GameLogic.return_RANDOM() % 100
		if _RandIdle < 20:
			match FACE:
				face_up:
					idleAni = "IdleActUp"
				_:
					idleAni = "IdleActDown"

		else:
			_rand_idle_ani(false)
