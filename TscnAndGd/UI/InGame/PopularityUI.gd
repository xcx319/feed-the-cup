extends Control

var Target_Pop: int = 0
var _NUM: int
var _ADD: int
var _CurNum: int
var _CurMax: int
var _time: float = 0
var _LEVELMAX: int = 10
onready var _GIFTTSCN = preload("res://TscnAndGd/UI/Info/GiftUI.tscn")
onready var ADDANI = $AddAni
func _ready():
	var _CON = GameLogic.connect("Popularity", self, "_SYCN")
	var _DayStart = GameLogic.connect("DayStart", self, "call_init")
	call_hide()
func call_hide():
	get_node("Ani").play("hide")

func _SYCN(_VALUE):


	if GameLogic.cur_Popularity_Level >= _LEVELMAX:
		if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
			_VALUE = int(float(_VALUE) * 1.5)
		GameLogic.call_MoneyOther_Change(_VALUE, GameLogic.HomeMoneyKey)

		$BG / ProgressBG / MoneyAdd.text = "+" + str(_VALUE)
		if ADDANI.current_animation == "AddMoney":
			ADDANI.play("init")
		ADDANI.play("AddMoney")
	else:
		_ADD = GameLogic.cur_Popularity - _CurNum
		$BG / ProgressBG / AddLebel.text = "+" + str(_VALUE)

		if ADDANI.current_animation == "play":
			ADDANI.play("init")
		ADDANI.play("play")




	set_physics_process(true)

func call_puppet_set(_POPULAR):
	GameLogic.cur_Popularity = _POPULAR
	call_ResetGift()
	_CurNum = GameLogic.cur_Popularity
	get_node("BG/ProgressBG/Progress").value = _CurNum
	_ProcessSet()
	get_node("Ani").play("show")
	if GameLogic.cur_Popularity_Level >= _LEVELMAX:
		call_LevelMax(true)
func call_init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	Target_Pop = 0
	call_ResetGift()
	_CurNum = GameLogic.cur_Popularity
	get_node("BG/ProgressBG/Progress").value = _CurNum
	_ProcessSet()
	get_node("Ani").play("show")
	_LEVELMAX = 10
	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Achievement.cur_EquipList.has("礼物增加"):
			_LEVELMAX += 2

		if GameLogic.Save.gameData.HomeDevList.has("猫爬架"):
			_LEVELMAX += 1
		if GameLogic.Save.gameData.HomeDevList.has("动物厕所"):
			_LEVELMAX += 1
		if GameLogic.Save.gameData.HomeDevList.has("自动喂食器"):
			_LEVELMAX += 1
		if GameLogic.Save.gameData.HomeDevList.has("充气泳池"):
			_LEVELMAX += 1
		if GameLogic.Save.gameData.HomeDevList.has("南瓜小窝"):
			_LEVELMAX += 1
		if GameLogic.Save.gameData.HomeDevList.has("祭台"):
			_LEVELMAX += 1
		if GameLogic.Save.gameData.HomeDevList.has("玩具鱼"):
			_LEVELMAX += 1
	var _BOOL: bool = false
	var _DAYCHECK: bool = false
	var _DiffSize = GameLogic.cur_levelInfo.Difficult.size()
	if GameLogic.cur_Day >= _DiffSize:

		if "难度-增加随机一日" in GameLogic.curLevelList:
			if GameLogic.cur_Day >= _DiffSize + 1:
				_DAYCHECK = true
		else:
			_DAYCHECK = true
	if GameLogic.SPECIALLEVEL_Int or _DAYCHECK:
		GameLogic.cur_Popularity_Level = _LEVELMAX

	if GameLogic.cur_Popularity_Level >= _LEVELMAX:
		call_LevelMax(true)
		_BOOL = true
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_init_puppet", [GameLogic.cur_Popularity_Level, GameLogic.cur_Popularity, _LEVELMAX, _BOOL, GameLogic.cur_Gift])
func call_init_puppet(_LEVEL, _POP, _MAX, _BOOL, _GIFT):
	GameLogic.cur_Popularity_Level = _LEVEL
	GameLogic.cur_Gift = _GIFT
	call_ResetGift()
	_CurNum = _POP
	GameLogic.cur_Popularity = _POP
	_LEVELMAX = _MAX
	call_LevelMax(_BOOL)
	get_node("BG/ProgressBG/Progress").value = _CurNum
	_ProcessSet()
	get_node("Ani").play("show")
func _ProcessSet():
	var BASEPOINT: float = 250
	var _NEGPOINT: float = 0
	var _MinNum: int = 0
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	call_LevelMax(false)
	var _LEVELINFO = GameLogic.cur_levelInfo


	var _CurLEVEL: int = GameLogic.cur_Popularity_Level
	var _ISMAX: bool = false
	if _CurLEVEL >= _LEVELMAX:
		_CurLEVEL = _LEVELMAX
		_ISMAX = true
	if _LEVELINFO.GamePlay.has("每日增加半小时") or _LEVELINFO.GamePlay.has("新手引导1"):
		var _LEVELNAME = GameLogic.cur_level
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			_LEVELNAME = SteamLogic.LOBBY_levelData.cur_level
		var _DiffCult_Array = GameLogic.Config.SceneConfig[_LEVELNAME].Difficult
		var _DAYBASE = _DiffCult_Array.size()
		var _CHECK = _CurLEVEL - _DAYBASE
		var _Base = (_CurLEVEL + 1) * BASEPOINT
		var _MinBase = (_CurLEVEL) * BASEPOINT


		_CurMax = ((_CurLEVEL + 1) * _Base + _Base) / 2
		_MinNum = ((_CurLEVEL) * _MinBase + _MinBase) / 2

	elif _LEVELINFO.GamePlay.has("每日增加一刻钟"):
		var _Base = (_CurLEVEL + 1) * BASEPOINT
		var _MinBase = (_CurLEVEL) * BASEPOINT
		_CurMax = ((_CurLEVEL + 1) * _Base + _Base) / 2
		_MinNum = ((_CurLEVEL) * _MinBase + _MinBase) / 2
	else:
		var _LEVELNAME = GameLogic.cur_level
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			_LEVELNAME = SteamLogic.LOBBY_levelData.cur_level
		var _DiffCult_Array = GameLogic.Config.SceneConfig[_LEVELNAME].Difficult
		var _DAYBASE = _DiffCult_Array.size()
		var _CHECK = _CurLEVEL - _DAYBASE

		var _Hours: float = float(GameLogic.Config.SceneConfig[_LEVELNAME].OpeningHours)
		var _BASEFLOAT = _Hours * 80
		var _Base = (_CurLEVEL + 1) * _BASEFLOAT
		var _MinBase = (_CurLEVEL) * _BASEFLOAT

		_CurMax = (_CurLEVEL + 1) * _Base
		_MinNum = _CurLEVEL * _MinBase

	get_node("BG/ProgressBG/Progress").min_value = _MinNum
	get_node("BG/ProgressBG/Progress").max_value = _CurMax
	get_node("BG/ProgressBG/Progress").value = _CurNum
	get_node("BG/ProgressBG/Progress/NumLabel").text = str(_CurNum - _MinNum) + " / " + str(_CurMax - _MinNum)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Process_puppet", [_MinNum, _CurMax, _CurNum, GameLogic.cur_Popularity, _CurLEVEL, _ISMAX])
func call_Process_puppet(_MINNUM, _MAX, _CURNUM, _POPULAR, _LEVEL, _ISMAX):


	GameLogic.cur_Popularity = _POPULAR
	GameLogic.cur_Popularity_Level = _LEVEL
	_CurNum = _CURNUM
	_CurMax = _MAX
	get_node("BG/ProgressBG/Progress").min_value = _MINNUM
	get_node("BG/ProgressBG/Progress").max_value = _MAX
	get_node("BG/ProgressBG/Progress").value = _CURNUM
	get_node("BG/ProgressBG/Progress/NumLabel").text = str(_CURNUM - _MINNUM) + " / " + str(_MAX - _MINNUM)
	if get_node("Ani").assigned_animation != "show":
		get_node("Ani").play("show")
	if _ISMAX:
		call_LevelMax(true)
	else:
		call_LevelMax(false)
func call_ResetGift():

	var _List = get_node("HBoxContainer").get_children()
	for _Node in _List:
		_Node.queue_free()

func call_Add_Gift():
	GameLogic.cur_Popularity_Level += 1
	GameLogic.cur_Gift += 1
	_ProcessSet()
	if GameLogic.cur_Popularity_Level >= _LEVELMAX:
		call_LevelMax(true)
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	_Add_Gift()
func call_LevelMax(_BOOL: bool):
	match _BOOL:
		false:
			$BG / ProgressBG / Progress / NumLabel.show()
			$BG / ProgressBG / Progress / Sprite / MaxAni.play("init")
		true:
			$BG / ProgressBG / Progress / NumLabel.hide()
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				var _x = SteamLogic.LevelDic
				if SteamLogic.LevelDic.SPECIALLEVEL_Int or SteamLogic.LevelDic.cur_Day >= GameLogic.Config.SceneConfig[GameLogic.cur_level].Difficult.size():
					$BG / ProgressBG / Progress / Sprite / MaxAni.play("FinalDay")
				else:
					$BG / ProgressBG / Progress / Sprite / MaxAni.play("show")
				get_node("BG/ProgressBG/Progress").value = _CurMax
				get_node("BG/ProgressBG/Progress").max_value = _CurMax
				return
			if GameLogic.SPECIALLEVEL_Int or GameLogic.cur_Day >= GameLogic.Config.SceneConfig[GameLogic.cur_level].Difficult.size():
				$BG / ProgressBG / Progress / Sprite / MaxAni.play("FinalDay")
			else:
				$BG / ProgressBG / Progress / Sprite / MaxAni.play("show")
			get_node("BG/ProgressBG/Progress").value = _CurMax
			get_node("BG/ProgressBG/Progress").max_value = _CurMax
func call_Gift_puppet(_GIFTNUM):
	GameLogic.cur_Gift = _GIFTNUM

	var _GIFT = _GIFTTSCN.instance()
	get_node("HBoxContainer").add_child(_GIFT)
func _Add_Gift():
	var _GIFT = _GIFTTSCN.instance()
	get_node("HBoxContainer").add_child(_GIFT)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Gift_puppet", [GameLogic.cur_Gift])
func _physics_process(_delta):
	if GameLogic.cur_Popularity_Level >= _LEVELMAX:
		set_physics_process(false)
		call_LevelMax(true)
		return
	if float(GameLogic.cur_Popularity) > _CurNum:
		if Target_Pop == 0:
			Target_Pop = GameLogic.cur_Popularity - _CurNum
		if Target_Pop > 0:
			_time += _delta
			if _time > 0.01:
				_time = 0

				var _NUMCHECK: int = int(Target_Pop)
				var _MinNum = get_node("BG/ProgressBG/Progress").min_value

				if Target_Pop > 50:
					_NUMCHECK = int(float(Target_Pop) / 50)

				_CurNum += _NUMCHECK
				Target_Pop -= _NUMCHECK

				get_node("BG/ProgressBG/Progress").value = _CurNum

				get_node("BG/ProgressBG/Progress/NumLabel").text = str(_CurNum - _MinNum) + " / " + str(_CurMax - _MinNum)
				if _CurNum >= _CurMax:
					call_Add_Gift()
	else:
		set_physics_process(false)
