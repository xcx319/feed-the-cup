extends Button

onready var Player_Unlock
var SelfID = null
var _butType
onready var SelectUI = get_parent().get_parent().get_parent().get_parent()

func _ready() -> void :

	set_process(false)
	var _ErrCheck
	_ErrCheck = self.connect("pressed", self, "on_pressed")
	if _ErrCheck:
		print(self.name, _ErrCheck)
	_butType = editor_description
	self.disabled = true
	call_deferred("NoAni_Set")
func NoAni_Set():
	get_node("C/LogicNode/Control").call_NoAni_Set()

func call_set(_id):
	SelfID = _id
	self.disabled = false
	get_node("C").modulate = Color8(255, 255, 255, 255)
	set_process(true)

func on_pressed():
	match _butType:
		"1":
			GameLogic.Audio.But_Base.play()
		_:
			GameLogic.Audio.But_Base.play()
