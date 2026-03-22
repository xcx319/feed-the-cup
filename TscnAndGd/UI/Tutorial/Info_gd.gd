extends Node2D

onready var Ani = get_node("AniNode/Ani")

func call_show(_name):
	if Ani.has_animation(_name):
		Ani.play(_name)
