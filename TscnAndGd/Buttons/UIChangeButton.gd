extends Button

var _scaleMin = 0.8
var _scaleSpeed = 3

var _downAni = 0

var _click_Audio
export var ButType = 0

func _ready() -> void :

	var _connect
	_connect = self.connect("button_down", self, "_button_down")
	_connect = self.connect("button_up", self, "_button_up")
	if not self.is_connected("pressed", self, "on_pressed"):
		_connect = self.connect("pressed", self, "on_pressed")

	rect_pivot_offset = rect_size / 2
	call_deferred("Audio_init")
	set_process(false)
func Audio_init():
	match ButType:
		GameLogic.Audio.BUTTYPE.APPLY:
			_click_Audio = GameLogic.Audio.But_Apply
		GameLogic.Audio.BUTTYPE.BACK:
			_click_Audio = GameLogic.Audio.But_Back
		GameLogic.Audio.BUTTYPE.SWITCHON:
			_click_Audio = GameLogic.Audio.But_SwitchOn
		GameLogic.Audio.BUTTYPE.SWITCHOFF:
			_click_Audio = GameLogic.Audio.But_SwitchOff
		GameLogic.Audio.BUTTYPE.EASYCLICK:
			_click_Audio = GameLogic.Audio.But_EasyClick
		GameLogic.Audio.BUTTYPE.CLICK:
			_click_Audio = GameLogic.Audio.But_Click

func _button_down():
	_downAni = 1

func _button_up():
	_downAni = 2
func on_pressed():
	_click_Audio.play()
