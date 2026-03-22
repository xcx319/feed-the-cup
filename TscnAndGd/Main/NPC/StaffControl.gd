extends Node

var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var IsJoy: bool
var JoyDevice: int
var CanPressA: bool
var Pressed: bool

enum STATE{
	IDLE_EMPTY
	MOVE
	IDLE_THINK
	IDLE_ORDER
	WORK
	STIR
	SHAKE
	ORDER
	SQUEEZE
	SHOW
	DISABLE
	DEAD
	IDLE_ACT
	DISABLE
}
var state = STATE.IDLE_EMPTY
var ArmState = STATE.IDLE_EMPTY
var IsHold: bool
var HoldInsId: int
var IsMixing: bool
var NeedPush: bool

onready var Stat = get_parent().get_node("Stat")
onready var playerNode = get_parent().get_parent()

func _IsCourier_check():
	if playerNode.IsCourier:
		NeedPush = true

func call_show_switch(_switch):
	match _switch:
		true:
			state = STATE.SHOW
		false:
			state = STATE.IDLE_EMPTY
func call_NoAni_Set():
	state = STATE.DISABLE

func call_OpenLogic(_Obj):
	ArmState = STATE.WORK
	var _WorkTime = 4 - playerNode.LV_Open
	var _Speed: float = 1.0
	if GameLogic.Player2_bool:
		_Speed = _Speed / GameLogic.Player2_Mult

	var _return = _Obj.return_WORK_start(playerNode, _Speed)
