extends Control

onready var TYPE = get_node("Sprite/Type")
onready var ANI = get_node("Sprite/Ani")
onready var NODE = get_node("Sprite")
func _ready():
	pass

func call_init(_Type: int, _Num: int, _Color: int):
	_Type_Set(_Type)
	_Num_Set(_Num)
	_Color_Set(_Color)
func _Type_Set(_Type: int):
	match _Type:
		0:
			TYPE.play("S")
		1:
			TYPE.play("M")
		2:
			TYPE.play("L")
		3:
			TYPE.play("S_elec")
func _Num_Set(_Num: int):
	NODE.set_frame(_Num)
func _Color_Set(_Color: int):
	match _Color:
		- 1:
			ANI.play("Reduce")
		0:
			ANI.play("Low")
		1:
			ANI.play("Normal")
		2:
			ANI.play("High")
		3:
			ANI.play("Tip")
		_:
			if _Color >= 10:
				var _G = 200 - _Color
				if _G < 0:
					_G = 0
				get_node("Sprite").set_modulate(Color8(255, _G, 0))
			pass
