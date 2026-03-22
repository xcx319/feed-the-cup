extends StaticBody2D
var playerList: Array
var cur_pressed: bool
var cur_Used: bool = false
var _playerNode
onready var aniPlayer = $AniNode / Ani
onready var ButShow = $Button / A
var _USED: bool = false
var _PICKLIST: Array

onready var EGGMAN_TSCN = preload("res://TscnAndGd/Characters/EggMan.tscn")

func _Used_set(_bool: bool):
	_USED = _bool
func call_finished():
	if not SteamLogic.STEAM_ID in [76561199510302905]:
		return
	_PlayerCreate()

	_USED = false

func call_Egg():
	if not _PICKLIST.size():
		var CardKeys = GameLogic.Config.CardConfig.keys()
		for _KEY in CardKeys:
			if GameLogic.Config.CardConfig[_KEY].Rank == "EGG":
				_PICKLIST.append(_KEY)

	var _RAND = GameLogic.return_rand_Egg() % _PICKLIST.size()
	var _PICK = _PICKLIST[_RAND]

	if not GameLogic.Save.gameData.has("EggDIC"):
		GameLogic.Save.gameData["EggDIC"] = {}
	if GameLogic.Save.gameData.has("EggArray"):
		GameLogic.Save.gameData.erase("EggArray")
	if GameLogic.Save.gameData["EggDIC"].has(_PICK):
		GameLogic.Save.gameData["EggDIC"][_PICK] += 1
		if GameLogic.Save.gameData["EggDIC"][_PICK] > 99:
			GameLogic.Save.gameData["EggDIC"][_PICK] = 99
	else:
		GameLogic.Save.gameData["EggDIC"][_PICK] = 1

func call_EggMan():
	if not SteamLogic.STEAM_ID in [76561199510302905]:
		return
	var _EGGMAN = EGGMAN_TSCN.instance()
	if get_tree().get_root().has_node("Home"):
		get_tree().get_root().get_node("Home/YSort/Items").add_child(_EGGMAN)
func return_check(_Cosebool: bool = false):

	var _EggCoinNeed: int = 30
	var _MAX: int = 0
	if not GameLogic.Save.gameData.has("EggDIC"):
		GameLogic.Save.gameData["EggDIC"] = {}
	var _KEYS = GameLogic.Save.gameData["EggDIC"].keys()
	for _KEY in _KEYS:
		_MAX += GameLogic.Save.gameData["EggDIC"][_KEY]
	match _MAX:
		0:
			_EggCoinNeed = 10
		1:
			_EggCoinNeed = 20
		2:
			_EggCoinNeed = 30

	var _EggCOIN = round(GameLogic.cur_EggCoin * GameLogic.EggCoinKey)
	if _EggCoinNeed > 0 and _EggCOIN >= _EggCoinNeed:
		if _Cosebool:
			GameLogic.call_EggCoinChange(_EggCoinNeed * - 1)
		return true
	else:
		return false
var _PLAYER
func _control_logic(_but, _value, _type):

	if _value == 1 or _value == - 1:
		match _but:
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
	if _type == 0 or _value == 0:
		cur_pressed = false
func call_home_device(_butID, _value, _type, _Player):

	_PLAYER = _Player
	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)
		2, "X":
			if not SteamLogic.STEAM_ID in [76561199510302905]:
				return
			$EGGUI.call_show()
			if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.connect("P1_Control", self, "_control_logic")
			if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
				GameLogic.Con.connect("P2_Control", self, "_control_logic")
		0, "A":
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if not return_check():

				return
			if _value == 1:
				if not cur_Used:
					match _Player.cur_Player:
						1, SteamLogic.STEAM_ID:
							aniPlayer.play("hold")
			if _value == 0:
				if aniPlayer.current_animation == "hold":
					if not _USED:
						aniPlayer.play("hold", - 1, - 0.5)
				return


func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")
var _ID: int = 0
func _PlayerCreate():

	if is_instance_valid(GameLogic.player_1P):

		var _Player1P = GameLogic.TSCNLoad.return_player(1).instance()

		if _ID == 5:
			_ID += 1


		_Player1P.cur_ID = _ID
		var _TSCNName = GameLogic.Config.PlayerConfig[str(_ID)].TSCN
		var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
		_Avatar.name = "Avatar"

		if SteamLogic.STEAM_ID:
			_Player1P.cur_Player = SteamLogic.STEAM_ID
		else:
			_Player1P.cur_Player = 1
		_Player1P.name = str(_Player1P.cur_Player)

		var _POS = _PLAYER.position

		_Player1P.position = _POS
		_PLAYER.get_parent().add_child(_Player1P)





		_Player1P.AvatarNode.add_child(_Avatar)
		_Player1P.call_init()
		_ID += 1
		GameLogic.player_1P = _Player1P

		_Player1P.CameraNode.reset_smoothing()
		_Player1P.add_to_group("PLAYER")
		_Avatar.call_HeadType(str(_HEADTYPE))
		_HEADTYPE += 1
		if _HEADTYPE > 4:
			_HEADTYPE = 1
var _HEADTYPE: int = 2
