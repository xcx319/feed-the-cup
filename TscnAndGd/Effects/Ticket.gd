extends Node2D

var _Num: int

func _ready():
	call_deferred("_Ticket_Init")

func _Ticket_Init():
	get_node("Sprite/Label").text = str(_Num)
	pass
