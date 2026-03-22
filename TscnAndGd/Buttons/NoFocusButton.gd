extends Button

var _click_Audio
export var EffectName: String
export var ButType: int
export var _butType: String = "empty"
export var _ActionModeBool: bool = false
func _ready() -> void :

	call_deferred("_connect")
func _connect():
	var _connect
	_connect = self.connect("button_down", self, "call_down")
	_connect = self.connect("button_up", self, "call_up")
	if not self.is_connected("pressed", self, "on_pressed"):
		_connect = self.connect("pressed", self, "on_pressed")



	if rect_pivot_offset == Vector2.ZERO:
		rect_pivot_offset = rect_size / 2
	call_deferred("call_init")
	set_process(false)
func call_init():

	if EffectName:

		for _Effect in GameLogic.Audio.EffectList:

			if _Effect.name == EffectName:
				_click_Audio = _Effect
				break

	else:
		match ButType:
			GameLogic.Audio.BUTTYPE.EASYCLICK:
				_click_Audio = GameLogic.Audio.But_EasyClick
			GameLogic.Audio.BUTTYPE.CLICK:
				_click_Audio = GameLogic.Audio.But_Click
			GameLogic.Audio.BUTTYPE.APPLY:
				_click_Audio = GameLogic.Audio.But_Apply
			GameLogic.Audio.BUTTYPE.BACK:
				_click_Audio = GameLogic.Audio.But_Back
			GameLogic.Audio.BUTTYPE.SWITCHON:
				_click_Audio = GameLogic.Audio.But_SwitchOn
			GameLogic.Audio.BUTTYPE.SWITCHOFF:
				_click_Audio = GameLogic.Audio.But_SwitchOff
			_:
				if self.name == "BackBut" or self.name == "Back":
					_click_Audio = GameLogic.Audio.But_Back
				elif self.name == "ApplyBut" or self.name == "Apply":
					_click_Audio = GameLogic.Audio.But_Apply
				elif self.name == "ReBut":
					_click_Audio = GameLogic.Audio.But_Click

	if has_node("Type"):
		var TypeAni = get_node("Type")
		if TypeAni.has_animation(_butType):
			TypeAni.play(_butType)
	match _ActionModeBool:
		true:
			action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		false:
			action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
func on_pressed():

	if _click_Audio:
		_click_Audio.play(0)
func call_down():
	var Ani
	if has_node("Ani"):

		Ani = get_node("Ani")
		if Ani.current_animation != "pressed" and not self.disabled:
			Ani.play("pressed")
func call_up():
	var Ani
	if has_node("Ani"):
		Ani = get_node("Ani")
		if Ani.assigned_animation == "pressed":
			Ani.play_backwards("pressed")
	if _click_Audio:
		_click_Audio.stop()
func call_pressed():
	on_pressed()
	var Ani
	if has_node("Ani"):
		Ani = get_node("Ani")
		if Ani.current_animation != "press_one" and not self.disabled:
			Ani.play_backwards("press_one")
