extends RigidBody2D

func _ready():
	var _rand = GameLogic.return_RANDOM() % 6
	$Ani.play(str(_rand))

	pass
