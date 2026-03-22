extends Node2D

onready var PressureSet = get_node("OffsetNode/TextureProgress")

var tex_up
var tex_down
var tex_side

var Pressure: int = 0
var PressureMax: int
var Pressure_Old: int

func return_Pressure_IsMax():
	if Pressure < PressureMax:
		return false
	else:
		return true

func call_texture_init():
	tex_up = get_parent().get_node("Up").get_texture()
	tex_down = get_parent().get_node("Down").get_texture()
	tex_side = get_parent().get_node("Left").get_texture()
	call_up()
	call_side()
	call_down()
func call_init(_num, _numMax):
	call_texture_init()

	call_set(_num, _numMax)
	call_down()

func call_set(_num, _numMax):

	if GameLogic.LoadingUI.IsHome:
		Pressure = int(0)
		PressureMax = int(_numMax)
		PressureSet.max_value = PressureMax
		PressureSet.value = Pressure
		return
	Pressure = int(_num)
	PressureMax = int(_numMax)
	PressureSet.max_value = PressureMax
	PressureSet.value = Pressure

func call_up():
	PressureSet.set_progress_texture(tex_up)

func call_down():
	PressureSet.set_progress_texture(tex_down)

func call_side():
	PressureSet.set_progress_texture(tex_side)
