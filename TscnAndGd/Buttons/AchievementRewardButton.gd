extends Button

var _click_Audio
export var EffectName: String
export var ButType: int
onready var Ani = get_node("Ani")
onready var TypeAni = get_node("Icon/TypeAni")

var Type: int
var NameInfo: String
var CheckBool: bool = false
var Cost: int
var IsUnlock: bool

var MAXNUM: int
var NUM: int
func _ready() -> void :

	call_deferred("_connect")

func call_grab():
	self.grab_focus()

	pass
func _connect():
	var _connect

	if rect_pivot_offset == Vector2.ZERO:
		rect_pivot_offset = rect_size / 2
	call_deferred("call_set")

func call_init(_Name, _MaxNum):

	MAXNUM = _MaxNum
	if GameLogic.Config.DevilBonusConfig.has(_Name):
		var _Num = int(GameLogic.Config.DevilBonusConfig[_Name].Num)
		$Label.text = str(_Num)
		NUM = _Num
		NameInfo = _Name

		if TypeAni.has_animation(NameInfo):
			TypeAni.play(NameInfo)
		if _Num <= _MaxNum:
			IsUnlock = true
			if not GameLogic.Achievement.AchievementReward_Array.has(NameInfo):
				GameLogic.Achievement.AchievementReward_Array.append(NameInfo)
			call_show()
		else:
			Ani.play("disable")
			if GameLogic.Achievement.AchievementReward_Array.has(NameInfo):

				GameLogic.Achievement.AchievementReward_Array.erase(NameInfo)

func call_show():
	if GameLogic.Achievement.AchievementReward_Array.has(NameInfo):
		if GameLogic.Achievement.cur_EquipList.has(NameInfo):
			if Ani.assigned_animation != "Check":
				Ani.play("Check")
		else:
			Ani.play("Normal")
func _check_logic():
	if GameLogic.Achievement.AchievementReward_Array.has(NameInfo):
		if GameLogic.Achievement.cur_EquipList.has(NameInfo):
			if Ani.assigned_animation != "Check":
				Ani.play("Check")
		else:
			if NUM <= MAXNUM:
				IsUnlock = true
				call_show()

			else:
				Ani.play("disable")



func call_set():
	_click_Audio = GameLogic.Audio.But_EasyClick

func on_pressed():

	if _click_Audio:
		_click_Audio.play(0)

func _on_Button_focus_entered():
	self.pressed = true
	on_pressed()
