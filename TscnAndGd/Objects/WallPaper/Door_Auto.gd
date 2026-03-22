extends Node2D

var playerlist = ["Player1P", "saPlayer2P"]
var _Num: int
var _curAni
onready var aniPlayer = $AniNode / AnimationPlayer

onready var timer = $Timer

var cur_playerList: Array

func _ready() -> void :
	_curAni = "init"

	var _CON = GameLogic.connect("OpenStore", self, "_DoorLogic")
	var _DatStart = GameLogic.connect("DayStart", self, "_StaticLogic")
	var _DayEnd = GameLogic.connect("CloseLight", self, "_on_Timer_timeout")
func call_init():
	_curAni = "init"
	aniPlayer.play("init")

func _StaticLogic():
	_curAni = "OpenTime"
	aniPlayer.play("opentime")

func _DoorLogic():

	if _curAni != "open":
		_curAni = "open"
		aniPlayer.play("open")
		get_node("Audio").play(0)
func _on_body_entered(_body: Node) -> void :

	if _body.has_method("_PlayerNode"):
		if _body.Stat.Skills.has("技能-穿越"):
			return
	if _Num == 0:

		if aniPlayer.current_animation == "close":
			var _time = aniPlayer.current_animation_length - aniPlayer.current_animation_position
			aniPlayer.play("open", _time)
			if not get_node("Audio").is_playing():
				get_node("Audio").play(0)
		elif _curAni != "open":
			_curAni = "open"
			aniPlayer.play("open")
			if not get_node("Audio").is_playing():
				get_node("Audio").play(0)
	_Num += 1
	timer.set_paused(true)

func _on_body_exited(_body: Node) -> void :
	if _body.has_method("_PlayerNode"):
		if _body.Stat.Skills.has("技能-穿越"):
			return
	_Num -= 1

	if _Num == 0:
		if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:

			if timer.is_inside_tree():
				timer.set_paused(false)
				timer.start(0)
		else:

			if timer.is_inside_tree():
				timer.set_paused(false)
				timer.start(0)

func _on_Timer_timeout() -> void :

	if not GameLogic.Order.cur_OrderList.size():

		if not aniPlayer.assigned_animation in ["close", "init"]:
			aniPlayer.play("close")
			_curAni = "close"
	else:
		timer.start(0)
func AniCall_Closed():
	if _Num == 0:
		_curAni = "close"
