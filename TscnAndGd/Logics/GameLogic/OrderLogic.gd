extends Node

onready var world
onready var OrderNode
var OrderCount: int
var cur_SeatList: Array
var cur_OrderList = {}
var cur_OrderArray: Array
var cur_CupArray: Array

signal NewOrder(_type)
signal OrderUpdate(_ID)
var cur_LevelMenu: Dictionary
var cur_ExtraMenu: Dictionary
var cur_LineUpArray: Array
var cur_TableOrderArray: Array
var cur_menu: Array
var Can_Cold: bool
var Can_Hot: bool
var Can_Normal: bool


enum CUPTYPE{
	S
	M
	L
}
enum LIQUIDTYPE{
	MIX
	LAYER
}
enum SUGARTYPE{
	ANY
	NOSUGAR
	SUGAR
	FREE
}

var EXTRATAGLIST: Array = ["其他配料", "万能配料", "奶茶配料", "自制配料", "水果配料", "冰淇淋配料"]

var SUGAR_FREE_BOOL: bool
enum ORDERTYPE{
	COFFEE
	MILK
	MILKTEA
	TEA
	SOYBEAN
	FRUIT
	SHAKE
	ICECREAM
	POP
	HEALTH
	FRUITTEA
}

enum ORDERPERSONAL{
	NONE
	EXPENSIVE
	CHEAPEST
	POPULAR
	FAVOURITE
	CANPAY
	ORDERCHEAPEST
	NOORDER
}

func call_OrderNode_init():
	OrderNode = GameLogic.GameUI.OrderBox

var NoSellTagList = ["冰淇淋配料", "万能配料", "其他配料", "奶茶配料", "自制配料", "水果配料", "禁用"]

func call_SugarFree_Check():
	SUGAR_FREE_BOOL = false
	for _MENU in GameLogic.cur_Menu:
		var _INFO = GameLogic.Config.FormulaConfig[_MENU]
		if int(_INFO.SugarType) > 1:
			SUGAR_FREE_BOOL = true
			GameLogic.call_Reward()
			break
	pass
func call_check(_Type: String):
	match _Type:
		"Hot":
			Can_Hot = true
		"Cold":
			Can_Cold = true
	if Can_Hot and Can_Cold:
		Can_Normal = true

func call_Formula_init():

	if not GameLogic.cur_level:
		return
	var _LEVELINFO = GameLogic.cur_levelInfo

	if not _LEVELINFO.has("Type"):
		GameLogic.call_SceneConfig_load()


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
	var _L = bool(_LEVELINFO.L)
	if not GameLogic.Config.FormulaConfig:
		return
	var _FormulaKeys = GameLogic.Config.FormulaConfig.keys()
	for _Formula in _FormulaKeys:
		var _FormulaData = GameLogic.Config.FormulaConfig[_Formula]

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


func call_NewMenu(_MaxNum: int):
	GameLogic.cur_Extra.clear()
	GameLogic.cur_ExtraBase.clear()
	GameLogic.cur_Menu.clear()
	var _LEVELINFO = GameLogic.cur_levelInfo

	var _Sugar = bool(_LEVELINFO.Sugar)
	var _StoreStartRank = GameLogic.cur_StoreStar
	if _StoreStartRank < 1:
		_StoreStartRank = 1
	var _List: Array
	var _MenuArray = cur_LevelMenu.keys()

	for i in _MenuArray.size():
		var _Info = cur_LevelMenu[_MenuArray[i]]
		if int(_Info.Rank) == _StoreStartRank:

			var _SUGERTYPE: int = int(_Info.SugarType)
			if not _Sugar or (_Sugar and _SUGERTYPE > 0):

				if not _Info.Tag[0] in NoSellTagList:
					_List.append(_MenuArray[i])

	if _List.size():

		for i in _MaxNum:
			var _RAND = GameLogic.return_randi() % _List.size()
			var _Menu = _List[_RAND]
			_List.remove(_RAND)
			GameLogic.cur_Menu.append(_Menu)
	else:
		printerr("菜单错误 初始化菜单为空。")
	GameLogic.Buy.call_init()

func call_init():
	OrderCount = 0
	cur_OrderList.clear()
	cur_CupArray.clear()
	cur_OrderArray.clear()
	cur_LineUpArray.clear()
	cur_TableOrderArray.clear()

func return_formula_dir(_FormulaName):
	var _Formula_Num = int(GameLogic.Config.FormulaConfig[_FormulaName]["FormulaNum"])
	var _Formula_List: Dictionary
	for i in _Formula_Num:
		var _Name = "For_" + str(i + 1)
		var _NumName = "For_" + str(i + 1) + "_Num"
		_Formula_List[GameLogic.Config.FormulaConfig[_FormulaName][_Name]] = GameLogic.Config.FormulaConfig[_FormulaName][_NumName]
	return _Formula_List

func _return_CupType(_type: String):
	match _type:
		"S":
			return CUPTYPE.S
		"M":
			return CUPTYPE.M
		"L":
			return CUPTYPE.L

func call_NPC_LineUp(_NPC):
	cur_LineUpArray.append(_NPC)
	if cur_LineUpArray.size():
		GameLogic.Staff.Need_Order = true
func call_NPC_TableOrder(_NPC):
	if not cur_TableOrderArray.has(_NPC):
		cur_TableOrderArray.append(_NPC)
	if cur_TableOrderArray.size():
		GameLogic.Staff.Need_Order = true

func return_order_NPC(_NPC):

	cur_menu.clear()
	for _Menu in GameLogic.cur_Menu:
		cur_menu.append(_Menu)

	var _OrderName = null
	match _NPC.Order_Personal:
		ORDERPERSONAL.NONE:
			_OrderName = _return_Order_Normal(_NPC, - 1)
		ORDERPERSONAL.EXPENSIVE:
			_OrderName = _return_Order_Expensive()
		ORDERPERSONAL.CHEAPEST:
			_OrderName = _return_Order_Cheapest()
		ORDERPERSONAL.POPULAR:
			_OrderName = _return_Order_Popular()
		ORDERPERSONAL.FAVOURITE:
			pass
		ORDERPERSONAL.ORDERCHEAPEST:
			_OrderName = _return_Order_Normal(_NPC, 1)
		ORDERPERSONAL.NOORDER:
			_OrderName = null
	print("点单：", _OrderName, " Order_Personal:", _NPC.Order_Personal)

	if _OrderName:
		var _TagList = GameLogic.Config.FormulaConfig[_OrderName].Tag
		var _check: bool = true
		for _Tag in _TagList:
			if _Tag in NoSellTagList:
				_check = false
		if _check:
			return _OrderName
		else:
			printerr("未点到订单，需检查逻辑")
			return ""
	else:

		printerr("未点到订单，需检查逻辑")
		return ""
func call_NPC_order(_NPC):
	if cur_LineUpArray.has(_NPC):
		cur_LineUpArray.erase(_NPC)
		_OrderLogic(_NPC)
		if _NPC.SpecialType == 6:
			_OrderLogic(_NPC)
func call_TableOrder(_NPC, _PLUS: int = 0):
	if cur_TableOrderArray.has(_NPC):
		cur_TableOrderArray.erase(_NPC)
		_OrderLogic(_NPC, _PLUS)
		if _NPC.SpecialType == 6:
			_OrderLogic(_NPC, _PLUS)
func call_order(_PLUS: int = 0, _TYPELOGIC: int = 0):
	if not cur_LineUpArray.size():
		return

	var _NPC = cur_LineUpArray.pop_front()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(self, "cur_LineUpArray", cur_LineUpArray)
	_OrderLogic(_NPC, _PLUS, _TYPELOGIC)
	if _NPC.SpecialType == 6:
		_OrderLogic(_NPC, _PLUS, _TYPELOGIC)
func call_NoOrder():
	if not cur_LineUpArray.size():
		return
	var _NPC = cur_LineUpArray.pop_front()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(self, "cur_LineUpArray", cur_LineUpArray)
	_NPC.call_leaving()
func _OrderLogic(_NPC, _PLUS: int = 0, _TYPELOGIC: int = 0):
	if not cur_LineUpArray.size() and not cur_TableOrderArray.size():
		GameLogic.Staff.Need_Order = false



	if not is_instance_valid(_NPC):
		printerr("NPC 不在LineUpArray当中。请检查问题。")
		return
	var _OrderName = _NPC.OrderName


	var _Extra_Array: Array = []
	var _ExtraList: Array
	var _ORDERINFO = GameLogic.Config.FormulaConfig[_OrderName]
	if _ORDERINFO.Extra_1 != "":
		_Extra_Array.append(_ORDERINFO.Extra_1)
		if _ORDERINFO.Extra_2 != "":
			_Extra_Array.append(_ORDERINFO.Extra_2)
			if _ORDERINFO.Extra_3 != "":
				_Extra_Array.append(_ORDERINFO.Extra_3)
	if _NPC.Order_Extra_Base:

		for _Extra in GameLogic.cur_Menu:

			for _TAG in GameLogic.Config.FormulaConfig[_Extra].Tag:
				if _TAG in ["万能配料", "奶茶配料", "自制配料", "其他配料", "水果配料", "冰淇淋配料"]:
					_ExtraList.append(_Extra)
					break

	if _ExtraList.size() > 0:
		var _CupType = _ORDERINFO.CupType
		var _ExtraMax: int
		match _CupType:
			"S":
				_ExtraMax = 1
			"M":
				_ExtraMax = 2
			"L":
				_ExtraMax = 3
		if int(_ORDERINFO.MakeType) == 4:
			_ExtraMax = 5

		var CanExtraNum = _ExtraMax - _Extra_Array.size()
		if _NPC.Order_Extra_Max:
			CanExtraNum = _ExtraMax
		if CanExtraNum > 0:


			var _rand = CanExtraNum
			if not _NPC.Order_Extra_Max:
				_rand = 1 + GameLogic.return_randi() % CanExtraNum

			for _i in _rand:
				if _Extra_Array.size() < _ExtraMax:
					if _ExtraList.size() > 0:
						var _randList = GameLogic.return_randi() % _ExtraList.size()

						_Extra_Array.append(_ExtraList[_randList])
					else:
						_Extra_Array.append(_ExtraList[0])


	if not _OrderName:
		_NPC.call_leaving()
	else:
		GameLogic.call_order()

		if GameLogic.cur_Rewards.has("耐心挑战"):
			if _NPC.OrderAngryBool:
				GameLogic.cur_AngryOrder += 1
				GameLogic.call_Info(1, "耐心挑战")

				var _MULT: float = 50 * (1 - _NPC.OrderAngryTimer.time_left / _NPC.OrderAngryTimer.wait_time)
				var _MONEY: int = _MULT * GameLogic.return_Multiplayer()
				if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
					_MONEY = int(float(_MONEY) * 1.5)
				GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

				var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
				_PayEffect.position = _NPC.global_position
				GameLogic.Staff.LevelNode.add_child(_PayEffect)
				_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)

		elif GameLogic.cur_Rewards.has("耐心挑战+"):
			if _NPC.OrderAngryBool:
				GameLogic.cur_AngryOrder += 1
				GameLogic.call_Info(1, "耐心挑战+")

				var _MULT: float = 150 * (1 - _NPC.OrderAngryTimer.time_left / _NPC.OrderAngryTimer.wait_time)

				var _MONEY: int = _MULT * GameLogic.return_Multiplayer()
				if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
					_MONEY = int(float(_MONEY) * 1.5)
				GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

				var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
				_PayEffect.position = _NPC.global_position
				GameLogic.Staff.LevelNode.add_child(_PayEffect)
				_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)



		_NPC.call_wait_logic()


	var _Celcius_Array: Array

	var _LEVELINFO = GameLogic.cur_levelInfo

	if int(_ORDERINFO.IceBreak) > 0:
		match _NPC.IceBreakType:
			1:
				_Celcius_Array.append("粗冰")
			2:
				_Celcius_Array.append("细冰")
	else:
		if _ORDERINFO.Finish in ["冰", "沙冰"]:
			_Celcius_Array.append("Cold")
		elif _LEVELINFO.Machine.has("制冰机"):
			var _check = bool(_ORDERINFO.CanCold)
			if _check:
				_Celcius_Array.append("Cold")
		if _ORDERINFO.Finish == "热":
			_Celcius_Array.append("Hot")
		elif _LEVELINFO.Machine.has("蒸汽机"):
			var _check = bool(_ORDERINFO.CanHot)
			if _check:
				_Celcius_Array.append("Hot")
		if _ORDERINFO.Finish == "常温":
			_Celcius_Array.append("Normal")
		elif _LEVELINFO.Machine.has("蒸汽机"):
			if _LEVELINFO.Machine.has("制冰机"):
				var _check = bool(_ORDERINFO.CanNormal)
				if _check:
					_Celcius_Array.append("Normal")



	if _Celcius_Array.size() == 0:
		return
	var _RAND = GameLogic.return_randi() % _Celcius_Array.size()
	var _Celcius = _Celcius_Array[_RAND]

	if GameLogic.cur_Event == "加冰日":
		if not _Celcius in ["粗冰", "细冰", "Cold"]:
			_Celcius = "Cold"



	var _Sugar_Array: Array
	var _OrderSugar = _NPC.Order_Sugar
	var _Sugar
	var _POPMAX = int(_ORDERINFO.PopMax)
	var _Pop: int = _POPMAX

	if _NPC.SpecialType in [7] and _POPMAX > 0:
		_Pop = GameLogic.return_randi() % 3 + 1
	var _BEERPOPNUM = int(_ORDERINFO.BeerPop)
	var _BeerPop: int = _BEERPOPNUM
	if _BEERPOPNUM > 0:
		if GameLogic.curLevelList.has("难度-啤酒泡"):
			_BeerPop = GameLogic.return_randi() % (_BEERPOPNUM + 1)
	if GameLogic.cur_Event == "加糖日":
		var _TYPE: int = int(_ORDERINFO.SugarType)
		match _TYPE:
			0:
				if GameLogic.Buy.Sell_1.has("Sugar") or GameLogic.Buy.Sell_1.has("Choco"):
					_Sugar_Array.append(SUGARTYPE.SUGAR)
				if GameLogic.Buy.Sell_1.has("FreeSugar"):
					_Sugar_Array.append(SUGARTYPE.FREE)
			1:
				_Sugar_Array.append(SUGARTYPE.SUGAR)
			2:
				_Sugar_Array.append(SUGARTYPE.FREE)
			3:
				_Sugar_Array.append(SUGARTYPE.SUGAR)
				_Sugar_Array.append(SUGARTYPE.FREE)

	elif int(_ORDERINFO.SugarType) > 0:
		match _OrderSugar:
			SUGARTYPE.ANY:
				if bool(_LEVELINFO.Sugar):
					var _TYPE: int = int(_ORDERINFO.SugarType)
					match _TYPE:
						1:
							_Sugar_Array.append(SUGARTYPE.SUGAR)
							_Sugar_Array.append(SUGARTYPE.NOSUGAR)
						2:
							_Sugar_Array.append(SUGARTYPE.FREE)
							_Sugar_Array.append(SUGARTYPE.NOSUGAR)
						3:
							_Sugar_Array.append(SUGARTYPE.FREE)
							_Sugar_Array.append(SUGARTYPE.SUGAR)
							_Sugar_Array.append(SUGARTYPE.NOSUGAR)
				else:
					_Sugar_Array.append(SUGARTYPE.NOSUGAR)

			SUGARTYPE.FREE:
				if bool(_LEVELINFO.Sugar):
					var _TYPE: int = int(_ORDERINFO.SugarType)
					match _TYPE:
						0:
							_Sugar_Array.append(SUGARTYPE.NOSUGAR)
						1:
							_Sugar_Array.append(SUGARTYPE.SUGAR)
						2:
							_Sugar_Array.append(SUGARTYPE.FREE)
						3:
							_Sugar_Array.append(SUGARTYPE.SUGAR)
							_Sugar_Array.append(SUGARTYPE.FREE)
				else:
					_Sugar_Array.append(SUGARTYPE.NOSUGAR)
			SUGARTYPE.SUGAR:
				if bool(_LEVELINFO.Sugar):

					var _TYPE: int = int(_ORDERINFO.SugarType)
					match _TYPE:
						1:
							_Sugar_Array.append(SUGARTYPE.SUGAR)
						2:
							_Sugar_Array.append(SUGARTYPE.FREE)
						3:
							_Sugar_Array.append(SUGARTYPE.SUGAR)
				else:
					_Sugar_Array.append(SUGARTYPE.NOSUGAR)
			SUGARTYPE.NOSUGAR:

				_Sugar_Array.append(SUGARTYPE.NOSUGAR)
	else:
		match _OrderSugar:
			SUGARTYPE.ANY:

				_Sugar_Array.append(SUGARTYPE.NOSUGAR)
			SUGARTYPE.NOSUGAR:

				_Sugar_Array.append(SUGARTYPE.NOSUGAR)

	if _Sugar_Array.size():
		if GameLogic.cur_Event == "加糖日":
			pass
		var _rand = GameLogic.return_randi() % _Sugar_Array.size()
		_Sugar = _Sugar_Array[_rand]
	else:
		_Sugar = SUGARTYPE.NOSUGAR

	if GameLogic.cur_Event == "无糖日":
		_Sugar = SUGARTYPE.NOSUGAR





	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 1:
			_Sugar = SUGARTYPE.NOSUGAR
		if GameLogic.cur_Day == 2:
			_Sugar = SUGARTYPE.SUGAR
		if GameLogic.cur_Day == 3:
			if _Extra_Array.size() == 0:
				_Extra_Array.append(GameLogic.cur_Extra[0])

	var _MakeType: int = 0
	match _ORDERINFO.MakeType:

		"2":
			var _Rand = GameLogic.return_RANDOM() % 2
			_MakeType = _Rand

		_:
			_MakeType = int(_ORDERINFO.MakeType)

	var _ORDERDIC = {
		"NPC": _NPC,
		"Name": _OrderName,
		"Pop": _Pop,
		"Celcius": _Celcius,
		"Sugar": _Sugar,
		"ExtraArray": _Extra_Array,
		"MakeType": _MakeType,
		"BeerPop": _BeerPop,
		}
	var _NPCPATH = _NPC.get_path()
	var _ORDERNAME = _NPC.name
	if _NPC.WaitTime == 0:
		_NPC._WaitingTime_Set()
	var _WAITTIME = _NPC.WaitTime
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_order_puppet", [_ORDERDIC, _PLUS, _TYPELOGIC, _WAITTIME])

	call_order_logic(_NPC, _ORDERDIC, _PLUS, _TYPELOGIC, _WAITTIME)


	var _PopularNum: float = 0
	if GameLogic.cur_Rewards.has("工作名牌"):
		GameLogic.call_Info(1, "工作名牌")
		_PopularNum += 5 * GameLogic.return_Multiplayer()

	if GameLogic.cur_Rewards.has("工作名牌+"):
		GameLogic.call_Info(1, "工作名牌+")
		_PopularNum += 15 * GameLogic.return_Multiplayer()
	if _PopularNum > 0:
		var _r = GameLogic.return_Popular(_PopularNum, GameLogic.HomeMoneyKey)

func call_order_puppet(_ORDERDIC: Dictionary, _PLUS, _TYPE, _WAITTIME):

	OrderCount += 1 + _PLUS
	cur_OrderList[OrderCount] = _ORDERDIC

	cur_OrderArray.append(OrderCount)

	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	var _ORDERTSCN = load("res://TscnAndGd/UI/InGame/OrderUI.tscn")
	var newOrder = _ORDERTSCN.instance()
	newOrder.name = str(OrderCount)
	OrderNode.add_child(newOrder)
	newOrder.call_init(OrderCount, cur_OrderList[OrderCount], _WAITTIME)
	emit_signal("NewOrder", 0)
func call_order_logic(_NPC, _ORDERDIC: Dictionary, _PLUS, _TYPE, _WAITTIME):

	OrderCount += 1 + _PLUS
	cur_OrderList[OrderCount] = _ORDERDIC

	cur_OrderArray.append(OrderCount)
	_NPC.call_order(OrderCount, _TYPE)
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	var _ORDERTSCN = load("res://TscnAndGd/UI/InGame/OrderUI.tscn")
	var newOrder = _ORDERTSCN.instance()
	newOrder.name = str(OrderCount)
	OrderNode.add_child(newOrder)

	newOrder.call_init(OrderCount, cur_OrderList[OrderCount], _WAITTIME)
	emit_signal("NewOrder", 0)
func return_readycheck(_OrderID):
	if OrderNode.has_node(str(_OrderID)):
		var _PickOrder = OrderNode.get_node(str(_OrderID))
		return _PickOrder._Ready

func return_Order_Check():
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	var _List = OrderNode.get_children()

	if _List:
		for _Node in _List:
			if _Node:
				printerr("OrderCheck ani:", _Node.OrderUIAni.assigned_animation)
				if _Node.OrderUIAni.assigned_animation in ["show", "shake", "normal"]:
					printerr("return true")
					return true
	return false
func return_Order_AddInNeed():
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	var _List = OrderNode.get_children()
	if _List:
		for _Node in _List:
			if _Node:

				if _Node.OrderAni.assigned_animation in ["check"] and _Node.OrderUIAni.assigned_animation in ["show", "shake", "normal"]:

					if _Node._ExtraArray.size() > 0:
						return true
				elif SteamLogic.IsMultiplay and _Node.OrderUIAni.assigned_animation in ["show", "shake", "normal"]:
					if _Node._ExtraArray.size() > 0:
						return true
	return false
func return_Order_SugarNeed():
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	var _List = OrderNode.get_children()
	if _List:
		for _Node in _List:
			if _Node:
				printerr("_Node._Sugar1:", _Node.OrderUIAni.assigned_animation)
				if _Node.OrderAni.assigned_animation in ["check"] and _Node.OrderUIAni.assigned_animation in ["show", "shake", "normal"]:
					printerr("_Node._Sugar:", _Node._Sugar)
					if _Node._Sugar == 2:
						return true
				elif SteamLogic.IsMultiplay and _Node.OrderUIAni.assigned_animation in ["show", "shake", "normal"]:
					if _Node._Sugar == 2:
						return true
	return false
func call_pickup_cup_logic(_ID, _PLAYERID):

	if not cur_CupArray.has(_ID):
		cur_CupArray.insert(cur_CupArray.size(), _ID)
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	if OrderNode.has_node(str(_ID)):

		var OrderUINode = OrderNode.get_node(str(_ID))
		if SteamLogic.IsMultiplay and _PLAYERID == SteamLogic.STEAM_ID:
			OrderUINode.call_Formula_show()
		elif not SteamLogic.IsMultiplay:
			OrderUINode.call_Formula_show()
func call_del_cup_logic(_ID):
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox

	if OrderNode.has_node(str(_ID)):

		var OrderUINode = OrderNode.get_node(str(_ID))
		OrderUINode.call_Formula_hide()
		emit_signal("OrderUpdate", _ID)

func call_PickUp_Order(_OrderID: int):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PickUp_Order", [_OrderID])
	if not is_instance_valid(OrderNode):
		OrderNode = GameLogic.GameUI.OrderBox
	if OrderNode.has_node(str(_OrderID)):
		var _PickOrder = OrderNode.get_node(str(_OrderID))
		_PickOrder.call_PickUp_ready()
func call_PickUp_NotOrder(_OrderID: int):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PickUp_NotOrder", [_OrderID])
	if OrderNode.has_node(str(_OrderID)):
		var _PickOrder = OrderNode.get_node(str(_OrderID))
		_PickOrder.call_PickUp_NotReady()
func call_PickUp(_OrderID: int):

	if OrderNode.has_node(str(_OrderID)):
		var _PickOrder = OrderNode.get_node(str(_OrderID))
		_PickOrder.call_PickUp()
	emit_signal("OrderUpdate", _OrderID)
func call_CleanOrder():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_CleanOrder")
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	for _NODE in OrderNode.get_children():
		_NODE.call_queue_free()
func return_CanClosed():
	if OrderNode == null:
		OrderNode = GameLogic.GameUI.OrderBox
	var _NUM: int = OrderNode.get_child_count()

	if _NUM == 0:
		return true
	else:
		return false
func return_HasOrder(_OrderID: int):
	if OrderNode.has_node(str(_OrderID)):
		return true
	else:
		return false
func return_PickOrder_Check(_OrderID: int):

	if OrderNode.has_node(str(_OrderID)):
		var _PickOrder = OrderNode.get_node(str(_OrderID))

		if _PickOrder._RefundTimer.is_paused():
			return false
		else:
			return true




func call_OutLine(_ID, _Type: int):

	if _ID == 0:
		return
	if OrderNode.has_node(str(_ID)):
		var _OrderUI = OrderNode.get_node(str(_ID))
		_OrderUI.call_Order_OutLine(_Type)

func call_ReSetTime(_ID, _RETIME):
	printerr("call_ReSetTime", _ID, " ", _RETIME)
	if OrderNode.has_node(str(_ID)):
		var _OrderUI = OrderNode.get_node(str(_ID))
		_OrderUI.call_RefundTime_Set(_RETIME)

func call_Refund(_refundID):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Refund", [_refundID])
	if OrderNode.has_node(str(_refundID)):
		var _removeOrder = OrderNode.get_node(str(_refundID))
		_removeOrder.call_refund()

	if cur_OrderList.has(int(_refundID)):
		cur_OrderList.erase(int(_refundID))
	if cur_OrderArray.has(int(_refundID)):
		cur_OrderArray.erase(int(_refundID))
	emit_signal("OrderUpdate", _refundID)

func _return_OrderCup_bool(_CupType, _NPC):

	match _CupType:
		CUPTYPE.S:

			if _NPC.Order_S:
				return true
		CUPTYPE.M:

			if _NPC.Order_M:
				return true
		CUPTYPE.L:

			if _NPC.Order_L:
				return true
func _return_OrderCelcius_bool(_CelciusList: Dictionary, _NPC):

	if _CelciusList.CanHot:
		if _NPC.Order_HOT:
			return true
	if _CelciusList.CanCold:

		if _NPC.Order_COLD:
			return true
	if _CelciusList.CanNormal:
		if _NPC.Order_NORMAL:
			return true
func _return_OrderType_bool(_TypeArray: Array, _NPC):

	return true
func _return_OrderSugar(_SugarType, _NPC):


	var _OrderSugar = _NPC.Order_Sugar
	if _SugarType > 0:
		match _OrderSugar:
			SUGARTYPE.ANY:
				return true
			SUGARTYPE.SUGAR:
				return true
			SUGARTYPE.FREE:
				return true
	else:
		match _OrderSugar:
			SUGARTYPE.ANY:
				return true
			SUGARTYPE.NOSUGAR:
				return true

	return true
func _return_Order_Normal(_NPC, _type):

	var _OrderList: Array
	var _PopularCount = 0

	for i in cur_menu.size():



		var _Celcius_list: Dictionary


		var _LEVELINFO = GameLogic.cur_levelInfo

		if GameLogic.Config.FormulaConfig[cur_menu[i]].Finish in ["冰", "沙冰"]:
			_Celcius_list["CanCold"] = true
		elif _LEVELINFO.Machine.has("制冰机"):
			_Celcius_list["CanCold"] = bool(GameLogic.Config.FormulaConfig[cur_menu[i]].CanCold)
		else:
			_Celcius_list["CanCold"] = false

		if GameLogic.Config.FormulaConfig[cur_menu[i]].Finish == "热":
			_Celcius_list["CanHot"] = true
		elif _LEVELINFO.Machine.has("蒸汽机"):
			_Celcius_list["CanHot"] = bool(GameLogic.Config.FormulaConfig[cur_menu[i]].CanNormal)
		else:
			_Celcius_list["CanHot"] = false

		if GameLogic.Config.FormulaConfig[cur_menu[i]].Finish == "常温":
			_Celcius_list["CanNormal"] = true
		elif _LEVELINFO.Machine.has("蒸汽机"):
			if _LEVELINFO.Machine.has("制冰机"):
				_Celcius_list["CanNormal"] = bool(GameLogic.Config.FormulaConfig[cur_menu[i]].CanNormal)
		else:
			_Celcius_list["CanNormal"] = false



		var _TypeCelcius = _return_OrderCelcius_bool(_Celcius_list, _NPC)

		var _Cup = _return_CupType(GameLogic.Config.FormulaConfig[cur_menu[i]].CupType)
		var _TypeCup = _return_OrderCup_bool(_Cup, _NPC)

		var _SugarType: int = int(GameLogic.Config.FormulaConfig[cur_menu[i]].SugarType)
		var _Sugar: bool = _return_OrderSugar(_SugarType, _NPC)


		if _TypeCelcius and _TypeCup and _Sugar:

			_OrderList.append(cur_menu[i])


		else:


			if not _TypeCelcius:
				_NPC.NoOrder_Celcius = true
			elif not _TypeCup:
				_NPC.NoOrder_Cup = true
			elif not _Sugar:
				_NPC.NoOrder_Suger = true





	if not _OrderList.size():
		for _i in cur_menu.size():
			_OrderList.append(cur_menu[_i])

	match _type:
		- 2:
			return
		- 1:

			var _rand = GameLogic.return_randi() % _OrderList.size()

			return _OrderList[_rand]
		0:

			var _rand = GameLogic.return_randi() % _OrderList.size()

			return _OrderList[_rand]

		1:
			var _cheapest
			var _OrderName
			for i in _OrderList.size():
				var _TagList = GameLogic.Config.FormulaConfig[_OrderList[i]].Tag
				var _CheckBool: bool = true
				for _Tag in _TagList:
					if _Tag in NoSellTagList:
						_CheckBool = false
				if _CheckBool:
					var _Price = int(GameLogic.Config.FormulaConfig[_OrderList[i]]["Price"])
					if _cheapest == null:
						_cheapest = _Price
						_OrderName = _OrderList[i]
					if _cheapest > _Price:
						_cheapest = _Price
						_OrderName = _OrderList[i]
			return _OrderName

func _return_Order_Popular():
	var _OrderName
	var _Popular_Most: int = 0
	for i in cur_menu.size():
		var _TagList = GameLogic.Config.FormulaConfig[cur_menu[i]].Tag
		var _CheckBool: bool = true
		for _Tag in _TagList:
			if _Tag in NoSellTagList:
				_CheckBool = false
		if _CheckBool:
			var _Popular = int(GameLogic.Formula.return_popular(cur_menu[i]))
			if _Popular > _Popular_Most:
				_Popular_Most = _Popular
				_OrderName = cur_menu[i]
			elif _Popular == _Popular_Most:
				var _rand = GameLogic.return_randi() % 2
				if _rand == 1:
					_Popular_Most = _Popular
					_OrderName = cur_menu[i]

	return _OrderName
func _return_Order_Expensive():
	var _OrderName
	var _Expensive_Price: int = 0
	for i in cur_menu.size():
		var _TagList = GameLogic.Config.FormulaConfig[cur_menu[i]].Tag
		var _CheckBool: bool = true
		for _Tag in _TagList:
			if _Tag in NoSellTagList:
				_CheckBool = false
		if _CheckBool:
			var _Price = int(GameLogic.Config.FormulaConfig[cur_menu[i]]["Price"])
			if _Price > _Expensive_Price:
				_Expensive_Price = _Price
				_OrderName = cur_menu[i]
			elif _Price == _Expensive_Price:
				var _rand = GameLogic.return_randi() % 2
				if _rand == 1:
					_Expensive_Price = _Price
					_OrderName = cur_menu[i]

	return _OrderName
func _return_Order_Cheapest():
	var _OrderName
	var _Cheapest_Price: int

	for i in cur_menu.size():
		var _TagList = GameLogic.Config.FormulaConfig[cur_menu[i]].Tag
		var _CheckBool: bool = true
		for _Tag in _TagList:
			if _Tag in NoSellTagList:
				_CheckBool = false
		if _CheckBool:
			var _Price = int(GameLogic.Config.FormulaConfig[cur_menu[i]]["Price"])

			if _OrderName == null:
				_Cheapest_Price = _Price
				_OrderName = cur_menu[i]
			elif _Price < _Cheapest_Price:
				_Cheapest_Price = _Price
				_OrderName = cur_menu[i]
			elif _Price == _Cheapest_Price:
				var _rand = GameLogic.return_randi() % 2
				if _rand == 1:
					_Cheapest_Price = _Price
					_OrderName = cur_menu[i]
	return _OrderName

func _return_Sugar_bool(_Sugar, _CurMenuInfo):
	if not _Sugar:
		return true
	elif int(_CurMenuInfo["SugarType"]) > 0:
		return true
	else:
		return false

func _return_Celcius_bool(_Celcius, _CurMenuInfo):
	match _Celcius:
		"Hot":
			if _CurMenuInfo["CanHot"]:
				return true
		"Cold":
			if _CurMenuInfo["CanCold"]:
				return true
		"Normal":
			if _CurMenuInfo["CanNormal"]:
				return true
		_:
			return true

func return_Picker_Order_PickUp(_key):

	if cur_OrderList.has(_key):
		var NPC = cur_OrderList[_key]["NPC"]

		return NPC
	return null

func return_CanPickCheck_Bool(_CupOBJ, _SpeicalArray: Array = []):

	var _orderid = _CupOBJ.cur_ID


	var _LiquidMax: int = 0
	match _CupOBJ.TYPE:
		"DrinkCup_S", "SodaCan_S", "BeerCup_S":
			_LiquidMax = 2
		"DrinkCup_M", "SuperCup_M", "SodaCan_M", "BeerCup_M":
			_LiquidMax = 4
		"DrinkCup_L", "SodaCan_L", "BeerCup_L":
			_LiquidMax = 6




	var _check: Dictionary = {
		"WrongType": 1,
		"Stress": 0,
		"Total": 0,
		"Celcius": 0,
		"Sugar": 0,
		"Extra": 0,
		"ExtraMax": 0,
		"IceBreak": 0,

		"Mixd": 0,

		"SugarIn": true,
		"Condiment": "",
		"Condiment_1": 0,
		"Hang": 0,
		"Top": 0,
		"IsPassDay": _CupOBJ.IsPassDay,
		"Sequence": 0,
		"NeedPop": false,
		"Pop": 0,



	}
	if _CupOBJ.Liquid_Count < _LiquidMax or _CupOBJ.Liquid_Count == 0:

		_check["WrongType"] = 0
		return _check


	var _CUPTYPE = _CupOBJ.get("FuncType")
	var _TypeStr = _CupOBJ.get("TypeStr")
	if GameLogic.Order.cur_OrderList.has(_orderid):
		var _orderInfo = GameLogic.Order.cur_OrderList[_orderid]
		var _MAKETYPE = _orderInfo.get("MakeType")
		match _CUPTYPE:
			"EggRollCup":
				match _MAKETYPE:
					5:
						if not _TypeStr in ["EggRoll_white"]:
							_check.Total += 1
							_check["WrongType"] = - 3
							_check["Stress"] += 3
					6:
						if not _TypeStr in ["EggRoll_black"]:
							_check.Total += 1
							_check["WrongType"] = - 3
							_check["Stress"] += 3
			"DrinkCup":
				if _TypeStr in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
					if int(_MAKETYPE) != 3:
						_check.Total += 1
						_check["WrongType"] = - 3
						_check["Stress"] += 3

				elif int(_MAKETYPE) != 0:
					_check.Total += 1
					_check["WrongType"] = - 3
					_check["Stress"] += 3

			"SodaCan":
				if int(_MAKETYPE) != 1:
					_check.Total += 1
					_check["WrongType"] = - 3
					_check["Stress"] += 3

		var _name = _orderInfo["Name"]
		var _INFO = GameLogic.Config.FormulaConfig[_name]
		if _TypeStr in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
			var _BEERCUPCHECK: bool = true
			var _TYPE = _INFO["CupType"]
			match _TypeStr:
				"BeerCup_S":
					if _TYPE != "S":
						_BEERCUPCHECK = false
				"BeerCup_M":
					if _TYPE != "M":
						_BEERCUPCHECK = false
				"BeerCup_L":
					if _TYPE != "L":
						_BEERCUPCHECK = false
			if not _BEERCUPCHECK:
				_check.Total += 1
				_check["WrongType"] = - 3
				_check["Stress"] += 3
				return _check



		var _Celcius = _orderInfo["Celcius"]
		var _Sugar = _orderInfo["Sugar"]
		var _CupCelcius = _CupOBJ.Celcius
		var _CupSugar: int
		var _SequenceBool: bool = bool(_INFO.SequenceBool)

		match _CupOBJ.SugarType:
			1:
				_CupSugar = GameLogic.Order.SUGARTYPE.SUGAR
				_check.SugarIn = true
			2:
				_CupSugar = GameLogic.Order.SUGARTYPE.FREE
				_check.SugarIn = true
			0:
				_CupSugar = GameLogic.Order.SUGARTYPE.NOSUGAR
				_check.SugarIn = false

		var _NeedMix = int(_INFO.Mixd)
		match _NeedMix:
			0:
				_check.Total += 1
				_check.Mixd = 1

				pass
			1:
				_check.Total += 1

				if _CupOBJ.Is_Mix:
					_check.Mixd = 1
			2:
				_check.Total += 1
				var _MIX = _CupOBJ.Is_Mix
				if not _CupOBJ.Is_Mix:
					_check.Mixd = 1
			3:
				_check.Total += 1
				var _x = _CupOBJ.MixInt
				var _y = _CupOBJ.Liquid_Max
				if _CupOBJ.MixInt == _CupOBJ.Liquid_Max - 1:
					_check.Mixd = 1
			4:
				_check.Total += 1
				var _x = _CupOBJ.MixInt
				var _y = _CupOBJ.Liquid_Max
				if _CupOBJ.MixInt == _CupOBJ.Liquid_Max - 2:
					_check.Mixd = 1
				pass

		var _ExtraList: Array
		if _CupOBJ.Extra_1 != "":
			_ExtraList.append(_CupOBJ.Extra_1)
		if _CupOBJ.Extra_2 != "":
			_ExtraList.append(_CupOBJ.Extra_2)
		if _CupOBJ.Extra_3 != "":
			_ExtraList.append(_CupOBJ.Extra_3)
		if _CupOBJ.get("Extra_4") != "":
			_ExtraList.append(_CupOBJ.Extra_4)
		if _CupOBJ.get("Extra_5") != "":
			_ExtraList.append(_CupOBJ.Extra_5)

		if _orderInfo.ExtraArray.size() != 0:
			_check.ExtraMax = _orderInfo.ExtraArray.size()
			_check.Total += _check.ExtraMax


			for _EXTRA in _orderInfo.ExtraArray:
				if _ExtraList.has(_EXTRA):
					_check.Extra += 1
					_ExtraList.erase(_EXTRA)




		_check.Total += 1

		if _Celcius == _CupCelcius:
			_check.Celcius = 1
		elif GameLogic.cur_Event == "无冰日":
			if _Celcius == "Cold":
				_check.Celcius = 1
		if GameLogic.cur_Rewards.has("加冰加价+") or GameLogic.cur_Rewards.has("透心凉+"):
			if _CupCelcius == "Cold":
				_check.Celcius = 1

		_check.Total += 1

		if _Sugar == _CupSugar:
			_check.Sugar = 1
		else:
			_check.Sugar = 0
		if GameLogic.cur_Rewards.has("加糖加价+") or GameLogic.cur_Rewards.has("七分糖+"):
			if _check.SugarIn:
				_check.Sugar = 1


		var _EXTRACHECK: bool = false
		if GameLogic.cur_Rewards.has("若有若无"):
			if _check.Extra == _check.ExtraMax - 1:
				_check.Extra += 1
				_EXTRACHECK = true

		elif GameLogic.cur_Rewards.has("若有若无+"):
			if _check.Extra < _check.ExtraMax:
				_check.Extra = _check.ExtraMax
				_EXTRACHECK = true

		if _INFO.Condiment_1:

			_check.Total += 1
			if _CupOBJ.Condiment_1 == _INFO.Condiment_1:
				_check.Condiment_1 = 1

		if _CupOBJ.Condiment_1 != "":
			_check.Condiment = _CupOBJ.Condiment_1

		if _INFO.Hang != "":
			if _CupOBJ.Hang == "":
				_check.Total += 1
				_check["WrongType"] = - 1
				_check["Stress"] += 1

			else:
				_check.Total += 1
				if _CupOBJ.Hang == _INFO.Hang:
					_check.Hang = 1
		if _INFO.Top != "":
			if _CupOBJ.Top == "":
				_check.Total += 1
				_check["WrongType"] = - 2
				_check["Stress"] += 1

			else:
				_check.Total += 1
				if _CupOBJ.Top == _INFO.Top:
					_check.Top = 1
		var _PopMaxNum: int = int(_orderInfo.Pop)
		if _PopMaxNum > 0:
			_check.NeedPop = true
			if "Pop" in _SpeicalArray:
				_check.Total += 1
				if _CupOBJ.Pop == _PopMaxNum:
					_check.Pop = 1
				elif _CupOBJ.Pop == 0:
					_check.Pop = - 1
			else:
				_check.Total += 1
				if _CupOBJ.Pop >= _PopMaxNum:
					_check.Pop = 1
				elif _CupOBJ.Pop == 0:
					_check.Pop = - 1
				pass

		var _FormulaNum = int(_INFO.FormulaNum)

		var _Cup_WaterType_Array = _CupOBJ.LIQUID_DIR.keys()

		var _ForCheck: bool = true
		if _SequenceBool:

			var _KEY: Array = _CupOBJ.LIQUID_ARRAY
			var _CHECKNUM: int = 1
			var _CHECKBOOL: bool = true
			var _CHECKLIST: Array
			var _LIQUIDLIST: Array
			var _POP = int(_orderInfo["BeerPop"])
			for _i in int(_INFO.FormulaNum):
				var _CHECKLABEL = "For_" + str(_i + 1)
				var _CHECKNUMLABEL: String = "For_" + str(_i + 1) + "_Num"
				var _LIQUIDNAME: String = _INFO[_CHECKLABEL]
				var _LIQUIDNUM: int = int(_INFO[_CHECKNUMLABEL])
				if _LIQUIDNAME != "":
					for _j in _LIQUIDNUM:
						_CHECKLIST.append(_LIQUIDNAME)
						_LIQUIDLIST.append(_LIQUIDNAME)
			for _NAME in _KEY:
				var _CHECKLABEL = "For_" + str(_CHECKNUM)

				var _LIQUIDCHECKNAME = _LIQUIDLIST[_CHECKNUM - 1]
				if _LIQUIDCHECKNAME in ["拉格", "艾尔", "皮尔森", "IPA", "小麦", "世涛"]:
					if _NAME == "啤酒泡":
						_NAME = _LIQUIDCHECKNAME
				if _LIQUIDCHECKNAME != _NAME:
					_CHECKBOOL = false
				if _CHECKLIST.has(_NAME):
					_CHECKLIST.erase(_NAME)
				else:
					_ForCheck = false
					_CHECKBOOL = false
					break

				_CHECKNUM += 1
			_check.Total += 1
			if _CHECKBOOL:
				_check.Sequence = 1
			if _CupOBJ.LIQUID_DIR.has("啤酒泡"):
				var _POPNUM = _CupOBJ.LIQUID_DIR["啤酒泡"]
				if _POPNUM != _POP:
					_check["Total"] += 1

		else:
			if int(_INFO.MakeType) in [5, 6]:
				var _For1: String
				var _For2: String
				var _For3: String
				var _For4: String
				var _For5: String
				var _For6: String
				for i in _FormulaNum:
					var _For_Name = "For_" + str(i + 1)
					var _Formula = _INFO[_For_Name]
					match i:
						0:
							_For1 = _Formula
						1:
							_For2 = _Formula
						2:
							_For3 = _Formula
						3:
							_For4 = _Formula
						4:
							_For5 = _Formula
						5:
							_For6 = _Formula

				var _Ball1Check: bool
				var _Ball2Check: bool
				var _Ball3Check: bool
				var _Ball12C: bool
				var _Ball13C: bool
				var _Ball23C: bool
				var _LIQUIDARRAY = _CupOBJ.LIQUID_ARRAY
				if _LIQUIDARRAY.size() >= 2:
					var _L1 = _LIQUIDARRAY[0]
					var _L2 = _LIQUIDARRAY[1]
					if _L1 == _For1 and _L2 == _For2:
						_Ball1Check = true
					elif _L1 == _For2 and _L2 == _For1:
						_Ball1Check = true


				if _LIQUIDARRAY.size() >= 4:
					var _L3 = _LIQUIDARRAY[2]
					var _L4 = _LIQUIDARRAY[3]
					if _L3 == _For3 and _L4 == _For4:
						_Ball2Check = true
					elif _L3 == _For4 and _L4 == _For3:
						_Ball2Check = true
					if not _Ball1Check and not _Ball2Check:
						var _L1 = _LIQUIDARRAY[0]
						var _L2 = _LIQUIDARRAY[1]
						if _L1 == _For3 and _L2 == _For4 and _L3 == _For1 and _L4 == _For2:
							_Ball12C = true
						elif _L1 == _For4 and _L2 == _For3 and _L3 == _For2 and _L4 == _For1:
							_Ball12C = true
				if _LIQUIDARRAY.size() >= 6:
					var _L1 = _LIQUIDARRAY[0]
					var _L2 = _LIQUIDARRAY[1]
					var _L3 = _LIQUIDARRAY[2]
					var _L4 = _LIQUIDARRAY[3]
					var _L5 = _LIQUIDARRAY[4]
					var _L6 = _LIQUIDARRAY[5]
					if _L5 == _For5 and _L6 == _For6:
						_Ball3Check = true
					elif _L5 == _For6 and _L6 == _For5:
						_Ball3Check = true
					if not _Ball1Check and not _Ball3Check and _Ball2Check:
						if _L1 == _For5 and _L2 == _For6 and _L5 == _For1 and _L6 == _For2:
							_Ball13C = true
						elif _L1 == _For6 and _L2 == _For5 and _L5 == _For2 and _L6 == _For1:
							_Ball13C = true
					elif _Ball1Check and not _Ball3Check and not _Ball2Check:
						if _L3 == _For5 and _L4 == _For6 and _L5 == _For3 and _L6 == _For4:
							_Ball23C = true
						elif _L3 == _For6 and _L4 == _For5 and _L5 == _For4 and _L6 == _For3:
							_Ball23C = true

				match _FormulaNum:
					2:
						if not _Ball1Check:
							_ForCheck = false
					4:
						if not _Ball1Check or not _Ball2Check:
							if not _Ball12C:
								_ForCheck = false
							else:
								_check.Total += 1
					6:
						if not _Ball1Check or not _Ball2Check or not _Ball3Check:
							if not _Ball1Check and not _Ball2Check:
								if not _Ball12C:
									_ForCheck = false
								else:
									_check.Total += 1
							elif not _Ball1Check and not _Ball3Check:
								if not _Ball13C:
									_ForCheck = false
								else:
									_check.Total += 1
							elif not _Ball2Check and not _Ball2Check:
								if not _Ball23C:
									_ForCheck = false
								else:
									_check.Total += 1
							else:
								_ForCheck = false

			elif int(_INFO.MakeType) in [3]:
				var _POP = _orderInfo["BeerPop"]
				for i in _FormulaNum:
					var _For_Name = "For_" + str(i + 1)
					var _For_Num = "For_" + str(i + 1) + "_Num"
					var _Formula = _INFO[_For_Name]
					var _Formula_Num = int(_INFO[_For_Num])

					var _Cup_Num: int = 0
					var _POP_Num: int = 0
					if _CupOBJ.LIQUID_DIR.has("啤酒泡"):
						_POP_Num = _CupOBJ.LIQUID_DIR["啤酒泡"]
					if _CupOBJ.LIQUID_DIR.has(_Formula):
						_Cup_Num = _CupOBJ.LIQUID_DIR[_Formula]
					if _Formula_Num - _POP != _Cup_Num:
						printerr("出杯检查错误", _For_Name, _Formula_Num, " ", _Cup_Num)

						if _Cup_Num == _Formula_Num:
							_check["Total"] += 1
						elif _Formula_Num - _POP == _Cup_Num - _POP_Num:
							_check["Total"] += 1
						elif _Formula_Num == _Cup_Num + _POP_Num:
							_check["Total"] += 1
						else:
							_ForCheck = false

					else:
						if not _CupOBJ.LIQUID_DIR.has("啤酒泡"):
							_ForCheck = false
						else:

							if _POP_Num != _POP:
								_ForCheck = false
			else:
				for i in _FormulaNum:
					var _For_Name = "For_" + str(i + 1)
					var _For_Num = "For_" + str(i + 1) + "_Num"
					var _Formula = _INFO[_For_Name]
					var _Formula_Num = int(_INFO[_For_Num])

					var _Cup_Num: int = 0
					if _CupOBJ.LIQUID_DIR.has(_Formula):
						_Cup_Num = _CupOBJ.LIQUID_DIR[_Formula]
					if _Formula_Num != _Cup_Num:
						printerr("出杯检查错误", _For_Name, _Formula, _Formula_Num, _Cup_Num, _INFO[_For_Name])
						if _Formula_Num > _Cup_Num:
							_check["Stress"] += _Formula_Num - _Cup_Num
						elif _Cup_Num > _Formula_Num:
							_check["Stress"] += _Cup_Num - _Formula_Num
						_ForCheck = false
		if _ForCheck:

			return _check
		else:

			_check.Total += 1
			_check["WrongType"] = - 4
			return _check


	else:

		_check["WrongType"] = 0
		return _check
