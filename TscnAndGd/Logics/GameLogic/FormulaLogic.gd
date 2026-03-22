extends Node

var Formula_keys: Array

func _ready() -> void :
	call_deferred("call_init")

func call_init():
	if not GameLogic.Config.FormulaConfig:
		return
	Formula_keys = GameLogic.Config.FormulaConfig.keys()



func return_list():
	pass
