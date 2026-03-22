extends Button

onready var EggPoint = $EggPoint

export var EGGNUM: int = 0
export var ID: String
onready var NumLabel = $NumLabel

func _ready():
	call_num_init()

func call_num_init():
	if EGGNUM > 0:
		NumLabel.text = str(EGGNUM)
	else:
		NumLabel.text = ""

func _on_EggBut_toggled(_PressedBool):
	match _PressedBool:
		true:
			if not GameLogic.cur_EggList.has(ID):
				if GameLogic.cur_EggList.size() < 3:
					GameLogic.cur_EggList.append(ID)
				else:
					self.pressed = false
		false:
			if GameLogic.cur_EggList.has(ID):
				GameLogic.cur_EggList.erase(ID)
