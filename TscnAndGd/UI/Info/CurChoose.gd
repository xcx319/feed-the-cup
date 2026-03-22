extends Control

onready var ShowBut = preload("res://TscnAndGd/UI/Buttons/RewardShowButton.tscn")
onready var Group = preload("res://TscnAndGd/UI/Info/RewardInfo.tres")
var CurGroup

func _del():
	for _BUT in get_node("Reward/Grid").get_children():
		_BUT.queue_free()
	for _BUT in get_node("Challenge/Grid").get_children():
		_BUT.queue_free()
func call_init():

	_del()
	get_node("ShowInfo").hide()
	if not CurGroup:
		CurGroup = Group

	var _RewardList = GameLogic.cur_Rewards

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_RewardList = SteamLogic.LevelDic.cur_Rewards

	var _RewardFirstBut

	if _RewardList:
		for i in _RewardList.size():
			var _RewardBut = ShowBut.instance()
			_RewardBut.name = str(i)

			_RewardBut.set_button_group(CurGroup)
			get_node("Reward/Grid").add_child(_RewardBut)
			_RewardBut.ID = _RewardList[i]

			if i == 0:
				_RewardFirstBut = _RewardBut
	var _ChallengeList = GameLogic.cur_Challenge.keys()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_ChallengeList = SteamLogic.LevelDic.cur_Challenge.keys()

	if _RewardList.size() > 17:
		$Ani.play("2")
	else:
		$Ani.play("1")
	if _ChallengeList:
		for i in _ChallengeList.size():
			var _But = ShowBut.instance()
			_But.name = str(i)

			_But.set_button_group(CurGroup)
			get_node("Challenge/Grid").add_child(_But)
			_But.ID = _ChallengeList[i]
	_focus_neighbour_set()

func call_ShowInfo_Hide():

	get_node("ShowInfo").hide()
func call_ShowInfo(_Select, _Pos):
	if GameLogic.cur_Rewards.has(_Select):
		_Pos.y += 100
		get_node("ShowInfo").rect_position = _Pos
		get_node("ShowInfo")._IDSet(_Select)
		get_node("ShowInfo").show()
	elif GameLogic.cur_Challenge.has(_Select):
		_Pos.y += 100
		get_node("ShowInfo").rect_position = _Pos
		get_node("ShowInfo")._IDSet(_Select)
		get_node("ShowInfo").show()
func _focus_neighbour_set():
	var _RewardButList = get_node("Reward/Grid").get_children()
	for i in _RewardButList.size():
		var _BUT = _RewardButList[i]
		var _ButPath = _BUT.get_path()
		if i == 0:
			_BUT.set_focus_neighbour(MARGIN_LEFT, _ButPath)
		else:
			var _LeftBut = _RewardButList[i - 1]
			var _LeftButPath = _LeftBut.get_path()
			_BUT.set_focus_neighbour(MARGIN_LEFT, _LeftButPath)

		if i == _RewardButList.size() - 1:
			_BUT.set_focus_neighbour(MARGIN_RIGHT, _ButPath)
		else:
			var _RightBut = _RewardButList[i + 1]
			var _RightButPath = _RightBut.get_path()
			_BUT.set_focus_neighbour(MARGIN_RIGHT, _RightButPath)


		_BUT.set_focus_neighbour(MARGIN_TOP, _ButPath)

	var _ChallengeButList = get_node("Challenge/Grid").get_children()
	for i in _ChallengeButList.size():
		var _BUT = _ChallengeButList[i]
		var _ButPath = _BUT.get_path()
		if i == 0:
			_BUT.set_focus_neighbour(MARGIN_LEFT, _ButPath)
		else:
			var _LeftBut = _ChallengeButList[i - 1]
			var _LeftButPath = _LeftBut.get_path()
			_BUT.set_focus_neighbour(MARGIN_LEFT, _LeftButPath)
		if i == _ChallengeButList.size() - 1:
			_BUT.set_focus_neighbour(MARGIN_RIGHT, _ButPath)
		else:
			var _RightBut = _ChallengeButList[i + 1]
			var _RightButPath = _RightBut.get_path()
			_BUT.set_focus_neighbour(MARGIN_RIGHT, _RightButPath)
