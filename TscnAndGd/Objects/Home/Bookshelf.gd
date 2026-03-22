extends Head_Object

var cur_pressed: bool

var cur_Used: bool = false
var AchievementList: Array

onready var ButShow = get_node("Button/A")
onready var AchievementUI = $AchievementUI
onready var Ani = AchievementUI.get_node("Ani")
onready var aniPlayer = $AniNode / Ani

onready var BackBut = AchievementUI.get_node("Control/ButControl/BackBut")

onready var AchievementBut = preload("res://TscnAndGd/Buttons/AchievementButton.tscn")
onready var CurButGroup
onready var AchievementGroup = preload("res://TscnAndGd/Buttons/Achievement_Group.tres")
onready var InfoButNode = get_node("AchievementUI/Control/Info/BG/Scroll/VBox")
onready var ShowAni = $TexNode / Sprite / Ani

onready var HomeBut

var IsBuy: bool
func _ready() -> void :
	match GameLogic.GlobalData.LoadingType:
		1:
			_HomeUpdateUI_Load()
	call_deferred("call_BookShelf_init")
func call_BookShelf_init():
	if GameLogic.Save.gameData.has("HomeDevList"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LOBBY_gameData.has("HomeDevList"):
				if SteamLogic.LOBBY_gameData.HomeDevList.has("书架"):
					ShowAni.play("show_init")
		elif GameLogic.Save.gameData.HomeDevList.has("书架"):
			ShowAni.play("show_init")
	var _con = GameLogic.connect("SYNC", self, "call_show")
func call_show():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if ShowAni.assigned_animation == "init":

		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has("书架"):
				ShowAni.play("show")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_show_puppet")
func call_show_puppet():
	ShowAni.play("show")

func _TypwShow_logic():

	_del_all_InfoButton()
	_add_InfoButton()

func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:
			"B", "START":
				if not AchievementUI.IsReward:
					BackBut.on_pressed()
					call_closed()

	if _type == 0 or _value == 0:
		cur_pressed = false


func _Buy_Check():
	var _But = HomeBut.group.get_pressed_button()

	IsBuy = _But.CheckBool

func call_grab_focus():

	cur_Used = true
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		0, "A":

			if not cur_Used:
				if is_instance_valid(GameLogic.player_1P):
					GameLogic.player_1P.call_control(1)
					if is_instance_valid(GameLogic.player_2P):
						GameLogic.player_2P.call_control(1)

					GameLogic.Achievement.call_Achievement_Check()
					match GameLogic.GlobalData.LoadingType:
						0:
							_HomeUpdateUI_Load()
					cur_Used = true

					GameLogic.Audio.But_SwitchOn.play(0)
					Ani.play("show")
					GameLogic.Can_ESC = false
					yield(get_tree().create_timer(0.3), "timeout")
					_Control_set()


func _Control_set():
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")



func _HomeUpdateUI_Load():
	AchievementUI.call_init()

	if not BackBut.is_connected("pressed", self, "call_closed"):
		var _con2 = BackBut.connect("pressed", self, "call_closed")

func call_closed():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

	BackBut.call_down()
	yield(get_tree().create_timer(0.1), "timeout")
	Ani.play("hide")
	yield(get_tree().create_timer(0.3), "timeout")
	GameLogic.Can_ESC = true
	cur_Used = false
	GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool:
		if is_instance_valid(GameLogic.player_2P):
			GameLogic.player_2P.call_control(0)


	GameLogic.call_SYNC()

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

	for i in _Data_Array.size():

		var _But = AchievementBut.instance()
		_But.name = str(InfoButNode.get_child_count())
		InfoButNode.add_child(_But)
		_But.connect("toggled", self, "call_HomeButton_pressed")

		if i == 0:
			CurButGroup = AchievementGroup
			HomeBut = _But
			_But.set_button_group(CurButGroup)
			_But.set_pressed(true)
			_But.grab_focus()
		else:
			_But.set_button_group(CurButGroup)
		_But.call_init(_Data_Array[i])
	_set_OrderBut_focus()

func _set_OrderBut_focus():




	var _but_Array = InfoButNode.get_children()
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

func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")
