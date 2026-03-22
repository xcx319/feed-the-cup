extends Node

var input_vector = Vector2.ZERO setget call_vector
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
	RUBBING
	DUMPING
	FALLDOWN
	EATTING
	IDLE_ANI_1
	IDLE_ANI_2
	IDLE_ANI_3
	IDLE_ANI_4
	SMASH
	SIT
	ANGRY_2
}
var state = STATE.IDLE_EMPTY setget call_state
var ArmState = STATE.IDLE_EMPTY setget call_ArmState
var IsHold: bool
var HoldInsId: int
var NeedPush: bool

onready var Stat = get_parent().get_node("Stat")
onready var playerNode = get_parent().get_parent()

var stateSave = GameLogic.NPC.STATE.IDLE_EMPTY
func call_vector(_VECTOR):
	input_vector = _VECTOR
	playerNode.call_StatChange()
func call_ArmState(_ARMSTATE):
	ArmState = _ARMSTATE
	playerNode.call_StatChange()
func call_state(_STATE):
	if stateSave != _STATE:
		stateSave = _STATE
	state = _STATE
	playerNode.call_StatChange()
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
