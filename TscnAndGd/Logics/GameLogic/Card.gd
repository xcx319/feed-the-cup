extends Node

var Reward_CanUsed: Dictionary
var Cards_CanUsed: Array
var Challenge_1: Array
var Challenge_2: Array
var Challenge_3: Array

var EventArray: Array

enum RANK{
	NORMAL
	RARE
	SUPERRARE
}
enum TYPE{
	Pressure
	COMBO
}
enum PRESSURE{
	NoAddMult
	Max

}

enum COMBO{
	Skip
	SkipGetTip
	TipPlus
}
func _ready():
	if not GameLogic.is_connected("OpenStore", self, "call_Event_Open"):
		var _CON = GameLogic.connect("OpenStore", self, "call_Event_Open")
	if not GameLogic.is_connected("CloseLight", self, "call_Event_Close"):
		var _CON = GameLogic.connect("CloseLight", self, "call_Event_Close")

func call_Event_init():







	GameLogic.Challenge_1 = ""
	GameLogic.Challenge_2 = ""
	GameLogic.Challenge_3 = ""

	match GameLogic.cur_DayType:
		"升级1":
			GameLogic.Challenge_2 = "随机升级"
			return
		"升级2":
			GameLogic.Challenge_2 = "随机升级+"
			return
		"升级3":
			GameLogic.Challenge_2 = "随机升级++"
			return
		"升级":
			GameLogic.Challenge_1 = "随机升级"
			GameLogic.Challenge_2 = "随机升级+"
			GameLogic.Challenge_3 = "随机升级++"
			return
	EventArray.clear()
	var _EventKeys = GameLogic.Config.EventConfig.keys()

	for _Event in _EventKeys:

		match GameLogic.Config.EventConfig[_Event].UnlockType:
			"-1":
				EventArray.append(_Event)
			"员工":
				if is_instance_valid(GameLogic.Staff.StaffLocker_OBJ):
					EventArray.append(_Event)
			"设备":
				var _LevelMachineList = GameLogic.Config.SceneConfig[GameLogic.cur_level].Machine

				if _LevelMachineList.has(GameLogic.Config.EventConfig[_Event].UnlockValue):
					EventArray.append(_Event)

			"换饮品":

				if GameLogic.cur_NewFormulaList.size() >= 3:
					EventArray.append(_Event)
			"换小料":

				pass
			"有饮品":
				var _Num = int(GameLogic.Config.EventConfig[_Event].UnlockValue)
				if (GameLogic.cur_Menu.size() - GameLogic.cur_Extra.size()) >= _Num:
					EventArray.append(_Event)

			"有小料":
				var _Num = int(GameLogic.Config.EventConfig[_Event].UnlockValue)
				if GameLogic.cur_Extra.size() >= _Num:
					EventArray.append(_Event)
			"有代价":
				var _Num = int(GameLogic.Config.EventConfig[_Event].UnlockValue)
				if GameLogic.cur_Challenge.size() >= _Num:
					EventArray.append(_Event)
			"有奖励":
				if GameLogic.cur_Rewards.size():
					for _REWARD in GameLogic.cur_Rewards:
						if GameLogic.Config.CardConfig[_REWARD].UnlockType == "-1":
							EventArray.append(_Event)
							break
	var _Array: Array
	var TypeList: Array = []

	EventArray.shuffle()


	for _Event in EventArray:
		var _EventType = GameLogic.Config.EventConfig[_Event].Type

		if not _EventType in TypeList:
			match GameLogic.cur_DayType:

				"精英事件", "精英事件1", "精英事件2":
					if int(GameLogic.Config.EventConfig[_Event].Rank) > 1 and not _Event in ["聚餐", "聚餐+", "聚餐++"]:
						_Array.append(_Event)
						if _EventType != "随机":
							TypeList.append(_EventType)
				"事件1", "事件2", "随机":
					_Array.append(_Event)
					TypeList.append(_EventType)
				"简化", "简化1", "简化2":
					if _EventType == "简化":
						_Array.append(_Event)
				"随机", "随机1", "随机2":
					if _EventType == "随机":
						_Array.append(_Event)
				"精英随机", "精英随机1", "精英随机2":
					if _EventType == "随机" and int(GameLogic.Config.EventConfig[_Event].Rank) > 1:
						_Array.append(_Event)
				_:
					_Array.append(_Event)
					if _EventType != "随机":
						TypeList.append(_EventType)



	var _Rand_1 = GameLogic.return_randi() % _Array.size()
	if GameLogic.Challenge_1 == "":
		GameLogic.Challenge_1 = _Array[_Rand_1]
		_Array.remove(_Rand_1)
	if GameLogic.Challenge_2 == "":
		var _Rand_2 = GameLogic.return_randi() % _Array.size()
		if not GameLogic.cur_DayType in ["随机1", "精英随机1", "简化1", "事件1", "精英事件1"]:
			GameLogic.Challenge_2 = _Array[_Rand_2]
			_Array.remove(_Rand_2)
	if GameLogic.Challenge_3 == "":
		var _Rand_3 = GameLogic.return_randi() % _Array.size()
		if not GameLogic.cur_DayType in ["事件1", "事件2", "简化1", "简化2", "随机1", "随机2", "精英随机1", "精英随机2", "精英事件1", "精英事件2"]:
			GameLogic.Challenge_3 = _Array[_Rand_3]
			_Array.remove(_Rand_3)

func _new_challenge():

	for i in 3:
		var _Rank: int = 1
		var _Reward: String = "礼物"
		match GameLogic.cur_Day:
			1:
				_Rank = 1
			3, 6, 9:
				_Rank = 3
			_:
				var _Rand = GameLogic.return_randi() % 10
				match _Rand:
					0, 1, 2, 3, 4, 5:
						_Rank = 1
					6, 7, 8:
						_Rank = 2
						var _RewardRand = GameLogic.return_randi() % 10
						match _RewardRand:
							1, 2, 3, 4:
								_Reward = "随机"
							5, 6, 7:
								_Reward = "商人"
							8, 9:
								_Reward = "放假"
					9:
						_Rank = 3
		var _ChallengeList
		match _Rank:
			1:
				_ChallengeList = Challenge_1
			2:
				_ChallengeList = Challenge_2
			3:
				_ChallengeList = Challenge_3
			_:
				printerr("无Rank")
		var _Rand = GameLogic.return_randi() % _ChallengeList.size()
		match (i + 1):
			1:
				GameLogic.Reward_1 = _Reward
				GameLogic.Challenge_1 = _ChallengeList[_Rand]
			2:
				GameLogic.Reward_2 = _Reward
				GameLogic.Challenge_2 = _ChallengeList[_Rand]
			3:
				GameLogic.Reward_3 = _Reward
				GameLogic.Challenge_3 = _ChallengeList[_Rand]

func _new_challenge_old():
	for i in 3:
		var _Rank
		var _Card
		match (i + 1):
			1:
				_Card = GameLogic.Card_1
			2:
				_Card = GameLogic.Card_2
			3:
				_Card = GameLogic.Card_3
		_Rank = int(GameLogic.Config.CardConfig[_Card].Rank)
		var _ChallengeList
		match _Rank:
			1:
				_ChallengeList = Challenge_1
			2:
				_ChallengeList = Challenge_2
			3:
				_ChallengeList = Challenge_3
			_:
				_ChallengeList = Challenge_1
		_ChallengeList.shuffle()
		match (i + 1):
			1:
				GameLogic.Challenge_1 = _ChallengeList.pop_front()
			2:
				GameLogic.Challenge_2 = _ChallengeList.pop_front()
			3:
				GameLogic.Challenge_3 = _ChallengeList.pop_front()
func _new_card():
	var _CardList = GameLogic.Card.Cards_CanUsed.duplicate()

	_CardList.shuffle()

	GameLogic.Card_1 = _CardList.pop_front()
	GameLogic.Card_2 = _CardList.pop_front()
	GameLogic.Card_3 = _CardList.pop_front()

func _Card_CanUse(_Rank, _CardName):
	if _CardName:
		var _check: bool = true
		for _Reward in GameLogic.cur_Rewards:
			if GameLogic.Config.CardConfig.has(_Reward):
				if GameLogic.Config.CardConfig[_Reward].UnlockValue == _CardName:
					_check = false
					break
		if _check == true:
			if not Cards_CanUsed.has(_CardName):
				Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("无压概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "1" or _INFO.SpecialAni == "1":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("高压概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "2" or _INFO.SpecialAni == "2":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("快出概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "3" or _INFO.SpecialAni == "3":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("暴击概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "4" or _INFO.SpecialAni == "4":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("跳单概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "5" or _INFO.SpecialAni == "5":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("小费概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "6" or _INFO.SpecialAni == "6":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("单价概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "7" or _INFO.SpecialAni == "7":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("连击概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "8" or _INFO.SpecialAni == "8":
							Cards_CanUsed.append(_CardName)
				if GameLogic.cur_Rewards.has("极限概率提高"):
					if GameLogic.Config.CardConfig.has(_CardName):
						var _INFO = GameLogic.Config.CardConfig[_CardName]
						if _INFO.Rank == "9" or _INFO.SpecialAni == "9":
							Cards_CanUsed.append(_CardName)

func _Reward_CanUse(_CardName, _CHANCE: int):
	if _CardName:
		if not Reward_CanUsed.has(_CardName):
			Reward_CanUsed[_CardName] = _CHANCE

func _Challenge_CanUse(_Rank: int, _Name: String):
	match _Rank:
		1:
			Challenge_1.append(_Name)
		2:
			Challenge_2.append(_Name)
		3:
			Challenge_3.append(_Name)
func call_challenge_init():
	Challenge_1.clear()
	Challenge_2.clear()
	Challenge_3.clear()
	var _keys = GameLogic.Config.ChallengeConfig.keys()
	for i in _keys.size():
		var _Name = _keys[i]
		var _Info = GameLogic.Config.ChallengeConfig[_Name]
		var _Rank = int(_Info.Rank)
		_Challenge_CanUse(_Rank, _Name)

func call_new_card():
	call_challenge_init()
	_new_challenge()
func call_new_buy():
	Cards_CanUsed.clear()
	var CardKeys = GameLogic.Config.CardConfig.keys()
	for _CardName in CardKeys:
		if not GameLogic.cur_Rewards.has(_CardName):
			var _INFO = GameLogic.Config.CardConfig[_CardName]
			if int(_INFO.MainType) == 0:
				match _INFO.UnlockType:
					"小料":
						pass
					"升级":
						if GameLogic.cur_Rewards.has(_INFO.UnlockValue):
							_Card_CanUse(_INFO.Rank, _CardName)
					"设备":

						var _LEVELNAME = GameLogic.cur_level
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							_LEVELNAME = SteamLogic.LOBBY_levelData.cur_level
						var _LevelMachineList = GameLogic.Config.SceneConfig[_LEVELNAME].Machine
						if _LevelMachineList.has(_INFO.UnlockValue):
							_Card_CanUse(_INFO.Rank, _CardName)
					"关闭", "EGG":
						pass
					_:
						_Card_CanUse(_INFO.Rank, _CardName)
func call_new_Reward():
	Reward_CanUsed.clear()
	var CardKeys = GameLogic.Config.CardConfig.keys()
	var _TYPE_1_NUM: int = 0
	var _TYPE_2_NUM: int = 0
	var _TYPE_3_NUM: int = 0
	var _TYPE_4_NUM: int = 0
	var _TYPE_5_NUM: int = 0
	var _TYPE_6_NUM: int = 0
	var _TYPE_7_NUM: int = 0
	var _TYPE_8_NUM: int = 0
	var _TYPE_9_NUM: int = 0
	for _NAME in GameLogic.cur_Rewards:
		var _INFO = GameLogic.Config.CardConfig[_NAME]
		var _RANK: String = _INFO.Rank
		var _SPECIAL: String = _INFO.SpecialAni
		var _BaseNUM: int = 1
		if _INFO.UnlockType == "升级": _BaseNUM = 3
		match _RANK:
			"1":
				_TYPE_1_NUM += _BaseNUM
			"2":
				_TYPE_2_NUM += _BaseNUM
			"3":
				_TYPE_3_NUM += _BaseNUM
			"4":
				_TYPE_4_NUM += _BaseNUM
			"5":
				_TYPE_5_NUM += _BaseNUM
			"6":
				_TYPE_6_NUM += _BaseNUM
			"7":
				_TYPE_7_NUM += _BaseNUM
			"8":
				_TYPE_8_NUM += _BaseNUM
			"9":
				_TYPE_9_NUM += _BaseNUM


		if _INFO.UnlockType == "条件":
			if _RANK != _SPECIAL:
				match _SPECIAL:
					"1":
						_TYPE_1_NUM += _BaseNUM
					"2":
						_TYPE_2_NUM += _BaseNUM
					"3":
						_TYPE_3_NUM += _BaseNUM
					"4":
						_TYPE_4_NUM += _BaseNUM
					"5":
						_TYPE_5_NUM += _BaseNUM
					"6":
						_TYPE_6_NUM += _BaseNUM
					"7":
						_TYPE_7_NUM += _BaseNUM
					"8":
						_TYPE_8_NUM += _BaseNUM
					"9":
						_TYPE_9_NUM += _BaseNUM
	for _CardName in CardKeys:
		var _INFO = GameLogic.Config.CardConfig[_CardName]
		var _PlusName = _CardName + "+"
		if not GameLogic.cur_Rewards.has(_CardName) and not GameLogic.cur_Rewards.has(_PlusName):
			if int(_INFO.MainType) == 1:
				if GameLogic.cur_level == "新手引导第一关":
					if _CardName in ["垃圾回收", "垃圾回收+"]:

						pass
					else:
						match _INFO.UnlockType:
							"-1":
								_Reward_CanUse(_CardName, 2)
							"升级":
								if GameLogic.cur_Rewards.has(_INFO.UnlockValue):
									_Reward_CanUse(_CardName, 2)
				elif GameLogic.DEMO_bool:

					match _INFO.UnlockType:
						"-1":
							_Reward_CanUse(_CardName, 2)
						"升级":
							if GameLogic.cur_Rewards.has(_INFO.UnlockValue):
								_Reward_CanUse(_CardName, 2)
				else:
					match _INFO.UnlockType:
						"条件":
							var _STR: String = _INFO.UnlockValue
							var _TYPE1 = _INFO.Rank
							var _TYPE2 = _INFO.SpecialAni

							var _TYPE1_NUM: int = 0
							var _TYPE2_NUM: int = 0
							match _TYPE1:
								"1":
									_TYPE1_NUM = _TYPE_1_NUM
								"2":
									_TYPE1_NUM = _TYPE_2_NUM
								"3":
									_TYPE1_NUM = _TYPE_3_NUM
								"4":
									_TYPE1_NUM = _TYPE_4_NUM
								"5":
									_TYPE1_NUM = _TYPE_5_NUM
								"6":
									_TYPE1_NUM = _TYPE_6_NUM
								"7":
									_TYPE1_NUM = _TYPE_7_NUM
								"8":
									_TYPE1_NUM = _TYPE_8_NUM
								"9":
									_TYPE1_NUM = _TYPE_9_NUM
							match _TYPE2:
								"1":
									_TYPE2_NUM = _TYPE_1_NUM
								"2":
									_TYPE2_NUM = _TYPE_2_NUM
								"3":
									_TYPE2_NUM = _TYPE_3_NUM
								"4":
									_TYPE2_NUM = _TYPE_4_NUM
								"5":
									_TYPE2_NUM = _TYPE_5_NUM
								"6":
									_TYPE2_NUM = _TYPE_6_NUM
								"7":
									_TYPE2_NUM = _TYPE_7_NUM
								"8":
									_TYPE2_NUM = _TYPE_8_NUM
								"9":
									_TYPE2_NUM = _TYPE_9_NUM
							if _TYPE1 == _TYPE2:
								if _TYPE1_NUM > 1:
									var _NUM = _TYPE1_NUM
									if _NUM >= 4:
										_NUM = 4
									_Reward_CanUse(_CardName, _NUM)
							elif _TYPE1_NUM > 0 and _TYPE2_NUM > 0:
								var _NUM = _TYPE1_NUM + _TYPE2_NUM
								if _NUM >= 4:
									_NUM = 4
								_Reward_CanUse(_CardName, _NUM)
						"升级":
							if GameLogic.cur_Rewards.has(_INFO.UnlockValue):
								_Reward_CanUse(_CardName, 2)
						"设备":
							var _LevelMachineList = GameLogic.Config.SceneConfig[GameLogic.cur_level].Machine
							if _LevelMachineList.has(_INFO.UnlockValue):
								_Reward_CanUse(_CardName, 2)
						"关闭", "EGG":
							pass
						"有小料":
							if GameLogic.cur_Extra.size():
								_Reward_CanUse(_CardName, 2)
						_:
							_Reward_CanUse(_CardName, 2)
func call_new_card_old():


	Cards_CanUsed.clear()
	var _Card_Keys = GameLogic.Config.CardConfig.keys()
	var _SceneConfig = GameLogic.Config.SceneConfig[GameLogic.cur_level]
	for i in _Card_Keys.size():
		var _Name = _Card_Keys[i]
		var _Info = GameLogic.Config.CardConfig[_Name]
		match _Info.UnlockType:
			"关闭":
				pass
			"设备":

				if _SceneConfig.Machine.has(_Info.UnlockValue):
					_Card_CanUse(_Info.Rank, _Name)
			"关卡":
				if GameLogic.Level_Data.has(_Info.UnlockValue):
					_Card_CanUse(_Info.Rank, _Name)
			"升级":
				if GameLogic.cur_Rewards.has(_Info.UnlockValue):
					_Card_CanUse(_Info.Rank, _Name)
			_:
				if not GameLogic.cur_Rewards.has(_Name):
					var _UpdateName = str(_Name) + "+"
					if not GameLogic.cur_Rewards.has(_UpdateName):
						_Card_CanUse(_Info.Rank, _Name)
	call_challenge_init()
	_new_card()
	_new_challenge()

func call_Event_Open():
	match GameLogic.cur_Event:
		"充分休息":
			GameLogic.call_Info(1, "充分休息")
			GameLogic.call_Pressure_Mult( - 25)
		"充分休息+":
			GameLogic.call_Info(1, "充分休息+")
			GameLogic.call_Pressure_Mult( - 50)
		"充分休息++":
			GameLogic.call_Info(1, "充分休息++")
			GameLogic.call_Pressure_Mult( - 100)
func call_Event_Close():
	match GameLogic.cur_Event:
		"资金补助":
			GameLogic.call_Info(1, "资金补助")

		"资金补助+":
			GameLogic.call_Info(1, "资金补助+")

		"资金补助++":
			GameLogic.call_Info(1, "资金补助++")

		"聚餐":
			GameLogic.Cost_Fine -= 50

			GameLogic.emit_signal("Pressure_Mult", - 25)
		"聚餐+":
			GameLogic.Cost_Fine -= 50

			GameLogic.emit_signal("Pressure_Mult", - 50)
		"聚餐++":
			GameLogic.Cost_Fine -= 50

			GameLogic.emit_signal("Pressure_Mult", - 100)
	if GameLogic.cur_Rewards.has("休息"):
		GameLogic.call_Info(1, "休息")
		GameLogic.emit_signal("Pressure_Mult", - 10)
	elif GameLogic.cur_Rewards.has("休息+"):
		GameLogic.call_Info(1, "休息+")
		GameLogic.emit_signal("Pressure_Mult", - 20)
