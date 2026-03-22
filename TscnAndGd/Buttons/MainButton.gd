extends Button

var _click_Audio
var _focus_Audio
export var ButLabel: String
export var ButType: int
onready var Ani = get_node("Ani")

func _ready() -> void :
	if not GameLogic.is_connected("OPTIONSYNC", self, "_Tr_Set"):
		var _SYNC = GameLogic.connect("OPTIONSYNC", self, "_Tr_Set")
	call_deferred("call_init")
func _Tr_Set():
	self.text = GameLogic.CardTrans.get_message(ButLabel)

func call_init():
	_Tr_Set()

	var _ErrCheck

	_ErrCheck = self.connect("pressed", self, "call_down")
	if _ErrCheck:
		printerr("Error:", self.name, _ErrCheck)
	_ErrCheck = self.connect("focus_entered", self, "focus_Audio")
	if _ErrCheck:
		printerr("Error:", self.name, _ErrCheck)

	_pivot_offset_set()
	Audio_init()

func _pivot_offset_set():
	self.rect_pivot_offset = self.rect_size / 2

func Audio_init():
	_focus_Audio = GameLogic.Audio.But_EasyClick
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
		_:
			_click_Audio = GameLogic.Audio.But_Click
func on_pressed():
	_click_Audio.play(0)
func focus_Audio():
	_focus_Audio.play(0)

func call_down():
	if Ani.current_animation != "pressed" and not self.disabled:
		Ani.play("pressed")

func _on_draw() -> void :
	self.text = GameLogic.CardTrans.get_message(ButLabel)
