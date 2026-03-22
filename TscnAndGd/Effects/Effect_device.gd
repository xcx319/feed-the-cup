extends Node2D

onready var Ani = get_node("AnimationPlayer")

func call_OpenBox_Ani():
	Ani.play("OpenBox")
