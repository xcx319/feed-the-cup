extends Node

onready var Audio = $Audio
onready var LoadingUI = $LoadingUI
onready var Save = $Save
onready var TSCNLoad = $TSCNLoad
onready var Config = $Config
onready var Astar = $Astar
onready var NPC = $NPC
onready var Staff = $Staff
onready var Order = $Order
onready var Liquid = $Liquid
onready var Device = $Device
onready var Buy = $Buy
onready var GlobalData = $GlobalData
onready var ScreenSet = $ScreenSet
onready var Day = $Day
onready var Formula = $Formula
onready var GameUI = $GameUI

onready var Con = $Control

onready var Skill = $Skill
onready var Card = $Card
onready var Tutorial = $Tutorial
onready var Info = $Info
onready var Achievement = $Achievement
onready var NetWork = $NetWork

var cur_Choose: bool
onready var CardTrans = Translation.new()
var Audio_ComboBreak
var _MONEYCHECK: float = 0
var _MONEYCHECKMULT: float = 2.1
var _MC: Vector2

var player_1P = null
var player_2P = null
var player_1P_ID: int
var player_2P_ID: int
var JoinPlayer: int
var Player2_bool: bool

var P1_Pressure_Max: int = 0
var P2_Pressure_Max: int = 0

var InHome_Bool: bool
var ShowLevel_bool: bool
var ComputerLevel_bool: bool
var DEMO_bool: bool = false

var AwaitMasterLoad: bool = false

var Level_bool: bool
var cur_Level_Update: Array
var cur_Update_Name: Array

var curLevelList: Array
var cur_size: int
var cur_Rent: int
var cur_Rent_Mult: int = 0
var CustomerTypeList: Array = ["MarkCup", "BritishCup", "PaperCup", "BigBottle", "BilateralCup"]
var cur_levelRank: int = 1
var cur_NPC_Rank: int = 1
var Traffic_Array: Array = [5, 5, 5, 5, 5, 10, 10, 10, 10, 20, 30, 40, 40, 40, 40, 40, 30, 30, 30, 30, 20, 10, 5, 4]
var MissionComplete_bool: bool = false
var cur_PurchaseMult: float = 1.0
var cur_OpenTime: float = 12
var cur_CloseTime: float = 22

var cur_MAILNUM: int = 0

var cur_PV: int
var cur_Item_List: Dictionary
var cur_Dev_Info: Dictionary

var cur_SellMenu: String = ""
var LastSellID: int
var cur_Quick: int
var cur_Combo: int
var cur_ComboMax: int
var cur_CustomerNum: int
var cur_NoOrderNum: int
var cur_NoSellNum: int
var cur_Perfect: int
var cur_Good: int
var cur_Bad: int
var cur_SellNum: int
var cur_Quickly: int
var cur_Skipping: int
var cur_Nearly: int
var cur_Cri: int
var cur_EarlyTime: float = 1
var cur_BuyNum: int
var cur_Ice: int
var cur_Sugar: int
var cur_AngryOrder: int
var cur_SkipID: int
var cur_QuickAndSkip: int
var cur_NearTime: float

var Cost_Items: int
var Cost_Fine: int

var cur_Player_Unlock: Array = [0]
var cur_Day: int = 0
var cur_money: int
var cur_money_home: float
var cur_HOMEMONEY: Vector2
var cur_EggCoin: float
var cur_ReDrawCoin: int
var Level_Data: Dictionary
var NPC_Data: Dictionary
var cur_LevelDifficult: Array
var cur_FreshBool: bool

var cur_level: String
var cur_levelInfo: Dictionary
var new_bool: bool
var Can_Card: bool
var Can_ESC: bool = true setget _CANESC

var FirstOpen: bool = true

var SPECIALLEVEL_Int: int = 0
var SPECIAL_NUM: int = 0

var cur_EggList: Array

func call_StatisticsData_Set(_TYPE, _ID, _NUM):
	if SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		GameLogic.CHEATINGBOOL = false
	if not GameLogic.CHEATINGBOOL and _NUM > 0:
		if _ID == null:
			if GameLogic.Save.statisticsData.has(_TYPE):
				GameLogic.Save.statisticsData[_TYPE] += _NUM
			else:
				GameLogic.Save.statisticsData[_TYPE] = _NUM
		elif GameLogic.Save.statisticsData.has(_TYPE):
			if GameLogic.Save.statisticsData[_TYPE].has(_ID):
				GameLogic.Save.statisticsData[_TYPE][_ID] += _NUM
				return
			GameLogic.Save.statisticsData[_TYPE][_ID] = _NUM

func _CANESC(_ESC):

	Can_ESC = _ESC

var Card_1: String
var Card_2: String
var Card_3: String

var cur_DayType: String
var cur_Rewards: Array
var cur_Challenge: Dictionary

var Challenge_1: String
var Challenge_2: String
var Challenge_3: String
var Reward_1: String
var Reward_2: String
var Reward_3: String
var cur_Event: String
var cur_Popularity: int
var cur_Popularity_Level: int
var cur_Gift: int
var cur_Devil: int
var Can_Formula: bool
var Can_Start: bool
var P1_Pressure: int = 0
var P2_Pressure: int = 0
var Pressure_List: Array = []
var PressureDic: Dictionary

var cur_StoreValue: int
var cur_StorePopular: int
var cur_StoreStar: int
var cur_Menu: Array
var cur_MenuNum: int
var cur_ExtraNum: int = 0

var cur_Extra: Array
var cur_Buy: Array
var cur_Update: Array
var cur_OrderMax: int = 1
var cur_NewFormulaList: Array
var cur_NeedClean: bool
var GameOverType: int = 0

var HomeMoneyKey: int = 1000000
var EggCoinKey: int = 2555
var _RANDOM = RandomNumberGenerator.new()

var _SubStationRANDOM = RandomNumberGenerator.new()
var _SubRANDOM = RandomNumberGenerator.new()
var _EggRANDOM = RandomNumberGenerator.new()
var cur_Staff: Dictionary

var Money_Sell: int
var Money_Tip: int
var Money_Other: int

var level_CustomerTotal: int
var level_SellTotal: int
var level_MoneyTotal: int
var level_ProfitTotal: int
var level_MoneyCostTotal: int
var level_StorePopular: int
var level_OpenGiftTotal: int
var level_Perfect: int
var level_Good: int
var level_Bad: int
var level_Lose: int
var level_Quickly: int
var level_Skipping: int
var level_Nearly: int
var level_NoOrder: int
var level_Cri: int
var level_DevilLevel: int = 0
var level_EXP_Base: float = 0
var level_BuyUpdate: int = 0

var Day_Perfect: int

var Day_JustCri: int = 0
var Day_JustJump: int = 0
var Day_SellSameNum: int = 0
var Day_SellDiffNum: int = 0

var CHEATINGBOOL: bool = false
func call_MoneyOther_Change(_Value, _KEY = 0):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _KEY != HomeMoneyKey:
		return

	Money_Other += _Value
	level_MoneyTotal += _Value
	level_ProfitTotal += _Value

	call_MoneyChange(_Value, GameLogic.HomeMoneyKey)

var cur_Menu_Unlock: Array

var Price_Electricity: float = 1
var Price_Water: float = 0.5
var Player2_Mult: float = 2

var Total_Water: float
var Total_Electricity: float

var AllStaff: Array

var Pressure_Nosell: int = 5
var Pressure_NoOrder: int = 5
var Pressure_BadSell: int = 2
var Pressure_NoOrderName: int = 0
var Pressure_Order: int = - 1
var Pressure_Sell: int = - 3
var Pressure_PerfectEndDay: int = - 5
var Pressure_OT: int = 2
signal NewInfo(_Type, _Info)
signal NewNetInfo(_Type, _Info, _SteamID)
signal MoneyChange(_value)
signal MoneyHomeChange(_value)
signal EggCoinChange(_value)
signal DevilCoinChange()
signal Pressure_Mult(_Mult)
signal Pressure_Set(_value)
signal Pressure_reset()
signal CanStart()

signal CallChallenge(_Switch)
signal CallFormula()
signal OpenLight()
signal CloseLight()

signal PopularSYCN()
signal Popularity()
signal GameOver(_Complete_Bool, FirstBool)
signal SYNC
signal RewardUI
signal NewDay
signal Reward
signal DayStart
signal OpenStore
signal ChooseFinish
signal Delivery
signal OrderQTE
signal OPTIONSYNC

var IsBlackOut: bool = false
var BlackOutTime: float = 0.5
signal BlackOut(_Switch)
signal Run(_ID, _TYPE)
signal NoPerfect
signal NPCLOGIC(_ID, _TYPE, _VALUE)
signal TimeCheck
signal EQUIPCHANGE
signal RecycleID(_ID)
signal CallRecycle
enum GAMEPLAY{
	Bear
	Wolf
	Fox
}

var QTEDic: Dictionary

var Popular_Day: float = 0
var WrongInfo: Array
enum WRONGTYPE{
	NONE
	ICEMACHINE
	TRASHBIN
	TRASHBAG
	INDUCTIONCOOKER
	TEAPORT
	WATERPORT
	DRINKCUP
	BOX
	ITEM
	STEAMMACHINE
	STAIN
	MATERIALBOX
	BIGPOT
	MILKPOT
	BOBAMACHINE
	JUICEMACHINE
	FRUITCORE
	TRASHITEM
	BARREL
	EGGROLLPOT
}

var _ACCELERATION_ARRAY: Array = [50, 10, 5, 2.5]
var _FRICTION_ARRAY: Array = [20000, 3500, 2000, 1000, 500, 300, 200, 100]

var SKILLDIC: Dictionary
var SPECIAL_DAY: Array = ["地铁"]

func _ready() -> void :
	set_message_translation(true)
	Physics2DServer.set_collision_iterations(1)


	call_deferred("_Tran_Logic")

func _Tran_Logic():
	GameLogic.GlobalData.call_read_Steam_Language()
func call_puppet_StoreStar(_Star, _Rank):
	cur_StoreStar = _Star
	cur_NPC_Rank = _Rank
func call_StoreStar_Logic():
	var _DayPopular: int = 0
	if GameLogic.cur_Day > 0:
		_DayPopular = GameLogic.cur_Day - 1
	var _INFO = GameLogic.cur_levelInfo

	var _POPULAR = 0
	if _INFO.has("Popular"):
		_POPULAR = int(_INFO.Popular)
	cur_StorePopular = _POPULAR + _DayPopular

	cur_StoreStar = cur_StorePopular
	if _INFO.has("StarMax"):
		if cur_StoreStar > int(_INFO.get("StarMax")):
			cur_StoreStar = int(_INFO.get("StarMax"))
	if cur_StoreStar <= 2:

		cur_NPC_Rank = 1
	elif cur_StoreStar <= 4:

		cur_NPC_Rank = 2
	elif cur_StoreStar <= 6:

		cur_NPC_Rank = 3
	elif cur_StoreStar <= 8:

		cur_NPC_Rank = 4
	elif cur_StoreStar <= 10:

		cur_NPC_Rank = 5

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_StoreStar", [cur_StoreStar, cur_NPC_Rank])
	emit_signal("PopularSYCN")
func call_Recycle(_ID):
	emit_signal("RecycleID", _ID)
func call_RecycleFinish():
	emit_signal("CallRecycle")
func call_EquipChange():
	emit_signal("EQUIPCHANGE")
func call_NoPerfect():
	emit_signal("NoPerfect")
func call_Run(_ID: int, _TYPE: int = 0):
	emit_signal("Run", _ID, _TYPE)
func call_NPCLOGIC(_ID, _TYPE, _VALUE):
	emit_signal("NPCLOGIC", _ID, _TYPE, _VALUE)
func call_BlackOut():

	if not IsBlackOut:
		IsBlackOut = true
		emit_signal("BlackOut", true)

func call_BlackOut_Over():

	emit_signal("BlackOut", false)
func call_Pressure_Set(_Value: int, _Type: int = 0):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Pressure_Set", [_Value, _Type])
	emit_signal("Pressure_Set", _Value, _Type)
func call_Pressure_Mult(_Value):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Pressure_Mult", [_Value])
	emit_signal("Pressure_Mult", _Value)

signal Pressure_Test(_TYPE)
func call_Pressure_Test(_TYPE: int):
	emit_signal("Pressure_Test", _TYPE)

func call_puppet_Popular(_cur_Popularity, _Value):
	cur_Popularity = _cur_Popularity
	emit_signal("Popularity", _Value)
func return_Popular(_Value, _KEY = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	var _VALUE = _Value
	if _Value > 0:

		var _PLAYERNUMMULT: float = return_Multiplayer()

		_VALUE = int(float(_Value) * _PLAYERNUMMULT + 0.5)




		if GameLogic.Achievement.cur_EquipList.has("声望提升") and not GameLogic.SPECIALLEVEL_Int:
			var _Plus = int(float(_VALUE) * 0.2)
			if _Plus < 1:
				_Plus = 1
			_VALUE += _Plus
		if GameLogic.cur_Event == "声望日":

			_VALUE += _VALUE * 0.25
		elif GameLogic.cur_Event == "声望日+":

			_VALUE += _VALUE * 0.5
		elif GameLogic.cur_Event == "声望日++":

			_VALUE += _VALUE
	if _VALUE <= 0:
		return 0
	_VALUE = int(_VALUE)
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return _VALUE
	cur_Popularity += _VALUE
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Popular", [cur_Popularity, _VALUE])
	emit_signal("Popularity", _VALUE)
	return _VALUE
func call_Delivery_Puppet(_ITEMLIST, _BUYARRAY):
	cur_Item_List = _ITEMLIST
	Buy.buy_Array = _BUYARRAY
func call_Delivery():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Delivery_Puppet", [cur_Item_List, Buy.buy_Array])
	emit_signal("Delivery")
func call_puppet_OpenStore():
	emit_signal("OpenStore")
func call_OPTIONSYNC():
	emit_signal("OPTIONSYNC")
func call_OpenStore():
	var _Pre: int = 0
	var _PreMult: int = 0
	if GameLogic.cur_Rewards.has("提前开店减压"):
		if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
			GameLogic.call_Info(1, "提前开店减压")
			_PreMult -= 10

	if GameLogic.cur_Rewards.has("提前开店减压+"):
		if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
			GameLogic.call_Info(1, "提前开店减压+")
			_PreMult -= 20

	if GameLogic.cur_Challenge.has("早班加班"):
		if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
			GameLogic.call_Info(2, "早班加班")
			_Pre += 2
	if GameLogic.cur_Challenge.has("早班加班+"):
		if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
			GameLogic.call_Info(2, "早班加班+")
			_Pre += 4
	if GameLogic.Achievement.cur_EquipList.has("每日放松") and not GameLogic.SPECIALLEVEL_Int:
		_PreMult -= 5
	if _Pre != 0:
		GameLogic.call_Pressure_Set(_Pre)
	if _PreMult != 0:
		call_Pressure_Mult(_PreMult)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(GameLogic, "call_puppet_OpenStore")
	emit_signal("OpenStore")
func call_DayStart():



	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	GameLogic.Order.call_SugarFree_Check()
	GameLogic.NPC.NPCNUM = 0
	GameLogic.LoadingUI.BGM_logic()
	SKILLDIC.clear()
	SteamLogic.call_OBJECT_Check()
	GameLogic.call_StoreStar_Logic()
	GameUI.DayEnd = false
	GameUI.call_UI_init()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_DayStart_puppet", [cur_Menu, cur_Item_List, cur_money, PressureDic, cur_Event])
		SteamLogic.call_PLAYER_SYNC()
	_DayOver_Bool = false
	emit_signal("DayStart")
	if cur_Day <= 1 or GameLogic.SPECIALLEVEL_Int:
		GameLogic.call_PlayerNum_Save()
	SteamLogic.JOIN.call_Master_WaitEnd()
	GameLogic.call_Reward()

func call_DayStart_puppet(_MENU, _LIST, _cur_money, _PRESSUREDIC, _cur_Event):
	SteamLogic.PuppetPreDic = _PRESSUREDIC
	GameLogic.LoadingUI.BGM_logic()
	cur_money = _cur_money
	SteamLogic.call_OBJECT_Check()
	cur_Menu = _MENU
	cur_Item_List = _LIST
	SKILLDIC.clear()
	GameLogic.call_StoreStar_Logic()
	GameUI.DayEnd = false
	GameUI.call_UI_init()
	emit_signal("DayStart")

	GameLogic.LoadingUI.BGM_logic()
	SteamLogic.JOIN.call_Master_WaitEnd()
	GameLogic.Order.call_SugarFree_Check()
	GameLogic.cur_Event = _cur_Event

func call_OpenLight():
	emit_signal("OpenLight")
func call_Reward():
	emit_signal("Reward")
func call_RewardUI():
	emit_signal("RewardUI")
func call_NewDay():
	emit_signal("NewDay")

func call_SYNC():
	emit_signal("SYNC")

func call_reset_pressure():
	emit_signal("Pressure_reset")
func call_Formula():
	emit_signal("CallFormula")
	call_start_check()
func call_ChooseFinish():
	emit_signal("ChooseFinish")
func call_TimeCheck():
	emit_signal("TimeCheck")
func call_challenge(_switch: bool = false):
	emit_signal("CallChallenge", _switch)

func call_Info(_Type, _Info, _Num = null, _CHECK: bool = false):
	if _CHECK:
		_CHECK = GameLogic.return_bool_MaxCheck(int(_Num))
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Info", [_Type, _Info, _Num, _CHECK])
	emit_signal("NewInfo", _Type, _Info, _Num, _CHECK)
func call_NetInfo(_Type, _Info, _SteamID):
	emit_signal("NewNetInfo", _Type, _Info, _SteamID)
func call_start_check():
	if cur_level:
		Can_Start = true
	else:
		Can_Start = false

	emit_signal("CanStart")
func call_puppet_MoneyChange(_cur_money, _value):

	cur_money = _cur_money
	emit_signal("MoneyChange", _value)

func call_MoneyChange(_value, _KEY = 0):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	if _KEY != GameLogic.HomeMoneyKey:
		return


	cur_money += int(_value)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_MoneyChange", [cur_money, _value])
	emit_signal("MoneyChange", _value)

func call_ReDrawCoinChange():
	emit_signal("DevilCoinChange")
func call_EggCoinChange(_value):
	if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
		return
	if cur_EggCoin > 0:
		cur_EggCoin = cur_EggCoin / float(EggCoinKey)
	if _value != 0:
		cur_EggCoin += float(_value) / float(EggCoinKey)

	if GameLogic.Save.gameData.HomeDevList.has("扭蛋币扩充+"):
		if int(round(cur_EggCoin * EggCoinKey)) > 99999:
			cur_EggCoin = 99999 / float(EggCoinKey)
	elif GameLogic.Save.gameData.HomeDevList.has("扭蛋币扩充"):
		if int(round(cur_EggCoin * EggCoinKey)) > 9999:
			cur_EggCoin = 9999 / float(EggCoinKey)
	else:
		if int(round(cur_EggCoin * EggCoinKey)) > 999:
			cur_EggCoin = 999 / float(EggCoinKey)
	if cur_EggCoin < 0:
		cur_EggCoin = 0
	emit_signal("EggCoinChange", _value)
	pass
func call_MoneyHomeChange(_value, _KEY = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return false


	var _V: float = float(_value) / 1000000

	var _HMKvalue = return_HMK(_value)
	cur_HOMEMONEY += _HMKvalue
	GameLogic.Save.gameData["cur_HOMEMONEY"] = cur_HOMEMONEY

	emit_signal("MoneyHomeChange", _value)
	return true

func call_NewGame():

	_MC = Vector2.ZERO
	Level_bool = false
	cur_level = ""
	cur_Day = 0
	cur_ReDrawCoin = 0

	Save.gameData.Bool_InLevel = true
	cur_Popularity = 0
	cur_Popularity_Level = 0
	cur_Gift = 0
	GameOverType = 0

	cur_Staff.clear()
	var _SPECIAL_INT = GameLogic.SPECIALLEVEL_Int
	if SteamLogic.IsJoin:
		_SPECIAL_INT = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if not _SPECIAL_INT:
		cur_Rewards.clear()
	cur_Event = ""
	Can_Start = false

	cur_Extra.clear()
	cur_Update.clear()
	Can_Formula = false

	cur_ExtraNum = 0
	Cost_Fine = 0

	_Level_Total_Init()
	call_save()
func call_statistics_save():

	GameLogic.Save.call_Statistics_Check()
	GameLogic.call_StatisticsData_Set("Count_Day", null, cur_Day)

	GameLogic.call_StatisticsData_Set("Count_Money", null, level_MoneyTotal)

	GameLogic.call_StatisticsData_Set("Count_MoneyCost", null, level_MoneyCostTotal)

	GameLogic.call_StatisticsData_Set("Count_SellCup", null, level_SellTotal)

	if level_OpenGiftTotal > GameLogic.Save.statisticsData["Max_OpenGift"]:
		GameLogic.Save.statisticsData["Max_OpenGift"] = level_OpenGiftTotal

	if GameOverType == 0:
		GameLogic.call_StatisticsData_Set("Count_Victories", null, 1)

	else:
		GameLogic.call_StatisticsData_Set("Count_Fail", null, 1)

func call_LevelFinished_puppet():
	GameOverType = 0
	MissionComplete_bool = false
	cur_money = 0

	cur_level = ""
	cur_Day = 0
	cur_Item_List.clear()
	cur_Staff.clear()
	cur_Menu.clear()
	cur_Extra.clear()

	cur_Challenge.clear()
	Buy.buy_Array.clear()
	cur_Update.clear()

	cur_Rewards.clear()
	cur_Event = ""
	Level_bool = false
	Can_Card = false

	Can_Formula = false
	call_Formula()

	_Level_Total_Init()
	cur_Popularity = 0
	cur_Popularity_Level = 0
	cur_Gift = 0


	Save.levelData["cur_level"] = ""
	P1_Pressure = 0
	P2_Pressure = 0
	PressureDic.clear()

	Cost_Fine = 0
	Save.gameData.Bool_InLevel = true
	GameOverType = 0


	GameUI.call_InHome()
func call_NewLevel_Init():

	_MC = Vector2.ZERO
	_MONEYCHECK = 0
	GameOverType = 0
	MissionComplete_bool = false
	cur_money = 0

	cur_level = ""
	cur_Day = 0
	cur_Item_List.clear()
	cur_Staff.clear()
	cur_Menu.clear()
	cur_Extra.clear()

	GameLogic.Order.SUGAR_FREE_BOOL = false
	Buy.buy_Array.clear()
	cur_Update.clear()

	var _SPECIAL_INT = GameLogic.SPECIALLEVEL_Int
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_SPECIAL_INT = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if not _SPECIAL_INT:
		cur_Rewards.clear()
		cur_Challenge.clear()
	cur_Event = ""
	Level_bool = false
	Can_Card = false

	Can_Formula = false
	call_Formula()

	_Level_Total_Init()
	cur_Popularity = 0
	cur_Popularity_Level = 0
	cur_Gift = 0


	Save.levelData["cur_level"] = ""
	P1_Pressure = 0
	P2_Pressure = 0
	PressureDic.clear()

	Cost_Fine = 0
	Save.gameData.Bool_InLevel = true
	GameOverType = 0


	var _rand = randi() % 100000000000
	Save.gameData.Rand_Hash = str(_rand)
	_RANDOM.seed = Save.gameData.Rand_Hash.hash()

	Save.gameData["Rand_State"] = _RANDOM.state

	_EggRANDOM.seed = Save.gameData.Rand_Hash.hash()
	Save.gameData["Rand_EggState"] = _EggRANDOM.state

func call_LevelFinished():


	call_statistics_save()

	if Player2_bool and GameOverType == 0:
		GameLogic.Save.statisticsData["Count_2P"] += 1

	_MC = Vector2.ZERO
	_MONEYCHECK = 0
	GameOverType = 0
	MissionComplete_bool = false
	cur_money = 0

	cur_level = ""
	cur_Day = 0
	cur_Item_List.clear()
	cur_Staff.clear()
	cur_Menu.clear()
	cur_Extra.clear()


	Buy.buy_Array.clear()
	cur_Update.clear()

	cur_Event = ""
	Level_bool = false
	Can_Card = false

	Can_Formula = false
	call_Formula()

	_Level_Total_Init()
	cur_Popularity = 0
	cur_Popularity_Level = 0
	cur_Gift = 0


	Save.levelData["cur_level"] = ""
	P1_Pressure = 0
	P2_Pressure = 0
	PressureDic.clear()

	Cost_Fine = 0
	Save.gameData.Bool_InLevel = true
	GameOverType = 0


	GameUI.call_InHome()


func _Level_Total_Init():
	level_SellTotal = 0
	level_CustomerTotal = 0
	level_MoneyTotal = 0
	level_ProfitTotal = 0
	level_MoneyCostTotal = 0
	level_OpenGiftTotal = 0
	level_Perfect = 0
	level_Good = 0
	level_Bad = 0
	level_Nearly = 0
	level_Quickly = 0
	level_Skipping = 0
	level_Cri = 0
	level_EXP_Base = 0
	level_BuyUpdate = 0
	level_Lose = 0
	level_NoOrder = 0

func _dayinfo_init():
	cur_Day += 1
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.LOBBY_gameData.has("cur_EquipList"):
			GameLogic.Achievement.cur_EquipList = SteamLogic.LOBBY_gameData["cur_EquipList"]
		SteamLogic.LevelDic.Day = cur_Day
	if cur_Day == 1:
		cur_ReDrawCoin = 0
		if not GameLogic.SPECIALLEVEL_Int:
			if GameLogic.Save.gameData.HomeDevList.has("风扇"):
				cur_ReDrawCoin += 1
			if GameLogic.Save.gameData.HomeDevList.has("挂式空调"):
				cur_ReDrawCoin += 1
			if GameLogic.Save.gameData.HomeDevList.has("冰箱"):
				cur_ReDrawCoin += 1
			if GameLogic.Save.gameData.HomeDevList.has("立式空调"):
				cur_ReDrawCoin += 1
			if GameLogic.Save.gameData.HomeDevList.has("净化器"):
				cur_ReDrawCoin += 1

	IsBlackOut = false
	GameUI.cur_BlackOut = 0
	cur_SellMenu = ""
	cur_Quick = 0

	GameLogic.Buy.buy_Array.clear()

	GameLogic.GameUI.OrderNode.Order_SellCount = 0


	Day_Perfect = 0
	Day_JustCri = 0
	Day_JustJump = 0
	Day_SellSameNum = 0
	Day_SellDiffNum = 0

	Money_Sell = 0
	Money_Tip = 0
	Money_Other = 0
	Cost_Items = 0

	Total_Water = 0

	Total_Electricity = 0
	Cost_Fine = 0
	cur_CustomerNum = 0
	cur_NoOrderNum = 0
	cur_NoSellNum = 0
	cur_SellNum = 0
	cur_Perfect = 0
	cur_Good = 0
	cur_Bad = 0
	cur_Skipping = 0
	cur_Nearly = 0
	cur_Quickly = 0
	cur_Cri = 0
	cur_Ice = 0
	cur_Sugar = 0
	cur_AngryOrder = 0
	LastSellID = 0
	cur_SkipID = 0

	cur_ComboMax = 0
	if Save.levelData.has("COMBO"):
		cur_Combo = int(Save.levelData.COMBO)
	if cur_Rewards.has("永生花"):
		cur_Combo = int(float(cur_Combo) * 0.5)
		call_combo(0)
		GameLogic.call_Info(1, "永生花")
	elif cur_Rewards.has("永生花+"):
		cur_Combo = int(float(cur_Combo) * 1)
		call_combo(0)
		GameLogic.call_Info(1, "永生花+")
	else:
		GameUI.Combo.call_DayStart()



	Order.call_init()
	call_Time_Init()
func call_Time_Init():


	var _INFO = cur_levelInfo
	cur_OpenTime = float(_INFO.OpenTime)
	if GameLogic.SPECIALLEVEL_Int:
		cur_CloseTime = float(_INFO.CloseTime)
	elif _INFO.GamePlay.has("每日增加半小时"):
		cur_CloseTime = float(cur_OpenTime + 0.5 + float(cur_Day) * 0.5)
		if cur_CloseTime > float(_INFO.CloseTime):
			cur_CloseTime = float(_INFO.CloseTime)
	elif _INFO.GamePlay.has("每日增加一刻钟"):
		cur_CloseTime = float(cur_OpenTime + 1.5 + float(cur_Day) * 0.25)
		if cur_CloseTime > float(_INFO.CloseTime):
			cur_CloseTime = float(_INFO.CloseTime)
	elif _INFO.GamePlay.has("新手引导1"):
		cur_CloseTime = float(cur_OpenTime + 0.5 + float(cur_Day) * 0.25)
		if cur_CloseTime > float(_INFO.CloseTime):
			cur_CloseTime = float(_INFO.CloseTime)
	else:
		cur_CloseTime = float(_INFO.CloseTime)

func call_pressure(_type):
	match _type:
		"Night":
			var _LEVELINFO = GameLogic.cur_levelInfo

			if _LEVELINFO.GamePlay.has("新手引导1"):
				return
			var _Pressure = Pressure_OT
			if not GameLogic.SPECIALLEVEL_Int:
				if GameLogic.Save.gameData.HomeDevList.has("浴缸"):
					_Pressure -= 1
			if GameLogic.cur_Challenge.has("拒绝加班"):
				call_Info(2, "拒绝加班")
				_Pressure += 1
			if GameLogic.cur_Challenge.has("拒绝加班+"):
				call_Info(2, "拒绝加班+")
				_Pressure += 2
			if _Pressure > 0:
				call_Pressure_Set(_Pressure)

		"PerfectEndDay":

			var _Pressure = Pressure_PerfectEndDay

			if cur_Rewards.has("完美主义"):
				call_Info(1, "完美主义")
				call_Pressure_Mult( - 10)

			elif cur_Rewards.has("完美主义+"):
				call_Info(1, "完美主义+")
				call_Pressure_Mult( - 20)

		"BlockWay":
			var _check: bool = false
			if cur_Rewards.has("合理堆放+"):

				_check = true

			if not _check:
				var _Pressure = 1

				call_Pressure_Set(Pressure_OT)
		"SellItem":
			call_Pressure_Set(Pressure_OT, 1)
		"NoInventory":
			call_Pressure_Set(1, 2)

func call_new_Extra():
	cur_NewFormulaList.clear()

	var _FormulaList = GameLogic.Order.cur_LevelMenu
	var _FormulaKeys = _FormulaList.keys()
	call_StoreStar_Logic()
	var _CanPickList: Array
	var _WeightCount: int = 0
	var _Rank: int = (int(GameLogic.cur_StoreStar + 1)) * 2
	for i in _FormulaKeys.size():
		if _Rank >= int(_FormulaList[_FormulaKeys[i]].Rank):
			if not cur_Menu.has(_FormulaKeys[i]):
				_CanPickList.append(_FormulaKeys[i])
				_WeightCount += int(_FormulaList[_FormulaKeys[i]].Weight)

func return_CanPick():
	var _FormulaList = GameLogic.Order.cur_LevelMenu
	var _FormulaKeys = _FormulaList.keys()

	call_StoreStar_Logic()

	var _CanPickList: Array
	if GameLogic.cur_DayType == "小料":
		var _ExtraList: Array = GameLogic.Order.cur_ExtraMenu.keys()

		for _Extra in _ExtraList:

			if int(GameLogic.Config.FormulaConfig[_Extra].Rank) <= GameLogic.cur_StoreStar:

				if not GameLogic.cur_Menu.has(_Extra):

					_CanPickList.append(_Extra)
	elif GameLogic.cur_DayType in ["配方", "随机"]:
		var _WeightCount: int = 0
		var _Rank: int = GameLogic.cur_StoreStar
		for i in _FormulaKeys.size():
			if _Rank >= int(_FormulaList[_FormulaKeys[i]].Rank):
				if not cur_Menu.has(_FormulaKeys[i]):
					_CanPickList.append(_FormulaKeys[i])
					_WeightCount += int(_FormulaList[_FormulaKeys[i]].Weight)

	if _CanPickList.size() > 3:
		return true
	else:
		return false

func call_Formula_new(_Num: int):
	cur_NewFormulaList.clear()
	call_StoreStar_Logic()

	var _LEVELINFO = GameLogic.cur_levelInfo

	var _FormulaList = _LEVELINFO.MenuList
	for _Menu in _FormulaList:
		if int(float(GameLogic.Config.FormulaConfig[_Menu].Rank) / 2) <= cur_StoreStar:
			if not cur_Menu.has(_Menu):
				cur_NewFormulaList.append(_Menu)
	if not cur_NewFormulaList:
		call_new_formula(_Num)
func call_new_formula(_Num: int):
	cur_NewFormulaList.clear()
	var _FormulaList = GameLogic.Order.cur_LevelMenu
	var _FormulaKeys = _FormulaList.keys()

	call_StoreStar_Logic()
	var _CanPickList: Array
	var _WeightCount: int = 0
	var _Rank: int = GameLogic.cur_StoreStar
	for i in _FormulaKeys.size():

		if _Rank >= int(_FormulaList[_FormulaKeys[i]].Rank):
			if not cur_Menu.has(_FormulaKeys[i]):
				_CanPickList.append(_FormulaKeys[i])
				_WeightCount += int(_FormulaList[_FormulaKeys[i]].Weight)

	for i in _Num:
		if _WeightCount == 0 or _CanPickList.size() == 0:

			pass
		else:
			var _rand = GameLogic.return_randi() % _WeightCount

			for y in _CanPickList.size():
				var _Weight: int = int(_FormulaList[_CanPickList[y]].Weight)
				if _rand < _Weight:

					cur_NewFormulaList.append(_CanPickList[y])
					_CanPickList.erase(_CanPickList[y])
					_WeightCount -= _Weight
					break
				else:
					_rand -= _Weight

func call_puppet_dayover(_TYPE, _DayEndMoney):
	GameLogic.GameOverType = _TYPE
	match _TYPE:
		0:
			var _x = SteamLogic.LevelDic.Day
			var _y = SteamLogic.LevelDic.Difficult
			var _z = SteamLogic.LevelDic.cur_levelInfo
			if not SteamLogic.LevelDic.Difficult.size():
				SteamLogic.LevelDic.Difficult = SteamLogic.LevelDic.cur_levelInfo.Difficult
			if GameLogic.SPECIALLEVEL_Int:
				SteamLogic.LevelDic.IsFinish = true
			elif SteamLogic.LevelDic.Day >= SteamLogic.LevelDic.Difficult.size():
				SteamLogic.LevelDic.IsFinish = true
			else:
				SteamLogic.LevelDic.IsFinish = false
		_:
			SteamLogic.LevelDic.IsFinish = false
	Audio.call_BGM_close()

	WrongInfo.clear()
	emit_signal("CloseLight")




	Order.call_init()
	Can_Card = true
	Can_Formula = true
	if GameLogic.LoadingUI.IsLevel:
		GameLogic.Can_ESC = false
		get_tree().set_pause(true)



var _DayOver_Bool: bool
func call_dayover():

	if not _DayOver_Bool:
		_DayOver_Bool = true
	else:

		return
	call_StoreStar_Logic()

	WrongInfo.clear()



	var _DayEndMoney: int = 0


	if _DayEndMoney != 0:
		var _PayEffect = TSCNLoad.PayEffect_TSCN.instance()
		player_1P.EffectNode.add_child(_PayEffect)
		_PayEffect.call_init(_DayEndMoney, _DayEndMoney, 0, false, false, false, false)
		call_MoneyOther_Change(_DayEndMoney, GameLogic.HomeMoneyKey)

	player_1P.call_control(0)
	player_1P.Con._control_logic("L2", 1, - 1)
	if Player2_bool:
		player_2P.call_control(0)
		player_2P.Con._control_logic("L2", 1, - 1)

	player_1P.call_control(1)
	if Player2_bool:
		player_2P.call_control(1)


	Audio.call_BGM_close()

	emit_signal("CloseLight")
	Order.call_CleanOrder()


	Order.call_init()




	call_Formula_new(3)
	Card.call_new_card()



	Can_Card = true
	Can_Formula = true


	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_dayover", [GameLogic.GameOverType, _DayEndMoney])

	if GameLogic.LoadingUI.IsLevel:
		GameLogic.Can_ESC = false
		get_tree().set_pause(true)

		GameUI.call_DayEndUI_switch(true)


func call_gameover(_Complete_Bool: bool):

	GameLogic.cur_ExtraNum = 0
	var FirstPassReward: int = 0
	if SteamLogic.IsJoin:

		pass
	else:
		if cur_level == "":
			return
		match _Complete_Bool:
			true:


				if not Level_Data.has(cur_level):
					Level_Data[cur_level] = {
						"level_CustomerTotal": level_CustomerTotal,
						"level_MoneyTotal": level_MoneyTotal,
						"level_StorePopular": level_StorePopular,
						"level_SellTotal": level_SellTotal,
						"cur_Devil": cur_Devil,
						}
					FirstPassReward = int(GameLogic.cur_levelInfo.RewardList[0])
				else:
					if Level_Data[cur_level].has("level_CustomerTotal"):
						if level_CustomerTotal > Level_Data[cur_level]["level_CustomerTotal"]:
							Level_Data[cur_level]["level_CustomerTotal"] = level_CustomerTotal
					else:
						Level_Data[cur_level]["level_CustomerTotal"] = level_CustomerTotal
					if Level_Data[cur_level].has("cur_Day"):
						if cur_Day > Level_Data[cur_level]["cur_Day"]:
							Level_Data[cur_level]["cur_Day"] = cur_Day
					else:
						Level_Data[cur_level]["cur_Day"] = cur_Day
					if level_MoneyTotal > Level_Data[cur_level]["level_MoneyTotal"]:
						Level_Data[cur_level]["level_MoneyTotal"] = level_MoneyTotal
					if level_SellTotal > Level_Data[cur_level]["level_SellTotal"]:
						Level_Data[cur_level]["level_SellTotal"] = level_SellTotal
					if Level_Data[cur_level].has("cur_Devil"):
						if int(cur_Devil) > int(Level_Data[cur_level]["cur_Devil"]):
							Level_Data[cur_level]["cur_Devil"] = cur_Devil

							if GameLogic.cur_levelInfo.RewardList.size() > cur_Devil:
								FirstPassReward = int(GameLogic.cur_levelInfo.RewardList[cur_Devil])
								pass
					else:
						Level_Data[cur_level]["cur_Devil"] = cur_Devil
						FirstPassReward = int(GameLogic.cur_levelInfo.RewardList[0])

	emit_signal("GameOver", _Complete_Bool, FirstPassReward)
	call_start_check()

func call_dead_logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _PLAYERLIST = get_tree().get_root().get_node("Level/YSort/Players").get_children()
	var _CHECKLIST: Array
	for _PLAYER in _PLAYERLIST:
		if _PLAYER.has_method("_PlayerNode"):
			if _PLAYER.cur_Pressure >= _PLAYER.cur_PressureMax:
				if GameLogic.cur_Rewards.has("员工帽") or GameLogic.cur_Rewards.has("员工帽+"):
					if _PLAYER._Pressure_1_Bool:
						_CHECKLIST.append(true)
					else:
						_CHECKLIST.append(false)

				else:
					_CHECKLIST.append(true)
			else:
				_CHECKLIST.append(false)
	if not _CHECKLIST.has(false):
		GameOverType = 1
		call_dayover()

func call_Customer_add():
	cur_CustomerNum += 1
	level_CustomerTotal += 1

func call_NoOrderName_add(_NoPressure: bool):
	cur_NoOrderNum += 1
	level_NoOrder += 1


	if not _NoPressure:
		call_Pressure_Set(Pressure_NoOrderName)



func call_GoodSell(_NoPressure: bool):

	var _Pre: int = 0
	if not _NoPressure:

		if GameLogic.cur_Challenge.has("自我要求+"):
			call_Info(2, "自我要求+")
			_Pre += 2
	if _Pre != 0:
		call_Pressure_Set(_Pre)
func call_BadSell(_NoPressure: bool):
	var _Pre: int = Pressure_BadSell
	if cur_Devil == 0:
		_Pre = 1

	if not _NoPressure:
		if GameLogic.cur_Challenge.has("自我要求"):
			call_Info(2, "自我要求")
			_Pre += 1
		if GameLogic.cur_Challenge.has("自我要求+"):
			call_Info(2, "自我要求+")
			_Pre += 2
	if _Pre != 0:
		call_Pressure_Set(_Pre)
func call_NoOrder_add(_NoPressure: bool):
	cur_NoOrderNum += 1
	level_NoOrder += 1
	cur_Quick = 0
	Day_JustJump = 0

	if cur_Rewards.has("未点单COMBO"):
		call_Info(1, "未点单COMBO")
	elif cur_Rewards.has("未点单COMBO+"):
		call_Info(1, "未点单COMBO+")
	else:
		call_combo_break()


	if not cur_Rewards.has("未点单COMBO+"):
		if not _NoPressure:
			if cur_Devil == 0:
				call_Pressure_Set(3)
			else:
				call_Pressure_Set(Pressure_NoOrder)


func call_NoSell_add(_NoPressure):
	cur_NoSellNum += 1
	level_Lose += 1
	cur_Quick = 0
	Day_JustJump = 0


	if cur_Rewards.has("退单COMBO+"):
		call_Info(1, "退单COMBO+")
	else:
		if not _NoPressure:
			if cur_Devil == 0:
				call_Pressure_Set(3)
			else:
				call_Pressure_Set(Pressure_Nosell)

	if not cur_Rewards.has("退单COMBO") and not cur_Rewards.has("退单COMBO+"):
		call_combo_break()
	if cur_Rewards.has("退单COMBO"):
		call_Info(1, "退单COMBO")

func call_order():
	if cur_Event == " 点单员":
		var _Rand = GameLogic.return_randi() % 2
		if _Rand:
			call_Pressure_Set( - 1)

	if cur_Event == " 点单员+":
		call_Pressure_Set( - 1)


func call_Sell_add():

	if cur_Event == " 销售员":
		var _rand = GameLogic.return_randi() % 2
		if _rand:
			call_Pressure_Set( - 1)
	if cur_Event == " 销售员+":
		call_Pressure_Set( - 1)
	if AllStaff.size() > 0:
		for _Staff in AllStaff:
			if is_instance_valid(_Staff):
				if _Staff.Stat.Skills.has("出餐减压"):
					_Staff.call_pressure_set(Pressure_Sell)

func call_combo_break(_ANI_BOOL: bool = true):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if cur_Event == "连击日":
		return

	if cur_Rewards.has("高强链接"):
		for _PLAYER in AllStaff:
			if not is_instance_valid(_PLAYER):
				AllStaff.erase(_PLAYER)
			else:
				if _PLAYER.has_method("_Press_Logic"):
					_PLAYER._Press_Logic()
				if _PLAYER.HighPress:
					call_Info(1, "高强链接")
					return
	if cur_Combo > 0:
		cur_Combo = 0
		GameUI.Combo.call_combo(cur_Combo)
func call_combo(_Num: int, _BOOL: bool = true):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return


	if cur_Challenge.has("COMBO不增") and _Num > 0:
		var _rand = GameLogic.return_randi() % 4
		if _rand == 0:
			GameLogic.call_Info(2, "COMBO不增")
			return
	if cur_Challenge.has("COMBO不增+") and _Num > 0:
		var _rand = GameLogic.return_randi() % 2
		if _rand == 0:
			GameLogic.call_Info(2, "COMBO不增+")
			return

	cur_Combo += _Num
	if cur_Combo < 0:
		cur_Combo = 0
	if cur_Rewards.has("取票器") and _Num > 0:
		var _rand = GameLogic.return_randi() % 3
		if _rand == 0:
			GameLogic.call_Info(1, "取票器")
			cur_Combo += 1
	elif cur_Rewards.has("取票器+") and _Num > 0:
		var _rand = 0
		if _rand == 0:
			GameLogic.call_Info(1, "取票器+")
			cur_Combo += 1
	var _MAX: int = 99
	if cur_Rewards.has("取票器"):
		_MAX += 50
	elif cur_Rewards.has("取票器+"):
		_MAX += 100
	if cur_Rewards.has("连击达人"):
		_MAX += 100
	if cur_Rewards.has("飞来横财"):
		_MAX += 100
	if cur_Rewards.has("准时达"):
		_MAX += 100
	if cur_Rewards.has("极限手段"):
		_MAX += 100
	if cur_Rewards.has("冰点连击"):
		_MAX += 100
	if cur_Rewards.has("爆炸灯笼"):
		_MAX += 100
	if cur_Rewards.has("跳跃连击"):
		_MAX += 100
	if cur_Rewards.has("高强链接"):
		_MAX += 100
	if cur_Combo > _MAX:
		cur_Combo = _MAX
	if cur_Combo > cur_ComboMax:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Combo_Puppet", [cur_ComboMax])
		cur_ComboMax = cur_Combo
		if GameLogic.Save.statisticsData["Max_Combo"] < cur_ComboMax:
			GameLogic.Save.statisticsData["Max_Combo"] = cur_ComboMax
	GameUI.Combo.call_combo(cur_Combo)

func call_Combo_Puppet(_COMBOMAX):
	if GameLogic.Save.statisticsData["Max_Combo"] < _COMBOMAX:
		GameLogic.Save.statisticsData["Max_Combo"] = _COMBOMAX

func CustomerCheck():
	var _S: bool
	var _M: bool
	var _L: bool
	var _LEVELINFO = GameLogic.cur_levelInfo

	for _MENU in cur_Menu:
		if not Config.FormulaConfig.has(_MENU):
			return
		var _CupType = Config.FormulaConfig[_MENU].CupType
		match _CupType:
			"S":
				_S = true
			"M":
				_M = true
			"L":
				_L = true
	if _S:
		if not _LEVELINFO.CustomersList.has("LittleCup"):
			_LEVELINFO.CustomersList.append("LittleCup")
	else:
		if _LEVELINFO.CustomersList.has("LittleCup"):
			_LEVELINFO.CustomersList.erase("LittleCup")
	if _M:
		if not _LEVELINFO.CustomersList.has("MarkCup"):
			_LEVELINFO.CustomersList.append("MarkCup")
	else:
		if _LEVELINFO.CustomersList.has("MarkCup"):
			_LEVELINFO.CustomersList.erase("MarkCup")
	if _L:
		if not _LEVELINFO.CustomersList.has("PaperCup"):
			_LEVELINFO.CustomersList.append("PaperCup")
	else:
		if _LEVELINFO.CustomersList.has("PaperCup"):
			_LEVELINFO.CustomersList.erase("PaperCup")
	if not _LEVELINFO.CustomersList.size():
		_LEVELINFO.CustomersList.append("LittleCup")
	GameLogic.NPC.call_NPC_init()

func call_SceneConfig_load(_BOOL: bool = false):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	curLevelList.clear()
	GameLogic.Config._SceneConfig()

	var _Level = cur_level
	if not GameLogic.Config.SceneConfig.has(_Level):
		return

	var _SPECIAL_INT = GameLogic.SPECIALLEVEL_Int
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_SPECIAL_INT = SteamLogic.LevelDic.SPECIALLEVEL_Int
	if not _SPECIAL_INT or not GameLogic.LoadingUI.IsLevel:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			pass
		else:
			if not _BOOL:
				var _SecneData = GameLogic.Config.SceneConfig[_Level]
				var _Keys = _SecneData.keys()
				for i in _Keys.size():
					cur_levelInfo[_Keys[i]] = _SecneData[_Keys[i]]

	for i in cur_Devil:
		if cur_levelInfo.DevilList.size() >= i + 1:
			curLevelList.append(cur_levelInfo.DevilList[i])

	var _PV_LEVEL_PLUS: int = cur_Devil
	if GameLogic.SPECIALLEVEL_Int:
		_PV_LEVEL_PLUS -= 1
	if GameLogic.SPECIALLEVEL_Int in [2]:
		_PV_LEVEL_PLUS -= 1
	if curLevelList.has("难度-初始星级加2"):
		cur_levelInfo.Popular = int(GameLogic.Config.SceneConfig[_Level].Popular) + 2

	if curLevelList.has("难度-初始星级加3"):
		cur_levelInfo.Popular = int(GameLogic.Config.SceneConfig[_Level].Popular) + 3

	if curLevelList.has("难度-初始星级加4"):
		cur_levelInfo.Popular = int(GameLogic.Config.SceneConfig[_Level].Popular) + 4

	if curLevelList.has("难度-大瓶顾客"):
		if not cur_levelInfo.CustomersList.has("BigBottle"):
			cur_levelInfo.CustomersList.append("BigBottle")
		_PV_LEVEL_PLUS -= 1
	if curLevelList.has("难度-玻璃瓶顾客"):
		if not cur_levelInfo.CustomersList.has("GlassBottle"):
			cur_levelInfo.CustomersList.append("GlassBottle")

	if curLevelList.has("难度-英式茶杯顾客"):
		if not cur_levelInfo.CustomersList.has("BritishCup"):
			cur_levelInfo.CustomersList.append("BritishCup")

	if curLevelList.has("难度-双耳茶杯顾客"):
		if not cur_levelInfo.CustomersList.has("BilateralCup"):
			cur_levelInfo.CustomersList.append("BilateralCup")

	if curLevelList.has("难度-日式茶杯顾客"):
		if not cur_levelInfo.CustomersList.has("TeaCup"):
			cur_levelInfo.CustomersList.append("TeaCup")



	if curLevelList.has("难度-玻璃瓶"):

		if not cur_levelInfo.CustomersList.has("GlassBottle"):
			cur_levelInfo.CustomersList.append("GlassBottle")

	if curLevelList.has("难度-新增鲜柠汁M"):
		cur_levelInfo.M = true

		if not cur_levelInfo.CustomersList.has("MarkCup"):
			cur_levelInfo.CustomersList.append("MarkCup")

		if not GameLogic.cur_Menu.has("鲜柠汁M") and cur_Day <= 1:
			GameLogic.cur_Menu.append("鲜柠汁M")
	if curLevelList.has("难度-小变中"):
		cur_levelInfo.S = false
		cur_levelInfo.M = true
		cur_levelInfo.CustomersList = ["MarkCup"]
		if cur_levelInfo.Menu.has("净水S"):
			cur_levelInfo.Menu.erase("净水S")
			cur_levelInfo.Menu.append("净水M")
	if curLevelList.has("难度-顾客小增加"):
		_PV_LEVEL_PLUS += 1

	if curLevelList.has("难度-顾客中增加"):
		_PV_LEVEL_PLUS += 2

	if curLevelList.has("难度-顾客大增加"):
		_PV_LEVEL_PLUS += 3


	cur_levelInfo.PV = int(cur_levelInfo.PV) + _PV_LEVEL_PLUS

	CustomerTypeList = cur_levelInfo.CustomersList
	call_Traffic_Init()

	cur_PV = int(cur_levelInfo.PV)


	cur_size = int(cur_levelInfo.IndoorArea)
	cur_Rent = int(cur_levelInfo.Rent)
	GameUI.sellCount_ShowLogic()

func call_Traffic_Init():
	Traffic_Array.clear()
	var _Level = cur_level
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_Level = SteamLogic.LOBBY_levelData.cur_level
	for i in 24:
		if Config.SceneConfig.has(_Level):
			Traffic_Array.push_back(Config.SceneConfig[_Level][str(i)])
		else:
			break
	pass
func call_gameover_logic():

	if Save.gameData.Money <= 0:
		pass
func call_rand_set():

	if not Save.gameData.has("Rand_Hash"):
		var _rand = randi() % 100000000000
		Save.gameData["Rand_Hash"] = str(_rand)
		_RANDOM.seed = Save.gameData.Rand_Hash.hash()
		Save.gameData["Rand_State"] = _RANDOM.state
		Save.gameData["Rand_EggState"] = _EggRANDOM.state
	var _load = Save.gameData.Rand_Hash
	var _seed = _load.hash()
	_RANDOM.seed = _seed
	_EggRANDOM.seed = _seed

	if Save.gameData.has("Rand_State"):
		_RANDOM.state = Save.gameData.Rand_State
	if Save.gameData.has("Rand_EggState"):
		_EggRANDOM.state = Save.gameData.Rand_EggState

func return_RANDOM():
	return randi()
func return_randi():
	var _RAND = _RANDOM.randi()
	GameLogic.Save.gameData.Rand_State = _RANDOM.state
	return _RAND
func return_rand_Egg():
	var _RAND = _EggRANDOM.randi()
	GameLogic.Save.gameData.Rand_EggState = _EggRANDOM.state
	return _RAND

func call_HomeLoad_puppet():





	GameLogic.Save.call_SteamDic_save()
	Buy.call_init()
	LoadingUI.call_HomeLoad()

func call_HomeLoad():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		call_HomeLoad_puppet()
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_HomeLoad_puppet")




	Buy.call_init()
	LoadingUI.call_HomeLoad()

func call_LevelLoad(_level, _TYPEID: int = 0):


	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_MemberCheck_init()
	Save.gameData.Bool_InLevel = true
	LoadingUI.call_LevelLoad(_level, _TYPEID)

func call_LobbyData_Load():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		if SteamLogic.LOBBY_levelData.has("cur_level"):
			cur_level = SteamLogic.LOBBY_levelData.cur_level
			Level_bool = SteamLogic.LOBBY_levelData.Level_bool
			cur_Devil = SteamLogic.LOBBY_levelData.cur_Devil
			cur_money = SteamLogic.LOBBY_gameData["cur_money"]
			cur_ReDrawCoin = SteamLogic.LOBBY_levelData["cur_ReDrawCoin"]
			GameLogic.GameUI.call_money_change(cur_money)
			if SteamLogic.LOBBY_levelData.has("cur_Day"):
				cur_Day = SteamLogic.LOBBY_levelData["cur_Day"]
				SteamLogic.LevelDic.Day = SteamLogic.LOBBY_levelData["cur_Day"]
				SteamLogic.LevelDic.Devil = SteamLogic.LOBBY_levelData.cur_Devil
				if SteamLogic.LOBBY_levelData.cur_level != "":
					SteamLogic.LevelDic.Level = SteamLogic.LOBBY_levelData.cur_level
				if SteamLogic.LOBBY_levelData.has("cur_levelInfo"):

					GameLogic.cur_levelInfo = SteamLogic.LOBBY_levelData.cur_levelInfo
					pass
			var _LEVELDATA = SteamLogic.LOBBY_levelData

			if SteamLogic.LOBBY_levelData.has("cur_Rewards"):
				cur_Rewards = SteamLogic.LOBBY_levelData["cur_Rewards"]
				SteamLogic.LevelDic.cur_Rewards = cur_Rewards
			if SteamLogic.LOBBY_levelData.has("cur_Challenge"):
				cur_Challenge = SteamLogic.LOBBY_levelData["cur_Challenge"]
				SteamLogic.LevelDic.cur_Challenge = cur_Challenge
			if SteamLogic.LOBBY_levelData.has("cur_Popularity"):
				cur_Popularity = SteamLogic.LOBBY_levelData["cur_Popularity"]
		call_start_check()

func call_load():

	GameLogic.Save.DataLoad()


	call_rand_set()
	if Save.gameData.has("Level_Data"):
		Level_Data = Save.gameData["Level_Data"]

	if Save.levelData.has("Level_bool"):

		if Save.levelData.has("Level_bool"):
			Level_bool = Save.levelData.Level_bool
		if Save.gameData.has("cur_money"):
			cur_money = Save.gameData["cur_money"]
		if Save.gameData.has("cur_HOMEMONEY"):
			cur_HOMEMONEY = Save.gameData["cur_HOMEMONEY"]
		if Save.gameData.has("HMK"):
			HomeMoneyKey = Save.gameData["HMK"]
		if Save.gameData.has("cur_money_home"):
			cur_money_home = float(Save.gameData["cur_money_home"])

			if cur_money_home < 0:
				cur_money_home = 0

		if Save.gameData.has("cur_EggCoin"):
			cur_EggCoin = float(Save.gameData["cur_EggCoin"])
			if cur_EggCoin < 0: cur_EggCoin = 0
			if cur_EggCoin > 1:
				cur_EggCoin = cur_EggCoin / GameLogic.EggCoinKey
		if not Save.gameData.has("HomeDevList"):
			Save.gameData["HomeDevList"] = []


		if GameLogic.Save.gameData.HomeDevList.has("扭蛋币扩充+"):
			if int(round(cur_EggCoin * EggCoinKey)) > 99999:
				cur_EggCoin = 99999 / float(EggCoinKey)
		elif GameLogic.Save.gameData.HomeDevList.has("扭蛋币扩充"):
			if int(round(cur_EggCoin * EggCoinKey)) > 9999:
				cur_EggCoin = 9999 / float(EggCoinKey)
		else:
			if int(round(cur_EggCoin * EggCoinKey)) > 999:
				cur_EggCoin = 999 / float(EggCoinKey)
		if Save.gameData.has("player_1P_ID"):
			player_1P_ID = Save.gameData["player_1P_ID"]
		if Save.gameData.has("player_2P_ID"):
			player_2P_ID = Save.gameData["player_2P_ID"]
		if Save.gameData.has("JoinPlayer"):
			JoinPlayer = Save.gameData["JoinPlayer"]

	if Save.gameData.has("IsJoin"):
		if Save.gameData.has("LevelDic"):
			SteamLogic.LevelDic = Save.gameData.LevelDic
			SteamLogic.IsJoin = Save.gameData.IsJoin
			if not SteamLogic.LevelDic.has("MoneyCHECK"):
				SteamLogic.LevelDic["MoneyCHECK"] = 0
	if Save.gameData.has("_MONEYCHECK"):
		_MONEYCHECK = Save.gameData._MONEYCHECK
	if Save.gameData.has("_MC"):
		_MC = Save.gameData._MC


	GameLogic.Achievement._Load()
	call_LevelData_Load()
	_debug_unlock_all()

func _debug_unlock_all():
	var _sd = Save.gameData
	var _st = Save.statisticsData
	# Unlock all levels
	if not _sd.has("Level_Data"):
		_sd["Level_Data"] = {}
	var _scenes = Config.SceneConfig
	if _scenes:
		for _level in _scenes.keys():
			var _info = _scenes[_level]
			var _dm = 4
			if _info.has("DevilMax"):
				_dm = int(_info.DevilMax)
			_sd["Level_Data"][_level] = {
				"level_CustomerTotal": 999,
				"level_MoneyTotal": 999999,
				"level_StorePopular": 10,
				"level_SellTotal": 999,
				"cur_Devil": _dm,
				"cur_Day": 30,
			}
		Level_Data = _sd["Level_Data"]
	# Unlock all players
	_st["Array_UnlockPlayer"] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	cur_Player_Unlock = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	# Unlock all recipes
	if Config.FormulaConfig:
		_st["Array_UnlockMenu"] = Config.FormulaConfig.keys()
	# Max home expansion + all furniture
	_sd["HomeUpdate"] = 7
	_sd["HomeDevList"] = [
		"风扇", "挂式空调", "冰箱", "立式空调", "净化器", "浴缸", "购物车",
		"暗格", "保险柜", "扭蛋币扩充", "扭蛋币扩充+", "钟", "床头桌", "壁炉",
		"洗手池", "镜子", "鞋柜", "衣橱", "茶几", "电视机", "电脑桌", "书架",
		"吉他", "唱片机", "唱片盒", "猫爬架", "玩具鱼", "自动喂食器", "动物厕所",
		"南瓜小窝", "祭台", "健身器材", "充气泳池", "游戏收纳架", "杂物箱",
		"菜篮", "小菜园", "浇水工具", "施肥工具", "捕蝇草", "遮阳网",
		"清洁套装", "香薰蜡烛", "来者不拒", "帽架", "水槽",
		"客厅灯", "厨房灯", "玄关吊灯", "豪华吊灯", "水晶灯", "冷光灯",
		"外墙壁灯", "月亮灯", "百叶窗", "粉色窗帘", "蓝色窗帘",
		"大地毯", "绿色地毯", "毛绒地毯", "飞行棋地毯", "书房地毯",
		"厨房地垫", "浴室地毯", "浴室花洒", "浴帘",
		"清新绿植", "挂墙绿植", "高大绿植", "多肉植物", "仙人掌",
		"盆栽竹子", "龟背竹", "幸运树",
		"熊熊照片", "猫猫照片", "灰狼照片", "狐狸照片",
		"秋千", "单车", "坐垫", "契约架", "室外椅", "急救箱", "沙发", "沙发L", "沙发R",
		"电脑椅", "纸箱战车", "雪花球", "飞机模型", "马桶", "麻将桌",
	]
	# Max money
	if not _sd.has("HMK"):
		_sd["HMK"] = randi() % 90000 + 10000
	HomeMoneyKey = _sd["HMK"]
	var _hmk = HomeMoneyKey
	var _x = float(int(9999999 / 10000)) / float(_hmk)
	var _y = float(int(9999999 % 10000)) / float(_hmk)
	_sd["cur_HOMEMONEY"] = Vector2(_x, _y)
	cur_HOMEMONEY = Vector2(_x, _y)
	_sd["money"] = 9999999
	cur_money = 9999999
	# Unlock all achievements
	if Config.AchievementConfig:
		var _all_ach = Config.AchievementConfig.keys()
		Achievement.Achievement_Array = _all_ach.duplicate()
		Achievement.AchievementReward_Array = _all_ach.duplicate()
		_sd["Achievement_Array"] = _all_ach.duplicate()
		_sd["AchievementReward_Array"] = _all_ach.duplicate()
	# Unlock all cards/challenges/events
	if Config.CardConfig:
		_st["CardList"] = {}
		for _k in Config.CardConfig.keys():
			_st["CardList"][_k] = true
	if Config.ChallengeConfig:
		_st["ChallengeList"] = {}
		for _k in Config.ChallengeConfig.keys():
			_st["ChallengeList"][_k] = true
	if Config.EventConfig:
		_st["EventList"] = {}
		for _k in Config.EventConfig.keys():
			_st["EventList"][_k] = true
	# Max equip slots and re-run achievement logic
	Achievement.EquipMax = 4
	Achievement.CanUpdate = 8
	# Unlock all costumes into Steam inventory
	if Config.CostumeConfig:
		for _k in Config.CostumeConfig.keys():
			var _id = int(_k)
			if not SteamLogic._EQUIPDIC.has(_id):
				SteamLogic._EQUIPDIC[_id] = {"Num": 1, "Id": _id}
	# Costume coins
	if not SteamLogic._EQUIPDIC.has(20001):
		SteamLogic._EQUIPDIC[20001] = {"Num": 99999, "Id": 20001}
	else:
		SteamLogic._EQUIPDIC[20001].Num = 99999
	print("[DEBUG] All content unlocked.")

func call_LevelData_Load():


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		if not GameLogic.SPECIALLEVEL_Int:
			call_LobbyData_Load()
		return



	GameLogic.call_HomeLoad()

	GameLogic.Order.call_Formula_init()

func _DATALOAD(_LEVELDATA):

	if _LEVELDATA:
		if _LEVELDATA.has("Level_bool"):
			Level_bool = _LEVELDATA.Level_bool
		if _LEVELDATA.has("cur_Devil"):
			cur_Devil = _LEVELDATA.cur_Devil

		if _LEVELDATA.has("SPECIAL_NUM"):
			SPECIAL_NUM = Save.levelData["SPECIAL_NUM"]
		if _LEVELDATA.has("cur_Popularity"):
			cur_Popularity = _LEVELDATA["cur_Popularity"]
			if _LEVELDATA.has("cur_Popularity_Level"):
				cur_Popularity_Level = _LEVELDATA["cur_Popularity_Level"]
			cur_Gift = 0
		else:
			cur_Popularity = 0
			cur_Popularity_Level = 0
			cur_Gift = 0
		if _LEVELDATA.has("Can_Card"):
			Can_Card = _LEVELDATA.Can_Card
		if _LEVELDATA.has("cur_Rewards"):
			cur_Rewards = _LEVELDATA.cur_Rewards
		if _LEVELDATA.has("cur_Challenge"):
			cur_Challenge = _LEVELDATA["cur_Challenge"]
		if _LEVELDATA.has("Can_Formula"):
			Can_Formula = _LEVELDATA["Can_Formula"]
		if _LEVELDATA.has("Reward_1"):
			Reward_1 = _LEVELDATA["Reward_1"]
		if _LEVELDATA.has("Reward_2"):
			Reward_2 = _LEVELDATA["Reward_2"]
		if _LEVELDATA.has("Reward_3"):
			Reward_3 = _LEVELDATA["Reward_3"]
		if _LEVELDATA.has("Challenge_1"):
			Challenge_1 = _LEVELDATA["Challenge_1"]
		if _LEVELDATA.has("Challenge_2"):
			Challenge_2 = _LEVELDATA["Challenge_2"]
		if _LEVELDATA.has("Challenge_3"):
			Challenge_3 = _LEVELDATA["Challenge_3"]
		if _LEVELDATA.has("cur_ReDrawCoin"):
			cur_ReDrawCoin = _LEVELDATA["cur_ReDrawCoin"]
		if _LEVELDATA.has("cur_level"):
			cur_level = _LEVELDATA["cur_level"]

		if _LEVELDATA.has("Can_Start"):
			Can_Start = _LEVELDATA["Can_Start"]
		if _LEVELDATA.has("cur_Day"):
			cur_Day = _LEVELDATA["cur_Day"]
		GameLogic.GameUI.DayLabel.text = str(cur_Day)

		if _LEVELDATA.has("PressureDic"):
			PressureDic = _LEVELDATA.PressureDic

		if _LEVELDATA.has("cur_StoreValue"):
			cur_StoreValue = _LEVELDATA["cur_StoreValue"]
		if _LEVELDATA.has("cur_StorePopular"):
			cur_StorePopular = _LEVELDATA["cur_StorePopular"]
		cur_Menu.clear()
		if _LEVELDATA.has("cur_Menu"):
			for _Menu in _LEVELDATA["cur_Menu"]:
				cur_Menu.append(_Menu)

		cur_Staff.clear()
		if _LEVELDATA.has("cur_Staff"):
			if _LEVELDATA.has("cur_Staff"):
				var _Keys = _LEVELDATA.cur_Staff.keys()

				for _Staff in _Keys:
					cur_Staff[_Staff] = _LEVELDATA.cur_Staff[_Staff]

		if _LEVELDATA.has("cur_MenuNum"):
			cur_MenuNum = _LEVELDATA["cur_MenuNum"]
		if _LEVELDATA.has("cur_ExtraNum"):
			cur_ExtraNum = _LEVELDATA["cur_ExtraNum"]

		if _LEVELDATA.has("cur_Update"):
			cur_Update = _LEVELDATA["cur_Update"]
		if _LEVELDATA.has("cur_Buy"):
			cur_Buy = _LEVELDATA.cur_Buy
			GameLogic.Buy.buy_Array = GameLogic.cur_Buy

		if _LEVELDATA.has("new_bool"):
			new_bool = _LEVELDATA["new_bool"]
		if _LEVELDATA.has("cur_NewFormulaList"):
			cur_NewFormulaList = _LEVELDATA.cur_NewFormulaList
		if _LEVELDATA.has("cur_NeedClean"):
			cur_NeedClean = _LEVELDATA["cur_NeedClean"]
		if _LEVELDATA.has("GameOverType"):
			GameOverType = _LEVELDATA.GameOverType
		if _LEVELDATA.has("SPECIALLEVEL_Bool"):
			_LEVELDATA.erase("SPECIALLEVEL_Bool")
		if _LEVELDATA.has("SPECIALLEVEL_Int"):
			SPECIALLEVEL_Int = _LEVELDATA.SPECIALLEVEL_Int


		if GameLogic.Config.SceneConfig.has(cur_level):
			var _LEVELINFO = GameLogic.Config.SceneConfig[cur_level]
			var _DAYCOUNT = _LEVELINFO.Difficult.size()
			if cur_Day >= _DAYCOUNT:
				GameLogic.MissionComplete_bool = true

		else:

			GameOverType = 3
		call_SceneConfig_load()
		call_StoreStar_Logic()


		if Save.levelData.has("level_CustomerTotal"):
			level_CustomerTotal = Save.levelData["level_CustomerTotal"]
			if Save.levelData.has("level_SellTotal"):
				level_SellTotal = Save.levelData["level_SellTotal"]
			if Save.levelData.has("level_MoneyTotal"):
				level_MoneyTotal = Save.levelData["level_MoneyTotal"]
			if Save.levelData.has("level_ProfitTotal"):
				level_ProfitTotal = Save.levelData["level_ProfitTotal"]
			if Save.levelData.has("level_StorePopular"):
				level_StorePopular = Save.levelData["level_StorePopular"]
			if Save.levelData.has("level_MoneyCostTotal"):
				level_MoneyCostTotal = Save.levelData["level_MoneyCostTotal"]
			if Save.levelData.has("level_OpenGiftTotal"):
				level_OpenGiftTotal = Save.levelData["level_OpenGiftTotal"]
			if Save.levelData.has("level_BuyUpdate"):
				level_BuyUpdate = Save.levelData["level_BuyUpdate"]
			if Save.levelData.has("level_EXP_Base"):
				level_EXP_Base = Save.levelData["level_EXP_Base"]
		if Save.levelData.has("level_Perfect"):
			level_Perfect = Save.levelData["level_Perfect"]
		if Save.levelData.has("level_Good"):
			level_Good = Save.levelData["level_Good"]
		if Save.levelData.has("level_Bad"):
			level_Bad = Save.levelData["level_Bad"]
		if Save.levelData.has("level_Lose"):
			level_Lose = Save.levelData["level_Lose"]
		if Save.levelData.has("level_NoOrder"):
			level_NoOrder = Save.levelData["level_NoOrder"]
		if Save.levelData.has("level_Quickly"):
			level_Quickly = Save.levelData["level_Quickly"]
		if Save.levelData.has("level_Nearly"):
			level_Nearly = Save.levelData["level_Nearly"]
		if Save.levelData.has("level_Skipping"):
			level_Skipping = Save.levelData["level_Skipping"]
		if Save.levelData.has("level_Cri"):
			level_Cri = Save.levelData["level_Cri"]

func call_MC(_VALUE, _KEY: int = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _x: float = 0
	var _y: float = 0
	if _VALUE != 0:
		_x = float(int(_VALUE / 10000)) * float(_MONEYCHECKMULT)
		_y = float(int(_VALUE) % 10000) * float(_MONEYCHECKMULT)
	_MC += Vector2(_x, _y)
	pass
func return_MC():
	var _x_num: float = float(_MC.x)
	var _y_num: float = float(_MC.y)
	var _x = _x_num
	var _y = _y_num
	if _x_num > 0:
		_x = _x_num / float(_MONEYCHECKMULT) * 10000
	if _y_num > 0:
		_y = _y_num / float(_MONEYCHECKMULT)
	var _MCNUM = round(_x + _y)
	return _MCNUM
func return_FullHMK():
	if Save.gameData.has("cur_HOMEMONEY"):
		GameLogic.cur_HOMEMONEY = Save.gameData["cur_HOMEMONEY"]
	var _x = cur_HOMEMONEY.x
	var _y = cur_HOMEMONEY.y
	var _CHECK = round(_x * HomeMoneyKey * 10000 + _y * HomeMoneyKey)
	if GameLogic.Save.gameData.HomeDevList.has("暗格"):
		if _CHECK > 9999999:
			_x = float(int(9999999 / 10000)) / float(HomeMoneyKey)
			_y = float(int(9999999 % 10000)) / float(HomeMoneyKey)
			cur_HOMEMONEY = Vector2(_x, _y)
	elif GameLogic.Save.gameData.HomeDevList.has("保险柜"):
		if _CHECK > 999999:
			_x = float(int(999999 / 10000)) / float(HomeMoneyKey)
			_y = float(int(999999 % 10000)) / float(HomeMoneyKey)
			cur_HOMEMONEY = Vector2(_x, _y)
	else:
		if _CHECK > 99999:
			_x = float(int(99999 / 10000)) / float(HomeMoneyKey)
			_y = float(int(99999 % 10000)) / float(HomeMoneyKey)
			cur_HOMEMONEY = Vector2(_x, _y)

	return round(_x * HomeMoneyKey * 10000 + _y * HomeMoneyKey)

func return_HMK(_VALUE):
	var _x: float = 0
	var _y: float = 0
	if _VALUE != 0:
		_x = float(int(float(_VALUE) / 10000)) / float(HomeMoneyKey)
		_y = float(int(_VALUE) % 10000) / float(HomeMoneyKey)
	var _CHECK = return_FullHMK()



	return Vector2(_x, _y)
func call_load_puppet():
	GameLogic.Save.call_DataLoad_withoutStatistics()
	if Save.gameData.has("Level_Data"):
		Level_Data = Save.gameData["Level_Data"]
	if Save.gameData.has("_MONEYCHECK"):
		_MONEYCHECK = Save.gameData._MONEYCHECK
	if Save.levelData.has("Level_bool"):

		Level_bool = Save.levelData.Level_bool
		if not SteamLogic.IsMultiplay or SteamLogic.LOBBY_IsMaster:
			cur_money = Save.gameData["cur_money"]
		if not Save.gameData.has("_MONEYCHECKMULT"):
			Save.gameData["_MONEYCHECKMULT"] = (GameLogic.return_RANDOM() % 99 + 1) / 10
			GameLogic._MONEYCHECKMULT = Save.gameData["_MONEYCHECKMULT"]
		else:
			if Save.gameData["_MONEYCHECKMULT"] == 0:
				var _NEW = (GameLogic.return_RANDOM() % 99 + 1) / 10
				Save.gameData["_MONEYCHECKMULT"] = _NEW
			GameLogic._MONEYCHECKMULT = Save.gameData["_MONEYCHECKMULT"]
		if Save.gameData.has("cur_money_home"):
			cur_money_home = Save.gameData["cur_money_home"]
			if not Save.gameData.has("HMK"):
				var _NEW = 10000 + randi() % 90000
				Save.gameData["HMK"] = _NEW
				GameLogic.HomeMoneyKey = _NEW
				var _ReMONEY = cur_money_home * 1000000

				GameLogic.cur_HOMEMONEY = return_HMK(_ReMONEY)

			else:
				if Save.gameData.has("cur_HOMEMONEY"):
					GameLogic.cur_HOMEMONEY = Save.gameData["cur_HOMEMONEY"]
				GameLogic.HomeMoneyKey = Save.gameData["HMK"]

		if Save.gameData.has("cur_EggCoin"):
			cur_EggCoin = float(Save.gameData["cur_EggCoin"])
			if cur_EggCoin < 0: cur_EggCoin = 0
			if cur_EggCoin > 1:
				cur_EggCoin = cur_EggCoin / EggCoinKey
			if GameLogic.Save.gameData.HomeDevList.has("扭蛋币扩充+"):
				if int(round(cur_EggCoin * EggCoinKey)) > 99999:
					cur_EggCoin = 99999 / float(EggCoinKey)
			elif GameLogic.Save.gameData.HomeDevList.has("扭蛋币扩充"):
				if int(round(cur_EggCoin * EggCoinKey)) > 9999:
					cur_EggCoin = 9999 / float(EggCoinKey)
			else:
				if int(round(cur_EggCoin * EggCoinKey)) > 999:
					cur_EggCoin = 999 / float(EggCoinKey)
		player_1P_ID = Save.gameData["player_1P_ID"]
		player_2P_ID = Save.gameData["player_2P_ID"]

	var _LEVELDATA = Save.levelData

	_DATALOAD(_LEVELDATA)
	_debug_unlock_all()

func call_save():
	Level_bool = true
	emit_signal("PopularSYCN")
	_save()
func _save():
	Save.levelData.Level_bool = true


	Save.gameData["player_1P_ID"] = player_1P_ID
	Save.gameData["player_2P_ID"] = player_2P_ID
	Save.gameData["JoinPlayer"] = JoinPlayer
	Save.gameData["cur_money"] = cur_money
	Save.gameData["cur_money_home"] = cur_money_home
	Save.gameData["cur_HOMEMONEY"] = cur_HOMEMONEY
	Save.gameData["cur_EggCoin"] = cur_EggCoin
	Save.gameData["Level_Data"] = Level_Data
	Save.gameData["NPC_Data"] = NPC_Data
	Save.gameData["_MONEYCHECK"] = _MONEYCHECK

	Save.gameData["IsJoin"] = SteamLogic.IsJoin
	Save.gameData["LevelDic"] = SteamLogic.LevelDic
	Save.gameData["_MONEYCHECK"] = GameLogic._MONEYCHECK
	Save.gameData["_MC"] = GameLogic._MC
	if SPECIALLEVEL_Int == 2:

		GameLogic.Save.gameData["SubRANDOM_State"] = GameLogic._SubRANDOM.state

	if cur_level != "":

		Save.levelData["SPECIALLEVEL_Int"] = SPECIALLEVEL_Int

		Save.levelData["cur_Devil"] = cur_Devil
		Save.levelData["cur_ReDrawCoin"] = cur_ReDrawCoin
		Save.levelData["cur_Popularity"] = cur_Popularity
		Save.levelData["SPECIAL_NUM"] = SPECIAL_NUM
		Save.levelData["cur_Popularity_Level"] = cur_Popularity_Level
		Save.levelData["Can_Card"] = Can_Card
		Save.levelData["Can_Formula"] = Can_Formula

		Save.levelData["cur_Rewards"] = cur_Rewards

		Save.levelData["cur_Challenge"] = cur_Challenge
		Save.levelData["Reward_1"] = Reward_1
		Save.levelData["Reward_2"] = Reward_2
		Save.levelData["Reward_3"] = Reward_3
		Save.levelData["Challenge_1"] = Challenge_1
		Save.levelData["Challenge_2"] = Challenge_2
		Save.levelData["Challenge_3"] = Challenge_3
		Save.levelData["Can_Start"] = Can_Start
		Save.levelData["cur_level"] = cur_level
		Save.levelData["cur_Day"] = cur_Day

		Save.levelData["PressureDic"] = PressureDic

		Save.levelData["cur_StoreValue"] = cur_StoreValue
		Save.levelData["cur_StorePopular"] = cur_StorePopular
		Save.levelData["cur_Menu"] = cur_Menu

		Save.levelData["cur_MenuNum"] = cur_MenuNum
		Save.levelData["cur_ExtraNum"] = cur_ExtraNum
		Save.levelData["cur_Staff"] = cur_Staff

		Save.levelData["cur_Buy"] = cur_Buy
		Save.levelData["cur_Update"] = cur_Update
		Save.levelData["new_bool"] = new_bool
		Save.levelData["cur_NewFormulaList"] = cur_NewFormulaList
		Save.levelData["cur_NeedClean"] = cur_NeedClean


		Save.levelData["level_CustomerTotal"] = level_CustomerTotal
		Save.levelData["level_SellTotal"] = level_SellTotal
		Save.levelData["level_MoneyTotal"] = level_MoneyTotal
		Save.levelData["level_ProfitTotal"] = level_ProfitTotal
		Save.levelData["level_StorePopular"] = level_StorePopular
		Save.levelData["level_MoneyCostTotal"] = level_MoneyCostTotal
		Save.levelData["level_BuyUpdate"] = level_BuyUpdate
		Save.levelData["GameOverType"] = GameOverType
		Save.levelData["level_EXP_Base"] = level_EXP_Base

		Save.levelData["level_OpenGiftTotal"] = level_OpenGiftTotal
		Save.levelData["level_Perfect"] = level_Perfect
		Save.levelData["level_Good"] = level_Good
		Save.levelData["level_Bad"] = level_Bad
		Save.levelData["level_NoOrder"] = level_NoOrder
		Save.levelData["level_Quickly"] = level_Quickly
		Save.levelData["level_Skipping"] = level_Skipping
		Save.levelData["level_Nearly"] = level_Nearly
		Save.levelData["level_Cri"] = level_Cri
		Save.levelData["level_Lose"] = level_Lose

	Save.call_save()

func call_PlayerNum_Save():
	var _IDLIST: Array = [0, 0, 0]
	var _PLAYERNUM: int = 1
	if SteamLogic.IsMultiplay:
		if SteamLogic.SLOT_2 != 0:
			_PLAYERNUM += 1
			_IDLIST[0] = SteamLogic.SLOT_2
		if SteamLogic.SLOT_3 != 0:
			_PLAYERNUM += 1
			_IDLIST[1] = SteamLogic.SLOT_3
		if SteamLogic.SLOT_4 != 0:
			_PLAYERNUM += 1
			_IDLIST[2] = SteamLogic.SLOT_4

	if Player2_bool:
		_PLAYERNUM = - 2
	Save.levelData["PlayerID"] = _IDLIST
	Save.levelData["PlayerNum"] = _PLAYERNUM
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_PlayerNum", [_PLAYERNUM])
func call_puppet_PlayerNum(_PLAYERNUM):

	SteamLogic.LevelDic["PlayerNum"] = _PLAYERNUM
func return_Multiplayer_Base():
	if SteamLogic.IsMultiplay:

		match SteamLogic.PlayerNum:
			0, 1:
				return 4
			2:
				return 3
			3:
				return 2
			4:
				return 1
			_:

				return 1
	elif GameLogic.Player2_bool:
		return 3
	return 4
func return_Multiplier():
	if SteamLogic.IsMultiplay:

		match SteamLogic.PlayerNum:
			0, 1:
				return 1
			2:
				return 1.5
			3:
				return 2
			4:
				return 2.5
			_:

				return 1
	elif GameLogic.Player2_bool:
		return 1.5
	return 1
func return_Multiplayer():
	if SteamLogic.IsMultiplay:
		match SteamLogic.LOBBY_MEMBERS.size():
			2:
				return 1.5
			3:
				return 1.2
			4:
				return 1
	else:
		if GameLogic.Player2_bool:
			return 1.5
		else:
			return 2
func return_Multiplier_Division():
	if SteamLogic.IsMultiplay:
		match SteamLogic.PlayerNum:
			0, 1:
				return 1.0
			2:
				return 1.25
			3:
				return 1.5
			4:
				return 1.75
			_:
				printerr("错误，房间成员超过4人：", SteamLogic.LOBBY_MEMBERS)
	elif GameLogic.Player2_bool:
		return 1.25
	return 1.0
var QTESELF_BOOL: bool
func call_OrderQTE(_TYPE: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if not $QTETimer.is_stopped():
		return
	match _TYPE:
		1:
			QTESELF_BOOL = true
		2:
			QTESELF_BOOL = false

	emit_signal("OrderQTE")
	$QTETimer.start(0)









func _on_QTETimer_timeout():
	var _INFO: Dictionary
	var _KEY = QTEDic.keys()
	for _NAME in _KEY:
		var _TYPE = QTEDic[_NAME]
		_INFO[_NAME] = _TYPE
	get_tree().call_group("Customers", "call_QTECheck", _INFO)
	QTEDic.clear()

var PAUSELOCK: bool
func call_pause(_Switch: bool):

	match _Switch:
		true:
			get_tree().paused = true
		false:
			if not PAUSELOCK:
				get_tree().paused = false


	pass
func call_ESCLOGIC(_SWITCH):
	match _SWITCH:
		false:
			Can_ESC = false
			PAUSELOCK = true
			GameUI.MainMenu.call_ESC_hide()

		true:
			PAUSELOCK = false
			Can_ESC = true
func return_bool_MaxCheck(_NUMBER):

	return false
func return_Multiplayer_Num(_NUMBER):

	return float(_NUMBER)

func call_Master_LoadSuccess():
	SteamLogic.call_puppet_node_sync(self, "on_Master_LoadSuccess")
	pass

func on_Master_LoadSuccess():
	AwaitMasterLoad = false
	var tree: SceneTree = get_tree()
	if tree.current_scene.has_method("on_Master_LoadSuccess"):
		tree.current_scene.call("on_Master_LoadSuccess")
	pass
