extends Control

var Perfect
var Good
var Bad
var Quickly
var Skipping
var Nearly
var TotalCustomer
var TotalSell
var TotalNoOrder
var TotalLose
var MaxCombo
var OrderRat: int

var cur_show: bool
var TYPE: int = 0
onready var Ani = $Ani

onready var ComboNode = $BG / VBox2 / MaxCombo / Scroll / HBox
onready var PerfectNode = $BG / VBox / Perfect / Scroll / HBox
onready var GoodNode = $BG / VBox / Good / Scroll / HBox
onready var BadNode = $BG / VBox / Bad / Scroll / HBox
onready var QuicklyNode = $BG / VBox2 / Quickly / Scroll / HBox
onready var SkippingNode = $BG / VBox2 / Skipping / Scroll / HBox
onready var NearlyNode = $BG / VBox2 / Nearly / Scroll / HBox
onready var CriNode = $BG / VBox2 / Cri / Scroll / HBox

onready var TotalNoOrderNode = $BG / VBox / TotalNoOrder / Scroll / HBox

onready var TotalLoseNode = $BG / VBox / TotalLose / Scroll / HBox
onready var TotalInComeNode = $BG / TotalIncome / Scroll / HBox
onready var TodayInComeNode = $BG / TodayIncome / Scroll / HBox

onready var DayCloseNode = get_node("BG/DayInfo/ScrollContainer/HBoxContainer")
onready var WrongInfoScroll = get_node("BG/DayInfo/ScrollContainer")

var cur_INFO_Array: Array
var _EXPARRAY: Array = [1, 0.625, 0.48, 0.41]
var ENDCHECK: bool
func _ready() -> void :

	set_physics_process(false)
	if not SteamLogic.is_connected("LeaveLobby", self, "call_UI_End"):
		var _CON = SteamLogic.connect("LeaveLobby", self, "call_UI_End")
var _time: float
var _ScrollUp: bool
func call_init():
	Ani.play("init")
func _physics_process(_delta: float) -> void :
	_time += _delta
	if _time > 0.1:
		_time = 0

		if not _ScrollUp:
			var cur_Scroll = WrongInfoScroll.scroll_vertical
			WrongInfoScroll.scroll_vertical += 1
			if cur_Scroll == WrongInfoScroll.scroll_vertical:
				_ScrollUp = true
		else:
			var cur_Scroll = WrongInfoScroll.scroll_vertical
			WrongInfoScroll.scroll_vertical -= 1
			if cur_Scroll == WrongInfoScroll.scroll_vertical:
				_ScrollUp = false

func call_perfect_puppet():
	GameLogic.call_StatisticsData_Set("Count_perfectEndDay", null, 1)

func _wrong_check():
	var _List = DayCloseNode.get_children()
	for i in _List.size():
		var _OldInfo = _List[i]
		DayCloseNode.remove_child(_OldInfo)
		_OldInfo.queue_free()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _CHECKLIST = [

		GameLogic.WRONGTYPE.TRASHBIN,
		GameLogic.WRONGTYPE.TRASHBAG,
		GameLogic.WRONGTYPE.INDUCTIONCOOKER,
		GameLogic.WRONGTYPE.TEAPORT,

		GameLogic.WRONGTYPE.DRINKCUP,
		GameLogic.WRONGTYPE.BOX,
		GameLogic.WRONGTYPE.ITEM,

		GameLogic.WRONGTYPE.STAIN,
		GameLogic.WRONGTYPE.MATERIALBOX,
		GameLogic.WRONGTYPE.BIGPOT,
		GameLogic.WRONGTYPE.MILKPOT,
		GameLogic.WRONGTYPE.BOBAMACHINE,
		GameLogic.WRONGTYPE.JUICEMACHINE,
		GameLogic.WRONGTYPE.FRUITCORE,
		GameLogic.WRONGTYPE.TRASHITEM,
		GameLogic.WRONGTYPE.BARREL,
		GameLogic.WRONGTYPE.EGGROLLPOT,
	]
	var _CHECK: bool = false
	for _TYPE in GameLogic.WrongInfo:
		if _TYPE in _CHECKLIST:
			_CHECK = true



	if not _CHECK:

		GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.NONE)
		for _i in GameLogic.WrongInfo.size():
			var _Info = GameLogic.TSCNLoad.DayClosedInfo_TSCN.instance()
			DayCloseNode.add_child(_Info)
			var _TYPE = GameLogic.WrongInfo[_i]
			_Info.call_set(_TYPE)

		GameLogic.call_pressure("PerfectEndDay")
		GameLogic.call_StatisticsData_Set("Count_perfectEndDay", null, 1)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_perfect_puppet")



		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		var _Other: int = 0
		if GameLogic.cur_Rewards.has("完美收拾"):
			GameLogic.call_Info(1, "完美收拾")
			_Other += int(float(GameLogic.Money_Sell + GameLogic.Money_Tip) * 0.05)
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_Other = int(float(_Other) * 1.5)
		elif GameLogic.cur_Rewards.has("完美收拾+"):
			GameLogic.call_Info(1, "完美收拾+")
			_Other += int(float(GameLogic.Money_Sell + GameLogic.Money_Tip) * 0.15)
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_Other = int(float(_Other) * 1.5)


		if _Other > 0:
			GameLogic.call_MoneyOther_Change(_Other, GameLogic.HomeMoneyKey)



	else:
		printerr("EndUI 完美收拾判断:", GameLogic.WrongInfo)
		var _Pressure: int = 0

		for _i in GameLogic.WrongInfo.size():
			var _Info = GameLogic.TSCNLoad.DayClosedInfo_TSCN.instance()
			DayCloseNode.add_child(_Info)
			var _TYPE = GameLogic.WrongInfo[_i]
			_Info.call_set(_TYPE)
			match _TYPE:
				GameLogic.WRONGTYPE.TRASHBAG:
					_Pressure += 2
				GameLogic.WRONGTYPE.TRASHBIN:
					_Pressure += 2
				GameLogic.WRONGTYPE.STAIN:
					_Pressure += 5
		if GameLogic.cur_Challenge.has("夜班偷懒"):
			GameLogic.call_Info(2, "夜班偷懒")
			_Pressure += 2

		if GameLogic.cur_Challenge.has("夜班偷懒+"):
			GameLogic.call_Info(2, "夜班偷懒+")
			_Pressure += 4

		if GameLogic.cur_Challenge.has("夜班偷懒++"):
			GameLogic.call_Info(2, "夜班偷懒++")
			_Pressure += 8

		if _Pressure != 0:
			GameLogic.call_Pressure_Set(_Pressure)

func call_puppet_DayEnd(_POPULARDAY, _INFODIC: Dictionary):

	GameLogic.Popular_Day = _POPULARDAY

	GameLogic.Popular_Day = 0

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_Master_Switch(true)

	var Money_Sell: int
	var Money_Tip: int
	var Money_Other: int
	var Cost_Rent: int
	var Cost_Water: int
	var Cost_Electricity: int
	var Cost_Fine: int
	var Cost_Items: int
	var Cost_Staff: int
	var Cost_Other: int
	var Cost_Coop: int
	var Count: int
	var ElectricityMult: float = 1
	var WaterMult: float = 1
	var RentMult: float = 1
	var ItemMult: float = 1
	var StaffMult: float = 1
	var BuyCount: int = 0
	var ProfitTotal: int = 0
	var _KEYLIST = _INFODIC.keys()
	var _WRONGINFO
	var _TODAY: int
	for _KEY in _KEYLIST:
		match _KEY:
			"TODAY":
				_TODAY = _INFODIC[_KEY]
			"ProfitTotal":
				ProfitTotal = _INFODIC[_KEY]
			"BuyCount":
				BuyCount = _INFODIC[_KEY]

			"_WRONGINFO":
				_WRONGINFO = _INFODIC[_KEY]
			"Day":
				SteamLogic.LevelDic.Day = int(_INFODIC[_KEY])
			"Devil":
				SteamLogic.LevelDic.Devil = int(_INFODIC[_KEY])
			"OrderRat":
				OrderRat = _INFODIC[_KEY]
			"MaxCombo":
				MaxCombo = _INFODIC[_KEY]
			"TotalCustomer":
				TotalCustomer = _INFODIC[_KEY]
			"Perfect":
				Perfect = _INFODIC[_KEY]
			"Good":
				Good = _INFODIC[_KEY]
			"Bad":
				Bad = _INFODIC[_KEY]
			"Quickly":
				Quickly = _INFODIC[_KEY]
			"Skipping":
				Skipping = _INFODIC[_KEY]
			"Nearly":
				Nearly = _INFODIC[_KEY]
			"TotalNoOrder":
				TotalNoOrder = _INFODIC[_KEY]
			"TotalSell":
				TotalSell = _INFODIC[_KEY]
			"TotalLose":
				TotalLose = _INFODIC[_KEY]
			"Money_Sell":
				Money_Sell = _INFODIC[_KEY]
			"Money_Tip":
				Money_Tip = _INFODIC[_KEY]
			"Money_Other":
				Money_Other = _INFODIC[_KEY]
			"Cost_Items":
				Cost_Items = _INFODIC[_KEY]
			"Cost_Rent":
				Cost_Rent = _INFODIC[_KEY]
			"Cost_Water":
				Cost_Water = _INFODIC[_KEY]
			"Cost_Electricity":
				Cost_Electricity = _INFODIC[_KEY]
			"Cost_Staff":
				Cost_Staff = _INFODIC[_KEY]
			"Cost_Fine":
				Cost_Fine = _INFODIC[_KEY]
			"Count":
				Count = _INFODIC[_KEY]
			"ItemMult":
				ItemMult = _INFODIC[_KEY]
			"RentMult":
				RentMult = _INFODIC[_KEY]
			"WaterMult":
				WaterMult = _INFODIC[_KEY]
			"ElectricityMult":
				ElectricityMult = _INFODIC[_KEY]
			"StaffMult":
				StaffMult = _INFODIC[_KEY]
			"Cost_Other":
				Cost_Other = _INFODIC[_KEY]
			"Cost_Coop":
				Cost_Coop = _INFODIC[_KEY]
	var _DAYMONEY = _TODAY

	SteamLogic.LevelDic.MoneyCHECK += float(_DAYMONEY) * float(GameLogic._MONEYCHECKMULT)


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.LevelDic.Coin += int(Count)
		SteamLogic.LevelDic.Cup += int(Perfect) + int(Good) + int(Bad)
		SteamLogic.LevelDic.Perfect += int(Perfect)
		SteamLogic.LevelDic.Good += int(Good)
		SteamLogic.LevelDic.Bad += int(Bad)

		SteamLogic.LevelDic.EXP += float(int(Perfect) + int(Good) + int(Bad)) / GameLogic.return_Multiplier()

		if not SteamLogic.IsJoin:
			SteamLogic.LevelDic.SkipDay = SteamLogic.LevelDic.Day - 1
		SteamLogic.IsJoin = true
		var _LEVELINFO = SteamLogic.LevelDic.cur_levelInfo
		SteamLogic.LevelDic.Difficult = _LEVELINFO.get("Difficult")

		if SteamLogic.LevelDic.Day >= SteamLogic.LevelDic.Difficult.size():
			SteamLogic.LevelDic.IsFinish = true

	GameLogic.call_ESCLOGIC(false)
	Ani.play("0")
	GameLogic.GameUI.call_PanelAni(true)
	TYPE = 0

	call_number_set(MaxCombo, ComboNode)
	call_number_set(Perfect, PerfectNode)
	call_number_set(Good, GoodNode)
	call_number_set(Bad, BadNode)
	call_number_set(Quickly, QuicklyNode)
	call_number_set(Skipping, SkippingNode)
	call_number_set(Nearly, NearlyNode)
	call_number_set(TotalNoOrder, TotalNoOrderNode)
	call_number_set(_INFODIC.Cri, CriNode)

	call_number_set(TotalLose, TotalLoseNode)
	_Num_set(Money_Sell, Money_Tip, Money_Other, Cost_Items, Cost_Rent, Cost_Water, Cost_Electricity, Cost_Staff, Cost_Fine, Count, BuyCount, ProfitTotal)
	_Mult_set(ItemMult, RentMult, WaterMult, ElectricityMult, StaffMult, Cost_Other, Cost_Coop)

	set_physics_process(true)

	for _NODE in DayCloseNode.get_children():
		DayCloseNode.remove_child(_NODE)
		_NODE.queue_free()
	for _i in _WRONGINFO.size():
		var _Info = GameLogic.TSCNLoad.DayClosedInfo_TSCN.instance()
		DayCloseNode.add_child(_Info)
		var _TYPE = _WRONGINFO[_i]
		_Info.call_set(_TYPE)
func call_DayEnd():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if ENDCHECK:
		return
	ENDCHECK = true
	_wrong_check()

	GameLogic.Save.levelData["COMBO"] = GameLogic.cur_Combo
	MaxCombo = GameLogic.cur_ComboMax
	Perfect = GameLogic.cur_Perfect
	Good = GameLogic.cur_Good
	Bad = GameLogic.cur_Bad
	Quickly = GameLogic.cur_Quickly
	Skipping = GameLogic.cur_Skipping
	Nearly = GameLogic.cur_Nearly

	var _Perfect_Level = GameLogic.level_Perfect
	var _Good_Level = GameLogic.level_Good
	var _Bad_Level = GameLogic.level_Bad
	var _Quickly_Level = GameLogic.level_Quickly
	var _Skipping_Level = GameLogic.level_Skipping
	var _Nearly_Level = GameLogic.level_Nearly

	TotalCustomer = GameLogic.cur_CustomerNum
	TotalSell = GameLogic.cur_SellNum
	TotalNoOrder = GameLogic.cur_NoOrderNum
	TotalLose = GameLogic.cur_NoSellNum
	if TotalCustomer == 0:
		OrderRat = 0
	else:
		if TotalSell > 0 and TotalCustomer:
			OrderRat = int(float(TotalSell) / float(TotalCustomer) * 100)



	var Money_Sell: int = GameLogic.Money_Sell
	var Money_Tip: int = GameLogic.Money_Tip
	var Money_Other: int = GameLogic.Money_Other
	var BuyCount: int = GameLogic.level_BuyUpdate
	var _DEVILMULT: float = float(1 + GameLogic.cur_Devil) * (1 + float(GameLogic.cur_Day - 1) * 0.5)
	var _RentMult = _DEVILMULT
	var _LEVELINFO = GameLogic.cur_levelInfo

	var Cost_Rent: int = int(float(GameLogic.cur_Rent) * _RentMult)
	var Cost_Water: int = int(float(GameLogic.Price_Water) * _DEVILMULT * float(GameLogic.Total_Water))
	var _x = GameLogic.Price_Electricity
	var _y = GameLogic.Total_Electricity

	var Cost_Electricity: int = int(float(GameLogic.Price_Electricity) * _DEVILMULT * float(GameLogic.Total_Electricity))

	var Cost_Fine: int = GameLogic.Cost_Fine
	var Cost_Items: int = GameLogic.Cost_Items
	var Cost_Staff: int = 0
	var Cost_Other: int = 0
	var Cost_Coop: int = 0
	var _StaffNameList = GameLogic.cur_Staff.keys()

	for _StaffName in _StaffNameList:

		Cost_Staff += int(GameLogic.cur_Staff[_StaffName].DailyWage)

	var ElectricityMult: float = 1
	var WaterMult: float = 1
	var RentMult: float = 1
	var ItemMult: float = 1
	var StaffMult: float = 1

	if GameLogic.cur_Challenge.has("电费增加"):
		ElectricityMult += 0.25
	if GameLogic.cur_Challenge.has("电费增加+"):
		ElectricityMult += 0.5
	if GameLogic.cur_Challenge.has("电费增加++"):
		ElectricityMult += 1
	if GameLogic.cur_Challenge.has("水费增加"):
		WaterMult += 0.25
	if GameLogic.cur_Challenge.has("水费增加+"):
		WaterMult += 0.5
	if GameLogic.cur_Challenge.has("水费增加++"):
		WaterMult += 1
	if GameLogic.cur_Challenge.has("涨租"):
		RentMult += 0.25
	if GameLogic.cur_Challenge.has("涨租+"):
		RentMult += 0.5
	if GameLogic.cur_Challenge.has("涨租++"):
		RentMult += 1

	if GameLogic.cur_Rewards.has("偷电"):
		ElectricityMult -= 0.5
	if GameLogic.cur_Rewards.has("偷电+"):
		ElectricityMult = 0
	if GameLogic.cur_Rewards.has("偷水"):
		WaterMult -= 0.5
	if GameLogic.cur_Rewards.has("偷水+"):
		WaterMult = 0
	if GameLogic.cur_Rewards.has("租金降低"):
		RentMult -= 0.25
	if GameLogic.cur_Rewards.has("租金降低+"):
		RentMult -= 0.5

	match GameLogic.cur_Event:
		"免房租":
			RentMult = 0
		"免工资":
			StaffMult = 0
		"免水费":
			WaterMult = 0
		"免电费":
			ElectricityMult = 0
		"免水电":
			WaterMult = 0
			ElectricityMult = 0
		"大免单":
			WaterMult = 0
			ElectricityMult = 0
			RentMult = 0
			StaffMult = 0

	Cost_Water = - 1 * int(float(Cost_Water) * WaterMult)
	Cost_Electricity = - 1 * int(float(Cost_Electricity) * ElectricityMult)
	Cost_Rent = - 1 * int(float(Cost_Rent) * RentMult)
	Cost_Items = - 1 * int(float(Cost_Items) * ItemMult)
	Cost_Staff = - 1 * int(float(Cost_Staff) * StaffMult)

	var _DayTotalCost = Cost_Rent + Cost_Water + Cost_Electricity + Cost_Items + Cost_Staff + Cost_Fine
	var _plus = Money_Sell + Money_Tip + Money_Other

	var Count = _plus
	var _IS_Save: bool
	var _TODAY: int = int(Count + _DayTotalCost)


	GameLogic.level_EXP_Base += float(Perfect + Good + Bad) / GameLogic.return_Multiplier()



	GameLogic.level_MoneyCostTotal += int(abs(_DayTotalCost))
	GameLogic.level_ProfitTotal += _DayTotalCost

	GameLogic.call_MoneyChange(_DayTotalCost, GameLogic.HomeMoneyKey)


	GameLogic.call_StoreStar_Logic()

	GameLogic.call_ESCLOGIC(false)
	Ani.play("0")
	GameLogic.GameUI.call_PanelAni(true)
	GameLogic.call_MC(_TODAY, GameLogic.HomeMoneyKey)
	TYPE = 0
	GameLogic.Popular_Day = 0
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if GameLogic.Player2_bool:
		if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.connect("P2_Control", self, "_control_logic")
	if GameLogic.cur_money == 0:
		GameLogic.call_StatisticsData_Set("Count_NoCupCoin", null, 1)

	var _POPULARDAY = GameLogic.Popular_Day


	call_number_set(MaxCombo, ComboNode)
	call_number_set(Perfect, PerfectNode)
	call_number_set(Good, GoodNode)
	call_number_set(Bad, BadNode)
	call_number_set(Quickly, QuicklyNode)
	call_number_set(Skipping, SkippingNode)
	call_number_set(Nearly, NearlyNode)
	call_number_set(TotalNoOrder, TotalNoOrderNode)

	call_number_set(GameLogic.cur_Cri, CriNode)
	call_number_set(TotalLose, TotalLoseNode)
	_Num_set(Money_Sell, Money_Tip, Money_Other, Cost_Items, Cost_Rent, Cost_Water, Cost_Electricity, Cost_Staff, Cost_Fine, Count, BuyCount, GameLogic.level_ProfitTotal)
	_Mult_set(ItemMult, RentMult, WaterMult, ElectricityMult, StaffMult, Cost_Other, Cost_Coop)

	set_physics_process(true)


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _INFODIC: Dictionary
		_INFODIC["_WRONGINFO"] = GameLogic.WrongInfo
		_INFODIC["Day"] = GameLogic.cur_Day
		_INFODIC["Devil"] = GameLogic.cur_Devil
		_INFODIC["OrderRat"] = OrderRat
		_INFODIC["MaxCombo"] = MaxCombo
		_INFODIC["TotalCustomer"] = TotalCustomer
		_INFODIC["Perfect"] = Perfect
		_INFODIC["Good"] = Good
		_INFODIC["Bad"] = Bad
		_INFODIC["Quickly"] = Quickly
		_INFODIC["Skipping"] = Skipping
		_INFODIC["Nearly"] = Nearly
		_INFODIC["TotalNoOrder"] = TotalNoOrder
		_INFODIC["TotalSell"] = TotalSell
		_INFODIC["TotalLose"] = TotalLose
		_INFODIC["Money_Sell"] = Money_Sell
		_INFODIC["Money_Tip"] = Money_Tip
		_INFODIC["Money_Other"] = Money_Other
		_INFODIC["Cost_Items"] = Cost_Items
		_INFODIC["Cost_Rent"] = Cost_Rent
		_INFODIC["Cost_Water"] = Cost_Water
		_INFODIC["Cost_Electricity"] = Cost_Electricity
		_INFODIC["Cost_Staff"] = Cost_Staff
		_INFODIC["Cost_Fine"] = Cost_Fine
		_INFODIC["Count"] = Count
		_INFODIC["ItemMult"] = ItemMult
		_INFODIC["RentMult"] = RentMult
		_INFODIC["WaterMult"] = WaterMult
		_INFODIC["ElectricityMult"] = ElectricityMult
		_INFODIC["StaffMult"] = StaffMult
		_INFODIC["Cost_Other"] = Cost_Other
		_INFODIC["Cost_Coop"] = Cost_Coop
		_INFODIC["BuyCount"] = GameLogic.level_BuyUpdate
		_INFODIC["level_Perfect"] = GameLogic.level_Perfect
		_INFODIC["level_Good"] = GameLogic.level_Good
		_INFODIC["level_Bad"] = GameLogic.level_Bad
		_INFODIC["level_Lose"] = GameLogic.level_Lose
		_INFODIC["level_Quickly"] = GameLogic.level_Quickly
		_INFODIC["level_Skipping"] = GameLogic.level_Skipping
		_INFODIC["level_Nearly"] = GameLogic.level_Nearly
		_INFODIC["level_NoOrder"] = GameLogic.level_NoOrder
		_INFODIC["level_Cri"] = GameLogic.level_Cri
		_INFODIC["Cri"] = GameLogic.cur_Cri
		_INFODIC["ProfitTotal"] = GameLogic.level_ProfitTotal
		_INFODIC["TODAY"] = _TODAY

		SteamLogic.call_puppet_node_sync(self, "call_puppet_DayEnd", [_POPULARDAY, _INFODIC])



func call_show_switch(_switch: bool):
	cur_show = _switch
	match cur_show:
		true:
			if GameLogic.cur_money < 0:
				$BG / Label / AnimationPlayer.play("broke")
				pass
func _control_logic(_but, _value, _type):

	if not cur_show:
		if not SteamLogic.IsMultiplay:
			match _but:
				"A":
					if _value in [1, - 1]:
						Ani.playback_speed = 3
					elif _value == 0:
						Ani.playback_speed = 1
		return
	match _but:
		"A":
			if _value == 1:
				_On_Back_pressed()
func call_Total_set(_num, _HBOX):


	var Num_bit = _HBOX.get_node("1")
	var Num_ten = _HBOX.get_node("10")
	var Num_hun = _HBOX.get_node("100")
	var Num_Thou = _HBOX.get_node("1000")
	var Num_TenThou = _HBOX.get_node("10000")
	var Num_HunThou = _HBOX.get_node("100000")
	var _Negative: bool = false
	if _num < 0:
		_Negative = true
	else:
		_Negative = false
	if _Negative:
		$"BG/TodayIncome/Scroll/HBox/-".show()
		$"BG/TotalIncome/Scroll/HBox/-".show()
	else:
		$"BG/TodayIncome/Scroll/HBox/-".hide()
		$"BG/TotalIncome/Scroll/HBox/-".hide()
	_num = abs(_num)
	if _num < 10:

		Num_bit.call_target(_num)

		Num_ten.call_init()
		Num_hun.call_init()
		Num_Thou.call_init()
		Num_TenThou.call_init()
		Num_HunThou.call_init()
	elif _num < 100:
		var _NUMSTR: String = str(_num)
		var _TENSTR = _NUMSTR.right(0)
		var _bit = int(_NUMSTR.right(1))
		var _ten = int(_TENSTR.left(1))
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_init()
		Num_Thou.call_init()
		Num_TenThou.call_init()
		Num_HunThou.call_init()
	elif _num < 1000:
		var _NUMSTR: String = str(_num)
		var _TENSTR = _NUMSTR.right(1)
		var _HUNSTR = _NUMSTR.right(0)
		var _bit = int(_NUMSTR.right(2))
		var _ten = int(_TENSTR.left(1))
		var _hun = int(_HUNSTR.left(1))
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_target(_hun)
		Num_Thou.call_init()
		Num_TenThou.call_init()
		Num_HunThou.call_init()
	elif _num < 10000:
		var _NUMSTR: String = str(_num)
		var _TENSTR = _NUMSTR.right(2)
		var _HUNSTR = _NUMSTR.right(1)
		var _THOUSTR = _NUMSTR.right(0)
		var _bit = int(_NUMSTR.right(3))
		var _ten = int(_TENSTR.left(1))
		var _hun = int(_HUNSTR.left(1))
		var _Thou = int(_THOUSTR.left(1))
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_target(_hun)
		Num_Thou.call_target(_Thou)
		Num_TenThou.call_init()
		Num_HunThou.call_init()
	elif _num < 100000:
		var _NUMSTR: String = str(_num)
		var _TENSTR = _NUMSTR.right(3)
		var _HUNSTR = _NUMSTR.right(2)
		var _THOUSTR = _NUMSTR.right(1)
		var _TENTHOUSTR = _NUMSTR.right(0)
		var _bit = int(_NUMSTR.right(4))
		var _ten = int(_TENSTR.left(1))
		var _hun = int(_HUNSTR.left(1))
		var _Thou = int(_THOUSTR.left(1))
		var _TenThou = int(_TENTHOUSTR.left(1))
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_target(_hun)
		Num_Thou.call_target(_Thou)
		Num_TenThou.call_target(_TenThou)
		Num_HunThou.call_init()
	elif _num < 1000000:
		var _NUMSTR: String = str(_num)
		var _TENSTR = _NUMSTR.right(4)
		var _HUNSTR = _NUMSTR.right(3)
		var _THOUSTR = _NUMSTR.right(2)
		var _TENTHOUSTR = _NUMSTR.right(1)
		var _HUNTHOUSTR = _NUMSTR.right(0)
		var _bit = int(_NUMSTR.right(5))
		var _ten = int(_TENSTR.left(1))
		var _hun = int(_HUNSTR.left(1))
		var _Thou = int(_THOUSTR.left(1))
		var _TenThou = int(_TENTHOUSTR.left(1))
		var _HunThou = int(_HUNTHOUSTR.left(1))
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_target(_hun)
		Num_Thou.call_target(_Thou)
		Num_TenThou.call_target(_TenThou)
		Num_HunThou.call_target(_HunThou)
	else:
		Num_bit.call_target(9)
		Num_ten.call_target(9)
		Num_hun.call_target(9)
		Num_Thou.call_target(9)
		Num_TenThou.call_target(9)
		Num_HunThou.call_target(9)

func call_number_set(_num, _HBOX):

	var Num_bit = _HBOX.get_node("1")

	var Num_ten = _HBOX.get_node("10")

	var Num_hun = _HBOX.get_node("100")

	if _HBOX.has_node("1000"):
		var Num_tho = _HBOX.get_node("1000")

		Num_tho.hide()
	if _num < 10:

		Num_bit.call_target(_num)

		Num_ten.call_init()
		Num_hun.call_init()
	elif _num < 100:

		Num_ten.show()
		var _ten = int(_num / 10)
		var _bit = _num - (_ten * 10)
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_init()

	elif _HBOX.has_node("1000"):
		var Num_tho = _HBOX.get_node("1000")
		Num_tho.ShowAni.play("show")

		if _num < 1000:
			var _hun = int(_num / 100)
			var _tenNum = _num - (_hun * 100)
			var _ten = int(_tenNum / 10)
			var _bit = _tenNum - (_ten * 10)
			Num_bit.call_target(_bit)
			Num_ten.call_target(_ten)
			Num_hun.call_target(_hun)
			Num_tho.ShowAni.play("init")
		else:
			if _num > 9999:
				_num = 9999
			var _tho = int(_num / 1000)
			var _thoNum = _num - (_tho * 1000)
			var _hun = int(_thoNum / 100)
			var _tenNum = _num - (_hun * 100)
			var _ten = int(_tenNum / 10)
			var _bit = _tenNum - (_ten * 10)
			Num_bit.call_target(_bit)
			Num_ten.call_target(_ten)
			Num_hun.call_target(_hun)
			Num_tho.call_target(_tho)
	else:

		if _num > 999:
			_num = 999
		var _hun = int(_num / 100)
		var _tenNum = _num - (_hun * 100)
		var _ten = int(_tenNum / 10)
		var _bit = _tenNum - (_ten * 10)
		if _num >= 100:
			Num_ten.show()
			Num_hun.show()
		Num_bit.call_target(_bit)
		Num_ten.call_target(_ten)
		Num_hun.call_target(_hun)
func call_LevelMoney_Show():
	var _Node = get_node("BG/DayInfoBG/VBox")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_Node.get_node("Count/Total/Num").text = str(SteamLogic.LevelDic.Coin)
	else:
		_Node.get_node("Count/Total/Num").text = str(GameLogic.level_MoneyTotal)
func _Num_set(Money_Sell, Money_Tip, Money_Other, Cost_Items, Cost_Rent, Cost_Water, Cost_Electricity, _Cost_Staff, _Cost_Fine, Count, _BuyCount, _ProfitTotal):
	var _Node = get_node("BG/DayInfoBG/VBox")
	_Node.get_node("Plus/Total/Num").text = str(Money_Sell)
	_Node.get_node("Plus/Tip/Num").text = str(Money_Tip)
	_Node.get_node("Plus/Other/Num").text = str(Money_Other)
	_Node.get_node("Minus/Buy/Num").text = str(Cost_Items)
	_Node.get_node("Minus/Rent/Num").text = str(Cost_Rent)
	_Node.get_node("Minus/Water/Num").text = str(Cost_Water)
	_Node.get_node("Minus/Electricity/Num").text = str(Cost_Electricity)

	_Node.get_node("Count/Count/Num").text = str(Count)
	var _COST: int = Cost_Items + Cost_Rent + Cost_Water + Cost_Electricity
	var _TODAY: int = Count + _COST
	call_Total_set(_TODAY, TodayInComeNode)
	_Node.get_node("Last/Total/Num").text = str(_COST)
	if Count >= 0:
		_Node.get_node("Count/Count/Num/Ani").play("+")
	else:
		_Node.get_node("Count/Count/Num/Ani").play("-")
	_Node.get_node("Last/Profit/Num").text = str(_TODAY)
	_Node.get_node("Last/CurMoney/Num").text = str(GameLogic.cur_money)

	var _TOTALINCOME = _ProfitTotal


	call_Total_set(_TOTALINCOME, TotalInComeNode)

	if GameLogic.SPECIALLEVEL_Int:
		get_node("BG/DayInfoBG/DayLabel").text = "SPECIAL"
	else:
		get_node("BG/DayInfoBG/DayLabel").text = "DAY " + str(GameLogic.cur_Day)
func _Mult_set(ItemMult, RentMult, WaterMult, ElectricityMult, StaffMult, _Cost_Other, Cost_Coop):
	var _PlusNode = get_node("BG/DayInfoBG/VBox")
	if ItemMult != 1:
		var _Mult = int(ItemMult * 100) - 100
		var _TEXT: String = str(_Mult) + "%"
		if _Mult > 0:
			_TEXT = "+" + _TEXT
		_PlusNode.get_node("Minus/Buy/MultLabel").text = _TEXT
		if ItemMult > 1:
			_PlusNode.get_node("Minus/Buy/Ani").play("+")
		else:
			_PlusNode.get_node("Minus/Buy/Ani").play("-")
	else:
		_PlusNode.get_node("Minus/Buy/MultLabel").text = ""
		_PlusNode.get_node("Minus/Buy/Ani").play("init")
	if RentMult != 1:
		var _Mult = int(RentMult * 100) - 100
		var _TEXT: String = str(_Mult) + "%"
		if _Mult > 0:
			_TEXT = "+" + _TEXT
		_PlusNode.get_node("Minus/Rent/MultLabel").text = _TEXT
		if RentMult > 1:
			_PlusNode.get_node("Minus/Rent/Ani").play("+")
		else:
			_PlusNode.get_node("Minus/Rent/Ani").play("-")
	else:
		_PlusNode.get_node("Minus/Rent/MultLabel").text = ""
		_PlusNode.get_node("Minus/Rent/Ani").play("init")
	if WaterMult != 1:
		var _Mult = int(WaterMult * 100) - 100
		var _TEXT: String = str(_Mult) + "%"
		if _Mult > 0:
			_TEXT = "+" + _TEXT
		_PlusNode.get_node("Minus/Water/MultLabel").text = _TEXT
		if WaterMult > 1:
			_PlusNode.get_node("Minus/Water/Ani").play("+")
		else:
			_PlusNode.get_node("Minus/Water/Ani").play("-")
	else:
		_PlusNode.get_node("Minus/Water/MultLabel").text = ""
		_PlusNode.get_node("Minus/Water/Ani").play("init")
	if ElectricityMult != 1:
		var _Mult = int(ElectricityMult * 100) - 100
		var _TEXT: String = str(_Mult) + "%"
		if _Mult > 0:
			_TEXT = "+" + _TEXT
		_PlusNode.get_node("Minus/Electricity/MultLabel").text = _TEXT
		if ElectricityMult > 1:
			_PlusNode.get_node("Minus/Electricity/Ani").play("+")
		else:
			_PlusNode.get_node("Minus/Electricity/Ani").play("-")
	else:
		_PlusNode.get_node("Minus/Electricity/MultLabel").text = ""
		_PlusNode.get_node("Minus/Electricity/Ani").play("init")
	if StaffMult != 1:
		var _Mult = int(StaffMult * 100) - 100
		var _TEXT: String = str(_Mult) + "%"
		if _Mult > 0:
			_TEXT = "+" + _TEXT
		_PlusNode.get_node("Minus/Staff/MultLabel").text = _TEXT
		if StaffMult > 1:
			_PlusNode.get_node("Minus/Staff/Ani").play("+")
		else:
			_PlusNode.get_node("Minus/Staff/Ani").play("-")
	else:
		_PlusNode.get_node("Minus/Staff/MultLabel").text = ""
		_PlusNode.get_node("Minus/Staff/Ani").play("init")
	if Cost_Coop > 0:

		_PlusNode.get_node("Plus/Coop/Num").text = "-" + str(Cost_Coop)
	else:
		_PlusNode.get_node("Plus/Coop/Num").text = str(0)
func _On_Back_pressed() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return



	_Back_Logic()



func call_Back_puppet(_TYPE, _OVERTYPE, _NUM):
	SteamLogic.LevelDic["SPECIAL_NUM"] = _NUM
	if _OVERTYPE != 0:
		SteamLogic.LevelDic.IsFinish = false
	TYPE = _TYPE
	match TYPE:
		0:
			GameLogic.Audio.But_Apply.play(0)
			cur_show = false
			Ani.play("1")
			if GameLogic.cur_money < 0:
				$BG / Label / AnimationPlayer.play("broke")
			TYPE = 1
		1:
			cur_show = false
			GameLogic.Audio.But_Apply.play(0)
			GameLogic.GameUI.DayEnd = true
			Ani.play("init")
			TYPE = 2

func _Back_Logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if TYPE == 0:
		get_tree().get_root().get_node("Level").call_level_save()
	if GameLogic.SPECIALLEVEL_Int:
		GameLogic.SPECIAL_NUM = GameLogic.cur_Gift

		if GameLogic.GameOverType == 4:
			GameLogic.GameOverType = 0



	if cur_show:
		match TYPE:
			0:
				if Ani.assigned_animation != "0":
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_Back_puppet", [TYPE, GameLogic.GameOverType, GameLogic.SPECIAL_NUM])
				GameLogic.Audio.But_Apply.play(0)
				cur_show = false
				Ani.playback_speed = 1
				Ani.play("1")
				if GameLogic.cur_money < 0:
					$BG / Label / AnimationPlayer.play("broke")
				TYPE = 1
			1:

				cur_show = false
				GameLogic.Audio.But_Apply.play(0)
				GameLogic.GameUI.DayEnd = true
				Ani.play("init")
				ENDCHECK = false
				TYPE = 2
				var _LEVELINFO = GameLogic.cur_levelInfo

				var _Difficult: Array = _LEVELINFO.Difficult
				var _DAYMAX = _Difficult.size()

				if "难度-增加随机一日" in GameLogic.curLevelList:
					_DAYMAX += 1

				if GameLogic.cur_money < 0 and GameLogic.GameOverType == 0:
					GameLogic.GameOverType = 2
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_Back_puppet", [TYPE, GameLogic.GameOverType, GameLogic.SPECIAL_NUM])
				if GameLogic.cur_Day >= _DAYMAX:
					if GameLogic.GameOverType == 0:
						GameLogic.MissionComplete_bool = true
					GameLogic.call_save()
					GameLogic.call_HomeLoad()
					return
				if _LEVELINFO.GamePlay.has("新手引导1"):
					if GameLogic.cur_Day > 1:
						GameLogic.cur_Gift += 1
				if GameLogic.GameOverType == 0:
					GameLogic.emit_signal("RewardUI")
				else:
					GameLogic.call_save()
					GameLogic.call_HomeLoad()

func call_UI_End():
	if Ani.assigned_animation != "init":

		GameLogic.GameUI.DayEnd = true
		Ani.play("init")
		TYPE = 2
