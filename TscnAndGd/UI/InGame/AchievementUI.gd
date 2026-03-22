extends CanvasLayer

var cur_pressed: bool

onready var BackBut = $Control / ButControl / BackBut
onready var HomeBut
onready var InfoButNode = $Control / Info / BG / Scroll / VBox
onready var Ach_UnLock = $Control / InfoControl / UnlockLabel
onready var Ach_Name = $Control / InfoControl / Name
onready var Ach_Sprite = $Control / InfoControl / RewardLabel / Sprite
onready var Ach_Label = $Control / InfoControl / RewardLabel / Label
onready var Ach_HomeMoney = $Control / InfoControl / RewardLabel / HomeMoneyLabel
onready var Ach_HomeMoneyLabel = $Control / RewardControl / Reward / HomeMoneyLabel
onready var HomeUpdateBut = preload("res://TscnAndGd/Buttons/AchievementButton.tscn")
onready var HomeUpdateGroups = preload("res://TscnAndGd/Buttons/Achievement_Group.tres")
onready var CurButGroup

var IsReward: bool
var CanEndReward: bool

func call_connect():
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")
	cur_pressed = false
	GameLogic.Can_ESC = false
func _del_all_InfoButton():
	var _child_array = InfoButNode.get_children()
	for i in _child_array.size():
		var _but = _child_array[i]
		var _butPar = _but.get_parent()
		_butPar.remove_child(_but)
		_but.queue_free()
func _add_InfoButton():
	var _Data_Array: Array
	_Data_Array = GameLogic.Config.AchievementConfig.keys()

	var _MoveEndList: Array
	var _NUM: int = 0
	CurButGroup = HomeUpdateGroups
	for i in _Data_Array.size():

		var _CHECK = _Data_Array[i]

		var _INFO = GameLogic.Config.AchievementConfig[_CHECK]
		var _UnLock = _INFO.PreUnlock
		if _UnLock != "-1":
			if not GameLogic.Achievement.AchievementReward_Array.has(_UnLock):
				continue
		var _USEBOOL = _INFO.UseBool
		if _USEBOOL == "True":
			var _But = HomeUpdateBut.instance()

			InfoButNode.add_child(_But)
			_But.connect("toggled", self, "call_HomeButton_pressed")
			_But.connect("pressed", self, "call_Reward_Show")


			_But.set_button_group(CurButGroup)
			_But.call_init(_Data_Array[i])
			if _But.CheckBool:
				_MoveEndList.append(_But)
				InfoButNode.remove_child(_But)
			_NUM += 1

	for _But in _MoveEndList:

		InfoButNode.add_child(_But)
	_set_OrderBut_focus()

func _set_OrderBut_focus():




	var _but_Array = InfoButNode.get_children()
	for i in _but_Array.size():
		var _but = _but_Array[i]
		_but.name = str(i)
		if i == 0:
			HomeBut = _but
			_but.set_pressed(true)
			_but.grab_focus()

	for i in _but_Array.size():
		var _but = _but_Array[i]
		var _butpath = _but.get_path()
		if _but_Array.size() > 1:
			if i == 0:
				_but.set_focus_neighbour(MARGIN_TOP, _butpath)
			else:
				var _upbut = _but_Array[i - 1]
				var _upbutpath = _upbut.get_path()
				_but.set_focus_neighbour(MARGIN_TOP, _upbutpath)
			if i == _but_Array.size() - 1:
				_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
			else:
				var _nextbut = _but_Array[i + 1]
				var _nextbutpath = _nextbut.get_path()
				_but.set_focus_neighbour(MARGIN_BOTTOM, _nextbutpath)
		else:
			_but.set_focus_neighbour(MARGIN_BOTTOM, _butpath)
		_but.set_focus_neighbour(MARGIN_LEFT, _butpath)
		_but.set_focus_neighbour(MARGIN_RIGHT, _butpath)
func call_init():
	_del_all_InfoButton()
	_add_InfoButton()
func call_closed():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.Can_ESC = true

func call_Reward_Show():
	var _But = HomeBut.group.get_pressed_button()
	if is_instance_valid(_But):
		if _But.Ani.assigned_animation != "UnLock":
			return
		if not GameLogic.Achievement.AchievementReward_Array.has(_But.NameInfo):

			if not IsReward:
				$Ani.play("Reward")
				IsReward = true
				CanEndReward = false
				GameLogic.Achievement.call_AchievementReward_Add(_But.NameInfo)
				_But.Ani.play("Get")
				GameLogic.call_save()
func _control_logic(_but, _value, _type):

	if not IsReward:
		if _value == 1 or _value == - 1:
			match _but:
				"B", "START":

					BackBut.on_pressed()

				"A":
					if cur_pressed == false:
						cur_pressed = true
						var _But = HomeBut.group.get_pressed_button()
						if _But._on_Button_pressed():
							_But.release_focus()
							call_Reward_Show()
				"u", "U":
					if cur_pressed == false:
						cur_pressed = true
						var _But = HomeBut.group.get_pressed_button()
						var _Name = str(int(_But.name) - 1)

						if InfoButNode.has_node(_Name):
							InfoButNode.get_node(_Name).grab_focus()
							InfoButNode.get_node(_Name).pressed = true
							InfoButNode.get_node(_Name).on_pressed()

				"d", "D":
					if cur_pressed == false:
						cur_pressed = true
						var _But = HomeBut.group.get_pressed_button()
						var _Name = str(int(_But.name) + 1)

						if InfoButNode.has_node(_Name):
							InfoButNode.get_node(_Name).grab_focus()
							InfoButNode.get_node(_Name).pressed = true
							InfoButNode.get_node(_Name).on_pressed()
	else:
		if _value == 1 or _value == - 1:
			match _but:
				"A":
					call_EndReward()
				"B", "START":
					return
		pass
	if _type == 0 or _value == 0:
		cur_pressed = false
func call_EndReward():
	if CanEndReward:
		$Ani.play("RewardEnd")
		call_init()
		CanEndReward = false
		IsReward = false
func call_CanEndReward():
	CanEndReward = true
func call_HomeButton_pressed(_pressed: bool):
	if _pressed:
		var _But = HomeBut.group.get_pressed_button()
		call_AchievementInfo_Show(_But.NameInfo)

func call_AchievementInfo_Show(_AchievementID: String):

	Ach_HomeMoney.hide()
	Ach_HomeMoneyLabel.hide()
	if GameLogic.Config.AchievementConfig.has(_AchievementID):
		var _INFO = GameLogic.Config.AchievementConfig[_AchievementID]

		Ach_Name.text = GameLogic.CardTrans.get_message(_INFO.Name)
		Ach_UnLock.text = GameLogic.CardTrans.get_message(_INFO.UnLockInfo)
		if _INFO.UnlockText != "0":
			Ach_Label.call_Tr_TEXT(_INFO.UnlockText)

			Ach_Label.show()
			$Control / RewardControl / Reward / Label.call_Tr_TEXT(_INFO.UnlockText)
		else:
			Ach_Label.hide()
		if _INFO.UnlockSprite != "0":
			var _Tex = load(_INFO.UnlockSprite)
			Ach_Sprite.set_texture(_Tex)
			Ach_Sprite.show()
			$Control / RewardControl / Reward / Sprite.set_texture(_Tex)
		else:
			Ach_Sprite.hide()

		if int(_INFO.Rewards) > 0:
			Ach_HomeMoney.text = str(_INFO.Rewards)
			Ach_HomeMoney.show()

			Ach_HomeMoneyLabel.text = str(_INFO.Rewards)
			Ach_HomeMoneyLabel.show()
