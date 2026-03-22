extends Control

onready var Info = get_node("BG/InfoBG/Control/Info")
onready var TutorialBut = get_node("BG/ListBG/Scroll/VBox/说明1")
onready var TutorialButVBox = get_node("BG/ListBG/Scroll/VBox")
onready var MainUI = get_parent()
var _LastName: String

func _ready() -> void :
	call_deferred("call_init")
func call_init():
	var _ButList = TutorialButVBox.get_children()
	for i in _ButList.size():
		var _But = _ButList[i]

		_But.text = GameLogic.CardTrans.get_message(_But.text)
		if i == 0:
			_But.set_focus_neighbour(MARGIN_TOP, _But.get_path())
		else:
			_But.set_focus_neighbour(MARGIN_TOP, _ButList[i - 1].get_path())
		_But.set_focus_neighbour(MARGIN_LEFT, _But.get_path())
		_But.set_focus_neighbour(MARGIN_RIGHT, _But.get_path())
		if i < _ButList.size() - 1:
			_But.set_focus_neighbour(MARGIN_BOTTOM, _ButList[i + 1].get_path())
		else:
			_But.set_focus_neighbour(MARGIN_BOTTOM, _But.get_path())

func _on_toggled(button_pressed: bool) -> void :
	if button_pressed:

		var _Pressed = TutorialBut.group.get_pressed_button()
		var _Name = _Pressed.name
		if _LastName != _Name:
			_LastName = _Name
			Info.call_show(_Name)

func _on_focus_entered() -> void :
	var _ButList = TutorialButVBox.get_children()
	for _But in _ButList:
		if _But.is_hovered():
			_But.grab_focus()
			_But.set_pressed(true)
			break
		if _But.has_focus():
			_But.set_pressed(true)
			break
	_on_toggled(true)

func call_info_init():
	Info.call_show("init")

func grab_focus():
	var _ButList = TutorialButVBox.get_children()
	for i in _ButList.size():
		var _But = _ButList[i]

		_But.text = GameLogic.CardTrans.get_message("BUT_" + _But.name)
	TutorialBut.grab_focus()
	var _Pressed = TutorialBut.group.get_pressed_button()
	var _Name = _Pressed.name
	Info.call_show(_Name)

func _on_ApplyBut_pressed() -> void :
	var _ButList = TutorialButVBox.get_children()
	for _But in _ButList:
		if _But.has_focus():
			_But.set_pressed(true)
	_on_toggled(true)

func _on_BackBut_pressed() -> void :
	if MainUI.name == "MainMenu":

		GameLogic.GameUI.EscAni.play("TutorialOff")
		MainUI.cur_UI = MainUI.UI.MAIN
		GameLogic.GameUI.call_OptionsBut_grabfocus()
		call_info_init()
