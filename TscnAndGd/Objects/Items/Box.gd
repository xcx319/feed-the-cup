extends Head_Object

var ItemName: String

var Type: String
var TypeName: String
var _ItemNameDic: Dictionary
var IsOpen: bool
var IsTrash: bool
var HasItem: bool
var CanPass: bool = false

var ItemPos_12_Array = [
	Vector2( - 30, - 20),
	Vector2( - 10, - 20),
	Vector2(10, - 20),
	Vector2(30, - 20),
	Vector2( - 30, 0),
	Vector2( - 10, 0),
	Vector2(10, 0),
	Vector2(30, 0),
	Vector2( - 30, 20),
	Vector2( - 10, 20),
	Vector2(10, 20),
	Vector2(30, 20)
]
var ItemPos_10_Array = [
	Vector2( - 10, - 20),
	Vector2(10, - 20),
	Vector2(30, - 20),
	Vector2( - 30, 0),
	Vector2( - 10, 0),
	Vector2(10, 0),
	Vector2(30, 0),
	Vector2( - 30, 20),
	Vector2( - 10, 20),
	Vector2(10, 20),
]
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
var ItemPos_5_Array = [
	Vector2(0, - 20),
	Vector2(0, - 10),
	Vector2(0, 0),
	Vector2(0, 10),
	Vector2(0, 20),
]
var ItemPos_4_Array = [
	Vector2( - 15, 5),
	Vector2(15, 5),
	Vector2( - 15, 15),
	Vector2(15, 15)
]
var ItemPos_2_Array = [
	Vector2( - 5, 0),
	Vector2(15, 0)
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
			var _Func = _OBJ.FuncType
			if _Func in ["SodaCan", "DrinkCup", "SuperCup"]:
				get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_2)
		else:

			get_node("But/A").show()
	else:
		get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
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
	call_init("Box_M_Paper")
	BuyDay = GameLogic.cur_Day
	HoldBut.hide()
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("DayStart", self, "_create"):
		var _con = GameLogic.connect("DayStart", self, "_create")

	Audio_Open = GameLogic.Audio.return_Effect("开纸箱")

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

				call_create_num(_INFO.ItemNum)

func call_load(_info):

	_INFO = _info
	_SELFID = int(_info.NAME)
	self.name = str(_info.NAME)
	ItemName = _info.ItemName
	.call_Ins_Save(_SELFID)
	if _info.has("FreshType"):
		_FreshType = _info.FreshType
	if GameLogic.Config.ItemConfig.has(ItemName):
		var _CONFIG = GameLogic.Config.ItemConfig[ItemName]
		Type = _CONFIG.FuncType
		TypeName = _CONFIG.FuncTypeNum
		BuyNum = int(_CONFIG.BuyNum)
		if _FreshType == 0:
			_FreshType = int(_CONFIG.FreshType)

	elif GameLogic.Config.DeviceConfig.has(ItemName):
		var _CONFIG = GameLogic.Config.DeviceConfig[ItemName]
		Type = _CONFIG.FuncType
		TypeName = _CONFIG.FuncTypeNum
		BuyNum = 1
	if _info.has("Type"):
		Type = _info.Type


	if _info.IsOpen:
		IsOpen = true
		if not Type in ["Fruit", "SodaCan"]:
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
	elif Type in ["Fruit", "SodaCan", "SuperCup"]:
		IsOpen = true
		BoxAni.play("open")
		_X_But_Set()
		TypeAni.play("Fruit")
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
		ItemName = _OBJ.TypeStr
		TypeName = _OBJ.FuncTypePara
		_ObjShow_init()
	But_Switch(true, _Player)
	_ItemNameDic_Check()
	if _OBJ.has_method("But_Switch"):
		_OBJ.But_Switch(false, _Player)
var PutOnPos_Array: Array
func _set_pos(_Fruit):
	PutOnPos_Array.clear()

	match int(_Fruit.Weight):
		20:
			PutOnPos_Array = [Vector2( - 30, - 20),
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
				Vector2(30, 20)]
		12:
			PutOnPos_Array = [
				Vector2( - 30, - 20),
				Vector2( - 10, - 20),
				Vector2(10, - 20),
				Vector2(30, - 20),
				Vector2( - 30, 0),
				Vector2( - 10, 0),
				Vector2(10, 0),
				Vector2(30, 0),
				Vector2( - 30, 20),
				Vector2( - 10, 20),
				Vector2(10, 20),
				Vector2(30, 20)]
		10:
			PutOnPos_Array = [
				Vector2( - 10, - 20),
				Vector2(10, - 20),
				Vector2(30, - 20),
				Vector2( - 30, 0),
				Vector2( - 10, 0),
				Vector2(10, 0),
				Vector2(30, 0),
				Vector2( - 30, 20),
				Vector2( - 10, 20),
				Vector2(10, 20)]
		6:
			PutOnPos_Array = [
				Vector2( - 17, - 10),
				Vector2(17, - 10),
				Vector2( - 17, 0),
				Vector2(17, 0),
				Vector2( - 17, 10),
				Vector2(17, 10)]
		5:
			PutOnPos_Array = [
				Vector2(0, - 20),
				Vector2(0, - 10),
				Vector2(0, 0),
				Vector2(0, 10),
				Vector2(0, 20)
			]
			if ItemName in ["甘蔗"]:
				PutOnPos_Array = [
					Vector2(0, - 20),
					Vector2(0, - 10),
					Vector2(0, 0),
					Vector2(0, 10),
					Vector2(0, 20)
				]
		4:
			PutOnPos_Array = [
				Vector2( - 15, - 5),
				Vector2(15, - 5),
				Vector2( - 15, 5),
				Vector2(15, 5)]
		2:
			PutOnPos_Array = [
				Vector2( - 5, 0),
				Vector2(15, 0)]
		_:
			pass
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
				if _HoldObj.TypeStr in ["bag_BlackCookie"] and not _HoldObj.CanUse:
					pass
				elif _HoldObj.get("IsOpen") or _HoldObj.get("Used"):
					return

				var _NUM = ItemNode.get_child_count()
				_set_pos(_HoldObj)
				if _NUM >= PutOnPos_Array.size() and PutOnPos_Array.size() > 0:
					return
				if (TypeName == _HoldObj.FuncTypePara and not IsTrash) or not ItemOBJ_Array.size():
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

				return

			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)

			if Type == "Fruit" and Type == _HoldObj.get("FuncType"):
				_set_pos(_HoldObj)

				var _CHECK: bool = false
				if not ItemOBJ_Array.size():
					_CHECK = true
				elif TypeName == _HoldObj.FuncTypePara and ItemOBJ_Array.size() < PutOnPos_Array.size():
					_CHECK = true
				if _CHECK:
					var _PosArray: Array
					for _Pos in PutOnPos_Array:
						_PosArray.append(_Pos)
					var _POS = _PosArray[ItemNode.get_child_count()]
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _OBJPATH = _OBJ.get_path()
						var _PLAYERPATH = _Player.get_path()
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_PutIn_puppet", [_OBJPATH, _PLAYERPATH, _POS])
					_OBJ.position = _POS
					_OBJ.get_parent().remove_child(_OBJ)
					ItemNode.add_child(_OBJ)
					if not ItemOBJ_Array.size():
						HasItem = true
						TypeName = _HoldObj.FuncTypePara
						ItemName = _HoldObj.FuncTypePara
					ItemOBJ_Array.append(_OBJ)
					_Player.Stat.call_carry_off()
					if _OBJ.has_method("call_Info_Switch"):
						_OBJ.call_Info_Switch(false)

					if _OBJ.has_method("call_Defrost_Switch"):
						_OBJ.call_Defrost_Switch(1)
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
				if Type != "Fruit" and _HoldObj.get("FuncType") != "Fruit":
					var _HOLDTYPE = _HoldObj.FuncTypePara
					if TypeName == _HOLDTYPE or TypeName == "":
						if _HoldObj.TypeStr in ["bag_BlackCookie"] and not _HoldObj.CanUse:
							pass
						elif _HoldObj.get("IsOpen") or _HoldObj.get("Used"):
							return
						var _NUM = ItemNode.get_child_count()
						if _NUM >= int(BuyNum):
							return
						var _PosArray: Array
						match int(BuyNum):
							20:
								for _Pos in ItemPos_20_Array:
									_PosArray.append(_Pos)
							12:
								for _Pos in ItemPos_12_Array:
									_PosArray.append(_Pos)
							10:
								for _Pos in ItemPos_10_Array:
									_PosArray.append(_Pos)
							6:
								for _Pos in ItemPos_6_Array:
									_PosArray.append(_Pos)
							5:
								for _Pos in ItemPos_5_Array:
									_PosArray.append(_Pos)
							4:
								for _Pos in ItemPos_4_Array:
									_PosArray.append(_Pos)
							2:
								for _Pos in ItemPos_2_Array:
									_PosArray.append(_Pos)
						var _POS = _PosArray[ItemNode.get_child_count()]
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _OBJPATH = _OBJ.get_path()
							var _PLAYERPATH = _Player.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_PutIn_puppet", [_OBJPATH, _PLAYERPATH, _POS])
						_OBJ.position = _POS
						_OBJ.get_parent().remove_child(_OBJ)
						ItemNode.add_child(_OBJ)
						if not ItemOBJ_Array.size():
							HasItem = true
							ItemName = _HoldObj.TypeStr
							TypeName = _HoldObj.FuncTypePara
							_ObjShow_init()
						ItemOBJ_Array.append(_OBJ)
						_Player.Stat.call_carry_off()
						call_PutIn_Audio()
						if _OBJ.has_method("call_Info_Switch"):
							_OBJ.call_Info_Switch(false)
						if _OBJ.has_method("But_Switch"):
							_OBJ.But_Switch(false, _Player)
						But_Switch(true, _Player)
						_ItemNameDic_Check()
						return "放"
func call_PutIn_Audio():
	var _AUDIO = GameLogic.Audio.return_Effect("放下箱子")
	_AUDIO.play(0)



func _ObjShow_init():

	if IconAni.has_animation(ItemName):
		IconAni.play(ItemName)
	elif IconAni.has_animation(TypeName):
		IconAni.play(TypeName)
	else:
		IconAni.play("init")

func call_puppet_create(_ItemName, _CurNum, _CurItemNameDic: Dictionary):
	if not GameLogic.Config.ItemConfig.has(ItemName) and not GameLogic.Config.DeviceConfig.has(ItemName):
		return

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
		12:
			for _Pos in ItemPos_12_Array:
				_PosArray.append(_Pos)
		10:
			for _Pos in ItemPos_10_Array:
				_PosArray.append(_Pos)
		6:
			for _Pos in ItemPos_6_Array:
				_PosArray.append(_Pos)
		5:
			for _Pos in ItemPos_5_Array:
				_PosArray.append(_Pos)
		4:
			for _Pos in ItemPos_4_Array:
				_PosArray.append(_Pos)
		2:
			for _Pos in ItemPos_2_Array:
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
			var IsFrozen: bool
			match ItemName:
				"DrinkCup_S":
					_ItemName = "DrinkCup_Group_S"
				"DrinkCup_M":
					_ItemName = "DrinkCup_Group_M"
				"DrinkCup_L":
					_ItemName = "DrinkCup_Group_L"
				_:
					if GameLogic.Config.ItemConfig.has(ItemName):
						var _ITEMINFO = GameLogic.Config.ItemConfig[ItemName]
						var _FRESHTYPE: int = int(_ITEMINFO.FreshType)
						if _FRESHTYPE in [5]:
							IsFrozen = true
					_ItemName = ItemName
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
			var _Obj = _TSCN.instance()
			_Obj._SELFID = int(_ObjName)
			_Obj.name = str(_Obj._SELFID)
			_Obj.position = _pos
			ItemNode.add_child(_Obj)
			_Obj.call_load_TSCN(_ItemName)
			ItemOBJ_Array.append(_Obj)
			if IsFrozen:
				if _Obj.has_method("call_Frozen_init"):
					_Obj.call_Frozen_init()
func call_create_num(_Num):
	if not GameLogic.Config.ItemConfig.has(ItemName) and not GameLogic.Config.DeviceConfig.has(ItemName):
		return

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
				if ItemName in ["胡萝卜"]:
					_Pos.y -= 8
				_PosArray.append(_Pos)
		12:
			for _Pos in ItemPos_12_Array:
				if ItemName in ["黄瓜"]:
					_Pos.x += 10
				_PosArray.append(_Pos)
		10:
			for _Pos in ItemPos_10_Array:
				if ItemName in ["西芹"]:
					_Pos.x += 10
				_PosArray.append(_Pos)
		6:
			for _Pos in ItemPos_6_Array:
				_PosArray.append(_Pos)
		5:
			for _Pos in ItemPos_5_Array:
				_PosArray.append(_Pos)
		4:
			for _Pos in ItemPos_4_Array:
				_PosArray.append(_Pos)
		2:
			for _Pos in ItemPos_2_Array:
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
			var IsFrozen: bool
			match ItemName:

				"DrinkCup_S":
					_ItemName = "DrinkCup_Group_S"
				"DrinkCup_M":
					_ItemName = "DrinkCup_Group_M"
				"DrinkCup_L":
					_ItemName = "DrinkCup_Group_L"
				_:
					if GameLogic.Config.ItemConfig.has(ItemName):
						var _ITEMINFO = GameLogic.Config.ItemConfig[ItemName]
						var _FRESHTYPE: int = int(_ITEMINFO.FreshType)
						if _FRESHTYPE in [5]:
							IsFrozen = true
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
			if IsFrozen:
				if _Obj.has_method("call_Frozen_init"):
					_Obj.call_Frozen_init()
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

func call_pup_pop(_FRUITID):
	var _Fruit = SteamLogic.OBJECT_DIC[_FRUITID]
	if ItemOBJ_Array.has(_Fruit):
		ItemOBJ_Array.erase(_Fruit)
	if not ItemOBJ_Array:
		HasItem = false
	_ItemNameDic_Check()
func call_PickFruitInCup(_ButID, _CupObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
			return
		- 1:
			But_Switch(true, _Player)
			return
	if Type in ["SodaCan", "SuperCup"]:
		if is_instance_valid(_CupObj):
			if _CupObj.FuncType in ["SodaCan", "SuperCup"]:
				if _CupObj.Liquid_Count > 0 or _CupObj.Extra_1 != "" or _CupObj.Condiment_1 != "" or _CupObj.Top != "" or _CupObj.Hang != "":
					return
		return call_Fruit_PutIn(_ButID, _CupObj, _Player)

	if Type in ["Fruit"] and HasItem:
		if not ItemOBJ_Array.size():
			return
		var _Item = ItemOBJ_Array.back()

		if not is_instance_valid(_Item):
			return
		if _Item.has_method("call_WaterInDrinkCup"):
			if _ButID >= 0:
				var _CHECK = GameLogic.Device.return_CanUse_bool(_Player)
				if _CHECK:
					return
			if _ButID == 0:
				var _TYPE = _Item.FuncTypePara
				match _TYPE:
					"桑葚", "草莓", "西柚块", "杨梅块", "凤梨块", "葡萄块":
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return
						match _CupObj.TYPE:
							"DrinkCup_S", "BeerCup_S":
								if _CupObj.Extra_1 != "":
									return
							"DrinkCup_M", "BeerCup_M":
								if _CupObj.Extra_2 != "":
									return
							"DrinkCup_L", "BeerCup_L":
								if _CupObj.Extra_3 != "":
									return
							"SuperCup_M":
								if _CupObj.Extra_5 != "":
									return
						var _R: bool = false
						if _CupObj.Extra_1 == "":
							_CupObj.Extra_1 = _TYPE
							_CupObj.call_add_extra()
							_R = true
						elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 == "" and _CupObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M", "BeerCup_M", "BeerCup_L"]:
							_CupObj.Extra_2 = _TYPE
							_CupObj.call_add_extra()
							_R = true
						elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 != "" and _CupObj.Extra_3 == "" and _CupObj.TYPE in ["DrinkCup_L", "SuperCup_M", "BeerCup_L"]:
							_CupObj.Extra_3 = _TYPE
							_CupObj.call_add_extra()
							_R = true
						elif _CupObj.Extra_3 != "" and _CupObj.get("Extra_4") == "" and _CupObj.TYPE in ["SuperCup_M"]:
							_CupObj.Extra_4 = _TYPE
							_CupObj.call_add_extra()
							_R = true
						elif _CupObj.get("Extra_4") != "" and _CupObj.get("Extra_5") == "" and _CupObj.TYPE in ["SuperCup_M"]:
							_CupObj.Extra_5 = _TYPE
							_CupObj.call_add_extra()
							_R = true
						else:
							return
						if _R:
							var _Fruit = ItemOBJ_Array.pop_back()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _ID = _Fruit.get("_SELFID")
								SteamLogic.call_puppet_id_sync(_SELFID, "call_pup_pop", [_ID])
							_Fruit.call_del()
							var _AUDIO = GameLogic.Audio.return_Effect("气泡")
							_AUDIO.play(0)
							if not ItemOBJ_Array:
								HasItem = false
							_ItemNameDic_Check()

							return "加水果"
					"百香果", "鸡蛋":
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return
						match _CupObj.TYPE:
							"DrinkCup_S", "BeerCup_S":
								if _CupObj.Extra_1 != "":
									return
							"DrinkCup_M", "BeerCup_M":
								if _CupObj.Extra_2 != "":
									return
							"DrinkCup_L", "BeerCup_L":
								if _CupObj.Extra_3 != "":
									return
							"SuperCup_M":
								if _CupObj.Extra_5 != "":
									return

						var _Fruit = ItemOBJ_Array.back()
						var _R = _Fruit.return_ExtraInDrinkCup(_ButID, _CupObj, _Player)
						if _R:
							if ItemOBJ_Array.has(_Fruit):
								ItemOBJ_Array.erase(_Fruit)
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _ID = _Fruit.get("_SELFID")
								SteamLogic.call_puppet_id_sync(_SELFID, "call_pup_pop", [_ID])
						if not ItemOBJ_Array:
							HasItem = false
						_ItemNameDic_Check()

						return "加水果"
					_:
						if not _TYPE in ["柠檬", "橙子"]:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
							return
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return

						if _CupObj.Liquid_Count >= _CupObj.Liquid_Max:
							if _CupObj.LIQUID_DIR.has("啤酒泡"):
								if _CupObj.LIQUID_DIR["啤酒泡"] == 0:
									return
							else:
								return
						var _Fruit = ItemOBJ_Array.back()
						var _R = _Fruit.return_ExtraInDrinkCup(_ButID, _CupObj, _Player)
						if _R:
							if ItemOBJ_Array.has(_Fruit):
								ItemOBJ_Array.erase(_Fruit)
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _ID = _Fruit.get("_SELFID")
								SteamLogic.call_puppet_id_sync(_SELFID, "call_pup_pop", [_ID])

						if not ItemOBJ_Array:
							HasItem = false
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
			TypeName = ""
			ItemName = ""
			_ObjShow_init()
		But_Switch(false, _Player)
		if _Item.has_method("call_Defrost_Switch"):
			_Item.call_Defrost_Switch(0)
		call_Fruit_PutIn( - 1, null, _Player)
		_ItemNameDic_Check()
		return "箱中取"
	else:
		if not IsTrash:
			call_ObjTurnTrashbag(5)
			return "拆箱"
		else:
			return


func call_ObjTurnTrash_puppet(_IsSell, _MONEY: int = 0):
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
		var _Money = _MONEY
		GameLogic.call_MoneyOther_Change(_Money, GameLogic.HomeMoneyKey)

		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_EffectNode.add_child(_PayEffect)
		_PayEffect.call_init(_Money, _Money, 0, false, false, false, false)
		var _TableNode = _parentNode.get_parent()
		if _TableNode.has_method("call_OnTable"):
			_TableNode.call_OnTable(null)

		GameLogic.call_StatisticsData_Set("Count_DelBox", null, 1)
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

		GameLogic.call_StatisticsData_Set("Count_DelBox", null, 1)
		get_node("But/X").hide()
func call_ObjTurnTrashbag(_weight):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Effect = GameLogic.TSCNLoad.SmokeEffect_TSCN
	var _EffectNode = _Effect.instance()
	_EffectNode.position = self.global_position
	var _Money = 0
	if GameLogic.Achievement.cur_EquipList.has("卖纸箱") and not GameLogic.SPECIALLEVEL_Int:
		_Money = 5
		if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
			_Money = int(float(_Money) * 1.5)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_ObjTurnTrash_puppet", [true, _Money])
		var _parentNode = get_parent()
		_parentNode.remove_child(self)
		if _parentNode.name in ["Devices", "Items"]:
			_parentNode.get_parent().add_child(_EffectNode)
		else:
			if is_instance_valid(GameLogic.Staff.LevelNode):
				GameLogic.Staff.LevelNode.add_child(_EffectNode)

		GameLogic.call_MoneyOther_Change(_Money, GameLogic.HomeMoneyKey)

		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_EffectNode.add_child(_PayEffect)
		_PayEffect.call_init(_Money, _Money, 0, false, false, false, false)
		var _TableNode = _parentNode.get_parent()
		if _TableNode.has_method("call_OnTable"):
			_TableNode.call_OnTable(null)
		GameLogic.call_StatisticsData_Set("Count_DelBox", null, 1)

		Audio_Open.play(0)
		self.call_del()
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
		SteamLogic.call_puppet_id_sync(_SELFID, "call_ObjTurnTrash_puppet", [false, int(_Money)])





	GameLogic.call_StatisticsData_Set("Count_DelBox", null, 1)
	get_node("But/X").hide()

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
func _Timer_End():
	if get_node("Label/Ani").assigned_animation != "hide":
		get_node("Label/Ani").play("hide")
	CanPass = false
func return_MoveInBoxList(_Num: int):

	if ItemOBJ_Array.size():
		var _returnList: Array
		var _CurNum: int

		for _i in _Num:
			if ItemOBJ_Array.size():
				var _Obj = ItemOBJ_Array.pop_back()
				if is_instance_valid(_Obj):
					if ItemNode.has_node(_Obj.get_path()):
						ItemNode.remove_child(_Obj)
						_returnList.append(_Obj)
			else:
				break
		if not ItemOBJ_Array.size():
			ItemName = ""

		return _returnList

func call_Check(_Player):
	if not ItemOBJ_Array.size():
		ItemName = ""
		_Player.Stat.call_carry_on(1)
