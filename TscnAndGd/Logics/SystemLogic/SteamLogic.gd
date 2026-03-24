extends Node

var INIT_ID: int = 2336220
var STEAM_BOOL: bool = false
var TEST_FOR_PLAYER: bool = false

var STEAM_ID: int = 0
var STEAM_NAME: String
var LOBBY_MAX_MEMBERS: int = 4
var LOBBY_ID: int = 0
var LOBBY_MEMBERS: Array

var CanJoin: bool = true setget call_JoinSet

var MasterID: int
var SLOT: int
var SLOT_2: int
var SLOT_3: int
var SLOT_4: int

var LatencyStart: float
var IsMultiplay: bool
var _pending_callv_queue: Array = []  # 缓存尚未创建节点的 Callv 消息
var _pending_create_player: Array = []  # 缓存场景未加载时的 CreateNetPlayer 数据
var LOBBY_IsMaster: bool
var LOBBY_gameData = {}
var LOBBY_statisticsData = {}
var LOBBY_levelData = {}
var LOBBY_InLevel: bool
var InitBool: bool
var error_4_times: int = 0

enum LOBBY_AVAILABILITY{
	PRIVATE = 0,
	FRIENDONLY = 1,
	PUBLIC = 2,
	INVISIBLE = 3
}

var LOBBY_DATA = {

}
var OBJECT_DIC: Dictionary
func call_OBJECT_Check():
	var _KEY = OBJECT_DIC.keys()
	for _NAME in _KEY:
		if not is_instance_valid(OBJECT_DIC[_NAME]):
			var _R = OBJECT_DIC.erase(_NAME)
var IsJoin: bool = false

var PlayerNum: int
var CanStart: bool = true
var PuppetPreDic: Dictionary
var LevelDic: Dictionary = {
	cur_Day = 0,
	PlayerNum = 0,
	Coin = 0,
	Cup = 0,
	NPCNum = 0,
	Perfect = 0,
	Good = 0,
	Bad = 0,
	Day = 0,
	SkipDay = 0,
	Devil = 0,
	MoneyCost = 0,
	OpenGift = 0,
	IsFinish = false,
	Difficult = [],
	Level = "",
	EXP = 0,
	Character = 0,
	cur_levelInfo = [],
	MoneyCHECK = 0,
	Choose_Rewards = [],
	Choose_Challenge = [],
	Choose_Event = [],
	SPECIALLEVEL_Int = 0,
}

onready var JOIN = $Join

signal CreateNetPlayer(_Data)
signal DelNetPlayer(_id)
signal PlayerSYNC(_Type, _id, _Data)
signal MasterSYNC()
signal NextSYNC()
signal Latency(_STEAMID, _LatencyNum)
signal LobbyUpdate()
signal SentPlayerToMaster()

signal LeaveLobby
signal TriggerItemDrop
func call_TriggerItemDrop():
	emit_signal("TriggerItemDrop")
func _ready() -> void :
	call_init()

func LevelDic_Init():
	IsJoin = false
	LevelDic = {
	cur_Day = 0,
	Coin = 0,
	Cup = 0,
	NPCNum = 0,
	Perfect = 0,
	Good = 0,
	Bad = 0,
	SkipDay = 0,
	Day = 0,
	Devil = 0,
	MoneyCost = 0,
	OpenGift = 0,
	IsFinish = false,
	Difficult = [],
	Level = "",
	EXP = 0.0,
	Character = GameLogic.player_1P_ID,
	StartDay = 0,
	cur_levelInfo = [],
	MoneyCHECK = 0,
	cur_Rewards = [],
	cur_Challenge = {},
	Choose_Rewards = [],
	Choose_Challenge = [],
	Choose_Event = [],
	PlayerNum = 0,
	SPECIALLEVEL_Int = 0,
	SPECIAL_NUM = 0,
}

var _FASHIONDIC: Dictionary = {}
func call_InLevel():
	if not STEAM_BOOL:
		return
	if STEAM_ID != 0:
		var _return = Steam.setLobbyJoinable(LOBBY_ID, false)

func call_InHome():
	if not STEAM_BOOL:
		return
	if STEAM_ID != 0 and LOBBY_IsMaster and LOBBY_ID:
		var _return = Steam.setLobbyJoinable(LOBBY_ID, true)
	else:
		call_create_Lobby()
func call_JoinSet(_CANJOIN: bool):
	CanJoin = _CANJOIN

	if LOBBY_IsMaster:
		var _ELOBBYTYPE: int = 0
		if CanJoin:
			_ELOBBYTYPE = 1
		var _RETURN = Steam.setLobbyType(LOBBY_ID, _ELOBBYTYPE)

func call_init():
	if not STEAM_BOOL:


		set_process(false)
		return
	_initialize_Steam()
	_connect_SteamSignal("lobby_created", "_on_Lobby_Created")

	_connect_SteamSignal("lobby_joined", "_on_Lobby_Joined")
	_connect_SteamSignal("lobby_chat_update", "_on_Lobby_Chat_Update")

	_connect_SteamSignal("lobby_invite", "_on_Lobby_Invite")
	_connect_SteamSignal("join_requested", "_on_Lobby_Join_Requested")

	_connect_SteamSignal("p2p_session_request", "_on_P2P_Session_Request")
	_connect_SteamSignal("p2p_session_connect_fail", "_on_P2P_Session_Connect_Fail")
	_connect_SteamSignal("inventory_full_update", "_inventory_update")
	_connect_SteamSignal("inventory_definition_update", "_definition_update")
	_connect_SteamSignal("inventory_result_ready", "_inventory_ready")


	var _Con = Steam.connect("leaderboard_find_result", self, "_leaderboard_Find_Result")
	_Con = Steam.connect("leaderboard_score_uploaded", self, "_leaderboard_Score_Uploaded")
	_Con = Steam.connect("leaderboard_scores_downloaded", self, "_leaderboard_Scores_Downloaded")
	_Con = Steam.connect("current_stats_received", self, "_on_steam_stats_ready", [], CONNECT_ONESHOT)
	call_FindLeaderBoard()
	call_Holiday_Check()
	LoadInventory()

func _on_steam_stats_ready(_game: int, result: int, user: int) -> void :

	print("Call result: %s" % result)
	print("This user's Steam ID: %s" % user)



func _on_Lobby_Join_Requested(lobby_id: int, friendID: int) -> void :




	var _CheckData = Steam.requestLobbyData(lobby_id)
	yield(get_tree().create_timer(0.5), "timeout")
	var _OWNER_NAME: String = Steam.getFriendPersonaName(friendID)
	var _LobbyVARSON = Steam.getLobbyData(lobby_id, "VERSION")

	_join_Lobby(lobby_id)
func _connect_SteamSignal(_name, _func):
	var _con = Steam.connect(_name, self, _func)
func _on_P2P_Session_Request(_remote_id: int) -> void :
	var _REQUESTER: String = Steam.getFriendPersonaName(_remote_id)
	var _Return = Steam.acceptP2PSessionWithUser(_remote_id)

	_make_P2P_Handshake()

func _send_LobbyData(_remote_id: int) -> void :
	var _REQUESTER: String = Steam.getFriendPersonaName(_remote_id)
	var _Return = Steam.acceptP2PSessionWithUser(_remote_id)

	_send_Data_to_New(_remote_id)

func _send_Data_to_New(_remote_id):
	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	_send_P2P_Packet(_remote_id, {"from": STEAM_ID, "cur_levelInfo": GameLogic.cur_levelInfo, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SLOT, "SLOT_2": SLOT_2, "SLOT_3": SLOT_3, "SLOT_4": SLOT_4}, SEND_TYPE)

func call_send_Data():
	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	_send_P2P_Packet(0, {"from": STEAM_ID, "cur_levelInfo": GameLogic.cur_levelInfo, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData}, SEND_TYPE)

func call_send_LevelInfo():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_LevelInfo", [GameLogic.cur_levelInfo, GameLogic.SPECIALLEVEL_Int])
func call_puppet_LevelInfo(_INFO, _SP):
	GameLogic.SPECIALLEVEL_Int = _SP
	LevelDic.SPECIALLEVEL_Int = _SP
	LevelDic.cur_levelInfo = _INFO
	GameLogic.cur_levelInfo = _INFO
	LevelDic.Difficult = _INFO.Difficult

func _on_P2P_Session_Connect_Fail(steamID: int, session_error: int) -> void :
	if session_error == 0:
		error_4_times = 0
		print("WARNING: Session failure with " + str(steamID) + " [no error given].")
	elif session_error == 1:
		print("WARNING: Session failure with " + str(steamID) + " [target user not running the same game].")
		error_4_times += 1
	elif session_error == 2:
		print("WARNING: Session failure with " + str(steamID) + " [local user doesn't own app / game].")
		error_4_times += 1
	elif session_error == 3:
		print("WARNING: Session failure with " + str(steamID) + " [target user isn't connected to Steam].")
		error_4_times += 1
	elif session_error == 4:
		print("WARNING: Session failure with " + str(steamID) + " [connection timed out].")
		error_4_times += 1
	elif session_error == 5:
		print("WARNING: Session failure with " + str(steamID) + " [unused].")
		error_4_times += 1
	else:
		print("WARNING: Session failure with " + str(steamID) + " [unknown error " + str(session_error) + "].")
		error_4_times += 1
	if $Join._ISJOIN:
		$Join.call_end()
	if LOBBY_ID != 0:
		if error_4_times > 0:
			printerr(" 网络连接异常，错误：", error_4_times)
		if error_4_times >= 10 and not LOBBY_IsMaster:
			if steamID == STEAM_ID:
				call_LeaveLobby(true, LOBBY_ID)



func call_PlayerNum_puppet(_NUM):
	PlayerNum = _NUM
func call_PlayerNum():
	PlayerNum = LOBBY_MEMBERS.size()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PlayerNum_puppet", [PlayerNum])

var _STEAMINIT_ID: int = 0
var _INIT_TYPE: int = 0

func _initialize_Steam() -> void :

	if _STEAMINIT_ID == 0:
		_STEAMINIT_ID = INIT_ID
	if _STEAMINIT_ID == 2336220:
		if GameLogic.DEMO_bool:
			_STEAMINIT_ID = 2400400

		var _INIT = Steam.steamInitEx(_STEAMINIT_ID, true)
		var _IS_ONLINE: bool = Steam.loggedOn()
		STEAM_ID = Steam.getSteamID()
		var IS_OWNED: bool = Steam.isSubscribed()
		_INIT_TYPE = _INIT.status
		print("steam连接网络", _INIT, IS_OWNED)
		STEAM_NAME = Steam.getFriendPersonaName(STEAM_ID)



		if not IS_OWNED:
			GameLogic.DEMO_bool = true
			_STEAMINIT_ID = 2400400
			_initialize_Steam()
			return
	else:
		GameLogic.DEMO_bool = true
		var _INIT = Steam.steamInitEx(2400400, true)

		print("steam连接网络失败", _INIT)
		var _IS_ONLINE: bool = Steam.loggedOn()
		STEAM_ID = Steam.getSteamID()
		var _IS_OWNED: bool = Steam.isSubscribed()

		STEAM_NAME = Steam.getFriendPersonaName(STEAM_ID)
		GameLogic._SubRANDOM.seed = SteamLogic.STEAM_ID

		print("_IS_ONLINE:", _IS_ONLINE)
func _process(_delta):
	if not STEAM_BOOL:
		return
	Steam.run_callbacks()
	if LOBBY_ID > 0:

		_read_All_P2P_Packets()
func _read_All_P2P_Packets(read_count: int = 0):
	if read_count >= 16:
		return

	if Steam.getAvailableP2PPacketSize(0) > 0:
		_read_P2P_Packet(0)
		_read_All_P2P_Packets(read_count + 1)

func call_NeedData():

	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	_send_P2P_Packet(MasterID, {"message": "NeedData", "from": STEAM_ID}, SEND_TYPE)
func _make_P2P_Handshake() -> void :

	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	_send_P2P_Packet(0, {"message": "handshake", "from": STEAM_ID}, SEND_TYPE)

var _Latency_DIC: Dictionary
var _CHECK_DIC: Dictionary
func call_Latency():
	if not STEAM_BOOL:
		return
	var _VERSIONReturn = Steam.setLobbyData(LOBBY_ID, "VERSION", GameLogic.Save.VERSION)
	var SEND_TYPE: int = Steam.P2P_SEND_UNRELIABLE_NO_DELAY
	_send_P2P_Packet(0, {"message": "Latency", "from": STEAM_ID, "join": GameLogic.GameUI._LEVELCHECKINT}, SEND_TYPE)
	var _Latency: float = Time.get_ticks_usec() - LatencyStart

	LatencyStart = Time.get_ticks_usec()
	$LatencyTimer.start(0)

	if IsMultiplay and LOBBY_IsMaster:
		for MEMBER in LOBBY_MEMBERS:
			var _ID = MEMBER["steam_id"]
			if _ID != STEAM_ID:
				if not _Latency_DIC.has(_ID):
					if _CHECK_DIC.has(_ID):
						var _E = _CHECK_DIC.erase(_ID)
					_Latency_DIC[_ID] = LatencyStart
				else:
					var _TIME = (LatencyStart - _Latency_DIC[_ID]) / 1000000
					if _TIME >= 20:
						if _CHECK_DIC.has(_ID):

							call_kick_player(_ID)
						else:
							_CHECK_DIC[_ID] = true
							_Latency_DIC[_ID] = LatencyStart
						pass
					else:
						if _CHECK_DIC.has(_ID):
							var _E = _CHECK_DIC.erase(_ID)
						_Latency_DIC[_ID] = LatencyStart

		for _ID in _Latency_DIC:

			if _ID != STEAM_ID:
				if not _Latency_DIC.has(_ID):
					_Latency_DIC[_ID] = LatencyStart
				else:
					var _TIME = (LatencyStart - _Latency_DIC[_ID]) / 1000000
					if _TIME >= 10:

						call_kick_player(_ID)
						pass
		var MEMBERS: int = Steam.getNumLobbyMembers(LOBBY_ID)
		var _NUMReturn = Steam.setLobbyData(LOBBY_ID, "NUM", str(MEMBERS))

func call_kick_player(_ID):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_one_sync(_ID, "LEAVE", [SteamLogic.LOBBY_ID])

		if _Latency_DIC.has(_ID):
			var _r = _Latency_DIC.erase(_ID)
func call_return_Latency(_STEAMID):
	var _TIME = Time.get_ticks_usec()
	if _Latency_DIC.has(_STEAMID):

		var _r = _Latency_DIC.erase(_STEAMID)
	var SEND_TYPE: int = Steam.P2P_SEND_UNRELIABLE_NO_DELAY
	_send_P2P_Packet(_STEAMID, {"message": "LatencyReturn", "from": STEAM_ID, "join": GameLogic.GameUI._LEVELCHECKINT}, SEND_TYPE)

func _LOBBY_DATA_set():
	LOBBY_DATA["lobby_name"] = STEAM_NAME

	LOBBY_DATA["VERSION"] = GameLogic.Save.VERSION
func call_create_Lobby() -> void :

	if not STEAM_BOOL:
		return

	TryJoinID = 0
	_LOBBY_DATA_set()
	if LOBBY_ID == 0:
		Steam.createLobby(LOBBY_AVAILABILITY.FRIENDONLY, LOBBY_MAX_MEMBERS)
		LOBBY_IsMaster = true

func _on_Lobby_Created(connect: int, lobby_id: int) -> void :
	print("_on_Lobby_Created: ", connect, " ID:", lobby_id)
	if connect == 1:

		LOBBY_ID = lobby_id

		print("Created a lobby: " + str(LOBBY_ID))
		var _JoinReturn = Steam.setLobbyJoinable(LOBBY_ID, true)



		var _VERSIONReturn = Steam.setLobbyData(LOBBY_ID, "VERSION", GameLogic.Save.VERSION)
		var _NUMReturn = Steam.setLobbyData(LOBBY_ID, "NUM", "1")
		var _SetLevel = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Level", GameLogic.cur_level)
		var _SerDevil = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Devil", str(GameLogic.cur_Devil))
		var _SetDay = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Day", str(GameLogic.cur_Day))
		var _RELAY: bool = Steam.allowP2PPacketRelay(true)

		MasterID = STEAM_ID
		LOBBY_IsMaster = true
		var _Max = Steam.getLobbyMemberLimit(LOBBY_ID)
		var _MEMBER = Steam.getNumLobbyMembers(LOBBY_ID)

		LOBBY_MEMBERS.clear()
		var MEMBER_STEAM_NAME: String = Steam.getFriendPersonaName(STEAM_ID)
		LOBBY_MEMBERS.append({"steam_id": STEAM_ID, "steam_name": MEMBER_STEAM_NAME, "Check": false, "Init": false})
		SLOT = STEAM_ID
		SLOT_2 = 0
		SLOT_3 = 0
		SLOT_4 = 0
		$LatencyTimer.start(0)
	else:
		LOBBY_MEMBERS.clear()
		var MEMBER_STEAM_NAME: String = Steam.getFriendPersonaName(STEAM_ID)
		LOBBY_MEMBERS.append({"steam_id": STEAM_ID, "steam_name": MEMBER_STEAM_NAME, "Check": false, "Init": false})
		SLOT = STEAM_ID
		SLOT_2 = 0
		SLOT_3 = 0
		SLOT_4 = 0

	call_SetRich()
func call_invite(_id):
	if LOBBY_ID != 0:
		var _IP_List = IP.get_local_interfaces()

		var _InviteCon = Steam.inviteUserToLobby(LOBBY_ID, _id)
func _on_Lobby_Invite(_inviter: int, _lobby: int, _game: int):
	var _CheckData = Steam.requestLobbyData(_lobby)

var TryJoinID: int = 0
func return_join_Check(lobby_id):
	if GameLogic.LoadingUI.IsLevel:
		$Join.call_NoJoin()
		return
	TryJoinID = lobby_id
	var _LobbyVARSON = Steam.getLobbyData(lobby_id, "VERSION")

	if GameLogic.Save.VERSION != _LobbyVARSON:



		$Join.call_VERSION_ANI(_LobbyVARSON)
		return false
	return true

func _join_Lobby(lobby_id: int) -> void :


	if LOBBY_ID == lobby_id:
		return
	if not return_join_Check(lobby_id):
		return
	print("Attempting to join lobby " + str(lobby_id) + "...", LOBBY_ID)
	LOBBY_MEMBERS.clear()
	if LOBBY_ID != 0 and LOBBY_ID != TryJoinID:

		GameLogic.JoinPlayer = GameLogic.player_1P_ID
		call_LeaveLobby(false, LOBBY_ID)
	Steam.joinLobby(lobby_id)
	GameLogic.call_NetInfo(3, "网络-正在进入房间", 0)
	var _LobbyOwnerID = Steam.getLobbyOwner(TryJoinID)
	var _NAME: String = Steam.getFriendPersonaName(_LobbyOwnerID)
	$Join.call_show(_NAME)

func _on_Lobby_Joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void :
	if response == 1:

		LOBBY_ID = lobby_id
		IsMultiplay = true

		if MasterID != STEAM_ID:
			LOBBY_IsMaster = false

		_get_Lobby_Members()
		_make_P2P_Handshake()
		call_Latency()
	else:
		var _FAIL_REASON: String
		match response:
			2: _FAIL_REASON = "This lobby no longer exists."
			3: _FAIL_REASON = "You don't have permission to join this lobby."
			4: _FAIL_REASON = "The lobby is now full."
			5: _FAIL_REASON = "Uh... something unexpected happened!"
			6: _FAIL_REASON = "You are banned from this lobby."
			7: _FAIL_REASON = "You cannot join due to having a limited account."
			8: _FAIL_REASON = "This lobby is locked or disabled."
			9: _FAIL_REASON = "This lobby is community locked."
			10: _FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: _FAIL_REASON = "A user you have blocked is in the lobby."
		IsMultiplay = false
		LOBBY_IsMaster = false
		print("WaitMaster1:", LOBBY_ID)

		$Join.call_end()
		if LOBBY_ID != 0:

			call_LeaveLobby(false, LOBBY_ID)
		else:
			call_create_Lobby()

func return_check(_ID):
	if IsMultiplay and LOBBY_IsMaster:
		if SLOT != _ID and SLOT_2 != _ID and SLOT_3 != _ID and SLOT_4 != _ID:
			if STEAM_BOOL:
				var _RETURN = Steam.closeP2PSessionWithUser(_ID)
			return true
	return

func _get_Lobby_Members():
	if not STEAM_BOOL:
		return
	if not LOBBY_IsMaster:
		printerr(STEAM_ID, " 不执行getmember逻辑")
		return
	var MEMBERS: int = Steam.getNumLobbyMembers(LOBBY_ID)

	print("房间人数：", MEMBERS)
	for MEMBER in range(0, MEMBERS):
		var MEMBER_STEAM_ID: int = Steam.getLobbyMemberByIndex(LOBBY_ID, MEMBER)
		Steam.setPlayedWith(MEMBER_STEAM_ID)

		var _MEMBERCHECK: bool = true
		for _MEMBERINFO in LOBBY_MEMBERS:
			if MEMBER_STEAM_ID == _MEMBERINFO.steam_id:
				_MEMBERCHECK = false
				break

		if _MEMBERCHECK:

			if LOBBY_IsMaster:

				if SLOT_2 == 0 and SLOT_3 != MEMBER_STEAM_ID and SLOT_4 != MEMBER_STEAM_ID:
					SLOT_2 = MEMBER_STEAM_ID

				elif SLOT_3 == 0 and SLOT_4 != MEMBER_STEAM_ID:
					SLOT_3 = MEMBER_STEAM_ID

				elif SLOT_4 == 0:
					SLOT_4 = MEMBER_STEAM_ID

				else:
					print("主机 槽位被全部占用：", MEMBER_STEAM_ID)
			var MEMBER_STEAM_NAME: String = Steam.getFriendPersonaName(MEMBER_STEAM_ID)
			LOBBY_MEMBERS.append({"steam_id": MEMBER_STEAM_ID, "steam_name": MEMBER_STEAM_NAME, "Check": false, "Init": false})
	_Del_Wrong_Members(MEMBERS)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		call_puppet_node_sync(self, "call_puppet_LOBBY_MEMBERS", [LOBBY_MEMBERS, SLOT, SLOT_2, SLOT_3, SLOT_4])
	emit_signal("MasterSYNC")
	call_SetRich()
	if LOBBY_IsMaster:
		var _NUMReturn = Steam.setLobbyData(LOBBY_ID, "NUM", str(MEMBERS))
	print("房间人员变动：", LOBBY_MEMBERS, " 1:", SLOT, " 2:", SLOT_2, " 3:", SLOT_3, " 4:", SLOT_4)
func call_puppet_LOBBY_MEMBERS(_LOBBY_MEMBERS, _SLOT, _SLOT_2, _SLOT_3, _SLOT_4):
	LOBBY_MEMBERS = _LOBBY_MEMBERS
	SLOT = _SLOT
	SLOT_2 = _SLOT_2
	SLOT_3 = _SLOT_3
	SLOT_4 = _SLOT_4
	print("puppet房间人员变动：", LOBBY_MEMBERS, SLOT, SLOT_2, SLOT_3, SLOT_4)
	call_SetRich()
func _Del_Wrong_Members(_MEMBERS):
	var _LOBBYMEMBERLIST: Array
	for _NUM in range(0, LOBBY_MEMBERS.size()):
		var MEMBER_INLOBBY: int = Steam.getLobbyMemberByIndex(LOBBY_ID, _NUM)
		_LOBBYMEMBERLIST.append(MEMBER_INLOBBY)
	for _INFO in LOBBY_MEMBERS:
		var _ID = _INFO.steam_id
		if not _LOBBYMEMBERLIST.has(_ID):
			if SLOT_2 == _ID:
				LOBBY_MEMBERS.erase(_INFO)
				SLOT_2 = 0
			elif SLOT_3 == _ID:
				SLOT_3 = 0
				LOBBY_MEMBERS.erase(_INFO)
			elif SLOT_4 == _ID:
				SLOT_4 = 0
				LOBBY_MEMBERS.erase(_INFO)
			else:
				printerr(_ID, " 离开玩家未在槽位上 1:", SLOT, " 2:", SLOT_2, " 3:", SLOT_3, " 4:", SLOT_4)
		else:
			if SLOT_2 == _ID:
				pass
			elif SLOT_3 == _ID:
				pass
			elif SLOT_4 == _ID:
				pass
			else:
				printerr(_ID, " 房间中玩家未在槽位上 1:", SLOT, " 2:", SLOT_2, " 3:", SLOT_3, " 4:", SLOT_4)

	if LOBBY_MEMBERS.size() > 1:
		if GameLogic.Player2_bool:
			GameLogic.Player2_bool = false
			GameLogic.player_2P.hide()
			GameLogic.player_2P.Collision.disabled = true
		IsMultiplay = true
		$LatencyTimer.start(0)
		print("MEMBER 大于1：", LOBBY_MEMBERS)
		if not LOBBY_IsMaster:

			call_Latency()
	else:

		LOBBY_MEMBERS.clear()
		var MEMBER_STEAM_NAME: String = Steam.getFriendPersonaName(STEAM_ID)
		LOBBY_MEMBERS.append({"steam_id": STEAM_ID, "steam_name": MEMBER_STEAM_NAME, "Check": false, "Init": false})
		SLOT = STEAM_ID
		SLOT_2 = 0
		SLOT_3 = 0
		SLOT_4 = 0
		IsMultiplay = false
		$LatencyTimer.stop()
	PlayerNum = LOBBY_MEMBERS.size()

func _on_Lobby_Chat_Update(_lobby_id: int, _change_id: int, _making_change_id: int, _chat_state: int) -> void :
	if not STEAM_BOOL:
		return
	var CHANGER: String = Steam.getFriendPersonaName(_change_id)

	if _chat_state == 1:
		print(str(CHANGER) + " has joined the lobby.")
		GameLogic.call_NetInfo(3, "网络-有玩家正在加入", _change_id)
		call_Latency()
	elif _chat_state == 2:

		GameLogic.call_NetInfo(3, "网络-玩家离开", _change_id)
		var _RETURN = Steam.closeP2PSessionWithUser(_change_id)

		if _change_id == MasterID:

			call_LeaveLobby(true, LOBBY_ID)
		emit_signal("DelNetPlayer", _change_id)
	elif _chat_state == 8:
		print(str(CHANGER) + " has been kicked from the lobby.")
		var _RETURN = Steam.closeP2PSessionWithUser(_change_id)
		GameLogic.call_NetInfo(3, "网络-玩家离开", _change_id)
		emit_signal("DelNetPlayer", _change_id)
	elif _chat_state == 16:
		print(str(CHANGER) + " has been banned from the lobby.")
		var _RETURN = Steam.closeP2PSessionWithUser(_change_id)
		GameLogic.call_NetInfo(3, "网络-玩家离开", _change_id)
		emit_signal("DelNetPlayer", _change_id)
	else:
		print(str(CHANGER) + " did... something.")
	_get_Lobby_Members()
	emit_signal("LobbyUpdate")

func _send_P2P_Packet(target: int, packet_data: Dictionary, SEND_TYPE: int) -> void :
	# WebSocket 模式：通过 OnlineNetwork 中继，使用 var2bytes + base64 保留 Godot 类型
	if not STEAM_BOOL:
		if not OnlineNetwork.is_connected:
			return
		var _bytes = var2bytes(packet_data)
		var _b64 = Marshalls.raw_to_base64(_bytes)
		var _msg = packet_data.get("message", "")
		if _msg != "Callv" and _msg != "Set":
			print("[WS P2P] 发送: ", _msg, " target=", target)
		OnlineNetwork.send_game_event("p2p_relay", {
			"target": target,
			"b64": _b64,
		})
		return

	var CHANNEL: int = 0
	var _DATA: PoolByteArray



	var _Bytes = var2bytes(packet_data)
	_DATA.append_array(_Bytes)

	var _SEND_TYPE = SEND_TYPE
	if _DATA.size() > 1024:
		if SEND_TYPE in [Steam.P2P_SEND_UNRELIABLE, Steam.P2P_SEND_UNRELIABLE_NO_DELAY]:
			_SEND_TYPE = Steam.P2P_SEND_RELIABLE
	if target == 0:
		if LOBBY_MEMBERS.size() > 1:
			for MEMBER in LOBBY_MEMBERS:
				if MEMBER["steam_id"] != STEAM_ID:
					var _con = Steam.sendP2PPacket(MEMBER["steam_id"], _DATA, _SEND_TYPE, CHANNEL)








	else:
		var _con = Steam.sendP2PPacket(target, _DATA, SEND_TYPE, CHANNEL)

func _read_P2P_move():
	var PACKET_SIZE: int = Steam.getAvailableP2PPacketSize(1)
	if PACKET_SIZE > 0:

		var PACKET: Dictionary = Steam.readP2PPacket(PACKET_SIZE, 1)
		if PACKET.empty() or PACKET == null:
			print("WARNING: read an empty packet with non-zero size!")
		var _PACKET_SENDER: int = PACKET["steam_id_remote"]
		var PACKET_CODE: PoolByteArray = PACKET["data"]
		var READABLE: Dictionary = bytes2var(PACKET_CODE)
		if READABLE.has("message"):
			match READABLE["message"]:
				"Callv":
					var _Node = get_node(READABLE.node)
					if is_instance_valid(_Node):
						_Node.callv(READABLE.func_name, READABLE.args)

func _read_P2P_Packet(_CHANNEL) -> void :
	var PACKET_SIZE: int = Steam.getAvailableP2PPacketSize(_CHANNEL)

	if PACKET_SIZE > 0:

		var PACKET: Dictionary = Steam.readP2PPacket(PACKET_SIZE, _CHANNEL)
		if PACKET.empty() or PACKET == null:
			print("WARNING: read an empty packet with non-zero size!")
		var _PACKET_SENDER: int = PACKET["remote_steam_id"]
		var PACKET_CODE: PoolByteArray = PACKET["data"]
		var READABLE: Dictionary = bytes2var(PACKET_CODE)
		if not READABLE.has("from"):
			_read_Logic(READABLE)
		elif READABLE.from == SLOT or READABLE.from == SLOT_2 or READABLE.from == SLOT_3 or READABLE.from == SLOT_4:
			_read_Logic(READABLE)
		else:
			if READABLE.has("func_name"):
				if READABLE.func_name == "call_puppet_LOBBY_MEMBERS":
					_read_Logic(READABLE)
					return

			var _RETURN = Steam.closeP2PSessionWithUser(READABLE.from) if STEAM_BOOL else false
func _read_Logic(READABLE):
	if READABLE.has("message"):
		match READABLE["message"]:
			"SentPlayerToMaster":
				emit_signal("SentPlayerToMaster")
			"NeedData":
				if LOBBY_IsMaster:
					_send_LobbyData(READABLE.from)
			"LEAVE":

				var _LOBBYID = READABLE.args[0]
				call_LeaveLobby(true, _LOBBYID)
			"NPC":
				var _Node = get_node(READABLE.node)
				if is_instance_valid(_Node):
					_Node.callv(READABLE.func_name, READABLE.args)
			"Set":
				if has_node(READABLE.node):
					var _Node = get_node(READABLE.node)
					if is_instance_valid(_Node):
						_Node.set(READABLE.key, READABLE.value)
				else:
					_pending_callv_queue.append(READABLE.duplicate())
			"CallID":

				if not OBJECT_DIC.has(READABLE.id):


					pass
				else:
					var _OBJ = OBJECT_DIC[READABLE.id]
					if is_instance_valid(_OBJ):

						if _OBJ.has_method(READABLE.func_name):
							_OBJ.callv(READABLE.func_name, READABLE.args)

						else:
							printerr(" OBJ无func:", READABLE)
					else:
						var _re = OBJECT_DIC.erase(READABLE.id)

			"Callv":
				if not has_node(READABLE.node):
					_pending_callv_queue.append(READABLE.duplicate())
					return
				var _Node = get_node(READABLE.node)
				if is_instance_valid(_Node):
					if _Node.has_method(READABLE.func_name):
						_Node.callv(READABLE.func_name, READABLE.args)
					else:
						printerr(" 节点无func:", READABLE)
				else:
					printerr(" Callv 错误:", READABLE)
			"handshake":

				if LOBBY_IsMaster:
					_send_LobbyData(READABLE.from)
				else:
					print("HandShake:", READABLE.from)
			"LoadingLevel":
				if GameLogic.LoadingUI.IsHome:

					var _check = GameLogic.Con.is_connected("P1_Control", GameLogic.GameUI.GameEndUI, "_control_logic")
					if GameLogic.Con.is_connected("P1_Control", GameLogic.GameUI.GameEndUI, "_control_logic"):
						GameLogic.GameUI.GameEndUI._on_Button_pressed()
					var _DIC = READABLE.args[0]
					if _DIC.has("LOBBY_gameData"):

						_read_LOBBY_gamedata(_DIC)

					var _x = LOBBY_levelData
					var _TYPE: int = 0
					if _DIC.has("SPECIALLEVEL_Int"):
						GameLogic.SPECIALLEVEL_Int = _DIC.SPECIALLEVEL_Int
						LevelDic["SPECIALLEVEL_Int"] = _DIC.SPECIALLEVEL_Int
					if _DIC.has("cur_levelInfo"):
						LevelDic["cur_levelInfo"] = _DIC.cur_levelInfo
						GameLogic.cur_levelInfo = _DIC.cur_levelInfo
					if _DIC.has("LevelType"):
						_TYPE = _DIC.LevelType
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						if not LevelDic["SPECIALLEVEL_Int"]:
							GameLogic.call_LevelData_Load()
						SteamLogic.LevelDic.StartDay = GameLogic.cur_Day
						GameLogic.call_LevelLoad(LOBBY_levelData.cur_level, _TYPE)

			"Check":
				for _MEMBER in LOBBY_MEMBERS:
					if _MEMBER.steam_id == READABLE.from:
						_MEMBER.Check = true
						break
				print(" CHECK：", LOBBY_MEMBERS)
				JOIN.call_Member_Set()
				emit_signal("MasterSYNC")

			"NextSYNC":
				emit_signal("NextSYNC")
			"PlayerTSCN_SYNC":
				_create_PuppetPlayer(READABLE.args, READABLE.from)
			"PlayerMove":
				emit_signal("PlayerSYNC", "Move", READABLE.from, READABLE.args)
			"PuppetBut":

				emit_signal("PlayerSYNC", "PuppetBut", READABLE.from, READABLE.args)
			"PlayerBut":
				emit_signal("PlayerSYNC", "PlayerBut", READABLE.from, READABLE.args)
			"LatencyReturn":
				var _Latency: float = Time.get_ticks_usec() - LatencyStart
				var _LEVELCHECK = READABLE.join
				emit_signal("Latency", READABLE.from, [_Latency, _LEVELCHECK])

			"Latency":
				if not InitBool and not LOBBY_IsMaster:
					_make_P2P_Handshake()
				call_return_Latency(READABLE.from)

			"LevelInfo":
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(READABLE.from, "LoadingLevel", [{"cur_levelInfo": GameLogic.cur_levelInfo, "SPECIALLEVEL_Int": GameLogic.SPECIALLEVEL_Int, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SteamLogic.SLOT, "SLOT_2": SteamLogic.SLOT_2, "SLOT_3": SteamLogic.SLOT_3, "SLOT_4": SteamLogic.SLOT_4}])
	if not LOBBY_IsMaster and READABLE.has("LOBBY_gameData"):

		if not InitBool:
			InitBool = true
			_read_LOBBY_gamedata(READABLE)
			call_LoadGame()
		else:
			_update_gamedata(READABLE)
		return
	if READABLE.has("type"):
		if READABLE["type"] == "rpc":
			var node = get_node(READABLE["node"])
			node.callv(READABLE["func_name"], READABLE["args"])
	pass
func _update_gamedata(READABLE: Dictionary):
	if READABLE.has("LOBBY_gameData"):
		LOBBY_gameData = READABLE.LOBBY_gameData
	if READABLE.has("LOBBY_statisticsData"):
		LOBBY_statisticsData = READABLE.LOBBY_statisticsData
	if READABLE.has("LOBBY_levelData"):
		LOBBY_levelData = READABLE.LOBBY_levelData
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		GameLogic.call_LobbyData_Load()
	if READABLE.has("cur_levelInfo"):
		LevelDic.cur_levelInfo = READABLE.cur_levelInfo
		GameLogic.cur_levelInfo = READABLE.cur_levelInfo

func _read_LOBBY_gamedata(READABLE: Dictionary):
	if READABLE.has("LOBBY_gameData"):
		LOBBY_gameData = READABLE.LOBBY_gameData
	if READABLE.has("LOBBY_statisticsData"):
		LOBBY_statisticsData = READABLE.LOBBY_statisticsData
	if READABLE.has("LOBBY_levelData"):
		LOBBY_levelData = READABLE.LOBBY_levelData
		if LOBBY_levelData.has("cur_level"):
			LevelDic.Level = LOBBY_levelData.cur_level
	if READABLE.has("SLOT"):
		SLOT = READABLE.SLOT
		MasterID = SLOT
		SLOT_2 = READABLE.SLOT_2
		SLOT_3 = READABLE.SLOT_3
		SLOT_4 = READABLE.SLOT_4
	if READABLE.has("cur_levelInfo"):
		LevelDic.cur_levelInfo = READABLE.cur_levelInfo
		GameLogic.cur_levelInfo = READABLE.cur_levelInfo

func call_PlayerMove_SYNC(_args: Array):
	if not STEAM_BOOL:
		return
	var SEND_TYPE: int = Steam.P2P_SEND_UNRELIABLE_NO_DELAY
	_send_P2P_Packet(0, {"message": "PlayerMove", "from": STEAM_ID, "args": _args}, SEND_TYPE)

func call_Master_But_SYNC(_args: Array):
	if not STEAM_BOOL:
		return
	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	_send_P2P_Packet(MasterID, {"message": "PuppetBut", "from": STEAM_ID, "args": _args}, SEND_TYPE)
func call_everybody_sync(_Info: String, _args: Array = [], _SteamID = STEAM_ID):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	_send_P2P_Packet(0, {"message": _Info, "from": _SteamID, "args": _args}, SEND_TYPE)

func call_master_sync(_Info: String, _args: Array = [], _SteamID = STEAM_ID):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	_send_P2P_Packet(MasterID, {"message": _Info, "from": _SteamID, "args": _args}, SEND_TYPE)
	print(" call Master:", _Info)
func call_one_sync(_ID, _Info: String, _args: Array = [], _SteamID = STEAM_ID):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	_send_P2P_Packet(_ID, {"message": _Info, "from": STEAM_ID, "args": _args}, SEND_TYPE)

func call_everybody_node_sync(_node: Node, _func_name: String, _args: Array = []):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	if is_instance_valid(_node):
		var _NodePath = _node.get_path()
		_send_P2P_Packet(0, {"message": "Callv", "from": STEAM_ID, "node": _NodePath, "func_name": _func_name, "args": _args}, SEND_TYPE)
		_node.callv(_func_name, _args)

func call_puppet_node_sync(_node: Node, _func_name: String, _args: Array = []):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	if _node.is_inside_tree():
		var _NodePath = _node.get_path()
		_send_P2P_Packet(0, {"message": "Callv", "from": STEAM_ID, "node": _NodePath, "func_name": _func_name, "args": _args}, SEND_TYPE)

func call_puppet_id_sync(_ID: int, _func_name: String, _args: Array = []):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	if SteamLogic.OBJECT_DIC.has(_ID):
		_send_P2P_Packet(0, {"message": "CallID", "from": STEAM_ID, "id": _ID, "func_name": _func_name, "args": _args}, SEND_TYPE)

func call_master_node_sync(_node: Node, _func_name: String, _args: Array = []):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	if is_instance_valid(_node):
		var _NodePath = _node.get_path()
		_send_P2P_Packet(MasterID, {"message": "Callv", "from": STEAM_ID, "node": _NodePath, "func_name": _func_name, "args": _args}, SEND_TYPE)

func call_puppet_set_sync(_node: Node, _key: String, _value):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	if is_instance_valid(_node):
		if _node.is_inside_tree():
			var _NodePath = _node.get_path()
			_send_P2P_Packet(0, {"message": "Set", "from": STEAM_ID, "node": _NodePath, "key": _key, "value": _value}, SEND_TYPE)

func call_one_set_sync(_STEAMID, _node: Node, _key: String, _value):
	if not STEAM_BOOL and not OnlineNetwork.is_connected:
		return
	var SEND_TYPE: int = 2
	if is_instance_valid(_node):
		var _NodePath = _node.get_path()
		_send_P2P_Packet(_STEAMID, {"message": "Set", "from": STEAM_ID, "node": _NodePath, "key": _key, "value": _value}, SEND_TYPE)

func call_NPC_sync(_node: Node, _func_name: String, _args: Array = []):
	if not STEAM_BOOL:
		return
	var SEND_TYPE: int = Steam.P2P_SEND_UNRELIABLE_NO_DELAY
	if is_instance_valid(_node):
		var _NodePath = _node.get_path()
		_send_P2P_Packet(0, {"message": "NPC", "from": STEAM_ID, "node": _NodePath, "func_name": _func_name, "args": _args}, SEND_TYPE)
func call_Puppet_But_SYNC(_PlayerID: int, _Obj: Node, _func_name: String, _But):
	if not STEAM_BOOL:
		return
	var _Path: String = _Obj.get_path()
	var args = [_Path, _func_name, _But]

	var SEND_TYPE: int = Steam.P2P_SEND_RELIABLE
	_send_P2P_Packet(0, {"message": "PlayerBut", "from": _PlayerID, "func_name": _func_name, "args": args}, SEND_TYPE)
func call_LoadGame():
	if not STEAM_BOOL:
		return
	$Join.call_end()
	if GameLogic.LoadingUI.IsMain:
		if not GameLogic.Save.levelData.has("Level_bool"):
			GameLogic.Save.levelData["Level_bool"] = false
			GameLogic.call_rand_set()
			GameLogic.call_NewGame()
			call_LoadHomeOrGame()
		else:
			if GameLogic.Save.levelData.Level_bool:
				GameLogic.call_load()
				call_LoadHomeOrGame()
	else:
		call_LoadHomeOrGame()
func call_LoadHomeOrGame():
	if not STEAM_BOOL:
		return

	if LOBBY_InLevel:
		if LOBBY_levelData.has("cur_level"):
			var _LOBBY_Level = LOBBY_levelData["cur_level"]
			GameLogic.LoadingUI.call_LevelLoad(_LOBBY_Level)
	else:
		GameLogic.call_HomeLoad_puppet()

func _create_PuppetPlayer(_INFO: Array, _SteamID):
	print("[联机] _create_PuppetPlayer: from=", _SteamID, " INFO[2]=", _INFO[2] if _INFO.size() > 2 else "?", " STEAM_ID=", STEAM_ID)

	for _i in LOBBY_MEMBERS.size():
		if LOBBY_MEMBERS[_i].steam_id == _INFO[2]:
			if not LOBBY_MEMBERS[_i].Init:
				LOBBY_MEMBERS[_i].Init = true

				if _INFO[2] != STEAM_ID:
					GameLogic.call_NetInfo(3, "网络-加入房间", _INFO[2])
			break
	var _x = _INFO.size()
	if _INFO.size() >= 7:
		var _UID = _INFO[2]
		var _FASION = _INFO[6]

		_FASHIONDIC[int(_UID)] = _FASION
	if get_signal_connection_list("CreateNetPlayer").size() == 0:
		# 场景还没加载完，缓存数据等 map_home 连接信号后重放
		print("[联机] CreateNetPlayer 无监听，缓存 INFO[2]=", _INFO[2] if _INFO.size() > 2 else "?")
		_pending_create_player.append(_INFO)
		return
	emit_signal("CreateNetPlayer", _INFO)
	# 延迟一帧后重放缓存的 Callv 消息（等节点树就绪）
	call_deferred("_replay_pending_callv")

	pass

# 供 map_home 连接信号后调用，重放缓存的 CreateNetPlayer
func replay_pending_create_player():
	if _pending_create_player.empty():
		return
	print("[联机] 重放缓存 CreateNetPlayer: ", _pending_create_player.size(), " 条")
	var _queue = _pending_create_player.duplicate()
	_pending_create_player.clear()
	for _info in _queue:
		emit_signal("CreateNetPlayer", _info)
	call_deferred("_replay_pending_callv")

func _replay_pending_callv():
	if _pending_callv_queue.empty():
		return
	print("[联机] 重放缓存消息: ", _pending_callv_queue.size(), " 条")
	var _queue = _pending_callv_queue.duplicate()
	_pending_callv_queue.clear()
	var _ok = 0
	var _fail = 0
	for msg in _queue:
		if has_node(msg.node):
			var _Node = get_node(msg.node)
			if not is_instance_valid(_Node):
				_fail += 1
				continue
			if msg.message == "Set":
				_Node.set(msg.key, msg.value)
				_ok += 1
			elif msg.message == "Callv":
				if _Node.has_method(msg.func_name):
					_Node.callv(msg.func_name, msg.args)
					_ok += 1
				else:
					_fail += 1
		else:
			_fail += 1
	print("[联机] 重放完成: 成功=", _ok, " 失败=", _fail)

func call_PLAYER_SYNC():

	var _YSortPlayer = null
	if get_tree().get_root().has_node("Home/YSort/Players"):
		_YSortPlayer = get_tree().get_root().get_node("Home/YSort/Players")
	elif get_tree().get_root().has_node("Level/YSort/Players"):
		_YSortPlayer = get_tree().get_root().get_node("Level/YSort/Players")
	if _YSortPlayer != null:
		var _PlayerList = _YSortPlayer.get_children()
		if _PlayerList.size() < LOBBY_MEMBERS.size():
			printerr("生成的角色与玩家数不匹配")
			call_everybody_sync("SentPlayerToMaster")
		for _PlayerNode in _PlayerList:
			var _CurID = str(_PlayerNode.cur_ID)
			var _TSCNName = GameLogic.Config.PlayerConfig[_CurID].TSCN
			var _CurPlayerID = _PlayerNode.cur_Player
			var _PlayerPos = _PlayerNode.global_position
			var _cur_face = _PlayerNode.cur_face
			var _SkillArray = _PlayerNode.Stat.Skills
			var _FashionDic: Dictionary = GameLogic.Save.gameData["EquipDic"][1][GameLogic.player_1P_ID]
			if _CurPlayerID == 1:
				_CurPlayerID = STEAM_ID
			if _CurPlayerID != 2:
				if _FASHIONDIC.has(int(_CurPlayerID)):
					_FashionDic = _FASHIONDIC[int(_CurPlayerID)]

				print("给指定玩家发送自身角色：", _CurPlayerID)
				call_everybody_sync("PlayerTSCN_SYNC", [_TSCNName, _CurID, _CurPlayerID, _PlayerPos, _cur_face, _SkillArray, _FashionDic])

func call_MemberCheck_init():
	for _MEMBER in LOBBY_MEMBERS:
		_MEMBER.Check = false

func call_LeaveLobby(_ToHOME: bool, _LOBBYID):
	if not STEAM_BOOL or LOBBY_ID == 0:
		return
	emit_signal("LeaveLobby")
	Steam.leaveLobby(_LOBBYID)

	LOBBY_ID = 0
	for MEMBERS in LOBBY_MEMBERS:
		if MEMBERS["steam_id"] != STEAM_ID:
			var _RETURN = Steam.closeP2PSessionWithUser(MEMBERS["steam_id"])
			print("断开连接返回：", _RETURN, " 信息:", MEMBERS)
	LOBBY_MEMBERS.clear()
	call_SLOT_set(STEAM_ID, 0, 0, 0)
	LOBBY_IsMaster = false
	IsMultiplay = false
	InitBool = false

	if _ToHOME:
		if not GameLogic.Save.levelData.has("Level_bool"):
			GameLogic.Save.levelData["Level_bool"] = false
			GameLogic.call_rand_set()
			GameLogic.call_NewGame()
			GameLogic.call_HomeLoad()
		else:
			if GameLogic.Save.levelData.Level_bool:
				GameLogic.call_load()

func call_SLOT_set(_SLOT, _SLOT_2, _SLOT_3, _SLOT_4):
	SLOT = _SLOT
	SLOT_2 = _SLOT_2
	SLOT_3 = _SLOT_3
	SLOT_4 = _SLOT_4

func call_Master_Switch(_Switch: bool):
	$Join.call_Master_Switch(_Switch)

func call_test():
	var _TIME = OS.get_datetime()
	var _STEAM_Time = Steam.getServerRealTime()
	var _DATA = OS.get_datetime_from_unix_time(_STEAM_Time)

	var _YEAR = str(_DATA.year)
	var _MONTH = str(_DATA.month)
	var _DAY = str(_DATA.day)
	var _CURDAY = _YEAR + _MONTH + _DAY

var DailyLEADERBOARD: int
var ARRAY = [PoolIntArray()]

func call_FindLeaderBoard():
	if not SteamLogic.STEAM_BOOL:
		return
	var _STEAM_Time = Steam.getServerRealTime()
	var _DATA = OS.get_datetime_from_unix_time(_STEAM_Time)

	var _YEAR = int(_DATA.year)
	var _MONTH = int(_DATA.month)
	var _DAY = int(_DATA.day)
	if _MONTH < 10:
		_MONTH = "0" + str(_MONTH)
	if _DAY < 10:
		_DAY = "0" + str(_DAY)

	var _LEADERBOARDNAME = str(_YEAR) + str(_MONTH) + str(_DAY)

	Steam.findOrCreateLeaderboard(_LEADERBOARDNAME, Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)


var _UploadPoint: int
var _UploadArray: Array
func call_upload_daily_leaderboard(_POINT, _ARRAY):

	_UploadPoint = _POINT
	_UploadArray = _ARRAY

var BlackList: Array = []

func call_upload():

	if STEAM_ID in BlackList:
		return
	if DailyLEADERBOARD != 0 and _UploadPoint != 0:

		var _KEEP_BEST: bool = true
		var _POOL = PoolIntArray(_UploadArray)

		Steam.uploadLeaderboardScore(_UploadPoint, _KEEP_BEST, _POOL, SteamLogic.DailyLEADERBOARD)

signal FindBoard(BoardID)
signal BoardInfo(_INFO)
func _leaderboard_Find_Result(handle: int, found: int) -> void :
	if found == 1:
		DailyLEADERBOARD = handle

		Steam.downloadLeaderboardEntriesForUsers([SteamLogic.STEAM_ID], SteamLogic.DailyLEADERBOARD)
		emit_signal("FindBoard")

func _leaderboard_Score_Uploaded(success: int, _this_handle: int, this_score: Dictionary) -> void :
	if success == 1:

		_UploadPoint = 0

	else:
		print("Failed to upload scores!", success, " Score:", this_score)

func _leaderboard_Scores_Downloaded(_message: String, _leaderboard_handle: int, _result: Array) -> void :

	emit_signal("BoardInfo", _result)





func call_SetRich():
	$RichPresence.call_SetRich()

var DAYTYPE: String = ""

func call_Holiday_Check():
	var _STEAM_Time = Steam.getServerRealTime()
	if _STEAM_Time == 0:
		return
	var _DATA = OS.get_datetime_from_unix_time(_STEAM_Time)

	var _YEAR = int(_DATA.year)
	var _MONTH = int(_DATA.month)
	var _DAY = int(_DATA.day)
	var _HOUR = int(_DATA.hour)
	var _MIN = int(_DATA.minute)
	var _SEC = int(_DATA.second)
	if _MONTH == 12:
		if _DAY >= 23:

			DAYTYPE = "Chris"
	if _MONTH == 1:
		if _DAY <= 7:

			DAYTYPE = "NewYear"
	if _YEAR == 2024 and _MONTH == 2:
		if _DAY >= 9 and _DAY <= 16:

			DAYTYPE = "ChineseNewYear"
	elif _YEAR == 2025:
		if _MONTH in [1] and _DAY >= 28:

			DAYTYPE = "ChineseNewYear"
		elif _MONTH in [2] and _DAY <= 4:

			DAYTYPE = "ChineseNewYear"
	elif _YEAR == 2026 and _MONTH == 2:
		if _DAY >= 16 and _DAY <= 23:

			DAYTYPE = "ChineseNewYear"
	elif _YEAR == 2027 and _MONTH == 2:
		if _DAY >= 5 and _DAY <= 12:

			DAYTYPE = "ChineseNewYear"
	if _MONTH == 2:
		if _DAY >= 14 and _DAY < 21:
			DAYTYPE = "Valentine"
	if _MONTH == 10:
		if _DAY == 31:
			DAYTYPE = "Halloween"
	if _MONTH == 11:
		if _DAY < 7:
			DAYTYPE = "Halloween"

var _EQUIPLIST: Array = []
var _EQUIPDIC: Dictionary
var MAILNUM: int = 0
func _inventory_update(_inventory_handle):

	var _status = Steam.getResultStatus(_inventory_handle)

	var _ARRAY = Steam.getResultItems(_inventory_handle)
	var _num = _ARRAY.size()
	_EQUIPLIST = _ARRAY
	call_EquipCheck(_ARRAY)


	call_Equip_init()
	GameLogic.call_RecycleFinish()





func call_EquipCheck(_ARRAY):

	var _COSTUMARRAY: Array
	for _DIC in _ARRAY:
		_COSTUMARRAY.append(_DIC.item_definition)
	for _PLAYERID in 2:
		for _AVATARID in 8:
			var _CHECK = GameLogic.Save.gameData["EquipDic"]
			if GameLogic.Save.gameData["EquipDic"].has(_PLAYERID + 1):
				if GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1].has(_AVATARID):
					var _DIC = GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]

					var _HEADID = _DIC.Head
					var _FACEID = _DIC.Face
					var _BODYID = _DIC.Body
					var _HANDID = _DIC.Hand
					var _FOOTID = _DIC.Foot
					var _ACC_1_ID = _DIC.Accessory_1
					var _ACC_2_ID = _DIC.Accessory_2
					var _ACC_3_ID = _DIC.Accessory_3
					if not _COSTUMARRAY.has(_HEADID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Head"] = 0
					if not _COSTUMARRAY.has(_FACEID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Face"] = 0
					if not _COSTUMARRAY.has(_BODYID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Body"] = 0
					if not _COSTUMARRAY.has(_HANDID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Hand"] = 0
					if not _COSTUMARRAY.has(_FOOTID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Foot"] = 0
					if not _COSTUMARRAY.has(_ACC_1_ID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Accessory_1"] = 0
					if not _COSTUMARRAY.has(_ACC_2_ID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Accessory_2"] = 0
					if not _COSTUMARRAY.has(_ACC_3_ID):
						GameLogic.Save.gameData["EquipDic"][_PLAYERID + 1][_AVATARID]["Accessory_3"] = 0
	GameLogic.call_EquipChange()

var IsTRANSFER: bool
func call_Equip_init():

	if not _EQUIPLIST.size():
		return

	var _MAILLogic: bool = false
	if not _EQUIPDIC.size():
		_MAILLogic = true
	_EQUIPDIC.clear()
	var _MAILCHECK: bool = false
	for _DIC in _EQUIPLIST:
		var _ID = _DIC.item_definition
		var _QUANTITY = _DIC.quantity
		var _ITEM_ID = _DIC.item_id
		if _ID == 20002:
			_MAILCHECK = true
			if _MAILLogic:
				MAILNUM = _QUANTITY
				GameLogic.cur_MAILNUM = MAILNUM


		if not _EQUIPDIC.has(_ID):
			_EQUIPDIC[_ID] = {"Num": int(_QUANTITY), "Id": _ITEM_ID}

	if _MAILCHECK == false:
		MAILNUM = 0
	GameLogic.GameUI.call_CostumeCoin_change()
	call_NewMail(false)
	call_Special_Check()
func _definition_update(_Array):

	pass

signal CostumeExchange(_INID, _INNUM, _OUTID)
signal MailExchange(_INID, _INNUM, _OUTID)
signal NewMail(_BOOL)
func call_MailExchange(_INID, _INNUM, _OUTID):
	emit_signal("MailExchange", 20002, _INNUM, _OUTID)
func call_CostumeExchange(_INID, _INNUM, _OUTID):
	emit_signal("CostumeExchange", 20001, _INNUM, _OUTID)
func call_NewMail(_BOOL):
	emit_signal("NewMail", _BOOL)
func _inventory_ready(_result: int, _inventory_handle: int):
	var _status = Steam.getResultStatus(_inventory_handle)

	var _ARRAY = Steam.getResultItems(_inventory_handle)

	if _ARRAY.size() == 2:

		var _INPUTDIC = _ARRAY[0]
		var _OUPUTDIC = _ARRAY[1]
		var _INNUM: int = 0
		var _INCHECK: bool = false
		var _MAILCHECK: bool = false
		var _OUTID: int = 0
		if _INPUTDIC.has("item_definition") and _INPUTDIC.has("quantity"):
			if _INPUTDIC.item_definition == 20001:
				_INNUM = _INPUTDIC.quantity
				_INCHECK = true
		if _INPUTDIC.has("item_definition") and _INPUTDIC.has("quantity"):
			if _INPUTDIC.item_definition == 20002:
				_INNUM = _INPUTDIC.quantity
				MAILNUM = _INPUTDIC.quantity
				GameLogic.cur_MAILNUM = MAILNUM
				_MAILCHECK = true
				call_NewMail(false)

		if _OUPUTDIC.has("item_definition") and _OUPUTDIC.has("quantity"):
			_OUTID = _OUPUTDIC.item_definition
		if _INCHECK and _OUTID != 0:
			call_CostumeExchange(20001, _INNUM, _OUTID)
		if _MAILCHECK and _OUTID != 0:
			call_MailExchange(20002, _INNUM, _OUTID)
			call_NewMail(false)
	if _ARRAY.size() == 1:

		for _DIC in _ARRAY:
			var _ITEMID = _DIC.item_definition
			if _ITEMID == 20002:

				MAILNUM = _DIC.quantity
				call_NewMail(true)

				LoadInventory()

func call_transferItemQuantity():
	for _DIC in _EQUIPLIST:
		var _ID = _DIC.item_definition
		var _QUANTITY = _DIC.quantity
		var _ITEM_ID = _DIC.item_id
		if _EQUIPDIC.has(_ID):
			var _TargetID = _EQUIPDIC[_ID].Id
			if _TargetID != _ITEM_ID:

				var _trans = Steam.transferItemQuantity(_ITEM_ID, _QUANTITY, _EQUIPDIC[_ID].Id, false)
				var _transstatus = Steam.getResultStatus(_trans)

				break
func LoadInventory():
	if SteamLogic.STEAM_BOOL:
		var _g = Steam.getAllItems()

var _LEADERBOARDLIST: Array = ["20251225"]
var NEXTID: int = 0
var DICID: int = 0
var BOARDIDArray: Array
func call_Special_Check():
	if not Steam.is_connected("leaderboard_find_result", self, "_Specialboard_Find_Result"):
		var _Con = Steam.connect("leaderboard_find_result", self, "_Specialboard_Find_Result")
		_Con = Steam.connect("leaderboard_scores_downloaded", self, "_Specialboard_Scores_Downloaded")
		call_FindSpecialLeaderBoard()

func call_CheckBoard():

	if BOARDIDArray.size() > DICID:

		var _BOARDID = BOARDIDArray[DICID]

		Steam.downloadLeaderboardEntriesForUsers([SteamLogic.STEAM_ID], _BOARDID)

func call_FindSpecialLeaderBoard():
	if not SteamLogic.STEAM_BOOL:
		return

	if _LEADERBOARDLIST.size() > NEXTID:

		Steam.findLeaderboard(_LEADERBOARDLIST[NEXTID])
	else:

		Steam.set_leaderboard_details_max(10)
		call_CheckBoard()

func _Specialboard_Scores_Downloaded(_message: String, _boardID: int, _result: Array) -> void :

	if _result.size():
		if BOARDIDArray.has(_boardID):
			var _ID = BOARDIDArray.find(_boardID)
			if _LEADERBOARDLIST.size() > _ID:

				var _NAME = _LEADERBOARDLIST[_ID]

				if _NAME in ["20251225"]:
					if not _EQUIPDIC.has(1110006):
						if STEAM_BOOL:
							var _reTr = Steam.triggerItemDrop(53001)
							var _status = Steam.getResultStatus(_reTr)



	DICID += 1
	call_CheckBoard()
func _Specialboard_Find_Result(_BOARDID: int, found: int) -> void :
	if found == 1:
		if not BOARDIDArray.has(_BOARDID):
			BOARDIDArray.append(_BOARDID)
	NEXTID += 1
	call_FindSpecialLeaderBoard()
