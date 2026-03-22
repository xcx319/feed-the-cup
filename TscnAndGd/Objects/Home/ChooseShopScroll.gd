extends Node2D

var P1_bool: bool
var P2_bool: bool
onready var Ani = get_node("Ani")
onready var GuideAni = get_node("GuideAni")
onready var ButShow = get_node("Button/A")
onready var UINode = get_node("CanvasLayer")
onready var MapUI = $CanvasLayer / Map
var Audio_Pop
func _ready() -> void :
	call_deferred("call_init")

	if not GameLogic.is_connected("CallFormula", self, "call_init"):
		var _check_2 = GameLogic.connect("CallFormula", self, "call_init")
	_UI_init()
func _UI_init():
	match GameLogic.GlobalData.LoadingType:
		1:
			_CardUI_Load()
func _CardUI_Load():

	if UINode.has_node("ChooseShop"):
		if not UINode.get_node("ChooseShop").is_connected("LevelSelect", self, "call_init"):
			var _check_1 = UINode.get_node("ChooseShop").connect("LevelSelect", self, "call_init")
func _control_logic(_but, _value, _type):

	if _value == 1 or _value == - 1:

		match _but:
			"A":
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if is_instance_valid(GameLogic.player_1P):
					if not GameLogic.player_1P.Con.CanControl or GameLogic.player_1P.Con.IsPause:
						return
					if is_instance_valid(GameLogic.player_2P):
						if not GameLogic.player_2P.Con.CanControl or GameLogic.player_1P.Con.IsPause:
							return
					match GameLogic.GlobalData.LoadingType:
						0:
							_CardUI_Load()
					GameLogic.GameUI.Tutorial_Devil.call_Switch(false)
					MapUI.call_show()
					Audio_Pop.play(0)

					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						pass
					else:
						GameLogic.player_1P.call_control(4)
						if is_instance_valid(GameLogic.player_2P):
							GameLogic.player_2P.call_control(4)
func call_puppet_logic(_Switch: bool):
	match _Switch:
		true:
			Ani.play("show")
		false:
			if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
			Ani.play("init")
func call_init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		Ani.play("init")
		return

	if not GameLogic.cur_level:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_logic", [true])
		Ani.play("show")
	else:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_logic", [false])
		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
		Ani.play("init")
	Audio_Pop = GameLogic.Audio.return_Effect("气泡")

func _on_Area2D_body_entered(body: Node) -> void :
	if not body.has_method("_PlayerNode"):
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			if not P1_bool:
				ButShow.call_player_in(_ID)
			P1_bool = true
			GameLogic.Con.connect("P1_Control", self, "_control_logic")

		2:
			if not P2_bool:
				ButShow.call_player_in(_ID)
			P2_bool = true
			GameLogic.Con.connect("P2_Control", self, "_control_logic")

func _on_Area2D_body_exited(body: Node) -> void :
	if not body.has_method("_PlayerNode"):
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			P1_bool = false
			if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P1_Control", self, "_control_logic")

			ButShow.call_player_out(_ID)
		2:
			P2_bool = false
			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
			ButShow.call_player_out(_ID)
