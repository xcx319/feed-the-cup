extends Control
var cur_used: bool
var cur_DevName: String
onready var BuyButton = preload("res://TscnAndGd/Buttons/StoreDevButton.tscn")
onready var CurButGroup
onready var _ButGroup = preload("res://TscnAndGd/Buttons/UpdateButton_buttongroup.tres")
onready var ButList = get_node("Scroll/VBox")
var ComputerUI

func call_init():
	call_butlist_del()
	var _cur_DevList: Array = GameLogic.cur_Update_Name

	if _cur_DevList.size():
		for i in _cur_DevList.size():
			cur_DevName = _cur_DevList[i]
			if GameLogic.Config.DeviceConfig.has(cur_DevName):
				var _But = BuyButton.instance()
				_But.cur_Dev = cur_DevName
				_But.name = str(i + 1)
				ButList.add_child(_But)
				_But.call_init()
				if i == 0:
					CurButGroup = _ButGroup
					_But.set_pressed(true)
				_But.set_button_group(CurButGroup)
	cur_used = true
func call_butlist_del():
	var _Array = ButList.get_children()
	if _Array.size():
		for i in _Array.size():
			var _Obj = _Array[i]
			_Obj.queue_free()

func _Apply_Logic():
	var _But = _ButGroup.get_pressed_button()
	_But.call_button_up()

	var _money = int(_But.MoneyLabel.text)
	if GameLogic.cur_money > _money:
		_But.cur_Pressed = false

		GameLogic.call_MoneyChange( - 1 * _money, GameLogic.HomeMoneyKey)
		GameLogic.cur_StoreValue += _money
		_But._Slider.value += 1
		GameLogic.cur_Update.append(_But.ObjName)
		for i in GameLogic.cur_Level_Update.size():
			var _Obj = GameLogic.cur_Level_Update[i]
			if _Obj.name == _But.ObjName:

				_Obj.call_guide_hide()
				var _NewObj = _Obj.duplicate()
				ComputerUI = GameLogic.GameUI.ComputerUI
				ComputerUI.LevelNode.Ysort_Dev.add_child(_NewObj)

				var _Data = GameLogic.Save.return_savedata(_Obj)
				GameLogic.Save.levelData["Devices"].insert(GameLogic.Save.levelData["Devices"].size(), _Data)
				break


		GameLogic.call_save()

func call_control(_but, _value):
	if cur_used:
		match _but:
			"A":
				var _But = _ButGroup.get_pressed_button()
				if not _But._HoldBut.is_connected("HoldFinish", self, "_Apply_Logic"):
					_But._HoldBut.connect("HoldFinish", self, "_Apply_Logic")
				if _But.visible:
					if _value == 1 or _value == - 1:
						_But.call_button_down()
					else:
						_But.call_button_up()
				else:
					_But.call_button_up()
					if _But._HoldBut.is_connected("HoldFinish", self, "_Apply_Logic"):
						_But._HoldBut.disconnect("HoldFinish", self, "_Apply_Logic")
			"U":
				if _value == 1 or _value == - 1:
					var _Select = _ButGroup.get_pressed_button()
					var _selectName = _Select.name
					if int(_selectName) > 0:
						var _PressedButID = str(int(_selectName) - 1)
						var _ButList = _ButGroup.get_buttons()
						for i in _ButList.size():
							var _But = _ButList[i]
							if _But.name == _PressedButID:
								_But.set_pressed(true)
			"D":
				if _value == 1 or _value == - 1:
					var _Select = _ButGroup.get_pressed_button()
					var _selectName = _Select.name
					var _ButList = _ButGroup.get_buttons()
					if int(_selectName) < _ButList.size():
						var _PressedButID = str(int(_selectName) + 1)
						for i in _ButList.size():
							var _But = _ButList[i]
							if _But.name == _PressedButID:
								_But.set_pressed(true)
