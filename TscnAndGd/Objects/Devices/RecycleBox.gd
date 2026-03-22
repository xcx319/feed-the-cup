extends Head_Object

var ItemName: String

var Type: String
var TypeName: String
var _ItemNameDic: Dictionary
var IsOpen: bool
var IsTrash: bool
var HasItem: bool
var CanPass: bool = false

var ItemPos_20_Array = [
	Vector2( - 30, - 20),
	Vector2( - 15, - 20),
	Vector2(0, - 20),
	Vector2(15, - 20),
	Vector2(30, - 20),
	Vector2( - 30, - 7),
	Vector2( - 15, - 7),
	Vector2(0, - 7),
	Vector2(15, - 7),
	Vector2(30, - 7),
	Vector2( - 30, 6),
	Vector2( - 15, 6),
	Vector2(0, 6),
	Vector2(15, 6),
	Vector2(30, 6),
	Vector2( - 30, 20),
	Vector2( - 15, 20),
	Vector2(0, 20),
	Vector2(15, 20),
	Vector2(30, 20)
]
var FruitPos_6_Array = [
	Vector2( - 17, - 10),
	Vector2(17, - 10),
	Vector2( - 17, 0),
	Vector2(17, 0),
	Vector2( - 17, 10),
	Vector2(17, 10),
]
var ItemPos_6_Array = [
	Vector2( - 17, - 3),
	Vector2(17, - 3),
	Vector2( - 17, 7),
	Vector2(17, 7),
	Vector2( - 17, 17),
	Vector2(17, 17),
]
var ItemPos_4_Array = [
	Vector2( - 15, 5),
	Vector2(15, 5),
	Vector2( - 15, 15),
	Vector2(15, 15)
]

var ItemOBJ_Array: Array
onready var ItemNode = get_node("TexNode/ItemNode")
onready var BoxAni = get_node("AniNode/AnimationPlayer")
onready var IconAni = get_node("TexNode/IconNode/IconAni")
onready var TypeAni = get_node("AniNode/TypeAni")
onready var HoldBut = get_node("Hold")
onready var HoldY_But = HoldBut.get_node("Y")
onready var X_But = get_node("But/X")
onready var Audio_Open
var _INFO: Dictionary
var BuyDay: int = 0
var IsBroken: bool = false
var _FreshType: int
func call_new():
	CanPass = true

	get_node("Label/Ani").play("New")

	if GameLogic.cur_Rewards.has("合理堆放") or GameLogic.cur_Rewards.has("合理堆放+"):
		if GameLogic.SPECIALLEVEL_Int:
			get_node("Label/Timer").wait_time = 120
		else:
			get_node("Label/Timer").wait_time = 60
	get_node("Label/Timer").start(0)

func call_move():
	if CanPass:
		CanPass = false
		get_node("Label/Timer").stop()
		_Timer_End()

func But_Hold(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	if not is_instance_valid(get_parent()):
		return
	if get_parent().name == "Weapon_note":
		HoldY_But.show_player(_Player.cur_Player)
		HoldBut.show()
	else:
		HoldBut.hide()
		HoldY_But.call_clean()
func _X_But_Set():
	if IsTrash:
		X_But.hide()
		return
	get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
	if IsOpen:
		if HasItem:
			X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_1)
			X_But.show()
		else:
			X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_2)
			X_But.show()
	else:
		X_But.InfoLabel.text = GameLogic.CardTrans.get_message(X_But.Info_Str)
		X_But.show()
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	But_Hold(_Player)
	_X_But_Set()
	if _Player.Con.IsHold:
		var _OBJ = instance_from_id(_Player.Con.HoldInsId)
		if TypeName != _OBJ.FuncTypePara:

			X_But.hide()
		else:
			get_node("But/A").show()

	.But_Switch(_bool, _Player)
	call_OutLine(_bool)
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func _DayClosedCheck():
	if not is_instance_valid(self):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not is_instance_valid(get_parent()):
		return
	if get_parent().name == "Items":
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.BOX):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.BOX)

func _ready() -> void :
	IsItem = true
	call_init("RecycleBox")

	HoldBut.hide()
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("DayStart", self, "_create"):
		var _con = GameLogic.connect("DayStart", self, "_create")

	Audio_Open = GameLogic.Audio.return_Effect("开纸箱")
func call_Collision_set():
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func _create():
	if _INFO.HasItem and not _ItemNameDic.size():
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		else:

			if _INFO.get("ItemNameDIC"):
				_ItemNameDic = _INFO.ItemNameDIC
				var _CurNum = _INFO.ItemNum
				call_puppet_create(ItemName, _CurNum, _ItemNameDic)

			else:
				print("call_create_num:", _INFO)
				call_create_num(_INFO.ItemNum)

func _new_Box():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN("GasBottle")
	var _BoxTypeNode
	for i in 4:
		var _Box = _BoxLoad.instance()

		var _Info = {
			"TSCN": "GasBottle",
			"NAME": str(_Box.get_instance_id()),
			"pos": ItemPos_4_Array[i],
			"GasNum": _Box.GasMax,
		}

func call_load(_info):

	_INFO = _info
	_SELFID = int(_info.NAME)
	self.name = _info.NAME
	ItemName = _info.ItemName
	.call_Ins_Save(_SELFID)
	if GameLogic.cur_Day < 1:
		_new_Box()
	if GameLogic.Config.ItemConfig.has(ItemName):
		var _CONFIG = GameLogic.Config.ItemConfig[ItemName]
		Type = _CONFIG.FuncType
		TypeName = _CONFIG.FuncTypeNum
		BuyNum = int(_CONFIG.BuyNum)
		_FreshType = int(_CONFIG.FreshType)

	elif GameLogic.Config.DeviceConfig.has(ItemName):
		var _CONFIG = GameLogic.Config.DeviceConfig[ItemName]
		Type = _CONFIG.FuncType
		TypeName = _CONFIG.FuncTypeNum
		BuyNum = 1

	if _info.IsOpen:
		IsOpen = true
		if not Type in ["Fruit"]:
			BoxAni.play("open")
		_X_But_Set()
	_ObjShow_init()
	.call_Collision_set()
	if _info.has("IsTrash"):
		IsTrash = _info.IsTrash
	if IsTrash:
		if Type != "Fruit" and _FreshType > 1:
			TypeAni.play("FoamTrash")
		else:
			TypeAni.play("Trash")
		Weight = 5
	elif Type == "Fruit":
		TypeAni.play(Type)
	elif _FreshType > 1:
		TypeAni.play("Foam")

	if _INFO.has("BuyDay"):
		BuyDay = int(_INFO.BuyDay)
	if _INFO.has("ItemBrokenDIC"):
		ItemBrokenDIC = _INFO.ItemBrokenDIC
var ItemBrokenDIC: Dictionary
func _BrokenCheck():
	for _OBJ in ItemOBJ_Array:
		if ItemBrokenDIC.has(_OBJ.name):
			var _TYPE = ItemBrokenDIC[_OBJ.name]
			match _TYPE:
				1:
					_OBJ.IsPassDay = true
					_OBJ._freshless_logic()
				2:
					_OBJ.Freshless_bool = true
					_OBJ._freshless_logic()

func call_Fruit_PutIn_puppet(_OBJPATH, _PLAYERPATH, _POS):
	var _OBJ = get_node(_OBJPATH)
	var _Player = get_node(_PLAYERPATH)

	if not is_instance_valid(_OBJ):
		return
	_OBJ.position = _POS
	_OBJ.get_parent().remove_child(_OBJ)
	ItemNode.add_child(_OBJ)
	ItemOBJ_Array.append(_OBJ)
	if _OBJ.has_method("call_Info_Switch"):
		_OBJ.call_Info_Switch(false)
	if not HasItem:
		HasItem = true
	But_Switch(true, _Player)
	_ItemNameDic_Check()
func call_Fruit_PutIn(_ButID, _OBJ, _Player):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			.But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			if is_instance_valid(_HoldObj):
				if _HoldObj.get("IsOpen") or _HoldObj.get("Used"):
					return
				var _NUM = ItemNode.get_child_count()
				if _NUM >= int(BuyNum):
					return
				if TypeName == _HoldObj.FuncTypePara and not IsTrash:
					get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_1)
					get_node("But/X").hide()
					.But_Switch(true, _Player)
				else:
					.But_Switch(false, _Player)

		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsTrash:
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				var _HoldObj = instance_from_id(_Player.Con.HoldInsId)

				return
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			if Type == "Fruit":
				var _ARRAY: Array = [Vector2.ZERO]
				match int(BuyNum):
					20:
						_ARRAY = ItemPos_20_Array
					6:
						_ARRAY = FruitPos_6_Array
					4:
						_ARRAY = ItemPos_4_Array

				if TypeName == _HoldObj.FuncTypePara and ItemOBJ_Array.size() < _ARRAY.size():

					var _PosArray: Array
					for _Pos in _ARRAY:
						_PosArray.append(_Pos)
					var _POS = _PosArray[ItemNode.get_child_count()]
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _OBJPATH = _OBJ.get_path()
						var _PLAYERPATH = _Player.get_path()
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_PutIn_puppet", [_OBJPATH, _PLAYERPATH, _POS])
					_OBJ.position = _POS
					_OBJ.get_parent().remove_child(_OBJ)
					ItemNode.add_child(_OBJ)
					ItemOBJ_Array.append(_OBJ)
					_Player.Stat.call_carry_off()
					if _OBJ.has_method("call_Info_Switch"):
						_OBJ.call_Info_Switch(false)
					if not HasItem:
						HasItem = true
					But_Switch(true, _Player)
					_ItemNameDic_Check()
					return "放"
			else:

				if TypeName in ["2", "4", "6"]:
					match ItemName:
						"DrinkCup_S":
							TypeName = GameLogic.Config.ItemConfig["DrinkCup_Group_S"].FuncTypeNum
						"DrinkCup_M":
							TypeName = GameLogic.Config.ItemConfig["DrinkCup_Group_M"].FuncTypeNum
						"DrinkCup_L":
							TypeName = GameLogic.Config.ItemConfig["DrinkCup_Group_L"].FuncTypeNum

				var _HOLDTYPE = _HoldObj.FuncTypePara
				if TypeName == _HOLDTYPE:
					if _HoldObj.get("IsOpen") or _HoldObj.get("Used"):
						return
					var _NUM = ItemNode.get_child_count()
					if _NUM >= int(BuyNum):
						return

					match int(BuyNum):
						20:
							var _PosArray: Array
							for _Pos in ItemPos_20_Array:
								_PosArray.append(_Pos)
							var _POS = _PosArray[ItemNode.get_child_count()]
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _OBJPATH = _OBJ.get_path()
								var _PLAYERPATH = _Player.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_PutIn_puppet", [_OBJPATH, _PLAYERPATH, _POS])
							_OBJ.position = _POS
							_OBJ.get_parent().remove_child(_OBJ)
							ItemNode.add_child(_OBJ)
							ItemOBJ_Array.append(_OBJ)
							_Player.Stat.call_carry_off()
							call_PutIn_Audio()
							if _OBJ.has_method("call_Info_Switch"):
								_OBJ.call_Info_Switch(false)
							if _OBJ.has_method("But_Switch"):
								_OBJ.But_Switch(false, _Player)
							if not HasItem:
								HasItem = true
							But_Switch(true, _Player)

						6:
							var _PosArray: Array
							for _Pos in ItemPos_6_Array:
								_PosArray.append(_Pos)
							var _POS = _PosArray[ItemNode.get_child_count()]
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _OBJPATH = _OBJ.get_path()
								var _PLAYERPATH = _Player.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_PutIn_puppet", [_OBJPATH, _PLAYERPATH, _POS])
							_OBJ.position = _POS
							_OBJ.get_parent().remove_child(_OBJ)
							ItemNode.add_child(_OBJ)
							ItemOBJ_Array.append(_OBJ)
							_Player.Stat.call_carry_off()
							call_PutIn_Audio()
							if _OBJ.has_method("call_Info_Switch"):
								_OBJ.call_Info_Switch(false)
							if _OBJ.has_method("But_Switch"):
								_OBJ.But_Switch(false, _Player)
							if not HasItem:
								HasItem = true
							But_Switch(true, _Player)

						4:
							var _PosArray: Array
							for _Pos in ItemPos_4_Array:
								_PosArray.append(_Pos)
							var _POS = _PosArray[ItemNode.get_child_count()]
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _OBJPATH = _OBJ.get_path()
								var _PLAYERPATH = _Player.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_PutIn_puppet", [_OBJPATH, _PLAYERPATH, _POS])
							_OBJ.position = _POS
							_OBJ.get_parent().remove_child(_OBJ)
							ItemNode.add_child(_OBJ)
							ItemOBJ_Array.append(_OBJ)
							_Player.Stat.call_carry_off()
							call_PutIn_Audio()
							if _OBJ.has_method("call_Info_Switch"):
								_OBJ.call_Info_Switch(false)
							if _OBJ.has_method("But_Switch"):
								_OBJ.But_Switch(false, _Player)
							if not HasItem:
								HasItem = true
							But_Switch(true, _Player)

					_ItemNameDic_Check()
					return "放"
func call_PutIn_Audio():
	var _AUDIO = GameLogic.Audio.return_Effect("放下箱子")
	_AUDIO.play(0)



func _ObjShow_init():

	IconAni.play(ItemName)

func call_puppet_create(_ItemName, _CurNum, _CurItemNameDic: Dictionary):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_create", [ItemName, _CurNum, _ItemNameDic])
	ItemName = _ItemName
	_ObjShow_init()
	HasItem = true
	var _PosArray: Array
	if GameLogic.Config.ItemConfig.has(ItemName):
		BuyNum = int(GameLogic.Config.ItemConfig[ItemName]["BuyNum"])
	elif GameLogic.Config.DeviceConfig.has(ItemName):
		BuyNum = 1
	else:
		BuyNum = 1
	match int(BuyNum):
		20:
			for _Pos in ItemPos_20_Array:
				_PosArray.append(_Pos)
		6:
			for _Pos in ItemPos_6_Array:
				_PosArray.append(_Pos)
		4:
			for _Pos in ItemPos_4_Array:
				_PosArray.append(_Pos)
		1:
			_PosArray.append(Vector2.ZERO)

	var _CONFIG
	if GameLogic.Config.ItemConfig.has(ItemName):
		_CONFIG = GameLogic.Config.ItemConfig[ItemName]
	elif GameLogic.Config.DeviceConfig.has(ItemName):
		_CONFIG = GameLogic.Config.DeviceConfig[ItemName]
	Type = _CONFIG.FuncType
	TypeName = _CONFIG.FuncTypeNum
	for i in int(_CurNum):
		if _PosArray:
			var _pos = _PosArray.pop_front()
			if _CurItemNameDic.has(str(i)):
				var _ObjName = _CurItemNameDic[str(i)]
				_Puppet_ItemCreate(_pos, _ObjName)
			else:
				printerr("生成箱子内容物错误：", TypeName, " Num:", _CurNum, " NameDic:", _CurItemNameDic)
	_BrokenCheck()
func _Puppet_ItemCreate(_pos, _ObjName):
	var _ItemName

	match Type:


		"Fruit":
			IsOpen = true
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("水果")
			var _Obj = _TSCN.instance()
			_Obj.position = _pos
			_Obj._SELFID = int(_ObjName)
			_Obj.name = str(_Obj._SELFID)
			ItemNode.add_child(_Obj)
			_Obj.call_load_TSCN(ItemName)
			ItemOBJ_Array.append(_Obj)
			TypeAni.play("Fruit")
		_:
			match ItemName:
				"DrinkCup_S":
					_ItemName = "DrinkCup_Group_S"
				"DrinkCup_M":
					_ItemName = "DrinkCup_Group_M"
				"DrinkCup_L":
					_ItemName = "DrinkCup_Group_L"
				_:
					_ItemName = ItemName
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
			var _Obj = _TSCN.instance()
			_Obj._SELFID = int(_ObjName)
			_Obj.name = str(_Obj._SELFID)
			_Obj.position = _pos
			ItemNode.add_child(_Obj)
			_Obj.call_load_TSCN(_ItemName)
			ItemOBJ_Array.append(_Obj)
func call_create_num(_Num):

	HasItem = true
	var _PosArray: Array
	if BuyNum == 0:
		if GameLogic.Config.ItemConfig.has(ItemName):
			BuyNum = int(GameLogic.Config.ItemConfig[ItemName]["BuyNum"])
		elif GameLogic.Config.DeviceConfig.has(ItemName):
			BuyNum = 1
		else:
			BuyNum = 1
	match int(BuyNum):
		20:
			for _Pos in ItemPos_20_Array:
				_PosArray.append(_Pos)
		6:
			for _Pos in ItemPos_6_Array:
				_PosArray.append(_Pos)
		4:
			for _Pos in ItemPos_4_Array:
				_PosArray.append(_Pos)
		1:
			_PosArray.append(Vector2.ZERO)

	if GameLogic.Config.ItemConfig.has(ItemName):
		var _CONFIG = GameLogic.Config.ItemConfig[ItemName]
		Type = _CONFIG.FuncType
		TypeName = _CONFIG.FuncTypeNum
	elif GameLogic.Config.DeviceConfig.has(ItemName):
		var _CONFIG = GameLogic.Config.DeviceConfig[ItemName]
		Type = _CONFIG.FuncType
		TypeName = _CONFIG.FuncTypeNum
	_ItemNameDic.clear()
	for i in int(_Num):
		if _PosArray:
			var _pos = _PosArray.pop_front()
			_ItemNameDic[str(i)] = return_ItemInBox_Create(_pos)
	_BrokenCheck()


func return_ItemInBox_Create(_pos):
	var _ItemName

	match Type:
		"Fruit":
			IsOpen = true
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("水果")
			var _Obj = _TSCN.instance()
			_Obj.position = _pos
			_Obj._SELFID = _Obj.get_instance_id()
			_Obj.name = str(_Obj._SELFID)
			ItemNode.add_child(_Obj)
			_Obj.call_load_TSCN(ItemName)
			ItemOBJ_Array.append(_Obj)
			TypeAni.play("Fruit")
			return _Obj.name
		_:
			match ItemName:
				"DrinkCup_S":
					_ItemName = "DrinkCup_Group_S"
				"DrinkCup_M":
					_ItemName = "DrinkCup_Group_M"
				"DrinkCup_L":
					_ItemName = "DrinkCup_Group_L"
				_:
					_ItemName = ItemName
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
			var _Obj = _TSCN.instance()
			_Obj._SELFID = _Obj.get_instance_id()
			_Obj.name = str(_Obj._SELFID)
			_Obj.position = _pos
			ItemNode.add_child(_Obj)
			_Obj.call_load_TSCN(_ItemName)
			ItemOBJ_Array.append(_Obj)

			if IsBroken:
				if _Obj.has_method("call_Broken"):
					_Obj.call_Broken()
			return _Obj.name


func call_pickup_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	.call_pickup_by(_Player, self)
	call_move()
func call_pickup_by(_Player, _BoxObj):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()

		SteamLogic.call_puppet_id_sync(_SELFID, "call_pickup_puppet", [_PLAYERPATH])
	_Player.Con.NeedPush = true
	.call_pickup_by(_Player, self)
	call_move()

func call_OpenBox_puppet():
	IsOpen = true
	if not Type in ["Fruit"]:
		BoxAni.play("open")
		Audio_Open.play(0)
		call_move()

		_X_But_Set()

func call_OpenBox():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_OpenBox_puppet")
	IsOpen = true
	if not Type in ["Fruit"]:
		BoxAni.play("open")
		Audio_Open.play(0)
		call_move()

		_X_But_Set()
		return "开箱"
	_X_But_Set()
func _ItemNameDic_Check():
	_ItemNameDic.clear()
	for _ItemOBJ in ItemOBJ_Array:
		_ItemNameDic[str(_ItemNameDic.size())] = _ItemOBJ.name

func call_PickFruitInCup(_ButID, _CupObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)
	if Type == "Fruit" and HasItem:
		if not ItemOBJ_Array.size():
			return
		var _Item = ItemOBJ_Array.back()
		print("PickFruitInCup:", ItemOBJ_Array, is_instance_valid(_Item))
		if not is_instance_valid(_Item):
			return
		if _Item.has_method("call_WaterInDrinkCup"):
			if _ButID >= 0:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
			if _ButID == 0:
				if _CupObj.Liquid_Count >= _CupObj.Liquid_Max:
					return
				var _Fruit = ItemOBJ_Array.pop_back()
				_Fruit.call_WaterInDrinkCup(_ButID, _CupObj, _Player)
				print("PickFruitInCup1:", _Fruit)
				if not ItemOBJ_Array:
					HasItem = false
				_ItemNameDic_Check()
				return "加水果"

			else:
				_Item.call_WaterInDrinkCup(_ButID, _CupObj, _Player)
				_ItemNameDic_Check()
				return "加水果"
func call_PickItem(_Player):

	if not ItemOBJ_Array:
		HasItem = false
	else:
		HasItem = true
	if HasItem:
		var _Item = ItemOBJ_Array.pop_back()

		GameLogic.Device.call_Player_Pick(_Player, _Item)
		if not ItemOBJ_Array:
			HasItem = false
		But_Switch(false, _Player)
		call_Fruit_PutIn( - 1, null, _Player)
		_ItemNameDic_Check()
		return "箱中取"
	else:
		if not IsTrash:
			call_ObjTurnTrashbag(5)
			return "拆箱"
		else:
			return


func call_ObjTurnTrash_puppet(_IsSell):
	if _IsSell:
		var _Effect = GameLogic.TSCNLoad.SmokeEffect_TSCN
		var _EffectNode = _Effect.instance()
		var _parentNode = get_parent()
		_EffectNode.position = self.global_position
		_parentNode.remove_child(self)
		if _parentNode.name in ["Devices", "Items"]:
			_parentNode.get_parent().add_child(_EffectNode)
		else:
			if is_instance_valid(GameLogic.Staff.LevelNode):
				GameLogic.Staff.LevelNode.add_child(_EffectNode)
		var _Money = 3
		GameLogic.call_MoneyOther_Change(_Money, GameLogic.HomeMoneyKey)

		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_EffectNode.add_child(_PayEffect)
		_PayEffect.call_init(_Money, _Money, 0, false, false, false, false)
		var _TableNode = _parentNode.get_parent()
		if _TableNode.has_method("call_OnTable"):
			_TableNode.call_OnTable(null)
		GameLogic.Save.statisticsData["Count_DelBox"] += 1
		Audio_Open.play(0)
		self.call_del()
	else:
		var _Effect = GameLogic.TSCNLoad.SmokeEffect_TSCN
		var _EffectNode = _Effect.instance()
		_EffectNode.position = self.global_position
		if not IsTrash:
			IsTrash = true
			Audio_Open.play(0)

		else:
			return

		var _parentNode = get_parent()
		if _parentNode.name in ["Devices", "Items"]:
			_parentNode.get_parent().add_child(_EffectNode)
		else:
			if is_instance_valid(GameLogic.Staff.LevelNode):
				GameLogic.Staff.LevelNode.add_child(_EffectNode)


		if TypeAni.assigned_animation in ["Foam"]:
			TypeAni.play("FoamTrash")
		else:
			TypeAni.play("Trash")
		Weight = 5
		GameLogic.Save.statisticsData["Count_DelBox"] += 1
		get_node("But/X").hide()
func call_ObjTurnTrashbag(_weight):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Effect = GameLogic.TSCNLoad.SmokeEffect_TSCN
	var _EffectNode = _Effect.instance()
	_EffectNode.position = self.global_position
	if GameLogic.Achievement.cur_EquipList.has("卖纸箱") and not GameLogic.SPECIALLEVEL_Int:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_ObjTurnTrash_puppet", [true])
		var _parentNode = get_parent()
		_parentNode.remove_child(self)
		if _parentNode.name in ["Devices", "Items"]:
			_parentNode.get_parent().add_child(_EffectNode)
		else:
			if is_instance_valid(GameLogic.Staff.LevelNode):
				GameLogic.Staff.LevelNode.add_child(_EffectNode)

		var _Money = 5
		if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
			_Money = int(float(_Money) * 1.5)
		GameLogic.call_MoneyOther_Change(_Money, GameLogic.HomeMoneyKey)

		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_EffectNode.add_child(_PayEffect)
		_PayEffect.call_init(_Money, _Money, 0, false, false, false, false)
		var _TableNode = _parentNode.get_parent()
		if _TableNode.has_method("call_OnTable"):
			_TableNode.call_OnTable(null)
		GameLogic.Save.statisticsData["Count_DelBox"] += 1
		Audio_Open.play(0)

		return
	if not IsTrash:
		IsTrash = true
		Audio_Open.play(0)

	else:
		return

	var _parentNode = get_parent()
	if _parentNode.name in ["Devices", "Items"]:
		_parentNode.get_parent().add_child(_EffectNode)
	else:
		if is_instance_valid(GameLogic.Staff.LevelNode):
			GameLogic.Staff.LevelNode.add_child(_EffectNode)

	if TypeAni.assigned_animation in ["Foam"]:
		TypeAni.play("FoamTrash")
	else:
		TypeAni.play("Trash")
	Weight = 5
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_ObjTurnTrash_puppet", [false])





	GameLogic.Save.statisticsData["Count_DelBox"] += 1
	get_node("But/X").hide()

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
func _Timer_End():
	if get_node("Label/Ani").assigned_animation != "hide":
		get_node("Label/Ani").play("hide")
	CanPass = false
