extends Control
var cur_TYPE: String
var LogicType: int = 1

func call_puppet_DayLabel(_DAY):

	pass
func call_init():
	call_del()

	if SteamLogic.STEAM_BOOL:
		if not SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

			GameLogic.call_HomeLoad_puppet()
			return



	var _DAY = GameLogic.cur_Day

	var _SPECIAL_INT = GameLogic.SPECIALLEVEL_Int
	if SteamLogic.IsJoin:
		if SteamLogic.LevelDic.has("SPECIALLEVEL_Int"):
			_SPECIAL_INT = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if _SPECIAL_INT:
		get_node("DAYLabel").text = "SPECIAL"
	else:
		get_node("DAYLabel").text = "DAY " + str(_DAY)

	call_newday(_DAY, _SPECIAL_INT)
func call_newday(_DAY, _SPECIAL_INT):

	var _Type: Array

	if _SPECIAL_INT > 0:
		_Type = GameLogic.SPECIAL_DAY
	else:
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.has("Difficult"):
			var _LIST = _LEVELINFO.get("Difficult")
			for _ID in _LIST:
				_Type.append(_ID)

		var _LEVELLIST: Array = GameLogic.curLevelList
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			_LEVELLIST.clear()
			var _DEVILNUM: int = int(SteamLogic.LevelDic["Devil"])
			var _NUM: int = 0
			if SteamLogic.LevelDic.has("cur_LevelInfo"):
				for _DEVIL in SteamLogic.LevelDic.cur_LevelInfo["DevilList"]:
					if _NUM < _DEVILNUM:
						_LEVELLIST.append(_DEVIL)
		if "难度-增加随机一日" in _LEVELLIST:
			var _x = _Type.size() - 1
			if _x >= 0:
				if _Type[_x] != "随机":
					_Type.insert(_Type.size() - 1, "随机")


	var _TSCN = load("res://TscnAndGd/UI/Info/DayTypeInfo.tscn")
	for _i in _Type.size():
		var _DayINFO = _TSCN.instance()
		get_node("HBoxContainer").add_child(_DayINFO)
		var _Name = _Type[_i]
		match _Name:
			"事件1", "事件2", "事件3":
				_Name = "事件"
			"升级1", "升级2", "升级3":
				_Name = "升级"
			"随机1", "随机2", "随机3":
				_Name = "随机"
			"精英事件1", "精英事件2", "精英随机1", "精英随机2", "地铁":
				_Name = "精英事件"
			"简化1", "简化2", "简化3":
				_Name = "简化"
			"无":
				_Name = "无"
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster and SteamLogic.LevelDic.SkipDay <= _i:

			if (_DAY - 1) > _i:
				_Name = _Name + "_完成"
		else:
			if (_DAY - 1) > _i:
				_Name = _Name + "_完成"
		_DayINFO.get_node("Tex/TypeAni").play(_Name)
		if (_DAY - 1) == _i:
			_DayINFO.get_node("Effect/Ani").play("show")
			cur_TYPE = _Type[_i]
			GameLogic.cur_DayType = cur_TYPE

	if GameLogic.SPECIALLEVEL_Int:
		cur_TYPE = "地铁"
		GameLogic.cur_DayType = cur_TYPE
func call_del():
	for _Node in get_node("HBoxContainer").get_children():
		_Node.queue_free()
