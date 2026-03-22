extends Control

var cur_type: String setget _But_Init
var _LeftTime: int = 0
onready var Ani = get_node("Ani")
onready var TypeAni = get_node("TypeAni")
onready var OneSTimer = get_node("Timer")
onready var TimeLabel = get_node("Control/TimeLabel")
func _ready() -> void :
	pass
func call_init(_Type: String, _Time: int):
	_But_Init(_Type)
	_LeftTime = _Time
	TimeLabel.text = str(_LeftTime)
	if _LeftTime > 1:
		OneSTimer.start()
	else:
		Ani.play("TimeEnd")
func _on_Timer_timeout():
	_LeftTime -= 1
	TimeLabel.text = str(_LeftTime)
	if _LeftTime < 1:
		Ani.play("TimeEnd")
		OneSTimer.stop()
	pass

func call_del():
	self.get_parent().remove_child(self)
	self.queue_free()

func _But_Init(_Type: String):
	cur_type = _Type
	if get_node("Control/IconNode/IconAni").has_animation(cur_type):
		get_node("Control/IconNode/IconAni").play(cur_type)
