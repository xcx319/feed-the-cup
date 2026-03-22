extends Head_Object

var cur_pressed: bool = false
var _playerNode
var cur_ID: int = 0
var Scene_bool: bool
var Brand_bool: bool
var cur_UI = UI.NONE
enum UI{
	NONE
	MENU
	SCENE
	BRAND
	}

onready var GuideAni = get_node("AniNode/GuideAni")
onready var UIAni = get_node("AniNode/UIAni")
onready var aniPlayer = $AniNode / Ani

onready var GuideNode = get_node("GuideNode")
onready var ButShow = get_node("Button/A")

onready var ShowAni = $TexNode / Sprite / Ani
onready var CardUI = $CardUI
func _ready() -> void :


	call_deferred("call_set")
func call_set():

	if GameLogic.cur_level:
		Scene_bool = true
	call_Desk_init()
func call_Desk_init():
	if GameLogic.Save.gameData.has("HomeDevList"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LOBBY_gameData.has("HomeDevList"):
				if SteamLogic.LOBBY_gameData.HomeDevList.has("电脑桌"):
					ShowAni.play("show_init")
		elif GameLogic.Save.gameData.HomeDevList.has("电脑桌"):
			ShowAni.play("show_init")
	var _con = GameLogic.connect("SYNC", self, "call_show")
func call_show():

	if ShowAni.assigned_animation == "init":

		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has("电脑桌"):
				ShowAni.play("show")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_show_puppet")

func call_show_puppet():
	ShowAni.play("show")

var cur_Used: bool
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		0, "A":

			CardUI.call_show()
			if not cur_Used:
				if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
					GameLogic.Con.connect("P1_Control", self, "_control_logic")
				if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
					GameLogic.Con.connect("P2_Control", self, "_control_logic")
				if is_instance_valid(GameLogic.player_1P):
					GameLogic.player_1P.call_control(1)
				if GameLogic.Player2_bool:
					if is_instance_valid(GameLogic.player_2P):
						GameLogic.player_2P.call_control(1)

				cur_Used = true

func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		if cur_pressed:
			return
		match _but:
			"L1":
				cur_pressed = true
				CardUI.call_L()
			"R1":
				cur_pressed = true
				CardUI.call_R()
			"l", "L":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_left"
					_input.pressed = true
					Input.parse_input_event(_input)
			"r", "R":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_right"
					_input.pressed = true
					Input.parse_input_event(_input)
			"u", "U":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					Input.parse_input_event(_input)

			"d", "D":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					Input.parse_input_event(_input)
			"B", "START":

				call_closed()
				pass
			"X":
				if cur_pressed == false:
					cur_pressed = true
					$CardUI.ApplyBut.on_pressed()
					$CardUI._on_But_pressed()

				pass
			"u", "U":

				pass
			"d", "D":

				pass
	elif _value < 1 and _value > - 1:
		cur_pressed = false
		match _but:
			"A":

				pass
	if _type == 0:

		cur_pressed = false
func call_closed():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

	$CardUI.call_hide()
	cur_Used = false
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool:
		if is_instance_valid(GameLogic.player_2P):
			GameLogic.player_2P.call_control(0)

func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")
