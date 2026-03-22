extends Node2D

var MoveBool: bool
var IdleBool: bool = true

func _ready():
	pass

func _rand_idle_ani(_SWITCH):
	return
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
	var _Audio = GameLogic.Audio.return_RandEffect("室外")

	if _Audio:
		_Audio.play(0)
