extends RigidBody2D

func _ready():
	var _rand = GameLogic.return_RANDOM() % 3
	$Cup / Act.play(str(_rand))
	_rand = GameLogic.return_RANDOM() % 15
	$Cup / AniNode / PersonalityAni.play(str(_rand))
	pass
