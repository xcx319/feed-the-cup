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
onready var aniPlayer = get_node("BodyPose")
onready var ArmAni = get_node("ArmAct")
onready var body = get_parent().get_parent()
onready var Controller

onready var Stat
onready var Con
onready var WeaponNode = get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note")
onready var RightHandNode = $SpriteTex / Top_note / All_note / Body_note / BodyPose / Arm / Pose / RIGHT_Node
onready var PressureNode = get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Texturenode")
onready var IdleTimer = get_node("IdleTimer")
onready var CryAni = $SpriteTex / Top_note / All_note / Body_note / BodyPose / Body / HeadPose / Head / Effect_StaffHead / HeadEffect
onready var FaceAni = null

var MoveBool: bool
var IdleBool: bool = true

func call_Pressure_Tex():
	PressureNode.call_texture_init()

func call_Act_End():
	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3"]:

		pass
func _FootPrint_Logic():
	if not body.has_method("_PlayerNode"):
		return

	if body.FootPrint:
		var _FootPrint_TSCN = GameLogic.TSCNLoad.FootPrintEffect_TSCN.instance()
		_FootPrint_TSCN.position = self.global_position
		match FACE:
			face_up:
				_FootPrint_TSCN.rotation = 0
			face_down:
				_FootPrint_TSCN.rotation = 180
			face_left:
				_FootPrint_TSCN.rotation = - 90
			face_right:
				_FootPrint_TSCN.rotation = 90
		GameLogic.Staff.LevelNode.Ysort_Update.add_child(_FootPrint_TSCN)
		_FootPrint_TSCN.WaterColor = body.FootWaterColor
		_FootPrint_TSCN.Concentration = body.FootPrint
		body.FootPrint -= 1

func call_Audio_Move():
	if IdleBool:
		IdleBool = false
func call_Audio_Left():
	if MoveBool:
		MoveBool = false
		_Audio_Play()
	_FootPrint_Logic()
func call_Audio_Right():
	MoveBool = true
	_Audio_Play()
	_FootPrint_Logic()
func call_Audio_Idle():

	if not IdleBool:
		IdleBool = true
		MoveBool = false
		_Audio_Play()
func _Audio_Play():
	var _Audio = GameLogic.Audio.return_FootSteps(self.global_position)
	if body.has_method("_PlayerNode"):

		if body.Stat.Skills.has("技能-幽灵基础"):
			return
	if _Audio:
		_Audio.play(0)

func call_HeadType(_Type: String):
	if not has_node("HeadType"):
		print("角色HeadType无相关node")
		return
	if get_node("HeadType").has_animation(_Type):
		get_node("HeadType").play(_Type)
