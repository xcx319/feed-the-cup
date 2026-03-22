extends Node2D

var _BOOL: bool
var P1_bool: bool
var P2_bool: bool
onready var ABUT = $Info / Label / A

var _x: float
onready var ANI = $Info / Label / Ani

func _process(_delta):
	_x += _delta
	if _x >= 1:
		_x = 0
		if GameLogic.cur_level:
			ANI.play("NoIn")
		else:
			ANI.play("play")

func _AutoShelf_Logic():
	var _ANI = $Info / Label / Sprite / Ani
	match _BOOL:
		true:
			_ANI.play("on")
		false:
			_ANI.play("off")
func _ready():
	if not GameLogic.Save.gameData.has("SubStation_AutoShelf"):
		GameLogic.Save.gameData["SubStation_AutoShelf"] = false
	else:
		_BOOL = GameLogic.Save.gameData["SubStation_AutoShelf"]
	_AutoShelf_Logic()
func call_turn():
	_BOOL = not _BOOL
	GameLogic.Save.gameData["SubStation_AutoShelf"] = _BOOL
	_AutoShelf_Logic()
	match _BOOL:
		true:
			GameLogic.Audio.But_SwitchOn.play(0)
		false:
			GameLogic.Audio.But_SwitchOff.play(0)
func _on_Area2D_body_entered(body: Node) -> void :
	if not body.has_method("_PlayerNode"):
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			if not P1_bool:
				ABUT.call_player_in(_ID)
			P1_bool = true
			GameLogic.Con.connect("P1_Control", self, "_control_logic")

		2:
			if not P2_bool:
				ABUT.call_player_in(_ID)
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

			ABUT.call_player_out(_ID)
		2:
			P2_bool = false
			if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
			ABUT.call_player_out(_ID)

func _control_logic(_but, _value, _type):
	if _value == 1 or _value == - 1:

		match _but:
			"A":
				if ANI.assigned_animation in ["play"]:
					call_turn()
