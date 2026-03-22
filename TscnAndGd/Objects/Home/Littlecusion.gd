extends Node2D

export var NAME: String
onready var Ani = get_node("TexNode/Sprite/Ani")
onready var ButShow = get_node("Button/A")
var ShowBool: bool

var P1_bool: bool
var P2_bool: bool
func _ready() -> void :
	self.hide()
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

func _on_Area2D_body_entered(body: Node) -> void :
	if not body.has_method("_PlayerNode"):
		return
	if not ShowBool:
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			if not P1_bool:
				ButShow.call_player_in(_ID)
			P1_bool = true
			GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
			_PLAYER_ONE = body
		2:
			if not P2_bool:
				ButShow.call_player_in(_ID)
			P2_bool = true
			GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")
			_PLAYER_TWO = body

func _on_Area2D_body_exited(body: Node) -> void :
	if not body.has_method("_PlayerNode"):
		return
	if not ShowBool:
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			P1_bool = false
			if GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
				GameLogic.Con.disconnect("P1_Control", self, "_P1_control_logic")

			ButShow.call_player_out(_ID)
		2:
			P2_bool = false
			if GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_P2_control_logic")
			ButShow.call_player_out(_ID)
var _PLAYER_ONE
var _PLAYER_TWO
var _USED: bool
var _Press: bool

var _SITTER
func _P1_control_logic(_but, _value, _type):
	if not ShowBool:
		return
	if _value == 1 or _value == - 1:

		match _but:
			"A":
				if not _Press:
					_Press = true
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						var _PATH = _PLAYER_ONE.get_path()
						SteamLogic.call_master_node_sync(self, "call_Sit_Master", [_PATH, _USED])
						return
					call_Sit_Logic(_PLAYER_ONE, _USED)
		_Press = false
		return
func _P2_control_logic(_but, _value, _type):
	if not ShowBool:
		return
	if _value == 1 or _value == - 1:

		match _but:
			"A":
				if not _Press:
					_Press = true
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						var _PATH = _PLAYER_TWO.get_path()
						SteamLogic.call_master_node_sync(self, "call_Sit_Master", [_PATH, _USED])
						return
					call_Sit_Logic(_PLAYER_TWO, _USED)
		_Press = false
		return
func call_Sit_Master(_PATH, _SWITCH):
	var _Player = get_node(_PATH)
	call_Sit_Logic(_Player, _SWITCH)
func call_Sit_puppet(_PATH, _SWITCH):
	if has_node(_PATH):
		var _Player = get_node(_PATH)
		call_Sit_Logic(_Player, _SWITCH)
func call_Sit_Logic(_Player, _SWITCH: bool):
	if _Player.Con.state in [GameLogic.NPC.STATE.CUTE, GameLogic.NPC.STATE.RUBBING]:
		return
	match _SWITCH:
		false:
			if _USED or _SITTER != null:
				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PATH = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Sit_puppet", [_PATH, _SWITCH])
			_SITTER = _Player
			_USED = true
			_Player.Con.call_Sit()
			_Player.call_control(1)
			var _POS = self.position
			_POS.y += 30
			_Player.mode = 3
			_Player.position = _POS
			yield(get_tree().create_timer(0.1), "timeout")
			_Player.mode = 0

			return true
		true:
			if _SITTER != _Player:
				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PATH = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Sit_puppet", [_PATH, _SWITCH])
			_SITTER = null
			_USED = false
			_Player.call_control(0)
			_Player.Con.call_SitEnd()
			return true
