extends RigidBody2D

var path: = PoolVector2Array()
var _distance = 10
var _FinalPos = Vector2.ZERO
var picking_time = 0
var _selfTypeID: String
var _old_pos = Vector2.ZERO
var IsTouched: bool
var IsPasser: bool
var IsCustomer: bool
var IsCourier: bool
var NPCTYPE: int = 0
var SpecialType: int = 0
var IsWaiting: bool
var PickUpID: int
var SpecialSave: int = - 1
var WINECanTouch: bool = false
var OrderWait_bool: bool
var LineTime: float
var IsPickUp: bool
var IsFinish: bool

var PerfectPoint: int
var NormalPoint: int
var Point: int
var PointType: int = - 1
var PickCheck: Dictionary
var cur_Touch_Count: int
var cur_Touch_List: Array
var SeatOBJ = null
var IsSit: bool

var _Path_IsFinish: bool
var target: Vector2
var _path2D_array: Array
var WayPoint_array: Array
var _checktime: float
var _FinalTarget: Vector2
var _PickUpDev
var HoldObj = null

onready var ThinkingAni = get_node("Thinking/ThinkingAni")
onready var ThinkingTimer = get_node("Thinking/ThinkingTimer")

onready var HappyAni = get_node("Happy/HappyAni")
var LineNPC
var WaitingReset: bool
var _Is_Customer: bool
var PosSave: Vector2

var WaitTime: float
var ReOrder: bool
var SeatRat: float

var Order_Extra_Base: bool

var Order_Extra_Max: bool

var Order_HOT: bool
var Order_NORMAL: bool
var Order_COLD: bool
var Order_S: bool
var Order_M: bool
var Order_L: bool
var Order_Sugar
var Order_Personal
var IceBreakType: int = 0

var NoOrder_TYPE: bool
var NoOrder_Cup: bool
var NoOrder_Celcius: bool
var NoOrder_Suger: bool

var OrderName: String
var PopularMult: float = 1
var Rank: int
var behavior = BEHAVIOR.PASSER
enum BEHAVIOR{
	LEAVE
	MOVE
	WAIT
	ORDER
	LINE
	CUSTOMER
	PASSER
	DELIVER
	PICKUP
	STEAL
	CLEAN
	WORKWAIT
	PLATE
}

var _PRESSURE_1: bool
var NOPRESSURE: bool
var BONUSDIC: Dictionary = {"Run": 0, "Panda": 0}

var CheckPos: Vector2
onready var CheckTimer = $LogicNode / CollisionLogicTimer
onready var EndTimer = get_node("LogicNode/CollisionLogicEndTimer")
onready var WaitingTimer = get_node("LogicNode/WaitingTimer")
onready var LineWaitingTimer = get_node("LogicNode/LineWaitingTimer")
onready var OrderTimer = get_node("LogicNode/OrderTimer")
onready var OrderAngryTimer = get_node("LogicNode/OrderAngryTimer")
onready var StandTimer = get_node("LogicNode/StandTimer")
onready var LogicTimer = get_node("LogicNode/LogicTimer")
onready var Avatar
onready var AvatarNode = get_node("Player")
onready var LevelNode = get_tree().get_root().get_node("Level")
onready var Stat = get_node("LogicNode/Stat")
onready var Con = get_node("LogicNode/Control")
onready var Ray2D = get_node("RayCast2D")
onready var ItemYSort = LevelNode.get_node("YSort/Items")

onready var InfoLabel = get_node("Thinking/Ani/Label")
var Audio_NoOrder
var _OBJ_Block
var KnockBack: bool
var IsService: bool
var ChargeNumTotal: int
var ServiceList: Array

var _Pay_Array: Array
var TipBonus: int = 0

var CRIBONUS: int = 0
var IsPayLine: bool = false
var SugarType: int
var HasIce: bool = false
var ExtraList: Array
var OrderAngryBool: bool = false
var _WAITPAYNUM: int = 0
var _PASSNUM: int = 0

signal StatChange

var _COMBO: int = 0
var _CANCOMBO: bool = true
func call_StatChange():
	emit_signal("StatChange")
func _ready() -> void :



	set_physics_process(true)
	_checktime = 0
	target = self.position
	Audio_NoOrder = GameLogic.Audio.return_Effect("未点单")
	Stat.call_NPC()
	if not GameLogic.is_connected("NPCLOGIC", self, "call_NPCLOGIC"):
		var _r = GameLogic.connect("NPCLOGIC", self, "call_NPCLOGIC")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():

	if is_instance_valid(HoldObj):
		if HoldObj.get("TypeStr") in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
			HoldObj.call_dirty()
			_thief_putDown()
func call_NPCLOGIC(_ID, _TYPE, _VALUE):
	match _TYPE:
		1:

			if IsCustomer and BONUSDIC["Panda"] == 0 and SpecialType >= 0:
				var _POS = self.global_position
				if _VALUE.distance_to(_POS) <= 200:
					BONUSDIC["Panda"] = 2

					var _EFFECT_TSCN = load("res://TscnAndGd/Effects/PandaBuff.tscn")
					var _EffectNode = _EFFECT_TSCN.instance()
					Avatar.add_child(_EffectNode)
					var _AUDIO = GameLogic.Audio.return_Effect("QTEGOOD")
					_AUDIO.play(0)
func call_Bonus(_TYPE: int):
	BONUSDIC["Run"] = _TYPE

	get_node("Thinking/HBox/1/Mood/MoodAni").play("1")

func call_courier_init():

	var _AvatarName = "DeliverCar"
	_Avatar_init(_AvatarName)

var _NPCINFO: Dictionary
var QTERate: int
var QTEType: int
func call_personality_init(_NPCID, _PERSONALITY: String = ""):
	if Avatar == null:
		_selfTypeID = _NPCID
		_NPCINFO = GameLogic.Config.NPCConfig[_selfTypeID]
		Stat.BaseSpeed = int(_NPCINFO.BaseSpeed)
		mass = float(_NPCINFO.Mass)
		QTERate = int(_NPCINFO.QTERate)
		QTEType = int(_NPCINFO.QTEType)

		var _AvatarName = _NPCINFO.Avatar
		var _AvatarID = _NPCINFO.PersonalityAniID
		SeatRat = float(_NPCINFO.SeatRat)
		_Avatar_init(_AvatarName)
		if _PERSONALITY != "":
			Avatar.call_personality_init(_PERSONALITY)
		else:
			Avatar.call_personality_init(_AvatarID)
		if _selfTypeID in ["BigBottle1_1", "BigBottle1_2", "BigBottle1_3",
		"BigBottle2_1", "BigBottle2_2", "BigBottle2_3",
		"BigBottle3_1", "BigBottle3_2", "BigBottle3_3",
		"BigBottle4_1", "BigBottle4_2", "BigBottle4_3",
		"BigBottle5_1", "BigBottle5_2", "BigBottle5_3",
		]:
			SpecialType = 6
		elif _selfTypeID in ["GlassBottlehomeless"]:
			SpecialType = 8

	if NOPRESSURE:
		var _EFFECT_TSCN = load("res://TscnAndGd/Effects/NoPressureBuff.tscn")
		var _EffectNode = _EFFECT_TSCN.instance()
		Avatar.add_child(_EffectNode)

func call_order(_OrderID, _TYPE: int = 0):
	if SpecialType in [6]:
		if PickUpID == 0:
			SpecialSave = _OrderID
	PickUpID = _OrderID

	OrderAngryTimer.stop()
	$LogicNode / TYPEAni.play("Order")
	call_OrderLogic(_TYPE)

func call_pup_order(_OID, _TYPE):
	PickUpID = _OID

	OrderAngryTimer.stop()
	$LogicNode / TYPEAni.play("Order")
	call_OrderLogic(_TYPE)
func call_OrderLogic(_TYPE):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_pup_order", [PickUpID, _TYPE])

	if _TYPE == 1:
		if GameLogic.cur_Rewards.has("消灾替身"):
			if not NOPRESSURE:
				var _RAND = GameLogic.return_randi() % 2
				if _RAND == 0:
					NOPRESSURE = true
					var _EFFECT_TSCN = load("res://TscnAndGd/Effects/NoPressureBuff.tscn")
					var _EffectNode = _EFFECT_TSCN.instance()
					Avatar.add_child(_EffectNode)
					GameLogic.call_Info(1, "消灾替身")
	if SpecialType == 4:
		if PickUpID != 0:
			$Thinking / Ani / Thick / Label.text = str(PickUpID)
			ThinkingAni.play("uper")

func _Avatar_init(_AvatarName):
	var _AvatarTSCN
	match _AvatarName:
		"TeaCup":
			_AvatarTSCN = GameLogic.NPC.TeaCup.instance()
		"MarkCup":
			_AvatarTSCN = GameLogic.NPC.MarkCup.instance()
		"PaperCup":
			_AvatarTSCN = GameLogic.NPC.PaperCup.instance()
		"BigBottle":
			_AvatarTSCN = GameLogic.NPC.BigBottle.instance()
		"BritishCup":
			_AvatarTSCN = GameLogic.NPC.BritishCup.instance()
		"BilateralCup":
			_AvatarTSCN = GameLogic.NPC.BilateralCup.instance()
		"DeliverCar":
			_AvatarTSCN = GameLogic.NPC.DeliverCar.instance()
		"LittleCup":
			_AvatarTSCN = GameLogic.NPC.LittleCup.instance()
		"GlassBottle":
			_AvatarTSCN = GameLogic.NPC.GlassBottle.instance()
	_AvatarTSCN.name = "Avatar"
	self.add_child(_AvatarTSCN)
	Avatar = _AvatarTSCN

func return_personal():
	var _NoPersonal = int(_NPCINFO.NoPersonal)
	var _rand = GameLogic.return_randi() % 100 + 1


	if GameLogic.cur_Event == "点便宜":
		return GameLogic.Order.ORDERPERSONAL.CHEAPEST
	elif GameLogic.cur_Event == "点昂贵":
		return GameLogic.Order.ORDERPERSONAL.EXPENSIVE

	if _rand <= _NoPersonal:
		return GameLogic.Order.ORDERPERSONAL.NONE
	else:
		var _Personal = _NPCINFO.Personal
		match _Personal:
			"EXPENSIVE":
				return GameLogic.Order.ORDERPERSONAL.EXPENSIVE
			"CHEAPEST":
				return GameLogic.Order.ORDERPERSONAL.CHEAPEST
			"POPULAR":
				return GameLogic.Order.ORDERPERSONAL.POPULAR
			"ORDERCHEAPEST":
				return GameLogic.Order.ORDERPERSONAL.ORDERCHEAPEST
			"NOORDER":
				return GameLogic.Order.ORDERPERSONAL.NOORDER
	return GameLogic.Order.ORDERPERSONAL.NONE

func _Order_Extra_Set():
	var Ratio_Base = int(_NPCINFO.Extra_Base)

	var _FULL = int(_NPCINFO.Full)
	if _FULL == 1:
		Order_Extra_Max = true

	var _rand = GameLogic.return_randi() % 100 + 1
	if GameLogic.cur_Event == "点小料":
		_rand -= 50
	elif GameLogic.cur_Event == "点小料+":
		_rand = 0
	if _rand <= Ratio_Base:
		Order_Extra_Base = true

func _Order_Type_Set():

	pass
func _Order_Celicius_Set():
	var Ratio_Hot = int(_NPCINFO.Hot)
	var Ratio_Normal = int(_NPCINFO.Normal)
	var Ratio_Cold = int(_NPCINFO.Cold)
	for i in 3:
		var _rand = GameLogic.return_randi() % 100 + 1
		match i:
			0:
				if _rand <= Ratio_Hot:
					Order_HOT = true
			1:
				if _rand <= Ratio_Normal:
					Order_NORMAL = true
			2:
				if _rand <= Ratio_Cold:
					Order_COLD = true
				if _rand < 50:
					IceBreakType = 1
				else:
					IceBreakType = 2

func _Order_Sugar_Set():
	PopularMult = float(_NPCINFO.PopularMult)
	Rank = int(_NPCINFO.Rank)

	var Ratio_AnySugar = int(_NPCINFO.AnySugar)
	var Ratio_Sugar = int(_NPCINFO.NeedSugar)
	var _rand = GameLogic.return_randi() % 100 + 1
	if _rand <= Ratio_AnySugar:
		Order_Sugar = GameLogic.Order.SUGARTYPE.ANY
	else:
		_rand = GameLogic.return_randi() % 100 + 1
		if _rand <= Ratio_Sugar:
			var Ratio_FreeSugar = int(_NPCINFO.FreeSugar)
			_rand = GameLogic.return_randi() % 100 + 1
			if _rand <= Ratio_FreeSugar:
				Order_Sugar = GameLogic.Order.SUGARTYPE.FREE
			else:
				Order_Sugar = GameLogic.Order.SUGARTYPE.SUGAR
		else:
			Order_Sugar = GameLogic.Order.SUGARTYPE.NOSUGAR

func call_touched():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_touched")
	if not IsTouched:
		IsTouched = true
		ThinkingAni.play("Recklessness")
func _Order_Cup_Set():

	var Ratio_S = int(_NPCINFO["S"])
	var Ratio_M = int(_NPCINFO["M"])
	var Ratio_L = int(_NPCINFO["L"])

	for i in 3:
		var _rand = GameLogic.return_randi() % 100 + 1
		match i:
			0:
				if _rand <= Ratio_S:
					Order_S = true
			1:
				if _rand <= Ratio_M:
					Order_M = true
			2:
				if _rand <= Ratio_L:
					Order_L = true

func _orderType_init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_Order_Thinking_Set()
		return
	Order_Personal = return_personal()



	_Order_Celicius_Set()
	_Order_Sugar_Set()
	_Order_Cup_Set()
	_Order_Thinking_Set()
	_Order_Extra_Set()

func _Collision_Logic():

	if behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER, BEHAVIOR.WAIT, BEHAVIOR.WORKWAIT]:
		return
	if CheckPos == self.position:
		match SpecialType:
			0:
				if not IsSit:
					if NPCTYPE in [4]:
						_CheckStore()
					else:
						WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.global_position, _FinalTarget)
			- 1, 1:
				WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _FinalTarget)
			_:
				if not IsSit:
					WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _FinalTarget)
		next_point()
	else:
		CheckPos = self.position

func return_Courier_Check():
	if IsCourier:
		if not Con.IsHold:
			return true
	else:
		return true
	return false

func call_puppet_courier(_deliveryPoint, _itemName, _BoxName, _CurNum, _MaxNum, _CurItemNameDic):
	var _BoxObj
	var _Num: int = 1
	var _TYPE
	if GameLogic.Config.ItemConfig.has(_itemName):
		_BoxObj = GameLogic.Buy.return_create_box()
		_Num = int(GameLogic.Config.ItemConfig[_itemName]["BuyNum"])
		_TYPE = GameLogic.Config.ItemConfig[_itemName]["FuncType"]
	elif GameLogic.Config.DeviceConfig.has(_itemName):
		_BoxObj = GameLogic.Buy.return_create_box()
		_TYPE = GameLogic.Config.DeviceConfig[_itemName]["FuncType"]
	else:
		printerr("配送员，货物无法生成。货物名字：", _itemName)
		return
	HoldObj = _BoxObj
	_BoxObj.name = str(_BoxName)
	self.Avatar.WeaponNode.add_child(_BoxObj)

	var _IsOpen: bool = false

	if _TYPE == "Fruit":
		_IsOpen = true
		if Avatar.has_node("AniNode/BoxType"):
			Avatar.get_node("AniNode/BoxType").play("fruit")
	var _INFO = {"NAME": _BoxName, "HasItem": true, "IsOpen": _IsOpen, "ItemName": _itemName, "ItemNum": _Num, "TSCN": "Box_M_Paper", "Type": _TYPE, "pos": Vector2.ZERO}
	_BoxObj.call_load(_INFO)
	_BoxObj.call_puppet_create(_itemName, _CurNum, _CurItemNameDic)
	_BoxObj.call_Collision_Switch(false)
	_FinalTarget = _deliveryPoint
	behavior = BEHAVIOR.DELIVER
	target = self.position
	WayPoint_array = GameLogic.Astar.return_courier_WayPoint_Array(self.position, _deliveryPoint)

	Con.IsHold = true
	Con.NeedPush = true
	IsCourier = true
	if not is_in_group("Couriers"):
		self.add_to_group("Couriers")
	$CollisionShape2D.disabled = true
	Stat.call_NPC_init()
func call_Goblin_puppet(_deliveryPoint, _itemName, _BoxID, _CurNum, _MaxNum, _CurItemNameDic):
	match _itemName:
		"BEER":
			call_Goblin_Beer()
		"拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛":
			call_Goblin_Beer()
			SpecialType = 12

			call_courier(_deliveryPoint, _itemName, _BoxID)
			return
		"GAS":
			call_Goblin_Equipment()
		"ICE":
			call_Goblin_IceEquip()
	NPCTYPE = 1
	_Path_IsFinish = false
	_FinalTarget = _deliveryPoint
	behavior = BEHAVIOR.DELIVER
	target = self.position
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _deliveryPoint)

	IsCourier = true
	SpecialType = 10
	$LogicNode / TYPEAni.play("courier")

	Stat.call_NPC_init()

var _GASCHECKLIST: Array

func return_GasBottle_Logic():

	for _GASBOTTLE in GameLogic.NPC.GASLIST:
		if is_instance_valid(_GASBOTTLE):
			if not is_instance_valid(_GASBOTTLE.get_parent()):
				continue
			if _GASCHECKLIST.has(_GASBOTTLE):
				continue

			if _GASBOTTLE.get_parent().name in ["Weapon_note", "GasNode"]:
				continue
			elif _GASBOTTLE.get_parent().name in ["Devices", "Items"]:

				return true

			elif _GASBOTTLE.get_parent().name in ["ObjNode"]:

				return true

			elif _GASBOTTLE.get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
				var _GOSBOX = _GASBOTTLE.get_parent().get_parent().get_parent().get_parent()
				if _GOSBOX.get_parent().name in ["Devices", "Items"]:

					return true

				elif _GOSBOX.get_parent().name in ["ObjNode"]:

					return true

		else:
			GameLogic.NPC.GASLIST.erase(_GASBOTTLE)
	return false

func call_Goblin_Beer():
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_Goblin()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_Goblin()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Goblin()

func call_Goblin_Equipment():
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_GasPackbag()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_Goblin()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_Goblin()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Goblin()

func call_Goblin_IceEquip():
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_Icebag()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_Goblin()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_Goblin()
	AvatarNode.get_node("Avatar/SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Goblin()

func call_Overseer():
	_Path_IsFinish = false
	behavior = BEHAVIOR.WORKWAIT

	IsCourier = true
	LogicTimer.wait_time = 2
	NPCTYPE = 4
	target = self.position


	Stat.Ins_Beaver = 0.75
	Stat.call_NPC_init()
	$LogicNode / TYPEAni.play("Overseer")

	LogicTimer.start(0)
func call_Checker():
	_Path_IsFinish = false
	behavior = BEHAVIOR.WORKWAIT

	IsCourier = true
	LogicTimer.wait_time = 2
	NPCTYPE = 3
	target = self.position
	$LogicNode / TYPEAni.play("Leave")
	Stat.Ins_Beaver = 0.75
	Stat.call_NPC_init()
	LogicTimer.start(0)
func call_Cleaner():
	_Path_IsFinish = false

	behavior = BEHAVIOR.WORKWAIT
	if GameLogic.NPC.LevelNode.has_node("MapNode/Floor"):
		var _FLOORLIST = GameLogic.NPC.LevelNode.get_node("MapNode/Floor").get_used_cells()
		var _randfloor = GameLogic.return_RANDOM() % _FLOORLIST.size()
		var _pointV2 = _FLOORLIST[_randfloor] * 100 + Vector2(50, 50)

		WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.global_position, _pointV2)
	IsCourier = true
	LogicTimer.wait_time = 2
	NPCTYPE = 2
	target = self.position
	$LogicNode / TYPEAni.play("Leave")
	Stat.Ins_Beaver = 0.5
	Stat.call_NPC_init()

func call_Goblin(_targetPos, _itemName):

	var _POS: Vector2
	var _OBJNODE
	match _itemName:
		"BEER":
			call_Goblin_Beer()
			SpecialType = 12
			_POS = _targetPos
		"拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛":
			call_Goblin_Beer()
			SpecialType = 12

			call_courier(_targetPos, _itemName)
			return
		"ICE":
			if not is_instance_valid(GameLogic.NPC.ICEMACHINE):
				return
			call_Goblin_IceEquip()
			_OBJNODE = GameLogic.NPC.ICEMACHINE
			_POS = _OBJNODE.global_position
			SpecialType = 10
			if not _OBJNODE.get_parent().name in ["Devices", "Items"]:
				if _OBJNODE.get_parent().name == "Weapon_note":
					var _name = _OBJNODE.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

					_POS = _OBJNODE.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().global_position
				else:
					_POS = _OBJNODE.get_parent().get_parent().global_position

		"GAS":
			if not is_instance_valid(GameLogic.NPC.GASBOX):
				return
			call_Goblin_Equipment()
			_OBJNODE = GameLogic.NPC.GASBOX
			_POS = _OBJNODE.global_position
			SpecialType = 11
			if not _OBJNODE.get_parent().name in ["Devices", "Items"]:
				if _OBJNODE.get_parent().name == "Weapon_note":
					var _name = _OBJNODE.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
					_POS = _OBJNODE.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().global_position
				else:
					_POS = _OBJNODE.get_parent().get_parent().global_position
					_POS.y += 25

		_:
			return
	NPCTYPE = 1
	_Path_IsFinish = false
	_FinalTarget = _POS
	behavior = BEHAVIOR.DELIVER
	target = self.position

	WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _FinalTarget)

	IsCourier = true

	$LogicNode / TYPEAni.play("Leave")

	Stat.call_NPC_init()

func call_courier(_targetPos, _itemName, _BoxID: int = 0):
	var _BoxObj
	var _Num: int = 1
	var _TYPE
	if _itemName in ["拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛"]:

		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_itemName)
		_BoxObj = _TSCN.instance()
		if _BoxID:
			_BoxObj._SELFID = _BoxID
			_BoxObj.name = str(_BoxID)
		else:
			_BoxObj._SELFID = _BoxObj.get_instance_id()
			_BoxObj.name = str(_BoxObj._SELFID)
		HoldObj = _BoxObj
		Avatar = AvatarNode.get_node("Avatar")
		Avatar.WeaponNode.add_child(_BoxObj)
		_BoxObj.call_load_TSCN(_itemName)

		_BoxObj.call_Collision_Switch(false)
		_FinalTarget = _targetPos
		behavior = BEHAVIOR.DELIVER
		target = self.position

		WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _targetPos)


		Con.IsHold = true
		Con.NeedPush = true
		IsCourier = true
		SpecialType = 12
		$LogicNode / TYPEAni.play("courier")
		if not is_in_group("Couriers"):
			self.add_to_group("Couriers")
		Stat.call_NPC_init()
		return
	if GameLogic.Config.ItemConfig.has(_itemName):
		_BoxObj = GameLogic.Buy.return_create_box()
		_Num = int(GameLogic.Config.ItemConfig[_itemName]["BuyNum"])
		_TYPE = GameLogic.Config.ItemConfig[_itemName]["FuncType"]
	elif GameLogic.Config.DeviceConfig.has(_itemName):
		_BoxObj = GameLogic.Buy.return_create_box()
		_TYPE = GameLogic.Config.DeviceConfig[_itemName]["FuncType"]
	else:

		return
	HoldObj = _BoxObj
	_BoxObj.name = str(_BoxObj.get_instance_id())
	self.Avatar.WeaponNode.add_child(_BoxObj)

	var _IsOpen: bool = false

	match _TYPE:

		"Fruit":
			_IsOpen = true
			if Avatar.has_node("AniNode/BoxType"):
				Avatar.get_node("AniNode/BoxType").play("fruit")
	var _INFO = {"NAME": _BoxObj.name, "HasItem": true, "IsOpen": _IsOpen, "ItemName": _itemName, "ItemNum": _Num, "TSCN": "Box_M_Paper", "Type": _TYPE, "pos": Vector2.ZERO}

	_BoxObj.call_load(_INFO)
	_BoxObj._create()
	_BoxObj.call_Collision_Switch(false)
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.DELIVER
	target = self.position
	WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _targetPos)

	Con.IsHold = true
	Con.NeedPush = true
	IsCourier = true
	SpecialType = - 1
	$LogicNode / TYPEAni.play("courier")
	if not is_in_group("Couriers"):
		self.add_to_group("Couriers")
	Stat.call_NPC_init()

func call_puppet_thief(_Target):
	SpecialType = 1
	$CollisionShape2D / AnimationPlayer.play("thief")
	if _Target == Vector2.ZERO:

		call_Thief_leaving()
		return
	_FinalTarget = _Target
	behavior = BEHAVIOR.STEAL
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	$LogicNode / TYPEAni.play("Special")
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _Target)
	if not is_in_group("NPC"):
		self.add_to_group("NPC")
	Stat.call_NPC_init()
func call_GlassBottle(_targetPos):
	SpecialType = 7
	call_customer(_targetPos)
	pass
func call_Critic(_targetPos):
	SpecialType = 2
	call_customer(_targetPos)
	pass
func call_Uper(_targetPos):

	call_customer(_targetPos)
func call_Cupmother(_targetPos):
	SpecialType = 4
	call_customer(_targetPos)
func call_PickUpCheck(_NPC_TYPE):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if PickUpID == 0:
		return
	if behavior == BEHAVIOR.PASSER:
		return
	if SpecialType == 4:
		if _NPC_TYPE != 4 and PickUpID != 0:

			if Avatar.has_method("call_Uper_Angry"):
				Avatar.call_Uper_Angry()
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(Avatar, "call_Uper_Angry")
			if not NOPRESSURE:
				if not _PRESSURE_1:
					GameLogic.call_Pressure_Set(1)
					_PRESSURE_1 = true

			pass
func call_Homeless(_targetPos):
	SpecialType = 8
	$LogicNode / TYPEAni.play("Homeless")
	call_customer(_targetPos)
func call_Studyholics(_targetPos):
	SpecialType = 5
	call_customer(_targetPos)
func call_Thug(_targetPos):
	SpecialType = 3

	call_customer(_targetPos)
	pass
func call_thief():
	SpecialType = 1
	$LogicNode / TYPEAni.play("Special")
	var _targetPos: Vector2
	if GameLogic.Staff.LevelNode.has_node("YSort/Items"):
		var _ItemYSort = GameLogic.Staff.LevelNode.get_node("YSort/Items")
		var _DEVLIST: Array = _ItemYSort.get_children()
		_DEVLIST.shuffle()
		for _Node in _DEVLIST:
			if _Node.IsItem:
				if not _Node.FuncType in ["Box", "BoxWood", "Trashbag", "DrinkCup", "SuperCup", "EggRollCup"]:
					if _Node.FuncType in ["Bottle", "Top", "Hang"]:
						if _Node.Liquid_Count > 0:
							_targetPos = _Node.position
							_PickUpDev = _Node
							IsPickUp = true
							break
					elif _Node.FuncType in ["Can"]:
						if _Node.Num > 0:
							_targetPos = _Node.position
							_PickUpDev = _Node
							IsPickUp = true
							break
					elif _Node.FuncType in ["Sugar", "Choco", "Pot", "TeaLeaf", "Cooker"]:
						if not _Node.Used:
							_targetPos = _Node.position
							_PickUpDev = _Node
							IsPickUp = true
							break
					else:
						_targetPos = _Node.position
						_PickUpDev = _Node
						IsPickUp = true
						break
	if _targetPos == Vector2.ZERO:
		if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
			var _DevYSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
			var _DEVLIST: Array = _DevYSort.get_children()
			_DEVLIST.shuffle()
			for _Node in _DEVLIST:
				if _Node.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
					if _Node.OnTableObj:
						if _Node.OnTableObj.IsItem:
							var _CHECK: bool = false
							if not _Node.OnTableObj.FuncType in ["Box", "BoxWood", "Trashbag", "DrinkCup", "SuperCup", "EggRollCup"]:
								if _Node.OnTableObj.get("Liquid_Count"):
									_CHECK = true

								elif _Node.OnTableObj.get("Used") == false:
									_CHECK = true
								if _CHECK:
									_targetPos = _Node.position
									_PickUpDev = _Node
									IsPickUp = false
									break
	if _targetPos == Vector2.ZERO:

		call_Thief_leaving()
		return
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.STEAL
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _targetPos)
	if not is_in_group("NPC"):
		self.add_to_group("NPC")

	Stat.call_NPC_init()

func return_ReCheck_WayPoint(_targetPos):
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _targetPos)
	if not WayPoint_array.size():
		return true
	else:
		return false
func call_Special_Leave(_targetPos):
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	if GameLogic.NPC._INOUT_Bool:
		WayPoint_array = GameLogic.Astar.return_NPC_Leave_Array(self.position, _targetPos)
	else:
		WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)


	IsPasser = true
	if not is_in_group("Passers"):
		self.add_to_group("Passers")
	if not is_in_group("NPC"):
		self.add_to_group("NPC")

	Stat.call_NPC_init()
func call_passer(_targetPos):
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	if GameLogic.NPC._INOUT_Bool:
		WayPoint_array = GameLogic.Astar.return_NPC_Leave_Array(self.position, _targetPos)
	else:
		WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)



	IsPasser = true
	if not is_in_group("Passers"):
		self.add_to_group("Passers")
	if not is_in_group("NPC"):
		self.add_to_group("NPC")

	Stat.call_NPC_init()

func call_Staff_Leave(_targetPos):
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _targetPos)

	Stat.call_NPC_init()
	ThinkingAni.play("Leaving")

func call_customer(_targetPos, _AutoOrderBool: bool = true):

	if not GameLogic.Order.cur_OrderArray.size():
		if GameLogic.cur_Rewards.has("新顾客"):
			GameLogic.call_Info(1, "新顾客")
			Stat.Ins_Skill_1_Mult = 1.5

		if GameLogic.cur_Rewards.has("新顾客+"):
			GameLogic.call_Info(1, "新顾客+")
			Stat.Ins_Skill_1_Mult = 3




	var _SeatRand = GameLogic.return_randi() % 100 + 1
	if _SeatRand <= SeatRat:
		if GameLogic.Order.cur_SeatList.size():
			var _List: Array
			for _Seat in GameLogic.Order.cur_SeatList:
				if is_instance_valid(_Seat):
					_List.append(_Seat)






				else:
					GameLogic.Order.cur_SeatList.erase(_Seat)

			if _List.size():
				_List.shuffle()
				for _Seat in _List:
					if not _Seat.OrderBool:
						_Seat.OrderBool = true
						SeatOBJ = _Seat
						_targetPos = SeatOBJ.global_position
						break

	_FinalTarget = _targetPos
	behavior = BEHAVIOR.CUSTOMER
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)



	var _INFO = _NPCINFO

	var _LineUpTime: float = float(_INFO["LineUpTime"])
	var _LINETIMECOST: float = 1
	if GameLogic.cur_Event == "排队等待":
		_LINETIMECOST += 0.5


	if GameLogic.cur_Challenge.has("不耐烦"):
		_LINETIMECOST -= 0.15
	if GameLogic.cur_Challenge.has("不耐烦+"):
		_LINETIMECOST -= 0.25
	if GameLogic.cur_Challenge.has("不耐烦++"):
		_LINETIMECOST -= 0.5
	if _LINETIMECOST < 0.01:
		_LINETIMECOST = 0.01
	var _LINETIME = float(_LineUpTime) * _LINETIMECOST
	if _LINETIME <= 0:
		_LINETIME = 1
	LineWaitingTimer.wait_time = _LINETIME

	var _OrderTime = float(_INFO["OrderTime"])
	var _ORDERMULT: float = 1
	if GameLogic.cur_Challenge.has("着急点单"):
		_ORDERMULT -= 0.1
	if GameLogic.cur_Challenge.has("着急点单+"):
		_ORDERMULT -= 0.2
	if GameLogic.cur_Challenge.has("着急点单++"):
		_ORDERMULT -= 0.4

	if GameLogic.cur_Rewards.has("耐心挑战"):
		_ORDERMULT -= 0.3
	elif GameLogic.cur_Rewards.has("耐心挑战+"):
		_ORDERMULT -= 0.9
	if _ORDERMULT < 0:
		_ORDERMULT = 0
	OrderTimer.wait_time = _OrderTime * _ORDERMULT

	var _AngryTime: int = 5

	if GameLogic.cur_Rewards.has("耐心挑战"):
		_AngryTime = 10
	elif GameLogic.cur_Rewards.has("耐心挑战+"):
		_AngryTime = 15
	OrderAngryTimer.wait_time = _AngryTime

	LogicTimer.wait_time = int(_INFO["SeatTime"])




	IsCustomer = true
	if not is_in_group("Customers"):
		self.add_to_group("Customers")
	if not is_in_group("NPC"):
		self.add_to_group("NPC")

	Stat.call_NPC_init()


	if _AutoOrderBool:
		if not SpecialType in [4]:
			if GameLogic.curLevelList.has("难度-小程序下单"):
				var _RAND = GameLogic.return_RANDOM() % 10
				if _RAND < 2:
					_orderType_init()
					OrderName = GameLogic.Order.return_order_NPC(self)

					GameLogic.Order._OrderLogic(self)
					call_OrderAudio()
func call_OrderAudio():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_OrderAudio")
	var _AUDIO = GameLogic.Audio.return_Effect("提示单短")
	_AUDIO.play(0)
func call_picker(_targetPos):
	IsPickUp = true
	WaitingTimer.set_paused(true)
	StandTimer.set_paused(true)
	_Path_IsFinish = false
	if _FinalTarget != _targetPos:
		WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.PICKUP
	target = self.position

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_picker", [_targetPos])

func call_RePicker():
	mass = float(_NPCINFO.Mass)
	IsPickUp = false
	IsFinish = false
	WaitingTimer.set_paused(false)
	StandTimer.set_paused(false)
	if behavior != BEHAVIOR.WAIT:
		behavior = BEHAVIOR.MOVE

func _on_StandTimer_timeout() -> void :

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var WAITTYPE = _NPCINFO["WAITTYPE"]
	match WAITTYPE:
		"BASE":

			_call_InStore_RandomMove()
		"OUT":
			_call_InStore_RandomMove()
		"STAND":
			_call_Beside_RandomMove()
		"SIT":
			_call_InStore_RandomMove()
		"MOVE":
			_call_InStore_RandomMove()

func call_puppet_wait(_SpecialType: int = 0):
	OrderTimer.stop()
	OrderAngryTimer.stop()
	if ThinkingAni.assigned_animation in ["angry", "angry_10", "angry_15"]:
		ThinkingAni.play("hide")
	WaitingReset = false
	OrderWait_bool = false
	if _SpecialType == 4:
		if PickUpID != 0:
			$Thinking / Ani / Thick / Label.text = str(PickUpID)
			ThinkingAni.play("uper")
	if IsSit:
		_WaitingTime_Set()
func call_wait_logic():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_wait", [SpecialType])
	OrderTimer.stop()
	OrderAngryTimer.stop()
	if ThinkingAni.assigned_animation in ["angry", "angry_10", "angry_15"]:
		ThinkingAni.play("hide")
	WaitingReset = false



	if SpecialType == 4:
		if PickUpID != 0:
			$Thinking / Ani / Thick / Label.text = str(PickUpID)
			ThinkingAni.play("uper")
	if IsSit:
		_WaitingTime_Set()
		return
	var WAITTYPE = _NPCINFO["WAITTYPE"]

	match WAITTYPE:
		"BASE":

			Waiter_MOVE_Logic()
		"OUT":
			Waiter_MOVE_Logic()
		"STAND":
			Waiter_STAND_Logic()
		"SIT":
			Waiter_MOVE_Logic()
		"MOVE":
			Waiter_MOVE_Logic()

var _OrderCurTime: float = 0

func _WaitingTime_Set():
	OrderWait_bool = false
	WaitTime = float(_NPCINFO["WaitTime"])

	var _WAITTIMEMULT: float = 1
	if GameLogic.cur_Event == "等餐":
		_WAITTIMEMULT += 0.25

	if GameLogic.cur_Event == "等餐+":
		_WAITTIMEMULT += 0.5

	if GameLogic.cur_Challenge.has("顾客等餐"):
		_WAITTIMEMULT -= 0.05

	if GameLogic.cur_Challenge.has("顾客等餐+"):
		_WAITTIMEMULT -= 0.1

	if GameLogic.cur_Challenge.has("顾客等餐++"):
		_WAITTIMEMULT -= 0.2

	if GameLogic.cur_Rewards.has("提速杯刷"):
		WaitTime += 5
	if GameLogic.cur_Rewards.has("提速杯刷+"):
		WaitTime += 15
	if GameLogic.Achievement.cur_EquipList.has("等餐耐心") and not GameLogic.SPECIALLEVEL_Int:
		_WAITTIMEMULT += 0.2


	if _WAITTIMEMULT < 0.1:
		_WAITTIMEMULT = 0.1
	WaitTime = WaitTime * _WAITTIMEMULT
	WaitingTimer.wait_time = WaitTime
	_OrderCurTime = GameLogic.GameUI.CurTime
	WaitingTimer.start(0)
	if GameLogic.Order.cur_LineUpArray.has(self):
		GameLogic.Order.cur_LineUpArray.erase(self)
func Waiter_STAND_Logic():

	if int(WaitTime) == 0:
		_WaitingTime_Set()
		_call_Beside_RandomMove()
	else:


		var _Transform2D = Transform2D(0, self.position)

		if not StandTimer.is_stopped():
			StandTimer.wait_time = 1
			StandTimer.start(0)

func Waiter_MOVE_Logic():

	if int(WaitTime) == 0:
		_WaitingTime_Set()
		_call_InStore_RandomMove()
	else:


		var _Transform2D = Transform2D(0, self.position)



func _call_Beside_RandomMove():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _pointID = GameLogic.Astar.AStar_NPC.get_closest_point(self.position)
	var _point = GameLogic.Astar.AStar_NPC.get_point_position(_pointID)
	var _check = GameLogic.NPC.return_besidePoint(_point)
	if not _check:
		print("_call_Beside_RandomMove 未找到可以动的位置。")
		return
	_FinalTarget = _check
	_Path_IsFinish = false
	behavior = BEHAVIOR.MOVE
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _FinalTarget)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Move", [_FinalTarget, self.position])
func _call_InStore_RandomMove():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	_FinalTarget = GameLogic.NPC.return_inStorePoint()
	_Path_IsFinish = false
	behavior = BEHAVIOR.MOVE
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPCWait_WayPoint_Array(self.position, _FinalTarget)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Move", [_FinalTarget, self.position])

func call_puppet_Move(_TARGET, _POS):
	if self.position.distance_to(_POS) >= 100:
		position = _POS

	IsPickUp = false
	_Path_IsFinish = false
	behavior = BEHAVIOR.MOVE
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _TARGET)


func call_CheckStore_puppet(_WAYPOINT, _SPEED, _OBJPATH):
	if has_node(_OBJPATH):
		HoldObj = get_node(_OBJPATH)
	else:
		HoldObj = null
	WayPoint_array = _WAYPOINT
	_Path_IsFinish = false
	Stat.Ins_Beaver = _SPEED
	Stat.call_NPC_init()
var _IGNORELIST: Array
func _CheckStore():

	if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime and NPCTYPE == 3:
		LogicTimer.start(0)
		return
	var _t = GameLogic.GameUI.CurTime
	var _c = GameLogic.cur_CloseTime

	if _t >= _c:
		call_leaving()
		return
	var _CHECK: bool
	if NPCTYPE in [3]:
		if GameLogic.NPC.LevelNode.has_node("YSort/Items"):
			var _ItemList = GameLogic.NPC.LevelNode.get_node("YSort/Items").get_children()
			if _IGNORELIST.size():
				for _IGNODE in _IGNORELIST:
					if _IGNODE in _ItemList:
						_ItemList.erase(_IGNODE)
			if _ItemList.size():
				var _randI = GameLogic.return_RANDOM() % _ItemList.size()
				HoldObj = _ItemList[_randI]
				var _ITEMPOS = HoldObj.global_position
				WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _ITEMPOS)
				if WayPoint_array.size():
					var _CHECKPOS = WayPoint_array.back()
					if _CHECKPOS.distance_to(HoldObj.global_position) > 150:
						_IGNORELIST.append(HoldObj)
						_CheckStore()
						return
				else:
					_IGNORELIST.append(HoldObj)
					_CheckStore()
					return
				_Path_IsFinish = false
				_CHECK = true
				Stat.Ins_Beaver = 1.5
				Stat.call_NPC_init()
				if is_instance_valid(HoldObj):
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _OBJPATH = HoldObj.get_path()
						SteamLogic.call_puppet_node_sync(self, "call_CheckStore_puppet", [WayPoint_array, Stat.Ins_Beaver, _OBJPATH])

	if not _CHECK:
		Point += 1

		if Point >= 2:
			if GameLogic.NPC.LevelNode.has_node("MapNode/Floor"):
				var _FLOORLIST = GameLogic.NPC.LevelNode.get_node("MapNode/Floor").get_used_cells()
				var _randfloor = GameLogic.return_RANDOM() % _FLOORLIST.size()
				var _pointV2 = _FLOORLIST[_randfloor] * 100 + Vector2(50, 50)
				WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.global_position, _pointV2)
				_IGNORELIST.clear()
				_Path_IsFinish = false
				Point = 0
				PerfectPoint += 1
				Stat.Ins_Beaver = 0.75
				Stat.call_NPC_init()
				var _OBJPATH = ""
				if is_instance_valid(HoldObj):
					_OBJPATH = HoldObj.get_path()
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

					SteamLogic.call_puppet_node_sync(self, "call_CheckStore_puppet", [WayPoint_array, Stat.Ins_Beaver, _OBJPATH])
		else:
			_call_Checking()
			LogicTimer.start(0)
func _find_WaterStain():
	if is_instance_valid(HoldObj):
		LogicTimer.start(0)
		return
	var _t = GameLogic.GameUI.CurTime
	var _c = GameLogic.cur_CloseTime

	if _t >= _c:
		call_leaving()
		return
	var _LIST = get_tree().get_nodes_in_group("WaterStain")
	var _WaterNum = _LIST.size()
	if _WaterNum:
		var _WR = GameLogic.return_RANDOM() % _WaterNum
		var _WATERNODE = _LIST[_WR]
		HoldObj = _WATERNODE
		WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _WATERNODE.position)
		_Path_IsFinish = false
	else:
		Point += 1
		if Point >= 5:
			if GameLogic.NPC.LevelNode.has_node("MapNode/Floor"):
				var _FLOORLIST = GameLogic.NPC.LevelNode.get_node("MapNode/Floor").get_used_cells()
				var _randfloor = GameLogic.return_RANDOM() % _FLOORLIST.size()
				var _pointV2 = _FLOORLIST[_randfloor] * 100 + Vector2(50, 50)
				WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.global_position, _pointV2)
				_Path_IsFinish = false
				Point = 0
		else:
			LogicTimer.start(0)
func _physics_process(_delta: float) -> void :
	if not Stat.Ins_MAXSPEED:
		return
	if IsSit:
		self.position = Vector2.ZERO
		Con.state = GameLogic.NPC.STATE.SIT
		return

	if behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER, BEHAVIOR.WAIT]:
		Con.velocity = Vector2.ZERO

	else:


		var _d = self.position.distance_to(target)

		if _d >= 31:
			var _velocity = position.direction_to(target) * Stat.Ins_MAXSPEED
			Con.velocity = _velocity


	if NPCTYPE in [4]:
		if _Path_IsFinish:
			Con.velocity = Vector2.ZERO
			Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				pass
			elif LogicTimer.is_stopped():
				LogicTimer.start(0)
	if NPCTYPE in [3]:
		if _Path_IsFinish:
			Con.velocity = Vector2.ZERO
			var _NewCheck: bool = false

			if is_instance_valid(HoldObj):
				if HoldObj.get_parent().name in ["Items"]:
					if self.position.distance_to(HoldObj.global_position) <= 150:
						Con.state = GameLogic.NPC.STATE.URGE
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

							pass
						elif LogicTimer.is_stopped():

							LogicTimer.start(0)
					else:


							_NewCheck = true
				else:
					_NewCheck = true
			else:
				_NewCheck = true
			if _NewCheck:
				Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					pass
				elif LogicTimer.is_stopped():
					LogicTimer.start(0)


	if NPCTYPE in [2]:

		if _Path_IsFinish:
			Con.velocity = Vector2.ZERO



		pass
	Con.input_vector = Con.velocity.normalized()

	if behavior != BEHAVIOR.LINE:

		if not _Path_IsFinish:
			if self.position.distance_to(target) < 31:

				next_point()

		elif self.position != target:
			if IsSit:
				self.position = Vector2.ZERO
				Con.state = GameLogic.NPC.STATE.SIT
			else:
				Con.velocity = Vector2.ZERO

	else:

		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			_ani_logic()
			return
		LineTime += _delta
		if LineTime > 0.5:
			LineTime = 0
			if is_instance_valid(LineNPC):
				if not LineNPC.behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER]:

					behavior = BEHAVIOR.CUSTOMER
					WaitingReset = true
					LineNPC = null
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_to_Customer")
			else:
				behavior = BEHAVIOR.CUSTOMER
				WaitingReset = true
				LineNPC = null
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_to_Customer")
	_ani_logic()
func call_puppet_to_Customer():
	behavior = BEHAVIOR.CUSTOMER
	WaitingReset = true
	LineNPC = null

func _ani_logic():
	if IsSit:
		return
	var _aniSpeed = _return_ani_speed()
	if _aniSpeed > 0:
		if Con.state != GameLogic.NPC.STATE.MOVE:
			Con.state = GameLogic.NPC.STATE.MOVE
	else:

		if not Con.state in [GameLogic.NPC.STATE.IDLE_EMPTY, GameLogic.NPC.STATE.URGE]:
			Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
	match behavior:
		BEHAVIOR.LINE:
			if Con.state != GameLogic.NPC.STATE.IDLE_EMPTY:
				Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
	pass

func _integrate_forces(s):
	var CURVELOCITY = s.get_linear_velocity()
	if not KnockBack:
		CURVELOCITY = CURVELOCITY.move_toward(Con.velocity, Stat.Ins_MAXSPEED * 1000)
		s.set_linear_velocity(CURVELOCITY)
	else:
		if CURVELOCITY == Con.velocity:
			KnockBack = false
		CURVELOCITY = CURVELOCITY.move_toward(Con.velocity, 10000 * s.get_step())

		set_linear_velocity(CURVELOCITY)



func call_sitting_puppet(_OBJPATH):
	var _OBJ = get_node(_OBJPATH)
	IsSit = true
	PosSave = self.position
	_OBJ.call_sitting(self)

	behavior = BEHAVIOR.ORDER

func call_sitting():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _OBJPATH = SeatOBJ.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_sitting_puppet", [_OBJPATH])
	IsSit = true
	PosSave = self.position
	SeatOBJ.call_sitting(self)
	if not PickUpID:

		_orderType_init()
		behavior = BEHAVIOR.ORDER

		_call_thinking()
func _homeless_run_away():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_homeless_run_away")
	IsPasser = true
	ThinkingAni.play("Leaving")

	SpecialType = - 1
	var _Popular: int = 5
	var _x = GameLogic.Save.gameData.HomeDevList

	if _Popular != 0:
		_Popular = GameLogic.return_Popular(_Popular, GameLogic.HomeMoneyKey)
		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
		_PayEffect.call_REP(_Popular)
	GameLogic.call_StatisticsData_Set("Count_CatchHomeless", null, 1)
	var _Audio = GameLogic.Audio.return_Effect("碰杯子")
	_Audio.play(0)
	call_leaving()
func _thief_run_away():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_thief_run_away")
	IsPasser = true

	ThinkingAni.play("thief_run")
	SpecialType = - 1
	mass = 0.5
	var _Popular: int = 30
	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Save.gameData.HomeDevList.has("唱片机"):
			_Popular += 10
	if _Popular != 0:
		_Popular = GameLogic.return_Popular(_Popular, GameLogic.HomeMoneyKey)
	var _MoneyGet: int = 0
	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Save.gameData.HomeDevList.has("唱片机"):
			_MoneyGet += 10
	if _MoneyGet != 0:
		GameLogic.call_MoneyOther_Change(_MoneyGet, GameLogic.HomeMoneyKey)
		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
		_PayEffect.call_init(_MoneyGet, _MoneyGet, 0, false, false, false, false, _Popular)
	elif _Popular != 0:

		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
		_PayEffect.call_REP(_Popular)

	GameLogic.call_StatisticsData_Set("Count_CatchThief", null, 1)

	call_Thief_leaving()
	yield(get_tree().create_timer(0.5), "timeout")
	if Con.IsHold:
		_thief_putDown()

	var _Audio = GameLogic.Audio.return_Effect("碰杯子")
	_Audio.play(0)

func call_thug_run_puppet(_SPEED):
	IsPasser = true

	ThinkingAni.play("thief_run")
	$LogicNode / TYPEAni.play("Leave")
	SpecialType = - 1

	GameLogic.call_StatisticsData_Set("Count_CatchThug", null, 1)

	Stat.Ins_Skill_1_Mult = _SPEED
	Stat._speed_change_logic()
	var _Audio = GameLogic.Audio.return_Effect("碰杯子")
	_Audio.play(0)
func _thug_run_away():

	SpecialType = - 1
	IsPasser = true

	ThinkingAni.play("thief_run")
	$LogicNode / TYPEAni.play("Leave")


	GameLogic.call_StatisticsData_Set("Count_CatchThug", null, 1)

	Stat.Ins_Skill_1_Mult = 1.5
	Stat._speed_change_logic()
	var _Audio = GameLogic.Audio.return_Effect("碰杯子")
	_Audio.play(0)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_thug_run_puppet", [Stat.Ins_Skill_1_Mult])
func _return_ani_speed():


	var _speedscale: float
	var velocity = Con.velocity
	var _Mult: float = (float(Stat.Ins_MAXSPEED) / 250)
	var _x = abs(velocity.x / Stat.Ins_MAXSPEED)
	var _y = abs(velocity.y / Stat.Ins_MAXSPEED)
	if _x >= _y:
		_speedscale = float(int(_x * 100)) / 100 * _Mult
	else:
		_speedscale = float(int(_y * 100)) / 100 * _Mult

	return _speedscale
func call_stealing():



	if IsPickUp:
		if is_instance_valid(_PickUpDev):
			if _PickUpDev.get_parent().name == "Items":
				WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _PickUpDev.position)
				if not WayPoint_array.size():
					_Thief_pickUp(_PickUpDev)
					return
				else:
					_Path_IsFinish = false
					next_point()
					return
	else:
		if _PickUpDev.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
			if _PickUpDev.OnTableObj:
				if _PickUpDev.OnTableObj.IsItem:
					if not _PickUpDev.OnTableObj.FuncType in ["Box", "BoxWood", "Trashbag", "DrinkCup", "SuperCup", "EggRollCup"]:
						_Thief_pickUp(_PickUpDev.OnTableObj)
						_PickUpDev.OnTableObj = null
						return
	call_thief()
func _Thief_pickUp_Puppet(_PATH, _POS):
	self.position = _POS
	var _OBJ = get_node(_PATH)
	var _ParNode = _OBJ.get_parent()
	_ParNode.remove_child(_OBJ)
	_OBJ.position = Vector2.ZERO
	self.Avatar.WeaponNode.add_child(_OBJ)
	HoldObj = _OBJ
	if _OBJ.has_method("call_Collision_Switch"):
		_OBJ.call_Collision_Switch(false)

	Con.IsHold = true
func _Thief_pickUp(_OBJ):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PATH = _OBJ.get_path()
		SteamLogic.call_puppet_node_sync(self, "_Thief_pickUp_Puppet", [_PATH, position])
	var _ParNode = _OBJ.get_parent()
	_ParNode.remove_child(_OBJ)
	_OBJ.position = Vector2.ZERO
	self.Avatar.WeaponNode.add_child(_OBJ)
	HoldObj = _OBJ
	if _OBJ.has_method("call_Collision_Switch"):
		_OBJ.call_Collision_Switch(false)

	Con.IsHold = true


	call_Thief_leaving()
func c_p(_POS, _BEHAVIOR):
	position = _POS
	behavior = _BEHAVIOR
	if behavior in [BEHAVIOR.ORDER]:
		mass = 100
	else:
		mass = float(_NPCINFO.Mass)
func call_puppet_BEHAVIOR(_POS, _BEHAVIOR):
	if self.position.distance_to(_POS) >= 100:
		position = _POS

	behavior = _BEHAVIOR
	if behavior in [BEHAVIOR.ORDER]:
		mass = 100
	else:
		mass = float(_NPCINFO.Mass)
func call_puppet_nextpoint(_POS, _TARGET):

	if self.position.distance_to(_POS) >= 100:
		position = _POS


	target = _TARGET
	_Path_IsFinish = false
func next_point():
	if SpecialType in [11]:

		if WayPoint_array.size() == 0:
			pass

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	elif SpecialType == 1 and not IsPasser and not Con.IsHold:
		var _rand = GameLogic.return_RANDOM() % 5
		if not _rand:
			call_thief()
			return

	if WayPoint_array.size():

		CheckPos = self.position
		CheckTimer.start(0)
		target = WayPoint_array.pop_front()

		if SpecialType != - 1:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_nextpoint", [self.position, target])

	else:

		_Path_IsFinish = true
		Stat.call_NPC_init()

		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return

		match behavior:
			BEHAVIOR.PLATE:
					_on_LogicTimer_timeout()
			BEHAVIOR.WORKWAIT:

				LogicTimer.start(0)
			BEHAVIOR.STEAL:
				call_stealing()
			BEHAVIOR.DELIVER:
				match SpecialType:
					12:
						if HoldObj != null:
							_putDown(target)
						var _POS: Vector2
						var _CHECKBOOL: bool = false
						var _BEER

						var _BEERLIST: Array = GameLogic.NPC.BEERLIST.duplicate()
						for _BARREL in _BEERLIST:
							if is_instance_valid(_BARREL):
								if _BARREL.Liquid_Count <= 0:
									if _BARREL.get_parent().name in ["Weapon_note", "Obj_X", "Obj_Y"]:
										continue
									elif _BARREL.get_parent().name in ["Devices", "Items"]:
										_POS = _BARREL.global_position
										_CHECKBOOL = true
										_BEER = _BARREL

										break
									elif _BARREL.get_parent().name in ["ObjNode"]:
										_PickUpDev = _BARREL.get_parent().get_parent()
										_POS = _PickUpDev.global_position
										_POS.y += 25
										_CHECKBOOL = true
										_BEER = _BARREL

										break
									elif _BARREL.get_parent().name in ["layer1", "layer2", "layer3", "layer4"]:
										_PickUpDev = _BARREL.get_parent().get_parent().get_parent()
										_POS = _PickUpDev.global_position
										_POS.y += 25
										_CHECKBOOL = true
										_BEER = _BARREL

										break
							else:
								if GameLogic.NPC.BEERLIST.has(_BARREL):
									GameLogic.NPC.BEERLIST.erase(_BARREL)
						if _CHECKBOOL:
							if _FinalTarget == _POS:
								if not is_instance_valid(_BEER):
									next_point()
									print(" 啤酒配送员：", name, " 未发现啤酒。")
									return
								match _BEER.get_parent().name:
									"ObjNode":
										_PickUpDev.OnTableObj = null
									"layer1":
										_PickUpDev.LayerA_Obj = null
									"layer2":
										_PickUpDev.LayerB_Obj = null
									"layer3":
										_PickUpDev.LayerX_Obj = null
									"layer4":
										_PickUpDev.LayerY_Obj = null
									"Devices", "Items":
										pass
									_:
										next_point()

										return
								var _itemName = _BEER.TypeStr
								if GameLogic.NPC.BEERLIST.has(_BEER):
									GameLogic.NPC.BEERLIST.erase(_BEER)
								_BEER.call_del()


								_Re_BEER(_itemName)

								call_leaving()
								IsCourier = false
							else:
								_Path_IsFinish = false
								_FinalTarget = _POS
								behavior = BEHAVIOR.DELIVER
								target = self.position
								WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _FinalTarget)

						else:
							call_leaving()
					11:
						var _POS: Vector2
						var _CHECKBOOL: bool = false
						var _BOTTLE
						var _GASLIST: Array = GameLogic.NPC.GASLIST.duplicate()
						for _GASBOTTLE in _GASLIST:
							if is_instance_valid(_GASBOTTLE):
								if _GASCHECKLIST.has(_GASBOTTLE):
									continue
								if not is_instance_valid(_GASBOTTLE.get_parent()):
									continue

								if _GASBOTTLE.get_parent().name in ["Weapon_note", "GasNode"]:
									continue
								elif _GASBOTTLE.get_parent().name in ["Devices", "Items"]:
									_POS = _GASBOTTLE.global_position
									_CHECKBOOL = true
									_BOTTLE = _GASBOTTLE
									break
								elif _GASBOTTLE.get_parent().name in ["ObjNode"]:
									_POS = _GASBOTTLE.get_parent().get_parent().global_position
									_POS.y += 25
									_CHECKBOOL = true
									_BOTTLE = _GASBOTTLE
									break
								elif _GASBOTTLE.get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
									var _GOSBOX = _GASBOTTLE.get_parent().get_parent().get_parent().get_parent()
									if _GOSBOX.get_parent().name in ["Devices", "Items"]:
										_POS = _GOSBOX.global_position
										_CHECKBOOL = true
										_BOTTLE = _GASBOTTLE
										break
									elif _GOSBOX.get_parent().name in ["ObjNode"]:
										_POS = _GOSBOX.get_parent().get_parent().global_position
										_POS.y += 25
										_CHECKBOOL = true
										_BOTTLE = _GASBOTTLE
										break
							else:
								if GameLogic.NPC.GASLIST.has(_GASBOTTLE):
									GameLogic.NPC.GASLIST.erase(_GASBOTTLE)
						if _CHECKBOOL:
							if _FinalTarget == _POS:
								_GASCHECKLIST.append(_BOTTLE)
								ChargeNumTotal += _BOTTLE.return_full_num()

								next_point()
							else:
								_Path_IsFinish = false
								_FinalTarget = _POS
								behavior = BEHAVIOR.DELIVER
								target = self.position
								WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _FinalTarget)

						else:
							_putDown(target)
							call_leaving()

					10:
						var _POS = GameLogic.NPC.ICEMACHINE.global_position
						if not GameLogic.NPC.ICEMACHINE.get_parent().name in ["Devices", "Items"]:
							if GameLogic.NPC.ICEMACHINE.get_parent().name == "Weapon_note":
								var _name = GameLogic.NPC.ICEMACHINE.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
								_POS = GameLogic.NPC.ICEMACHINE.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().global_position
							else:
								_POS = GameLogic.NPC.ICEMACHINE.get_parent().get_parent().global_position
							if _FinalTarget == _POS:
								_putDown(target)
								call_leaving()
							else:
								call_Goblin(_POS, "ICE")
					_:
						_putDown(target)
						call_leaving()
			BEHAVIOR.CUSTOMER:


				if SeatOBJ and not IsSit:
					call_sitting()
					return
				behavior = BEHAVIOR.ORDER

				if not PickUpID:

					_orderType_init()
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "c_p", [self.position, BEHAVIOR.ORDER])

					_call_thinking()
			BEHAVIOR.MOVE:
				behavior = BEHAVIOR.WAIT
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_BEHAVIOR", [self.position, BEHAVIOR.WAIT])
				call_wait_logic()

			BEHAVIOR.PICKUP:
				_pickUp()
			BEHAVIOR.PASSER:
				_free_logic()
			BEHAVIOR.LEAVE:
				_free_logic()
func _free_logic():
	call_del()

func _Re_BEER(_itemName):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_Re_BEER", [_itemName])
	var _MoneyGet: int = 50

	if _MoneyGet != 0:
		GameLogic.call_MoneyOther_Change(_MoneyGet, GameLogic.HomeMoneyKey)
		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
		_PayEffect.call_init(_MoneyGet, _MoneyGet, 0, false, false, false, false, 0)

	if _itemName in ["拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛"]:

		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_itemName)
		var _BoxObj = _TSCN.instance()
		HoldObj = _BoxObj
		Avatar = AvatarNode.get_node("Avatar")
		Avatar.WeaponNode.add_child(_BoxObj)
		_BoxObj.call_Barrel_tex(_itemName)
		Con.IsHold = true
		Con.NeedPush = true

func _Order_Thinking_Set():


	var _npcThinkTime = float(_NPCINFO["ThinkTime"])


	var _THINKMULT: float = 1
	if GameLogic.cur_Challenge.has("选择困难"):
		_THINKMULT += 0.25

	if GameLogic.cur_Challenge.has("选择困难+"):
		_THINKMULT += 0.5

	if GameLogic.cur_Challenge.has("选择困难++"):
		_THINKMULT += 1

	ThinkingTimer.wait_time = _npcThinkTime * _THINKMULT

	if GameLogic.cur_Rewards.has("排队"):

		LineWaitingTimer.wait_time = LineWaitingTimer.wait_time * 1.5
	if GameLogic.cur_Rewards.has("排队+"):

		LineWaitingTimer.wait_time = LineWaitingTimer.wait_time * 2

func call_puppet_thinking():
	ThinkingAni.play("show")
	IsFinish = false

func _call_Checking():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_call_Checking")
	ThinkingAni.play("Checking")
func call_off_puppet(_POS):
	position = _POS
	WayPoint_array.clear()
	_Path_IsFinish = true
	Con.velocity = Vector2.ZERO
	Con.input_vector = Con.velocity.normalized()
	ThinkingAni.play("离地存放")
func _call_StoreOfftheground():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_off_puppet", [position])
	ThinkingAni.play("离地存放")

func _call_thinking():

	IsFinish = false
	SteamLogic.call_puppet_node_sync(self, "call_puppet_thinking")
	LineWaitingTimer.stop()

	if GameLogic.curLevelList.has("难度-点单服务"):
		if not IsService:
			GameLogic.call_OrderQTE(QTEType)
	if not IsService:
		if QTERate > 0:
			var _RAND = GameLogic.return_randi() % 100 + 1
			if _RAND <= QTERate:
				GameLogic.call_OrderQTE(QTEType)

	if ThinkingTimer.wait_time > 0 and ThinkingTimer.time_left == 0:

		ThinkingAni.play("show")
		ThinkingTimer.start()
		_Add_Customer()

	else:

		_on_ThinkingTimer_timeout()

func call_puppet_thinking_finish(_OrderName):

	if ThinkingAni.is_playing():
		ThinkingAni.play("hide")
	OrderName = _OrderName
	if OrderName != "":
		if not IsSit:
			GameLogic.Order.call_NPC_LineUp(self)
			OrderWait_bool = true

	else:
		if not IsSit:
			if GameLogic.Order.cur_LineUpArray.has(self):
				GameLogic.Order.cur_LineUpArray.erase(self)

			Audio_NoOrder.play(0)
func _on_ThinkingTimer_timeout() -> void :
	if ThinkingAni.is_playing():
		ThinkingAni.stop()
	if ThinkingTimer.wait_time > 0:
		ThinkingAni.play("hide")
	if OrderName == "":
		OrderName = GameLogic.Order.return_order_NPC(self)
		SteamLogic.call_puppet_node_sync(self, "call_puppet_thinking_finish", [OrderName])
	if OrderName != "":
		if not IsSit:
			GameLogic.Order.call_NPC_LineUp(self)
			OrderWait_bool = true
			OrderTimer.start(0)
		else:

			SeatOBJ.call_NPC_order()
			OrderTimer.start(0)
			pass

	else:
		if not IsSit:
			if GameLogic.Order.cur_LineUpArray.has(self):
				GameLogic.Order.cur_LineUpArray.erase(self)
			GameLogic.call_NoOrderName_add(NOPRESSURE)
			_NoOrder_reason_show()
			call_leaving()
			Audio_NoOrder.play(0)

func call_NoOrder_Reason_puppet(_INFOTEXT):
	ThinkingAni.play("NoOrder")
	InfoLabel.text = _INFOTEXT
func _NoOrder_reason_show():
	ThinkingAni.play("NoOrder")
	if NoOrder_TYPE:
		InfoLabel.text = "错误-饮品类型"
	elif NoOrder_Celcius:
		InfoLabel.text = "错误-饮品温度"
	elif NoOrder_Cup:
		InfoLabel.text = "错误-饮品杯型"
	elif NoOrder_Suger:
		InfoLabel.text = "错误-饮品甜度"
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_NoOrder_Reason_puppet", [InfoLabel.text])





var _PickTimes: int = 0
func call_puppet_reward(_MONEY):
	if _MONEY > 0:

		GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
		_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
func call_Pick_Reward(_ID):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.cur_Rewards.has("黄牛票") or GameLogic.cur_Rewards.has("黄牛票+"):

		var _MONEY: int = 0
		var _orderid = _ID

		var _CHECK: bool = true




		if _CHECK:
			var _orderInfo = GameLogic.Order.cur_OrderList[_orderid]
			var _name = _orderInfo["Name"]
			var _INFO = GameLogic.Config.FormulaConfig[_name]
			var _BASEMONEY = int(float(_INFO.Price) * 0.1)
			if _BASEMONEY <= 0:
				_BASEMONEY = 1
			_MONEY = int(float(_BASEMONEY) * GameLogic.return_Multiplayer())
		if GameLogic.cur_Rewards.has("黄牛票+"):
			_MONEY = _MONEY * 3
		if _MONEY > 0:
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_MONEY = int(float(_MONEY) * 1.5)
			GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

			var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
			_PayEffect.position = self.global_position
			GameLogic.Staff.LevelNode.add_child(_PayEffect)
			_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_reward", [_MONEY])

func call_pickup(_devObj, _check):

	PickCheck = _check

	if SpecialType in [6]:
		if is_instance_valid(_PickUpDev):
			var _OBJ = _PickUpDev.get("OnTableObj")
			if is_instance_valid(_OBJ):
				if _OBJ.has_method("call_reset_pickup"):

					_PickUpDev.OnTableObj.call_reset_pickup()
	_PickUpDev = _devObj

	var _ID = PickUpID
	var _OBJ = _PickUpDev.get("OnTableObj")
	if is_instance_valid(_OBJ):
		var _CUPID = _OBJ.get("cur_ID")
		if _CUPID > 0:
			_ID = _CUPID


	GameLogic.Order.call_PickUp_Order(_ID)
	if is_instance_valid(_OBJ):
		call_Pick_Reward(_OBJ.cur_ID)




	if not IsSit:
		call_picker(_devObj.global_position)
		WaitingReset = false


		Stat.call_NPC_init()

func call_puppet_point(_ThinkingAni: String, _HappyAni: String):
	if ThinkingAni.has_animation(_ThinkingAni):
		ThinkingAni.play(_ThinkingAni)
	HappyAni.play(_HappyAni)
func return_point_logic(_Player, _ID: int = PickUpID):



	var _PopularNum: float = 0
	var _total = int(PickCheck.Total)
	var _keys = PickCheck.keys()
	Point = 0

	for i in _keys.size():
		if not _keys[i] in ["WrongType", "Stress"]:
			var _PointValue = PickCheck[_keys[i]]
			if typeof(_PointValue) == TYPE_INT:
				Point += _PointValue
	Point -= (_total + PickCheck.ExtraMax)
	PerfectPoint = _total
	NormalPoint = PerfectPoint - 1
	if SpecialType in [2]:
		NormalPoint = PerfectPoint
	if NormalPoint < 0:
		NormalPoint = 0



	if GameLogic.cur_Rewards.has("连续完美"):
		if GameLogic.Day_Perfect >= 1:
			if Point >= NormalPoint and Point < 1:
				GameLogic.call_Info(1, "连续完美")
				Point = 1
				GameLogic.Day_Perfect = 2
	if GameLogic.cur_Rewards.has("连续完美+"):
		if GameLogic.Day_Perfect >= 1:
			if Point < 1:
				GameLogic.call_Info(1, "连续完美+")
				Point = 1
				GameLogic.Day_Perfect = 2


	var _WrongAni: String
	var _OrderList = GameLogic.Order.cur_OrderList.keys()

	if SpecialType in [2]:
		if PickCheck["IsPassDay"]:
			Point = NormalPoint - 1
	if is_instance_valid(_Player):
		if _Player.HighPress:
			if GameLogic.cur_Rewards.has("擦汗毛巾"):
				if Point >= NormalPoint and Point < PerfectPoint:
					Point = PerfectPoint
					GameLogic.call_Info(1, "擦汗毛巾")
			elif GameLogic.cur_Rewards.has("擦汗毛巾+"):
				if Point >= NormalPoint and Point < PerfectPoint:
					Point = PerfectPoint
				elif Point < NormalPoint:
					Point = NormalPoint
				GameLogic.call_Info(1, "擦汗毛巾+")
	if _Player.Stat.Skills.has("技能-鳄鱼"):
		if Point < PerfectPoint:
			if Point >= NormalPoint:
				_Player.call_pressure_set(1)
			else:
				_Player.call_pressure_set(3)
			_Player.call_Say_Perfect()
			Point = PerfectPoint
	if GameLogic.cur_Event == "销售员":
		var _RAND = GameLogic.return_randi() % 100
		if _RAND < 25:
			_Player.call_pressure_set( - 1)
	elif GameLogic.cur_Event == "销售员+":
		var _RAND = GameLogic.return_randi() % 100
		if _RAND < 50:
			_Player.call_pressure_set( - 1)
	elif GameLogic.cur_Event == "销售员++":
		var _RAND = GameLogic.return_randi() % 100
		_Player.call_pressure_set( - 1)
	if Point >= PerfectPoint:
		if GameLogic.Day_Perfect == 2:
			GameLogic.Day_Perfect = 0
		else:
			GameLogic.Day_Perfect = 1

		PointType = 0



		_COMBO += 1



		if _ID != _OrderList.front():

			if GameLogic.cur_Rewards.has("跳跃连击"):

				pass
			elif not SpecialType in [4]:
				GameLogic.call_combo_break()
				_CANCOMBO = false


		HappyAni.play("1")

		var _PopularBase: float = 30
		if not GameLogic.SPECIALLEVEL_Int:
			if GameLogic.Save.gameData.HomeDevList.has("绿色地毯"):
				_PopularBase += 1
			if GameLogic.Save.gameData.HomeDevList.has("浴室地毯"):
				_PopularBase += 1
			if GameLogic.Save.gameData.HomeDevList.has("毛绒地毯"):
				_PopularBase += 1
			if GameLogic.Save.gameData.HomeDevList.has("书房地毯"):
				_PopularBase += 1
			if GameLogic.Save.gameData.HomeDevList.has("大地毯"):
				_PopularBase += 1
			if GameLogic.Save.gameData.HomeDevList.has("飞行棋地毯"):
				_PopularBase += 1
			if GameLogic.Save.gameData.HomeDevList.has("厨房地垫"):
				_PopularBase += 1

		_PopularNum += int(_PopularBase)
	elif Point >= NormalPoint:
		GameLogic.Day_Perfect = 0

		PointType = 1
		GameLogic.call_GoodSell(NOPRESSURE)
		GameLogic.call_NoPerfect()



		var _check: bool
		if GameLogic.cur_Rewards.has("气球"):
			GameLogic.call_Info(1, "气球")
			_check = true
		elif GameLogic.cur_Rewards.has("气球+"):
			GameLogic.call_Info(1, "气球+")

			_check = true
		if not _check:

			GameLogic.call_combo_break()



		if PickCheck.Pop == 0 and PickCheck.NeedPop:
			_WrongAni = "PopWrong"
			ThinkingAni.play("PopWrong")
		if PickCheck.Celcius == 0:
			_WrongAni = "Celcius"
			ThinkingAni.play("Celcius")
		elif PickCheck.Extra < PickCheck.ExtraMax:
			_WrongAni = "ExtraWrong"
			ThinkingAni.play("ExtraWrong")
		elif PickCheck.Sugar == 0:







			if PickCheck.SugarIn:
				_WrongAni = "SugarMore"
				ThinkingAni.play("SugarMore")
			else:
				_WrongAni = "NoSugar"
				ThinkingAni.play("NoSugar")
		elif PickCheck.Condiment_1 == 0 and PickCheck.Condiment != "":
			_WrongAni = "ForWrong"
			ThinkingAni.play("ForWrong")
		elif int(PickCheck.Mixd) == 0:

			if GameLogic.Config.FormulaConfig.has(OrderName):
				var _MIXLogic: int = int(GameLogic.Config.FormulaConfig[OrderName].Mixd)
				match _MIXLogic:
					1:
						_WrongAni = "NoMix"
						ThinkingAni.play("NoMix")
					2:
						_WrongAni = "MixWrong"
						ThinkingAni.play("MixWrong")

		else:

			_WrongAni = "ForWrong"
			ThinkingAni.play("ForWrong")






		HappyAni.play("2")
		_PopularNum += 15
	else:
		GameLogic.call_NoPerfect()
		GameLogic.Day_Perfect = 0

		PointType = 2
		if not NOPRESSURE:
			GameLogic.call_BadSell(NOPRESSURE)

		GameLogic.call_combo_break()

		if GameLogic.cur_Rewards.has("跳单减压"):
			GameLogic.call_Info(1, "跳单减压")
			GameLogic.emit_signal("Pressure_Set", - 1)
		if GameLogic.cur_Rewards.has("跳单减压+"):
			GameLogic.call_Info(1, "跳单减压+")
			GameLogic.emit_signal("Pressure_Set", - 2)


		_WrongAni = "TooWrong"
		ThinkingAni.play("TooWrong")
		HappyAni.play("3")

		_PopularNum += 5
	var _PopularMAX: int = 25
	if GameLogic.cur_Rewards.has("COMBO声望"):
		_PopularMAX = 50
	if GameLogic.cur_Rewards.has("COMBO声望+"):
		_PopularMAX = 150
	if GameLogic.cur_Combo > 1:
		var _COMBOPUPULAR = (GameLogic.cur_Combo - 1) * 2.5 * GameLogic.return_Multiplayer()
		if _COMBOPUPULAR > _PopularMAX:
			_PopularNum += _PopularMAX
		else:
			_PopularNum += _COMBOPUPULAR
	var _OrderPupuarMult: float = 1
	if GameLogic.Config.FormulaConfig.has(OrderName):
		_OrderPupuarMult = float(GameLogic.Config.FormulaConfig[OrderName].PopularMult)
	if _OrderPupuarMult <= 0:
		_OrderPupuarMult = 1

	_PopularNum = int(float(_PopularNum) * PopularMult * _OrderPupuarMult)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_point", [_WrongAni, str(PointType + 1)])

	get_tree().call_group("PLAYER", "call_Special_Logic", "Sell", PointType)
	return _PopularNum
func call_puppet_pickUp_false(_POS):

	position = _POS

	call_RePicker()
func call_pickUp_false(_ID: int = PickUpID):
	if SpecialType in [6]:
		if SpecialSave > 0:
			if _ID != SpecialSave:
				return

	GameLogic.Order.call_PickUp_NotOrder(_ID)
	call_RePicker()
	call_wait_logic()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_pickUp_false", [self.position])
func call_puppet_pickUp(_POS, _CupRemovePath):
	var _CupOBJNode = get_node(_CupRemovePath)
	if self.position.distance_to(_POS) >= 100:
		position = _POS

	if not is_instance_valid(_CupOBJNode):
		return
	var _ParNode = _CupOBJNode.get_parent()
	var _TableNode = _ParNode.get_parent()
	if _TableNode.has_method("call_OnTable"):
		_TableNode.OnTableObj = null
	_ParNode.remove_child(_CupOBJNode)
	self.Avatar.WeaponNode.add_child(_CupOBJNode)
	_CupOBJNode.CupInfoAni.play("hide")

	_CupOBJNode.get_node("But").hide()
	_CupOBJNode.call_Sell_hide()
	_CupOBJNode.IsPickUp = true
	Con.IsHold = true
	IsFinish = true
	HoldObj = _CupOBJNode
func _pickUp():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	get_tree().call_group("Customers", "call_PickUpCheck", SpecialType)

	if not IsSit:
		if not is_instance_valid(_PickUpDev):
			return
		if not is_instance_valid(_PickUpDev.OnTableObj):
			call_pickUp_false()
			return
		var _CupObj = _PickUpDev.OnTableObj

		if not _CupObj.FuncType in ["DrinkCup", "SodaCan", "SuperCup", "EggRollCup"]:
			call_pickUp_false()
			return
		elif not _CupObj.cur_ID in [PickUpID, SpecialSave]:

			call_pickUp_false()
			return



		if SpecialType in [6]:
			var _CUPID = _CupObj.cur_ID
			if _CUPID == PickUpID and SpecialSave > 0:
				call_pickUp_false(SpecialSave)
			elif _CUPID == SpecialSave and PickUpID != 0:
				call_pickUp_false(PickUpID)
		if SpecialType in [7]:
			PickCheck = GameLogic.Order.return_CanPickCheck_Bool(_CupObj, ["Pop"])
		else:
			PickCheck = GameLogic.Order.return_CanPickCheck_Bool(_CupObj)

		_PickUpDev.OnTableObj = null
		var _CupRemovePath = _CupObj.get_path()
		var _ParNode = _CupObj.get_parent()
		_ParNode.remove_child(_CupObj)
		self.Avatar.WeaponNode.add_child(_CupObj)
		_CupObj.CupInfoAni.play("hide")
		_CupObj.get_node("But").hide()
		_CupObj.call_Sell_hide()
		_CupObj.IsPickUp = true
		Con.IsHold = true
		IsFinish = true
		HoldObj = _CupObj
		TipBonus = _CupObj.TipBonus
		SugarType = _CupObj.SugarType
		if SugarType > 0:
			GameLogic.cur_Sugar += 1
		HasIce = _CupObj.HasIce
		if HasIce:
			GameLogic.cur_Ice += 1
		if _CupObj.Extra_1 != "":
			ExtraList.append(_CupObj.Extra_1)
		if _CupObj.Extra_2 != "":
			ExtraList.append(_CupObj.Extra_2)
		if _CupObj.Extra_3 != "":
			ExtraList.append(_CupObj.Extra_3)
		if _CupObj.get("Extra_4") != "":
			ExtraList.append(_CupObj.Extra_4)
		if _CupObj.get("Extra_5") != "":
			ExtraList.append(_CupObj.Extra_5)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_pickUp", [self.position, _CupRemovePath])
		_SellLogic(_CupObj)
	else:
		var _CupOBJ
		match SeatOBJ.name:
			"L":
				_CupOBJ = SeatOBJ.get_parent().get_node("L_OBJ").get_child(0)
			"R":
				_CupOBJ = SeatOBJ.get_parent().get_node("R_OBJ").get_child(0)
		if is_instance_valid(_CupOBJ):
			if _CupOBJ.has_method("call_FinishUpdate"):
				var _CupRemovePath = _CupOBJ.get_path()
				_CupOBJ.get_parent().remove_child(_CupOBJ)
				self.Avatar.WeaponNode.add_child(_CupOBJ)
				_CupOBJ.CupInfoAni.play("hide")
				_CupOBJ.get_node("But").hide()
				_CupOBJ.IsPickUp = true
				_PickUpDev = SeatOBJ.get_parent()
				HoldObj = _CupOBJ
				TipBonus = _CupOBJ.TipBonus
				SugarType = _CupOBJ.SugarType
				if SugarType > 0:
					GameLogic.cur_Sugar += 1
				HasIce = _CupOBJ.HasIce
				if HasIce:
					GameLogic.cur_Ice += 1
				if _CupOBJ.Extra_1 != "":
					ExtraList.append(_CupOBJ.Extra_1)
				if _CupOBJ.Extra_2 != "":
					ExtraList.append(_CupOBJ.Extra_2)
				if _CupOBJ.Extra_3 != "":
					ExtraList.append(_CupOBJ.Extra_3)
				if _CupOBJ.get("Extra_4") != "":
					ExtraList.append(_CupOBJ.Extra_4)
				if _CupOBJ.get("Extra_5") != "":
					ExtraList.append(_CupOBJ.Extra_5)
				PickCheck = GameLogic.Order.return_CanPickCheck_Bool(_CupOBJ)
				_SellLogic(_CupOBJ)
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_pickUp", [self.position, _CupRemovePath])
				Con.IsHold = true

		else:
			printerr("出杯错误，CupOBJ：", _CupOBJ)




func _SellLogic(_CupObj):
	var _Player = _CupObj.SELLPLAYER
	var _Popular = return_point_logic(_Player, _CupObj.cur_ID)
	if SpecialType == 3:
		_sell_logic(_Player, _CupObj.cur_ID, _Popular)
		if not IsSit:
			var _LEVELTYPE = GameLogic.cur_levelInfo.Type
			if "WINE" in _LEVELTYPE:
				print(" 酒馆逻辑 Thug")
				if not IsSit:
					_call_InStore_RandomMove()
				LogicTimer.stop()
				LogicTimer.start(0)
				return
			else:
				call_Thug_leaving()
		else:
			LogicTimer.wait_time = 5 + GameLogic.return_RANDOM() % 10
			LogicTimer.start(0)
	else:
		_sell_logic(_Player, _CupObj.cur_ID, _Popular)
		if SpecialType in [6]:
			var _x = _CupObj.cur_ID
			if _CupObj.cur_ID == SpecialSave:
				SpecialSave = - 1
				call_RePicker()
				_call_InStore_RandomMove()

				return
			elif _CupObj.cur_ID == PickUpID and SpecialSave > 0:
				PickUpID = SpecialSave
				SpecialSave = - 1

				GameLogic.Order.call_PickUp_NotOrder(PickUpID)

				call_RePicker()

				_call_InStore_RandomMove()

				return
			elif _CupObj.cur_ID == PickUpID and SpecialSave <= 0:

				var _Node = self.Avatar.WeaponNode.get_child(0)
				self.Avatar.WeaponNode.remove_child(_Node)
				_Node.call_del()
		if GameLogic.cur_levelInfo.has("Type"):
			var _LEVELTYPE = GameLogic.cur_levelInfo.Type
			if "WINE" in _LEVELTYPE:
				print(" 酒馆逻辑")
				if not IsSit:
					_call_InStore_RandomMove()
				LogicTimer.stop()
				LogicTimer.start(0)
				return
		call_leaving()



func call_happy(_type):
	if int(_type) in [1, 2, 3]:
		HappyAni.play(str(_type))

func call_puppet_PayEffect(_DevPath, _BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump):
	if _DevPath != "":
		_PickUpDev = get_node(_DevPath)

	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	if SpecialType in [3] or IsSit:
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
	elif _DevPath == "":
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
	else:
		_PickUpDev.PayNode.add_child(_PayEffect)
	_PayEffect.call_init(_BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump)


func call_sell_logic_puppet(_IsCri, _IsQuick, _IsSlow, _IsJump, _PointType):
	GameLogic.call_StatisticsData_Set("Dic_NPC_SellNum", _selfTypeID, 1)

	if _IsCri:

		GameLogic.call_StatisticsData_Set("Count_Cri", null, 1)
	if _PointType == 0:

		GameLogic.call_StatisticsData_Set("Count_PerfectSell", null, 1)

func _sell_logic(_Player, _CUPID, _Popular: int = 0):
	if is_instance_valid(_Player):
		if _Player.Stat.Skills.has("技能-出杯服务"):
			if not HoldObj._TouchedPlayer.has(_Player.cur_Player):
				CRIBONUS += 5
		if _Player.Stat.Skills.has("技能-揽客") and PointType == 0:
			CRIBONUS += 5

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Pressure: int = 0
	var _CallSayPerfectBool: bool
	match PointType:
		0:
			GameLogic.cur_Perfect += 1
			GameLogic.level_Perfect += 1
		1:

			GameLogic.cur_Good += 1
			GameLogic.level_Good += 1
		2:

			GameLogic.cur_Bad += 1
			GameLogic.level_Bad += 1



	GameLogic.cur_SellNum += 1
	if GameLogic.Order.cur_OrderList.has(_CUPID):
		var _cur_Order = GameLogic.Order.cur_OrderList[_CUPID]

		var _INFO = GameLogic.Config.FormulaConfig[OrderName]

		var _BasePay: float = int(_INFO["Price"])
		var _Pay: float = 0
		var _Tip: float = 0
		var IsCri: bool = false
		var IsQuick: bool
		var IsSlow: bool
		var IsJump: bool
		var NeedCri: bool
		var _CriRand = GameLogic.return_randi() % 100 + 1
		var _CriChance: int = 5
		var _CriMult: float = 1

		var _PopularNum: int = _Popular
		var _BaseMult: float = 1
		var _PayMult: float = 0
		var _TipMult: float = 1
		var _PlayerPressure: int = 0
		var _OrderList = GameLogic.Order.cur_OrderList.keys()

		var _ExtraPrice: float = 0
		var _ExtraMult: float = 1
		var _EXTRA_ARRAY: Array
		var _PointCheck: bool
		var _CritCheck: bool
		var _TotalCheck: bool = true
		if _INFO.Condiment_1 != "":
			_EXTRA_ARRAY.append(_INFO.Condiment_1)
			var _Condiment_Sell = float(GameLogic.Config.ItemConfig[_INFO.Condiment_1].Sell)
			_BasePay -= _Condiment_Sell
		if PickCheck.Condiment != "":
			ExtraList.append(PickCheck.Condiment)


		var _ExtraArray = _cur_Order.ExtraArray
		var _BASEEXTRAARRAY: Array

		if _INFO.Extra_1 != "":
			_BASEEXTRAARRAY.append(_INFO.Extra_1)
			_BasePay -= int(GameLogic.Config.FormulaConfig[_INFO.Extra_1].Price)
			if _INFO.Extra_2 != "":
				_BASEEXTRAARRAY.append(_INFO.Extra_2)
				_BasePay -= int(GameLogic.Config.FormulaConfig[_INFO.Extra_2].Price)
				if _INFO.Extra_3 != "":
					_BASEEXTRAARRAY.append(_INFO.Extra_3)
					_BasePay -= int(GameLogic.Config.FormulaConfig[_INFO.Extra_3].Price)


		for _EXTRA in _ExtraArray:
			_EXTRA_ARRAY.append(_EXTRA)
		if ExtraList.size() > 0:
			var _ExtraDiffArray: Array
			var _ExtraMoreNum: int = 0
			if _INFO.Condiment_1 != "":
				_ExtraDiffArray.append(_INFO.Condiment_1)
			for _EXTRA in ExtraList:

				if _EXTRA_ARRAY.has(_EXTRA):
					_EXTRA_ARRAY.erase(_EXTRA)
					if GameLogic.Config.FormulaConfig.has(_EXTRA):
						_ExtraPrice += float(GameLogic.Config.FormulaConfig[_EXTRA].Price)
					elif GameLogic.Config.ItemConfig.has(_EXTRA):
						_ExtraPrice += float(GameLogic.Config.ItemConfig[_EXTRA].Sell)
					if GameLogic.cur_Rewards.has("来者不拒new+"):
						_ExtraPrice += 15

				else:
					_ExtraMoreNum += 1
					if GameLogic.cur_Rewards.has("来者不拒new+"):
						var _Price: int

						if GameLogic.Config.FormulaConfig.has(_EXTRA):
							_ExtraPrice += float(GameLogic.Config.FormulaConfig[_EXTRA].Price)
						elif GameLogic.Config.ItemConfig.has(_EXTRA):
							_ExtraPrice += float(GameLogic.Config.ItemConfig[_EXTRA].Sell)
						_ExtraPrice += 15

					elif GameLogic.cur_Rewards.has("来者不拒new"):
						var _Price: int

						if GameLogic.Config.FormulaConfig.has(_EXTRA):
							_ExtraPrice += float(GameLogic.Config.FormulaConfig[_EXTRA].Price)
						elif GameLogic.Config.ItemConfig.has(_EXTRA):
							_ExtraPrice += float(GameLogic.Config.ItemConfig[_EXTRA].Sell)

				if not _ExtraDiffArray.has(_EXTRA):
					_ExtraDiffArray.append(_EXTRA)

			if _ExtraDiffArray.size() > 0:
				if GameLogic.cur_Rewards.has("大满贯"):
					GameLogic.call_Info(1, "大满贯")
					_BaseMult += 1.5 * float(_ExtraDiffArray.size())
				elif GameLogic.cur_Rewards.has("大满贯+"):
					GameLogic.call_Info(1, "大满贯+")
					_BaseMult += 3 * float(_ExtraDiffArray.size())

			if GameLogic.cur_Rewards.has("高价小料"):
				GameLogic.call_Info(1, "高价小料")
				_ExtraMult += 0.5 * GameLogic.cur_Day * GameLogic.return_Multiplayer()
			elif GameLogic.cur_Rewards.has("高价小料+"):
				GameLogic.call_Info(1, "高价小料+")
				_ExtraMult += GameLogic.cur_Day * GameLogic.return_Multiplayer()


			_ExtraPrice = _ExtraPrice * _ExtraMult
			_BasePay += _ExtraPrice

			if GameLogic.cur_Rewards.has("管吃饱"):
				var _MULT: float = float(ExtraList.size())
				GameLogic.call_Info(1, "管吃饱", int(_MULT))
				_BasePay += int(10 * _MULT)
			elif GameLogic.cur_Rewards.has("管吃饱+"):
				var _MULT: float = float(ExtraList.size())
				GameLogic.call_Info(1, "管吃饱+", int(_MULT))
				_BasePay += int(30 * _MULT)

		var SellerNoPre: bool
		var SellerHasPre: bool
		var SellerHighPre: bool
		var SellerPRE: float

		var NoPressure: bool
		var HasPressure: bool
		var _HighPressure: bool

		var SellerMax: int
		var SellerCur: int
		var SellerTime: float
		if is_instance_valid(_Player):
			_Player._Press_Logic()
			SellerNoPre = _Player.NoPress
			SellerHasPre = _Player.HasPress
			SellerHighPre = _Player.HighPress
			SellerTime = _Player.AddPressTime
			SellerMax = _Player.cur_PressureMax
			SellerCur = _Player.cur_Pressure
			if SellerCur > 0:
				SellerPRE = float(SellerCur) / float(SellerMax)
		for _PLAYER in GameLogic.AllStaff:
			if not is_instance_valid(_PLAYER):
				GameLogic.AllStaff.erase(_PLAYER)
		for _PLAYER in GameLogic.AllStaff:
			if not is_instance_valid(_PLAYER):

				pass
			else:

				_PLAYER._Press_Logic()
				if not NoPressure:
					if _PLAYER.NoPress or _PLAYER.cur_Pressure <= 0:
						NoPressure = true
				if not HasPressure:
					if _PLAYER.HasPress:
						HasPressure = true
				if not _HighPressure:
					if _PLAYER.HighPress:
						_HighPressure = true
		for _PlayerID in GameLogic.PressureDic:
			var _PRE = GameLogic.PressureDic[_PlayerID]
			if int(_PRE) > 0:
				HasPressure = true
				var _PlayerSort = get_tree().get_root().get_node("Level/YSort/Players")
				if _PlayerSort.has_node(str(_PlayerID)):
					var _MAX = _PlayerSort.get_node(str(_PlayerID)).cur_PressureMax
					var _HIGHLIMIT: float = 0.8
					if GameLogic.cur_Rewards.has("外放音响"):
						_HIGHLIMIT = 0.7
					if GameLogic.cur_Rewards.has("外放音响+"):
						_HIGHLIMIT = 0.5
					if int(_PRE) >= int(float(_MAX) * _HIGHLIMIT):
						_HighPressure = true
						if GameLogic.cur_Rewards.has("精神寄托new"):
							NoPressure = true
					if GameLogic.cur_Rewards.has("内卷饭碗"):
						if _PRE <= float(_MAX) * 0.1:
							NoPressure = true
							if GameLogic.cur_Rewards.has("精神寄托new"):
								_HighPressure = true
					elif GameLogic.cur_Rewards.has("内卷饭碗+"):
						if _PRE <= float(_MAX) * 0.3:
							NoPressure = true
							if GameLogic.cur_Rewards.has("精神寄托new"):
								_HighPressure = true

		if GameLogic.cur_Rewards.has("连击达人"):

			if GameLogic.cur_Combo > 1:
				GameLogic.call_Info(1, "连击达人")
				_BasePay += float(GameLogic.cur_Combo) * 0.5 * GameLogic.return_Multiplayer()


		if GameLogic.cur_Rewards.has("七分糖"):
			if SugarType:

				_Tip += 50
				GameLogic.call_Info(1, "七分糖")
		elif GameLogic.cur_Rewards.has("七分糖+"):
			if SugarType:

				_Tip += 100
				GameLogic.call_Info(1, "七分糖+")

		if GameLogic.cur_Rewards.has("透心凉"):
			if HasIce:

				_Tip += 50
				GameLogic.call_Info(1, "透心凉")
		elif GameLogic.cur_Rewards.has("透心凉+"):
			if HasIce:

				_Tip += 100
				GameLogic.call_Info(1, "透心凉+")

		if GameLogic.cur_Rewards.has("畅饮爽"):
			GameLogic.call_Info(1, "畅饮爽")
			_BaseMult += 0.5 * GameLogic.cur_Day
		elif GameLogic.cur_Rewards.has("畅饮爽+"):
			GameLogic.call_Info(1, "畅饮爽+")
			_BaseMult += 1.5 * GameLogic.cur_Day

		if GameLogic.cur_Rewards.has("坐地起价"):
			var _NUM = GameLogic.return_Multiplayer_Num(int(_CUPID))
			_BasePay += 1 * _NUM * GameLogic.return_Multiplayer()
			GameLogic.call_Info(1, "坐地起价", _NUM, true)
		elif GameLogic.cur_Rewards.has("坐地起价+"):
			var _NUM = GameLogic.return_Multiplayer_Num(int(_CUPID))
			_BasePay += 2 * _NUM * GameLogic.return_Multiplayer()
			GameLogic.call_Info(1, "坐地起价+", _NUM - 1, true)
		if GameLogic.cur_Rewards.has("小费纸巾"):

			_TipMult += 0.75 * GameLogic.cur_Day
			GameLogic.call_Info(1, "小费纸巾")
		elif GameLogic.cur_Rewards.has("小费纸巾+"):

			_TipMult += 2.25 * GameLogic.cur_Day
			GameLogic.call_Info(1, "小费纸巾+")




		if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
			if GameLogic.cur_Rewards.has("免洗消毒"):
				GameLogic.call_Info(1, "免洗消毒")
				_BaseMult += 2 * float(_INFO.Rank)
			elif GameLogic.cur_Rewards.has("免洗消毒+"):
				GameLogic.call_Info(1, "免洗消毒+")
				_BaseMult += 6 * float(_INFO.Rank)



		for _KEY in _OrderList:
			var _NPC = GameLogic.Order.cur_OrderList[_KEY].NPC
			if is_instance_valid(_NPC):
				_NPC._REWAITTIME = 0
			else:
				GameLogic.Order.cur_OrderList.erase(_KEY)
		var SellTimeRat: float = 0
		var OrderNode = GameLogic.Order.OrderNode
		if OrderNode.has_node(str(_CUPID)):
			var _PickOrder = OrderNode.get_node(str(_CUPID))

			if _PickOrder.RefundTimeBar.value > 0:
				SellTimeRat = float(_PickOrder.RefundTimeBar.value) / float(_PickOrder.RefundTimeBar.max_value)
			var _QuickMult = 0.8
			if GameLogic.cur_Rewards.has("延时抹布"):
				_QuickMult = 0.7
			if GameLogic.cur_Rewards.has("延时抹布+"):
				_QuickMult = 0.5
			var _LimitMult = 0.2
			if GameLogic.cur_Rewards.has("灭蚊灯"):
				_LimitMult = 0.3
			if GameLogic.cur_Rewards.has("灭蚊灯+"):
				_LimitMult = 0.5
			if SellTimeRat >= _QuickMult:
				IsQuick = true
				if GameLogic.cur_Rewards.has("平行时间"):
					GameLogic.call_Info(1, "平行时间")
					IsSlow = true

			if SellTimeRat <= _LimitMult:
				IsSlow = true
				if GameLogic.cur_Rewards.has("平行时间"):
					GameLogic.call_Info(1, "平行时间")
					IsQuick = true

			if GameLogic.cur_Rewards.has("图穷匕见"):
				if _PickOrder.RefundTimeBar.value <= 1:

					GameLogic.call_Info(1, "图穷匕见")
					IsCri = true
					NeedCri = true
					_PayMult += 3
			if IsQuick:
				GameLogic.cur_Quick += 1
				GameLogic.cur_Quickly += 1
				GameLogic.level_Quickly += 1

				if GameLogic.cur_Rewards.has("时间管理"):
					var _NUM: int = 0
					for _KEY in _OrderList:
						if int(_CUPID) > (_KEY):
							_NUM += 1
						else:
							break
					GameLogic.call_Info(1, "时间管理", str(_NUM))
					_PayMult += 0.6 * _NUM * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("延时抹布"):
					_BasePay += 15
					GameLogic.call_Info(1, "延时抹布")
				elif GameLogic.cur_Rewards.has("延时抹布+"):
					_BasePay += 45
					GameLogic.call_Info(1, "延时抹布+")
				if GameLogic.cur_Rewards.has("速销冠军"):
					var _QUICKNUM = GameLogic.cur_Quick - 1
					if _QUICKNUM > 0:
						var _MULT: float = GameLogic.return_Multiplayer_Num(_QUICKNUM)
						GameLogic.call_Info(1, "速销冠军", int(_MULT), true)
						_BaseMult += _MULT * 0.2 * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("网红爆款"):

					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.Day_SellSameNum)
					_BaseMult += 0.1 * _MULT * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "网红爆款", int(_MULT), true)
				elif GameLogic.cur_Rewards.has("网红爆款+"):

					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.Day_SellSameNum)
					_BaseMult += 0.2 * _MULT * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "网红爆款+", int(_MULT), true)

				if GameLogic.cur_Rewards.has("高速反应"):


					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Quickly)
					GameLogic.call_Info(1, "高速反应", int(_MULT), true)
					_PayMult += 0.1 * _MULT * GameLogic.return_Multiplayer()



				if GameLogic.cur_Rewards.has("洗脑钢刷"):
					var _MULT = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "洗脑钢刷", _MULT)
					_BaseMult += 0.05 * _MULT * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("洗脑钢刷+"):
					var _MULT = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "洗脑钢刷+", _MULT)
					_BaseMult += 0.15 * _MULT * GameLogic.return_Multiplayer()

				if GameLogic.cur_Rewards.has("事不宜迟"):
					var _LogicNum = SellTimeRat
					if GameLogic.cur_Rewards.has("争分夺秒") and SellerNoPre:
						_LogicNum += 0.25 * GameLogic.return_Multiplayer()
						if _LogicNum > 1:
							_LogicNum = 1

					_LogicNum = int(_LogicNum * 100)
					GameLogic.call_Info(1, "事不宜迟", str(_LogicNum) + "%")
					_BaseMult += 0.1 * _LogicNum
				elif GameLogic.cur_Rewards.has("事不宜迟+"):
					var _LogicNum = SellTimeRat
					if GameLogic.cur_Rewards.has("争分夺秒") and SellerNoPre:
						_LogicNum += 0.25 * GameLogic.return_Multiplayer()
						if _LogicNum > 1:
							_LogicNum = 1

					_LogicNum = int(_LogicNum * 100)
					GameLogic.call_Info(1, "事不宜迟+", str(_LogicNum) + "%")
					_BaseMult += 0.2 * _LogicNum
				if GameLogic.cur_Rewards.has("快出减压"):

					var _rand = GameLogic.return_randi() % 2
					if _rand == 0:
						GameLogic.call_Info(1, "快出减压")
						_PlayerPressure -= 1

				elif GameLogic.cur_Rewards.has("快出减压+"):

					var _rand = 0
					if _rand == 0:
						_PlayerPressure -= 1

						GameLogic.call_Info(1, "快出减压+")
				if PointType == 0:



					if GameLogic.cur_Rewards.has("快出声望"):
						GameLogic.call_Info(1, "快出声望")
						_PopularNum += 10 * GameLogic.return_Multiplayer()
					elif GameLogic.cur_Rewards.has("快出声望+"):
						GameLogic.call_Info(1, "快出声望+")
						_PopularNum += 30 * GameLogic.return_Multiplayer()
					if GameLogic.cur_Rewards.has("准时达"):
						GameLogic.call_Info(1, "准时达")
						_COMBO += 1


			else:
				GameLogic.cur_Quick = 0
				if GameLogic.curLevelList.has("难度-快速出杯"):
					_TotalCheck = false
			if IsSlow:
				GameLogic.cur_Nearly += 1
				GameLogic.level_Nearly += 1
				GameLogic.cur_NearTime = GameLogic.GameUI.CurTime

				if GameLogic.cur_Rewards.has("灭蚊灯"):
					_BasePay += 15
					GameLogic.call_Info(1, "灭蚊灯")
				elif GameLogic.cur_Rewards.has("灭蚊灯+"):
					_BasePay += 45
					GameLogic.call_Info(1, "灭蚊灯+")
				if GameLogic.cur_Rewards.has("饥饿营销new"):
					var _NUM = GameLogic.Order.cur_OrderList.size()
					_BaseMult += (_NUM - 1) * 0.3 * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "饥饿营销new", _NUM - 1)
				elif GameLogic.cur_Rewards.has("饥饿营销new+"):
					var _NUM = GameLogic.Order.cur_OrderList.size()
					_BaseMult += (_NUM - 1) * 0.9 * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "饥饿营销new+", _NUM - 1)
				if GameLogic.cur_Rewards.has("极限加价"):

					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Nearly)
					_PayMult += 0.03 * _MULT * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "极限加价", _MULT, true)
				if GameLogic.cur_Rewards.has("极限加价+"):

					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Nearly)
					_PayMult += 0.09 * _MULT * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "极限加价+", _MULT, true)






				if GameLogic.cur_Rewards.has("极限手段"):
					GameLogic.call_Info(1, "极限手段")
					_BaseMult += float(GameLogic.cur_Combo) * 0.05 * GameLogic.return_Multiplayer()

				if PointType == 0:
					if GameLogic.cur_Rewards.has("极限好评"):
						GameLogic.call_Info(1, "极限好评")
						_PopularNum += 15 * GameLogic.return_Multiplayer()
					elif GameLogic.cur_Rewards.has("极限好评+"):
						GameLogic.call_Info(1, "极限好评+")
						_PopularNum += 45 * GameLogic.return_Multiplayer()


				if GameLogic.cur_Rewards.has("极限出杯"):
					GameLogic.call_Info(1, "极限出杯")

					_BaseMult += 0.5 * GameLogic.cur_Day * GameLogic.return_Multiplayer()

				elif GameLogic.cur_Rewards.has("极限出杯+"):
					GameLogic.call_Info(1, "极限出杯+")

					_BaseMult += 1.5 * GameLogic.cur_Day * GameLogic.return_Multiplayer()

				if GameLogic.cur_Challenge.has("准时承诺"):
					GameLogic.call_Info(2, "准时承诺")
					_PlayerPressure += 1

				if GameLogic.cur_Challenge.has("准时承诺+"):
					GameLogic.call_Info(2, "准时承诺+")
					_PlayerPressure += 2
			else:
				if GameLogic.curLevelList.has("难度-极限出杯"):
					_TotalCheck = false


		if _CUPID != _OrderList.front():

			IsJump = true
			if _CUPID > GameLogic.cur_SkipID:
				GameLogic.cur_SkipID = _CUPID


		else:
			if GameLogic.cur_Rewards.has("品牌商标"):

				if _CUPID < GameLogic.cur_SkipID:
					GameLogic.call_Info(1, "品牌商标")
					IsJump = true
			elif GameLogic.cur_Rewards.has("品牌商标+"):
				if _CUPID < GameLogic.cur_SkipID:
					GameLogic.call_Info(1, "品牌商标+")
					IsJump = true
					_TipMult += 5

		if IsJump:
			GameLogic.Day_JustJump += 1
			GameLogic.cur_Skipping += 1
			GameLogic.level_Skipping += 1

			if IsQuick:
				GameLogic.cur_QuickAndSkip += 1
			if GameLogic.cur_Rewards.has("跳跃连击") and _CANCOMBO:
				GameLogic.call_Info(1, "跳跃连击")
				_COMBO += 1

			if GameLogic.cur_Rewards.has("安抚蛋糕"):
				GameLogic.call_Info(1, "安抚蛋糕")
				for _KEY in _OrderList:
					if int(_CUPID) > (_KEY):
						var _NPC = GameLogic.Order.cur_OrderList[_KEY].NPC


						_NPC._REWAITTIME += 0.05 * GameLogic.return_Multiplayer()

					else:
						break
			elif GameLogic.cur_Rewards.has("安抚蛋糕+"):
				GameLogic.call_Info(1, "安抚蛋糕+")
				for _KEY in _OrderList:
					if int(_CUPID) > (_KEY):
						var _NPC = GameLogic.Order.cur_OrderList[_KEY].NPC

						var _TIME = 0.15 * GameLogic.return_Multiplayer()
						_NPC._REWAITTIME += _TIME

					else:
						break

			if GameLogic.cur_Rewards.has("连续跳单小费"):
				var _SkipNum = abs(int(GameLogic.Day_JustJump)) - 1
				if _SkipNum > 0:
					var _MULT = GameLogic.return_Multiplayer_Num(_SkipNum)
					_TipMult += _MULT * 0.3 * GameLogic.return_Multiplayer()

					GameLogic.call_Info(1, "连续跳单小费", int(_MULT), true)

			if GameLogic.cur_Rewards.has("连续跳票"):
				var _SkipNum = abs(int(GameLogic.Day_JustJump)) - 1
				if _SkipNum > 0:
					var _MULT: float = GameLogic.return_Multiplayer_Num(_SkipNum)
					GameLogic.call_Info(1, "连续跳票", int(_MULT), true)
					_PayMult += _MULT * 0.15 * GameLogic.return_Multiplayer()


			if GameLogic.cur_Rewards.has("VIP服务"):
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Nearly)
				GameLogic.call_Info(1, "VIP服务", int(_MULT), true)
				_PayMult += _MULT * 0.1 * GameLogic.return_Multiplayer()
			if PointType == 0:


				if GameLogic.cur_Rewards.has("圆顶杯盖"):
					if _CUPID > _OrderList.front():
						var _SKIPID = int(_CUPID) - int(_OrderList[0])
						var _SKIP = GameLogic.return_Multiplayer_Num(int(_SKIPID))

						GameLogic.call_Info(1, "圆顶杯盖", _SKIP, true)
						_TipMult += float(_SKIP) * 0.2 * GameLogic.return_Multiplayer()

				elif GameLogic.cur_Rewards.has("圆顶杯盖+"):
					if _CUPID > _OrderList.front():
						var _SKIPID = int(_CUPID) - int(_OrderList[0])
						var _SKIP = GameLogic.return_Multiplayer_Num(int(_SKIPID))
						GameLogic.call_Info(1, "圆顶杯盖+", _SKIP, true)
						_TipMult += float(_SKIP) * 0.4 * GameLogic.return_Multiplayer()

			if GameLogic.cur_Rewards.has("跳单减压"):
				GameLogic.call_Info(1, "跳单减压")
				_Pressure -= 1
			if GameLogic.cur_Rewards.has("跳单减压+"):
				GameLogic.call_Info(1, "跳单减压+")
				_Pressure -= 2
			if GameLogic.cur_Rewards.has("跳单声望"):
				GameLogic.call_Info(1, "跳单声望")
				_PopularNum += 20 * GameLogic.return_Multiplayer()
			if GameLogic.cur_Rewards.has("跳单声望+"):
				GameLogic.call_Info(1, "跳单声望+")
				_PopularNum += 60 * GameLogic.return_Multiplayer()
		else:
			GameLogic.Day_JustJump = 0
			if GameLogic.curLevelList.has("难度-跳单出杯"):
				_TotalCheck = false
		if not IsJump or not IsQuick:
			GameLogic.cur_QuickAndSkip = 0

		if GameLogic.cur_Rewards.has("慢工细活new"):
			var _TIME = GameLogic.GameUI.CurTime - _OrderCurTime
			var _MULT: float = (GameLogic.GameUI.CurTime - _OrderCurTime) * 50
			_BaseMult += _MULT * 0.05
			GameLogic.call_Info(1, "慢工细活new", int(_MULT))
		if GameLogic.cur_Rewards.has("乱序叫号"):
			if GameLogic.LastSellID != 0 and IsJump:
				if GameLogic.LastSellID + 1 != PickUpID and GameLogic.LastSellID - 1 != PickUpID:
					_PayMult += 0.1 * GameLogic.cur_Skipping * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "乱序叫号", GameLogic.cur_Skipping)
		GameLogic.LastSellID = PickUpID


		if PointType == 0:
			_PointCheck = true
			_CritCheck = true
			GameLogic.call_StatisticsData_Set("Count_PerfectSell", null, 1)

		if GameLogic.cur_Rewards.has("营业执照+") and PointType in [0, 1]:
			_PointCheck = true
			GameLogic.call_Info(1, "营业执照+")
		if GameLogic.cur_Rewards.has("福气到"):
			_CritCheck = true
			GameLogic.call_Info(1, "福气到")
		elif GameLogic.cur_Rewards.has("福气到+") and PointType in [1]:
			_CritCheck = true
			GameLogic.call_Info(1, "福气到+")
		if _PointCheck:

			if IsJump:
				if GameLogic.cur_Rewards.has("吸管"):
					var _MULT = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "吸管")
					_TipMult += 0.1 * _MULT * GameLogic.return_Multiplayer()

				if GameLogic.cur_Rewards.has("吸管+"):
					var _MULT = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "吸管+")
					_TipMult += 0.3 * _MULT * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("杯套"):
					GameLogic.call_Info(1, "杯套")
					_TipMult += 1 * float(_INFO.Rank)

				if GameLogic.cur_Rewards.has("杯套+"):
					GameLogic.call_Info(1, "杯套+")
					_TipMult += 3 * float(_INFO.Rank)

				if GameLogic.cur_Rewards.has("跳单待定"):
					var _MULT: int = GameLogic.return_Multiplayer_Num(GameLogic.cur_Skipping)
					GameLogic.call_Info(1, "跳单待定", _MULT, true)
					_PayMult += 0.15 * _MULT * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("跳单待定+"):
					var _MULT: int = GameLogic.return_Multiplayer_Num(GameLogic.cur_Skipping)
					GameLogic.call_Info(1, "跳单待定+", _MULT, true)
					_PayMult += 0.3 * _MULT * GameLogic.return_Multiplayer()
			if GameLogic.cur_Combo < 2:
				if GameLogic.cur_Rewards.has("无COMBO加价"):
					GameLogic.call_Info(1, "无COMBO加价")
					_PayMult += 2
				elif GameLogic.cur_Rewards.has("无COMBO加价+"):
					GameLogic.call_Info(1, "无COMBO加价+")
					_PayMult += 5


		if GameLogic.cur_Rewards.has("消灾替身"):
			if NOPRESSURE:
				_PayMult += 3
				GameLogic.call_Info(1, "消灾替身")

		if NoPressure:



			if GameLogic.cur_Rewards.has("冰点连击"):
				GameLogic.call_Info(1, "冰点连击")
				_TipMult += float(GameLogic.cur_Combo) * 0.05 * GameLogic.return_Multiplayer()

			if GameLogic.cur_Rewards.has("轻松增价"):

				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_SellNum)
				_TipMult += 0.1 * _MULT * GameLogic.return_Multiplayer()
				GameLogic.call_Info(1, "轻松增价", int(_MULT), true)
			if GameLogic.cur_Rewards.has("轻松增价+"):
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_SellNum)
				_BaseMult += 0.3 * _MULT * GameLogic.return_Multiplayer()
				GameLogic.call_Info(1, "轻松增价+", int(_MULT), true)
			if GameLogic.cur_Rewards.has("无压加价"):

				GameLogic.call_Info(1, "无压加价")
				_PayMult += 0.5
			if GameLogic.cur_Rewards.has("无压加价+"):
				GameLogic.call_Info(1, "无压加价+")
				_PayMult += 1
				_TipMult += 0.5

		if GameLogic.cur_SellMenu == OrderName:

			GameLogic.Day_SellSameNum += 1
			var _MULT: float = 0

			_TipMult += _MULT
		elif GameLogic.cur_SellMenu != "":
			GameLogic.Day_SellDiffNum += 1
			if GameLogic.cur_Rewards.has("包罗万象"):
				var _MULTNUM: float = GameLogic.return_Multiplayer_Num(GameLogic.Day_SellDiffNum)
				GameLogic.call_Info(1, "包罗万象", int(_MULTNUM), true)
				_BaseMult += _MULTNUM * 0.2 * GameLogic.return_Multiplayer()
			elif GameLogic.cur_Rewards.has("包罗万象+"):
				var _MULTNUM: float = GameLogic.return_Multiplayer_Num(GameLogic.Day_SellDiffNum)
				GameLogic.call_Info(1, "包罗万象+", int(_MULTNUM), true)
				_BaseMult += _MULTNUM * 0.4 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Combo < 2:
			if GameLogic.cur_Rewards.has("无连加价"):
				GameLogic.call_Info(1, "无连加价")
				_PayMult += 1
			elif GameLogic.cur_Rewards.has("无连加价+"):
				GameLogic.call_Info(1, "无连加价+")
				_PayMult += 2.5

		if GameLogic.cur_Rewards.has("福气到"):
			GameLogic.call_Info(1, "福气到")
			_CriChance += 20
		elif GameLogic.cur_Rewards.has("福气到+"):
			GameLogic.call_Info(1, "福气到+")
			_CriChance += 40

		if GameLogic.cur_Rewards.has("丢单重点+"):

			if ReOrder:
				_PayMult += 2


		if PointType != 0:
			if GameLogic.cur_Challenge.has("小费限制"):
				GameLogic.call_Info(2, "小费限制")
				_TipMult -= 0.25
			if GameLogic.cur_Challenge.has("小费限制+"):
				GameLogic.call_Info(2, "小费限制+")
				_TipMult -= 0.5
			if GameLogic.cur_Challenge.has("小费限制++"):
				GameLogic.call_Info(2, "小费限制++")
				_TipMult -= 1

		if GameLogic.cur_Rewards.has("加班加单价"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_SellNum)
				GameLogic.call_Info(1, "加班加单价", int(_MULT), true)
				_PayMult += 0.1 * _MULT * GameLogic.return_Multiplayer()
		if GameLogic.cur_Rewards.has("加班加单价+"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_SellNum)
				GameLogic.call_Info(1, "加班加单价+", int(_MULT), true)
				_PayMult += 0.3 * _MULT * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("高压不断连"):
			if _HighPressure:
				_BaseMult += float(GameLogic.cur_Combo) * 0.01 * GameLogic.return_Multiplayer()
				GameLogic.call_Info(1, "高压不断连")



		if GameLogic.cur_Rewards.has("纸扇"):
			var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_SellNum)
			GameLogic.call_Info(1, "纸扇", int(_MULT), true)
			_CriChance += _MULT * 1 * GameLogic.return_Multiplayer()
		elif GameLogic.cur_Rewards.has("纸扇+"):
			var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_SellNum)
			GameLogic.call_Info(1, "纸扇+", int(_MULT), true)

			_CriChance += _MULT * 3 * GameLogic.return_Multiplayer()
			pass
		if GameLogic.cur_Rewards.has("首杯暴击"):
			if GameLogic.cur_SellNum == 0:
				_CriChance += 1000
				NeedCri = true
		elif GameLogic.cur_Rewards.has("首杯暴击+"):
			if GameLogic.cur_SellNum <= 1:
				_CriChance += 1000
				NeedCri = true

		if _CritCheck or NeedCri:
			if GameLogic.Achievement.cur_EquipList.has("暴击率增加") and not GameLogic.SPECIALLEVEL_Int:
				_CriChance += 10
			if GameLogic.cur_Rewards.has("完美碧玉"):

				var _MULT: float = 1 * float(_INFO.Rank)
				GameLogic.call_Info(1, "完美碧玉")
				_CriMult += _MULT
			if GameLogic.cur_Rewards.has("完美碧玉+"):

				var _MULT: float = 3 * float(_INFO.Rank)
				GameLogic.call_Info(1, "完美碧玉+")
				_CriMult += _MULT
			if GameLogic.cur_Rewards.has("出手阔绰"):

				var _MULT: float = GameLogic.return_Multiplayer_Num(int(_CUPID))
				GameLogic.call_Info(1, "出手阔绰", int(_MULT), true)
				_CriMult += 0.1 * _MULT * GameLogic.return_Multiplayer()
			if GameLogic.cur_Rewards.has("出手阔绰+"):

				var _MULT: float = GameLogic.return_Multiplayer_Num(int(_CUPID))
				GameLogic.call_Info(1, "出手阔绰+", int(_MULT), true)
				_CriMult += 0.3 * _MULT * GameLogic.return_Multiplayer()
			if not GameLogic.SPECIALLEVEL_Int:
				if GameLogic.Save.gameData.HomeDevList.has("游戏收纳架"):
					_CriChance += 1
				if GameLogic.Save.gameData.HomeDevList.has("唱片盒"):
					_CriChance += 1
				if GameLogic.Save.gameData.HomeDevList.has("吉他"):
					_CriChance += 1
				if GameLogic.Save.gameData.HomeDevList.has("浴室花洒"):
					_CriChance += 1
				if GameLogic.Save.gameData.HomeDevList.has("施肥工具"):
					_CriChance += 1

			if GameLogic.cur_Rewards.has("暴击单价"):
				GameLogic.call_Info(1, "暴击单价", GameLogic.cur_Perfect)
				_BaseMult += float(GameLogic.cur_Perfect) * 0.05 * GameLogic.return_Multiplayer()


			if GameLogic.cur_Rewards.has("爆炸灯笼"):
				GameLogic.call_Info(1, "爆炸灯笼")

				_CriMult += float(GameLogic.cur_Combo) * 0.1 * GameLogic.return_Multiplayer()

			if GameLogic.cur_Rewards.has("快出暴击"):
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Quickly)
				GameLogic.call_Info(1, "快出暴击", int(_MULT), true)
				_CriMult += _MULT * 0.3 * GameLogic.return_Multiplayer()

			if GameLogic.cur_Event == "暴击日":
				_CriChance += 25 * GameLogic.return_Multiplayer()
			if GameLogic.cur_Challenge.has("随机折扣"):
				var _rand = GameLogic.return_randi() % 4
				if _rand == 0:
					GameLogic.call_Info(2, "随机折扣")
					_CriChance -= 5
			if GameLogic.cur_Challenge.has("随机折扣+"):
				var _rand = GameLogic.return_randi() % 4
				if _rand == 0:
					GameLogic.call_Info(2, "随机折扣+")
					_CriChance -= 10
			if GameLogic.cur_Challenge.has("随机折扣++"):
				var _rand = GameLogic.return_randi() % 4
				if _rand == 0:
					GameLogic.call_Info(2, "随机折扣++")
					_CriChance -= 20


			if (_CritCheck and _CriRand <= _CriChance + CRIBONUS) or IsCri:



				if GameLogic.Day_JustCri > 0:
					if GameLogic.cur_Rewards.has("下次暴击"):
						GameLogic.call_Info(1, "下次暴击")
					elif GameLogic.cur_Rewards.has("下次暴击+"):
							GameLogic.call_Info(1, "下次暴击+")

				IsCri = true
				GameLogic.call_StatisticsData_Set("Count_Cri", null, 1)

				if GameLogic.Day_JustCri < 0:
					GameLogic.Day_JustCri = 0
				GameLogic.cur_Cri += 1
				GameLogic.level_Cri += 1
				GameLogic.Day_JustCri += 1


				if GameLogic.Day_JustCri > 1:
					if GameLogic.cur_Rewards.has("发财鞭炮"):
						var _MULTNUM: float = GameLogic.return_Multiplayer_Num(GameLogic.Day_JustCri)
						var _MULT = _MULTNUM * 0.3 * GameLogic.return_Multiplayer()
						GameLogic.call_Info(1, "发财鞭炮", int(_MULT), true)
						_CriMult += _MULT
					elif GameLogic.cur_Rewards.has("发财鞭炮+"):
						var _MULTNUM: float = GameLogic.return_Multiplayer_Num(GameLogic.Day_JustCri)
						var _MULT = _MULTNUM * 0.6 * GameLogic.return_Multiplayer()
						GameLogic.call_Info(1, "发财鞭炮", int(_MULT), true)
						_CriMult += _MULT

				if GameLogic.cur_Rewards.has("捡来好运"):
					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Cri)
					GameLogic.call_Info(1, "捡来好运", int(_MULT), true)
					_BasePay += 2 * _MULT * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("幸运结"):
					if IsQuick:

						GameLogic.call_Info(1, "幸运结")
						_CriMult += 15
				if GameLogic.cur_Rewards.has("喜庆窗花"):
					var _MULT: float = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "喜庆窗花", int(_MULT), true)
					_CriMult += _MULT * 0.1 * GameLogic.return_Multiplayer()

				elif GameLogic.cur_Rewards.has("喜庆窗花+"):
					var _MULT: float = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "喜庆窗花+", int(_MULT), true)
					_CriMult += _MULT * 0.3 * GameLogic.return_Multiplayer()

				if GameLogic.cur_Rewards.has("跳单暴击"):
					if IsCri:
						var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Skipping)
						_CriMult += 0.3 * _MULT * GameLogic.return_Multiplayer()
						GameLogic.call_Info(1, "跳单暴击", int(_MULT), true)
				if GameLogic.Day_JustCri > 0:
					if GameLogic.cur_Rewards.has("下次暴击"):
						_CriMult += float(_CriChance + CRIBONUS) * 0.02 * GameLogic.return_Multiplayer()
						GameLogic.call_Info(1, "下次暴击")

				if GameLogic.cur_Rewards.has("不找零"):
					GameLogic.call_Info(1, "不找零", GameLogic.cur_Cri)
					_CriMult += 0.75 * GameLogic.return_Multiplayer()
					_TipMult += 0.75 * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("命运之愿") and IsCri:
					var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Cri)
					GameLogic.call_Info(1, "命运之愿", int(_MULT), true)
					_CriMult += 0.1 * _MULT * GameLogic.return_Multiplayer()
					_PlayerPressure -= 1

				if GameLogic.cur_Rewards.has("暴击增强"):
					GameLogic.call_Info(1, "暴击增强", int(_CriChance + CRIBONUS))
					_CriMult += float(_CriChance + CRIBONUS) * 0.02 * GameLogic.return_Multiplayer()
				elif GameLogic.cur_Rewards.has("暴击增强+"):
					GameLogic.call_Info(1, "暴击增强+", int(_CriChance + CRIBONUS))
					_CriMult += float(_CriChance + CRIBONUS) * 0.06 * GameLogic.return_Multiplayer()
				if GameLogic.cur_Rewards.has("连串铜币"):
					var _MULTNUM: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Cri)
					var _MULT = _MULTNUM * 0.2 * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "连串铜币", int(_MULTNUM), true)
					_CriMult += _MULT
				elif GameLogic.cur_Rewards.has("连串铜币+"):
					var _MULTNUM: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Cri)
					var _MULT = _MULTNUM * 0.4 * GameLogic.return_Multiplayer()
					GameLogic.call_Info(1, "连串铜币+", int(_MULTNUM), true)
					_CriMult += _MULT




			else:
				if GameLogic.Day_JustCri > 0:
					GameLogic.Day_JustCri = 0

				GameLogic.Day_JustCri -= 1
				if GameLogic.curLevelList.has("难度-暴击出杯"):
					_TotalCheck = false

		if GameLogic.cur_Rewards.has("加压"):
			GameLogic.call_Info(1, "加压")
			_TipMult += 1 * GameLogic.cur_Day * GameLogic.return_Multiplayer()
		elif GameLogic.cur_Rewards.has("加压+"):
			GameLogic.call_Info(1, "加压+")
			_TipMult += 3 * GameLogic.cur_Day * GameLogic.return_Multiplayer()

		var _BASEPAYMULT: float = 1
		if GameLogic.cur_Challenge.has("补差价"):
			if PointType in [1, 2]:
				GameLogic.call_Info(2, "补差价")
				_BASEPAYMULT -= 0.25

		if GameLogic.cur_Challenge.has("补差价+"):
			if PointType in [1, 2]:
				GameLogic.call_Info(2, "补差价+")
				_BASEPAYMULT -= 0.5

		if GameLogic.cur_Combo < 2:
			if GameLogic.cur_Challenge.has("推广促销"):
				GameLogic.call_Info(2, "推广促销")
				_BASEPAYMULT -= 0.1
			if GameLogic.cur_Challenge.has("推广促销+"):
				GameLogic.call_Info(2, "推广促销+")
				_BASEPAYMULT -= 0.2
			if GameLogic.cur_Challenge.has("推广促销++"):
				GameLogic.call_Info(2, "推广促销++")
				_BASEPAYMULT -= 0.4

		if _BASEPAYMULT < 0:
			_BASEPAYMULT = 0
		_BasePay = _BasePay * _BASEPAYMULT

		if BONUSDIC["Run"] in [1]:
			var _BONUSPLUS: float
			match SteamLogic.PlayerNum:
				1:
					_BONUSPLUS = 1
				2:
					_BONUSPLUS = 0.5
				3:
					_BONUSPLUS = 0.33
				4:
					_BONUSPLUS = 0.25
			_BaseMult += _BONUSPLUS
		if BONUSDIC["Panda"] in [2]:
			var _BONUSPLUS: float
			_BONUSPLUS = 0.05 / GameLogic.return_Multiplayer()

			_PayMult += _BONUSPLUS


		var _RANDCHECK: int = 0
		if GameLogic.cur_Challenge.has("小费减少"):
			_RANDCHECK += 5
		if GameLogic.cur_Challenge.has("小费减少+"):
			_RANDCHECK += 10
		if GameLogic.cur_Challenge.has("小费减少++"):
			_RANDCHECK += 20
		if _RANDCHECK > 0:
			var _RAND = GameLogic.return_randi() % 100
			if _RAND < _RANDCHECK:
				_Tip = 0
				if GameLogic.cur_Challenge.has("小费减少"):
					GameLogic.call_Info(2, "小费减少")
				if GameLogic.cur_Challenge.has("小费减少+"):
					GameLogic.call_Info(2, "小费减少+")
				if GameLogic.cur_Challenge.has("小费减少++"):
					GameLogic.call_Info(2, "小费减少++")

		if GameLogic.Achievement.cur_EquipList.has("饮品加价") and not GameLogic.SPECIALLEVEL_Int:
			_PayMult += 0.1
		if ServiceList.has("Miss"):
			_TipMult -= 0.5
			_Pressure += 1

		elif ServiceList.has("Perfect"):
			_TipMult += 1
		if _Pay < 0:
			_Pay = 0

		for _KEY in _OrderList:
			var _NPC = GameLogic.Order.cur_OrderList[_KEY].NPC
			if is_instance_valid(_NPC):
				_NPC.call_ReWait()
			else:
				GameLogic.Order.cur_OrderList.erase(_KEY)








		if GameLogic.cur_Rewards.has("勉强微笑"):
			if _HighPressure:

				GameLogic.call_Info(1, "勉强微笑")
				_TipMult += 1 * GameLogic.cur_Day
		elif GameLogic.cur_Rewards.has("勉强微笑+"):
			if _HighPressure:

				GameLogic.call_Info(1, "勉强微笑+")
				_TipMult += 3 * GameLogic.cur_Day

		if GameLogic.cur_Rewards.has("慷慨花环"):
			var _NUM = GameLogic.return_Multiplayer_Num(int(_CUPID))
			GameLogic.call_Info(1, "慷慨花环", int(_NUM), true)
			_Tip += _NUM * 1 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("慷慨花环+"):
			var _NUM = GameLogic.return_Multiplayer_Num(int(_CUPID))
			GameLogic.call_Info(1, "慷慨花环+", int(_NUM), true)
			_Tip += _NUM * 2 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("拒绝找零"):
			var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Cri)
			GameLogic.call_Info(1, "拒绝找零", int(_MULT), true)
			_Tip += _MULT * 3 * GameLogic.return_Multiplayer()


		if GameLogic.cur_Rewards.has("好评如潮"):
			var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Perfect)
			_TipMult += 0.15 * _MULT * GameLogic.return_Multiplayer()
			GameLogic.call_Info(1, "好评如潮", int(_MULT), true)
		elif GameLogic.cur_Rewards.has("好评如潮+"):
			var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Perfect)
			_TipMult += 0.3 * _MULT * GameLogic.return_Multiplayer()
			GameLogic.call_Info(1, "好评如潮+", int(_MULT), true)
		if IsSlow:
			if GameLogic.cur_Rewards.has("时间沙漏"):

				_BaseMult += 0.75 * GameLogic.cur_Day
				GameLogic.call_Info(1, "时间沙漏")

			elif GameLogic.cur_Rewards.has("时间沙漏+"):

				_BaseMult += 2.25 * GameLogic.cur_Day
				GameLogic.call_Info(1, "时间沙漏+")
			if GameLogic.cur_Rewards.has("心理战术"):
				var _MULT: int = GameLogic.cur_Nearly
				_BaseMult += _MULT * 0.15 * GameLogic.return_Multiplayer()
				GameLogic.call_Info(1, "心理战术", _MULT)

			elif GameLogic.cur_Rewards.has("心理战术+"):
				var _MULT: int = GameLogic.cur_Nearly
				_BaseMult += _MULT * 0.3 * GameLogic.return_Multiplayer()
				GameLogic.call_Info(1, "心理战术+", _MULT)
			if GameLogic.cur_Rewards.has("绝对极限new"):
				var _TIMERAT: int = 100 - int(SellTimeRat * 100)
				_BaseMult += _TIMERAT * 0.1
				GameLogic.call_Info(1, "绝对极限new", _TIMERAT)

			elif GameLogic.cur_Rewards.has("绝对极限new+"):
				var _TIMERAT: int = 100 - int(SellTimeRat * 100)
				_BaseMult += _TIMERAT * 0.2
				GameLogic.call_Info(1, "绝对极限new+", _TIMERAT)
		var _TipBaseMult: float = 0.2
		if GameLogic.cur_Rewards.has("营业执照"):
			_TipBaseMult += 0.25
			GameLogic.call_Info(1, "营业执照")
		elif GameLogic.cur_Rewards.has("营业执照+"):
			_TipBaseMult += 0.5

		if GameLogic.cur_Rewards.has("排班表"):
			if SellerPRE > 1:
				SellerPRE = 1
			var _PREMULT = abs(SellerPRE) * 100
			GameLogic.call_Info(1, "排班表", str(_PREMULT) + "%")
			_TipMult += 0.2 * _PREMULT
		elif GameLogic.cur_Rewards.has("排班表+"):
			if SellerPRE > 1:
				SellerPRE = 1
			var _PREMULT = abs(SellerPRE) * 100
			GameLogic.call_Info(1, "排班表+", str(_PREMULT) + "%")
			_TipMult += 0.4 * _PREMULT
		if GameLogic.cur_Rewards.has("肾上腺素new"):
			if IsCri:
				var _MULT = abs(SellerCur)
				if _MULT > SellerMax:
					_MULT = SellerMax
				GameLogic.call_Info(1, "肾上腺素new", int(abs(_MULT)))
				_PayMult += 0.1 * _MULT
		if GameLogic.cur_Rewards.has("快乐心情"):
			if GameLogic.GameUI.CurTime > SellerTime + 0.5:
				var _TIMELEFT = GameLogic.GameUI.CurTime - SellerTime
				_TipMult += 3 * _TIMELEFT
				GameLogic.call_Info(1, "快乐心情", str(_TIMELEFT))
		if GameLogic.cur_Rewards.has("暴力营销"):
			var _MULT = abs(SellerCur)
			GameLogic.call_Info(1, "暴力营销", int(abs(_MULT)))
			_TipMult += _MULT * 0.3

		if SellerNoPre:
			if GameLogic.cur_Rewards.has("争分夺秒"):
				if IsQuick:
					for _KEY in _OrderList:
						var _NPC = GameLogic.Order.cur_OrderList[_KEY].NPC

						_NPC._REWAITTIME += 0.25 * GameLogic.return_Multiplayer()
						_NPC.call_ReWait()
					GameLogic.call_Info(1, "争分夺秒")
			if GameLogic.cur_Rewards.has("内卷饭碗"):
				_TipBaseMult += 0.2
				GameLogic.call_Info(1, "内卷饭碗")
			elif GameLogic.cur_Rewards.has("内卷饭碗+"):
				_TipBaseMult += 0.4
				GameLogic.call_Info(1, "内卷饭碗+")
			if GameLogic.cur_Rewards.has("杂物篮"):
				var _NUM = float(_INFO["Rank"])
				_TipMult += 1 * _NUM
				GameLogic.call_Info(1, "杂物篮")
			elif GameLogic.cur_Rewards.has("杂物篮+"):
				var _NUM = int(_INFO["Rank"])
				_TipMult += 3 * _NUM
				GameLogic.call_Info(1, "杂物篮+")
			if GameLogic.cur_Rewards.has("流浪捐助箱"):
				var _SKIP = GameLogic.return_Multiplayer_Num(int(_CUPID))
				GameLogic.call_Info(1, "流浪捐助箱", str(_SKIP), true)
				_TipMult += 0.1 * _SKIP * GameLogic.return_Multiplayer()
			elif GameLogic.cur_Rewards.has("流浪捐助箱+"):
				var _SKIP = GameLogic.return_Multiplayer_Num(int(_CUPID))
				GameLogic.call_Info(1, "流浪捐助箱+", str(_SKIP), true)
				_TipMult += 0.3 * _SKIP * GameLogic.return_Multiplayer()
		if SellerHighPre:


			if GameLogic.cur_Rewards.has("风驰电掣"):
				if IsQuick:
					var _MULT = GameLogic.return_Multiplayer_Num(int(_CUPID))
					GameLogic.call_Info(1, "风驰电掣", int(_MULT), true)
					_PayMult = _MULT * 0.1 * GameLogic.return_Multiplayer()
			if GameLogic.cur_Rewards.has("外放音响"):
				_TipBaseMult += 0.2
				GameLogic.call_Info(1, "外放音响")
			elif GameLogic.cur_Rewards.has("外放音响+"):
				_TipBaseMult += 0.4
				GameLogic.call_Info(1, "外放音响+")
			if GameLogic.cur_Rewards.has("招财猫"):

				var _MULT: float = GameLogic.cur_Perfect
				GameLogic.call_Info(1, "招财猫", _MULT)
				_TipMult += 0.15 * _MULT * GameLogic.return_Multiplayer()
			elif GameLogic.cur_Rewards.has("招财猫+"):
				var _MULT: float = GameLogic.cur_Perfect
				GameLogic.call_Info(1, "招财猫+", _MULT)
				_TipMult += 0.45 * _MULT * GameLogic.return_Multiplayer()
			if GameLogic.cur_Rewards.has("压力山大"):

				GameLogic.call_Info(1, "压力山大", int(GameLogic.cur_SellNum))
				_BaseMult += GameLogic.cur_SellNum * 0.2 * GameLogic.return_Multiplayer()
		else:
			if GameLogic.curLevelList.has("难度-高压出杯"):
				_TotalCheck = false
		if SellerCur < 0:
			if GameLogic.cur_Rewards.has("超负荷小窝"):
				GameLogic.call_Info(1, "超负荷小窝")
				_TipMult += abs(SellerCur) * 0.25
			elif GameLogic.cur_Rewards.has("超负荷小窝+"):
				GameLogic.call_Info(1, "超负荷小窝+")
				_TipMult += abs(SellerCur) * 0.5

		if GameLogic.cur_Rewards.has("零花钱"):
			GameLogic.call_Info(1, "零花钱")
			_TipMult += GameLogic.cur_Combo * 0.02 * GameLogic.return_Multiplayer()
		elif GameLogic.cur_Rewards.has("零花钱+"):
			GameLogic.call_Info(1, "零花钱+")
			_TipMult += GameLogic.cur_Combo * 0.06 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("照片墙"):
			GameLogic.call_Info(1, "照片墙")
			_BaseMult += GameLogic.cur_Combo * 0.015 * GameLogic.return_Multiplayer()
		elif GameLogic.cur_Rewards.has("照片墙+"):
			GameLogic.call_Info(1, "照片墙+")
			_BaseMult += GameLogic.cur_Combo * 0.045 * GameLogic.return_Multiplayer()
		if GameLogic.cur_Rewards.has("猪猪罐"):
			if GameLogic.cur_Combo > 1:
				GameLogic.call_Info(1, "猪猪罐")
				_PayMult += float(GameLogic.cur_Combo) * 0.01 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("猪猪罐+"):
			if GameLogic.cur_Combo > 1:
				GameLogic.call_Info(1, "猪猪罐+")
				_PayMult += float(GameLogic.cur_Combo) * 0.02 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("飞来横财"):
			if GameLogic.cur_Combo > 1:
				GameLogic.call_Info(1, "飞来横财")
				_Tip += float(GameLogic.cur_Combo) * 0.75 * GameLogic.return_Multiplayer()

		if GameLogic.cur_Rewards.has("陪伴玩偶"):


			var _RANDMAX = 25 * GameLogic.return_Multiplayer()
			var _RAND = GameLogic.return_randi() % 100
			if _RAND < _RANDMAX:
				GameLogic.call_Info(1, "陪伴玩偶")
				_PlayerPressure -= 1
		elif GameLogic.cur_Rewards.has("陪伴玩偶+"):
			var _RANDMAX = 25 * GameLogic.return_Multiplayer()
			var _RAND = GameLogic.return_randi() % 100
			if _RAND <= _RANDMAX:
				GameLogic.call_Info(1, "陪伴玩偶+")
				_PlayerPressure -= 3
		if GameLogic.cur_Rewards.has("高额小费"):


			var _RAND = GameLogic.return_randi() % 4
			if _RAND == 0:
				GameLogic.call_Info(1, "高额小费")
				_PlayerPressure -= 1
		elif GameLogic.cur_Rewards.has("高额小费+"):
			GameLogic.call_Info(1, "高额小费+")

			var _RAND = GameLogic.return_randi() % 4
			if _RAND <= 2:
				GameLogic.call_Info(1, "高额小费+")
				_PlayerPressure -= 1
		if GameLogic.cur_Rewards.has("高压小费"):
			if SellerHighPre:
				var _SELLERPRE: int = int(abs(SellerPRE) * 100)
				_TipMult += int(abs(_SELLERPRE) * 0.2 * GameLogic.return_Multiplayer())
				GameLogic.call_Info(1, "高压小费", _SELLERPRE)
		if GameLogic.cur_Rewards.has("极限累计"):
			if IsJump:
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Nearly)
				_PayMult += _MULT * 0.05 * GameLogic.return_Multiplayer()
				GameLogic.call_Info(1, "极限累计", int(_MULT), true)
		if GameLogic.cur_Rewards.has("值夜班"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				GameLogic.call_Info(1, "值夜班")
				_BaseMult += 1 * float(_INFO.Rank)
		if GameLogic.cur_Rewards.has("值夜班+"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				GameLogic.call_Info(1, "值夜班+")
				_BaseMult += 3 * float(_INFO.Rank)


		if GameLogic.cur_Rewards.has("泄压急救"):
			if IsSlow:
				var _MULT: float = GameLogic.return_Multiplayer_Num(GameLogic.cur_Nearly)
				_PayMult += _MULT * 0.05 * GameLogic.return_Multiplayer()

				var _RAND = GameLogic.return_randi() % 2
				if _RAND:
					_PlayerPressure -= 1
				GameLogic.call_Info(1, "泄压急救", int(_MULT), true)


		if GameLogic.cur_Rewards.has("平稳心电new"):
			if not IsQuick and not IsJump and not IsSlow:
				_PayMult += 5
				GameLogic.call_Info(1, "平稳心电new")



		if GameLogic.cur_Rewards.has("完美一天"):

			_BaseMult += 0.15 * _TipMult
			_TipMult += 0.15 * _BaseMult
			GameLogic.call_Info(1, "完美一天")

		if GameLogic.cur_Rewards.has("好运锦鲤"):
			if IsCri and IsJump:
				var _MULT: float = 0.1 * (_CriMult - 1)
				_PayMult += _MULT
				GameLogic.call_Info(1, "好运锦鲤", int((_CriMult - 1) * 100))
		if GameLogic.cur_Rewards.has("极限榨取"):
			if IsSlow:
				var _MULT: float = 0.1 * _TipMult
				_PayMult += _MULT
				GameLogic.call_Info(1, "极限榨取", int(_MULT * 100))

		if GameLogic.cur_Event == "加糖日" or GameLogic.cur_Event == "加冰日":
			_PayMult += 1
		_Pay += _BasePay
		var _BaseTip: float = _Pay * _TipBaseMult
		if _BaseTip < 1:
			_BaseTip = 1
		if GameLogic.Achievement.cur_EquipList.has("服务费") and not GameLogic.SPECIALLEVEL_Int:
			_BaseTip += 1
		_Tip += _BaseTip

		if _TipMult < 0:
			_TipMult = 0
		if _PayMult < 0:
			_PayMult = 0
		if _BaseMult < 0:
			_BaseMult = 0
		if not _PointCheck:
			_Tip = 0
		if _Tip < 0:
			_Tip = 0
		if _Pay < 0:
			_Pay = 0

		_Tip = _Tip * (_TipMult + _PayMult)
		var _CriPay = 0
		if IsCri:
			_CriPay = float(_Pay) * (_CriMult + _PayMult)
		_Pay = _Pay * (_BaseMult + _PayMult) + _CriPay
		_Tip += TipBonus

		var _TipCHECK: float = 0
		if GameLogic.cur_Challenge.has("抹去零头"):
			GameLogic.call_Info(2, "抹去零头")
			_TipCHECK += 0.05
		if GameLogic.cur_Challenge.has("抹去零头+"):
			GameLogic.call_Info(2, "抹去零头+")
			_TipCHECK += 0.1
		if GameLogic.cur_Challenge.has("抹去零头++"):
			GameLogic.call_Info(2, "抹去零头++")
			_TipCHECK += 0.2
		if _TipCHECK > 0:
			if _TipCHECK > 1:
				_TipCHECK = 1
			_Tip = _Tip * (1 - _TipCHECK)
		var _FINALCHECK: float = 0
		if PointType > 0:

			if GameLogic.cur_Challenge.has("制作不规范"):
				GameLogic.call_Info(2, "制作不规范")
				_FINALCHECK += 0.1
			if GameLogic.cur_Challenge.has("制作不规范+"):
				GameLogic.call_Info(2, "制作不规范+")
				_FINALCHECK += 0.2
			if GameLogic.cur_Challenge.has("制作不规范++"):
				GameLogic.call_Info(2, "制作不规范++")
				_FINALCHECK += 0.4

			if PointType in [1, 2]:
				var _NOGET: int = 0
				if GameLogic.cur_Challenge.has("退单"):
					_NOGET += 25
				if GameLogic.cur_Challenge.has("退单+"):
					_NOGET += 50
				if _NOGET > 0:
					var _rand = GameLogic.return_randi() % 100
					if _rand < _NOGET:
						_Pay = 0
						_Tip = 0
						if GameLogic.cur_Challenge.has("退单"):
							GameLogic.call_Info(2, "退单")
						if GameLogic.cur_Challenge.has("退单+"):
							GameLogic.call_Info(2, "退单+")
		if NoPressure:
			if GameLogic.cur_Challenge.has("无压折扣"):
				GameLogic.call_Info(2, "无压折扣")
				_FINALCHECK -= 0.05
			if GameLogic.cur_Challenge.has("无压折扣+"):
				GameLogic.call_Info(2, "无压折扣+")
				_FINALCHECK -= 0.1
			if GameLogic.cur_Challenge.has("无压折扣++"):
				GameLogic.call_Info(2, "无压折扣++")
				_FINALCHECK -= 0.2
		if SellerHasPre:
			var _RANDNUM: int = 0
			if GameLogic.cur_Challenge.has("有压无小费"):
				_RANDNUM += 5
			if GameLogic.cur_Challenge.has("有压无小费+"):
				_RANDNUM += 10
			if GameLogic.cur_Challenge.has("有压无小费++"):
				_RANDNUM += 20
			if _RANDNUM > 0:
				var _RAND = GameLogic.return_randi() % 100
				if _RAND < _RANDNUM:
					_Tip = 0
					if GameLogic.cur_Challenge.has("有压无小费"):
						GameLogic.call_Info(2, "有压无小费")
					if GameLogic.cur_Challenge.has("有压无小费+"):
						GameLogic.call_Info(2, "有压无小费+")
					if GameLogic.cur_Challenge.has("有压无小费++"):
						GameLogic.call_Info(2, "有压无小费++")
		var _NOPAYNUM: int = 0
		if GameLogic.cur_Challenge.has("白嫖"):
			_NOPAYNUM += 4
		if GameLogic.cur_Challenge.has("白嫖+"):
			_NOPAYNUM += 8
		if GameLogic.cur_Challenge.has("白嫖++"):
			_NOPAYNUM += 16
		if _NOPAYNUM > 0:
			var _rand = GameLogic.return_randi() % 100
			if _rand < _NOPAYNUM:
				_Pay = 0
				if GameLogic.cur_Challenge.has("白嫖"):
					GameLogic.call_Info(2, "白嫖")
				if GameLogic.cur_Challenge.has("白嫖+"):
					GameLogic.call_Info(2, "白嫖+")
				if GameLogic.cur_Challenge.has("白嫖++"):
					GameLogic.call_Info(2, "白嫖++")

		var _PAYPRICEMULT: float = 1
		if IsJump:
			if GameLogic.cur_Challenge.has("跳单折扣"):
				GameLogic.call_Info(2, "跳单折扣")
				_PAYPRICEMULT -= 0.1
			if GameLogic.cur_Challenge.has("跳单折扣+"):
				GameLogic.call_Info(2, "跳单折扣+")
				_PAYPRICEMULT -= 0.2
			if GameLogic.cur_Challenge.has("跳单折扣++"):
				GameLogic.call_Info(2, "跳单折扣++")
				_PAYPRICEMULT -= 0.4
		if GameLogic.cur_Challenge.has("打折"):
			GameLogic.call_Info(2, "打折")
			_PAYPRICEMULT -= 0.05
		if GameLogic.cur_Challenge.has("打折+"):
			GameLogic.call_Info(2, "打折+")
			_PAYPRICEMULT -= 0.1
		if GameLogic.cur_Challenge.has("打折++"):
			GameLogic.call_Info(2, "打折++")
			_PAYPRICEMULT -= 0.2
		if _FINALCHECK > 0:
			if _FINALCHECK > 1:
				_FINALCHECK = 1
			_Pay = _Pay * (1 - _FINALCHECK)
			_Tip = _Tip * (1 - _FINALCHECK)

		if _PAYPRICEMULT < 0:
			_PAYPRICEMULT = 0
		_Pay = _Pay * _PAYPRICEMULT

		if is_instance_valid(_Player):
			if _Player.Stat.Skills.has("技能-强卖"):
				_PlayerPressure += PickCheck["Stress"]
			if _PlayerPressure != 0:
				_Player.call_pressure_set(_PlayerPressure)
			if _Player.cur_Player in [0, 1, 2, SteamLogic.STEAM_ID]:
				GameLogic.call_StatisticsData_Set("Count_SellServer", null, 1)

			elif SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Count_SellServer", [_Player.cur_Player])

		if not _TotalCheck:
			_Pay = 0
			_Tip = 0
		_Pay = int(_Pay)
		_Tip = int(_Tip)
		if SpecialType == 3:
			_Pay_Array = [_BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump]

		else:
			_MoneyLogic([_BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump])

		GameLogic.call_Sell_add()
		if GameLogic.Order.cur_OrderList.has(_CUPID):
			GameLogic.Order.cur_OrderList.erase(_CUPID)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_set_sync(GameLogic.Order, "cur_OrderList", GameLogic.Order.cur_OrderList)


		GameLogic.Order.call_PickUp(_CUPID)

		GameLogic.cur_SellMenu = OrderName

		if _COMBO > 0 and _CANCOMBO:
			GameLogic.call_combo(_COMBO)
			_COMBO = 0
		if _PopularNum > 0:





			var _r = GameLogic.return_Popular(_PopularNum, GameLogic.HomeMoneyKey)

		if _Pressure != 0:
			GameLogic.call_Pressure_Set(_Pressure)
		GameLogic.call_StatisticsData_Set("Dic_NPC_SellNum", _selfTypeID, 1)

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_sell_logic_puppet", [IsCri, IsQuick, IsSlow, IsJump, PointType])
func _MoneyLogic(_ARRAY):
	var _BasePay = _ARRAY[0]
	var _Pay = _ARRAY[1]
	var _Tip = _ARRAY[2]
	var IsCri = _ARRAY[3]
	var IsQuick = _ARRAY[4]
	var IsSlow = _ARRAY[5]
	var IsJump = _ARRAY[6]
	GameLogic.Money_Sell += _Pay
	GameLogic.Money_Tip += _Tip
	GameLogic.call_StatisticsData_Set("Count_Tip", null, _Tip)

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		GameLogic.level_MoneyTotal += _Pay + _Tip
		GameLogic.level_SellTotal += 1
		GameLogic.level_ProfitTotal += _Pay + _Tip


	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	if SpecialType in [3] or IsSit:
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
	else:
		_PickUpDev.PayNode.add_child(_PayEffect)
	_PayEffect.call_init(_BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _DevPath = _PickUpDev.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_puppet_PayEffect", [_DevPath, _BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump])
	GameLogic.call_MoneyChange(_Pay + _Tip, GameLogic.HomeMoneyKey)

func _putDown(_Pos):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_putDown", [_Pos])
	if SpecialType == 10:
		GameLogic.NPC.ICEMACHINE.call_add_ice()
		return
	if SpecialType == 11:
		GameLogic.NPC.GASBOX.call_GAS_FULL()
		return
	if SpecialType == 12:
		Avatar.WeaponNode.remove_child(HoldObj)
		HoldObj.position = _Pos
		ItemYSort.add_child(HoldObj)
		if HoldObj.has_method("call_Collision_Switch"):
			HoldObj.call_Collision_Switch(true)
		if HoldObj.has_method("call_new"):
			HoldObj.call_deferred("call_new")
		HoldObj = null
		Con.IsHold = false
		return
	if not is_instance_valid(HoldObj):
		HoldObj = null
		Con.IsHold = false
		return
	self.Avatar.WeaponNode.remove_child(HoldObj)
	HoldObj.position = _Pos
	ItemYSort.add_child(HoldObj)
	if HoldObj.has_method("call_Collision_Switch"):
		HoldObj.call_Collision_Switch(true)
	if HoldObj.has_method("call_new"):
		HoldObj.call_deferred("call_new")
	HoldObj = null
	Con.IsHold = false
func _thief_putDown_puppet(_POS: Vector2):
	if self.Avatar.WeaponNode.get_child_count():
		var _OBJ = self.Avatar.WeaponNode.get_child(0)
		self.Avatar.WeaponNode.remove_child(_OBJ)
		_OBJ.position = _POS
		ItemYSort.add_child(_OBJ)
	Con.IsHold = false
	HoldObj = null
func _thief_putDown():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not is_instance_valid(HoldObj):
		return
	var _Pos = self.global_position
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "_thief_putDown_puppet", [_Pos])
	if HoldObj.has_method("call_Collision_Switch"):
		HoldObj.call_Collision_Switch(true)

	self.Avatar.WeaponNode.remove_child(HoldObj)
	HoldObj.position = _Pos

	GameLogic.Staff.LevelNode.get_node("YSort/Items").add_child(HoldObj)

	if HoldObj.get("TypeStr") in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:

		ThinkingAni.play("hide")
	Con.IsHold = false
	HoldObj = null
func call_NoOrder_puppet():
	if GameLogic.Order.cur_LineUpArray.has(self):
		GameLogic.Order.cur_LineUpArray.erase(self)

func _on_WaitingTimer_timeout() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not PickUpID:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_NoOrder_puppet")
		if GameLogic.Order.cur_LineUpArray.has(self):
			GameLogic.Order.cur_LineUpArray.erase(self)
			GameLogic.call_NoOrder_add(NOPRESSURE)

			call_leaving()
	else:
		if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
			if GameLogic.cur_Day == 1:
				return

		else:

			if GameLogic.cur_Rewards.has("舒适圈"):
				var _HighPressure
				for _PlayerID in GameLogic.PressureDic:
					var _PRE = GameLogic.PressureDic[_PlayerID]
					var _PlayerSort = get_tree().get_root().get_node("Level/YSort/Players")
					if _PlayerSort.has_node(str(_PlayerID)):
						var _MAX = _PlayerSort.get_node(str(_PlayerID)).cur_PressureMax
						var _HIGHLIMIT: float = 0.8
						if GameLogic.cur_Rewards.has("外放音响"):
							_HIGHLIMIT = 0.7
						if GameLogic.cur_Rewards.has("外放音响+"):
							_HIGHLIMIT = 0.5
						if int(_PRE) >= int(float(_MAX) * _HIGHLIMIT):
							_HighPressure = true
							break

						if GameLogic.cur_Rewards.has("内卷饭碗"):
							if _PRE <= float(_MAX) * 0.1:

								if GameLogic.cur_Rewards.has("精神寄托new"):
									_HighPressure = true
									break
						elif GameLogic.cur_Rewards.has("内卷饭碗+"):
							if _PRE <= float(_MAX) * 0.3:

								if GameLogic.cur_Rewards.has("精神寄托new"):
									_HighPressure = true
									break
						else:
							if _PRE <= 0:
								if GameLogic.cur_Rewards.has("精神寄托new"):
									_HighPressure = true
									break
				if _HighPressure:
					var _KEY = GameLogic.Order.cur_OrderList.keys()
					if PickUpID > _KEY.min():
						_REWAITTIME = 0.05
						call_ReWait()
						return

			if GameLogic.cur_Challenge.has("集体退单"):

				pass
			if GameLogic.cur_Challenge.has("集体退单+"):

				pass
			if GameLogic.cur_Challenge.has("投诉"):

				pass
			if GameLogic.cur_Challenge.has("投诉+"):

				pass
			if PointType == - 1:
				GameLogic.call_NoSell_add(NOPRESSURE)
			if IsSit:
				if SpecialType == 5:
					SpecialType = - 1
				_on_LogicTimer_timeout()
			else:
				call_leaving()
func _on_LineWaitingTimer_timeout() -> void :
	if not PickUpID:

		if behavior == BEHAVIOR.LINE:
			if GameLogic.cur_Rewards.has("排队+"):
				return

		GameLogic.call_NoOrderName_add(NOPRESSURE)

		call_leaving()
	else:
		print("NPC有单情况，排队等待时间错误。")
func call_puppet_Angry():

	ThinkingAni.play("angry_leave")
func _on_OrderAngryTimer_timeout():
	if GameLogic.cur_Day == 1:
		if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
			return
	if not PickUpID:
		if IsSit:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_Angry")
			var _Pressure: int = NOPRESSURE
			if SpecialType in [4]:
				_Pressure = _Pressure * 2
			GameLogic.call_NoOrder_add(_Pressure)
			_on_LogicTimer_timeout()
			ThinkingAni.play("angry_leave")
		elif GameLogic.Order.cur_LineUpArray.has(self):
			if GameLogic.Order.cur_LineUpArray.has(self):
				GameLogic.Order.cur_LineUpArray.erase(self)
				var _Pressure: int = NOPRESSURE
				if SpecialType in [4]:
					_Pressure = _Pressure * 2
				GameLogic.call_NoOrder_add(_Pressure)
				call_leaving()
				ThinkingAni.play("angry_leave")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_Angry")
		else:
			print("顾客不在队伍当中。")
	else:
		print("NPC有单情况，点单等待时间错误。")
func call_puppet_ThinkingAngry():
	if GameLogic.cur_Rewards.has("耐心挑战"):
		ThinkingAni.play("angry_10")
	elif GameLogic.cur_Rewards.has("耐心挑战+"):
		ThinkingAni.play("angry_15")
	else:
		ThinkingAni.play("angry")
func _on_OrderTimer_timeout() -> void :

	if not PickUpID:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_ThinkingAngry")
		if GameLogic.cur_Rewards.has("耐心挑战"):
			ThinkingAni.play("angry_10")
		elif GameLogic.cur_Rewards.has("耐心挑战+"):
			ThinkingAni.play("angry_15")
		else:
			ThinkingAni.play("angry")
		OrderAngryTimer.start(0)
		OrderAngryBool = true

func call_leaving_night():

	if IsSit:
		return
	if not GameLogic.Order.cur_OrderArray.has(PickUpID):

		if not PickUpID and not GameLogic.Order.cur_LineUpArray.has(self):

			if not ThinkingAni.assigned_animation in ["show", "angry", "angry_10", "angry_15"]:

				if SpecialType in [3, 4]:
					SpecialType = - 1
				call_leaving()
				if is_in_group("Customers"):
					remove_from_group("Customers")

func call_del():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_del")
	if Con.IsHold:
		if Avatar != null:
			if self.Avatar.WeaponNode.get_child_count():
				var _OBJ = self.Avatar.WeaponNode.get_child(0)
				if GameLogic.cur_Item_List.has(_OBJ.TypeStr):
					GameLogic.cur_Item_List[_OBJ.TypeStr] -= 1
					if GameLogic.cur_Item_List[_OBJ.TypeStr] < 0:
						GameLogic.cur_Item_List[_OBJ.TypeStr] = 0

	if is_in_group("NPC"):
		remove_from_group("NPC")
	if is_in_group("Customers"):
		remove_from_group("Customers")
	if is_in_group("Passers"):
		remove_from_group("Passers")
	if is_in_group("Couriers"):
		remove_from_group("Couriers")
	GameLogic.NPC.NPCNUM -= 1
	self.queue_free()

func _Add_Customer():
	if not _Is_Customer:
		_Is_Customer = true
		GameLogic.call_Customer_add()
func call_puppet_leaveSeat(_PosSave):
	SeatOBJ.call_leaving(_PosSave)
	IsSit = false
func _StudyHolics_Logic():
	SpecialType = - 1

func call_Del_Hold():
	if is_instance_valid(HoldObj):
		HoldObj.get_parent().remove_child(HoldObj)
		HoldObj.queue_free()
	Con.IsHold = false
func WINE_pup():
	WINECanTouch = true
	if is_instance_valid(HoldObj):
		if HoldObj.has_method("call_dirty"):
			HoldObj.call_dirty()
	ThinkingAni.play("WINE")
	$LogicNode / TYPEAni.play("Special")
func _on_LogicTimer_timeout():
	var _LEVELTYPE = GameLogic.cur_levelInfo.Type
	if "WINE" in _LEVELTYPE:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		if not WINECanTouch:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "WINE_pup")
			WINECanTouch = true
			if is_instance_valid(HoldObj):
				if HoldObj.has_method("call_dirty"):
					HoldObj.call_dirty()
			ThinkingAni.play("WINE")
			$LogicNode / TYPEAni.play("Special")
		if not IsSit:


			var _BENCHLIST = GameLogic.NPC.WORKBENCH.duplicate()
			for _BENCH in _BENCHLIST:
				if is_instance_valid(_BENCH):
					if is_instance_valid(_BENCH.OnTableObj):
						var _PLATE = _BENCH.OnTableObj
						if _PLATE.get("SelfDev") == "Plate":
							var _targetPos = _BENCH.global_position
							_targetPos.y += 25
							var Way_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)

							if Way_array.size() <= 1:
								if _PLATE._OBJLIST.size() < 4:
									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "WINE_Touch_pup", [_PLATE._SELFID, HoldObj._SELFID])

									call_BEER_in_Plate(_PLATE)
									return

							if _PLATE._OBJLIST.size() < 4:

								WayPoint_array = Way_array
								_Path_IsFinish = false
								_FinalTarget = _targetPos

								target = self.position
								behavior = BEHAVIOR.PLATE
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_node_sync(self, "call_puppet_Move", [_FinalTarget, self.position])

								return
				else:
					if GameLogic.NPC.WORKBENCH.has(_BENCH):
						GameLogic.NPC.WORKBENCH.erase(_BENCH)
			_COMBO += 1

			var _MAX = 3
			if is_instance_valid(HoldObj):
				match HoldObj.get("TypeStr"):

					"BeerCup_S":
						_MAX = 3
					"BeerCup_M":
						_MAX = 4
					"BeerCup_L":
						_MAX = 5
			if _COMBO >= _MAX:
				if is_instance_valid(HoldObj):
					if HoldObj.get("TypeStr") in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
						HoldObj.call_dirty()
						_thief_putDown()
						LogicTimer.stop()
						ThinkingAni.play("hide")
						if SpecialType in [3]:
							call_Thug_leaving()
						else:
							call_leaving()
						var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
						_AUDIO.play(0)
						return
			_call_InStore_RandomMove()
		LogicTimer.start(0)

		return
	if NPCTYPE == 2:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		_find_WaterStain()
	elif NPCTYPE == 3:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		if Con.state == GameLogic.NPC.STATE.URGE:
			if is_instance_valid(HoldObj):
				if HoldObj.get_parent().name in ["Items"]:
					GameLogic.call_Pressure_Set(1)
					_call_StoreOfftheground()
		else:
			_CheckStore()
	elif NPCTYPE == 4:
		_CheckStore()
	elif IsSit:
		if SpecialType in [5]:
			if PickUpID == 0:
				SeatOBJ.call_leaving(PosSave)
				IsSit = false
				call_leaving()
				return
			SpecialType = - 1
			Point = 0
			OrderName = ""
			SeatOBJ.get_parent().call_Study_Logic(SeatOBJ.name)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Del_Hold")
			call_Del_Hold()
			PickUpID = 0

			_orderType_init()
			behavior = BEHAVIOR.ORDER

			_call_thinking()
			return


		SeatOBJ.call_leaving(PosSave)
		IsSit = false

		if SpecialType in [3] and Con.IsHold:
			call_Thug_leaving()
		else:

			call_leaving()
func call_leaving():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	ThinkingTimer.stop()
	StandTimer.stop()
	WaitingTimer.stop()
	LineWaitingTimer.stop()


	if IsSit:

		if LogicTimer.is_stopped():
			LogicTimer.start(0)
		return
	var _OBJ = HoldObj

	if GameLogic.Order.cur_LineUpArray.has(self):
		GameLogic.Order.cur_LineUpArray.erase(self)

	Stat.call_NPC_init()
	var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
	if GameLogic.NPC._INOUT_Bool:
		_NPC_Create_Array = GameLogic.NPC.Out_Array

	var _LeavingPoint = _NPC_Create_Array[GameLogic.return_RANDOM() % _NPC_Create_Array.size()]
	if SpecialType in [10, 11, 12] or NPCTYPE > 0:
		if ChargeNumTotal > 0:
			var _PAYMONEY = int(ChargeNumTotal * 0.2)
			if _PAYMONEY > 0:
				GameLogic.Cost_Items += _PAYMONEY
				GameLogic.GameUI.OrderNode.Order_SellCount += int(_PAYMONEY)
				GameLogic.GameUI.Order_SellCount += int(_PAYMONEY)
				GameLogic.GameUI.sellCount_ShowLogic()

				var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
				var _POS: Vector2 = self.global_position
				_PayEffect.position = _POS
				GameLogic.Staff.LevelNode.add_child(_PayEffect)
				_PayEffect.call_Pay(_PAYMONEY)

		call_Staff_Leave(_LeavingPoint)
	else:
		call_Special_Leave(_LeavingPoint)

	if not SpecialType in [3]:
		$LogicNode / TYPEAni.play("Leave")

	if not PickUpID and SpecialType in [0, 2, 3, 4, 5, 6, 8]:
		ThinkingAni.play("Leaving")

	if PickUpID and not IsFinish:

		GameLogic.Order.call_Refund(PickUpID)
	if SpecialSave > 0:

		GameLogic.Order.call_Refund(SpecialSave)

	SpecialType = - 1
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_leaving", [0, _LeavingPoint, GameLogic.Order.cur_LineUpArray, Stat.Ins_Skill_1_Mult])
	if PickUpID and IsFinish:
		if GameLogic.curLevelList.has("难度-捡垃圾") or GameLogic.curLevelList.has("难度-顾客垃圾"):
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _RAND = GameLogic.return_randi() % 3
			if not _RAND:

				var _TIME: float = float(GameLogic.return_RANDOM() % 500 + 100) / 100
				yield(get_tree().create_timer(_TIME), "timeout")
				var _ITEMPOS = self.global_position



				if _ITEMPOS.x <= 1500 and _ITEMPOS.x >= - 150 and _ITEMPOS.y <= 1200 and _ITEMPOS.y >= 150:

					HoldObj.get_parent().remove_child(HoldObj)
					HoldObj.call_del()
					var _TRASH = load("res://TscnAndGd/Objects/Gears/TrashItem.tscn")
					var _TRASHTSCN = _TRASH.instance()
					_TRASHTSCN.position = _ITEMPOS
					ItemYSort.add_child(_TRASHTSCN)

					var _INFO = {
						"NAME": _TRASHTSCN.get_instance_id(),
						"ANI": str(GameLogic.return_RANDOM() % 4 + 1)
					}
					_TRASHTSCN.call_load(_INFO)

					Con.IsHold = false
					HoldObj = null
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_Trash_puppet", [_INFO, _ITEMPOS])
func call_Trash_puppet(_INFO, _POS):
	if is_instance_valid(HoldObj):
		HoldObj.get_parent().remove_child(HoldObj)
		HoldObj.call_del()
	var _TRASH = load("res://TscnAndGd/Objects/Gears/TrashItem.tscn")
	var _TRASHTSCN = _TRASH.instance()
	_TRASHTSCN.position = _POS
	ItemYSort.add_child(_TRASHTSCN)
	_TRASHTSCN.call_load(_INFO)
	Con.IsHold = false
	HoldObj = null

func call_puppet_leaving(_TYPE, _TARGET, _LINEUPARRAY, _SPEED, _SPECIALTYPE: int = 1, _LB: bool = false):

	if not PickUpID and SpecialType in [0, 2, 3, 4, 5, 6]:
		if not IsCourier:
			ThinkingAni.play("Leaving")
	match _TYPE:
		1:
			if SpecialType != - 1:
				if Con.IsHold:
					ThinkingAni.play("thief_warning")
			elif SpecialType == - 1:
				ThinkingAni.play("thief_run")

		2:

			SpecialType = _SPECIALTYPE

			if SpecialType == - 1:
				$LogicNode / TYPEAni.play("Leave")

			elif SpecialType != - 1:
				Stat.Ins_Skill_1_Mult = 0.5
				Stat._speed_change_logic()
				ThinkingAni.play("thief_warning")
				$LogicNode / TYPEAni.play("Special")
		_:
			if not SpecialType in [3]:
				$LogicNode / TYPEAni.play("Leave")

	Stat.Ins_Skill_1_Mult = _SPEED
	Stat._speed_change_logic()
	StandTimer.stop()
	WaitingTimer.stop()
	LineWaitingTimer.stop()
	GameLogic.Order.cur_LineUpArray = _LINEUPARRAY

	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	if _SPECIALTYPE in [10, 11, 12] or NPCTYPE > 0:
		WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _TARGET)
	else:

		if GameLogic.NPC._INOUT_Bool:
			WayPoint_array = GameLogic.Astar.return_NPC_Leave_Array(self.position, _TARGET)
		else:
			WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _TARGET)
func call_Thug_leaving():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _LEVELTYPE = GameLogic.cur_levelInfo.Type
	if "WINE" in _LEVELTYPE and WINECanTouch:
		pass
	elif "WINE" in _LEVELTYPE and not WINECanTouch:
		SpecialType = - 1
	elif PickUpID and not Con.IsHold:
		SpecialType = - 1
	if SpecialType == - 1:
		$LogicNode / TYPEAni.play("Leave")

	elif SpecialType != - 1:
		Stat.Ins_Skill_1_Mult = 0.5
		Stat._speed_change_logic()
		ThinkingAni.play("Thug_warning")
		$LogicNode / TYPEAni.play("Special")

	var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	if PickUpID and not Con.IsHold:
		GameLogic.Order.call_Refund(PickUpID)
	var _LeavingPoint = _NPC_Create_Array[GameLogic.return_RANDOM() % _NPC_Create_Array.size()]
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _LeavingPoint)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_leaving", [2, _LeavingPoint, GameLogic.Order.cur_LineUpArray, Stat.Ins_Skill_1_Mult, SpecialType])
func call_Thief_leaving():

	Stat.call_NPC_init()
	if Con.IsHold and SpecialType != - 1:
		Stat.Ins_Skill_1_Mult = 0.5

	elif SpecialType == - 1:
		Stat.Ins_Skill_1_Mult = 1.5

	if SpecialType != - 1 and Con.IsHold:
		ThinkingAni.play("thief_warning")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	var _LeavingPoint = _NPC_Create_Array[GameLogic.return_RANDOM() % _NPC_Create_Array.size()]
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _LeavingPoint)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_leaving", [1, _LeavingPoint, GameLogic.Order.cur_LineUpArray, Stat.Ins_Skill_1_Mult])

func call_AcrossItem(_OBJ):
	if SpecialType in [1, - 1]:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _OBJ.has_method("call_move"):
		if _OBJ.CanPass:
			return
	if IsCourier:
		return

	if GameLogic.GameUI.Is_Open:
		if is_instance_valid(_OBJ_Block):
			if _OBJ_Block != _OBJ:
				_OBJ_Block = _OBJ
				ThinkingAni.play("hide")
				ThinkingAni.play("BlockTheWay")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_AcrossItem_puppet")
				if GameLogic.cur_Devil == 0:
					pass
				elif not NOPRESSURE:
					if _OBJ.get("CanFraud"):
						GameLogic.call_pressure("SellItem")
					else:
						GameLogic.call_pressure("BlockWay")
		else:
			_OBJ_Block = _OBJ
			ThinkingAni.play("hide")
			ThinkingAni.play("BlockTheWay")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_AcrossItem_puppet")
			if GameLogic.cur_Devil == 0:
				pass
			elif not NOPRESSURE:
				if _OBJ.get("CanFraud"):
					GameLogic.call_pressure("SellItem")
				else:
					GameLogic.call_pressure("BlockWay")
func call_AcrossItem_puppet():
	ThinkingAni.play("hide")
	ThinkingAni.play("BlockTheWay")

func _Puppet_SYNC(_POS: Vector2, _Target: Vector2):
	if self.position.distance_to(_POS) >= 100:
		position = _POS

	target = _Target
	pass

func _Collision_Logic_End():
	pass
func master_Homeless_touch():
	if not IsTouched:
		IsTouched = true
		_homeless_run_away()
func master_Thug_touch():
	if not IsTouched:
		IsTouched = true
		_MoneyLogic(_Pay_Array)
		_thug_run_away()
func master_thief_touch():
	if not IsTouched:
		IsTouched = true
		if Con.IsHold:
			call_deferred("_thief_putDown")
		call_deferred("_thief_run_away")
func call_master_touch(_PlayerPath):
	var _body = get_node(_PlayerPath)
	master_touch(_body)
func master_touch(_body):
	var _PRESS: int = 0
	if GameLogic.cur_Challenge.has("鲁莽"):
		if not IsTouched and SpecialType in [0, 2, 4, 5, 6, 7]:
			call_touched()
			if not NOPRESSURE:
				GameLogic.call_Info(2, "鲁莽")
				_PRESS += 1
	if GameLogic.cur_Challenge.has("鲁莽+"):
		if not IsTouched and SpecialType in [0, 2, 4, 5, 6, 7]:
			call_touched()
			if not NOPRESSURE:
				GameLogic.call_Info(2, "鲁莽+")
				_PRESS += 2
	if _PRESS > 0:
		_body.call_pressure_set(_PRESS)
func call_LINE_Touch():
	if behavior in [BEHAVIOR.LINE]:
		behavior = BEHAVIOR.CUSTOMER
		LineNPC = null
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_BEHAVIOR", [self.position, behavior])
func call_Panda_Touch():

	if not GameLogic.GameUI.Is_Open or GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:
		return
	IsPasser = false
	call_PassToC()
	match _selfTypeID:
		"BritishCupcritic":
			SpecialType = 2
		"PaperCupbadguy":
			SpecialType = 3
		"BilateralCupmother":
			SpecialType = 4
		"TeaCupstudent":
			SpecialType = 5
func call_BEER_in_Plate(_PLATE):
	HoldObj.get_parent().remove_child(HoldObj)
	_PLATE.call_deferred("call_CupOn", HoldObj)
	Con.IsHold = false
	HoldObj = null
	if ThinkingAni.assigned_animation == "WINE":
		ThinkingAni.play("hide")
	if IsSit:
		SeatOBJ.call_leaving(PosSave)
		IsSit = false
	LogicTimer.stop()
	if SpecialType in [3]:
		call_Thug_leaving()
	else:
		call_leaving()
	var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
	_AUDIO.play(0)
func call_WINE_Touch(_PLAYERPATH):
	var _body = get_node(_PLAYERPATH)
	if WINECanTouch:
		var _PLATE = _body.Con.HoldObj
		if is_instance_valid(_PLATE):
			if _PLATE.get("SelfDev") == "Plate":
				if _PLATE._OBJLIST.size() < 4:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "WINE_Touch_pup", [_PLATE._SELFID, HoldObj._SELFID])
					call_BEER_in_Plate(_PLATE)

					return
func WINE_Touch_pup(_PLATEID, _CUPID):
	if not SteamLogic.OBJECT_DIC.has(_PLATEID):
		printerr(" Plate_pup OBJECT_DIC 无_PLATEID：", _PLATEID)
		return
	if not SteamLogic.OBJECT_DIC.has(_CUPID):
		printerr(" Plate_pup OBJECT_DIC 无_PLATEID：", _CUPID)
		return
	var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
	var _PLATE = SteamLogic.OBJECT_DIC[_PLATEID]

	_CUP.get_parent().remove_child(_CUP)
	_PLATE.call_deferred("call_CupOn", _CUP)

	Con.IsHold = false
	HoldObj = null
	if ThinkingAni.assigned_animation == "WINE":
		ThinkingAni.play("hide")
	var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
	_AUDIO.play(0)
func _on_NPC_body_entered(_body):

	if _body.has_method("_PlayerNode"):
		if WINECanTouch:
			var _HOLDOBJ = _body.Con.HoldObj
			if is_instance_valid(_HOLDOBJ):
				if _HOLDOBJ.get("SelfDev") == "Plate":
					if _HOLDOBJ._OBJLIST.size() < 4:
						if SteamLogic.IsMultiplay:
							if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								var _PLAYERPATH = _body.get_path()
								SteamLogic.call_master_node_sync(self, "call_WINE_Touch", [_PLAYERPATH])
						else:
							var _PLAYERPATH = _body.get_path()
							call_WINE_Touch(_PLAYERPATH)
			if SpecialType in [3]:
				if not Con.IsHold and not IsSit:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							SteamLogic.call_master_node_sync(self, "master_Thug_touch")
					else:
						master_Thug_touch()
			return
		match SpecialType:
			- 1:
				if behavior in [BEHAVIOR.LINE]:
					if SteamLogic.IsMultiplay:
						if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							SteamLogic.call_master_node_sync(self, "call_LINE_Touch")
					else:
						call_LINE_Touch()

			0, 6:
				if behavior in [BEHAVIOR.LINE]:
					if SteamLogic.IsMultiplay:
						if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							SteamLogic.call_master_node_sync(self, "call_LINE_Touch")
					else:
						call_LINE_Touch()

				elif _body.Stat.Skills.has("技能-熊猫"):
					if GameLogic.cur_Day == 1:
						if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
							return

					if not IsCustomer and not IsCourier and IsPasser:

						if SteamLogic.IsMultiplay:
							if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								SteamLogic.call_master_node_sync(self, "call_Panda_Touch")
						else:
							call_Panda_Touch()


			8:
				if behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER]:
					if SteamLogic.IsMultiplay:
						if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							SteamLogic.call_master_node_sync(self, "master_Homeless_touch")
					else:

						master_Homeless_touch()
						IsTouched = true
			1:
				if SteamLogic.IsMultiplay:
					if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						SteamLogic.call_master_node_sync(self, "master_thief_touch")
				else:
					master_thief_touch()
			3:

				if Con.IsHold and not IsSit:
					var _LEVELTYPE = GameLogic.cur_levelInfo.Type
					if "WINE" in _LEVELTYPE:
						pass
					else:
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								SteamLogic.call_master_node_sync(self, "master_Thug_touch")
						else:
							master_Thug_touch()

		if GameLogic.GameUI.Is_Open and NPCTYPE == 0:
			if GameLogic.cur_Challenge.has("鲁莽") or GameLogic.cur_Challenge.has("鲁莽+"):
				if not IsTouched and SpecialType in [0, 2, 4, 5, 6, 7]:
					if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						GameLogic.Con.call_vibration(_body.cur_Player, 0.8, 0.8, 0.1)
					if SteamLogic.IsMultiplay:
						if _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							var _PLAYERPATH = _body.get_path()
							SteamLogic.call_master_node_sync(self, "call_master_touch", [_PLAYERPATH])

							master_touch(_body)
							call_touched()
					else:
						master_touch(_body)
		if _body.Stat.Skills.has("技能-威压"):

			if ThinkingAni.is_playing():
				_on_ThinkingTimer_timeout()
				_body.call_pressure_set(1)

	elif _body.has_method("_on_NPC_body_entered"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return
		if behavior in [BEHAVIOR.MOVE, BEHAVIOR.WAIT]:
			if _body.behavior in [BEHAVIOR.PASSER, BEHAVIOR.WAIT, BEHAVIOR.LINE, BEHAVIOR.ORDER]:
				if _body._Path_IsFinish:
					_on_StandTimer_timeout()


		elif behavior == BEHAVIOR.CUSTOMER:
			if SpecialType in [4]:
				return
			if _body.IsSit:
				return
			if _body.behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER]:
				if _body.LineNPC != null:
					if is_instance_valid(_body.LineNPC):
						if _body.LineNPC == self:
							return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				LineNPC = _body
				if LineWaitingTimer.is_stopped():
					LineWaitingTimer.start(0)

				behavior = BEHAVIOR.LINE

				if GameLogic.cur_Rewards.has("排队付费"):
					var _Times = 1
					_WAITPAYNUM += 1
					if _WAITPAYNUM < _Times:


						GameLogic.call_Info(1, "排队付费")
						var _OTHERMONEY = int(5 * GameLogic.return_Multiplayer())

						if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
							_OTHERMONEY = int(float(_OTHERMONEY) * 1.5)
						GameLogic.call_MoneyOther_Change(_OTHERMONEY, GameLogic.HomeMoneyKey)


						var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
						var _POS: Vector2 = self.global_position
						_PayEffect.position = _POS
						GameLogic.Staff.LevelNode.add_child(_PayEffect)
						_PayEffect.call_init(0, _OTHERMONEY, 0, false, false, false, false)
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_Pos_Pay_puppet", [_POS, _OTHERMONEY])

				elif GameLogic.cur_Rewards.has("排队付费+"):
					var _Times = 5
					_WAITPAYNUM += 1
					if _WAITPAYNUM < _Times:

						GameLogic.call_Info(1, "排队付费+")
						var _OTHERMONEY = int(5 * GameLogic.return_Multiplayer())
						if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
							_OTHERMONEY = int(float(_OTHERMONEY) * 1.5)

						GameLogic.call_MoneyOther_Change(_OTHERMONEY, GameLogic.HomeMoneyKey)






						var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
						var _POS: Vector2 = self.global_position
						_PayEffect.position = _POS
						GameLogic.Staff.LevelNode.add_child(_PayEffect)
						_PayEffect.call_init(0, _OTHERMONEY, 0, false, false, false, false)
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_Pos_Pay_puppet", [_POS, _OTHERMONEY])

				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_BEHAVIOR", [self.position, BEHAVIOR.LINE])
			elif _body.behavior in [BEHAVIOR.MOVE, BEHAVIOR.WAIT]:
				_body._on_StandTimer_timeout()
		elif behavior in [BEHAVIOR.PASSER]:
			if _body.behavior in [BEHAVIOR.PASSER]:

				pass

func call_PassToC_puppet():
	ThinkingAni.play("Panda")
	call_customer(GameLogic.Astar.OrderV2, false)
	var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
	_AUDIO.play(0)
func call_PassToC():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	ThinkingAni.play("Panda")
	call_customer(GameLogic.Astar.OrderV2, false)
	var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
	_AUDIO.play(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PassToC_puppet")
func call_Pos_Pay_puppet(_POS, _MONEY):
	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = _POS
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	_PayEffect.call_init(0, _MONEY, 0, false, false, false, false)

var _REWAITTIME: float = 0
func call_ReWait():
	if _REWAITTIME == 0:
		return
	var _ReWaitTIME = WaitTime * _REWAITTIME
	var _ReStart: float = WaitingTimer.time_left + _ReWaitTIME
	if _ReStart < 0:
		_ReStart = 0
	if _ReStart > WaitTime:
		_ReStart = WaitTime

	WaitingTimer.wait_time = WaitTime

	WaitingTimer.start(_ReStart)

	GameLogic.Order.call_ReSetTime(PickUpID, _ReStart)
	if SpecialType in [6]:
		if SpecialSave > 0:
			GameLogic.Order.call_ReSetTime(SpecialSave, _ReStart)
func _on_NPC_body_exited(_body):

	pass
func call_puppet_QTECheck(_INFO):
	IsService = true
	var _NUM: int = 0
	var Perfect: int = 0
	var Good: int = 0
	var Miss: int = 0
	var _KEYList = _INFO.keys()
	for _KEY in _KEYList:
		var _CHECK = _INFO[_KEY]
		match _CHECK:
			"Perfect":
				Perfect += 1
			"Good":
				Good += 1
			"Miss":
				Miss += 1
	if Miss > 0:
		ServiceList.append("Miss")
		get_node("Thinking/HBox/1/Mood/MoodAni").play("3")
		var _AUDIO = GameLogic.Audio.return_Effect("QTEMISS")
		if not _AUDIO.is_playing():
			_AUDIO.play(0)
	elif Good > 0:
		ServiceList.append("Good")
		get_node("Thinking/HBox/1/Mood/MoodAni").play("2")
		var _AUDIO = GameLogic.Audio.return_Effect("QTEGOOD")
		if not _AUDIO.is_playing():
			_AUDIO.play(0)
	elif Perfect > 0:
		ServiceList.append("Perfect")
		get_node("Thinking/HBox/1/Mood/MoodAni").play("1")
		var _AUDIO = GameLogic.Audio.return_Effect("QTEPERFECT")
		if not _AUDIO.is_playing():
			_AUDIO.play(0)
func call_QTECheck(_INFO: Dictionary):
	var _CanCheck: bool
	if GameLogic.QTESELF_BOOL:
		if QTEType > 0:
			if behavior == BEHAVIOR.ORDER:
				_CanCheck = true
	else:
		_CanCheck = true
	if not _CanCheck:
		return
	if not IsService:

		for _POS in GameLogic.NPC._InStore_Customer_Array:
			if self.position.distance_to(_POS) <= 100:
				IsService = true
				break

		if IsSit:
			IsService = true
		if IsService:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_QTECheck", [_INFO])
			var _NUM: int = 0
			var Perfect: int = 0
			var Good: int = 0
			var Miss: int = 0
			var _KEYList = _INFO.keys()
			for _KEY in _KEYList:
				var _CHECK = _INFO[_KEY]
				match _CHECK:
					"Perfect":
						Perfect += 1
					"Good":
						Good += 1
					"Miss":
						Miss += 1
			if Miss > 0:
				ServiceList.append("Miss")
				get_node("Thinking/HBox/1/Mood/MoodAni").play("3")
			elif Good > 0:
				ServiceList.append("Good")
				get_node("Thinking/HBox/1/Mood/MoodAni").play("2")
			elif Perfect > 0:
				ServiceList.append("Perfect")
				get_node("Thinking/HBox/1/Mood/MoodAni").play("1")

func call_Count_SellServer(_ID):
	if _ID == SteamLogic.STEAM_ID:
		GameLogic.call_StatisticsData_Set("Count_SellServer", null, 1)

func Thug_Logic():
	SpecialType = 3
	$LogicNode / TYPEAni.play("Special")
	pass
