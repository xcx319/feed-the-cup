extends StaticBody2D

var SPECIALTYPE: int = 0
var _LEVEL: String
var ChallengeList_1: Array
var ChallengeList_2: Array
var ChallengeList_3: Array
var CHALLANGEDIC: Dictionary

var _UpdateList: Array
var _DEVPICKLIST: Array
var _PICKLIST: Array
var _MENULIST: Array

var _DAYARRAY: Array = ["配方", "小料", "无", "事件", "精英事件"]
var _DAYList: Array
var cur_LevelMenu: Dictionary
var cur_ExtraMenu: Dictionary

var _CurNum: int

var item_count: int
var now_count: int
onready var ANI = $Info / Label / Ani
onready var view = $LEVELINFO / Control / InfoControl / BG / ViewportContainer / Viewport
onready var RewardLabel = $LEVELINFO / Control / InfoBG / BaseInfo1 / Reward / Label
onready var RewardMaxLabel = $LEVELINFO / Control / InfoBG / BaseInfo2 / RewardMax / Label

var LevelCamera
var _check = ERR_FILE_EOF

onready var ApplyBut = $LEVELINFO / Control / ButControl / ApplyBut
var LEVELINFO
onready var TrafficLabel = $LEVELINFO / Control / InfoBG / BaseInfo2 / Traffic / Label
var DevilList: Array
var TrafficNum: int
var TrafficList: Array = [20, 20, 20, 20, 30, 40, 50, 50, 60, 70, 80, 90, 100]
onready var loader: ResourceInteractiveLoader

var CANIN: bool
export var ALLPLAYERIN: bool = false
onready var BackBut = $LEVELINFO / Control / ButControl / BackBut

var UI_TYPE: int = 0
onready var UIANI = $Node / Ani
var Can_Control: bool = true
onready var FREEBUT = $SPECIAL_CHOOSE / Control / BG / Grid / Free
onready var COSTBUT = $SPECIAL_CHOOSE / Control / BG / Grid / Cost

var EVENT: String
var SpecialArray: Array = [
	"",
	"",
]

var LevelTypeArray: Array = [
	"社区店1",
	"社区店2",
	"社区店3",
	"美食街1",
	"美食街2",
	"美食街3",
	"美食街4",
	"写字楼1",
	"写字楼2",
	"写字楼3",
	"写字楼4",
	"公园1",
	"公园2",
	"公园3",
	"公园4",
	"体育场1",
	"体育场2",
	"体育场3",
	"体育场4",
	"古街1",
	"古街2",
	"古街3",
	"古街4",
	"游乐园1",
	"游乐园2",
	"游乐园3",
	"游乐园4",
	"酒吧1",
	"酒吧2",
	"酒吧3",
	"酒吧4",
	]
var LevelTypeID: int = 0
func _ready():
	call_hide()

func call_hide():
	$LEVELINFO.hide()

func call_init():
	match SPECIALTYPE:
		1:
			call_Special_1_init()
		2:
			call_Special_2_init()
func call_LoadEffect():
	var _Effect = GameLogic.TSCNLoad.LoadingEffect.instance()
	view.add_child(_Effect)

func call_Challenge_Set(_TYPE: int = 0):
	if _LEVEL in ["社区店1", "美食街1", "美食街2", "写字楼1", "写字楼2", "公园1", "公园2",
	"体育场1", "体育场2", "古街1", "古街2", "游乐园1", "游乐园2"]:
		var ChallengeArray: Array = [
		"难度-小偷",
		"难度-混混",
		"难度-批评家",
		"难度-学咖族",

		"难度-每日随机停电",
		"难度-设备故障",

		"难度-探店客",
		"难度-玻璃瓶",
		"难度-检查员",
		"难度-虫虫",
		"难度-大瓶顾客",
		"难度-双耳茶杯顾客",
		"难度-英式茶杯顾客",
		"难度-日式茶杯顾客",
		"难度-插队客",
		"难度-流浪杯",
		]

		for _DEVIL in LEVELINFO.DevilList:
			if ChallengeArray.has(_DEVIL):
				ChallengeArray.erase(_DEVIL)
		match _TYPE:
			1:

				var _CHALLRAND = GameLogic._SubStationRANDOM.randi() % ChallengeArray.size()



				LEVELINFO.DevilList.append(ChallengeArray[_CHALLRAND])
			2:
				var _CHALLRAND = GameLogic._SubRANDOM.randi() % ChallengeArray.size()



				LEVELINFO.DevilList.append(ChallengeArray[_CHALLRAND])
	var NewChallengeArray: Array = [
	"难度-各种顾客",
	"难度-顾客垃圾",

	"难度-小程序下单",

	"难度-陨石",
	"难度-督导",
	"难度-快速出杯",
	"难度-极限出杯",
	"难度-跳单出杯",

	"难度-暴击出杯",

	]
	if not LEVELINFO.DevilList.has("难度-虫虫"):
		NewChallengeArray.append("难度-虫虫")
	if not LEVELINFO.DevilList.has("难度-设备故障"):
		NewChallengeArray.append("难度-设备故障")
	if not LEVELINFO.DevilList.has("难度-每日随机停电"):
		NewChallengeArray.append("难度-每日随机停电")

	if not LEVELINFO.DevilList.has("难度-大瓶顾客"):
		NewChallengeArray.append("难度-大瓶顾客")

	var _EVENTLIST: Array = [
		"销售员+",
		"点单员+",
		"调整+",
		"手速",
		"抗压+",
		"等餐+",
		"无冰日",
		"无糖日"
	]
	match _TYPE:
			1:

				var _NewRAND = GameLogic._SubStationRANDOM.randi() % NewChallengeArray.size()


				LEVELINFO.DevilList.append(NewChallengeArray[_NewRAND])
				var _EVENTRAND = GameLogic._SubStationRANDOM.randi() % _EVENTLIST.size()
				EVENT = _EVENTLIST[_EVENTRAND]

			2:
				var _NewRAND = GameLogic._SubRANDOM.randi() % NewChallengeArray.size()


				LEVELINFO.DevilList.append(NewChallengeArray[_NewRAND])
				var _EVENTRAND = GameLogic._SubRANDOM.randi() % _EVENTLIST.size()
				EVENT = _EVENTLIST[_EVENTRAND]
func call_Special_2_init():
	var _DelArray: Array = ["测试关卡", "新手引导第一关",
	"社区店1",
	"社区店2",
	"社区店3",
	"美食街1",
	"美食街2",
	"美食街3",
	"美食街4",
	"写字楼1",
	"写字楼2",
	"写字楼3",
	"写字楼4",
	"公园1",
	"公园2",
	"公园3",
	"公园4",

	"古街1",
	"古街2",
	"古街3",
	"古街4",
	"游乐园1",
	"游乐园2",
	"游乐园3",
	"游乐园4",
	"酒吧1",
	"酒吧2",
	"酒吧3",
	"酒吧4",
	]


	$LEVELINFO / Control / InfoBG / BaseInfo1 / Update.call_Tr_TEXT("UI-随机升级")
	$LEVELINFO / Control / InfoBG / BaseInfo2 / Challenge.call_Tr_TEXT("UI-随机代价")
	_del_view()
	call_LoadEffect()
	if GameLogic.Save.gameData.has("SubRANDOM_State"):
		GameLogic._SubRANDOM.state = GameLogic.Save.gameData["SubRANDOM_State"]
	GameLogic.Save.gameData["SubRANDOM_State"] = GameLogic._SubRANDOM.state

	var _LEVELKEYS: Array = GameLogic.Save.gameData["Level_Data"].keys()

	for _LEVELDEL in _DelArray:
		if _LEVELKEYS.has(_LEVELDEL):
			_LEVELKEYS.erase(_LEVELDEL)

	var _RAND = GameLogic._SubRANDOM.randi() % _LEVELKEYS.size()
	_LEVEL = _LEVELKEYS[_RAND]
	if _LEVEL in LevelTypeArray:
		LevelTypeID = GameLogic._SubRANDOM.randi() % 4 + 1

	var _SCENEINFO = GameLogic.Config.SceneConfig[_LEVEL]
	LEVELINFO = _SCENEINFO.duplicate(true)
	call_Challenge_Set(2)


	LEVELINFO.OpenTime = 11
	LEVELINFO.CloseTime = 20
	TrafficList = [50, 50, 50, 50, 50, 50, 50, 50, 50, 100]
	for i in 24:
		if i < 11 or i > 20:
			LEVELINFO[str(i)] = 50
		else:
			var _TrafficRAND = GameLogic._SubRANDOM.randi() % TrafficList.size()
			var _TrafficNUM = TrafficList.pop_at(_TrafficRAND)
			if _TrafficNUM >= 100:
				$LEVELINFO / Control / InfoBG / BaseInfo2 / PeakTime / Label.text = str(i) + ":00"
			LEVELINFO[str(i)] = _TrafficNUM

	$LEVELINFO / Control / InfoBG / BaseInfo1 / DailyRent / Label.text = str(int(LEVELINFO.Rent) * 10)
	var GPNODE = $LEVELINFO / Control / InfoBG / GamePlay
	GPNODE.get_node("1").text = ""
	GPNODE.get_node("2").text = ""
	GPNODE.get_node("3").text = ""
	var _List = LEVELINFO.GamePlay
	var _CurNUM: int = 1
	for _i in _List.size():
		_CurNUM += _i
		if _List[_i] in ["每日增加半小时", "每日增加一刻钟"]:
			pass
		elif GPNODE.has_node(str(_CurNUM)):
			GPNODE.get_node(str(_CurNUM)).text = GameLogic.CardTrans.get_message(_List[_i])

	if LEVELINFO.DevilList.size() >= 2:
		_CurNUM += 1
		if GPNODE.has_node(str(_CurNUM)):
			GPNODE.get_node(str(_CurNUM)).text = GameLogic.CardTrans.get_message("信息-不可保存进度")
	call_DevUpdate_init()
	call_Update_init()
	call_Menu_init()
	call_Day_init()
	call_UI_init()
	call_Level_load()
	Choose_Init()
	_popular_set(int(LEVELINFO.StarMax))
func call_Special_1_init():
	var _DelArray: Array = ["测试关卡", "新手引导第一关",
	"社区店1",
	"社区店2",
	"社区店3",
	"美食街1",
	"美食街2",
	"美食街3",
	"美食街4",
	"写字楼1",
	"写字楼2",
	"写字楼3",
	"写字楼4",
	"公园1",
	"公园2",
	"公园3",
	"公园4",



	"古街1",
	"古街2",
	"古街3",
	"古街4",
	"游乐园1",
	"游乐园2",
	"游乐园3",
	"游乐园4",
	"酒吧1",
	"酒吧2",
	"酒吧3",
	"酒吧4",
	]
	$LEVELINFO / Control / InfoBG / BaseInfo1 / Update.call_Tr_TEXT("UI-指定升级")
	$LEVELINFO / Control / InfoBG / BaseInfo2 / Challenge.call_Tr_TEXT("UI-指定代价")
	_del_view()

	call_LoadEffect()


	var _STEAM_Time = Steam.getServerRealTime()
	var _DATA = OS.get_datetime_from_unix_time(_STEAM_Time)

	var _STR: String = str(_DATA.year) + str(_DATA.month) + str(_DATA.day)
	var _NUM = int(_STR)
	GameLogic._SubStationRANDOM.seed = _NUM
	var _LEVELKEYS: Array = GameLogic.Config.SceneConfig.keys()
	for _LEVELDEL in _DelArray:
		_LEVELKEYS.erase(_LEVELDEL)

	var _RAND = GameLogic._SubStationRANDOM.randi() % _LEVELKEYS.size()
	_LEVEL = _LEVELKEYS[_RAND]
	if _LEVEL in LevelTypeArray:
		LevelTypeID = GameLogic._SubStationRANDOM.randi() % 4 + 1

	printerr(" 地铁站:", _LEVEL)
	var _SCENEINFO = GameLogic.Config.SceneConfig[_LEVEL]
	LEVELINFO = _SCENEINFO.duplicate(true)
	call_Challenge_Set(1)

	LEVELINFO.OpenTime = 11
	LEVELINFO.CloseTime = 20
	TrafficList = [50, 50, 50, 50, 50, 50, 50, 50, 50, 100]
	for i in 24:
		if i < 11 or i > 20:
			LEVELINFO[str(i)] = 50
		else:
			var _TrafficRAND = GameLogic._SubStationRANDOM.randi() % TrafficList.size()
			var _TrafficNUM = TrafficList.pop_at(_TrafficRAND)
			if _TrafficNUM >= 100:
				$LEVELINFO / Control / InfoBG / BaseInfo2 / PeakTime / Label.text = str(i) + ":00"
			LEVELINFO[str(i)] = _TrafficNUM

	$LEVELINFO / Control / InfoBG / BaseInfo1 / DailyRent / Label.text = str(int(LEVELINFO.Rent) * 10)
	var GPNODE = $LEVELINFO / Control / InfoBG / GamePlay
	GPNODE.get_node("1").text = ""
	GPNODE.get_node("2").text = ""
	GPNODE.get_node("3").text = ""
	var _List = LEVELINFO.GamePlay
	var _CurList: int = 1
	for _i in _List.size():
		_CurList += _i
		if _List[_i] in ["每日增加半小时", "每日增加一刻钟"]:
			pass
		elif GPNODE.has_node(str(_CurList)):
			GPNODE.get_node(str(_CurList)).text = GameLogic.CardTrans.get_message(_List[_i])

	if LEVELINFO.DevilList.size() >= 2:
		_CurList += 1
		if GPNODE.has_node(str(_CurList)):
			GPNODE.get_node(str(_CurList)).text = GameLogic.CardTrans.get_message("信息-不可保存进度")
	call_DevUpdate_init()
	call_Update_init()
	call_Menu_init()
	call_Day_init()
	call_UI_init()
	call_Level_load()
	Choose_Init()
	_popular_set(int(LEVELINFO.StarMax))
func _popular_set(_Popular: int):


	var PopularLabel = $LEVELINFO / Control / InfoBG / BaseInfo1 / Popular
	var _StarList = PopularLabel.get_node("HBox").get_children()
	if _Popular <= 2:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i == 0:
				_Node.get_node("TextureProgress").value = _Popular
			else:
				_Node.get_node("TextureProgress").value = 0

	elif _Popular <= 4:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 1:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 1:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif _Popular <= 6:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 2:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 2:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif _Popular <= 8:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 3:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 3:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
	elif _Popular <= 10:
		for i in _StarList.size():
			var _Node = _StarList[i]
			if i < 4:
				_Node.get_node("TextureProgress").value = _Node.get_node("TextureProgress").max_value
			elif i == 4:
				_Node.get_node("TextureProgress").value = _Popular - _Node.get_node("TextureProgress").max_value
			else:
				_Node.get_node("TextureProgress").value = 0
func Choose_Init():

	var _HBox = $LEVELINFO / Control / Choose / HBox
	for _Node in _HBox.get_children():
		_HBox.remove_child(_Node)
		_Node.queue_free()
	var _test = LEVELINFO.DevilList
	var Devil_Max = LEVELINFO.DevilList.size()
	for i in Devil_Max:
		var _DevilIcon = GameLogic.TSCNLoad.DevilIcon_TSCN.instance()
		_DevilIcon.name = str(i)
		_HBox.add_child(_DevilIcon)
		_HBox.move_child(_DevilIcon, 0)
		_DevilIcon.call_type(i)

		if i >= 0 and LEVELINFO.DevilList.size() > (i):

			_DevilIcon.call_Str(LEVELINFO.DevilList[i])
		_DevilIcon.get_node("Ani").play("select")

func call_UI_init():
	LEVELINFO.Funds = str(int(LEVELINFO.Funds) * 10)

	$LEVELINFO / Control / InfoBG / BaseInfo1 / CostMoney / Label.text = LEVELINFO.Funds
	$LEVELINFO / Control / InfoBG / BaseInfo1 / DayCount / Label.text = "1"
	var _PlayerNUM = SteamLogic.PlayerNum
	var _Mult: float = 2
	match _PlayerNUM:
		0, 1:
			_Mult = 2
		2, - 2:
			_Mult = 1.5
		3:
			_Mult = 1.1
		4:
			_Mult = 0.8

	LEVELINFO.HomeMoneyMult = str(_Mult)

	RewardLabel.text = str(_Mult / 2) + "%" + "(" + str(_Mult) + "%" + ")"
	var _MAX: String = LEVELINFO.HomeMoneyMax
	RewardMaxLabel.text = str(int(float(_MAX) / 2)) + "(" + str(int(_MAX) * 3) + ")"

	call_Traffic_set()

func call_Traffic_set():
	TrafficNum = int(LEVELINFO.PV)
	TrafficNum += LEVELINFO.DevilList.size() - 1

	if SteamLogic.IsMultiplay:
		match SteamLogic.PlayerNum:
			2:
				TrafficNum += 1
			3:
				TrafficNum += 2
			4:
				TrafficNum += 3
	elif GameLogic.Player2_bool:
		TrafficNum += 1


	if TrafficNum == 0:
		TrafficNum = 1
	if SPECIALTYPE in [2]:
		TrafficNum -= 1
	if LEVELINFO.DevilList.has("难度-大瓶顾客"):
		TrafficNum -= 1
	if LEVELINFO.DevilList.has("难度-顾客小增加"):
		TrafficNum += 1
	if LEVELINFO.DevilList.has("难度-顾客中增加"):
		TrafficNum += 2

	if LEVELINFO.DevilList.has("难度-顾客大增加"):
		TrafficNum += 3
	if TrafficNum > 9:
		TrafficNum = 9
	if TrafficNum == 0:
		TrafficNum = 1
	var _TrafficText = "信息-客流" + str(TrafficNum)
	TrafficLabel.text = GameLogic.CardTrans.get_message(_TrafficText)
	TrafficLabel.get_node("AnimationPlayer").play(str(TrafficNum))

func call_DevUpdate_init():
	_UpdateList.clear()
	_DEVPICKLIST.clear()
	var _DEVNUM: int = 6
	var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVEL]
	var _MACHINE = _LEVELINFO.Machine
	if _MACHINE.has("汽水机"):
		_DEVPICKLIST.append("气泡水机升级")

	if _MACHINE.has("软饮机"):
		_DEVPICKLIST.append("软饮机升级")

	if _MACHINE.has("封盖机"):
		_DEVPICKLIST.append("封盖机升级")
		_UpdateList.append("封盖机升级")
		_DEVNUM -= 1

	if _MACHINE.has("咖啡机"):
		_UpdateList.append("咖啡机升级")
		_DEVPICKLIST.append("咖啡机升级")
		_DEVNUM -= 1

	if _MACHINE.has("制冰机"):
		_DEVPICKLIST.append("制冰机升级")

	if _MACHINE.has("蒸汽机"):
		_DEVPICKLIST.append("蒸汽机升级")

	if _MACHINE.has("电磁炉"):
		_DEVPICKLIST.append("电磁炉升级")

	_DEVPICKLIST.append("垃圾桶升级")

	_DEVPICKLIST.append("杯架升级")

	_DEVPICKLIST.append("果糖机升级")




	for i in _DEVNUM:
		var _RANDI
		if SPECIALTYPE == 1:
			_RANDI = GameLogic._SubStationRANDOM.randi()
		else:
			_RANDI = GameLogic._SubRANDOM.randi()
		if _DEVPICKLIST.size():
			var _RANDNUM = _RANDI % _DEVPICKLIST.size()
			var _PICK = _DEVPICKLIST[_RANDNUM]
			_DevUpdate_Check(_PICK)

func _DevUpdate_Check(_PICK):
	if not _PICK in _UpdateList:
		_UpdateList.append(_PICK)
		if _PICK in ["新增桌台"]:
			_DEVPICKLIST.erase(_PICK)
	else:
		var _PLUS = _PICK + "+"
		_UpdateList.erase(_PICK)
		_DEVPICKLIST.erase(_PICK)
		_UpdateList.append(_PLUS)

func call_Update_init():
	_PICKLIST.clear()

	_UpdateList.append("新增桌台")
	var _LIST = GameLogic.Config.CardConfig.keys()
	for _CARDNAME in _LIST:
		var _CARDINFO = GameLogic.Config.CardConfig[_CARDNAME]
		if _CARDINFO.Rank == "T":
			if _CARDINFO.MainType == "0":
				if _CARDINFO.UnlockType == "-1":
					_PICKLIST.append(_CARDNAME)
	if _PICKLIST.has("自检狂"):
		_PICKLIST.erase("自检狂")
	var _UPDATE: int = 8


	if not _PICKLIST.has("新增桌台"):
		_PICKLIST.append("新增桌台")

	$LEVELINFO / Control / InfoBG / BaseInfo1 / Update / Label.text = str(20)
	for i in _UPDATE:
		var _RANDI
		if SPECIALTYPE == 1:
			_RANDI = GameLogic._SubStationRANDOM.randi()
		else:
			_RANDI = GameLogic._SubRANDOM.randi()

		var _RANDNUM = _RANDI % _PICKLIST.size()
		var _PICK = _PICKLIST[_RANDNUM]

		if not _PICK in _UpdateList:
			_UpdateList.append(_PICK)
		else:
			var _PLUS = _PICK + "+"
			_UpdateList.erase(_PICK)
			_UpdateList.append(_PLUS)
			_PICKLIST.erase(_PICK)

	_ChallengeList()

func call_Day_init():

	_DAYList = ["地铁"]

func call_Formula_init():

	var _LEVELINFO = GameLogic.Config.SceneConfig[_LEVEL]
	cur_LevelMenu.clear()
	cur_ExtraMenu.clear()
	if not _LEVELINFO.has("Type"):
		return

	var _TypeList = _LEVELINFO.Type
	var _TagList = _LEVELINFO.Tag
	var _MachineList = _LEVELINFO.Machine

	var _Sugar = bool(_LEVELINFO.Sugar)

	var _S = bool(_LEVELINFO.S)
	var _M = bool(_LEVELINFO.M)
	if LEVELINFO.DevilList.has("难度-小变中"):
		_M = true
	if LEVELINFO.DevilList.has("难度-新增鲜柠汁M"):
		_M = true

	var _L = bool(_LEVELINFO.L)
	if not GameLogic.Config.FormulaConfig:
		return
	var _FormulaKeys = GameLogic.Config.FormulaConfig.keys()
	for _Formula in _FormulaKeys:
		var _FormulaData = GameLogic.Config.FormulaConfig[_Formula]
		if "CAN" in _FormulaData.Type:
			var _ExtraTypeList = _LEVELINFO.Can
			for _TAG in _FormulaData.Tag:
				if _TAG in _ExtraTypeList:
					if not cur_ExtraMenu.has(_Formula):
						cur_ExtraMenu[_Formula] = _FormulaData

		for _Type in _TypeList:
			if _Type in _FormulaData.Type:
				var _TagCheck: bool
				if not _FormulaData.Tag:
					_TagCheck = true
				else:
					_TagCheck = true
					for _Tag in _FormulaData.Tag:
						if not _Tag in _TagList:
							_TagCheck = false
							break
						else:
							pass
				if _TagCheck:
					var _MachineCheck: bool
					if not _FormulaData.Machine:
						_MachineCheck = true
					else:
						for _Machine in _FormulaData.Machine:
							if _Machine in _MachineList:
								_MachineCheck = true
							else:
								_MachineCheck = false
								break
					if _MachineCheck:
						var _SUGERTYPE: int = int(_FormulaData.SugarType)
						if _Sugar or ( not _Sugar and _SUGERTYPE == 0):

							if not _FormulaData.CupType or (_S and _FormulaData.CupType == "S") or (_M and _FormulaData.CupType == "M") or (_L and _FormulaData.CupType == "L"):
								cur_LevelMenu[_Formula] = _FormulaData

func call_Menu_init():
	call_Formula_init()
	var _FormulaList = cur_LevelMenu
	var _FormulaKeys = _FormulaList.keys()


	var _CanPickList: Array
	var _WeightCount: int = 0
	var _Rank: int = 10
	for i in _FormulaKeys.size():

		if _Rank >= int(_FormulaList[_FormulaKeys[i]].Rank):
			if not _CanPickList.has(_FormulaKeys[i]):
				_CanPickList.append(_FormulaKeys[i])
				_WeightCount += int(_FormulaList[_FormulaKeys[i]].Weight)
	print("可Pick：", _CanPickList, "_WeightCount", _WeightCount)
	_MENULIST.clear()
	var _LEVELMENUMAX: int = int(GameLogic.Config.SceneConfig[_LEVEL].MenuMax)
	for i in _LEVELMENUMAX:
		var _RANDI
		if SPECIALTYPE == 1:
			_RANDI = GameLogic._SubStationRANDOM.randi()
		else:
			_RANDI = GameLogic._SubRANDOM.randi()
		var _RAND = _RANDI % _CanPickList.size()
		var _MENU = _CanPickList.pop_at(_RAND)
		_MENULIST.append(_MENU)
	print("配方：", _MENULIST)

func _ChallengeList():
	ChallengeList_1.clear()
	ChallengeList_2.clear()
	ChallengeList_3.clear()
	CHALLANGEDIC.clear()
	var _ChallengeKeys = GameLogic.Config.ChallengeConfig.keys()
	for _ChallengeName in _ChallengeKeys:
		if LEVELINFO.DevilList.has("难度-极限出杯") and _ChallengeName in ["准时承诺", "准时承诺+"]:
			pass

		elif not _ChallengeName in ["夜班偷懒", "夜班偷懒+", "夜班偷懒++"]:
			var _CHALLRANK = int(GameLogic.Config.ChallengeConfig[_ChallengeName].Rank)
			match _CHALLRANK:
				1:
					if not ChallengeList_1.has(_ChallengeName):
						ChallengeList_1.append(_ChallengeName)
				2:
					if not ChallengeList_2.has(_ChallengeName):
						ChallengeList_2.append(_ChallengeName)
				3:
					if not ChallengeList_3.has(_ChallengeName):
						ChallengeList_3.append(_ChallengeName)

	var _CHALLNUM: int = 7
	var _L1: int = 3
	var _L2: int = 2
	if SPECIALTYPE == 2:
		_CHALLNUM = 7
		_L1 = 3
		_L2 = 2
	$LEVELINFO / Control / InfoBG / BaseInfo2 / Challenge / Label.text = str(_CHALLNUM)
	for i in _CHALLNUM:
		var _RANDI
		if SPECIALTYPE == 1:
			_RANDI = GameLogic._SubStationRANDOM.randi()
		else:
			_RANDI = GameLogic._SubRANDOM.randi()
		if i < _L1:

			var _RAND = _RANDI % ChallengeList_1.size()
			var _CHALL = ChallengeList_1[_RAND]

			CHALLANGEDIC[_CHALL] = GameLogic.Config.ChallengeConfig[_CHALL]
		elif i < _L1 + _L2:
			var _RAND = _RANDI % ChallengeList_2.size()
			var _CHALL = ChallengeList_2[_RAND]

			CHALLANGEDIC[_CHALL] = GameLogic.Config.ChallengeConfig[_CHALL]
		else:
			var _RAND = _RANDI % ChallengeList_3.size()
			var _CHALL = ChallengeList_3[_RAND]
			CHALLANGEDIC[_CHALL] = GameLogic.Config.ChallengeConfig[_CHALL]

func call_puppet_PLAYERIN():
	$CanvasLayer / InfoAni.play("play")

func _on_ApplyBut_pressed():

	if GameLogic.cur_level:
		return
	if not CANIN:
		return
	if not ALLPLAYERIN:
		$CanvasLayer / InfoAni.play("play")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_PLAYERIN")
		return
	var _COST = SteamLogic.PlayerNum * 500
	if SPECIALTYPE == 2:
		_COST = 0

	if GameLogic.return_FullHMK() < _COST:
		$CanvasLayer / InfoAni.play("homemoney")
		return
	GameLogic.cur_level = _LEVEL

	GameLogic.Audio.But_Apply.play(0)
	CANIN = false

	GameLogic.SPECIALLEVEL_Int = SPECIALTYPE
	GameLogic.SPECIAL_DAY = _DAYList
	GameLogic.cur_Rewards = _UpdateList
	GameLogic.cur_Challenge = CHALLANGEDIC


	GameLogic.call_NewLevel_Init()

	GameLogic.Can_ESC = true

	GameLogic.cur_level = _LEVEL
	GameLogic.new_bool = true


	GameLogic.cur_StoreStar = int(GameLogic.Config.SceneConfig[_LEVEL].StarMax)
	GameLogic.Card.call_Event_init()
	GameLogic.Can_Card = true


	GameLogic.cur_Menu = _MENULIST
	GameLogic.cur_Devil = LEVELINFO.DevilList.size()
	GameLogic.cur_Day = 7
	GameLogic.cur_MenuNum = LEVELINFO.MenuStart
	GameLogic.cur_money = int(LEVELINFO.Funds)

	GameLogic.GameOverType = 4
	GameLogic.cur_levelInfo = LEVELINFO.duplicate(true)
	var _x = GameLogic.cur_levelInfo.DevilList
	GameLogic.Order.call_Formula_init()

	GameLogic.call_SceneConfig_load(true)
	if SPECIALTYPE == 1:
		GameLogic.call_MoneyHomeChange(_COST * - 1, GameLogic.HomeMoneyKey)
	for _i in GameLogic.Traffic_Array.size():
		if LEVELINFO.has(str(_i)):
			GameLogic.Traffic_Array[_i] = LEVELINFO[str(_i)]

	GameLogic.call_save()

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

		SteamLogic.call_send_Data()
		var _SetLevel = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Level", GameLogic.cur_level)
		var _SerDevil = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Devil", str(GameLogic.cur_Devil))
		var _SetDay = Steam.setLobbyData(SteamLogic.LOBBY_ID, "Day", str(GameLogic.cur_Day))


	GameLogic.cur_Event = EVENT
	var _LOBBY_Level = GameLogic.cur_level

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_PlayerNum()
		SteamLogic.call_everybody_sync("LoadingLevel", [{"cur_levelInfo": GameLogic.cur_levelInfo, "SPECIALLEVEL_Int": GameLogic.SPECIALLEVEL_Int, "LevelType": LevelTypeID, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SteamLogic.SLOT, "SLOT_2": SteamLogic.SLOT_2, "SLOT_3": SteamLogic.SLOT_3, "SLOT_4": SteamLogic.SLOT_4}])
	GameLogic.call_LevelLoad(_LOBBY_Level, LevelTypeID)

func call_Level_load():
	CANIN = false
	loader = GameLogic.TSCNLoad.loader
	var _SceneName = GameLogic.Config.SceneConfig[_LEVEL].TSCN
	match LevelTypeID:
		0:
			pass
		_:
			_SceneName = _SceneName + "_" + str(LevelTypeID - 1)

	var _path = "res://TscnAndGd/Main/Level/" + _SceneName + ".tscn"
	var _checkbool = ResourceLoader.exists(_path)
	if not _checkbool:
		print("LoadingUI 错误，MainUILoad 地址不存在。")
		return
	if ResourceLoader.has_cached(_path):

		if loader != null:

			if loader.get_resource():
				var _TSCN = loader.get_resource()

				var _TSCN_Instance = _TSCN.instance()
				_del_view()
				view.add_child(_TSCN_Instance)
				LevelCamera = _TSCN_Instance.get_node("CameraNode/Camera2D")

				_check = ERR_FILE_EOF
				ApplyBut.show()
				CANIN = true
				return
	loader = ResourceLoader.load_interactive(_path)

	if loader != null:
		item_count = loader.get_stage_count()
		set_process(true)
func _process(_delta):
	if loader != null:

		now_count = loader.get_stage()


		_check = loader.poll()
		if _check == ERR_FILE_EOF:
			var _TSCN = loader.get_resource()

			var _TSCN_Instance = _TSCN.instance()
			_del_view()
			view.add_child(_TSCN_Instance)
			LevelCamera = _TSCN_Instance.get_node("CameraNode/Camera2D")



			set_process(false)
			GameLogic.TSCNLoad.loader = loader
			ApplyBut.show()
			CANIN = true

		elif _check != OK:
			print("start loader check error:", _check, " loader:", loader.get_stage(), " count:", loader.get_stage_count())

func _del_view():
	var _viewArray = view.get_children()
	for i in _viewArray.size():
		var _Obj = _viewArray[i]
		_Obj.queue_free()

func _on_Area2D_body_entered(_body):
	if GameLogic.LoadingUI.IsHome and SteamLogic.STEAM_ID != 0:
		if _body.cur_Player in [SteamLogic.STEAM_ID]:
			if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
				GameLogic.Con.connect("P1_Control", self, "_control_logic")
	var _x = self.scale
	if self.scale.x < 0:
		$Info.scale.x = - 1
	if GameLogic.cur_level:
		ANI.play("NoIn")
	else:
		ANI.play("play")
func _on_Area2D_body_exited(_body):

	if _body.cur_Player in [SteamLogic.STEAM_ID]:
		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	ANI.play("init")
func _control_logic(_But, _Value, _Type):
	print("Substation:", _But)
	match _But:
		"l", "L":
			if _Value == 1:
				if UI_TYPE == 1:
					if Can_Control:
						FREEBUT.pressed = true
						_on_Free_pressed()
		"r", "R":
			if _Value == 1:
				if UI_TYPE == 1:
					if Can_Control:
						COSTBUT.pressed = true
						_on_Cost_pressed()
		0, "A":
			if _Value == 1:

				if GameLogic.cur_level:
					return
				print("地铁测试：", UI_TYPE, " Can_Control： ", Can_Control)
				match UI_TYPE:
					0:
						call_start()
					1:
						if Can_Control and SPECIALTYPE:
							call_show()
					2:
						if Can_Control and CANIN:
							_on_ApplyBut_pressed()

		"B", "START":
			if Can_Control:
				match UI_TYPE:
						1:
							_on_BackBut_pressed()
						2:
							call_Choose_show()

func call_start():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not Can_Control:
		return
	GameLogic.Can_ESC = false
	UI_TYPE = 1
	Can_Control = false
	GameLogic.Audio.But_Apply.play(0)
	GameLogic.player_1P.call_control(1)

	GameLogic.player_2P.call_control(1)
	UIANI.play("Start")
func call_Control():
	Can_Control = true
func call_LEVEL_show():
	if not Can_Control:
		return

	UI_TYPE = 2
	Can_Control = false
	GameLogic.Audio.But_Apply.play(0)
	UIANI.play("show_Level")
func call_Choose_show():
	if not Can_Control:
		return

	UI_TYPE = 1
	Can_Control = false
	GameLogic.Audio.But_Back.play(0)
	UIANI.play("show_Choose")
func call_show():

	call_LEVEL_show()
	call_init()

func call_close():
	UI_TYPE = 0
	Can_Control = true
	GameLogic.Audio.But_Back.play(0)
	UIANI.play("init")
	yield(get_tree().create_timer(0.1), "timeout")
	GameLogic.Can_ESC = true
func _on_BackBut_pressed():
	if not Can_Control:
		return
	call_close()
	GameLogic.player_1P.call_control(0)
	GameLogic.player_2P.call_control(0)

func _on_Free_pressed():
	SPECIALTYPE = 1

func _on_Cost_pressed():
	SPECIALTYPE = 2

func _on_LEVEL_BackBut_pressed():
	call_Choose_show()

func _on_Choose_ApplyBut_pressed():
	call_show()

func _on_PlayerArea2D_body_entered(body):
	if body.has_method("_PlayerNode"):
		_CurNum += 1
	if SteamLogic.IsMultiplay:
		if SteamLogic.LOBBY_MEMBERS.size() == _CurNum:
			ALLPLAYERIN = true

		else:
			ALLPLAYERIN = false

	else:
		if GameLogic.Player2_bool:
			if _CurNum == 2:
				ALLPLAYERIN = true

			else:
				ALLPLAYERIN = false

		else:
			ALLPLAYERIN = true

func _on_PlayerArea2D_body_exited(body):
	if body.has_method("_PlayerNode"):
		_CurNum -= 1
		if SteamLogic.LOBBY_MEMBERS.size() == _CurNum:
			ALLPLAYERIN = true

		else:
			ALLPLAYERIN = false
