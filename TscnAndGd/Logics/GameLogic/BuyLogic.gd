extends Node

var buy_Dict: Dictionary
var buy_Array: Array
var Dev_List: Array

var _devices: Dictionary = {
	"WaterPort": 2,
	"TeaPort": 2,
}

var Sell_1: Array
var Sell_2: Array
var Sell_3: Array
var Sell_4: Array

signal BuyNew(_Type, _Time)

func _ready() -> void :
	call_deferred("call_Dev_init")

func call_Dev_init():
	Dev_List.clear()
	if not GameLogic.Config.DeviceConfig:
		return
	var _keys = GameLogic.Config.DeviceConfig.keys()
	for i in _keys.size():
		if GameLogic.Config.DeviceConfig[_keys[i]].CanSell:
			Dev_List.append(_keys[i])

func call_init():



	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	Sell_1.clear()
	Sell_2.clear()
	Sell_3.clear()
	Sell_4.clear()
	for i in GameLogic.cur_Menu.size():
		var _ForName = GameLogic.cur_Menu[i]
		if GameLogic.Config.FormulaConfig.has(_ForName):
			var _Data = GameLogic.Config.FormulaConfig[_ForName]

			var _ItemNum = int(_Data.FormulaNum)
			if not Sell_1.has("Sugar") or not Sell_1.has("FreeSugar"):
				var _SUGERTYPE: int = int(_Data.SugarType)
				match _SUGERTYPE:
					1:
						if not Sell_1.has("Sugar"):
							Sell_1.append("Sugar")
					2:
						if not Sell_1.has("FreeSugar"):
							Sell_1.append("FreeSugar")
					3:
						if not Sell_1.has("Sugar"):
							Sell_1.append("Sugar")
						if not Sell_1.has("FreeSugar"):
							Sell_1.append("FreeSugar")

					_:
						if GameLogic.cur_Event == "加糖日":
							if not Sell_1.has("Sugar"):
								if not Sell_1.has("FreeSugar"):
									Sell_1.append("Sugar")
			var _CHECKBOOL: bool
			if int(_Data.ShowNum) > 0:
				_CHECKBOOL = true

			if _CHECKBOOL:
				for y in int(_Data.ShowNum):
					var _For = "Bag_" + str(y + 1)
					var _Item = _Data[_For]
					match _Item:
						"bag_cheeze":
							_Item = "芝士"
						"上层巧克力":
							_Item = "挂壁巧克力"
						"icecream_milk":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "bag_whitesugar"
						"icecream_vanilla":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "bottle_vanilla"
						"icecream_coco":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "powder_coco"
						"icecream_mocha":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "powder_mocha"
						"icecream_blueberry":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "bottle_blueberry"
						"icecream_cheery":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "bottle_cheery"
						"icecream_yogurt":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "ice_yogurt"
						"icecream_pistachio":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "bottle_pistachio"
						"icecream_rum":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							if not Sell_1.has("ice_cream"):
								Sell_1.append("ice_cream")
							_Item = "bottle_wine_rum"
					if GameLogic.Config.ItemConfig.has(_Item):
						var _INFO = GameLogic.Config.ItemConfig[_Item]
						var _SellType = int(_INFO.SellType)
						var _FuncType = _INFO.FuncType
						var _FuncTypeNum = _INFO.FuncTypeNum
						match _SellType:
							1:

								if not Sell_1.has(_Item):
									Sell_1.append(_Item)
							2:
								if not Sell_2.has(_Item):
									Sell_2.append(_Item)
							3:
								match _FuncType:
									"Fruit":
										if not Sell_3.has(_FuncTypeNum):
											Sell_3.append(_FuncTypeNum)
							4:
								if not Sell_4.has(_Item):
									Sell_4.append(_Item)
			else:
				for y in _ItemNum:
					var _For = "For_" + str(y + 1)
					var _Item = _Data[_For]
					if _Item == "coffeemaker_milkfoam":
						_Item = "ice_milk"
					match _Item:
						"芝士牛奶":
							if not Sell_1.has("ice_milk"):
								Sell_1.append("ice_milk")
							_Item = "芝士"
					if GameLogic.Config.ItemConfig.has(_Item):
						var _INFO = GameLogic.Config.ItemConfig[_Item]
						var _SellType = int(_INFO.SellType)
						var _FuncType = _INFO.FuncType
						var _FuncTypeNum = _INFO.FuncTypeNum
						match _SellType:
							1:
								if not Sell_1.has(_Item):
									Sell_1.append(_Item)
							2:
								if not Sell_2.has(_Item):
									Sell_2.append(_Item)
							3:
								match _FuncType:
									"Fruit":

										if not Sell_3.has(_FuncTypeNum):
											Sell_3.append(_FuncTypeNum)
							4:
								if not Sell_4.has(_Item):
									Sell_4.append(_Item)
			var _Condiment = _Data.Condiment_1
			var _Top = _Data.Top
			var _Hang = _Data.Hang
			if GameLogic.Config.ItemConfig.has(_Hang):
				var _INFO = GameLogic.Config.ItemConfig[_Hang]
				var _SellType = int(_INFO.SellType)
				var _FuncType = _INFO.FuncType
				var _FuncTypeNum = _INFO.FuncTypeNum

				match _SellType:
					1:
						match _FuncType:
							"Hang":
								if not Sell_1.has(_FuncTypeNum):
									Sell_1.append(_FuncTypeNum)
			if GameLogic.Config.ItemConfig.has(_Top):
				var _INFO = GameLogic.Config.ItemConfig[_Top]
				var _SellType = int(_INFO.SellType)
				var _FuncType = _INFO.FuncType
				var _FuncTypeNum = _INFO.FuncTypeNum

				match _SellType:
					1:
						match _FuncType:
							"Top":
								if not Sell_1.has(_Top):
									Sell_1.append(_Top)

			if GameLogic.Config.ItemConfig.has(_Condiment):
				var _INFO = GameLogic.Config.ItemConfig[_Condiment]
				var _SellType = int(_INFO.SellType)
				var _FuncType = _INFO.FuncType
				var _FuncTypeNum = _INFO.FuncTypeNum

				match _SellType:
					1:

						if not Sell_1.has(_FuncTypeNum):
							Sell_1.append(_FuncTypeNum)
					3:
						match _FuncType:
							"Fruit":
								if not Sell_3.has(_FuncTypeNum):
									Sell_3.append(_FuncTypeNum)

			if GameLogic.cur_Rewards.has("来者不拒new") or GameLogic.cur_Rewards.has("来者不拒new+"):
				if not Sell_1.has("can_konjac"):
					Sell_1.append("can_konjac")
				if not Sell_1.has("can_coco"):
					Sell_1.append("can_coco")
				if not Sell_1.has("can_grassjelly"):
					Sell_1.append("can_grassjelly")

			if _Data.Extra_1 != "":
				var _ExtraFormulaNum: int = int(GameLogic.Config.FormulaConfig[_Data.Extra_1].FormulaNum)
				for _NUM in _ExtraFormulaNum:
					var _FORNAME = "For_" + str(_NUM + 1)
					var _NAME = GameLogic.Config.FormulaConfig[_Data.Extra_1][_FORNAME]
					if GameLogic.Config.ItemConfig.has(_NAME):
						var _INFO = GameLogic.Config.ItemConfig[_NAME]
						var _SellType = int(_INFO.SellType)
						var _FuncType = _INFO.FuncType
						var _FuncTypeNum = _INFO.FuncTypeNum
						match _SellType:
							1:
								if not Sell_1.has(_NAME):
									Sell_1.append(_NAME)
							2:
								if not Sell_2.has(_NAME):
									Sell_2.append(_NAME)
							3:
								if not Sell_3.has(_NAME):
									Sell_3.append(_NAME)
							4:
								if not Sell_4.has(_NAME):
									Sell_4.append(_NAME)
				if _Data.Extra_2 != "":
					_ExtraFormulaNum = int(GameLogic.Config.FormulaConfig[_Data.Extra_2].FormulaNum)
					for _NUM in _ExtraFormulaNum:
						var _FORNAME = "For_" + str(_NUM + 1)
						var _NAME = GameLogic.Config.FormulaConfig[_Data.Extra_2][_FORNAME]
						if GameLogic.Config.ItemConfig.has(_NAME):
							var _INFO = GameLogic.Config.ItemConfig[_NAME]
							var _SellType = int(_INFO.SellType)
							var _FuncType = _INFO.FuncType
							var _FuncTypeNum = _INFO.FuncTypeNum
							match _SellType:
								1:
									if not Sell_1.has(_NAME):
										Sell_1.append(_NAME)
								2:
									if not Sell_2.has(_NAME):
										Sell_2.append(_NAME)
								3:
									if not Sell_3.has(_NAME):
										Sell_3.append(_NAME)
								4:
									if not Sell_4.has(_NAME):
										Sell_4.append(_NAME)
					if _Data.Extra_3 != "":
						_ExtraFormulaNum = int(GameLogic.Config.FormulaConfig[_Data.Extra_3].FormulaNum)
						for _NUM in _ExtraFormulaNum:
							var _FORNAME = "For_" + str(_NUM + 1)
							var _NAME = GameLogic.Config.FormulaConfig[_Data.Extra_3][_FORNAME]
							if GameLogic.Config.ItemConfig.has(_NAME):
								var _INFO = GameLogic.Config.ItemConfig[_NAME]
								var _SellType = int(_INFO.SellType)
								var _FuncType = _INFO.FuncType
								var _FuncTypeNum = _INFO.FuncTypeNum
								match _SellType:
									1:
										if not Sell_1.has(_NAME):
											Sell_1.append(_NAME)
									2:
										if not Sell_2.has(_NAME):
											Sell_2.append(_NAME)
									3:
										if not Sell_3.has(_NAME):
											Sell_3.append(_NAME)
									4:
										if not Sell_4.has(_NAME):
											Sell_4.append(_NAME)

			var _CupType = _Data.CupType
			var _CanSize: String
			match _Data.MakeType:
				"1", "2":
					match _CupType:
						"S":
							_CanSize = "SodaCan_S"
						"M":
							_CanSize = "SodaCan_M"
						"L":
							_CanSize = "SodaCan_L"
					if not Sell_2.has(_CanSize):
						Sell_2.append(_CanSize)
				"3":
					pass
				"4":
					if not Sell_2.has("SuperCup_M"):
						Sell_2.append("SuperCup_M")
				"5":
					_CanSize = "bag_eggroll_white"
					if not Sell_1.has(_CanSize):
						Sell_1.append(_CanSize)
				"6":
					_CanSize = "bag_eggroll_black"
					if not Sell_1.has(_CanSize):
						Sell_1.append(_CanSize)
			var _Cup_bool: bool = true
			if _Data.MakeType in ["0", "2"]:
				_Cup_bool = true
			else:
				_Cup_bool = false
			var _Size: String

			match _CupType:
				"S":
					_Size = "DrinkCup_S"
				"M":
					_Size = "DrinkCup_M"
				"L":
					_Size = "DrinkCup_L"
				_:
					_Cup_bool = false
			if not Sell_2.has(_Size) and _Cup_bool:
				Sell_2.append(_Size)






	var _Name = "WaterPort"
	if GameLogic.cur_Item_List.has(_Name):
		if GameLogic.cur_Item_List[_Name] > 0:
			if not Sell_2.has(_Name):
				Sell_2.append(_Name)
	_Name = "TeaPort"
	if GameLogic.cur_Item_List.has(_Name):
		if GameLogic.cur_Item_List[_Name] > 0:
			if not Sell_2.has(_Name):
				Sell_2.append(_Name)
	if GameLogic.cur_levelInfo.has("Machine"):
		if GameLogic.cur_levelInfo.Machine.has("量杯"):
			if not Sell_2.has("WaterPort"):
				Sell_2.append("WaterPort")
		if GameLogic.cur_levelInfo.Machine.has("茶壶"):
			if not Sell_2.has("TeaPort"):
				Sell_2.append("TeaPort")
		if GameLogic.cur_levelInfo.Machine.has("制冰机"):
			if GameLogic.SPECIALLEVEL_Int:

				if not Sell_4.has("ICE"):
					Sell_4.append("ICE")
		if GameLogic.cur_levelInfo.GamePlay.has("冰块配送"):
			if not Sell_4.has("ICE"):
				Sell_4.append("ICE")
		if GameLogic.cur_levelInfo.Machine.has("气瓶"):
			if not Sell_4.has("GAS"):
				Sell_4.append("GAS")
		if GameLogic.cur_levelInfo.Type.has("WINE"):
			if not Sell_4.has("BEER"):
				Sell_4.append("BEER")
	if GameLogic.cur_Rewards.has("七分糖+"):
		if not Sell_1.has("Sugar") and not Sell_1.has("FreeSugar"):
			Sell_1.append("Sugar")
	if Sell_1.has("bag_eggroll_white") or Sell_1.has("bag_eggroll_black"):
		if Sell_1.has("Sugar"):
			Sell_1.erase("Sugar")
		if Sell_1.has("FreeSugar"):
			Sell_1.erase("FreeSugar")
		if not Sell_1.has("Choco"):
			Sell_1.append("Choco")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_puppet_SYNC", [GameLogic.cur_Extra, GameLogic.cur_Menu, GameLogic.Buy.Sell_1, GameLogic.Buy.Sell_2, GameLogic.Buy.Sell_3, GameLogic.Buy.Sell_4])



func _puppet_SYNC(_EXTRA, _MENU, _SELL1, _SELL2, _SELL3, _SELL4):
	GameLogic.cur_Extra = _EXTRA
	GameLogic.cur_Menu = _MENU
	GameLogic.Buy.Sell_1 = _SELL1
	GameLogic.Buy.Sell_2 = _SELL2
	GameLogic.Buy.Sell_3 = _SELL3
	GameLogic.Buy.Sell_4 = _SELL4
func call_new_buy_puppet(_array, _type):
	var _time
	var _startTime = GameLogic.GameUI.CurTime
	var _endTime
	match _type:
		_:
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				_endTime = GameLogic.GameUI.CurTime
			else:

				if GameLogic.cur_Rewards.has("高速配送"):
					_endTime = GameLogic.GameUI.CurTime + 0.2
				elif GameLogic.cur_Rewards.has("高速配送+"):
					_endTime = GameLogic.GameUI.CurTime
				else:
					_endTime = GameLogic.GameUI.CurTime + 0.5

	_array.insert(0, _endTime)
	buy_Array.append(_array)
func call_new_buy(_array, _type):

	var _time
	var _startTime = GameLogic.GameUI.CurTime
	var _endTime
	match _type:

		_:
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				_endTime = GameLogic.GameUI.CurTime
			else:
				var _TimeMult: float = 0.5
				if GameLogic.Save.gameData.HomeDevList.has("购物车") and not GameLogic.SPECIALLEVEL_Int:
					_TimeMult -= 0.1

				if GameLogic.cur_Rewards.has("高速配送"):
					_TimeMult -= 0.2

				elif GameLogic.cur_Rewards.has("高速配送+"):
					_TimeMult = 0

				_endTime = GameLogic.GameUI.CurTime + _TimeMult
	if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 1:
			_endTime = GameLogic.GameUI.CurTime - 0.1
	_array.insert(0, _endTime)
	buy_Array.append(_array)
	var _xs = GameLogic.GameUI._Timer.wait_time
	var _xx = GameLogic.GameUI.CurTime
	var _ys = float(_array[0] - GameLogic.GameUI.CurTime)
	var _SendTime = float((_array[0] - GameLogic.GameUI.CurTime) * GameLogic.GameUI._Timer.wait_time * 50)
	if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 1:
			_SendTime = 2
	var _DIC = _array[1]
	var _KEYS = _DIC.keys()
	var _ITEMTYPE = _KEYS[0]
	emit_signal("BuyNew", _ITEMTYPE, _SendTime)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_new_buy", [_ITEMTYPE, _SendTime])

func call_puppet_new_buy(_ITEMTYPE, _SendTime):
	emit_signal("BuyNew", _ITEMTYPE, _SendTime)
func call_check(_time):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if buy_Array:
		for i in buy_Array.size():

			var _DivTime = buy_Array[i].front()

			if _time >= _DivTime:

				_courier_Logic(buy_Array.pop_at(i))
				GameLogic.call_Delivery()
				return

func _courier_Logic(_Obj_Array):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _item_Dir = _Obj_Array.back()
	var _item_Name_Array = _item_Dir.keys()
	var _devpoint = GameLogic.NPC.return_Courier_CreateOrLeave_Point()
	for i in _item_Name_Array.size():
		var _itemName = _item_Name_Array[i]
		var _orderNum = _item_Dir[_itemName]
		while _orderNum > 0:
			_orderNum -= 1
			if _itemName in ["ICE", "GAS"
			, "拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛", "BEER"]:
				GameLogic.NPC.call_goblin(_itemName, _devpoint)
			else:
				GameLogic.NPC.call_courier(_itemName, _devpoint)
func return_create_box():

	var _TSCN = load("res://TscnAndGd/Objects/Items/Box_M_Paper.tscn")
	var _BoxObj = _TSCN.instance()
	return _BoxObj
func return_create_woodbox():
	var _TSCN = load("res://TscnAndGd/Objects/Items/WoodBox.tscn")
	var _BoxObj = _TSCN.instance()
	return _BoxObj

func call_puppet_Box_Create(_ItemName, _pos, _Name, _CurNum, _MaxNum, _CurItemNameDic):

	var _Num = GameLogic.Config.ItemConfig[_ItemName]["BuyNum"]
	var _ItemData: Dictionary = {
		"NAME": _Name,
		"TSCN": "Box_M_Paper",
		"IsOpen": false,
		"pos": _pos,
		"HasItem": true,
		"ItemName": _ItemName,
		"ItemNum": _Num,
		}
	var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemData.TSCN)
	var _Item = _TSCN.instance()
	_Item.name = _Name
	_Item.position = _ItemData.pos
	if get_tree().get_root().has_node("Level"):


		get_tree().get_root().get_node("Level").Ysort_Items.add_child(_Item)
		_Item.call_load(_ItemData)
		_Item.call_puppet_create(_ItemName, _CurNum, _CurItemNameDic)
		_Item.call_deferred("call_new")
