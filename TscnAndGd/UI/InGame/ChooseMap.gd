extends Control

var cur_pressed: bool
var Type: int = 0
var show_bool: bool
var cur_MAP_Select = 0

onready var AreaBut = get_node("Control/BG/Control/ButList/1")
onready var MapNode = get_node("Control/BG/Control/ButList")
onready var ChooseShop = get_parent().get_node("ChooseShop")
onready var Ani = get_node("Control/Ani")

onready var BackBut = get_node("Control/ButControl/BackBut")

func call_init():
	get_node("Control/BG/Control/ButList/1").call_init()
	get_node("Control/BG/Control/ButList/2").call_init()
	get_node("Control/BG/Control/ButList/3").call_init()
	get_node("Control/BG/Control/ButList/4").call_init()
	get_node("Control/BG/Control/ButList/5").call_init()
	get_node("Control/BG/Control/ButList/6").call_init()
	get_node("Control/BG/Control/ButList/7").call_init()
	get_node("Control/BG/Control/ButList/8").call_init()

	var _Chap1
	var _Chap2
	var _Chap3
	var _Chap4
	var _Chap5
	var _Chap6
	var _Chap7
	var _Chap8
	var _Keys = GameLogic.Config.SceneConfig.keys()
	for _Name in _Keys:
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 1 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap1 = _Name
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 2 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap2 = _Name
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 3 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap3 = _Name
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 4 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap4 = _Name
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 5 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap5 = _Name
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 6 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap6 = _Name
		if int(GameLogic.Config.SceneConfig[_Name].LevelType) == 7 and int(GameLogic.Config.SceneConfig[_Name].LevelID) == 4:
			_Chap7 = _Name
	if GameLogic.Level_Data.has(_Chap1):

		get_node("Control/BG/Control/ButList/2").LockBool = false
		get_node("Control/BG/Control/ButList/2").call_init()

	if GameLogic.Level_Data.has(_Chap2):
		get_node("Control/BG/Control/ButList/3").LockBool = false

		get_node("Control/BG/Control/ButList/3").call_init()

	if GameLogic.Level_Data.has(_Chap3):
		get_node("Control/BG/Control/ButList/4").LockBool = false
		get_node("Control/BG/Control/ButList/4").call_init()


	if GameLogic.Level_Data.has(_Chap4):
		get_node("Control/BG/Control/ButList/5").LockBool = false
		get_node("Control/BG/Control/ButList/5").call_init()


	if GameLogic.Level_Data.has(_Chap5):
		get_node("Control/BG/Control/ButList/6").LockBool = false
		get_node("Control/BG/Control/ButList/6").call_init()

	if GameLogic.Level_Data.has(_Chap6):
		get_node("Control/BG/Control/ButList/7").LockBool = false
		get_node("Control/BG/Control/ButList/7").call_init()

	if GameLogic.Level_Data.has(_Chap7):
		get_node("Control/BG/Control/ButList/8").LockBool = false
		get_node("Control/BG/Control/ButList/8").call_init()





func _on_area_pressed() -> void :
	var _pressed = AreaBut.group.get_pressed_button()

	if not _pressed.disabled:

		Type = int(_pressed.name)
		if Ani.assigned_animation == "show":
			Ani.play("hide")
		ChooseShop.call_show(Type)
		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
		cur_pressed = false
		show_bool = false
func _on_BackBut_pressed() -> void :

	if Ani.assigned_animation == "show":
		Ani.play("close")


func call_end():
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(0)
	if is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(0)
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.Can_ESC = true
func call_show():

	call_init()
	Ani.play("show")
	show_bool = false
	GameLogic.Can_ESC = false
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")





func call_GrabFocus():
	show_bool = true
	AreaBut.set_pressed(true)
	AreaBut._on_toggled(true)

func _ChooseMap_ButPress():
	_on_area_pressed()
func _control_logic(_but, _value, _type):

	if _value < 1 and _value > - 1:
		cur_pressed = false

	if cur_pressed:
		return
	match _but:
		"B", "START":
			if not cur_pressed and _value == 1 and show_bool:
				cur_pressed = true
				_on_BackBut_pressed()
				GameLogic.Audio.But_Back.play(0)
		"A":

			if not cur_pressed and _value == 1 and show_bool:
				cur_pressed = true
				_on_area_pressed()
				GameLogic.Audio.But_Apply.play(0)
		"U", "u":
			if (_value == 1 or _value == - 1):
				cur_pressed = true

				_Input_parse("ui_up")
		"D", "d":
			if (_value == 1 or _value == - 1):
				cur_pressed = true

				_Input_parse("ui_down")
		"L", "l":
			if (_value == 1 or _value == - 1):
				cur_pressed = true

				_Input_parse("ui_left")
		"R", "r":
			if (_value == 1 or _value == - 1):
				cur_pressed = true

				_Input_parse("ui_right")
func _Input_parse(_Action: String):
	var _input = InputEventAction.new()
	_input.action = _Action
	_input.pressed = true
	Input.parse_input_event(_input)
