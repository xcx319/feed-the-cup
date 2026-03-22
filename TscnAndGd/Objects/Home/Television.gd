extends Head_Object

export var NAME: String

var ShowBool: bool

onready var BOARDINFO_TSCN = preload("res://TscnAndGd/UI/Info/BoardInfo.tscn")

onready var BoardBOX = $LeaderBoard / Control / Info / BG / Scroll / VBox
onready var ButShow = get_node("Button/A")

onready var aniPlayer = $AniNode / Ani
onready var ShowAni = $TexNode / Sprite / Ani
func _ready() -> void :
	self.hide()

	call_deferred("call_TV_init")
func call_TV_init():
	if GameLogic.Save.gameData.has("HomeDevList"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LOBBY_gameData.has("HomeDevList"):
				if SteamLogic.LOBBY_gameData.HomeDevList.has("电视机"):
					ShowAni.play("show_init")
		elif GameLogic.Save.gameData.HomeDevList.has("电视机"):
			ShowAni.play("show_init")
	var _con = GameLogic.connect("SYNC", self, "call_show")
func call_show():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if ShowAni.assigned_animation == "init":

		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has("电视机"):
				ShowAni.play("show")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_show_puppet")

func call_show_puppet():
	ShowAni.play("show")
	ShowBool = true

var cur_Used: bool = false
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				ButShow.call_player_in(_Player.cur_Player)
		- 2:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				ButShow.call_player_out(_Player.cur_Player)
		0, "A":
			if not cur_Used:

				cur_Used = true
				match _Player.cur_Player:
					1, SteamLogic.STEAM_ID:
						if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
							GameLogic.Con.connect("P1_Control", self, "_control_logic")

					2:
						if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
							GameLogic.Con.connect("P2_Control", self, "_control_logic")

				call_show_logic()
func call_show_logic():
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(1)
	if GameLogic.Player2_bool and is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(1)
		for _NODE in BoardBOX.get_children():
			BoardBOX.remove_child(_NODE)
			_NODE.queue_free()
	$LeaderBoard / Control / Info / BoardInfo.call_reset()
	if not SteamLogic.is_connected("FindBoard", self, "_download_LeaderBoard_Self"):
		var _CON = SteamLogic.connect("FindBoard", self, "_download_LeaderBoard_Self")
	if not SteamLogic.is_connected("BoardInfo", self, "_LeaderBoard_SelfShow"):
		var _CON = SteamLogic.connect("BoardInfo", self, "_LeaderBoard_SelfShow")
	SteamLogic.call_FindLeaderBoard()

	$LeaderBoard / AnimationPlayer.play("show")
	GameLogic.Can_ESC = false
	call_Time_Show()
var _DATAINFO: Dictionary
func call_Time_Show():
	if not SteamLogic.STEAM_BOOL:
		return
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
	_DATAINFO = _DATA
	var _TIME = 24 * 60 * 60 - ((_HOUR * 60 * 60) + (_MIN * 60) + _SEC)
	var _HOUR_Check: int = int(float(_TIME) / 3600)
	var _MIN_Check: int = (_TIME - int(_HOUR_Check) * 3600) / 60
	var _SCE_Check: int = _TIME - int(_HOUR_Check) * 3600 - int(_MIN_Check) * 60

	call_TimeLabel_Show(_HOUR_Check, _MIN_Check, _SCE_Check)
func call_TimeLabel_Show(_HOUR, _MIN, _SCE):
	var _MINSTR = str(_MIN)
	if _MIN < 10:
		_MINSTR = "0" + _MINSTR
	var _SCESTR = str(_SCE)
	if _SCE < 10:
		_SCESTR = "0" + _SCESTR
	$LeaderBoard / Control / TimeInfoLabel / TimeLabel.text = str(_HOUR) + ":" + _MINSTR + ":" + _SCESTR
	$LeaderBoard / Control / TimeInfoLabel / TimeLabel / Timer.start()

func _download_LeaderBoard_Self():

	Steam.set_leaderboard_details_max(10)

	Steam.downloadLeaderboardEntriesForUsers([SteamLogic.STEAM_ID], SteamLogic.DailyLEADERBOARD)
func _LeaderBoard_SelfShow(_ARRAY):
	for _BOARDINFO in _ARRAY:
		var _ID = _BOARDINFO.steam_id
		var _RANK = _BOARDINFO.global_rank
		var _SCORE = _BOARDINFO.score
		var _DETAIL = _BOARDINFO.details
		$LeaderBoard / Control / Info / BoardInfo.call_init(_RANK, _SCORE, _ID, _DETAIL)
	call_download_Leaderboard()
func call_download_Leaderboard():
	if SteamLogic.is_connected("BoardInfo", self, "_LeaderBoard_SelfShow"):
		SteamLogic.disconnect("BoardInfo", self, "_LeaderBoard_SelfShow")
	if not SteamLogic.is_connected("BoardInfo", self, "_LeaderBoard_ShowLogic"):
		var _CON = SteamLogic.connect("BoardInfo", self, "_LeaderBoard_ShowLogic")
	Steam.set_leaderboard_details_max(10)

	if SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:

		Steam.downloadLeaderboardEntries( - 100, 100, 1, SteamLogic.DailyLEADERBOARD)

	else:

		Steam.downloadLeaderboardEntries( - 10, 10, 1, SteamLogic.DailyLEADERBOARD)

func return_LeaderBoard_Check(_ARRAY: Array):
	if not _ARRAY.size():
		return _ARRAY
	if _ARRAY[0].steam_id == SteamLogic.STEAM_ID and _ARRAY.size() == 1:
		return _ARRAY

	var _CHECK: bool = true
	var _RETURNARRAY: Array

	if _CHECK:
		var _DELLIST: Array
		for _BOARDINFO in _ARRAY:

			var _CHECKPOINT = _BOARDINFO.details[9]
			var _CUP = int(_BOARDINFO.details[3]) + int(_BOARDINFO.details[4]) + int(_BOARDINFO.details[5])
			if _BOARDINFO.score > _CHECKPOINT * 10:
				_DELLIST.append(_BOARDINFO)
			elif _BOARDINFO.score > 900000 and _CUP < 100:
				_DELLIST.append(_BOARDINFO)

		for _BOARDINFO in _DELLIST:
			if _ARRAY.has(_BOARDINFO):
				_ARRAY.erase(_BOARDINFO)
		if _ARRAY.size() >= 10:

			var _RANK: int = 1
			var _MAX: int = 30
			if SteamLogic.STEAM_ID in [76561199510302905]:
				_MAX = 1000
			for _BOARDINFO in _ARRAY:
				if _RANK <= _MAX:

					_RANK += 1
					_RETURNARRAY.append(_BOARDINFO)
	else:
		if _ARRAY.size() >= 10:

			var _RANK: int = 1
			for _BOARDINFO in _ARRAY:
				if _RANK <= 10:
					_BOARDINFO.global_rank = _RANK
					_RANK += 1
					_RETURNARRAY.append(_BOARDINFO)
					$LeaderBoard / Control / Info / BoardInfo.call_ReCheck(_BOARDINFO)

	return _RETURNARRAY
func _LeaderBoard_ShowLogic(_ARRAY):

	_ARRAY = return_LeaderBoard_Check(_ARRAY)
	if _ARRAY.size() == 1:
		return
	for _NODE in BoardBOX.get_children():
		BoardBOX.remove_child(_NODE)
		_NODE.queue_free()
	for _BOARDINFO in _ARRAY:
		var _RANK = _BOARDINFO.global_rank
		var _SCORE = _BOARDINFO.score
		var _ID = _BOARDINFO.steam_id
		var _DETAIL = _BOARDINFO.details
		var _INFONODE = BOARDINFO_TSCN.instance()
		BoardBOX.add_child(_INFONODE)
		_INFONODE.call_init(_RANK, _SCORE, _ID, _DETAIL)
func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:
			"B", "START":
				call_Back_Logic()
func call_Back_Logic():
	$LeaderBoard / AnimationPlayer.play("hide")
	cur_Used = false

	if SteamLogic.is_connected("FindBoard", self, "_download_LeaderBoard_Self"):
		SteamLogic.disconnect("FindBoard", self, "_download_LeaderBoard_Self")

func call_CanControl():
	if is_instance_valid(GameLogic.player_1P):
		GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool and is_instance_valid(GameLogic.player_2P):
		GameLogic.player_2P.call_control(0)
	$LeaderBoard / Control / TimeInfoLabel / TimeLabel / Timer.stop()
	GameLogic.Can_ESC = true

func _on_BackBut_pressed():
	call_Back_Logic()

func _on_Timer_timeout():
	call_Time_Show()

func _on_Area2D_body_entered(_body):
	aniPlayer.play("show")

func _on_Area2D_body_exited(_body):
	aniPlayer.play("hide")
