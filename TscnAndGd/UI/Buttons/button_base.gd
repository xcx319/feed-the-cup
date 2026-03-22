extends Button

var _scaleMin = 0.8
var _scaleSpeed = 3

var _downAni = 0
export var NeedTranText: bool

var _butType = 0

func _ready() -> void :
	if NeedTranText:
		self.text = GameLogic.CardTrans.get_message(text)
	set_physics_process(false)

	var _ErrCheck
	_ErrCheck = self.connect("button_down", self, "_button_down")
	if _ErrCheck:
		printerr("But Base1:", self.name, _ErrCheck)
	_ErrCheck = self.connect("button_up", self, "_button_up")
	if _ErrCheck:
		printerr("But Base2:", self.name, _ErrCheck)
	_ErrCheck = self.connect("pressed", self, "on_pressed")
	if _ErrCheck:
		printerr("But Base3:", self.name, _ErrCheck)
	if self.is_connected("focus_entered", self, "_on_focus_entered"):
		_ErrCheck = self.connect("focus_entered", self, "_on_focus_entered")
	if _ErrCheck:
		printerr("But Base4:", self.name, _ErrCheck)
	if self.is_connected("mouse_entered", self, "_on_mouse_entered"):
		_ErrCheck = self.connect("mouse_entered", self, "_on_mouse_entered")
	if _ErrCheck:
		printerr("But Base5:", self.name, _ErrCheck)

	_butType = editor_description
	_pivot_offset_set()


func _pivot_offset_set():
	self.rect_pivot_offset = self.rect_size / 2

func _physics_process(delta):

	match _downAni:
		1:
			if self.rect_scale != Vector2(_scaleMin, _scaleMin):
				if self.rect_scale.x > _scaleMin:
					self.rect_scale.x -= _scaleSpeed * delta
					self.rect_scale.y -= _scaleSpeed * delta
				elif self.rect_scale.x < _scaleMin:
					self.rect_scale = Vector2(_scaleMin, _scaleMin)
			elif _downAni != 2:
				_downAni = 2
				set_physics_process(true)
		2:
			if self.rect_scale != Vector2(1, 1):
				if self.rect_scale.x > 1:
					self.rect_scale = Vector2(1, 1)
				elif self.rect_scale != Vector2(1, 1):
					self.rect_scale.x += _scaleSpeed * delta
					self.rect_scale.y += _scaleSpeed * delta
			elif _downAni != 0:
				_downAni = 0
				set_physics_process(false)
		3:
			if self.rect_scale.x > _scaleMin:
				self.rect_scale.x -= _scaleSpeed * delta
				self.rect_scale.y -= _scaleSpeed * delta
			elif self.rect_scale.x < _scaleMin:
				self.rect_scale = Vector2(_scaleMin, _scaleMin)
				_downAni = 2
func _button_down():

	_downAni = 1
	set_physics_process(true)

func _button_up():
	_downAni = 2
	set_physics_process(true)

func on_pressed():
	match _butType:
		"1":
			GameLogic.Audio.But_Click.play()

		_:
			GameLogic.Audio.But_Click.play()

func call_pressed():
	match _butType:
		"1":
			GameLogic.Audio.But_Click.play()

		_:
			GameLogic.Audio.But_Click.play()

	_downAni = 3

func _on_focus_entered() -> void :
	if not self.pressed:
		if self.rect_scale != Vector2(1, 1):
			_downAni = 2
			set_physics_process(true)

func _on_mouse_entered() -> void :
	if is_hovered():
		self.grab_focus()
