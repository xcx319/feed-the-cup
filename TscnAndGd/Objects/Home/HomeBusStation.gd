extends Head_Object

var Can_Start: bool
var cur_Uesd: bool = false
var _playerNode
var cur_ID: int = 0
var bodyCount: int = 0
var _player1_stat: int = - 1
var _player2_stat: int = - 1
var _CurNum: int = 0
onready var WaitAni = get_node("AniNode/WaitingAni")
onready var CarAni = get_node("AniNode/CarAni")
onready var GuideAni = get_node("AniNode/GuideAni")

func _ready() -> void :
	if not GameLogic.is_connected("CanStart", self, "_CanStart_Logic"):
		var _con = GameLogic.connect("CanStart", self, "_CanStart_Logic")

func call_CarAni_puppet(_CARANI, GUIDEANI, WAITANI):
	if CarAni.has_animation(_CARANI):
		CarAni.play(_CARANI)
	if GuideAni.has_animation(GUIDEANI):
		GuideAni.play(GUIDEANI)
	if WaitAni.has_animation(WAITANI):
		WaitAni.play(WAITANI)
func call_SYNC():
	if Can_Start:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["come", "show", ""])
	else:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["init", "init", ""])
func _CanStart_Logic():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_master_node_sync(self, "call_SYNC")
		return
	if GameLogic.GameOverType != 0 and SteamLogic.IsJoin:
		Can_Start = false
		GuideAni.play("init")
		CarAni.play("init")
		return
	if GameLogic.Can_Start and not Can_Start:
		Can_Start = true
		GuideAni.play("show")

		if CarAni.assigned_animation != "come":
			CarAni.play("come")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["come", "show", ""])
	elif not GameLogic.Can_Start:
		Can_Start = false
		GuideAni.play("init")
		CarAni.play("init")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["init", "init", ""])

func _on_player_entered(body: Node) -> void :
	if body.has_method("_PlayerNode"):
		_CurNum += 1
	if SteamLogic.IsMultiplay:
		if SteamLogic.LOBBY_MEMBERS.size() == _CurNum:
			WaitAni.play("321")
			CarAni.play("open")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["open", "", "321"])
		else:
			WaitAni.play("waiting")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["", "", "waiting"])
	else:
		if GameLogic.Player2_bool:
			if _CurNum == 2:
				WaitAni.play("321")
				CarAni.play("open")
			else:
				WaitAni.play("waiting")
		else:
			WaitAni.play("321")
			CarAni.play("open")

func _on_player_exited(body: Node) -> void :
	if body.has_method("_PlayerNode"):
		_CurNum -= 1
		WaitAni.play("reset")
		CarAni.play("close")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["close", "", "reset"])

func _level_ready():

	if not GameLogic.Can_Start:
		return
	if not GameLogic.Player2_bool:
		if _player1_stat == 0:


			WaitAni.play("321")
			CarAni.play("open")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["open", "", "321"])

		else:

			WaitAni.play("init")
			if CarAni.assigned_animation == "open":
				CarAni.play("close")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_CarAni_puppet", ["close", "", "init"])

	else:
		if _player1_stat == 0 and _player2_stat == 0:

			WaitAni.play("321")
			CarAni.play("open")

			pass
		elif _player1_stat == 0 and _player2_stat != 0:

			WaitAni.play("waiting")
			if CarAni.assigned_animation == "open":
				CarAni.play("close")

			pass
		elif _player1_stat != 0 and _player2_stat == 0:

			WaitAni.play("waiting")
			if CarAni.assigned_animation == "open":
				CarAni.play("close")

		else:
			WaitAni.play("init")
			if CarAni.assigned_animation == "open":
				CarAni.play("close")

func _on_Timer_timeout() -> void :

	GameLogic.SPECIALLEVEL_Int = 0
	var _LOBBY_Level = GameLogic.cur_level
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		$AniNode / Timer.start(0)
		return
	if SteamLogic.IsMultiplay and _CurNum != SteamLogic.LOBBY_MEMBERS.size():
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_PlayerNum()
		SteamLogic.call_everybody_sync("LoadingLevel", [{"cur_levelInfo": GameLogic.cur_levelInfo, "SPECIALLEVEL_Int": GameLogic.SPECIALLEVEL_Int, "LevelType": 0, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SteamLogic.SLOT, "SLOT_2": SteamLogic.SLOT_2, "SLOT_3": SteamLogic.SLOT_3, "SLOT_4": SteamLogic.SLOT_4}])
	GameLogic.call_LevelLoad(_LOBBY_Level)

func _on_Area2D_body_entered(body: Node) -> void :
	var _player = body.cur_Player
	match _player:
		1:
			pass
		2:
			pass

var _ReCheck: bool
func _on_Puppet_Timer_timeout():
	if GameLogic.LoadingUI.IsHome:
		if not _ReCheck:
			SteamLogic.call_master_sync("LevelInfo")
			_ReCheck = true
		else:
			SteamLogic.call_LeaveLobby(true, SteamLogic.LOBBY_ID)
	pass
