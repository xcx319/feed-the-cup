extends Button

var _scaleMin = 0.8
var _scaleSpeed = 3

var _downAni = 0

var _click_Audio
var _butType = 0

func _ready() -> void :


	focus_mode = FOCUS_NONE


	if editor_description != "":
		_butType = editor_description

	rect_pivot_offset = rect_size / 2
	call_deferred("call_init")
	set_process(false)
func call_init():
	_click_Audio = GameLogic.Audio.But_Base

func call_button_down():
	_downAni = 1
	on_pressed()
func _button_up():
	_downAni = 2
func on_pressed():

	match int(_butType):
		1:
			_click_Audio.play()
		0:
			_click_Audio.play()
