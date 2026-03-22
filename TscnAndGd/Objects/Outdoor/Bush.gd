extends Area2D

func _ready():
	pass

func _on_Bush_body_entered(_body):
	$Aninode / Act.play("shake")
	pass
