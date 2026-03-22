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
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_master_node_sync(self, "call_PlayerCreate")
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
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			if not P1_bool:
				ButShow.call_player_in(_ID)
			P1_bool = true
			GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
			_PLAYER = body
		2:
			if not P2_bool:
				ButShow.call_player_in(_ID)
			P2_bool = true
			GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")
			_PLAYER = body

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
var _PLAYER
var _USED: bool
var _Press: bool
var _POSSAVE: Vector2
var _SITTER
func _P1_control_logic(_but, _value, _type):
	if not ShowBool:
		return
	if is_instance_valid(_SITTER):

		if _SITTER.cur_Player != GameLogic.player_1P.cur_Player:
			return
	if _value == 1 or _value == - 1:

		match _but:
			"A":
				if not _Press:
					_Press = true
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						var _PATH = _PLAYER.get_path()
						SteamLogic.call_master_node_sync(self, "call_Sit_Master", [_PATH, _USED])
						return
					call_Sit_Logic(_PLAYER, _USED)
		_Press = false
		return
func _P2_control_logic(_but, _value, _type):
	if not ShowBool:
		return
	if is_instance_valid(_SITTER):

		if _SITTER.cur_Player != GameLogic.player_2P.cur_Player:
			return
	if _value == 1 or _value == - 1:

		match _but:
			"A":
				if not _Press:
					_Press = true
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						var _PATH = _PLAYER.get_path()
						SteamLogic.call_master_node_sync(self, "call_Sit_Master", [_PATH, _USED])
						return
					call_Sit_Logic(_PLAYER, _USED)
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
			if _USED:
				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PATH = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Sit_puppet", [_PATH, _SWITCH])
			_SITTER = _Player
			_USED = true
			_POSSAVE = _Player.position

			_Player.get_parent().remove_child(_Player)
			_Player.position = Vector2.ZERO
			get_node("TexNode/SitNode").add_child(_Player)

			_Player.Con.call_Sit()
			_Player.call_control(1)
			$TexNode / SwingAni.play("swing")

		true:
			_Player = _SITTER
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PATH = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Sit_puppet", [_PATH, _SWITCH])

			_Player.get_parent().remove_child(_Player)
			var _POS = self.position
			_POS.y -= 50
			_Player.position = _POS
			if get_tree().get_root().has_node("Home/YSort/Players"):
				var _YSortPlayer = get_tree().get_root().get_node("Home/YSort/Players")
				_YSortPlayer.add_child(_Player)
			_Player.call_control(0)

			_Player.Con.call_SitEnd()
			_SITTER = null
			_USED = false
			$TexNode / SwingAni.play("init")
func call_PlayerCreate():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		if is_instance_valid(_SITTER):
			var _CurID = str(_SITTER.cur_ID)
			var _TSCNName = GameLogic.Config.PlayerConfig[_CurID].TSCN
			var _CurPlayerID = _SITTER.cur_Player
			var _PlayerPos = _SITTER.global_position
			var _cur_face = _SITTER.cur_face
			var _SkillArray = _SITTER.Stat.Skills
			var _FashionDic: Dictionary = GameLogic.Save.gameData["EquipDic"][1][GameLogic.player_1P_ID]
			if _CurPlayerID == 1:
				_CurPlayerID = SteamLogic.STEAM_ID
			if _CurPlayerID != 2:

				var _DATA: Array = [_TSCNName, _CurID, _CurPlayerID, _PlayerPos, _cur_face, _SkillArray, _FashionDic]
				SteamLogic.call_puppet_node_sync(self, "call_NetWork_PlayerCreate", [_DATA])
func call_NetWork_PlayerCreate(_DataArray: Array):
	if is_instance_valid(_SITTER):
		return
	if get_tree().get_root().has_node("Home/YSort/Players"):
		var _YSortPlayer = get_tree().get_root().get_node("Home/YSort/Players")
		var _PlayerList = _YSortPlayer.get_children()
		for _PLAYERNODE in _PlayerList:
			var _ID = _PLAYERNODE.cur_Player
			if _ID == _DataArray[2]:
				return
	print("家里 创建网络其他玩家角色", _DataArray)
	var _TSCN = _DataArray[0]
	var _cur_ID = _DataArray[1]
	var _cur_Player_ID = _DataArray[2]
	var _Pos = _DataArray[3]
	var _SKILLLIST = _DataArray[5]

	var _NetPlayer = GameLogic.TSCNLoad.return_player(1).instance()
	var _TSCNName = _TSCN
	_NetPlayer.cur_ID = int(_cur_ID)
	var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = "Avatar"
	_NetPlayer.position = _Pos
	_NetPlayer.name = str(_cur_Player_ID)
	_NetPlayer.cur_Player = _cur_Player_ID
	if _DataArray.size() >= 5:
		var _cur_face = _DataArray[4]
		_NetPlayer.cur_face = _cur_face
	get_node("TexNode/SitNode").add_child(_NetPlayer)




	_NetPlayer.AvatarNode.add_child(_Avatar)
	_NetPlayer.call_init()
	_Avatar.hide()

	for _id in [0, 1, 2, 3, 4, 5, 6, 7]:

		if not GameLogic.Config.PlayerConfig.has(str(_id)):
			return
		var _AVATARTSCN = GameLogic.Config.PlayerConfig[str(_id)].TSCN
		var _AllAvatar = GameLogic.TSCNLoad.return_character(_AVATARTSCN).instance()
		_NetPlayer.AvatarNode.add_child(_AllAvatar)



		_AllAvatar.name = str(_id)
		if int(_NetPlayer.cur_ID) != int(_id):
			_AllAvatar.hide()
	_NetPlayer.Stat.Skills = _SKILLLIST
	if SteamLogic.LOBBY_IsMaster and GameLogic.LoadingUI.IsHome:
		SteamLogic.call_PLAYER_SYNC()

	_NetPlayer._MultName_Logic()

	if SteamLogic.LOBBY_IsMaster:

		GameLogic.Achievement.call_SetAchievement("MULTIPLAY_1")
	else:
		GameLogic.Achievement.call_SetAchievement("JOIN_1")
	_NetPlayer.position = Vector2.ZERO
	_NetPlayer.Con.call_SitDown()
	_NetPlayer.call_control(1)
