extends Node2D

onready var Ani = get_node("Ani")
onready var GuideAni = get_node("GuideAni")
var P1_bool: bool
var P2_bool: bool
onready var ButShow = get_node("Button/X")
onready var RewardShow = get_node("Button/X/Texture/1")

var MenuUI = null
var RewardID: String setget _Reward_Init
func _ready() -> void :
	if GameLogic.cur_Choose:
		GameLogic.cur_Choose = false
	var _check = GameLogic.connect("CallFormula", self, "call_init")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		var _HoldCheck = ButShow.connect("HoldFinish", self, "_Buy_Puppet_Logic")
	else:
		var _HoldCheck = ButShow.connect("HoldFinish", self, "_Buy_Logic")
	var _TimeCheck = GameLogic.connect("OpenStore", self, "_Hide")
	var _ChooseCheck = GameLogic.connect("ChooseFinish", self, "_StartCheck")
	call_deferred("call_init")
func _StartCheck():
	if GameLogic.cur_BuyNum <= 0:
		_Hide()
	else:
		GameLogic.call_SYNC()
func _Hide():
	if Ani.assigned_animation != "Buy":
		Ani.play("hide")
func _del():
	self.queue_free()
func call_puppet_logic(_BUYNUM):

	GameLogic.cur_BuyNum = _BUYNUM
	if GameLogic.Config.CardConfig[RewardID].UnlockType == "升级":
		var _VALUE = GameLogic.Config.CardConfig[RewardID].UnlockValue
		if GameLogic.cur_Rewards.has(_VALUE):
			GameLogic.cur_Rewards.erase(_VALUE)
	GameLogic.cur_Rewards.append(RewardID)

	GameLogic.call_Reward()
	if Ani.assigned_animation != "Buy":
		Ani.play("Buy")
	GameLogic.call_ChooseFinish()
func _Buy_Puppet_Logic():
	SteamLogic.call_master_node_sync(self, "_Buy_Logic")


func _Buy_Logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.cur_Rewards.has(RewardID):
		return
	if GameLogic.cur_money >= int(RewardShow.Cost):
		if GameLogic.cur_BuyNum <= 0:
			return
		GameLogic.cur_Choose = false
		GameLogic.cur_BuyNum -= 1
		if GameLogic.Config.CardConfig[RewardID].UnlockType == "升级":
			var _VALUE = GameLogic.Config.CardConfig[RewardID].UnlockValue
			if GameLogic.cur_Rewards.has(_VALUE):
				GameLogic.cur_Rewards.erase(_VALUE)
		GameLogic.cur_Rewards.append(RewardID)

		GameLogic.call_MoneyChange( - 1 * int(RewardShow.Cost), GameLogic.HomeMoneyKey)
		GameLogic.level_BuyUpdate += int(RewardShow.Cost)
		GameLogic.call_Reward()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

			SteamLogic.call_puppet_node_sync(self, "call_puppet_logic", [GameLogic.cur_BuyNum])
		if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
		if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
			GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
		if Ani.assigned_animation != "Buy":
			Ani.play("Buy")
		GameLogic.call_ChooseFinish()
		GameLogic.call_StatisticsData_Set("Count_BuyUpdate", null, 1)


		if RewardID in ["自检狂", "自检狂+"]:
			var _Delivery_Array: Array
			var TMap_Delivery = GameLogic.Staff.LevelNode.get_node("MapNode/Delivery")
			var _UsedArray = TMap_Delivery.get_used_cells()
			for _i in _UsedArray.size():
				var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
				_Delivery_Array.append(_pointV2)

			var _rand = GameLogic.return_RANDOM() % _Delivery_Array.size()
			var _ItemName = "HighStressToy"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("HighStressToy")
			var _Item = _TSCN.instance()

			var _Info: Dictionary = {
			"NAME": str(_Item.get_instance_id()),
			"pos": _Delivery_Array[_rand],
			}

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_NewItem", [_ItemName, _Info])
			pass

		if RewardID in ["新增桌台", "新增桌台+", "新增桌台++"]:
			var _Delivery_Array: Array
			var TMap_Delivery = GameLogic.Staff.LevelNode.get_node("MapNode/Delivery")
			var _UsedArray = TMap_Delivery.get_used_cells()
			for _i in _UsedArray.size():
				var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
				_Delivery_Array.append(_pointV2)

			var _rand = GameLogic.return_RANDOM() % _Delivery_Array.size()
			var _ItemName = "Shelf_OnTable"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("Shelf_OnTable")
			var _Item = _TSCN.instance()

			var _Info: Dictionary = {
			"NAME": str(_Item.get_instance_id()),
			"pos": _Delivery_Array[_rand],
			"LayerA_Obj": null,
			"LayerB_Obj": null,
			"LayerX_Obj": null,
			"LayerY_Obj": null,
			}

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_NewItem", [_ItemName, _Info])
		if RewardID in ["新增雪克杯", "新增雪克杯+", "新增雪克杯++"]:
			var _Delivery_Array: Array
			var TMap_Delivery = GameLogic.Staff.LevelNode.get_node("MapNode/Delivery")
			var _UsedArray = TMap_Delivery.get_used_cells()
			for _i in _UsedArray.size():
				var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
				_Delivery_Array.append(_pointV2)

			var _rand = GameLogic.return_RANDOM() % _Delivery_Array.size()
			var _ItemName = "ShakeCup"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("ShakeCup")
			var _Item = _TSCN.instance()
			var _Info: Dictionary = {
			"NAME": str(_Item.get_instance_id()),
			"pos": _Delivery_Array[_rand],
			"LayerA_Obj": null,
			"LayerB_Obj": null,
			"LayerX_Obj": null,
			"LayerY_Obj": null,
			}

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_NewItem", [_ItemName, _Info])
func call_NewItem(_TYPE, _Info):
	match _TYPE:
		"HighStressToy":
			var _ItemName = "HighStressToy"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("HighStressToy")
			var _Item = _TSCN.instance()

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
		"Shelf_OnTable":
			var _ItemName = "Shelf_OnTable"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("Shelf_OnTable")
			var _Item = _TSCN.instance()

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
		"ShakeCup":
			var _ItemName = "ShakeCup"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("ShakeCup")
			var _Item = _TSCN.instance()

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
func _Reward_Init(_ID: String):
	RewardID = _ID
	RewardShow.TYPE = 1
	RewardShow.ID = RewardID

func _Control(_but, _value, _type):

	if P1_bool or P2_bool:
		if _value == 0:
			match _but:
				"X":
					ButShow.call_holding(false)
					GameLogic.cur_Choose = false
		if _value == 1 or _value == - 1:
			if not GameLogic.cur_Choose:
				if GameLogic.cur_money >= int(RewardShow.Cost):
					match _but:
						"X":
							ButShow.call_holding(true)
							GameLogic.cur_Choose = true
				else:
					call_NoMoney()
	else:
		ButShow.call_holding(false)
		GameLogic.cur_Choose = false
func _P2_control_logic(_but, _value, _type):

	if _value == 0:
		match _but:
			"X":
				ButShow.call_holding(false)
				GameLogic.cur_Choose = false
	if _value == 1 or _value == - 1:
		if not GameLogic.cur_Choose:
			if GameLogic.cur_money >= int(RewardShow.Cost):
				match _but:
					"X":
						ButShow.call_holding(true)
						GameLogic.cur_Choose = true
			else:
				call_NoMoney()

func call_NoMoney():
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
	GuideAni.play("NoMoney")
func _P1_control_logic(_but, _value, _type):

	if _value == 0:
		match _but:
			"X":
				ButShow.call_holding(false)
				GameLogic.cur_Choose = false
	if _value == 1 or _value == - 1:
		if not GameLogic.cur_Choose:
			if GameLogic.cur_money >= int(RewardShow.Cost):
				match _but:
					"X":
						ButShow.call_holding(true)
						GameLogic.cur_Choose = true
			else:
				call_NoMoney()




func call_init():
	Ani.play("show")


func _on_Area2D_body_entered(body: Node) -> void :

	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			if not P1_bool and not P2_bool:
				ButShow.call_player_in(_ID)
			P1_bool = true
			if not GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
				var _CON = GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
		2:
			if not P1_bool and not P2_bool:
				ButShow.call_player_in(_ID)
			P2_bool = true
			if not GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
				var _CON = GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")

func _on_Area2D_body_exited(body: Node) -> void :
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			P1_bool = false
			if GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
				GameLogic.Con.disconnect("P1_Control", self, "_P1_control_logic")

			if not P1_bool and not P2_bool:
				ButShow.call_player_out(_ID)

		2:
			P2_bool = false
			if GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_P2_control_logic")

			if not P1_bool and not P2_bool:
				ButShow.call_player_out(_ID)
