extends StaticBody2D

export var NAME: String
onready var Ani = get_node("TexNode/Sprite/Ani")
var ShowBool: bool

onready var RecycleUI = $RecycleUI
onready var ButShow = $Button / A
var cur_Used: bool
var cur_PlayerID: int = 1
var cur_pressed: bool

func _ready() -> void :

	call_deferred("call_init")

func call_init():
	if GameLogic.Save.gameData.has("HomeDevList"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LOBBY_gameData.has("HomeDevList"):
				if SteamLogic.LOBBY_gameData.HomeDevList.has(NAME):
					Ani.play("show_init")
					ShowBool = true
		elif GameLogic.Save.gameData.HomeDevList.has(NAME):
			Ani.play("show_init")
			ShowBool = true
	var _con = GameLogic.connect("SYNC", self, "call_show")
func call_show():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not ShowBool:

		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has(NAME):
				Ani.play("show")
				ShowBool = true
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_show_puppet")

func call_show_puppet():
	Ani.play("show")
	ShowBool = true

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)











		0, "A":
			if _value == 0:
				return


			SteamLogic.LoadInventory()

			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return
			if not cur_Used:

				match _Player.cur_Player:
					1, SteamLogic.STEAM_ID:
						if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
							GameLogic.Con.connect("P1_Control", self, "_control_logic")

						cur_PlayerID = 1
						RecycleUI.get_node("ButPlayer").play("1")


					2:
						if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
							GameLogic.Con.connect("P2_Control", self, "_control_logic")

						cur_PlayerID = 2
						RecycleUI.get_node("ButPlayer").play("2")

				GameLogic.player_1P.call_control(1)
				if GameLogic.Player2_bool:
					GameLogic.player_2P.call_control(1)
				cur_Used = true
				GameLogic.Audio.But_SwitchOn.play(0)
				RecycleUI._AVATARID = _Player.cur_ID
				RecycleUI.call_show()
				return true
func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:
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
			"X":
				if cur_pressed == false:
					cur_pressed = true
					RecycleUI._on_TYPEButton_pressed()
					RecycleUI.TYPEBUT._button_down()
					RecycleUI.TYPEBUT.call_pressed()

			"Y":
				if cur_pressed == false:
					cur_pressed = true
					RecycleUI._on_FashionButton_pressed()
					RecycleUI.FASHIONBUT._button_down()
					RecycleUI.FASHIONBUT.call_pressed()

			"A":
				if cur_pressed == false:
					cur_pressed = true
					call_apply()
			"B", "START":
				if _value != 0:
					call_close()

	if _type == 0 or _value == 0:
		cur_pressed = false
func call_apply():
	var _FOCUSBUT = RecycleUI.return_Focus_But()
	if is_instance_valid(_FOCUSBUT):
		if _FOCUSBUT.has_method("_on_Button_pressed"):
			if not _FOCUSBUT.disabled:
				_FOCUSBUT._on_Button_pressed()
func call_close():
	GameLogic.Audio.But_SwitchOff.play()
	RecycleUI.call_hide()
	GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool:
		GameLogic.player_2P.call_control(0)
	cur_Used = false
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")

	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

func _on_1_pressed():
	var item_definitions = PoolIntArray([1310010])
	var quantities = PoolIntArray([1])
	var _x = Steam.generateItems(item_definitions, quantities)
	if _x:

		Steam.destroyResult(_x)
	print(" Add Item:", _x)
	Steam.loadItemDefinitions()

func _on_3_pressed():

	var _INFO = SteamLogic._EQUIPDIC
	pass

func _on_Area2D_body_entered(_body):

	$AniNode / Ani.play("show")

func _on_Area2D_body_exited(_body):
	$AniNode / Ani.play("hide")
