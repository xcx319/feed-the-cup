extends Button
export var NameStr: String
export var InfoStr: String
export (String, "1_1", "1_2", "1_3", "1_4", "1_5", "1_6", "1_7", "1_8") var LevelType: String = "1_1"
onready var NameLabel = get_node("InfoBG/Name")
onready var InfoLabel = get_node("InfoBG/Info")
onready var TypeAni = get_node("TypeAni")
onready var Ani = get_node("Ani")
export var LockBool: bool

func call_init():
	NameLabel.text = GameLogic.CardTrans.get_message(NameStr)
	InfoLabel.text = GameLogic.CardTrans.get_message(InfoStr)
	TypeAni.play(LevelType)
	if LockBool:
		Ani.play("Lock")
	else:
		Ani.play("Unlock")

func _on_toggled(button_pressed: bool) -> void :
	if LockBool:

		return
	if button_pressed:
		Ani.play("play")
		self.grab_focus()
		GameLogic.Audio.But_EasyClick.play(0)
	else:
		if LockBool:
			Ani.play("Lock")
		else:
			Ani.play("Unlock")

func _on_mouse_entered() -> void :
	if LockBool:
		return
	if not self.pressed:
		self.pressed = true
		_on_toggled(true)

func _on_focus_entered() -> void :
	if LockBool:
		return
	if not self.pressed:
		self.pressed = true
		_on_toggled(true)


func _on_1_focus_exited():
	_on_toggled(false)
