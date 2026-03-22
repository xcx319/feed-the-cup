extends Button

var _click_Audio
export var EffectName: String
export var ButType: int
onready var Ani = get_node("Ani")
onready var NameLabel = get_node("BG/Control/NameLabel")
onready var NumLabel = get_node("ProgressNode/NumLabel")

onready var LockAni = get_node("BG/Control/Lock/Ani")
onready var Progress = get_node("ProgressNode/Progress")
var Type: int
var NameInfo: String
var CheckBool: bool = false
var Cost: int

func _ready() -> void :

	call_deferred("_connect")

func call_grab():
	self.grab_focus()

	pass
func _connect():
	var _connect

	if not self.is_connected("pressed", self, "on_pressed"):
		_connect = self.connect("pressed", self, "on_pressed")
	if rect_pivot_offset == Vector2.ZERO:
		rect_pivot_offset = rect_size / 2
	call_deferred("call_set")

func call_init(_Name):

	if GameLogic.Config.AchievementConfig.has(_Name):

		NameInfo = _Name

		var INFO = GameLogic.Config.AchievementConfig[_Name]
		Type = 0
		NameLabel.text = GameLogic.CardTrans.get_message(INFO.Name)
		var _MaxValue: int = int(INFO.Num)
		var _Value: int = GameLogic.Achievement.return_Achievement_Value(INFO.Type)

		if _Value > _MaxValue:
			_Value = _MaxValue
		Progress.max_value = _MaxValue
		Progress.value = _Value
		NumLabel.text = str(_Value) + "/" + str(_MaxValue)

		_check_logic()
func _check_logic():

	if GameLogic.Achievement.AchievementReward_Array.has(NameInfo):
		Ani.play("Check")
		CheckBool = true

	else:
		if GameLogic.Achievement.Achievement_Array.has(NameInfo):

			Ani.play("UnLock")

		else:
			Ani.play("disable")


func _on_Button_pressed():

	if Ani.assigned_animation != "UnLock":

		return
	if not GameLogic.Achievement.AchievementReward_Array.has(NameInfo):

		GameLogic.Audio.But_Apply.play(0)

		return true

	return

func call_set():
	_click_Audio = GameLogic.Audio.But_EasyClick

func on_pressed():

	if _click_Audio:
		_click_Audio.play(0)
