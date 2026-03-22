extends Button

var IsScaleMin: bool
var _scaleMax = 1.2
var _scaleMin = 0.8
var _scaleSpeed = 3

var _downAni = 0

var _click_Audio
var _butType = 0

func _ready() -> void :

	var _connect
	_connect = self.connect("button_down", self, "_button_down")
	_connect = self.connect("button_up", self, "_button_up")
	if not self.is_connected("pressed", self, "on_pressed"):
		_connect = self.connect("pressed", self, "on_pressed")



	if editor_description != "":
		_butType = editor_description

	rect_pivot_offset = rect_size / 2

	set_process(false)

func _button_down():
	_downAni = 1
func _button_up():
	_downAni = 2
func on_pressed():
	match _butType:
		"1":
			_click_Audio.play()
