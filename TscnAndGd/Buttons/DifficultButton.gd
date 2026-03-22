extends Button

export var TYPE: int
export var BASECHECK: bool
onready var Ani = get_node("Ani")
onready var TypeAni = get_node("Type")

func _ready() -> void :
	call_deferred("call_init")

func call_init():
	if TypeAni.has_animation(self.name):
		TypeAni.play(self.name)
	elif TypeAni.has_animation(str(TYPE)):
		TypeAni.play(str(TYPE))
	call_unlock(BASECHECK)
func call_check(_LEVELID):
	if GameLogic.Level_Data.has(_LEVELID):
		var _DEVILMAX: int = int(GameLogic.Config.SceneConfig[_LEVELID].DevilMax)
		if not GameLogic.Level_Data[_LEVELID].has("cur_Devil"):
			GameLogic.Level_Data[_LEVELID]["cur_Devil"] = 0
		var _CURDEVIL: int = int(GameLogic.Level_Data[_LEVELID].cur_Devil)
		if _CURDEVIL < (_DEVILMAX - 1):
			Ani.play("Devil")
		else:
			Ani.play("Check")
func call_unlock(_bool: bool):
	match _bool:
		true:
			Ani.play("Unlock")
		false:
			Ani.play("Lock")
