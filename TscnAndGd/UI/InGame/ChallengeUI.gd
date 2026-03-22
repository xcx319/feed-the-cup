extends CanvasLayer
var ChallengeList: Array

func _ready():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.is_connected("OpenStore", self, "_Hide"):
		var _CON = GameLogic.connect("OpenStore", self, "_Hide")
	if not GameLogic.is_connected("DayStart", self, "_NewChallenge"):
		var _CON = GameLogic.connect("DayStart", self, "_NewChallenge")

func _Hide():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_Hide")
	if has_node("Control/Ani"):
		if get_node("Control/Ani").assigned_animation == "show":
			get_node("Control/Ani").play("hide")
		else:
			call_del()
func _ChallengeList():
	ChallengeList.clear()

	if GameLogic.cur_Event:
		var _Rank = GameLogic.Config.EventConfig[GameLogic.cur_Event].Rank
		var _ChallengeKeys = GameLogic.Config.ChallengeConfig.keys()
		for _ChallengeName in _ChallengeKeys:
			if GameLogic.Config.ChallengeConfig[_ChallengeName].Rank == _Rank:
				if not GameLogic.cur_Challenge.has(_ChallengeName):
					ChallengeList.append(_ChallengeName)
	else:
		var _Rank = 1

		match GameLogic.cur_StoreStar:
			0, 1, 2, 3:
				_Rank = 1
			4, 5, 6, 7:
				_Rank = 2
			8, 9, 10:
				_Rank = 3

		var _ChallengeKeys = GameLogic.Config.ChallengeConfig.keys()
		for _ChallengeName in _ChallengeKeys:
			if int(GameLogic.Config.ChallengeConfig[_ChallengeName].Rank) == _Rank:
				if not GameLogic.cur_Challenge.has(_ChallengeName):
					ChallengeList.append(_ChallengeName)
func _NewChallenge():
	if GameLogic.cur_Day > 1 and not GameLogic.SPECIALLEVEL_Int:
		match GameLogic.cur_DayType:
			"无":
				GameLogic.call_Reward()

				return

		_ChallengeList()
		var _Rand = GameLogic.return_randi() % ChallengeList.size()
		var _CHALLENGENODE = get_node("Control/ChallengeInfo")
		var _Name = ChallengeList[_Rand]
		_CHALLENGENODE.ID = _Name
		GameLogic.cur_Challenge[_Name] = GameLogic.Config.ChallengeConfig[_Name]

		get_node("Control/Ani").play("show")
		GameLogic.call_Reward()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_Challenge", [_Name, GameLogic.cur_Challenge])
func call_puppet_Challenge(_Name, _CHALLENGE):

	GameLogic.cur_Challenge = _CHALLENGE
	SteamLogic.LevelDic.cur_Challenge = GameLogic.cur_Challenge

	var _CHALLENGENODE = get_node("Control/ChallengeInfo")
	_CHALLENGENODE.ID = _Name

	get_node("Control/Ani").play("show")

	GameLogic.call_Reward()
	if not SteamLogic.LevelDic.has("Choose_Challenge"):
		SteamLogic.LevelDic["Choose_Challenge"] = []
	if not SteamLogic.LevelDic["Choose_Challenge"].has(_Name):
		SteamLogic.LevelDic["Choose_Challenge"].append(_Name)
func call_del():
	self.queue_free()
