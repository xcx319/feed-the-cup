extends RigidBody2D

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
onready var Stat = get_node("Player/LogicNode/Stat")
onready var Con = get_node("Player/LogicNode/Control")
onready var AVATAR
onready var WeaponNode
onready var Collision = get_node("CollisionShape2D")
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

var _Pressure_1_Bool: bool
var FootPrint: int = 0
var FootWaterColor

func _PlayerNode():
	pass
func call_control(_type: int):
	get_node("Player").call_control(_type)
