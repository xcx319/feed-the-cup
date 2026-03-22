extends Node2D

export var Audio_Bool: bool = true

var _Num: int
var _curAni
onready var aniPlayer = $AniNode / AnimationPlayer

onready var Audio_Open
onready var Audio_Close = null

export var CANOPEN: bool = true

func _ready() -> void :
	if has_node("Audio"):
		Audio_Open = get_node("Audio")
	else:
		Audio_Open = GameLogic.Audio.return_Effect("开门")
		Audio_Close = GameLogic.Audio.return_Effect("关门")
func _StaticLogic():

	if aniPlayer.has_animation("opentime"):
		aniPlayer.play("opentime")
func _on_player_entered(_body: Node) -> void :

	if _Num == 0:
		if not CANOPEN:
			if aniPlayer.assigned_animation != "close":
				aniPlayer.play("close")
		else:
			aniPlayer.play("open")
			if Audio_Bool:
				Audio_Open.play(0)
				if Audio_Close != null:
					Audio_Close.stop()
	_Num += 1

func call_Lock_Ani():
	if has_node("AniNode/LockAni"):
		var _LockAni = $AniNode / LockAni
		if CANOPEN:
			_LockAni.play("init")
		else:
			_LockAni.play("Lock")
func _on_player_exited(_body: Node) -> void :
	_Num -= 1

	if not CANOPEN:
		if aniPlayer.assigned_animation != "close":
			aniPlayer.play("close")
		return
	if _Num == 0:

		aniPlayer.play("close")

		if Audio_Bool:
			if Audio_Close != null:
				Audio_Close.play(0)
				Audio_Open.stop()

func _on_Timer_timeout() -> void :
	aniPlayer.play("close")
	if Audio_Bool:
		if Audio_Close != null:
			Audio_Close.play(0)
func AniCall_Closed():
	_curAni = "close"
