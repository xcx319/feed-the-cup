extends Node2D
class_name Head_Object

onready var TypeStr: String
var BuyNum: int
var SellCount: int = 0
var IsItem: bool

var DeviceID: int
var Weight: int
var Holding: bool
var Holder
var CanFraud: bool
var Sell: int
var CanDrag: bool
var CanMove: bool
var CanLift: bool
var CarrySpeed: float
var NeedAssemble: bool
var NeedDisassemble: bool
var CanLiquid: bool
var HasTable: bool
var FuncType
var FuncTypePara
var cur_ButInfo
var CanGround: bool
var CanLayout: bool = true
var NeedPush: bool

var CanPick
var OnTableObj
var OnTable_InstanceId: int
onready var ButInfo_Node
var SavedNode
var IsOverlap: bool
var FreshType: int
var AudioPut: String = "放下"
var _SELFID: int
var GearList: Array

var velocity: Vector2
func _item_move():
	if GearList:
		var _GEAR = GearList.back()
		velocity = _GEAR.Direction
		if velocity.x == 0:
			if self.global_position.x < _GEAR.global_position.x - 5:
				velocity.x = _GEAR.global_position.x - self.global_position.x
			elif self.global_position.x > _GEAR.global_position.x + 5:
				velocity.x = _GEAR.global_position.x - self.global_position.x
		elif velocity.y == 0:
				if self.global_position.y < _GEAR.global_position.y - 5:
					velocity.y = _GEAR.global_position.y - self.global_position.y
				elif self.global_position.y > _GEAR.global_position.y + 5:
					velocity.y = _GEAR.global_position.y - self.global_position.y

		set_physics_process(true)

	else:

		set_physics_process(false)
		velocity = Vector2.ZERO
func _physics_process(_delta):

	if not get_tree().paused:
		self.position = self.position.move_toward(self.position + velocity, 118 * _delta)
func But_hide(_bool, _Player):

	var _playerID: int = _Player.cur_Player
	if has_node("But"):
		var ButList = get_node("But").get_children()
		for i in ButList.size():
			var _But = ButList[i]
			match _bool:
				true:
					_But.call_player_in(_playerID)
				false:
					_But.call_player_hide(_playerID)
func But_Switch(_bool, _Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.IsStaff:
		return
	if is_instance_valid(get_parent()):
		if get_parent().name in ["ObjNode"]:
			if _Player.cur_RayObj != get_parent().get_parent():
				_bool = false
	var _playerID: int = _Player.cur_Player
	if has_node("But"):
		var ButList = get_node("But").get_children()
		if is_instance_valid(get_parent()):
			var _Name = get_parent().name
			if _Name == "Weapon_note":

				for i in ButList.size():
					var _But = ButList[i]
					_But.call_clean()
			for i in ButList.size():
				var _But = ButList[i]
				match _bool:
					true:
						_But.call_player_in(_playerID)
					false:
						_But.call_player_out(_playerID)
func _ready() -> void :
	if self.has_node("SavedNode"):
		SavedNode = get_node("SavedNode")
	if self.has_node("Control_Info"):
		ButInfo_Node = get_node("Control_Info")

func call_del():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		printerr("联机时提前删除，请检查")

		return
	if GameLogic.cur_Item_List.has(TypeStr):
		GameLogic.cur_Item_List[TypeStr] -= 1
		if GameLogic.cur_Item_List[TypeStr] < 0:
			GameLogic.cur_Item_List[TypeStr] = 0
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_del_puppet", [GameLogic.cur_Item_List])

	if TypeStr in ["DrinkCup_S"]:
		GameLogic.Tutorial.NeedSell = false

	self.queue_free()
func call_del_puppet(_LIST):
	if TypeStr in ["WaterTank"]:
		return

	var _x = _SELFID
	GameLogic.cur_Item_List = _LIST
	self.queue_free()
func call_puppet_del():
	self.queue_free()
func call_init(_TypeStr):

	if TypeStr == _TypeStr:
		pass
	TypeStr = _TypeStr
	var _Stat

	if TypeStr in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
		var _TYPE: String
		match TypeStr:
			"BeerCup_S":
				_TYPE = "DrinkCup_S"
			"BeerCup_M":
				_TYPE = "DrinkCup_M"
			"BeerCup_L":
				_TYPE = "DrinkCup_L"
		if GameLogic.Config.ItemConfig.has(_TYPE):
			IsItem = true
			_Stat = GameLogic.Config.ItemConfig[_TYPE]
			if GameLogic.cur_Item_List.has(_TYPE):
				GameLogic.cur_Item_List[_TYPE] += 1
			else:
				GameLogic.cur_Item_List[_TYPE] = 1
			DeviceID = GameLogic.cur_Item_List[_TYPE]
	elif GameLogic.Config.ItemConfig.has(TypeStr):
		IsItem = true
		_Stat = GameLogic.Config.ItemConfig[TypeStr]
		if GameLogic.cur_Item_List.has(TypeStr):
			GameLogic.cur_Item_List[TypeStr] += 1
		else:
			GameLogic.cur_Item_List[TypeStr] = 1
		DeviceID = GameLogic.cur_Item_List[TypeStr]

	elif GameLogic.Config.DeviceConfig.has(TypeStr):
		_Stat = GameLogic.Config.DeviceConfig[TypeStr]


		if GameLogic.cur_Item_List.has(TypeStr):
			GameLogic.cur_Item_List[TypeStr] += 1
		else:
			GameLogic.cur_Item_List[TypeStr] = 1
		DeviceID = GameLogic.cur_Item_List[TypeStr]

	if not _Stat:
		return

	if _Stat.has("CanLayout"):
		if _Stat.CanLayout:
			CanLayout = bool(_Stat.CanLayout)
	if _Stat.has("NeedPush"):
		if _Stat.NeedPush:
			NeedPush = bool(_Stat.NeedPush)
	if _Stat.has("AudioPut"):
		if TypeStr in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
			AudioPut = "放下瓶子"
		elif _Stat.AudioPut:
			AudioPut = str(_Stat.AudioPut)
	if _Stat.has("FreshType"):
		FreshType = int(_Stat.FreshType)

	if _Stat.has("CanGround"):
		CanGround = bool(_Stat["CanGround"])
	if _Stat.has("CanMove"):

		CanMove = bool(_Stat["CanMove"])
	if _Stat.has("CanFraud"):
		CanFraud = bool(_Stat["CanFraud"])
	if _Stat.has("Sell"):
		Sell = int(_Stat["Sell"])
	if _Stat.has("FuncType"):
		FuncType = str(_Stat["FuncType"])
	if _Stat.has("FuncTypeNum"):
		FuncTypePara = _Stat["FuncTypeNum"]
	if _Stat.has("CanLiquid"):
		CanLiquid = bool(_Stat["CanLiquid"])
	if _Stat.has("HasTable"):
		HasTable = bool(_Stat["HasTable"])

	if _Stat.has("Weight"):
		Weight = int(_Stat.Weight)

	if _Stat.has("CarrySpeed"):
		CarrySpeed = float(_Stat.CarrySpeed)

func call_Collision_Switch(_Switch: bool):
	if has_node("CollisionShape2D"):
		var _col = get_node("CollisionShape2D")
		_col.disabled = not _Switch
	if has_node("Area2D/CollisionShape2D"):
		var _col = get_node("Area2D/CollisionShape2D")
		_col.disabled = not _Switch

func call_pickup_by(_Player, _DevObj):



	call_Collision_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _DevObj)

func call_Ins_Save(_InsID: int):
	SteamLogic.OBJECT_DIC[_InsID] = self

func call_Collision_set():
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func call_Open_Money(_PRICE: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _MONEY: int = 0
	var _RAND: int = GameLogic.return_RANDOM() % 4
	var _CHECK: bool
	if GameLogic.cur_Rewards.has("开盖中奖"):
		if _RAND == 0:
			_CHECK = true
	elif GameLogic.cur_Rewards.has("开盖中奖+"):
		if _RAND > 0:
			_CHECK = true
	if _CHECK:
		var _CHECKRAND = GameLogic.return_RANDOM() % 10
		match _CHECKRAND:
			0, 1, 2, 3:
				_MONEY = int(float(_PRICE) / 10 * GameLogic.return_Multiplayer())

			4, 5, 6:
				_MONEY = int(float(_PRICE) / 2 * GameLogic.return_Multiplayer())

			7, 8:
				_MONEY = int(_PRICE * 2 * GameLogic.return_Multiplayer())

			9:
				_MONEY = int(_PRICE * 20 * GameLogic.return_Multiplayer())

		if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
			_MONEY = int(float(_MONEY) * 1.5)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_MONEY_Effect", [_MONEY])
		GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

		call_MONEY_Effect(_MONEY)

func call_MONEY_Effect(_MONEY):
	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = self.global_position
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)

func call_Extra():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _CHECK: bool = false
	var _MONEY: int = 0
	if GameLogic.cur_Rewards.has("意外收获"):
		_MONEY = int(GameLogic.cur_Combo * 1)
		_CHECK = true
	elif GameLogic.cur_Rewards.has("意外收获+"):
		_MONEY = int(GameLogic.cur_Combo * 3)
		_CHECK = true
	if _CHECK:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_MONEY_Effect", [_MONEY])
		GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

		call_MONEY_Effect(_MONEY)


func return_Sell():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not CanFraud:
		return


	var _CHECK: bool = false
	var _MONEY: int = 0

	if GameLogic.cur_Rewards.has("碰瓷"):
		_MONEY = int(Sell * 0.4 * GameLogic.return_Multiplayer())
		_CHECK = true
	elif GameLogic.cur_Rewards.has("碰瓷+"):
		_MONEY = int(Sell * 1.2 * GameLogic.return_Multiplayer())

		_CHECK = true
	if _CHECK:
		SellCount += 1
		if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
			_MONEY = int(float(_MONEY) * 1.5)
		GameLogic.call_pressure("SellItem")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_MONEY_Effect", [_MONEY])
		GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

		call_MONEY_Effect(_MONEY)

		if SellCount > 5:
			return true
	return
func return_MoneyBool(_body):
	if _body.has_method("_PlayerNode"):
		return false
	if _body.get("NPCTYPE"):
		return false
	elif _body.get("SpecialType") in [1, - 1]:
		return false
	if CanFraud:

		return return_Sell()

	return false
