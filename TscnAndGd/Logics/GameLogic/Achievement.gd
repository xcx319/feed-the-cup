extends Node
var EquipMax: int = 0
var cur_EquipList: Array
var AchievementReward_Array: Array
var Achievement_Array: Array
var CanUpdate: int = 1
func call_Delete_Wrong():

	var _HomeUpdate = str(GameLogic.Save.gameData.HomeUpdate)
	var _CHECKARRAY: Array = GameLogic.Config.HomeConfig[_HomeUpdate].FurnitureList

	var _NOUSEDLIST: Array
	var _NUM = GameLogic.Save.gameData.HomeDevList.size()
	for _i in _NUM:
		var _FUR = GameLogic.Save.gameData.HomeDevList[_i]
		if not _CHECKARRAY.has(_FUR):
			_NOUSEDLIST.append(_FUR)
	for _FUR in _NOUSEDLIST:
		GameLogic.Save.gameData.HomeDevList.erase(_FUR)


func call_AchievementReward_Add(_NAME):
	if Achievement_Array.has(_NAME):
		if not AchievementReward_Array.has(_NAME):
			AchievementReward_Array.append(_NAME)
			var _REWARD = int(GameLogic.Config.AchievementConfig[_NAME].Rewards)
			if _REWARD > 0:
				GameLogic.call_MoneyHomeChange(_REWARD, GameLogic.HomeMoneyKey)
			if _NAME == "钞票2":
				if GameLogic.Save.gameData.HomeDevList.has("保险柜"):

					printerr("非法家具 保险柜 没收！")

	call_Logic_Check()
func call_Logic_Check():

	CanUpdate = 0
	if AchievementReward_Array.has("通关游乐园"):
		CanUpdate = 8
	elif AchievementReward_Array.has("通关古街"):
		CanUpdate = 7
	elif AchievementReward_Array.has("通关运动场"):
		CanUpdate = 6
	elif AchievementReward_Array.has("通关网红公园"):
		CanUpdate = 5
	elif AchievementReward_Array.has("通关办公楼"):
		CanUpdate = 4
	elif AchievementReward_Array.has("通关美食街"):
		CanUpdate = 3
	elif AchievementReward_Array.has("通关居民区"):
		CanUpdate = 2
	elif AchievementReward_Array.has("购买镜子"):
		CanUpdate = 1
	if not GameLogic.Save.gameData.has("HomeUpdate"):

		return
	if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
		var _CanBuyList: Array = GameLogic.Config.HomeConfig["1"].FurnitureList
		var _BuyList: Array
		for _Furniture in GameLogic.Save.gameData.HomeDevList:
			_BuyList.append(_Furniture)
		for _Furniture in _BuyList:
			if not _CanBuyList.has(_Furniture):
				if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
					GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
		GameLogic.Save.gameData.HomeUpdate = 1

	if AchievementReward_Array.has("钞票2"):
		var _x = GameLogic.return_FullHMK()
		pass

	else:
		if GameLogic.Save.gameData.HomeDevList.has("保险柜"):

			printerr("非法家具2 保险柜 没收！")

	for _Ach in AchievementReward_Array:


		if _Ach == "冰糖水关卡":
			if not GameLogic.cur_Player_Unlock.has(1):
				GameLogic.cur_Player_Unlock.append(1)
		if _Ach == "卖出饮品1":
			if not GameLogic.cur_Player_Unlock.has(2):
				GameLogic.cur_Player_Unlock.append(2)
		if _Ach == "完美收拾1":
			if not GameLogic.cur_Player_Unlock.has(3):
				GameLogic.cur_Player_Unlock.append(3)
		if _Ach == "联机1":
			if not GameLogic.cur_Player_Unlock.has(4):
				GameLogic.cur_Player_Unlock.append(4)
		if _Ach == "拖地1":
			if not GameLogic.cur_Player_Unlock.has(5):
				GameLogic.cur_Player_Unlock.append(5)
		if _Ach == "踩扁虫虫":
			if not GameLogic.cur_Player_Unlock.has(6):
				GameLogic.cur_Player_Unlock.append(6)
		if _Ach == "捡垃圾":
			if not GameLogic.cur_Player_Unlock.has(7):
				GameLogic.cur_Player_Unlock.append(7)

		if _Ach == "通关游乐园":
			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["7"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 7
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()
		if _Ach == "通关古街":
			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["6"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 6
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()
		if _Ach == "通关运动场":
			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["5"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 5
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()
		if _Ach == "通关网红公园":
			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["4"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 4
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()

		if _Ach == "通关办公楼":
			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["3"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 3
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()

		if _Ach == "通关美食街":
			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["2"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 2
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()

		if _Ach == "通关居民区":

			if GameLogic.Save.gameData.HomeUpdate > CanUpdate:
				var _CanBuyList: Array = GameLogic.Config.HomeConfig["1"].FurnitureList
				var _BuyList: Array
				for _Furniture in GameLogic.Save.gameData.HomeDevList:
					_BuyList.append(_Furniture)
				for _Furniture in _BuyList:
					if not _CanBuyList.has(_Furniture):
						if GameLogic.Save.gameData.HomeDevList.has(_Furniture):
							GameLogic.Save.gameData.HomeDevList.erase(_Furniture)
				GameLogic.Save.gameData.HomeUpdate = 1
				if not SteamLogic.IsMultiplay:
					GameLogic.LoadingUI.call_HomeLoad()

func _Save():
	for _Ach in AchievementReward_Array:
		if not GameLogic.Config.AchievementConfig.has(_Ach):
			AchievementReward_Array.erase(_Ach)

	for _Ach in Achievement_Array:
		if not GameLogic.Config.AchievementConfig.has(_Ach):
			Achievement_Array.erase(_Ach)

	GameLogic.Save.gameData["cur_EquipList"] = cur_EquipList
	GameLogic.Save.gameData["AchievementReward_Array"] = AchievementReward_Array
	GameLogic.Save.gameData["Achievement_Array"] = Achievement_Array

func _Load():

	if not GameLogic.Save.gameData.has("cur_EquipList"):
		GameLogic.Save.gameData["cur_EquipList"] = cur_EquipList
	else:
		cur_EquipList = GameLogic.Save.gameData["cur_EquipList"]
	if not GameLogic.Save.gameData.has("AchievementReward_Array"):
		GameLogic.Save.gameData["AchievementReward_Array"] = AchievementReward_Array
	else:
		AchievementReward_Array = GameLogic.Save.gameData["AchievementReward_Array"]
	if not GameLogic.Save.gameData.has("Achievement_Array"):
		GameLogic.Save.gameData["Achievement_Array"] = Achievement_Array
	else:
		Achievement_Array = GameLogic.Save.gameData["Achievement_Array"]
	GameLogic.cur_Player_Unlock = [0]
	GameLogic.Achievement.call_Logic_Check()
	var _ACHKEY = GameLogic.Config.DevilBonusConfig.keys()
	for _ACH in GameLogic.Achievement.cur_EquipList:
		if not _ACH in _ACHKEY:
			GameLogic.Achievement.cur_EquipList.erase(_ACH)
	var _HOMEID = int(GameLogic.Save.gameData["HomeUpdate"])
	if _HOMEID in [1, 2, 3]:
		GameLogic.Achievement.EquipMax = 1
	elif _HOMEID in [4, 5]:
		GameLogic.Achievement.EquipMax = 2
	elif _HOMEID in [6, 7]:
		GameLogic.Achievement.EquipMax = 3
	elif _HOMEID in [8, 9]:
		GameLogic.Achievement.EquipMax = 4
	var _CurEQUIPNUM: int = GameLogic.Achievement.cur_EquipList.size()
	if _CurEQUIPNUM > GameLogic.Achievement.EquipMax:
		var _DELNUM: int = _CurEQUIPNUM - GameLogic.Achievement.EquipMax
		for _i in _DELNUM:
			var _DELACH = GameLogic.Achievement.cur_EquipList.pop_back()

	call_Delete_Wrong()

func call_Achievement_Check():
	Achievement_Array.clear()
	var _Ach_Keys = GameLogic.Config.AchievementConfig.keys()

	for _AchName in _Ach_Keys:
		var _return = return_Achievement_Logic(_AchName)
		if _return:
			if not Achievement_Array.has(_AchName):
				Achievement_Array.append(_AchName)

	_Save()
func call_Achievement_Logic():

	if cur_EquipList.has("夜间倒垃圾"):
		var _StaffID = 5
		var _INFO = GameLogic.Config.StaffConfig[str(_StaffID)]

		if not GameLogic.cur_Staff.has("员工-零时垃圾工"):
			GameLogic.cur_Staff["员工-零时垃圾工"] = {
			"cur_Pressure": 0,
			"AvatarID": _StaffID,
			"AvatarType": GameLogic.return_randi() % 2 + 2,
			"SkillList": ["技能-倒垃圾临时工", "技能-搬运力", "技能-加班狂"],

			"ReactionTime": _INFO.ReactionTime,
			"DayActionDic": {},
			"DailyWage": 1,
			"MoveSpeed": _INFO.MoveSpeed,
			"ActionMax": 0,
			"HomePoint": Vector2.ZERO,
			"CanTeach": false,
			}
		print("生成垃圾工")

	if cur_EquipList.has("首日搬运工") and GameLogic.cur_Day == 1:
		var _StaffID = 0
		var _INFO = GameLogic.Config.StaffConfig[str(_StaffID)]
		if is_instance_valid(GameLogic.Staff.StaffLocker_OBJ):
			if not GameLogic.cur_Staff.has("员工-临时搬运工"):
				GameLogic.cur_Staff["员工-临时搬运工"] = {
				"cur_Pressure": 0,
				"AvatarID": _StaffID,
				"AvatarType": GameLogic.return_randi() % 2 + 2,
				"SkillList": ["技能-早到", "技能-进货整理", "技能-地面整理"],

				"ReactionTime": _INFO.ReactionTime,
				"DayActionDic": {},
				"DailyWage": 5,
				"MoveSpeed": _INFO.MoveSpeed,
				"ActionMax": 0,
				"HomePoint": Vector2.ZERO,
				"CanTeach": false,
				}

	elif cur_EquipList.has("首日搬运工") and GameLogic.cur_Day > 1:
		if GameLogic.cur_Staff.has("员工-临时搬运工"):
			var _return = GameLogic.cur_Staff.erase("员工-临时搬运工")

	var _startMoney: int = 0
	if GameLogic.cur_Day == 1:
		if not GameLogic.SPECIALLEVEL_Int:
			if GameLogic.Save.gameData.HomeDevList.has("粉色窗帘"):
				_startMoney += 50
			if GameLogic.Save.gameData.HomeDevList.has("蓝色窗帘"):
				_startMoney += 50
			if GameLogic.Save.gameData.HomeDevList.has("浴帘"):
				_startMoney += 50
			if GameLogic.Save.gameData.HomeDevList.has("百叶窗"):
				_startMoney += 50
			if GameLogic.Save.gameData.HomeDevList.has("遮阳网"):
				_startMoney += 50
			if cur_EquipList.has("初始杯币"):

				_startMoney += 300
		if cur_EquipList.has("初始杯币"):
			_startMoney += 300
		if _startMoney != 0:
			GameLogic.call_MoneyChange(_startMoney, GameLogic.HomeMoneyKey)
func return_Achievement_Value(_ACHTYPE: String):
	if _ACHTYPE in ["捡垃圾"]: return GameLogic.Save.statisticsData["Count_CleanTrash"]
	if _ACHTYPE in ["虫虫"]: return GameLogic.Save.statisticsData["Count_KillBugs"]
	if _ACHTYPE in ["购买镜子"]:
		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has("镜子"):
				return 1
			else:
				return 0
		else:
			return 0

	if _ACHTYPE in ["关卡"]: return GameLogic.Level_Data.size()
	if _ACHTYPE in ["展示柜"]: return GameLogic.Save.statisticsData["HasEquipReward"]

	if _ACHTYPE in ["难度", "难度1", "难度2", "难度3"]:
		var _KEYS = GameLogic.Level_Data.keys()
		var _LEVELKEYS = GameLogic.Config.SceneConfig.keys()
		var _DEVILCOUNT: int = 0
		for _NAME in _KEYS:
			if _NAME in _LEVELKEYS:
				_DEVILCOUNT += int(GameLogic.Level_Data[_NAME].cur_Devil) + 1
		return _DEVILCOUNT


	if _ACHTYPE in ["乱入"]: return GameLogic.Save.statisticsData["Count_NetVictories"]

	if _ACHTYPE in ["钞票"]: return GameLogic.Save.statisticsData["Count_HomeMoney"]

	if _ACHTYPE in ["杯币"]: return GameLogic.Save.statisticsData["Count_Money"]

	if _ACHTYPE in ["小费"]: return GameLogic.Save.statisticsData["Count_Tip"]

	if _ACHTYPE in ["杯币花费"]: return GameLogic.Save.statisticsData["Count_MoneyCost"]

	if _ACHTYPE in ["设备购买"]: return GameLogic.Save.statisticsData["Count_BuyUpdate"]

	if _ACHTYPE in ["拆纸箱"]: return GameLogic.Save.statisticsData["Count_DelBox"]

	if _ACHTYPE in ["开礼物"]: return GameLogic.Save.statisticsData["Count_OpenGift"]

	if _ACHTYPE in ["暴击次数"]: return GameLogic.Save.statisticsData["Count_Cri"]

	if _ACHTYPE in ["完美收拾"]: return GameLogic.Save.statisticsData["Count_perfectEndDay"]

	if _ACHTYPE in ["配方掌握"]: return GameLogic.Save.statisticsData["Array_UnlockMenu"].size()

	if _ACHTYPE in ["过关次数"]: return GameLogic.Save.statisticsData["Count_Victories"]

	if _ACHTYPE in ["卖出饮品"]: return GameLogic.Save.statisticsData["Count_SellCup"]

	if _ACHTYPE in ["经营总天数"]: return GameLogic.Save.statisticsData["Count_Day"]

	if _ACHTYPE in ["完美出杯"]: return GameLogic.Save.statisticsData["Count_PerfectSell"]
	if _ACHTYPE in ["救人"]: return GameLogic.Save.statisticsData["Count_SaveFriend"]
	if _ACHTYPE in ["连击数"]: return GameLogic.Save.statisticsData["Max_Combo"]
	if _ACHTYPE in ["今日杯币"]: return GameLogic.Save.statisticsData["Count_NoCupCoin"]
	if _ACHTYPE in ["扩建"]: return GameLogic.Save.gameData["HomeUpdate"]
	match _ACHTYPE:
		"初出茅庐":
			return GameLogic.Level_Data.size()
		"居民区制霸":
			return GameLogic.Level_Data.size()
		"设备升级":
			return GameLogic.Save.statisticsData["Count_BuyUpdate"]
		"赚取杯币":
			return GameLogic.Save.statisticsData["Count_Money"]
		"花费杯币":
			return GameLogic.Save.statisticsData["Count_MoneyCost"]
		"拆纸箱":
			return GameLogic.Save.statisticsData["Count_DelBox"]
		"开礼物":
			return GameLogic.Save.statisticsData["Count_OpenGift"]
		"暴击次数":
			return GameLogic.Save.statisticsData["Count_Cri"]
		"双人合作":
			return GameLogic.Save.statisticsData["Count_2P"]
		"废物利用", "扔垃圾":
			return GameLogic.Save.statisticsData["Count_TrashBag"]
		"拖地":
			return GameLogic.Save.statisticsData["CleanNum"]
		"垃圾清理":
			return GameLogic.Save.statisticsData["Count_TrashBin"]
		"加冰达人":
			return GameLogic.Save.statisticsData["Count_Ice"]
		"加糖达人":
			return GameLogic.Save.statisticsData["Count_Sugar"]
		"销售千杯":
			return GameLogic.Save.statisticsData["Count_SellCup"]
		"夜班达人":
			return GameLogic.Save.statisticsData["Count_perfectEndDay"]
		"极限连击":
			return GameLogic.Save.statisticsData["Max_Combo"]
		"抓到小偷":
			return GameLogic.Save.statisticsData["Count_CatchThief"]
		"收礼狂魔":
			return GameLogic.Save.statisticsData["Max_OpenGift"]
		"通关狂魔":
			return GameLogic.Save.statisticsData["Count_Victories"]
		"角色全解锁":
			return GameLogic.Save.statisticsData["Array_UnlockPlayer"].size()
		"配方掌握":
			return GameLogic.Save.statisticsData["Array_UnlockMenu"].size()
		"小费成堆":
			return GameLogic.Save.statisticsData["Count_Tip"]
		"钞票成堆":
			return GameLogic.Save.statisticsData["Count_HomeMoney"]
		"挥金如土":
			return GameLogic.Save.statisticsData["Count_HomeMoneyCost"]
		"经营持久":
			return GameLogic.Save.statisticsData["Count_Day"]
		"完美出杯":
			return GameLogic.Save.statisticsData["Count_PerfectSell"]
		"高额利润":
			return GameLogic.Save.statisticsData["Max_FinishMoney"]
		"五星饮品店":
			return GameLogic.Save.statisticsData["Count_AllStarFinish"]
func return_Achievement_Logic(_AchName: String):
	if _AchName in ["购买镜子"]:
		if not Achievement_Array.has(_AchName):
			if GameLogic.Save.gameData.has("HomeDevList"):
				if GameLogic.Save.gameData.HomeDevList.has("镜子"):
					return true

	var Level_List: Array = ["教学关卡", "冰糖水关卡", "通关居民区", "通关美食街", "通关办公楼", "通关网红公园", "通关运动场", "通关古街", "通关游乐园"]
	if _AchName in Level_List:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]

			if GameLogic.Level_Data.size() >= int(_INFO.Num):
				return true

	if _AchName in ["钞票1", "钞票2", "钞票3"]:
		if not Achievement_Array.has(_AchName):
				var _INFO = GameLogic.Config.AchievementConfig[_AchName]
				if GameLogic.Save.statisticsData["Count_HomeMoney"] >= int(_INFO.Num):
					return true


	if _AchName in ["杯币1", "杯币2", "杯币3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_Money"] >= int(_INFO.Num):
				return true


	if _AchName in ["小费1", "小费2", "小费3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_Tip"] >= int(_INFO.Num):
				return true


	if _AchName in ["杯币花费1", "杯币花费2", "杯币花费3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_MoneyCost"] >= int(_INFO.Num):
				return true


	if _AchName in ["设备购买1", "设备购买2", "设备购买3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_BuyUpdate"] >= int(_INFO.Num):
				return true


	if _AchName in ["拆纸箱1", "拆纸箱2", "拆纸箱3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_DelBox"] >= int(_INFO.Num):
				return true


	if _AchName in ["开礼物1", "开礼物2", "开礼物3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_OpenGift"] >= int(_INFO.Num):
				return true


	if _AchName in ["暴击次数1", "暴击次数2", "暴击次数3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_Cri"] >= int(_INFO.Num):
				return true




	if _AchName in ["完美收拾1", "完美收拾2", "完美收拾3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_perfectEndDay"] >= int(_INFO.Num):
				return true
		else:
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_perfectEndDay"] >= int(_INFO.Num):
				return true


	if _AchName in ["配方掌握1", "配方掌握2", "配方掌握3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Array_UnlockMenu"].size() >= int(_INFO.Num):
				return true


	if _AchName in ["过关次数1", "过关次数2", "过关次数3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_Victories"] >= int(_INFO.Num):
				return true


	if _AchName in ["卖出饮品1", "卖出饮品2", "卖出饮品3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_SellCup"] >= int(_INFO.Num):
				return true


	if _AchName in ["经营总天数1", "经营总天数2", "经营总天数3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_Day"] >= int(_INFO.Num):
				return true


	if _AchName in ["完美出杯1", "完美出杯2", "完美出杯3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_PerfectSell"] >= int(_INFO.Num):
				return true

	if _AchName in ["联机1", "联机2", "联机3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_NetVictories"] >= int(_INFO.Num):
				return true

	if _AchName in ["扔垃圾1", "扔垃圾2", "扔垃圾3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["Count_TrashBag"] >= int(_INFO.Num):
				return true
	if _AchName in ["踩扁虫虫"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]

			if GameLogic.Save.statisticsData["Count_KillBugs"] >= int(_INFO.Num):
				return true

	if _AchName in ["捡垃圾"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]

			if not GameLogic.Save.statisticsData.has("Count_CleanTrash"):
				GameLogic.Save.statisticsData["Count_CleanTrash"] = 0
			if GameLogic.Save.statisticsData["Count_CleanTrash"] >= int(_INFO.Num):
				return true
	if _AchName in ["拖地1", "拖地2", "拖地3"]:
		if not Achievement_Array.has(_AchName):
			var _INFO = GameLogic.Config.AchievementConfig[_AchName]
			if GameLogic.Save.statisticsData["CleanNum"] >= int(_INFO.Num):
				return true

func call_SteamAchievement():
	if SteamLogic.STEAM_BOOL:
		var IS_OWNED: bool = Steam.isSubscribed()
		if not IS_OWNED:
			return
		call_StatUp()

		var _STEAM_ACHIEVEMENT: Dictionary = {
			"TUTORIAL": false,
			"LEVEL_1": false,
			"LEVEL_2": false,
			"LEVEL_3": false,
			"LEVEL_4": false,
			"LEVEL_5": false,
			"LEVEL_6": false,
			"LEVEL_7": false,
			"LEVEL_8": false,
			"HOUSE_1": false,
			"HOUSE_2": false,
			"HOUSE_3": false,
			"HOUSE_4": false,
			"HOUSE_5": false,
			"HOUSE_6": false,
			"HOUSE_7": false,
			"HOUSE_8": false,
			"AVATAR_1": false,
			"AVATAR_2": false,
			"AVATAR_3": false,
			"AVATAR_4": false,
			"AVATAR_5": false,
			"AVATAR_6": false,
			"AVATAR_7": false,
			"CUPCOIN_0": false,
			"SHOWCASE_1": false,
			"SAVE_1": false,
			"COMBO_99": false,
			"MULTIPLAY_1": false,
			"HIGHINCOME_3": false,
			"FURNITURE_1": false,
			"FURNITURE_2": false,
			"FURNITURE_3": false,
			"FURNITURE_4": false,
			"FURNITURE_5": false,
			"FURNITURE_6": false,
			"FURNITURE_7": false,
			"MANAGER_1": false,
			"MANAGER_2": false,
			"MANAGER_3": false,
			"MANAGER_4": false,
			"MANAGER_5": false,
			"MANAGER_6": false,
			"MANAGER_7": false,
			"MANAGER_8": false,
			"UNPACKING_2": false,
			"OPENGIFT_1": false,
			"REOPEN_1": false,
			"CHALLENGE_1": false,
			"CHALLENGE_2": false,
			"CHALLENGE_3": false,
			"TRASH_1": false,
			"PEFRECTSHIFT_1": false,
			"CUPCOIN_1": false,
			"CUPCOIN_2": false,
			"TIPS_1": false,
			"TIPS_2": false,
			"UPGRADE_1": false,
			"UPGRADE_2": false,
			"CRITICAL_1": false,
			"CRITICAL_2": false,
			"DIFFERENT_2": false,
			"COMPLETE_2": false,
			"DAY_1": false,
			"DAY_2": false,
			"DAY_3": false,
			"PERFECT_3": false,
			"TRASHIN_1": false,
			"ADDICE_1": false,
			"ADDSUGAR_1": false,
			"TOTALSELL_1": false,
			"TOTALORDER_1": false, }
		var _ACHKEYS = _STEAM_ACHIEVEMENT.keys()
		for _ACH in _ACHKEYS:
			get_achievement(_ACH, _STEAM_ACHIEVEMENT)


func get_achievement(value: String, _DIC: Dictionary) -> void :

	var this_achievement: Dictionary = Steam.getAchievement(value)
	if this_achievement["ret"]:
		if this_achievement["achieved"]:
			if _DIC.has(value):
				_DIC[value] = true
		else:
			if _DIC.has(value):
				_DIC[value] = false
	else:
		if _DIC.has(value):
			_DIC[value] = false

	var _LEVEL_KEYS = GameLogic.Level_Data.keys()
	if this_achievement["ret"] and not this_achievement["achieved"]:
		match value:
			"TUTORIAL":
				if "新手引导第一关" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_1":
				if "新手引导第一关" in _LEVEL_KEYS and "社区店1" in _LEVEL_KEYS and "社区店2" in _LEVEL_KEYS and "社区店3" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_2":
				if "美食街1" in _LEVEL_KEYS and "美食街2" in _LEVEL_KEYS and "美食街3" in _LEVEL_KEYS and "美食街4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_3":
				if "写字楼1" in _LEVEL_KEYS and "写字楼2" in _LEVEL_KEYS and "写字楼3" in _LEVEL_KEYS and "写字楼4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_4":
				if "公园1" in _LEVEL_KEYS and "公园2" in _LEVEL_KEYS and "公园3" in _LEVEL_KEYS and "公园4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_5":
				if "体育场1" in _LEVEL_KEYS and "体育场2" in _LEVEL_KEYS and "体育场3" in _LEVEL_KEYS and "体育场4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_6":
				if "古街1" in _LEVEL_KEYS and "古街2" in _LEVEL_KEYS and "古街3" in _LEVEL_KEYS and "古街4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_7":
				if "游乐园1" in _LEVEL_KEYS and "游乐园2" in _LEVEL_KEYS and "游乐园3" in _LEVEL_KEYS and "游乐园4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"LEVEL_8":
				if "酒吧1" in _LEVEL_KEYS and "酒吧2" in _LEVEL_KEYS and "酒吧3" in _LEVEL_KEYS and "酒吧4" in _LEVEL_KEYS:
					call_SetAchievement(value)
			"HOUSE_1":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 1:
						call_SetAchievement(value)
			"HOUSE_2":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 2:
						call_SetAchievement(value)
			"HOUSE_3":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 3:
						call_SetAchievement(value)
			"HOUSE_4":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 4:
						call_SetAchievement(value)
			"HOUSE_5":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 5:
						call_SetAchievement(value)
			"HOUSE_6":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 6:
						call_SetAchievement(value)
			"HOUSE_7":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 7:
						call_SetAchievement(value)
			"HOUSE_8":
				if GameLogic.Save.gameData.has("HomeUpdate"):
					if GameLogic.Save.gameData["HomeUpdate"] >= 8:
						call_SetAchievement(value)
			"AVATAR_1":
				if AchievementReward_Array.has("冰糖水关卡"):
					call_SetAchievement(value)
			"AVATAR_2":
				if AchievementReward_Array.has("卖出饮品1"):
					call_SetAchievement(value)
			"AVATAR_3":
				if AchievementReward_Array.has("联机1"):
					call_SetAchievement(value)
			"AVATAR_4":
				if AchievementReward_Array.has("完美收拾1"):
					call_SetAchievement(value)
			"AVATAR_5":
				if AchievementReward_Array.has("拖地1"):
					call_SetAchievement(value)
			"AVATAR_6":
				if AchievementReward_Array.has("踩扁虫虫"):
					call_SetAchievement(value)
			"AVATAR_7":
				if AchievementReward_Array.has("捡垃圾"):
					call_SetAchievement(value)
			"FURNITURE_1":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 1:
						var _LIST = GameLogic.Config.HomeConfig["1"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"FURNITURE_2":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 2:
						var _LIST = GameLogic.Config.HomeConfig["2"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"FURNITURE_3":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 3:
						var _LIST = GameLogic.Config.HomeConfig["3"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"FURNITURE_4":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 4:
						var _LIST = GameLogic.Config.HomeConfig["4"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"FURNITURE_5":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 5:
						var _LIST = GameLogic.Config.HomeConfig["5"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"FURNITURE_6":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 6:
						var _LIST = GameLogic.Config.HomeConfig["6"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"FURNITURE_7":
				if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
					var _Num = int(SteamLogic.LOBBY_gameData["HomeUpdate"])
					if _Num >= 7:
						var _LIST = GameLogic.Config.HomeConfig["7"].FurnitureList
						var _CHECK: bool = true
						for _FURNITURENAME in _LIST:
							if not GameLogic.Save.gameData.HomeDevList.has(_FURNITURENAME):
								_CHECK = false
								break
						if _CHECK:
							call_SetAchievement(value)
			"MANAGER_1":
				var _INFO = GameLogic.Save.statisticsData["Character"][0]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_2":
				var _INFO = GameLogic.Save.statisticsData["Character"][1]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_3":
				var _INFO = GameLogic.Save.statisticsData["Character"][2]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_5":
				var _INFO = GameLogic.Save.statisticsData["Character"][3]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_4":
				var _INFO = GameLogic.Save.statisticsData["Character"][4]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_6":
				var _INFO = GameLogic.Save.statisticsData["Character"][5]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_7":
				var _INFO = GameLogic.Save.statisticsData["Character"][6]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"MANAGER_8":
				var _INFO = GameLogic.Save.statisticsData["Character"][7]
				var _TITLELEVEL: int = 0
				for i in GameLogic.Staff.TITLEARRAY.size():
					if _INFO.EXP < GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i
						break
					if _INFO.EXP == GameLogic.Staff.TITLEARRAY[i]:
						_TITLELEVEL = i + 1
						break
				if _TITLELEVEL >= 3:
					call_SetAchievement(value)
			"CUPCOIN_0":
				if GameLogic.Save.statisticsData["Count_NoCupCoin"]:
					call_SetAchievement(value)

			"SHOWCASE_1":
				if GameLogic.Save.statisticsData["HasEquipReward"] >= 1:
					call_SetAchievement(value)
			"SAVE_1":
				if GameLogic.Save.statisticsData["Count_SaveFriend"] >= 1:
					call_SetAchievement(value)
			"COMBO_99":
				if GameLogic.Save.statisticsData["Max_Combo"] >= 99:
					call_SetAchievement(value)


			"HIGHINCOME_3":
				if GameLogic.Save.statisticsData["Max_FinishMoney"] >= 100000:
					call_SetAchievement(value)

			"UNPACKING_2":
				if GameLogic.Save.statisticsData["Count_DelBox"] >= 1000:
					call_SetAchievement(value)

			"OPENGIFT_1":
				if GameLogic.Save.statisticsData["Count_OpenGift"] >= 50:
					call_SetAchievement(value)

			"REOPEN_1":
				if GameLogic.Save.statisticsData["Count_ReOpenGift"] >= 100:
					call_SetAchievement(value)

			"CHALLENGE_1":
				var _KEYS = GameLogic.Level_Data.keys()
				var _LEVELKEYS = GameLogic.Config.SceneConfig.keys()
				var _DEVILCOUNT: int = 0
				for _NAME in _KEYS:
					if _NAME in _LEVELKEYS:
						_DEVILCOUNT += int(GameLogic.Level_Data[_NAME].cur_Devil) + 1
				if _DEVILCOUNT >= 12:
					call_SetAchievement(value)

			"CHALLENGE_2":
				var _KEYS = GameLogic.Level_Data.keys()
				var _LEVELKEYS = GameLogic.Config.SceneConfig.keys()
				var _DEVILCOUNT: int = 0
				for _NAME in _KEYS:
					if _NAME in _LEVELKEYS:
						_DEVILCOUNT += int(GameLogic.Level_Data[_NAME].cur_Devil) + 1
				if _DEVILCOUNT >= 40:
					call_SetAchievement(value)

			"CHALLENGE_3":
				var _KEYS = GameLogic.Level_Data.keys()
				var _LEVELKEYS = GameLogic.Config.SceneConfig.keys()
				var _DEVILCOUNT: int = 0
				for _NAME in _KEYS:
					if _NAME in _LEVELKEYS:
						_DEVILCOUNT += int(GameLogic.Level_Data[_NAME].cur_Devil) + 1
				if _DEVILCOUNT >= 110:
					call_SetAchievement(value)

			"TRASH_1":
				if GameLogic.Save.statisticsData["Count_TrashBin"] >= 100:
					call_SetAchievement(value)

			"PEFRECTSHIFT_1":
				if GameLogic.Save.statisticsData["Count_perfectEndDay"] >= 100:
					call_SetAchievement(value)

			"CUPCOIN_1":
				if GameLogic.Save.statisticsData["Count_Money"] >= 50000:
					call_SetAchievement(value)

			"CUPCOIN_2":
				if GameLogic.Save.statisticsData["Count_Money"] >= 10000000:
					call_SetAchievement(value)

			"TIPS_1":
				if GameLogic.Save.statisticsData["Count_Tip"] >= 10000:
					call_SetAchievement(value)

			"TIPS_2":
				if GameLogic.Save.statisticsData["Count_Tip"] >= 1000000:
					call_SetAchievement(value)
			"UPGRADE_1":
				if GameLogic.Save.statisticsData["Count_BuyUpdate"] >= 100:
					call_SetAchievement(value)

			"UPGRADE_2":
				if GameLogic.Save.statisticsData["Count_BuyUpdate"] >= 1000:
					call_SetAchievement(value)
			"CRITICAL_1":
				if GameLogic.Save.statisticsData["Count_Cri"] >= 100:
					call_SetAchievement(value)

			"CRITICAL_2":
				if GameLogic.Save.statisticsData["Count_Cri"] >= 2000:
					call_SetAchievement(value)
			"DIFFERENT_2":
				if GameLogic.Save.statisticsData["Array_UnlockMenu"].size() >= 100:
					call_SetAchievement(value)

			"COMPLETE_2":
				if GameLogic.Save.statisticsData["Count_Victories"] >= 100:
					call_SetAchievement(value)

			"DAY_1":
				if GameLogic.Save.statisticsData["Count_Day"] >= 30:
					call_SetAchievement(value)

			"DAY_2":
				if GameLogic.Save.statisticsData["Count_Day"] >= 365:
					call_SetAchievement(value)
			"DAY_3":
				if GameLogic.Save.statisticsData["Count_Day"] >= 1461:
					call_SetAchievement(value)
			"PERFECT_3":
				if GameLogic.Save.statisticsData["Count_PerfectSell"] >= 10000:
					call_SetAchievement(value)

			"TRASHIN_1":
				if GameLogic.Save.statisticsData["Count_TrashBag"] >= 500:
					call_SetAchievement(value)

			"ADDICE_1":
				if GameLogic.Save.statisticsData["Count_Ice"] >= 500:
					call_SetAchievement(value)
			"ADDSUGAR_1":
				if GameLogic.Save.statisticsData["Count_Sugar"] >= 500:
					call_SetAchievement(value)
			"TOTALSELL_1":
				if GameLogic.Save.statisticsData["Count_SellServer"] >= 10000:
					call_SetAchievement(value)
			"TOTALORDER_1":
				if GameLogic.Save.statisticsData["Count_Order"] >= 10000:
					call_SetAchievement(value)

func call_SetAchievement(_VALUE):

	var _R = Steam.setAchievement(_VALUE)
	var _RS = Steam.storeStats()

func call_StatUp():
	var _COMBO: int = GameLogic.Save.statisticsData["Max_Combo"]
	if _COMBO > 99:
		_COMBO = 99
	call_SetStat("COMBO", _COMBO)
	var _DELBOX: int = GameLogic.Save.statisticsData["Count_DelBox"]
	if _DELBOX > 1000:
		_DELBOX = 1000
	call_SetStat("Box", _DELBOX)
	var _OPENGIFT: int = GameLogic.Save.statisticsData["Count_OpenGift"]
	if _OPENGIFT > 50:
		_OPENGIFT = 50
	call_SetStat("Gifts", _OPENGIFT)
	var _REOPEN: int = GameLogic.Save.statisticsData["Count_ReOpenGift"]
	if _REOPEN > 100:
		_REOPEN = 100
	call_SetStat("ReDraw", _REOPEN)
	var _GARBAGE: int = GameLogic.Save.statisticsData["Count_TrashBin"]
	if _GARBAGE > 100:
		_GARBAGE = 100
	call_SetStat("Garbage", _GARBAGE)
	var _NIGHT: int = GameLogic.Save.statisticsData["Count_perfectEndDay"]
	if _NIGHT > 100:
		_NIGHT = 100
	call_SetStat("Night", _NIGHT)
	var _CUPCOINS: int = GameLogic.Save.statisticsData["Count_Money"]
	if _CUPCOINS > 10000000:
		_CUPCOINS = 10000000
	call_SetStat("CupCoins", _CUPCOINS)
	var _TIPS: int = GameLogic.Save.statisticsData["Count_Tip"]
	if _TIPS > 1000000:
		_TIPS = 1000000
	call_SetStat("Tips", _TIPS)
	var _UPGRADE: int = GameLogic.Save.statisticsData["Count_BuyUpdate"]
	if _UPGRADE > 1000:
		_UPGRADE = 1000
	call_SetStat("Upgrade", _UPGRADE)
	var _KEYS = GameLogic.Level_Data.keys()
	var _LEVELKEYS = GameLogic.Config.SceneConfig.keys()
	var _DEVILCOUNT: int = 0
	for _NAME in _KEYS:
		if _NAME in _LEVELKEYS:
			_DEVILCOUNT += int(GameLogic.Level_Data[_NAME].cur_Devil) + 1
	if _DEVILCOUNT > 110:
		_DEVILCOUNT = 110
	call_SetStat("Challenge", _DEVILCOUNT)
	var _CRIT: int = GameLogic.Save.statisticsData["Count_Cri"]
	if _CRIT > 2000:
		_CRIT = 2000
	call_SetStat("Crit", _CRIT)
	var _UNLOCK: int = GameLogic.Save.statisticsData["Array_UnlockMenu"].size()
	if _UNLOCK > 100:
		_UNLOCK = 100
	call_SetStat("Different", _UNLOCK)
	var _COMPLETE: int = GameLogic.Save.statisticsData["Count_Victories"]
	if _COMPLETE > 100:
		_COMPLETE = 100
	call_SetStat("Complete", _COMPLETE)
	var _DAYS: int = GameLogic.Save.statisticsData["Count_Day"]
	if _DAYS > 1461:
		_DAYS = 1461
	call_SetStat("Days", _DAYS)
	var _PERFECT: int = GameLogic.Save.statisticsData["Count_PerfectSell"]
	if _PERFECT > 10000:
		_PERFECT = 10000
	call_SetStat("Perfect", _PERFECT)
	var _TRASHBIN: int = GameLogic.Save.statisticsData["Count_TrashBag"]
	if _TRASHBIN > 500:
		_TRASHBIN = 500
	call_SetStat("Trashbin", _TRASHBIN)
	var _ICE: int = GameLogic.Save.statisticsData["Count_Ice"]
	if _ICE > 500:
		_ICE = 500
	call_SetStat("Ice", _ICE)
	var _SUGAR: int = GameLogic.Save.statisticsData["Count_Sugar"]
	if _SUGAR > 500:
		_SUGAR = 500
	call_SetStat("Sugar", _SUGAR)
	var _SELL: int = GameLogic.Save.statisticsData["Count_SellServer"]
	if _SELL > 10000:
		_SELL = 10000
	call_SetStat("Sell", _SELL)
	var _ORDER: int = GameLogic.Save.statisticsData["Count_Order"]
	if _ORDER > 10000:
		_ORDER = 10000
	call_SetStat("Order", _ORDER)

func call_SetStat(_STAT, _value):


	var _r = Steam.setStatInt(_STAT, _value)
