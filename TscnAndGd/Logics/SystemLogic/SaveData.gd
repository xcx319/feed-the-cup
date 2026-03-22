extends Node

var _CHECKTIMEARRAY: Dictionary = {
	"year": 2024,
	"month": 1,
	"day": 27}
var _NEEDCREATE: bool = true
var _CHECKOLDDATA: bool = true
var _ISONLINE: bool
var SaveTime: int

const SAVE_DIR = "user://"

var save_suffix = ".sav"
var dataSavedName = "default"
var Default_path = SAVE_DIR + "default/saves/" + dataSavedName + save_suffix

var VERSION: String = "0.9.07"
var LASTVER: String = ""
var _PassWord = " "
var BackUpNum = 50
var gameData = {}
var statisticsData = {}
var levelData = {}

var Config
var game_randseed

func _ready() -> void :

	Config = ConfigFile.new()
	DataLoad()

func call_levelData_load():
	if Config.has_section("Level"):
		for i in Config.get_section_keys("Level"):
			var _value = Config.get_value("Level", i)
			levelData[i] = _value
func call_save_puppet():
	SaveTime = OS.get_ticks_usec()
	GameLogic.GameUI.SaveUIAni.play("show")


	var _game_keys = gameData.keys()
	for i in gameData.size():
		Config.set_value("Game", _game_keys[i], gameData[_game_keys[i]])

	pass
	var _Stat_keys = statisticsData.keys()
	for i in statisticsData.size():
		Config.set_value("Statistics", _Stat_keys[i], statisticsData[_Stat_keys[i]])

	pass
	var _level_keys = levelData.keys()
	for i in levelData.size():
		Config.set_value("Level", _level_keys[i], levelData[_level_keys[i]])
	Config.set_value("Game", "IsJoin", SteamLogic.IsJoin)
	Config.set_value("Game", "LevelDic", SteamLogic.LevelDic)
	Config.set_value("Game", "_MONEYCHECK", GameLogic._MONEYCHECK)
	_save()

func call_SteamDic_save():
	if SteamLogic.IsJoin:
		Config.set_value("Game", "IsJoin", SteamLogic.IsJoin)
		Config.set_value("Game", "LevelDic", SteamLogic.LevelDic)
		Config.set_value("Game", "_MONEYCHECK", GameLogic._MONEYCHECK)

	_save()
func call_save():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	SaveTime = OS.get_ticks_usec()
	GameLogic.GameUI.SaveUIAni.play("show")


	var _game_keys = gameData.keys()
	for i in gameData.size():
		Config.set_value("Game", _game_keys[i], gameData[_game_keys[i]])

	pass
	var _Stat_keys = statisticsData.keys()
	for i in statisticsData.size():
		Config.set_value("Statistics", _Stat_keys[i], statisticsData[_Stat_keys[i]])

	var _level_keys = levelData.keys()
	for i in levelData.size():
		Config.set_value("Level", _level_keys[i], levelData[_level_keys[i]])
	_save()
func call_Statistics_Check():
	if not statisticsData.has("Count_KillBugs"):
		statisticsData["Count_KillBugs"] = 0
	if not statisticsData.has("Count_Day"):
		statisticsData["Count_Day"] = 0
	if not statisticsData.has("Count_Money"):
		statisticsData["Count_Money"] = 0
	if not statisticsData.has("Count_MoneyCost"):
		statisticsData["Count_MoneyCost"] = 0
	if not statisticsData.has("Count_SellCup"):
		statisticsData["Count_SellCup"] = 0
	if not statisticsData.has("Count_SellServer"):
		statisticsData["Count_SellServer"] = 0
	if not statisticsData.has("Count_Order"):
		statisticsData["Count_Order"] = 0
	if not statisticsData.has("Count_Victories"):
		statisticsData["Count_Victories"] = 0
	if not statisticsData.has("Count_NetVictories"):

		statisticsData["Count_NetVictories"] = 0
	if not statisticsData.has("Count_Fail"):
		statisticsData["Count_Fail"] = 0
	if not statisticsData.has("Count_Tip"):
		statisticsData["Count_Tip"] = 0
	if not statisticsData.has("Count_BuyUpdate"):
		statisticsData["Count_BuyUpdate"] = 0
	if not statisticsData.has("Count_DelBox"):
		statisticsData["Count_DelBox"] = 0
	if not statisticsData.has("Count_OpenGift"):
		statisticsData["Count_OpenGift"] = 0
	if not statisticsData.has("Count_ReOpenGift"):
		statisticsData["Count_ReOpenGift"] = 0
	if not statisticsData.has("Count_HomeMoney"):
		statisticsData["Count_HomeMoney"] = 0
	if not statisticsData.has("Count_HomeMoneyCost"):
		statisticsData["Count_HomeMoneyCost"] = 0
	if not statisticsData.has("Count_Cri"):
		statisticsData["Count_Cri"] = 0
	if not statisticsData.has("Count_PerfectSell"):
		statisticsData["Count_PerfectSell"] = 0
	if not statisticsData.has("Count_2P"):
		statisticsData["Count_2P"] = 0
	if not statisticsData.has("Count_TrashBag"):
		statisticsData["Count_TrashBag"] = 0
	if not statisticsData.has("Count_TrashBin"):
		statisticsData["Count_TrashBin"] = 0
	if not statisticsData.has("Count_Ice"):
		statisticsData["Count_Ice"] = 0
	if not statisticsData.has("Count_Sugar"):
		statisticsData["Count_Sugar"] = 0
	if not statisticsData.has("Count_perfectEndDay"):
		statisticsData["Count_perfectEndDay"] = 0
	if not statisticsData.has("Count_CatchThief"):
		statisticsData["Count_CatchThief"] = 0
	if not statisticsData.has("Max_Combo"):
		statisticsData["Max_Combo"] = 0
	if not statisticsData.has("Max_OpenGift"):
		statisticsData["Max_OpenGift"] = 0
	if not statisticsData.has("Max_FinishMoney"):
		statisticsData["Max_FinishMoney"] = 0
	if not statisticsData.has("Count_AllStarFinish"):
		statisticsData["Count_AllStarFinish"] = 0
	if not statisticsData.has("Array_UnlockPlayer"):
		statisticsData["Array_UnlockPlayer"] = [0, 1, 2]
	if not statisticsData.has("Array_UnlockMenu"):
		statisticsData["Array_UnlockMenu"] = []
	if not statisticsData.has("Dic_NPC_SellNum"):
		statisticsData["Dic_NPC_SellNum"] = {}
	if not statisticsData.has("CardList"):
		statisticsData["CardList"] = {}
	if not statisticsData.has("ChallengeList"):
		statisticsData["ChallengeList"] = {}
	if not statisticsData.has("EventList"):
		statisticsData["EventList"] = {}

	if not statisticsData.has("HasEquipReward"):
		statisticsData["HasEquipReward"] = 0
	if not statisticsData.has("Count_SaveFriend"):
		statisticsData["Count_SaveFriend"] = 0
	if not statisticsData.has("Count_NoCupCoin"):
		statisticsData["Count_NoCupCoin"] = 0
	if not statisticsData.has("CleanNum"):
		statisticsData["CleanNum"] = 0


	if not statisticsData.has("Character"):
		statisticsData["Character"] = {}
		for i in 10:
			var _CHARACTERDIC: Dictionary = {"EXP": 0,
			"UseCount": 0,
			"MultplayCount": 0,
			"FeedCups": 0,
			"HomeMoneyCount": 0,
			"CupCoinCount": 0
			}
			statisticsData["Character"][i] = _CHARACTERDIC

var IsNew: bool
func new_PlayerData_Create():

	IsNew = true
	Config.clear()
	Config.set_value("Game", "VERSION", VERSION)

	var _TIME
	if SteamLogic.STEAM_BOOL:
		var _STEAM_Time = Steam.getServerRealTime()
		if _STEAM_Time != 0:
			_TIME = OS.get_datetime_from_unix_time(_STEAM_Time)
			_ISONLINE = true
		else:
			_TIME = OS.get_datetime()
	else:
		_TIME = OS.get_datetime()

	Config.set_value("Statistics", "SaveData_CreateTime", _TIME)
	Config.set_value("Statistics", "SaveData_IsOnline", _ISONLINE)
	call_Statistics_Check()



	Config.set_value("Game", "HomeUpdate", 0)
	Config.set_value("Game", "HomeDevList", [])








	var _rand = randi() % 100000000000
	Config.set_value("Game", "Rand_Hash", str(_rand))
	Config.set_value("Game", "Rand_State", 0)
	Config.set_value("Game", "Rand_EggState", 0)
	_save()

func dataSYNC():


	for i in Config.get_section_keys("Statistics"):
		var _value = Config.get_value("Statistics", i)
		statisticsData[i] = _value






	for i in Config.get_section_keys("Game"):
		var _value = Config.get_value("Game", i)
		gameData[i] = _value

	if Config.has_section("Level"):
		for i in Config.get_section_keys("Level"):
			var _value = Config.get_value("Level", i)
			levelData[i] = _value
	call_Statistics_Check()


	if SteamLogic.STEAM_BOOL:
		var _STEAM_Time = Steam.getServerRealTime()
		var _TIME
		if _STEAM_Time != 0:
			_TIME = OS.get_datetime_from_unix_time(_STEAM_Time)
			_ISONLINE = true
		else:
			_TIME = OS.get_datetime()
	if gameData.has("SubRANDOM_State"):
		GameLogic._SubRANDOM.state = gameData["SubRANDOM_State"]
	if not gameData.has("KEY"):
		gameData["KEY"] = randi() % 1000000
	GameLogic.EggCoinKey = gameData["KEY"]


	if not gameData.has("SubStation_AutoShelf"):
		gameData["SubStation_AutoShelf"] = false

	if gameData.has("EquipDic"):
		if 1 in gameData["EquipDic"] and 2 in gameData["EquipDic"]:
			pass
		else:
			gameData["EquipDic"].clear()
			gameData["EquipDic"] = {1: {}, 2: {}}
	else:
		gameData["EquipDic"] = {1: {}, 2: {}}



	if statisticsData.has("SaveData_CheckTime"):
		var _CheckTime = statisticsData["SaveData_CheckTime"]
		if _CheckTime.year >= _CHECKTIMEARRAY.year:
			if _CheckTime.month >= _CHECKTIMEARRAY.month:
				if _CheckTime.day >= _CHECKTIMEARRAY.day:
					_CHECKOLDDATA = false
					_NEEDCREATE = false
	elif statisticsData.has("SaveData_IsOnline"):
		if statisticsData.SaveData_IsOnline:
			_NEEDCREATE = false
			var _OS_Time = statisticsData["SaveData_CreateTime"]

			if _OS_Time.year > _CHECKTIMEARRAY.year:
				_CHECKOLDDATA = false
			elif _OS_Time.year == _CHECKTIMEARRAY.year:
				if _OS_Time.month > _CHECKTIMEARRAY.month:
					_CHECKOLDDATA = false
				elif _OS_Time.month == _CHECKTIMEARRAY.month:
					if _OS_Time.day >= _CHECKTIMEARRAY.day:
						_CHECKOLDDATA = false

func call_CleanLogic():
	var _TIME
	var _STEAM_Time = 0
	if SteamLogic.STEAM_BOOL:
		_STEAM_Time = Steam.getServerRealTime()
	if _STEAM_Time != 0:
		_TIME = OS.get_datetime_from_unix_time(_STEAM_Time)
		_ISONLINE = true
	else:
		_TIME = OS.get_datetime()
	if _NEEDCREATE and _ISONLINE:

		Config.set_value("Statistics", "SaveData_CreateTime", _TIME)
		Config.set_value("Statistics", "SaveData_IsOnline", _ISONLINE)
	if _CHECKOLDDATA and _ISONLINE:

		GameLogic.Achievement.cur_EquipList.clear()
		gameData["cur_EquipList"] = []
		statisticsData["SaveData_CheckTime"] = _CHECKTIMEARRAY

		var _LEVELKEY = gameData["Level_Data"].keys()
		for _i in _LEVELKEY.size():
			var _LEVELNAME = _LEVELKEY[_i]
			var _INFO = gameData["Level_Data"][_LEVELNAME]
			_INFO.level_SellTotal = 0
			_INFO.level_CustomerTotal = 0
			_INFO.level_MoneyTotal = 0
			_INFO.cur_Devil = 0

		for i in 10:
			statisticsData["Character"][i]["CupCoinCount"] = 0

		statisticsData["Dic_NPC_SellNum"].clear()
		statisticsData["Count_Day"] = 0
		statisticsData["Count_Money"] = 0
		statisticsData["Count_MoneyCost"] = 0
		statisticsData["Count_SellCup"] = 0
		statisticsData["Count_SellServer"] = 0
		statisticsData["Count_Order"] = 0
		statisticsData["Count_Victories"] = 0
		statisticsData["Count_NetVictories"] = 0
		statisticsData["Count_Fail"] = 0
		statisticsData["Count_Tip"] = 0
		statisticsData["Count_BuyUpdate"] = 0
		statisticsData["Count_DelBox"] = 0
		statisticsData["Count_OpenGift"] = 0
		statisticsData["Count_ReOpenGift"] = 0
		statisticsData["Count_HomeMoney"] = 0
		statisticsData["Count_HomeMoneyCost"] = 0
		statisticsData["Count_Cri"] = 0
		statisticsData["Count_PerfectSell"] = 0
		statisticsData["Count_2P"] = 0
		statisticsData["Count_TrashBag"] = 0
		statisticsData["Count_TrashBin"] = 0
		statisticsData["Count_Ice"] = 0
		statisticsData["Count_Sugar"] = 0
		statisticsData["Count_perfectEndDay"] = 0
		statisticsData["Count_CatchThief"] = 0
		statisticsData["Max_Combo"] = 0
		statisticsData["Max_OpenGift"] = 0
		statisticsData["Max_FinishMoney"] = 0
		statisticsData["Count_AllStarFinish"] = 0
		statisticsData["Array_UnlockPlayer"] = [0, 1, 2]
		statisticsData["Array_UnlockMenu"] = []
		statisticsData["Dic_NPC_SellNum"] = {}


		statisticsData["HasEquipReward"] = 0
		statisticsData["Count_SaveFriend"] = 0
		statisticsData["Count_NoCupCoin"] = 0
		statisticsData["CleanNum"] = 0

		call_save()

		pass







func call_exit_level():

	if levelData.has("cur_level"):
		GameLogic.GameOverType = 3

func _save():



	var file = File.new()
	var dir = Directory.new()



	var _path = Default_path
	var CheckDIR: String = SAVE_DIR + "default/saves/"
	if SteamLogic.STEAM_ID != 0:
		CheckDIR = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/saves/"
		_path = CheckDIR + dataSavedName + save_suffix


	if dir.open(CheckDIR) != OK:
		printerr(" Default 文件夹不存在,执行创建新文件夹。")
		dir.make_dir(CheckDIR)

	if file.file_exists(_path):
		_Data_BackUp()
	file.close()
	_saveLogic(_path)

	SaveTime = OS.get_ticks_usec() - SaveTime
	print("保存用时(微秒）：", float(SaveTime) / 1000000, "秒 保存地址：", _path)

func DataLoad():

	_loadLogic(dataSavedName, 0)
	dataSYNC()
func call_DataLoad_withoutStatistics():
	_loadLogic(dataSavedName, 0)

	for i in Config.get_section_keys("Game"):
		var _value = Config.get_value("Game", i)
		gameData[i] = _value

	if Config.has_section("Level"):
		for i in Config.get_section_keys("Level"):
			var _value = Config.get_value("Level", i)
			levelData[i] = _value
	call_Statistics_Check()

func _Data_BackUp():
	var file = File.new()

	var _OlderData: Dictionary

	for i in BackUpNum:
		var _backupName = "BackUp_" + str(i)
		var _backup_path = SAVE_DIR + "default/saves/" + _backupName + save_suffix
		if SteamLogic.STEAM_ID != 0:
			_backup_path = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/saves/" + _backupName + save_suffix

		if file.file_exists(_backup_path):
			var _savetime = file.get_modified_time(_backup_path)
			if not _OlderData.size():
				_OlderData[i] = _savetime
			else:
				var _key = _OlderData.keys()
				var _OlderTime = _OlderData[_key[0]]
				if _savetime < _OlderTime:
					_OlderData.clear()
					_OlderData[i] = _savetime
		else:
			_BackUp_Save(_backup_path)
			file.close()
			return

	var _key = _OlderData.keys()
	if _key:
		var _backupName = "BackUp_" + str(_key[0])
		var _backup_path = SAVE_DIR + "default/saves/" + _backupName + save_suffix
		if SteamLogic.STEAM_ID != 0:
			_backup_path = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/saves/" + _backupName + save_suffix


		_BackUp_Save(_backup_path)

	file.close()

func _saveLogic(_path):
	var _check = Config.save_encrypted_pass(_path, str(_PassWord))

	if _check != OK:
		printerr("存档保存失败，错误：", _check)
	else:
		print("存档保存:", _check, _path)
func _BackUp_Load(_num):
	var _file = File.new()
	var _OlderData: Dictionary

	for i in BackUpNum:
		var _backupName = "BackUp_" + str(i)
		var _backup_path = SAVE_DIR + "default/saves/" + _backupName + save_suffix
		if SteamLogic.STEAM_ID != 0:
			_backup_path = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/saves/" + _backupName + save_suffix
		var _TimeCheck = null
		if _file.file_exists(_backup_path):
			var _savetime = _file.get_modified_time(_backup_path)
			_OlderData[_savetime] = i
		else:
			print("文件不存在：", _backupName)

	var _key = _OlderData.keys()

	var _BackUpTimeList: Array
	for i in _key.size():
		var _Max = _key.max()
		_key.erase(_Max)
		_BackUpTimeList.append(_Max)

	if _BackUpTimeList:
		if _BackUpTimeList.size() > _num:

			if _OlderData.has(_BackUpTimeList[_num]):
				var _BackUpName = str(_OlderData[_BackUpTimeList[_num]])
				var _backupName = "BackUp_" + _BackUpName
				_loadLogic(_backupName, _num + 1)
			else:
				print("备用存档Load问题，无法找到：", _BackUpTimeList[_num])
		else:
			print("备用存档Load问题：", _BackUpTimeList.size(), _num)
	else:
		new_PlayerData_Create()
	_file.close()
func _loadLogic(_Name, times):
	var _path = Default_path
	if SteamLogic.STEAM_ID != 0:
		_path = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/saves/" + _Name + save_suffix
	var file = File.new()

	if file.file_exists(_path):
		var _check = Config.load_encrypted_pass(_path, str(_PassWord))

		if _check != OK:
			printerr("存档加载失败，错误：", _check)
			_check = Config.load(_path)
			if _check != OK:
				printerr("未加密存档加载失败，错误：", _check)


		if not Config.get_sections():

			_BackUp_Load(times)
	else:
		_BackUp_Load(times)

	file.close()
func _BackUp_Save(_path):
	var _OldConfig = ConfigFile.new()
	var _DefaultPath = Default_path
	if SteamLogic.STEAM_ID != 0:
		_DefaultPath = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/saves/" + dataSavedName + save_suffix
	var _check = _OldConfig.load_encrypted_pass(_DefaultPath, str(_PassWord))

	if _check != OK:

		_check = Config.load(_path)
		if _check != OK:
			printerr("未加密存档加载失败，错误：", _check)
	if _check == OK:
		_check = _OldConfig.save_encrypted_pass(_path, str(_PassWord))

	if _check != OK:
		printerr("存档保存失败，错误：", _check)

func return_savedata(_Obj):
	if not _Obj:
		return null
	if not _Obj.get("TypeStr"):

		return
	var _ObjName = _Obj.TypeStr
	var _functype = _Obj.FuncType
	var _Data: Dictionary
	match _functype:
		"HighStressToy":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"TYPE": _Obj.TYPE,
				}
		"Beer":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Liquid_Count": _Obj.Liquid_Count,
				"IsOpen": _Obj.IsOpen,

			}
		"CreamMachine":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"CreamBool": _Obj.CreamBool,
				"CreamTYPE": _Obj.CreamTYPE,
				"MixFinishBool": _Obj.MixFinishBool,
				"OverBool": _Obj.OverBool,

				"Liquid_Count": _Obj.Liquid_Count,
				"WaterType": _Obj.WaterType,
				"IsPassDay": _Obj.IsPassDay
			}
		"BreakMachine":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Liquid_Count": _Obj.Liquid_Count,
				"WaterCelcius": _Obj.WaterCelcius,
				"IsPassDay": _Obj.IsPassDay,
				"WaterType": _Obj.WaterType,
				"HasWater": _Obj.HasWater,
				"IsOpen": _Obj.IsOpen,
				"MachineStat": _Obj.MachineStat,
				"SugarType": _Obj.SugarType,
				}
		"ChopMachine":
			var _NAME = str(_Obj.get_instance_id())
			var _BOX = null
			if is_instance_valid(_Obj._BOX):
				_BOX = return_savedata(_Obj._BOX)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"_BOX": _BOX,
				}
		"FruitCore":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"FruitName": _Obj.FruitName,
				"IsBroken": _Obj.IsBroken,
				"FruitNum": _Obj.FruitNum,
				}

		"SmashTable":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				}
		"TicketMachine":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				}
		"CleanMachine":
			var _NAME = str(_Obj.get_instance_id())
			var _OBJNUM: int = _Obj.CUPLIST.size()
			var _OBJLIST: Array
			for _NUM in _OBJNUM:
				_OBJLIST.append(return_savedata(_Obj.CUPLIST[_NUM]))

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"OBJLIST": _OBJLIST,

				}
		"Shelf_Beer", "Shelf_OnTable", "FreezerOnTable", "TeaBarrelShelf", "GasBox", "Plate":
			var _TableData = null
			var _AObj = null
			var _BObj = null
			var _XObj = null
			var _YObj = null
			if _Obj.LayerA_Obj:
				_AObj = return_savedata(_Obj.LayerA_Obj)
			else:
				var _ObjList = _Obj.Layer_A.get_children()

				if _ObjList.size():
					for i in _ObjList.size():
						_AObj = return_savedata(_ObjList[i])

			if _Obj.LayerB_Obj:
				_BObj = return_savedata(_Obj.LayerB_Obj)
			else:
				var _ObjList = _Obj.Layer_B.get_children()
				if _ObjList.size():
					for i in _ObjList.size():
						_BObj = return_savedata(_ObjList[i])

			if _Obj.LayerX_Obj:
				_XObj = return_savedata(_Obj.LayerX_Obj)
			else:
				var _ObjList = _Obj.Layer_X.get_children()
				if _ObjList.size():
					for i in _ObjList.size():
						_XObj = return_savedata(_ObjList[i])

			if _Obj.LayerY_Obj:
				_YObj = return_savedata(_Obj.LayerY_Obj)
			else:
				var _ObjList = _Obj.Layer_Y.get_children()
				if _ObjList.size():
					for i in _ObjList.size():
						_YObj = return_savedata(_ObjList[i])

			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"LayerA_Obj": _AObj,
				"LayerB_Obj": _BObj,
				"LayerX_Obj": _XObj,
				"LayerY_Obj": _YObj,
				}
		"FruitShelf":
			var _NAME = str(_Obj.get_instance_id())

			var Layer1_Array: Array = []
			var Layer2_Array: Array = []
			var Layer3_Array: Array = []
			var Layer4_Array: Array = []
			if _Obj.layer1_Array.size():
				for _Layer1Obj in _Obj.layer1_Array:
					Layer1_Array.append(return_savedata(_Layer1Obj))
			if _Obj.layer2_Array.size():
				for _Layer2Obj in _Obj.layer2_Array:
					Layer2_Array.append(return_savedata(_Layer2Obj))
			if _Obj.layer3_Array.size():
				for _Layer3Obj in _Obj.layer3_Array:
					Layer3_Array.append(return_savedata(_Layer3Obj))
			if _Obj.layer4_Array.size():
				for _Layer4Obj in _Obj.layer4_Array:
					Layer4_Array.append(return_savedata(_Layer4Obj))
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Layer1_Array": Layer1_Array,
				"Layer2_Array": Layer2_Array,
				"Layer3_Array": Layer3_Array,
				"Layer4_Array": Layer4_Array,

			}
		"Shelf_GlassCup":
			var _NAME = str(_Obj.get_instance_id())
			var Layer1_Array: Array = []
			var Layer2_Array: Array = []
			var Layer3_Array: Array = []
			var Layer4_Array: Array = []
			var Layer1_Item = _Obj.Layer1_Item
			var Layer2_Item = _Obj.Layer2_Item
			var Layer3_Item = _Obj.Layer3_Item
			var Layer4_Item = _Obj.Layer4_Item
			if GameLogic.LoadingUI.IsHome:

				for _OBJNODE in _Obj.Layer1.get_children():
					Layer1_Array.append(return_savedata(_OBJNODE))
				Layer1_Item = Layer1_Array[0].TSCN
				for _OBJNODE in _Obj.Layer2.get_children():
					Layer2_Array.append(return_savedata(_OBJNODE))
				Layer2_Item = Layer2_Array[0].TSCN
				for _OBJNODE in _Obj.Layer3.get_children():
					Layer3_Array.append(return_savedata(_OBJNODE))
				Layer3_Item = Layer3_Array[0].TSCN
				for _OBJNODE in _Obj.Layer4.get_children():
					Layer4_Array.append(return_savedata(_OBJNODE))
				Layer4_Item = Layer4_Array[0].TSCN
			if _Obj.layer1_Array.size():
				for _Layer1Obj in _Obj.layer1_Array:
					Layer1_Array.append(return_savedata(_Layer1Obj))
			if _Obj.layer2_Array.size():
				for _Layer2Obj in _Obj.layer2_Array:
					Layer2_Array.append(return_savedata(_Layer2Obj))
			if _Obj.layer3_Array.size():
				for _Layer3Obj in _Obj.layer3_Array:
					Layer3_Array.append(return_savedata(_Layer3Obj))
			if _Obj.layer4_Array.size():
				for _Layer4Obj in _Obj.layer4_Array:
					Layer4_Array.append(return_savedata(_Layer4Obj))
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Layer1_Array": Layer1_Array,
				"Layer2_Array": Layer2_Array,
				"Layer3_Array": Layer3_Array,
				"Layer4_Array": Layer4_Array,
				"Layer1_Item": Layer1_Item,
				"Layer2_Item": Layer2_Item,
				"Layer3_Item": Layer3_Item,
				"Layer4_Item": Layer4_Item,

			}
		"Freezer":
			var _NAME = str(_Obj.get_instance_id())
			var Layer1_Array: Array = []
			var Layer2_Array: Array = []
			var Layer3_Array: Array = []
			var Layer4_Array: Array = []
			if _Obj.layer1_Array.size():
				for _Layer1Obj in _Obj.layer1_Array:
					Layer1_Array.append(return_savedata(_Layer1Obj))
			if _Obj.layer2_Array.size():
				for _Layer2Obj in _Obj.layer2_Array:
					Layer2_Array.append(return_savedata(_Layer2Obj))
			if _Obj.layer3_Array.size():
				for _Layer3Obj in _Obj.layer3_Array:
					Layer3_Array.append(return_savedata(_Layer3Obj))
			if _Obj.layer4_Array.size():
				for _Layer4Obj in _Obj.layer4_Array:
					Layer4_Array.append(return_savedata(_Layer4Obj))
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Layer1_Array": Layer1_Array,
				"Layer2_Array": Layer2_Array,
				"Layer3_Array": Layer3_Array,
				"Layer4_Array": Layer4_Array,
			}
		"Shelf", "FreezeShelf":
			var _NAME = str(_Obj.get_instance_id())
			var Layer1_Array: Array = []
			var Layer2_Array: Array = []
			var Layer3_Array: Array = []
			var Layer4_Array: Array = []
			if _Obj.layer1_Array.size():
				for _Layer1Obj in _Obj.layer1_Array:
					Layer1_Array.append(return_savedata(_Layer1Obj))
			if _Obj.layer2_Array.size():
				for _Layer2Obj in _Obj.layer2_Array:
					Layer2_Array.append(return_savedata(_Layer2Obj))
			if _Obj.layer3_Array.size():
				for _Layer3Obj in _Obj.layer3_Array:
					Layer3_Array.append(return_savedata(_Layer3Obj))
			if _Obj.layer4_Array.size():
				for _Layer4Obj in _Obj.layer4_Array:
					Layer4_Array.append(return_savedata(_Layer4Obj))
			var _AUTOTYPE: int = _Obj.get("AUTOTYPE")
			if _AUTOTYPE > 0:
				pass
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Layer1_Array": Layer1_Array,
				"Layer2_Array": Layer2_Array,
				"Layer3_Array": Layer3_Array,
				"Layer4_Array": Layer4_Array,
				"AUTOTYPE": _AUTOTYPE,

			}

		"Trashbin":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Trash_Count": _Obj.Trash_Count,
				}
		"Table", "PickUp":
			var _NAME = str(_Obj.get_instance_id())

			var _TableData = null
			if _Obj.has_node("ObjNode"):
				if _Obj.get_node("ObjNode").get_child_count():
					var _ObjList = _Obj.get_node("ObjNode").get_children()
					for y in _ObjList.size():
						var _ObjOnTable = _ObjList[y]
						var _x = _ObjOnTable.name
						_TableData = return_savedata(_ObjOnTable)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"Table": _TableData,
				"pos": _Obj.position,
				"Tex": _Obj.Tex,
				"SPECIAL": _Obj.get("SPECIAL"),
				"CanPutDev": _Obj.CanPutDev
				}

		"MilkPot":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"HasMilk": _Obj.HasMilk,
				"HasContent": _Obj.HasContent,
				"ContentType": _Obj.ContentType,

				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"WaterType": _Obj.WaterType,

				"WaterCelcius": _Obj.WaterCelcius,
				}
		"BigPot":
			var _NAME = str(_Obj.get_instance_id())
			var _ITEMDATA = null
			if is_instance_valid(_Obj.ITEMOBJ):
				_ITEMDATA = return_savedata(_Obj.ITEMOBJ)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Liquid_Count": _Obj.Liquid_Count,
				"cur_ContentNum": _Obj.cur_ContentNum,
				"ContentType": _Obj.ContentType,
				"cur_TYPE": _Obj.cur_TYPE,
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"IsFreezer": _Obj.IsFreezer,
				"WaterCelcius": _Obj.WaterCelcius,
				"WaterType": _Obj.WaterType,
				"ITEMOBJ": _ITEMDATA,
				}
		"Con_TeaPort":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"HasTeaLeaf": _Obj.HasTeaLeaf,
				"HasContent": _Obj.HasContent,
				"HasWater": _Obj.HasWater,
				"CanMix": _Obj.CanMix,
				"MixShow": _Obj._MixShow,
				"WaterType": _Obj.WaterType,
				"TeaType": _Obj.TeaType,
				"ContentType": _Obj.ContentType,
				"CanWaterOut": _Obj.CanWaterOut,
				"WaterCelcius": 25,
				"IsDrawTea": _Obj.IsDrawTea,
				"Liquid_Count": _Obj.Liquid_Count,
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"IsFreezer": _Obj.IsFreezer,

				}

		"GasBottle":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"GasNum": _Obj.GasNum,
				}
		"PopCap":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _functype,
				"NAME": _NAME,
				"pos": _Obj.position,
				"ContentDic": _Obj.ContentDic,
				"Liquid_Count": _Obj.Liquid_Count,
				"WaterType": _Obj.WaterType,
				"NeedWater": _Obj.NeedWater,
				"HasWater": _Obj.HasWater,
				"NeedWaterNum": _Obj.NeedWaterNum,
				"_COLOR": _Obj.LiquidNode.modulate,
				"TYPE": _Obj.TYPE,
				"CanContant": _Obj.CanContant,
				"GasNum": _Obj.GasNum,
				}
		"TeaBarrel":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"WaterType": _Obj.WaterType,
				"WaterCelcius": 25,
				"Liquid_Count": _Obj.Liquid_Count,
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"IsFreezer": _Obj.IsFreezer,
				}
		"Con_Liquid":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"HasContent": _Obj.HasContent,
				"HasTeaLeaf": _Obj.HasTeaLeaf,
				"HasWater": _Obj.HasWater,
				"WaterType": _Obj.WaterType,
				"WaterCelcius": 25,
				"CanWaterOut": _Obj.CanWaterOut,
				"Liquid_Count": _Obj.Liquid_Count,
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"IsFreezer": _Obj.IsFreezer,
				}
		"LiquidCon_Heat":
			var _NAME = str(_Obj.get_instance_id())

			var _TableData = null
			var _TableObj = _Obj.OnTableObj
			if _TableObj:
				_TableData = return_savedata(_TableObj)
				if _TableData.has("WaterCelcius"):
					_TableData.WaterCelcius = 99
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Obj": _TableData,
				}
		"CupHolder":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"S_Num": _Obj.S_Num,
				"M_Num": _Obj.M_Num,
				"L_Num": _Obj.L_Num,
				}
		"CoffeeMachine":
			var _NAME = str(_Obj.get_instance_id())
			var _HasMilk: bool = _Obj.HasMilk
			var _HasCup: bool = _Obj.HasCup
			var _MilkOBJ
			var _CupOBJ
			if _HasMilk:
				_MilkOBJ = return_savedata(_Obj.MilkOBJ)
			if _HasCup:
				_CupOBJ = return_savedata(_Obj.CupOBJ)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"CoffeeBean": _Obj.cur_CoffeeBean,
				"HasMilk": _HasMilk,
				"HasCup": _HasCup,
				"MilkBottle": _MilkOBJ,
				"Cup": _CupOBJ,
				}
		"JuiceMachine":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"FRUIT": _Obj.FRUIT,
				"Liquid_Count": _Obj.Liquid_Count,
				"Trash_Count": _Obj.Trash_Count,
				"HasFruit": _Obj.HasFruit,
				"WaterType": _Obj.WaterType,
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				}
		"BobaMachine":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"cur_TYPE": _Obj.cur_TYPE,
				"Liquid_Count": _Obj.Liquid_Count,
				"cur_ContentNum": _Obj.cur_ContentNum,
				"ContentType": _Obj.ContentType,
				}
		"SugarMachine":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"cur_sugar": _Obj.cur_sugar,
				"cur_free": _Obj.cur_free,
				}
		"Box_M_Paper":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"IsTrash": _Obj.IsTrash,
				"IsOpen": _Obj.IsOpen,
				"pos": _Obj.position,
				"HasItem": _Obj.HasItem,
				"ItemName": _Obj.ItemName,
				"ItemNum": _Obj.ItemOBJ_Array.size(),
				"ItemNameDIC": _Obj._ItemNameDic,

				"Type": _Obj.Type,
				"BuyDay": _Obj.BuyDay,
				}
		"PopWaterMachine":
			var _NAME = str(_Obj.get_instance_id())
			var _BObj

			if _Obj.LayerB_Obj:
				_BObj = return_savedata(_Obj.LayerB_Obj)
			else:
				var _ObjList = _Obj.Layer_B.get_children()
				if _ObjList.size():

					_BObj = return_savedata(_ObjList[0])

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,

				"LayerB_Obj": _BObj,

				}
		"BeerMachine":
			var _NAME = str(_Obj.get_instance_id())
			var _AObj
			var _BObj
			var _XObj
			var _YObj
			if _Obj.LayerA_Obj:
				_AObj = return_savedata(_Obj.LayerA_Obj)
			else:
				var _ObjList = _Obj.Layer_A.get_children()
				if _ObjList.size():

					_AObj = return_savedata(_ObjList[0])

			if _Obj.LayerB_Obj:
				_BObj = return_savedata(_Obj.LayerB_Obj)
			else:
				var _ObjList = _Obj.Layer_B.get_children()
				if _ObjList.size():

					_BObj = return_savedata(_ObjList[0])
			if _Obj.LayerX_Obj:
				_XObj = return_savedata(_Obj.LayerX_Obj)
			else:
				var _ObjList = _Obj.Layer_X.get_children()
				if _ObjList.size():

					_XObj = return_savedata(_ObjList[0])

			if _Obj.LayerY_Obj:
				_YObj = return_savedata(_Obj.LayerY_Obj)
			else:
				var _ObjList = _Obj.Layer_Y.get_children()
				if _ObjList.size():

					_YObj = return_savedata(_ObjList[0])
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"LayerA_Obj": _AObj,
				"LayerX_Obj": _XObj,
				"LayerY_Obj": _YObj,
				"LayerB_Obj": _BObj,

				}
		"PopMachine":
			var _NAME = str(_Obj.get_instance_id())
			var _BObj
			var _XObj
			var _YObj
			if _Obj.LayerB_Obj:
				_BObj = return_savedata(_Obj.LayerB_Obj)
			else:
				var _ObjList = _Obj.Layer_B.get_children()
				if _ObjList.size():

					_BObj = return_savedata(_ObjList[0])
			if _Obj.LayerX_Obj:
				_XObj = return_savedata(_Obj.LayerX_Obj)
			else:
				var _ObjList = _Obj.Layer_X.get_children()
				if _ObjList.size():
					for i in _ObjList.size():
						_XObj = return_savedata(_ObjList[i])

			if _Obj.LayerY_Obj:
				_YObj = return_savedata(_Obj.LayerY_Obj)
			else:
				var _ObjList = _Obj.Layer_Y.get_children()
				if _ObjList.size():
					for i in _ObjList.size():
						_YObj = return_savedata(_ObjList[i])
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"LayerX_Obj": _XObj,
				"LayerY_Obj": _YObj,
				"LayerB_Obj": _BObj,

				}
		"EggRollPot":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"HasWater": _Obj.HasWater,
				"HasContent": _Obj.HasContent,
				"ContentType": _Obj.ContentType,
				"WaterType": _Obj.WaterType,
				"IsBroken": _Obj.IsBroken,
				"IsPassDay": _Obj.IsPassDay,
				"Liquid_Count": _Obj.Liquid_Count,

				}

		"EggRollMachine":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"TurnOn": _Obj._TurnOn,
				"MakingType": _Obj.MakingType,
				"CurKEY": _Obj.CurKEY,
				"EggRollNum": _Obj.EggRollNum,
				"EggRollType": _Obj.EggRollType,
				"IsBroken": _Obj.IsBroken,
				"IsPassDay": _Obj.IsPassDay,
				}
		"IceMachine":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"TurnOn": _Obj._TurnOn,
				"cur_Ice": _Obj.cur_Ice,
				}
		"HotWaterMachine":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"TurnOn": _Obj._TurnOn,

				}
		"ShakeCup":
			var _NAME = str(_Obj.get_instance_id())

			var _Liquid_Array: Array
			for i in _Obj.Liquid_Count:
				var _Layer = "Layer" + str(i + 1)
				var _LayerModulate = _Obj.get_node("TexNode/Tex/Layer").get_node(_Layer).get_modulate()
				_Liquid_Array.append(_LayerModulate)

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Is_Mix": _Obj.Is_Mix,
				"SugarType": _Obj.SugarType,
				"LIQUID_DIR": _Obj.LIQUID_DIR,

				"WaterCelcius": 25,
				"cur_ID": 0,
				"Liquid_Count": _Obj.Liquid_Count,
				"IsPassDay": _Obj.IsPassDay,
				"Liquid_Array": _Liquid_Array
			}

		"Trashbag", "FruitTrash":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"Weight": _Obj.Weight,
				"pos": _Obj.position,
				}
		"SodaPack":
			var _NAME = str(_Obj.get_instance_id())
			var _SODAOBJ
			if _Obj.HasSodaCan:
				_SODAOBJ = return_savedata(_Obj.SodaObj)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"HasSodaCan": _Obj.HasSodaCan,
				"SodaObj": _SODAOBJ,
			}
		"SodaCan":
			var _NAME = str(_Obj.get_instance_id())
			var _LayerArray: Array
			if _Obj.Liquid_Count > 0:
				_LayerArray.append(_Obj.return_color_layer(0))
				for _i in int(_Obj.Liquid_Count):
					_LayerArray.append(_Obj.return_color_layer(_i + 1))
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Is_Mix": _Obj.Is_Mix,
				"Can_Mix": _Obj.Can_Mix,
				"SugarType": _Obj.SugarType,
				"LIQUID_DIR": _Obj.LIQUID_DIR,
				"LIQUID_ARRAY": _Obj.LIQUID_ARRAY,
				"WaterCelcius": _Obj.WaterCelcius,
				"cur_ID": 0,
				"Liquid_Count": _Obj.Liquid_Count,
				"Extra_1": _Obj.Extra_1,
				"Extra_2": _Obj.Extra_2,
				"Extra_3": _Obj.Extra_3,
				"Condiment_1": _Obj.Condiment_1,
				"Condiment_2": _Obj.Condiment_2,
				"Condiment_3": _Obj.Condiment_3,
				"IsPassDay": _Obj.IsPassDay,
				"IsPack": _Obj.IsPack,
				"LayerArray": _LayerArray,
				"Pop": _Obj.Pop,
				"_FREEZERBOOL": _Obj._FREEZERBOOL,
				"IsStale": _Obj.IsStale,
			}
		"DrinkCup", "EggRollCup", "BeerCup":

			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Is_Mix": _Obj.Is_Mix,
				"MixInt": _Obj.MixInt,
				"Can_Mix": _Obj.Can_Mix,
				"SugarType": _Obj.SugarType,
				"LIQUID_DIR": _Obj.LIQUID_DIR,
				"LIQUID_ARRAY": _Obj.LIQUID_ARRAY,
				"WaterCelcius": 25,
				"cur_ID": 0,
				"Liquid_Count": _Obj.Liquid_Count,
				"Extra_1": _Obj.Extra_1,
				"Extra_2": _Obj.Extra_2,
				"Extra_3": _Obj.Extra_3,
				"Condiment_1": _Obj.Condiment_1,
				"Condiment_2": _Obj.Condiment_2,
				"Condiment_3": _Obj.Condiment_3,
				"IsPassDay": _Obj.IsPassDay,
				"IsStale": _Obj.IsStale,

			}
			pass
		"SuperCup":

			var _NAME = str(_Obj.get_instance_id())

			var _x = _Obj.LIQUID_ARRAY
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Is_Mix": _Obj.Is_Mix,
				"Can_Mix": _Obj.Can_Mix,
				"SugarType": _Obj.SugarType,
				"LIQUID_DIR": _Obj.LIQUID_DIR,
				"LIQUID_ARRAY": _Obj.LIQUID_ARRAY,
				"WaterCelcius": 25,
				"cur_ID": 0,
				"Liquid_Count": _Obj.Liquid_Count,
				"Extra_1": _Obj.Extra_1,
				"Extra_2": _Obj.Extra_2,
				"Extra_3": _Obj.Extra_3,
				"Extra_4": _Obj.Extra_4,
				"Extra_5": _Obj.Extra_5,
				"Condiment_1": _Obj.Condiment_1,
				"Condiment_2": _Obj.Condiment_2,
				"Condiment_3": _Obj.Condiment_3,
				"IsPassDay": _Obj.IsPassDay,
				"IsStale": _Obj.IsStale,
			}
		"Can":

			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Num": _Obj.Num,
				"IsOpen": _Obj.IsOpen,
				"CanUse": _Obj.CanUse,
				"IsPassDay": _Obj.IsPassDay,
				"Freshless_bool": _Obj.Freshless_bool,
			}
		"Sugar", "Choco", "Cooker", "FreeSugar", "EggRoll":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Used": _Obj.Used,
			}
		"Powder", "Pot", "CoffeeBean", "Cake":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Used": _Obj.Used,
				"Is_Storage": _Obj.Is_Storage,
				"Freshless_bool": _Obj.Freshless_bool,
				"IsPassDay": _Obj.IsPassDay,
			}
		"TeaLeaf":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"IsOpen": _Obj.IsOpen,
				"CurGram": _Obj.CurGram,
				"Freshless_bool": _Obj.Freshless_bool,

				}
		"Bottle", "Top", "Hang", "Pop":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Liquid_Count": _Obj.Liquid_Count,
				"IsOpen": _Obj.IsOpen,
				"Freshness": _Obj.Freshness,
				"Is_Storage": _Obj.Is_Storage,
				"Freshless_bool": _Obj.Freshless_bool,
				"IsPassDay": _Obj.IsPassDay,
				"FrozenBool": _Obj.FrozenBool,
				"WaterCelcius": _Obj.WaterCelcius,
			}
		"TeaBag":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"TypeStr": _Obj.TypeStr,
				"pos": _Obj.position,
			}
		"Fruit":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": "水果",
				"NAME": _NAME,
				"TypeStr": _Obj.TypeStr,
				"pos": _Obj.position,
				"IsBroken": _Obj.IsBroken,
			}
		"Water_Normal":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position
				}
		"WorkBoard":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Type": _Obj.ItemType,
				"Number": _Obj.SaveNodeList.size(),
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
			}
		"FreezerBox", "FreezerBig", "IceCreamMachine":
			var _NAME = str(_Obj.get_instance_id())

			var _A = null
			if is_instance_valid(_Obj.A_Box):
				_A = return_savedata(_Obj.A_Box)
			var _B = null
			if is_instance_valid(_Obj.B_Box):
				_B = return_savedata(_Obj.B_Box)
			var _X = null
			if is_instance_valid(_Obj.X_Box):
				_X = return_savedata(_Obj.X_Box)
			var _Y = null
			if is_instance_valid(_Obj.Y_Box):
				_Y = return_savedata(_Obj.Y_Box)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"A_Box": _A,
				"B_Box": _B,
				"X_Box": _X,
				"Y_Box": _Y,
			}

		"MopPool":
			var _NAME = str(_Obj.get_instance_id())
			var _MOPDATA
			if _Obj.HasMop:
				if _Obj.get_node("SavedNode").get_children():
					for _MOP in _Obj.get_node("SavedNode").get_children():
						_MOPDATA = return_savedata(_MOP)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"HasMop": _Obj.HasMop,
				"pos": _Obj.position,
				"Mop": _MOPDATA,
			}
		"Mop":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,

				"StainCount": _Obj.StainCount,
				"Color": _Obj._COLOR,
				"pos": _Obj.position,
			}
		"SnowShovel":
			var _NAME = str(_Obj.get_instance_id())
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,

				"pos": _Obj.position,
			}
		"GramScale":
			var _NAME = str(_Obj.get_instance_id())
			var _ITEMLIST: Array
			if _Obj.CurTeaBagList.size():
				for _OBJ in _Obj.CurTeaBagList:
					var _OBJDATA = return_savedata(_OBJ)
					_ITEMLIST.append(_OBJDATA)
			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"CurGram": _Obj.CurGram,
				"CurType": _Obj.CurType,
				"pos": _Obj.position,
				"TeaBagList": _ITEMLIST,
			}
		"IceCreamBox":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"MilkBool": _Obj.MilkBool,
				"CreamBool": _Obj.CreamBool,
				"FlavorType": _Obj.FlavorType,
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"IsFreezer": _Obj.IsFreezer,
				"Liquid_Count": _Obj.Liquid_Count,
				"CreamType": _Obj.CreamType,
				"WaterType": _Obj.WaterType,
			}

		"MaterialBox", "MaterialBig":
			var _NAME = str(_Obj.get_instance_id())

			_Data = {
				"TSCN": _ObjName,
				"NAME": _NAME,
				"pos": _Obj.position,
				"Type": _Obj.ItemType,
				"Number": _Obj.ItemArray.size(),
				"IsPassDay": _Obj.IsPassDay,
				"IsBroken": _Obj.IsBroken,
				"IsFreezer": _Obj.IsFreezer,
				"ItemFreshType": _Obj.ItemFreshType,
			}
		_:

			match _ObjName:

				"Box_M_Paper":
					var _NAME = str(_Obj.get_instance_id())

					var _BrokenDic: Dictionary
					for _OBJINBOX in _Obj.ItemOBJ_Array:
						var _TYPE = _OBJINBOX.TypeStr
						if _OBJINBOX.get("Freshless_bool"):
							_BrokenDic[_OBJINBOX.name] = 2
						elif _OBJINBOX.get("IsPassDay"):
							_BrokenDic[_OBJINBOX.name] = 1
						else:
							_BrokenDic[_OBJINBOX.name] = 0
					_Data = {
						"TSCN": _ObjName,
						"NAME": _NAME,
						"IsTrash": _Obj.IsTrash,
						"IsOpen": _Obj.IsOpen,
						"pos": _Obj.position,
						"HasItem": _Obj.HasItem,
						"ItemName": _Obj.ItemName,
						"ItemNum": _Obj.ItemOBJ_Array.size(),
						"ItemNameDIC": _Obj._ItemNameDic,
						"ItemBrokenDIC": _BrokenDic,
						"Type": _Obj.Type,
						"FreshType": _Obj._FreshType,
						"BuyDay": _Obj.BuyDay,
						}
				"Box_Wood":
					var _NAME = str(_Obj.get_instance_id())

					var _ObjIn = _Obj.DevOBJ
					var _ObjInData = null
					if _ObjIn:
						_ObjInData = return_savedata(_ObjIn)
					_Data = {
						"TSCN": _ObjName,
						"NAME": _NAME,
						"DevOBJ": _ObjInData,
						"pos": _Obj.position,
					}

				"OrderTab":
					var _NAME = str(_Obj.get_instance_id())
					_Data = {
						"TSCN": _ObjName,
						"NAME": _NAME,
						"pos": _Obj.position,
						"OFFSET": _Obj.OFFSET,
						}

				_:
					var _NAME = _Obj.name
					if _NAME in ["Mop_pool"]:

						_NAME = str(_Obj.get_instance_id())
						_Data = {
							"TSCN": "Mop",
							"NAME": _NAME,

							"StainCount": _Obj.StainCount,
							"Color": _Obj._COLOR,
							"pos": _Obj.position,
						}
					else:

						_NAME = str(_Obj.get_instance_id())
						_Data = {
							"TSCN": _ObjName,
							"NAME": _NAME,
							"pos": _Obj.position
							}
	return _Data

func call_load_objinfo(_Obj, _Info):

	var _ObjName = _Obj.TypeStr
	var _functype = _Obj.FuncType
	if _Obj.has_method("call_load"):
		_Obj.call_load(_Info)

func load_external_png(filepath: String):
	var f = File.new()
	f.open(filepath, File.READ)
	var buffer = f.get_buffer(f.get_len())
	f.close()
	var img = Image.new()
	if img.load_png_from_buffer(buffer) != 0:
		print("Error,LoadImage Failure.")
		return
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	return texture
