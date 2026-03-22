extends Node2D

func _ready():
	pass

func call_del():
	self.queue_free()
