extends Node2D

onready var TypeAni = get_node("TypeAni")

func _ready():
	call_deferred("call_init")
func call_init():
	var _TYPE: String
	if round(rotation_degrees) == 0:
		_TYPE = "L"
	elif round(rotation_degrees) in [90, - 270]:
		_TYPE = "U"
	elif round(rotation_degrees) in [180, - 180]:
		_TYPE = "R"
	elif round(rotation_degrees) in [270, - 90]:
		_TYPE = "D"
	if get_node("TypeAni").has_animation(_TYPE):
		get_node("TypeAni").play(_TYPE)
