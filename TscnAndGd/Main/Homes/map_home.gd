extends Node2D

onready var P1_pos = get_node("PlayerPos2D/1").position
onready var P2_pos = get_node("PlayerPos2D/2").position

onready var Ysort_Players = get_node("YSort/Players")
onready var Ysort_Outdoor = get_node("YSort/Outdoor")
onready var Camera_Limit_Left = get_node("CameraPos2D/LeftTop").position.x
onready var Camera_Limit_Top = get_node("CameraPos2D/LeftTop").position.y
onready var Camera_Limit_Right = get_node("CameraPos2D/RightBottom").position.x
onready var Camera_Limit_Bottom = get_node("CameraPos2D/RightBottom").position.y
onready var CameraMain = get_node("CameraNode")
onready var CameraNode = get_node("CameraNode/Camera2D")

var HomeIn_Bool: bool = true

var Master_LoadSuccess: bool = false

var Emit_PlayerTSCN_SYNC_Bool: bool = false

func _SteamLogic():
	SteamLogic.get_node("Join").call_end()
	if not SteamLogic.IsMultiplay:
		var _Num = str(GameLogic.Save.gameData["HomeUpdate"])
		if editor_description != _Num:
			GameLogic.call_HomeLoad()
			GameLogic.Can_ESC = true
			GameLogic.GameUI.call_esc(0)
	else:
		GameLogic.Player2_bool = false
		SteamLogic.call_Latency()

func _ready() -> void :

	if not GameLogic.LoadingUI.IsHome:
		return
	if get_tree().is_paused():
		get_tree().set_pause(false)
		GameLogic.Can_ESC = true

	else:
		GameLogic.Can_ESC = true

	GameLogic.GameUI.MainMenu.call_ESC_hide()
	_SteamLogic()
	_Logic_Init()

	HomeIn_Bool = true
	call_deferred("MissionComplete_Check")
	if not GameLogic.is_connected("SYNC", self, "MissionComplete_Check"):
		var _Con = GameLogic.connect("SYNC", self, "MissionComplete_Check")
	if not SteamLogic.is_connected("CreateNetPlayer", self, "call_NetWork_PlayerCreate"):
		var _Con = SteamLogic.connect("CreateNetPlayer", self, "call_NetWork_PlayerCreate")

	if not SteamLogic.is_connected("PlayerSYNC", self, "_PlayerSYNC"):
		var _SteamCon = SteamLogic.connect("PlayerSYNC", self, "_PlayerSYNC")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return


	if not _ISCG:
		if not SteamLogic.IsMultiplay:
			if GameLogic.Level_Data.size() == 0 and GameLogic.cur_level == "":

				if has_node("CanvasLayer/AnimationPlayer"):
					$CanvasLayer / AnimationPlayer.play("Tutorial")
	if not _ISCG:
		SteamLogic.call_create_Lobby()
	yield(get_tree().create_timer(10), "timeout")
	GameLogic.Achievement.call_SteamAchievement()

func _PlayerSYNC(_Type: String, _SteamID: int, _Data: Array):
	for _playerNode in Ysort_Players.get_children():
		if _playerNode.cur_Player == _SteamID:
			_playerNode.Con.call_PlayerSYNC(_Type, _Data)
			break

func MissionComplete_Check():





	if SteamLogic.IsJoin:

		if SteamLogic.LevelDic.IsFinish:
			GameLogic.call_gameover(true)
		else:
			GameLogic.call_gameover(false)
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	elif GameLogic.GameOverType:

		GameLogic.call_gameover(false)
		if get_tree().is_paused():
			get_tree().set_pause(false)
			GameLogic.GameUI.call_esc(0)
	elif GameLogic.MissionComplete_bool:



		GameLogic.call_gameover(true)
		if get_tree().is_paused():
			get_tree().set_pause(false)
			GameLogic.GameUI.call_esc(0)
	elif not GameLogic.Save.gameData.has("VERSION"):
		GameLogic.Save.gameData["VERSION"] = GameLogic.Save.VERSION

		GameLogic.Save.call_exit_level()

		GameLogic.call_gameover(false)
		if get_tree().is_paused():
			get_tree().set_pause(false)
			GameLogic.GameUI.call_esc(0)
	elif GameLogic.Save.gameData["VERSION"] != GameLogic.Save.VERSION and not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:

		GameLogic.Save.gameData["VERSION"] = GameLogic.Save.VERSION
		GameLogic.Save.call_exit_level()
		GameLogic.call_gameover(false)
		if get_tree().is_paused():
			get_tree().set_pause(false)
			GameLogic.GameUI.call_esc(0)
	elif GameLogic.Save.levelData.has("cur_Devil") and HomeIn_Bool and not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:

		if GameLogic.Save.levelData.cur_Devil > 1:
			GameLogic.Save.call_exit_level()
			GameLogic.call_gameover(false)
			if get_tree().is_paused():
				get_tree().set_pause(false)
				GameLogic.GameUI.call_esc(0)
	elif get_tree().is_paused():
		get_tree().set_pause(false)
		GameLogic.GameUI.call_esc(0)

	HomeIn_Bool = false

func _OpenCG_End():
	get_node("YSort").show()
	get_node("MapNode").show()
	_PlayerCreate()
	GameLogic.GameUI.call_InHome()
	GameLogic.ShowLevel_bool = true
	if has_node("MapNode/Audio"):
		GameLogic.Audio.call_TileSet(get_node("MapNode/Audio"))
	GameLogic.LoadingUI.BGM_logic()
	SteamLogic.call_create_Lobby()
	_ISCG = false
	if not _ISCG:
		if not SteamLogic.IsMultiplay:
			if GameLogic.Level_Data.size() == 0 and GameLogic.cur_level == "":

				if has_node("CanvasLayer/AnimationPlayer"):
					$CanvasLayer / AnimationPlayer.play("Tutorial")
	GameLogic.GameUI.call_DEMOINFO()
var _ISCG: bool
func _Logic_Init():
	call_camera_init()
	_ISCG = false
	if not GameLogic.Save.gameData.has("Tutorial"):
		GameLogic.Save.gameData["Tutorial"] = 0

	if GameLogic.Save.gameData["Tutorial"] == 0:
		if GameLogic.Level_Data.size() > 0:
			GameLogic.Save.gameData["Tutorial"] = 1
	if not GameLogic.Tutorial.Skip_OPENCG and not SteamLogic.IsMultiplay:
		if GameLogic.Save.gameData["Tutorial"] == 0:
			if has_node("StoryNode"):

				var _OpenCG_TSCN = load("res://TscnAndGd/UI/Main/OpenCG.tscn")
				var _OpenCG = _OpenCG_TSCN.instance()
				get_node("StoryNode").add_child(_OpenCG)
				get_node("YSort").hide()
				get_node("MapNode").hide()

				_OpenCG.call_play()
				_ISCG = true
				GameLogic.Save.gameData["Tutorial"] = 1
				return
	var SaveTime = OS.get_ticks_usec()

	_PlayerCreate()


	GameLogic.GameUI.call_InHome()
	GameLogic.ShowLevel_bool = true
	if has_node("MapNode/Audio"):
		GameLogic.Audio.call_TileSet(get_node("MapNode/Audio"))
	GameLogic.LoadingUI.BGM_logic()
	GameLogic.call_start_check()
	SaveTime = OS.get_ticks_usec() - SaveTime



	if SteamLogic.IsMultiplay:
		if SteamLogic.LOBBY_IsMaster:


			GameLogic.AwaitMasterLoad = false
			GameLogic.call_Master_LoadSuccess()
			pass
		else:

			if not GameLogic.AwaitMasterLoad:
				call_PlayerTSCN_SYNC();
			elif Master_LoadSuccess:
				GameLogic.AwaitMasterLoad = false
				call_PlayerTSCN_SYNC();
	else:
		GameLogic.AwaitMasterLoad = false

func on_Master_LoadSuccess():
	Master_LoadSuccess = true

	call_PlayerTSCN_SYNC();
	pass

func call_PlayerTSCN_SYNC():
	if Emit_PlayerTSCN_SYNC_Bool:
		return
	Emit_PlayerTSCN_SYNC_Bool = true
	var _AVATARID = GameLogic.JoinPlayer
	var _TSCNName = GameLogic.Config.PlayerConfig[str(_AVATARID)].TSCN
	var _PlayerNODE = get_node("YSort/Players").get_node(str(SteamLogic.STEAM_ID))
	var _PlayerPos = _PlayerNODE.global_position
	var _cur_face = _PlayerNODE.cur_face
	var _SkillArray = _PlayerNODE.Stat.Skills

	var _FashionDic: Dictionary = GameLogic.Save.gameData["EquipDic"][1][_AVATARID]
	SteamLogic.call_master_sync("PlayerTSCN_SYNC", [_TSCNName, _AVATARID, SteamLogic.STEAM_ID, _PlayerPos, _cur_face, _SkillArray, _FashionDic])

func call_camera_init():
	CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
	CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
	CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
	CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)
	CameraNode.smoothing_enabled = false
	if is_instance_valid(GameLogic.player_1P):
		CameraNode.position = GameLogic.player_1P.CameraNode.global_position
	CameraNode.current = true
	CameraNode.smoothing_enabled = true

func _process(_delta: float) -> void :


	if GameLogic.Player2_bool:
		if is_instance_valid(GameLogic.player_1P) and is_instance_valid(GameLogic.player_2P):
			if not CameraNode.current:
				CameraNode.current = true
			CameraMain.position = ((GameLogic.player_2P.global_position + Vector2(0, - 60)) + (GameLogic.player_1P.global_position + Vector2(0, - 60))) / 2

			var _space_x: float = abs(GameLogic.player_1P.global_position.x - GameLogic.player_2P.global_position.x)
			var _space_y: float = abs(GameLogic.player_1P.global_position.y - GameLogic.player_2P.global_position.y)
			if _space_x > 1600 or _space_y > 900:
				var _zoom_x: float = 0.0
				var _zoom_y: float = 0.0
				var _zoom: float = 0.0
				_zoom_x = _space_x / 1600
				_zoom_y = _space_y / 900
				if _zoom_x > _zoom_y:
					_zoom = _zoom_x
				else:
					_zoom = _zoom_y
				CameraNode.zoom = Vector2(_zoom, _zoom)
				if CameraNode.zoom > Vector2(1.3, 1.3):
					CameraNode.zoom = Vector2(1.3, 1.3)
			else:
				CameraNode.zoom = Vector2.ONE


	else:

		if is_instance_valid(GameLogic.player_1P):
			if not CameraNode.current:
				CameraNode.current = true
			CameraMain.position = (GameLogic.player_1P.global_position + Vector2(0, - 60))


			CameraNode.zoom = Vector2.ONE
func _PlayerCreate():
	print("家里创建角色:", GameLogic.player_1P_ID, " ", SteamLogic.LevelDic.Character)

	var _Player1P = GameLogic.TSCNLoad.return_player(1).instance()
	var _ID: int = GameLogic.player_1P_ID
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:


		_ID = GameLogic.JoinPlayer

		print(" PlayerCreate JoinPlayer: ", GameLogic.JoinPlayer)
	else:
		SteamLogic.LevelDic.Character = _ID

	print("家里创建角色2", _ID, " LevelDic.Character:", SteamLogic.LevelDic.Character)
	var _TSCNName = GameLogic.Config.PlayerConfig[str(_ID)].TSCN
	_Player1P.cur_ID = int(_ID)
	var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = "Avatar"

	_Player1P.position = P1_pos
	if SteamLogic.IsMultiplay:
		if SteamLogic.SLOT_2 == SteamLogic.STEAM_ID:
			_Player1P.position = get_node("PlayerPos2D/2").position
		elif SteamLogic.SLOT_3 == SteamLogic.STEAM_ID:
			_Player1P.position = get_node("PlayerPos2D/3").position
		elif SteamLogic.SLOT_4 == SteamLogic.STEAM_ID:
			_Player1P.position = get_node("PlayerPos2D/4").position

	if SteamLogic.STEAM_ID:
		_Player1P.cur_Player = SteamLogic.STEAM_ID
	else:
		_Player1P.cur_Player = 1
	_Player1P.name = str(SteamLogic.STEAM_ID)
	Ysort_Players.add_child(_Player1P)

	_Player1P.CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
	_Player1P.CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
	_Player1P.CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
	_Player1P.CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)
	CameraNode.reset_smoothing()



	_Player1P.AvatarNode.add_child(_Avatar)
	_Player1P.call_init()
	_Avatar.hide()

	for _id in [0, 1, 2, 3, 4, 5, 6, 7]:
		if GameLogic.Config.PlayerConfig.has(str(_id)):
			var _TSCN = GameLogic.Config.PlayerConfig[str(_id)].TSCN
			var _AllAvatar = GameLogic.TSCNLoad.return_character(_TSCN).instance()
			_Player1P.AvatarNode.add_child(_AllAvatar)
			_AllAvatar.name = str(_id)
			if int(_Player1P.cur_ID) != int(_id):
				_AllAvatar.hide()


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		GameLogic.player_1P = _Player1P
		_Player1P._MultName_Logic()
		return

	var _Player2P = GameLogic.TSCNLoad.return_player(2).instance()

	var _P2ID = GameLogic.player_2P_ID
	var _P2TSCNName = GameLogic.Config.PlayerConfig[str(_P2ID)].TSCN
	_Player2P.cur_ID = int(_P2ID)
	var _P2Avatar = GameLogic.TSCNLoad.return_character(_P2TSCNName).instance()
	_P2Avatar.name = "Avatar"
	_Player2P.position = P2_pos
	_Player2P.cur_Player = 2
	_Player2P.name = str(_Player2P.cur_Player)
	Ysort_Players.add_child(_Player2P)
	_Player2P.AvatarNode.add_child(_P2Avatar)
	_Player2P.call_init()
	_P2Avatar.hide()


	for _id in [0, 1, 2, 3, 4, 5, 6, 7]:

		if GameLogic.Config.PlayerConfig.has(str(_id)):
			var _TSCN = GameLogic.Config.PlayerConfig[str(_id)].TSCN
			var _AllAvatar = GameLogic.TSCNLoad.return_character(_TSCN).instance()
			_Player2P.AvatarNode.add_child(_AllAvatar)




			_AllAvatar.name = str(_id)
			if int(_Player2P.cur_ID) != int(_id):
				_AllAvatar.hide()

	if not GameLogic.Player2_bool or SteamLogic.IsMultiplay:
		_Player2P.hide()
		_Player2P.Collision.disabled = true
	GameLogic.player_1P = _Player1P
	GameLogic.player_2P = _Player2P


func call_NetWork_PlayerCreate(_DataArray: Array):

	var _TSCN = _DataArray[0]
	var _cur_ID = _DataArray[1]
	var _cur_Player_ID = _DataArray[2]
	var _Pos = _DataArray[3]
	var _SKILLLIST = _DataArray[5]
	var _AVATARDIC = _DataArray[6]
	if Ysort_Players.has_node(str(_cur_Player_ID)):

		return

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
	Ysort_Players.add_child(_NetPlayer)

	_NetPlayer.CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
	_NetPlayer.CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
	_NetPlayer.CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
	_NetPlayer.CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)
	CameraNode.reset_smoothing()


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

	_NetPlayer.call_change_avatar(_NetPlayer.cur_ID, _AVATARDIC)
	if SteamLogic.LOBBY_IsMaster:

		GameLogic.Achievement.call_SetAchievement("MULTIPLAY_1")
	else:
		GameLogic.Achievement.call_SetAchievement("JOIN_1")
