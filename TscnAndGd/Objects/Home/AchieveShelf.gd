extends Node2D

onready var aniPlayer = $AniNode / Ani

func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")
