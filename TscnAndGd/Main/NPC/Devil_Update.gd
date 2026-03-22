extends Area2D

onready var DeviceTSCN = preload("res://TscnAndGd/Main/NPC/Devil_Device.tscn")

onready var MainAni = $AnimationPlayer
onready var HBox = $Control / HBoxContainer
onready var NumAni = $NumAni
onready var ChooseAni = $ChooseAni

onready var But_X = $Control / CurChoose / L / X
onready var But_Y = $Control / CurChoose / R / Y
onready var But_A = $Control / CurChoose / A
var CurGroup
export var CanUse: bool
var cur_Used: bool
var cur_PLAYERNAME: String
var CanBuy: bool
var cur_1: String
var cur_2: String
var cur_3: String

func call_show():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_show_puppet", [cur_1, cur_2, cur_3])
	$ShowAni.play("show")
	call_Say_1()

func call_show_puppet(_1, _2, _3):
	cur_1 = _1
	cur_2 = _2
	cur_3 = _3

	var _LIST: Array = HBox.get_children()
	for _NODE in _LIST:
		HBox.remove_child(_NODE)
		_NODE.queue_free()

	var _NUM: int = 0
	if cur_1 != "":
		_NUM = 1
	if cur_2 != "":
		_NUM = 2
	if cur_3 != "":
		_NUM = 3
	if NumAni.has_animation(str(_NUM)):
		NumAni.play(str(_NUM))
	for _i in _NUM:
		var _CHOOSE
		match _i:
			0:
				_CHOOSE = cur_1
			1:
				_CHOOSE = cur_2
			2:
				_CHOOSE = cur_3
			_:
				break
		var _DEVICE = DeviceTSCN.instance()
		HBox.add_child(_DEVICE)
		_DEVICE.call_init(_CHOOSE)
	$ShowAni.play("show")
	call_Say_1()
	call_Info_Set()

func call_init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _LIST: Array = HBox.get_children()
	for _NODE in _LIST:
		HBox.remove_child(_NODE)
		_NODE.queue_free()

	var _PICKLIST: Array
	if not GameLogic.cur_Rewards.has("垃圾桶升级") and not GameLogic.cur_Rewards.has("垃圾桶升级+"):
		_PICKLIST.append("垃圾桶升级")
	elif GameLogic.cur_Rewards.has("垃圾桶升级") and not GameLogic.cur_Rewards.has("垃圾桶升级+"):
		_PICKLIST.append("垃圾桶升级+")
	if is_instance_valid(GameLogic.NPC.CUPHOLDER):
		if not GameLogic.cur_Rewards.has("杯架升级") and not GameLogic.cur_Rewards.has("杯架升级+"):
			_PICKLIST.append("杯架升级")
		elif GameLogic.cur_Rewards.has("杯架升级") and not GameLogic.cur_Rewards.has("杯架升级+"):
			_PICKLIST.append("杯架升级+")
	if not GameLogic.cur_Rewards.has("新增桌台") and not GameLogic.cur_Rewards.has("新增桌台+"):
		_PICKLIST.append("新增桌台")
	if not GameLogic.cur_Rewards.has("果糖机升级") and not GameLogic.cur_Rewards.has("果糖机升级+"):
		_PICKLIST.append("果糖机升级")
	elif GameLogic.cur_Rewards.has("果糖机升级") and not GameLogic.cur_Rewards.has("果糖机升级+"):
		_PICKLIST.append("果糖机升级+")

	if GameLogic.cur_levelInfo.has("Machine"):
		if GameLogic.cur_levelInfo.Machine.has("清洗机"):
			if not GameLogic.cur_Rewards.has("清洗机升级") and not GameLogic.cur_Rewards.has("清洗机升级+"):
				_PICKLIST.append("清洗机升级")
			elif GameLogic.cur_Rewards.has("清洗机升级") and not GameLogic.cur_Rewards.has("清洗机升级+"):
				_PICKLIST.append("清洗机升级+")

		if GameLogic.cur_levelInfo.Machine.has("冰淇淋机"):
			if not GameLogic.cur_Rewards.has("冰淇淋机升级") and not GameLogic.cur_Rewards.has("冰淇淋机升级+"):
				_PICKLIST.append("冰淇淋机升级")
			elif GameLogic.cur_Rewards.has("冰淇淋机升级") and not GameLogic.cur_Rewards.has("冰淇淋机升级+"):
				_PICKLIST.append("冰淇淋机升级+")
		if GameLogic.cur_levelInfo.Machine.has("蛋卷机"):
			if not GameLogic.cur_Rewards.has("蛋卷机升级") and not GameLogic.cur_Rewards.has("蛋卷机升级+"):
				_PICKLIST.append("蛋卷机升级")
			elif GameLogic.cur_Rewards.has("蛋卷机升级") and not GameLogic.cur_Rewards.has("蛋卷机升级+"):
				_PICKLIST.append("蛋卷机升级+")
		if GameLogic.cur_levelInfo.Machine.has("搅拌机"):
			if not GameLogic.cur_Rewards.has("搅拌机升级") and not GameLogic.cur_Rewards.has("搅拌机升级+"):
				_PICKLIST.append("搅拌机升级")
			elif GameLogic.cur_Rewards.has("搅拌机升级") and not GameLogic.cur_Rewards.has("搅拌机升级+"):
				_PICKLIST.append("搅拌机升级+")
		if GameLogic.cur_levelInfo.Machine.has("榨汁机"):
			if not GameLogic.cur_Rewards.has("榨汁机升级") and not GameLogic.cur_Rewards.has("榨汁机升级+"):
				_PICKLIST.append("榨汁机升级")
			elif GameLogic.cur_Rewards.has("榨汁机升级") and not GameLogic.cur_Rewards.has("榨汁机升级+"):
				_PICKLIST.append("榨汁机升级+")
		if GameLogic.cur_levelInfo.Machine.has("切块机"):
			if not GameLogic.cur_Rewards.has("切块机升级") and not GameLogic.cur_Rewards.has("切块机升级+"):
				_PICKLIST.append("切块机升级")
			elif GameLogic.cur_Rewards.has("切块机升级") and not GameLogic.cur_Rewards.has("切块机升级+"):
				_PICKLIST.append("切块机升级+")

		if GameLogic.cur_levelInfo.Machine.has("气泡水机"):
			if not GameLogic.cur_Rewards.has("气泡水机升级") and not GameLogic.cur_Rewards.has("气泡水机升级+"):
				_PICKLIST.append("气泡水机升级")
			elif GameLogic.cur_Rewards.has("气泡水机升级") and not GameLogic.cur_Rewards.has("气泡水机升级+"):
				_PICKLIST.append("气泡水机升级+")
		if GameLogic.cur_levelInfo.Machine.has("软饮机"):
			if not GameLogic.cur_Rewards.has("软饮机升级") and not GameLogic.cur_Rewards.has("软饮机升级+"):
				_PICKLIST.append("软饮机升级")
			elif GameLogic.cur_Rewards.has("软饮机升级") and not GameLogic.cur_Rewards.has("软饮机升级+"):
				_PICKLIST.append("软饮机升级+")
		if GameLogic.cur_levelInfo.Machine.has("封盖机"):
			if not GameLogic.cur_Rewards.has("封盖机升级") and not GameLogic.cur_Rewards.has("封盖机升级+"):
				_PICKLIST.append("封盖机升级")
			elif GameLogic.cur_Rewards.has("封盖机升级") and not GameLogic.cur_Rewards.has("封盖机升级+"):
				_PICKLIST.append("封盖机升级+")
		if GameLogic.cur_levelInfo.Machine.has("咖啡机"):
			if not GameLogic.cur_Rewards.has("咖啡机升级") and not GameLogic.cur_Rewards.has("咖啡机升级+"):
				_PICKLIST.append("咖啡机升级")
			elif GameLogic.cur_Rewards.has("咖啡机升级") and not GameLogic.cur_Rewards.has("咖啡机升级+"):
				_PICKLIST.append("咖啡机升级+")
		if GameLogic.cur_levelInfo.Machine.has("制冰机"):
			if is_instance_valid(GameLogic.NPC.ICEMACHINE):
				if not GameLogic.cur_Rewards.has("制冰机升级") and not GameLogic.cur_Rewards.has("制冰机升级+"):
					_PICKLIST.append("制冰机升级")
				elif GameLogic.cur_Rewards.has("制冰机升级") and not GameLogic.cur_Rewards.has("制冰机升级+"):
					_PICKLIST.append("制冰机升级+")
		if GameLogic.cur_levelInfo.Machine.has("蒸汽机"):
			if not GameLogic.cur_Rewards.has("蒸汽机升级") and not GameLogic.cur_Rewards.has("蒸汽机升级+"):
				_PICKLIST.append("蒸汽机升级")
			elif GameLogic.cur_Rewards.has("蒸汽机升级") and not GameLogic.cur_Rewards.has("蒸汽机升级+"):
				_PICKLIST.append("蒸汽机升级+")
		if GameLogic.cur_levelInfo.Machine.has("电磁炉"):
			if not GameLogic.cur_Rewards.has("电磁炉升级") and not GameLogic.cur_Rewards.has("电磁炉升级+"):
				_PICKLIST.append("电磁炉升级")
			elif GameLogic.cur_Rewards.has("电磁炉升级") and not GameLogic.cur_Rewards.has("电磁炉升级+"):
				_PICKLIST.append("电磁炉升级+")
		if GameLogic.cur_levelInfo.Machine.has("茶桶"):
			if not GameLogic.cur_Rewards.has("茶桶升级") and not GameLogic.cur_Rewards.has("茶桶升级+"):
				_PICKLIST.append("茶桶升级")
			elif GameLogic.cur_Rewards.has("茶桶升级") and not GameLogic.cur_Rewards.has("茶桶升级+"):
				_PICKLIST.append("茶桶升级+")
		if GameLogic.cur_levelInfo.Machine.has("破壁机"):
			if not GameLogic.cur_Rewards.has("破壁机升级") and not GameLogic.cur_Rewards.has("破壁机升级+"):
				_PICKLIST.append("破壁机升级")
			elif GameLogic.cur_Rewards.has("破壁机升级") and not GameLogic.cur_Rewards.has("破壁机升级+"):
				_PICKLIST.append("破壁机升级+")
	var _CHOOSECHANCE: int = 3
	if _PICKLIST.size() < 3:
		_CHOOSECHANCE = _PICKLIST.size()



	for _i in _CHOOSECHANCE:
		var _RAND = GameLogic.return_randi() % _PICKLIST.size()
		var _CHOOSE = _PICKLIST[_RAND]
		_PICKLIST.remove(_RAND)
		match _i:
			0:
				cur_1 = _CHOOSE
			1:
				cur_2 = _CHOOSE
			2:
				cur_3 = _CHOOSE
		var _DEVICE = DeviceTSCN.instance()
		HBox.add_child(_DEVICE)
		_DEVICE.call_init(_CHOOSE)

	var _ANINAME = str(HBox.get_child_count())
	if NumAni.has_animation(_ANINAME):
		NumAni.play(_ANINAME)
	match _ANINAME:
		1:
			ChooseAni.play("1-1")
		2:
			ChooseAni.play("2-1")
		3:
			ChooseAni.play("3-2")

	if not GameLogic.is_connected("DayStart", self, "call_show"):
		var _CON = GameLogic.connect("DayStart", self, "call_show")
	var _TimeCheck = GameLogic.connect("OpenStore", self, "_Hide")
var _INITBOOL: bool
func call_Info_Set():
	var _CUR
	match ChooseAni.assigned_animation:
		"1-1", "2-1", "3-1":
			_CUR = cur_1
		"2-2", "3-2":
			_CUR = cur_2
		"3-3":
			_CUR = cur_3
	if GameLogic.Config.CardConfig.has(_CUR):

		var _INFO = GameLogic.Config.CardConfig[_CUR]
		var _Type1 = _INFO.InfoType1
		var _Type2 = _INFO.InfoType2
		$Control / INFOBG / NameLabel.text = GameLogic.CardTrans.get_message(_INFO.ShowNameID)
		var _ChallengeInfo = GameLogic.CardTrans.get_message(_INFO.ShowInfoID)
		var _TEXT_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo, _Type1, _Type2)

		var _TEXT = "[center]" + _TEXT_1.format(GameLogic.Info.Info_Name) + "[/center]"
		$Control / INFOBG / InfoLabel.bbcode_text = _TEXT
	_INITBOOL = true

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 2:
			if not CanUse:
				return
			if cur_Used:
				if cur_PLAYERNAME == _Player.name:
					cur_PLAYERNAME = ""
					if MainAni.assigned_animation == "buy":
						MainAni.play("hide")

					cur_Used = false
					But_X.call_player_out(_Player.cur_Player)
					But_Y.call_player_out(_Player.cur_Player)
					But_A.call_player_out(_Player.cur_Player)
		- 1:
			if CanUse:
				if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					if not cur_Used:
						cur_Used = true
						cur_PLAYERNAME = _Player.name
						MainAni.play("buy")
						But_X.call_player_in(_Player.cur_Player)
						But_Y.call_player_in(_Player.cur_Player)
						But_A.call_player_in(_Player.cur_Player)

		0, "A":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if CanUse:
					if _value == 1 or _value == - 1:
						if MainAni.assigned_animation == "buy":
							call_BuyCheck()
		2, "X":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if CanUse:
					if _value == 1 or _value == - 1:
						if MainAni.assigned_animation == "buy":
							call_ChooseLogic("L")
		3, "Y":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if CanUse:
					if _value == 1 or _value == - 1:
						if MainAni.assigned_animation == "buy":
							call_ChooseLogic("R")
func call_ChooseLogic(_LR):

	match ChooseAni.assigned_animation:
		"1-1":
			pass
		"2-1":
			if _LR == "R":
				ChooseAni.play("2-2")
				GameLogic.Audio.But_EasyClick.play(0)
		"2-2":
			if _LR == "L":
				ChooseAni.play("2-1")
				GameLogic.Audio.But_EasyClick.play(0)
		"3-1":
			if _LR == "R":
				ChooseAni.play("3-2")
				GameLogic.Audio.But_EasyClick.play(0)
		"3-2":
			if _LR == "L":
				ChooseAni.play("3-1")
				GameLogic.Audio.But_EasyClick.play(0)
			if _LR == "R":
				ChooseAni.play("3-3")
				GameLogic.Audio.But_EasyClick.play(0)
		"3-3":
			if _LR == "L":
				ChooseAni.play("3-2")
				GameLogic.Audio.But_EasyClick.play(0)
	call_Info_Set()
func call_BuyCheck():

	match ChooseAni.assigned_animation:
		"1-1", "2-1", "3-1":
			if HBox.get_child_count() >= 1:
				var _NODE = HBox.get_child(0)
				var _MONEY: int = _NODE.MONEY
				var _ID = _NODE.ID
				_BuyLogic(_MONEY, _ID)
		"2-2", "3-2":
			if HBox.get_child_count() >= 2:
				var _NODE = HBox.get_child(1)
				var _MONEY: int = _NODE.MONEY
				var _ID = _NODE.ID
				_BuyLogic(_MONEY, _ID)
		"3-3":
			if HBox.get_child_count() >= 3:
				var _NODE = HBox.get_child(2)
				var _MONEY: int = _NODE.MONEY
				var _ID = _NODE.ID
				_BuyLogic(_MONEY, _ID)
func _BuyLogic(_Money, _ID):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if GameLogic.cur_money >= _Money and not GameLogic.cur_Rewards.has(_ID):
			SteamLogic.call_master_node_sync(self, "call_Master_Buy", [_Money, _ID])
		else:
			var _AUDIO = GameLogic.Audio.return_Effect("错误1")
			_AUDIO.play(0)
		return
	call_Master_Buy(_Money, _ID)

func call_Master_Buy(_Money, _ID):
	if not CanBuy:
		return
	if GameLogic.cur_money >= _Money and not GameLogic.cur_Rewards.has(_ID):
		GameLogic.level_BuyUpdate += _Money
		GameLogic.call_MoneyChange(_Money * - 1, GameLogic.HomeMoneyKey)
		if GameLogic.Config.CardConfig[_ID].UnlockType == "升级":
			var _VALUE = GameLogic.Config.CardConfig[_ID].UnlockValue
			if GameLogic.cur_Rewards.has(_VALUE):
				GameLogic.cur_Rewards.erase(_VALUE)
		GameLogic.cur_Rewards.append(_ID)
		CanBuy = false
		call_BuyEnd(_ID)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_BuyEnd_puppet", [_ID])
	else:
		var _AUDIO = GameLogic.Audio.return_Effect("错误1")
		_AUDIO.play(0)
func call_BuyEnd(_ID):

	CanUse = false
	GameLogic.call_Reward()
	$CoinAudio.play(0)
	MainAni.play("buyend")
	if _ID in ["新增桌台", "新增桌台+", "新增桌台++"]:
		var _Delivery_Array: Array
		var TMap_Delivery = GameLogic.Staff.LevelNode.get_node("MapNode/Delivery")
		var _UsedArray = TMap_Delivery.get_used_cells()
		for _i in _UsedArray.size():
			var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
			_Delivery_Array.append(_pointV2)
		_Delivery_Array.shuffle()
		var _rand = GameLogic.return_randi() % _Delivery_Array.size()
		var _ItemName = "Shelf_OnTable"
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
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
func call_BuyEnd_puppet(_ID):
	if GameLogic.Config.CardConfig[_ID].UnlockType == "升级":
		var _VALUE = GameLogic.Config.CardConfig[_ID].UnlockValue
		if GameLogic.cur_Rewards.has(_VALUE):
			GameLogic.cur_Rewards.erase(_VALUE)
	if not GameLogic.cur_Rewards.has(_ID):
		GameLogic.cur_Rewards.append(_ID)
	CanUse = false
	GameLogic.call_Reward()
	$CoinAudio.play(0)
	MainAni.play("buyend")
func call_del():
	self.queue_free()
func _Hide():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_Hide")
	if CanUse:
		CanUse = false

	if not MainAni.assigned_animation in ["leave", "buyend"]:
		$ShowAni.play("leave")
func call_NewItem(_TYPE, _Info):
	match _TYPE:
		"Shelf_OnTable":
			var _ItemName = "Shelf_OnTable"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
			var _Item = _TSCN.instance()

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)
		"ShakeCup":
			var _ItemName = "ShakeCup"
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
			var _Item = _TSCN.instance()

			GameLogic.Staff.LevelNode.Ysort_Items.add_child(_Item)
			_Item.call_load(_Info)

func call_Say_1():
	$Label.text = GameLogic.CardTrans.get_message("UI-设备升级")


var P1_bool: bool
var P2_bool: bool

func call_check():
	CanBuy = true
	if P1_bool or P2_bool:
		if CanUse:
			if MainAni.assigned_animation != "buy":
				MainAni.play("buy")
	if P1_bool:
		if not GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
			var _CON = GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
	if P2_bool:
		if not GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
			var _CON = GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")
func _on_Area2D_body_entered(body):

	if not _INITBOOL:
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			if not P1_bool and not P2_bool:
				if CanUse:
					MainAni.play("buy")

			P1_bool = true
			if not GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
				var _CON = GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
		2:
			if not P1_bool and not P2_bool:
				if CanUse:
					MainAni.play("buy")
			P2_bool = true
			if not GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
				var _CON = GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")

func _on_Area2D_body_exited(body: Node) -> void :
	if not _INITBOOL:
		return
	var _ID = body.cur_Player
	match _ID:
		1, SteamLogic.STEAM_ID:
			P1_bool = false
			if GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
				GameLogic.Con.disconnect("P1_Control", self, "_P1_control_logic")

			if not P1_bool and not P2_bool:
				if MainAni.assigned_animation == "buy":
					MainAni.play("hide")

		2:
			P2_bool = false
			if GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
				GameLogic.Con.disconnect("P2_Control", self, "_P2_control_logic")

			if not P1_bool and not P2_bool:
				if MainAni.assigned_animation == "buy":
					MainAni.play("hide")
func _P2_control_logic(_but, _value, _type):

	match _but:
		0, "A":

			if CanUse:
				if _value == 1 or _value == - 1:
					if MainAni.assigned_animation == "buy":
						call_BuyCheck()
		2, "X":

			if CanUse:
				if _value == 1 or _value == - 1:
					if MainAni.assigned_animation == "buy":
						call_ChooseLogic("L")
		3, "Y":

			if CanUse:
				if _value == 1 or _value == - 1:
					if MainAni.assigned_animation == "buy":
						call_ChooseLogic("R")
func _P1_control_logic(_but, _value, _type):

	match _but:
		0, "A":

			if CanUse:
				if _value == 1 or _value == - 1:
					if MainAni.assigned_animation == "buy":
						call_BuyCheck()
		2, "X":

			if CanUse:
				if _value == 1 or _value == - 1:
					if MainAni.assigned_animation == "buy":
						call_ChooseLogic("L")
		3, "Y":

			if CanUse:
				if _value == 1 or _value == - 1:
					if MainAni.assigned_animation == "buy":
						call_ChooseLogic("R")

func call_Money_Set():

	for _NODE in HBox.get_children():
		if _NODE.has_method("call_MoneyAni"):
			_NODE.call_MoneyAni()
