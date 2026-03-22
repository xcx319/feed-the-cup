extends Label

var SteamID: int = 0
var _CHECK: bool

func _ready():
	if SteamLogic.IsMultiplay:

		var _Latency = SteamLogic.connect("Latency", self, "_LatencyLabel_set")

func _LatencyLabel_set(_STEAMID, _INFO: Array):

	var _Latency: int = _INFO[0]
	if SteamID == 0:
		SteamID = get_parent().get_parent().get_parent().get("cur_Player")
	if SteamID != _STEAMID:
		return
	if not _CHECK:
		_CHECK = true
		return
	var LATENCY = int(float(_Latency) / 1000)
	self.text = str(LATENCY) + " ms"
	if LATENCY <= 255:
		self.modulate = Color8(LATENCY, 255, 0, 255)
	elif LATENCY <= (255 + 255):
		self.modulate = Color8(255, 255 - (LATENCY - 255), 0, 255)
	else:
		self.modulate = Color8(255, 0, 0, 255)
	if GameLogic.LoadingUI.IsHome:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			var _LEVEL = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Level")
			var _Devil = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Devil")
			call_JoinCheck(_LEVEL, _Devil)
		elif SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _LEVEL = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Level")
			var _Devil = Steam.getLobbyData(SteamLogic.LOBBY_ID, "Devil")
			if _LEVEL != GameLogic.cur_level:
				var _SetLevel = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Level", GameLogic.cur_level)
				var _SetDevil = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Devil", str(GameLogic.cur_Devil))
				var _SetDay = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Day", str(GameLogic.cur_Day))

func call_JoinCheck(_LEVEL, _Devil):
	if _LEVEL == "":
		GameLogic.GameUI.call_JoinInfo( - 1)
		return
	elif SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.LOBBY_levelData.has("cur_Day"):
			var _DAY = SteamLogic.LOBBY_levelData.cur_Day
			if _DAY > 0:
				GameLogic.GameUI.call_JoinInfo(3)
				return

	elif GameLogic.cur_Day > 0:
		GameLogic.GameUI.call_JoinInfo(3)
		return
	var _LEVELKEY = GameLogic.Save.gameData["Level_Data"].keys()



	if _LEVELKEY.has(_LEVEL):
		if int(GameLogic.Save.gameData["Level_Data"][_LEVEL].cur_Devil) < int(_Devil):

			GameLogic.GameUI.call_JoinInfo(1)

		else:

			GameLogic.GameUI.call_JoinInfo(0)

	else:
		var _LEVELTYPE: int = int(GameLogic.Config.SceneConfig[_LEVEL].LevelType)
		var _LEVELID: int = int(GameLogic.Config.SceneConfig[_LEVEL].LevelID)
		if _LEVELID == 1:
			_LEVELTYPE -= 1
			_LEVELID = 4
		else:
			_LEVELID -= 1
		var _SCENEKEY = GameLogic.Config.SceneConfig.keys()
		var _JOINTYPE: int = 0
		for _CHECKLEVEL in _SCENEKEY:
			var _INFO = GameLogic.Config.SceneConfig[_CHECKLEVEL]
			if int(_INFO.LevelType) == _LEVELTYPE and int(_INFO.LevelID) == _LEVELID:
				if _LEVELKEY.has(_CHECKLEVEL):
					_JOINTYPE = 1
				else:
					_JOINTYPE = 2
				break
		GameLogic.GameUI.call_JoinInfo(_JOINTYPE)
