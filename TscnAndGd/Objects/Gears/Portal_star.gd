extends Node2D

var PortalOutPos: Vector2
onready var PortalAni = $Ani
func _ready():
	PortalOutPos = $OutPoint.global_position

func _on_Area2D_body_entered(_body):
	if _body.has_method("_PlayerNode"):
		_body.call_Portal_Pos(PortalOutPos)
		PortalAni.play("Portal")

func _on_Area2D_body_exited(_body):
	pass
