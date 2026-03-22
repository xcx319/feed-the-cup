extends Button

var _scaleMin = 0.95
var _scaleSpeed = 3

var _downAni = 0

var _butType = 0

onready var Ani = get_node("AnimationPlayer")

func _ready() -> void :

	var _ErrCheck
	_ErrCheck = self.connect("button_down", self, "_button_down")
	if _ErrCheck:
		print("SceneButton Error:", self.name, _ErrCheck)
	_ErrCheck = self.connect("button_up", self, "_button_up")
	if _ErrCheck:
		print("SceneButton Error:", self.name, _ErrCheck)
	_ErrCheck = self.connect("pressed", self, "on_pressed")
	if _ErrCheck:
		print("SceneButton Error:", self.name, _ErrCheck)

	_butType = editor_description
	_pivot_offset_set()

	set_process(false)

func _pivot_offset_set():
	self.rect_pivot_offset = self.rect_size / 2

func _button_down():

	_downAni = 1

func _button_up():
	_downAni = 2

func on_pressed():
	match _butType:
		"1":
			GameLogic.Audio.But_Base.play()

		_:
			GameLogic.Audio.But_Base.play()

func call_pressed():
	match _butType:
		"1":
			GameLogic.Audio.But_Base.play()

		_:
			GameLogic.Audio.But_Base.play()

	_downAni = 3

func _on_0_mouse_entered() -> void :
	self.grab_focus()
