extends Button
var _focus_Audio
func _ready() -> void :
	set_process(false)

	var _ErrCheck
	if not self.is_connected("focus_entered", self, "_on_focus_entered"):
		_ErrCheck = self.connect("focus_entered", self, "_on_focus_entered")
		if _ErrCheck:
			printerr("Option But:", self.name, _ErrCheck)
	if not self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		_ErrCheck = self.connect("mouse_entered", self, "_on_mouse_entered")
		if _ErrCheck:
			printerr("Option But:", self.name, _ErrCheck)
	call_deferred("Audio_init")

func _pivot_offset_set():
	self.rect_pivot_offset = self.rect_size / 2

func Audio_init():
	_focus_Audio = GameLogic.Audio.But_EasyClick
func _on_focus_entered() -> void :

	if not self.pressed:
		self.pressed = true
		_focus_Audio.play(0)


func _on_mouse_entered() -> void :

	if is_hovered():
		self.grab_focus()
