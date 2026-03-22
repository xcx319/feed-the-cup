extends Node2D

func _ready():
	call_deferred("call_effect")

func call_effect():
	var _Rand = str(GameLogic.return_RANDOM() % 4 + 1)
	get_node("AnimationPlayer").play(_Rand)

func call_del():
	get_parent().remove_child(self)
	self.queue_free()
