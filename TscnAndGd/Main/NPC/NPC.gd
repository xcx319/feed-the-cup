extends KinematicBody2D

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
var SpecialType: int = 0
var IsWaiting: bool
var PickUpID: int
var OrderWait_bool: bool
var LineTime: float
var IsPickUp: bool

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
var HoldObj

onready var ThinkingAni = get_node("Thinking/ThinkingAni")
onready var ThinkingTimer = get_node("Thinking/ThinkingTimer")

onready var HappyAni = get_node("Happy/HappyAni")
var LineNPC
var WaitingReset: bool
var _Is_Customer
var PosSave: Vector2

var WaitTime: float
var ReOrder: bool
var SeatRat: float

var Order_COFFEE: bool
var Order_MILK: bool
var Order_MILKTEA: bool
var Order_TEA: bool
var Order_POP: bool
var Order_SOYBEAN: bool
var Order_FRUIT: bool
var Order_SHAKE: bool
var Order_ICECREAM: bool

var Order_Extra_Base: bool
var Order_Extra_Tea: bool

var Order_HOT: bool
var Order_NORMAL: bool
var Order_COLD: bool
var Order_S: bool
var Order_M: bool
var Order_L: bool
var Order_Sugar
var Order_Personal

var NoOrder_TYPE: bool
var NoOrder_Cup: bool
var NoOrder_Celcius: bool
var NoOrder_Suger: bool

var OrderName: String
var PopularMult: float
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
}

onready var _selfCollision = get_node("CollisionShape2D")
onready var EndTimer = get_node("LogicNode/CollisionLogicEndTimer")
onready var WaitingTimer = get_node("LogicNode/WaitingTimer")
onready var LineWaitingTimer = get_node("LogicNode/LineWaitingTimer")
onready var OrderTimer = get_node("LogicNode/OrderTimer")
onready var OrderAngryTimer = get_node("LogicNode/OrderAngryTimer")
onready var StandTimer = get_node("LogicNode/StandTimer")
onready var LogicTimer = get_node("LogicNode/LogicTimer")
onready var Avatar

onready var LevelNode = get_tree().get_root().get_node("Level")
onready var Stat = get_node("LogicNode/Stat")
onready var Con = get_node("LogicNode/Control")
onready var Ray2D = get_node("RayCast2D")
onready var ItemYSort = LevelNode.get_node("YSort/Items")

onready var InfoLabel = get_node("Thinking/Ani/Label")
var Audio_NoOrder
var _OBJ_Block
func _ready() -> void :



	set_physics_process(true)
	_checktime = 0
	target = self.position
	Audio_NoOrder = GameLogic.Audio.return_Effect("未点单")

func call_courier_init():

	var _AvatarName = "DeliverCar"
	_Avatar_init(_AvatarName)



func call_personality_init(_NPCID):
	if Avatar == null:
		_selfTypeID = _NPCID
		Stat.BaseSpeed = int(GameLogic.Config.NPCConfig[_selfTypeID].BaseSpeed)

		var _AvatarName = GameLogic.Config.NPCConfig[_selfTypeID].Avatar
		var _AvatarID = GameLogic.Config.NPCConfig[_selfTypeID].PersonalityAniID
		SeatRat = float(GameLogic.Config.NPCConfig[_selfTypeID].SeatRat)
		_Avatar_init(_AvatarName)
		Avatar.call_personality_init(_AvatarID)


func call_order(_OrderID):
	PickUpID = _OrderID
	OrderAngryTimer.stop()

func _Avatar_init(_AvatarName):
	var _AvatarTSCN
	match _AvatarName:
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
	var _NoPersonal = int(GameLogic.Config.NPCConfig[_selfTypeID].NoPersonal)
	var _rand = randi() % 100 + 1

	if GameLogic.cur_Event == "点便宜":
		return GameLogic.Order.ORDERPERSONAL.CHEAPEST
	elif GameLogic.cur_Event == "点昂贵":
		return GameLogic.Order.ORDERPERSONAL.EXPENSIVE

	if _rand <= _NoPersonal:
		return GameLogic.Order.ORDERPERSONAL.NONE
	else:
		var _Personal = GameLogic.Config.NPCConfig[_selfTypeID].Personal
		match _Personal:
			"EXPENSIVE":
				return GameLogic.Order.ORDERPERSONAL.EXPENSIVE
			"CHEAPEST":
				return GameLogic.Order.ORDERPERSONAL.CHEAPEST
			"POPULAR":
				return GameLogic.Order.ORDERPERSONAL.POPULAR
			"ORDERCHEAPEST":
				return GameLogic.Order.ORDERPERSONAL.ORDERCHEAPEST
	return GameLogic.Order.ORDERPERSONAL.NONE

func _Order_Extra_Set():
	var Ratio_Base = int(GameLogic.Config.NPCConfig[_selfTypeID].Extra_Base)
	var Ratio_Tea = int(GameLogic.Config.NPCConfig[_selfTypeID].Extra_Tea)

	for i in 2:
		var _rand = randi() % 100 + 1
		match i:
			0:

				if GameLogic.cur_Event == "点小料":
					_rand -= 50
				elif GameLogic.cur_Event == "点小料+":
					_rand = 0
				if _rand <= Ratio_Base:
					Order_Extra_Base = true

			1:
				if GameLogic.cur_Event == "点小料":
					_rand -= 50
				elif GameLogic.cur_Event == "点小料+":
					_rand = 0
				if _rand <= Ratio_Tea:
					Order_Extra_Tea = true

func _Order_Type_Set():
	var Ratio_COFFEE = int(GameLogic.Config.NPCConfig[_selfTypeID].COFFEE)
	var Ratio_MILK = int(GameLogic.Config.NPCConfig[_selfTypeID].MILK)
	var Ratio_MILKTEA = int(GameLogic.Config.NPCConfig[_selfTypeID].MILKTEA)
	var Ratio_TEA = int(GameLogic.Config.NPCConfig[_selfTypeID].TEA)
	var Ratio_POP = int(GameLogic.Config.NPCConfig[_selfTypeID].POP)
	var Ratio_SOYBEAN = int(GameLogic.Config.NPCConfig[_selfTypeID].SOYBEAN)
	var Ratio_FRUIT = int(GameLogic.Config.NPCConfig[_selfTypeID].FRUIT)
	var Ratio_SHAKE = int(GameLogic.Config.NPCConfig[_selfTypeID].SHAKE)
	var Ratio_ICECREAM = int(GameLogic.Config.NPCConfig[_selfTypeID].ICECREAM)
	for i in 9:
		var _rand = randi() % 100 + 1
		match i:
			0:
				if _rand <= Ratio_COFFEE:
					Order_COFFEE = true
			1:
				if _rand <= Ratio_MILK:
					Order_MILK = true
			2:
				if _rand <= Ratio_MILKTEA:
					Order_MILKTEA = true
			3:
				if _rand <= Ratio_TEA:
					Order_TEA = true
			4:
				if _rand <= Ratio_POP:
					Order_POP = true
			5:
				if _rand <= Ratio_SHAKE:
					Order_SHAKE = true
			6:
				if _rand <= Ratio_FRUIT:
					Order_FRUIT = true
			7:
				if _rand <= Ratio_ICECREAM:
					Order_ICECREAM = true
			8:
				if _rand <= Ratio_SOYBEAN:
					Order_SOYBEAN = true

func _Order_Celicius_Set():
	var Ratio_Hot = int(GameLogic.Config.NPCConfig[_selfTypeID].Hot)
	var Ratio_Normal = int(GameLogic.Config.NPCConfig[_selfTypeID].Normal)
	var Ratio_Cold = int(GameLogic.Config.NPCConfig[_selfTypeID].Cold)
	for i in 3:
		var _rand = randi() % 100 + 1
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

func _Order_Sugar_Set():
	PopularMult = float(GameLogic.Config.NPCConfig[_selfTypeID].PopularMult)
	Rank = int(GameLogic.Config.NPCConfig[_selfTypeID].Rank)

	var Ratio_AnySugar = int(GameLogic.Config.NPCConfig[_selfTypeID].AnySugar)
	var Ratio_Sugar = int(GameLogic.Config.NPCConfig[_selfTypeID].NeedSugar)
	var _rand = randi() % 100 + 1
	if _rand < Ratio_AnySugar:
		Order_Sugar = GameLogic.Order.SUGARTYPE.ANY
	else:
		_rand = randi() % 100 + 1
		if _rand < Ratio_Sugar:
			Order_Sugar = GameLogic.Order.SUGARTYPE.SUGAR
		else:
			Order_Sugar = GameLogic.Order.SUGARTYPE.NOSUGAR

func call_touched():
	IsTouched = true
func _Order_Cup_Set():

	var Ratio_S = int(GameLogic.Config.NPCConfig[_selfTypeID]["S"])
	var Ratio_M = int(GameLogic.Config.NPCConfig[_selfTypeID]["M"])
	var Ratio_L = int(GameLogic.Config.NPCConfig[_selfTypeID]["L"])

	for i in 3:
		var _rand = randi() % 100 + 1
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
	Order_Personal = return_personal()


	_Order_Type_Set()
	_Order_Celicius_Set()
	_Order_Sugar_Set()
	_Order_Cup_Set()
	_Order_Thinking_Set()
	_Order_Extra_Set()

func _Collision_Logic():
	if SpecialType == 1:
		return
	if behavior != BEHAVIOR.LINE:
		_selfCollision.disabled = true
		EndTimer.start(0)
func _Collision_Logic_End():
	_selfCollision.disabled = false
	var _Transform2D = Transform2D(0, self.position)
	if not WaitingReset:
		if test_move(_Transform2D, Con.velocity):

			_Collision_Logic()

func return_Courier_Check():
	if IsCourier:
		if not Con.IsHold:
			return true
	return false

func call_courier(_targetPos, _itemName):

	var _BoxObj
	var _Num: int = 1
	var _TYPE
	if GameLogic.Config.ItemConfig.has(_itemName):
		_BoxObj = GameLogic.Buy.return_create_box()
		_Num = int(GameLogic.Config.ItemConfig[_itemName]["BuyNum"])
		_TYPE = GameLogic.Config.ItemConfig[_itemName]["FuncType"]
	elif GameLogic.Config.DeviceConfig.has(_itemName):
		_BoxObj = GameLogic.Buy.return_create_woodbox()
		_TYPE = GameLogic.Config.DeviceConfig[_itemName]["FuncType"]
	else:
		print("配送员，货物无法生成。货物名字：", _itemName)
		return
	HoldObj = _BoxObj
	self.Avatar.WeaponNode.add_child(_BoxObj)

	var _IsOpen: bool = false

	if _TYPE == "Fruit":
		_IsOpen = true
		if Avatar.has_node("AniNode/BoxType"):
			Avatar.get_node("AniNode/BoxType").play("fruit")
	var _INFO = {"HasItem": true, "IsOpen": _IsOpen, "ItemName": _itemName, "ItemNum": _Num, "TSCN": "Box_M_Paper", "Type": _TYPE, "pos": Vector2.ZERO}
	_BoxObj.call_load(_INFO)


	_BoxObj.call_Collision_Switch(false)
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.DELIVER
	target = self.position
	WayPoint_array = GameLogic.Astar.return_courier_WayPoint_Array(self.position, _targetPos)
	print("送货员逻辑：", WayPoint_array, _targetPos)
	_selfCollision.disabled = false

	Con.IsHold = true
	Con.NeedPush = true
	_selfCollision.disabled = true
	IsCourier = true
	self.add_to_group("Couriers")
	Stat.call_NPC_init()

func call_thief():
	SpecialType = 1
	var _targetPos: Vector2
	if GameLogic.Staff.LevelNode.has_node("YSort/Items"):
		var _ItemYSort = GameLogic.Staff.LevelNode.get_node("YSort/Items")
		for _Node in _ItemYSort.get_children():
			if _Node.IsItem:
				if not _Node.FuncType in ["Box", "BoxWood", "Trashbag", "DrinkCup"]:
					if _Node.FuncType in ["Bottle", "Can"]:
						if _Node.Liquid_Count > 0:
							_targetPos = _Node.position
							_PickUpDev = _Node
							IsPickUp = true
							break
					elif _Node.FuncType in ["Sugar"]:
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
			for _Node in _DevYSort.get_children():
				if _Node.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
					if _Node.OnTableObj:
						if _Node.OnTableObj.IsItem:
							if not _Node.OnTableObj.FuncType in ["Box", "BoxWood", "Trashbag", "DrinkCup"]:
								_targetPos = _Node.position
								_PickUpDev = _Node
								IsPickUp = false
	if _targetPos == Vector2.ZERO:

		call_Thief_leaving()
		return
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.STEAL
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _targetPos)
	_selfCollision.disabled = false
	self.add_to_group("NPC")
	Stat.call_NPC_init()
func return_ReCheck_WayPoint(_targetPos):
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _targetPos)
	if not WayPoint_array.size():
		return true
	else:
		return false
func call_passer(_targetPos):
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)
	_selfCollision.disabled = false
	IsPasser = true
	self.add_to_group("Passers")
	self.add_to_group("NPC")
	Stat.call_NPC_init()

func call_customer(_targetPos):

	if not GameLogic.Order.cur_OrderArray.size():
		if GameLogic.cur_Rewards.has("新顾客"):
			GameLogic.call_Info(1, "新顾客")

			Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 1.5
		if GameLogic.cur_Rewards.has("新顾客+"):
			GameLogic.call_Info(1, "新顾客+")

			Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 3



	var _SeatRand = randi() % 100
	if _SeatRand < SeatRat:
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
	_selfCollision.disabled = false


	var _INFO = GameLogic.Config.NPCConfig[_selfTypeID]
	var _LineUpTime = int(_INFO["LineUpTime"])
	if GameLogic.cur_Event == "排队等待":
		_LineUpTime = int(float(_LineUpTime) * 1.5)
	WaitingTimer.wait_time = _LineUpTime
	var _OrderTime = int(_INFO["OrderTime"])

	if GameLogic.cur_Challenge.has("不耐烦"):
		_LineUpTime = float(_LineUpTime) * 0.75
	if GameLogic.cur_Challenge.has("不耐烦+"):
		_LineUpTime = float(_LineUpTime) * 0.5
	LineWaitingTimer.wait_time = _LineUpTime
	OrderTimer.wait_time = _OrderTime

	OrderAngryTimer.wait_time = 5

	LogicTimer.wait_time = int(_INFO["SeatTime"])





	IsCustomer = true
	self.add_to_group("Customers")
	self.add_to_group("NPC")
	Stat.call_NPC_init()

func call_picker(_targetPos):
	IsPickUp = true
	WaitingTimer.set_paused(true)
	StandTimer.set_paused(true)
	_Path_IsFinish = false
	_FinalTarget = _targetPos
	behavior = BEHAVIOR.PICKUP
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _targetPos)
	_selfCollision.disabled = true
func call_RePicker():
	IsPickUp = false
	WaitingTimer.set_paused(false)
	StandTimer.set_paused(false)
	behavior = BEHAVIOR.MOVE

func _on_StandTimer_timeout() -> void :

	var WAITTYPE = GameLogic.Config.NPCConfig[_selfTypeID]["WAITTYPE"]
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

func call_wait_logic():

	OrderTimer.stop()
	OrderAngryTimer.stop()
	if ThinkingAni.assigned_animation == "angry":
		ThinkingAni.play("hide")
	WaitingReset = false



	if IsSit:
		_WaitingTime_Set()
		return
	var WAITTYPE = GameLogic.Config.NPCConfig[_selfTypeID]["WAITTYPE"]

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

func _WaitingTime_Set():
	OrderWait_bool = false
	WaitTime = float(GameLogic.Config.NPCConfig[_selfTypeID]["WaitTime"])

	if GameLogic.cur_Event == "等餐":
		WaitTime = int(float(WaitTime) * 1.25)
	if GameLogic.cur_Event == "等餐+":
		WaitTime = int(float(WaitTime) * 1.5)
	if GameLogic.cur_Challenge.has("顾客等餐"):
		WaitTime = int(float(WaitTime) * 0.9)
	if GameLogic.cur_Challenge.has("顾客等餐+"):
		WaitTime = int(float(WaitTime) * 0.8)

	if GameLogic.Achievement.cur_EquipList.has("等餐耐心"):
		WaitTime += int(float(WaitTime) * 0.2)

	WaitingTimer.wait_time = WaitTime

	WaitingTimer.start(0)
	if GameLogic.Order.cur_LineUpArray.has(self):
		GameLogic.Order.cur_LineUpArray.erase(self)
func Waiter_STAND_Logic():

	if int(WaitTime) == 0:
		_WaitingTime_Set()
		_call_Beside_RandomMove()
	else:

		_selfCollision.disabled = false
		var _Transform2D = Transform2D(0, self.position)
		if test_move(_Transform2D, Con.velocity):

			_call_Beside_RandomMove()
		else:

			StandTimer.wait_time = randi() % int(WaitTime) + 1
			StandTimer.start(0)

func Waiter_MOVE_Logic():

	if int(WaitTime) == 0:
		_WaitingTime_Set()
		_call_InStore_RandomMove()
	else:

		_selfCollision.disabled = false
		var _Transform2D = Transform2D(0, self.position)
		if test_move(_Transform2D, Con.velocity):

			_call_InStore_RandomMove()
		else:

			StandTimer.wait_time = randi() % int(WaitTime) + 1
			StandTimer.start(0)


func _call_Beside_RandomMove():
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
	_selfCollision.disabled = false
func _call_InStore_RandomMove():
	_FinalTarget = GameLogic.NPC.return_inStorePoint()
	_Path_IsFinish = false
	behavior = BEHAVIOR.MOVE
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _FinalTarget)
	_selfCollision.disabled = false

func _Waiting_Check():
	Ray2D.force_raycast_update()
	if Ray2D.is_colliding():
		var collider = Ray2D.get_collider()

		if collider.editor_description == "NPC":

			if behavior in [BEHAVIOR.MOVE, BEHAVIOR.WAIT]:
				if collider.behavior == BEHAVIOR.WAIT:
					if collider._Path_IsFinish:
						var _randi = randi() % 2
						_on_StandTimer_timeout()

			elif behavior == BEHAVIOR.CUSTOMER:
				if collider.behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER]:
					LineNPC = collider
					if LineWaitingTimer.is_stopped():
						LineWaitingTimer.start(0)
						_Add_Customer()
					behavior = BEHAVIOR.LINE
				elif collider.behavior == BEHAVIOR.WAIT:

					collider._on_StandTimer_timeout()
func Ray2D_Logic(_delta):

	Con.input_vector = Con.velocity.normalized()
	if behavior in [BEHAVIOR.CUSTOMER, BEHAVIOR.MOVE]:
		Ray2D.cast_to = Con.input_vector * 35

		_Waiting_Check()

func _physics_process(_delta: float) -> void :
	if not Stat.Ins_MAXSPEED:
		return
	Con.velocity = position.direction_to(target) * Stat.Ins_MAXSPEED
	Con.velocity = Con.velocity * float(Stat.Ins_SpeedMult)

	if behavior != BEHAVIOR.LINE:
		Ray2D_Logic(_delta)
		if not _Path_IsFinish:
			if self.position.distance_to(target) < 20:

				next_point()
			move(_delta)
		elif self.position != target:
			if IsSit:
				self.position = Vector2.ZERO
				Con.state = Con.STATE.SIT
			else:
				self.position = target

	else:
		if _selfCollision.disabled:
			_selfCollision.disabled = false
		LineTime += _delta
		if LineTime > 0.5:
			LineTime = 0
			if is_instance_valid(LineNPC):
				if not (LineNPC.behavior in [BEHAVIOR.LINE, BEHAVIOR.ORDER]):

					behavior = BEHAVIOR.CUSTOMER
					WaitingReset = true
					LineNPC = null
	_ani_logic()

func _ani_logic():
	if IsSit:
		return
	var _aniSpeed = _return_ani_speed()
	if _aniSpeed > 0:
		if Con.state != Con.STATE.MOVE:
			Con.state = Con.STATE.MOVE
	else:
		if Con.state != Con.STATE.IDLE_EMPTY:
			Con.state = Con.STATE.IDLE_EMPTY
	match behavior:
		BEHAVIOR.LINE:
			if Con.state != Con.STATE.IDLE_EMPTY:
				Con.state = Con.STATE.IDLE_EMPTY

	pass
func move(_delta):

	Con.velocity = move_and_slide(Con.velocity)
	var _aniSpeed = _return_ani_speed()
	if not WaitingReset:
		if _aniSpeed < 0.5:
			if EndTimer.is_stopped():
				_checktime += _delta
				if _checktime > 0.5:
					_Collision_Logic()
					_checktime = 0
			else:
				_checktime = 0
		else:
			_checktime = 0


func call_sitting():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_sitting")
	IsSit = true
	PosSave = self.position
	SeatOBJ.call_sitting(self)
	if not PickUpID:

		_orderType_init()

		_call_thinking()

	pass
func _thief_run_away():
	IsPasser = true
	_selfCollision.disabled = true
	ThinkingAni.play("thief_run")
	if Con.IsHold:
		_thief_putDown()
	var _MoneyGet: int = 0
	if GameLogic.Save.gameData.HomeDevList.has("鞋柜"):
		_MoneyGet += 2
	if _MoneyGet != 0:
		GameLogic.call_MoneyChange(_MoneyGet)
		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PayEffect.position = self.global_position
		GameLogic.Staff.LevelNode.add_child(_PayEffect)
		_PayEffect.call_init(_MoneyGet, _MoneyGet, 0, false, false, false, false)
	var _Popular: int = 0
	if GameLogic.Save.gameData.HomeDevList.has("鞋柜"):
		_Popular += 2
	if _Popular != 0:
		GameLogic.call_Popular(_Popular)

	GameLogic.Save.statisticsData["Count_CatchThief"] += 1
	call_Thief_leaving()
	Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 1.5
	var _Audio = GameLogic.Audio.return_Effect("碰杯子")
	_Audio.play(0)
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
					if not _PickUpDev.OnTableObj.FuncType in ["Box", "BoxWood", "Trashbag", "DrinkCup"]:
						_Thief_pickUp(_PickUpDev.OnTableObj)
						_PickUpDev.OnTableObj = null
						return
	call_thief()
func _Thief_pickUp(_OBJ):
	var _ParNode = _OBJ.get_parent()
	_ParNode.remove_child(_OBJ)
	_OBJ.position = Vector2.ZERO
	self.Avatar.WeaponNode.add_child(_OBJ)
	HoldObj = _OBJ
	if _OBJ.has_method("call_Collision_Switch"):
		_OBJ.call_Collision_Switch(false)

	Con.IsHold = true


	call_Thief_leaving()
func next_point():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SpecialType == 1 and not IsPasser and not Con.IsHold:
		var _rand = randi() % 5
		if not _rand:
			call_thief()
			return

	if WayPoint_array.size():
		target = WayPoint_array.pop_front()
		SteamLogic.call_NPC_sync(self, "_Puppet_SYNC", [self.global_position, target])
	else:

		_Path_IsFinish = true
		Stat._data_instance()
		match behavior:
			BEHAVIOR.STEAL:
				call_stealing()
			BEHAVIOR.DELIVER:
				_putDown(target)
				call_leaving()
			BEHAVIOR.CUSTOMER:


				if SeatOBJ and not IsSit:
					call_sitting()
					return
				behavior = BEHAVIOR.ORDER
				if not PickUpID:

					_orderType_init()

					_call_thinking()
			BEHAVIOR.MOVE:
				behavior = BEHAVIOR.WAIT
				call_wait_logic()

			BEHAVIOR.PICKUP:
				_pickUp()
			BEHAVIOR.PASSER:
				_free_logic()
			BEHAVIOR.LEAVE:
				_free_logic()
func _free_logic():
	SteamLogic.call_NPC_sync(self, "call_del")
	call_del()

func _Order_Thinking_Set():


	var _npcThinkTime = int(GameLogic.Config.NPCConfig[_selfTypeID]["ThinkTime"])


	if GameLogic.cur_Challenge.has("选择困难"):

		_npcThinkTime += _npcThinkTime * 0.5
	if GameLogic.cur_Challenge.has("选择困难+"):

		_npcThinkTime += _npcThinkTime
	if not GameLogic.Order.cur_OrderArray.size():
		if GameLogic.cur_Rewards.has("新顾客"):

			_npcThinkTime = _npcThinkTime * 0.5
		if GameLogic.cur_Rewards.has("新顾客+"):

			_npcThinkTime = 0
	ThinkingTimer.wait_time = _npcThinkTime

	if GameLogic.cur_Rewards.has("排队"):

		LineWaitingTimer.wait_time = LineWaitingTimer.wait_time * 2
	if GameLogic.cur_Rewards.has("排队+"):

		LineWaitingTimer.wait_time = LineWaitingTimer.wait_time * 999

func _call_thinking():
	if ThinkingAni.is_playing():
		print("call thinking")
		return
	LineWaitingTimer.stop()
	if ThinkingTimer.wait_time > 0 and ThinkingTimer.time_left == 0:
		ThinkingAni.play("show")
		ThinkingTimer.start()
		_Add_Customer()

	else:
		_on_ThinkingTimer_timeout()

func _on_ThinkingTimer_timeout() -> void :
	print("NPC思考结束")
	if ThinkingAni.is_playing():
		ThinkingAni.stop()
	if ThinkingTimer.wait_time > 0:
		ThinkingAni.play("hide")

	OrderName = GameLogic.Order.return_order_NPC(self)
	print("NPC: ", OrderName)
	if OrderName != "":
		if not IsSit:
			GameLogic.Order.call_NPC_LineUp(self)
			OrderWait_bool = true
			OrderTimer.start(0)
		else:
			print("点单逻辑")
			SeatOBJ.call_NPC_order()
			OrderTimer.start(0)
			pass

	else:
		if not IsSit:
			if GameLogic.Order.cur_LineUpArray.has(self):
				GameLogic.Order.cur_LineUpArray.erase(self)

			_NoOrder_reason_show()
			call_leaving()
			Audio_NoOrder.play(0)

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





	pass

func call_pickup(_devObj, _check):
	PickCheck = _check
	_PickUpDev = _devObj
	GameLogic.Order.call_PickUp_Order(PickUpID)
	if not IsSit:
		call_picker(_devObj.global_position)
		WaitingReset = false

		if GameLogic.cur_Rewards.has("小蜜蜂"):

			Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 2

		if GameLogic.cur_Rewards.has("小蜜蜂+"):
			Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 4

		if GameLogic.cur_Challenge.has("不慌不急"):
			Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 0.75
		if GameLogic.cur_Challenge.has("不慌不急+"):
			Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 0.5
func _point_logic():



	var _total = int(PickCheck.Total)
	var _keys = PickCheck.keys()

	for i in _keys.size():
		var _PointValue = PickCheck[_keys[i]]
		if typeof(_PointValue) == TYPE_INT:
			Point += _PointValue
	Point -= (_total + PickCheck.ExtraMax)
	PerfectPoint = _total
	NormalPoint = PerfectPoint - 1
	if NormalPoint < 0:
		NormalPoint = 0



	if GameLogic.cur_Rewards.has("连续完美"):
		if GameLogic.Day_Perfect == 1:
			if Point >= NormalPoint and Point < 1:
				GameLogic.call_Info(1, "连续完美")
				Point = 1
				GameLogic.Day_Perfect = 2
	if GameLogic.cur_Rewards.has("连续完美+"):
		if GameLogic.Day_Perfect == 1:
			if Point < 1:
				GameLogic.call_Info(1, "连续完美+")
				Point = 1
				GameLogic.Day_Perfect = 2


	var _PopularNum: int = 0
	if Point >= PerfectPoint:
		if GameLogic.Day_Perfect == 2:
			GameLogic.Day_Perfect = 0
		else:
			GameLogic.Day_Perfect = 1

		PointType = 0
		var _OrderList = GameLogic.Order.cur_OrderList.keys()

		var _COMBO: int = 0
		if PickUpID != _OrderList.front():

			if not GameLogic.cur_Rewards.has("跳单出杯COMBO") and not GameLogic.cur_Rewards.has("跳单出杯COMBO+"):
				GameLogic.call_combo_break()
			if GameLogic.cur_Rewards.has("跳单出杯COMBO"):
				GameLogic.call_Info(1, "跳单出杯COMBO")
			if GameLogic.cur_Rewards.has("跳单出杯COMBO+"):
				GameLogic.call_Info(1, "跳单出杯COMBO+")
				_COMBO += 1
		else:

			_COMBO += 1
			if GameLogic.cur_Rewards.has("完美COMBO"):
				var _rand = randi() % 4

				if _rand == 0:
					GameLogic.call_Info(1, "完美COMBO")
					_COMBO += 1
			elif GameLogic.cur_Rewards.has("完美COMBO+"):
				var _rand = randi() % 2
				if _rand == 0:
					GameLogic.call_Info(1, "完美COMBO+")
					_COMBO += 1



		GameLogic.call_combo(_COMBO)

		HappyAni.play("1")


		var _PopularBase: int = 5
		if GameLogic.Save.gameData.HomeDevList.has("绿色地毯"):
			_PopularBase += 1
		if GameLogic.Save.gameData.HomeDevList.has("浴室地毯"):
			_PopularBase += 1
		if GameLogic.Save.gameData.HomeDevList.has("毛绒地毯"):
			_PopularBase += 1
		if GameLogic.Save.gameData.HomeDevList.has("书房地毯"):
			_PopularBase += 1
		if GameLogic.cur_Combo > 1:
			_PopularNum += _PopularBase + GameLogic.cur_Combo - 1
		else:
			_PopularNum += _PopularBase
	elif Point >= NormalPoint:
		GameLogic.Day_Perfect = 0

		PointType = 1
		GameLogic.call_GoodSell()


		var _check: bool
		if GameLogic.cur_Rewards.has("非完美出杯COMBO"):
			GameLogic.call_Info(1, "非完美出杯COMBO")
			_check = true
		if GameLogic.cur_Rewards.has("非完美出杯COMBO+"):
			GameLogic.call_Info(1, "非完美出杯COMBO+")
			GameLogic.call_combo(1)
			_check = true
		if not _check:
			print("稍差 打断combo")
			GameLogic.call_combo_break()


		if GameLogic.cur_Rewards.has("跳单出杯COMBO"):
			GameLogic.call_Info(1, "跳单出杯COMBO")
		if GameLogic.cur_Rewards.has("跳单出杯COMBO+"):
			GameLogic.call_Info(1, "跳单出杯COMBO+")
			GameLogic.call_combo(1)
		if GameLogic.cur_Rewards.has("跳单减压"):
			GameLogic.call_Info(1, "跳单减压")
			GameLogic.emit_signal("Pressure_Set", - 1)
		if GameLogic.cur_Rewards.has("跳单减压+"):
			GameLogic.call_Info(1, "跳单减压+")
			GameLogic.emit_signal("Pressure_Set", - 2)




		if PickCheck.Celcius == 0:
			ThinkingAni.play("Celcius")
		elif PickCheck.Extra < PickCheck.ExtraMax:
			ThinkingAni.play("ExtraWrong")
		elif PickCheck.Sugar == 0:

			if PickCheck.SugarIn:
				ThinkingAni.play("SugarMore")
			else:
				ThinkingAni.play("NoSugar")
		elif PickCheck.Condiment_1 == 0:
			ThinkingAni.play("ForWrong")
		elif PickCheck.Mixd == 0:
			ThinkingAni.play("MixWrong")
		else:
			ThinkingAni.play("ForWrong")






		HappyAni.play("2")
		if GameLogic.cur_Combo > 1:
			_PopularNum += 3 + GameLogic.cur_Combo - 1
		else:
			_PopularNum += 3
	else:
		GameLogic.Day_Perfect = 0

		PointType = 2
		GameLogic.call_BadSell()

		if GameLogic.cur_Rewards.has("非完美出杯COMBO") or GameLogic.cur_Rewards.has("非完美出杯COMBO+"):
			pass
		else:
			GameLogic.call_combo_break()
		if GameLogic.cur_Rewards.has("非完美出杯COMBO"):
			GameLogic.call_Info(1, "非完美出杯COMBO")
		if GameLogic.cur_Rewards.has("非完美出杯COMBO+"):
			GameLogic.call_Info(1, "非完美出杯COMBO+")
			GameLogic.call_combo(1)


		if GameLogic.cur_Rewards.has("跳单出杯COMBO"):
			GameLogic.call_Info(1, "跳单出杯COMBO")
		if GameLogic.cur_Rewards.has("跳单出杯COMBO+"):
			GameLogic.call_Info(1, "跳单出杯COMBO+")
			GameLogic.call_combo(1)
		if GameLogic.cur_Rewards.has("跳单减压"):
			GameLogic.call_Info(1, "跳单减压")
			GameLogic.emit_signal("Pressure_Set", - 1)
		if GameLogic.cur_Rewards.has("跳单减压+"):
			GameLogic.call_Info(1, "跳单减压+")
			GameLogic.emit_signal("Pressure_Set", - 2)


		ThinkingAni.play("TooWrong")
		HappyAni.play("3")


		if GameLogic.cur_Combo > 1:
			_PopularNum += 1 + GameLogic.cur_Combo - 1
		else:
			_PopularNum += 1
	GameLogic.call_Popular(_PopularNum)
func call_pickUp_false():
	GameLogic.Order.call_PickUp_NotOrder(PickUpID)
	call_RePicker()
	call_wait_logic()
func _pickUp():

	if not IsSit:
		if _PickUpDev.OnTableObj == null:
			call_pickUp_false()
			return
		elif _PickUpDev.OnTableObj.FuncType != "DrinkCup":
			call_pickUp_false()
			return
		elif _PickUpDev.OnTableObj.cur_ID != PickUpID:
			call_pickUp_false()
			return
		var _CupObj = _PickUpDev.OnTableObj
		_PickUpDev.OnTableObj = null

		var _ParNode = _CupObj.get_parent()
		_ParNode.remove_child(_CupObj)

		self.Avatar.WeaponNode.add_child(_CupObj)
		_CupObj.CupInfoAni.play("hide")
		_CupObj.ButInfo_Switch( - 2, "")
		_CupObj.get_node("But").hide()
		_CupObj.IsPickUp = true

		_SellLogic()
	else:
		var _CupOBJ
		match SeatOBJ.name:
			"L":
				_CupOBJ = SeatOBJ.get_parent().get_node("L_OBJ").get_child(0)
			"R":
				_CupOBJ = SeatOBJ.get_parent().get_node("R_OBJ").get_child(0)
		if is_instance_valid(_CupOBJ):
			if _CupOBJ.has_method("call_FinishUpdate"):
				_CupOBJ.get_parent().remove_child(_CupOBJ)
				self.Avatar.WeaponNode.add_child(_CupOBJ)
				_CupOBJ.CupInfoAni.play("hide")
				_CupOBJ.ButInfo_Switch( - 2, "")
				_CupOBJ.get_node("But").hide()
				_CupOBJ.IsPickUp = true
				_PickUpDev = SeatOBJ.get_parent()
				_SellLogic()
		else:
			printerr("出杯错误，CupOBJ：", _CupOBJ)



	call_leaving()
func _SellLogic():
	_point_logic()
	_sell_logic()
	PickUpID = 0
	Con.IsHold = true

	call_leaving()

func call_happy(_type):
	if int(_type) in [1, 2, 3]:
		HappyAni.play(str(_type))

func _sell_logic():



	if GameLogic.Order.cur_OrderList.has(PickUpID):
		var _cur_Order = GameLogic.Order.cur_OrderList[PickUpID]
		var _OrderName = _cur_Order["Name"]
		var _BasePay = int(GameLogic.Config.FormulaConfig[_OrderName]["Price"])
		var _Pay: int = _BasePay
		var _Tip: int = 0
		var IsCri: bool = false
		var IsQuick: bool
		var IsSlow: bool
		var IsJump: bool
		var _CriRand = randi() % 100 + 1
		var _CriCheckNum: int = 5
		var _Pressure: int = 0



		var _ExtraArray = _cur_Order.ExtraArray

		if _ExtraArray.size() > 0:
			for i in _ExtraArray.size():
				var _Extra = _ExtraArray[i]
				var _ExtraPrice = int(GameLogic.Config.FormulaConfig[_Extra].Price)
				if GameLogic.cur_Rewards.has("高价小料"):
					GameLogic.call_Info(1, "高价小料")
					_ExtraPrice += int(float(_ExtraPrice) * 0.5)
				if GameLogic.cur_Rewards.has("高价小料+"):
					GameLogic.call_Info(1, "高价小料+")
					_ExtraPrice += _ExtraPrice
				_BasePay += _ExtraPrice
				_Pay += _ExtraPrice





		var _PayMult: float = 1
		var _TipMult: float = 1
		if GameLogic.cur_Event == "加糖日" or GameLogic.cur_Event == "加冰日":
			_PayMult += 0.25


		var _PointCheck: bool

		if PointType == 0:
			_PointCheck = true
			GameLogic.Save.statisticsData["Count_PerfectSell"] += 1
		elif GameLogic.cur_Rewards.has("需加小费") and PointType in [0, 1]:
			_PointCheck = true
		elif GameLogic.cur_Rewards.has("需加小费+") and PointType in [0, 1, 2]:
			_PointCheck = true
		if _PointCheck:
			if GameLogic.cur_Rewards.has("出手阔绰"):

				_CriCheckNum += 5
			if GameLogic.cur_Rewards.has("出手阔绰+"):

				_CriCheckNum += 10
			if GameLogic.Save.gameData.HomeDevList.has("盆栽竹子"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("挂墙绿植"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("仙人掌"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("捕蝇草"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("清新绿植"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("龟背竹"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("幸运树"):
				_CriCheckNum += 1
			if GameLogic.Save.gameData.HomeDevList.has("高大绿植"):
				_CriCheckNum += 1
			var _TipBaseMult: float = 0.1
			if GameLogic.cur_Rewards.has("高额小费"):
				GameLogic.call_Info(1, "高额小费")
				_TipBaseMult = 0.2
			elif GameLogic.cur_Rewards.has("高额小费+"):
				GameLogic.call_Info(1, "高额小费+")
				_TipBaseMult = 0.3
			var _BaseTip: int
			if GameLogic.Save.gameData.HomeDevList.has("来者不拒"):
				_BaseTip = int(float(_Pay) * _TipBaseMult + 0.5)
			else:
				_BaseTip = int(float(_Pay) * _TipBaseMult)
			if _BaseTip < 1:
				_BaseTip = 1
			if GameLogic.Achievement.cur_EquipList.has("额外小费"):
				_BaseTip += 1
			_Tip = _BaseTip

			if GameLogic.cur_Combo < 2:
				if GameLogic.cur_Rewards.has("无COMBO加价"):
					GameLogic.call_Info(1, "无COMBO加价")
					_PayMult += 2
				elif GameLogic.cur_Rewards.has("无COMBO加价+"):
					GameLogic.call_Info(1, "无COMBO加价+")
					_PayMult += 5
			else:
				if GameLogic.cur_Rewards.has("小费随COMBO"):
					if GameLogic.Save.gameData.HomeDevList.has("来者不拒"):
						_Tip += int(float(GameLogic.cur_Combo) * 0.5 + 0.5)
					else:
						_Tip += int(float(GameLogic.cur_Combo) * 0.5)
					GameLogic.call_Info(1, "小费随COMBO")
				elif GameLogic.cur_Rewards.has("小费随COMBO+"):
					_Tip += int(float(GameLogic.cur_Combo) * 1)
					GameLogic.call_Info(1, "小费随COMBO+")
				if GameLogic.cur_Rewards.has("COMBO加价"):
					_PayMult += (float(GameLogic.cur_Combo) / 2) * 0.25
					GameLogic.call_Info(1, "COMBO加价")
				elif GameLogic.cur_Rewards.has("COMBO加价+"):
					GameLogic.call_Info(1, "COMBO加价+")
					_PayMult += float(GameLogic.cur_Combo) * 0.25


		var _OrderList = GameLogic.Order.cur_OrderList.keys()
		if PickUpID != _OrderList.front():
			IsJump = true
			if GameLogic.cur_Rewards.has("跳单加价"):
				GameLogic.call_Info(1, "跳单加价")
				_PayMult += 0.2
			if GameLogic.cur_Rewards.has("跳单加价+"):
				GameLogic.call_Info(1, "跳单加价+")
				_PayMult += 0.4

			if GameLogic.cur_Rewards.has("跳单减压"):
				GameLogic.call_Info(1, "跳单减压")
				_Pressure -= 1
			if GameLogic.cur_Rewards.has("跳单减压+"):
				GameLogic.call_Info(1, "跳单减压+")
				_Pressure -= 2

		if GameLogic.cur_Rewards.has("轻松增价"):
			if GameLogic.P1_Pressure == 0 and GameLogic.P2_Pressure == 0:
				_Pay += int(float(_Pay) * 0.25)
				GameLogic.call_Info(1, "轻松增价")
		if GameLogic.cur_Rewards.has("轻松增价+"):
			if GameLogic.P1_Pressure == 0 and GameLogic.P2_Pressure == 0:
				_Pay += int(float(_Pay) * 0.5)
				GameLogic.call_Info(1, "轻松增价+")
		if GameLogic.cur_Rewards.has("小费提升"):
			GameLogic.call_Info(1, "小费提升")
			_Tip += int(float(GameLogic.cur_SellNum) / 3)
		if GameLogic.cur_Rewards.has("小费提升+"):
			GameLogic.call_Info(1, "小费提升+")
			_Tip += int(float(GameLogic.cur_SellNum) / 2)
		if GameLogic.cur_Rewards.has("价格上调"):
			GameLogic.call_Info(1, "价格上调")
			_Pay += int(float(_Pay) * 0.2)
		if GameLogic.cur_Rewards.has("价格上调+"):
			GameLogic.call_Info(1, "价格上调+")
			_Pay += int(float(_Pay) * 0.4)
		if GameLogic.cur_SellMenu == OrderName:
			if GameLogic.cur_Rewards.has("指定饮品"):
				GameLogic.call_Info(1, "指定饮品")
				_TipMult += 0.5
			if GameLogic.cur_Rewards.has("指定饮品+"):
				GameLogic.call_Info(1, "指定饮品+")
				_PayMult += 0.25
				_TipMult += 1
		else:
			if GameLogic.cur_Rewards.has("交替贩卖"):
				GameLogic.call_Info(1, "交替贩卖")
				_TipMult += 0.5
			if GameLogic.cur_Rewards.has("交替贩卖+"):
				GameLogic.call_Info(1, "交替贩卖+")
				_PayMult += 0.25
				_TipMult += 1
		if GameLogic.cur_Combo < 2:
			if GameLogic.cur_Rewards.has("无连加价"):
				GameLogic.call_Info(1, "无连加价")
				_PayMult += 1
			elif GameLogic.cur_Rewards.has("无连加价+"):
				GameLogic.call_Info(1, "无连加价+")
				_PayMult += 2.5
		if GameLogic.P1_Pressure > (GameLogic.P1_Pressure_Max * 0.5) or GameLogic.P2_Pressure > (GameLogic.P2_Pressure_Max * 0.5):

			if GameLogic.cur_Rewards.has("高压加价"):
				GameLogic.call_Info(1, "高压加价")
				_PayMult += 0.5
			elif GameLogic.cur_Rewards.has("高压加价+"):
				GameLogic.call_Info(1, "高压加价+")
				_PayMult += 1
				_TipMult += 0.5
		if GameLogic.P1_Pressure == 0 or (GameLogic.Player2_bool and GameLogic.P2_Pressure == 0):
			if GameLogic.cur_Rewards.has("无压加价"):

				GameLogic.call_Info(1, "无压加价")
				_PayMult += 0.5
			if GameLogic.cur_Rewards.has("无压加价+"):
				GameLogic.call_Info(1, "无压加价+")
				_PayMult += 1
				_TipMult += 0.5
		if GameLogic.P1_Pressure > 0 or GameLogic.P2_Pressure > 0:
			if GameLogic.cur_Rewards.has("压力加价"):
				GameLogic.call_Info(1, "压力加价")
				_PayMult += 0.25
			if GameLogic.cur_Rewards.has("压力加价+"):
				GameLogic.call_Info(1, "压力加价+")
				_PayMult += 0.5
				_TipMult += 0.25
		if GameLogic.cur_Rewards.has("加压"):
			GameLogic.call_Info(1, "加压")
			_PayMult += 0.5
		elif GameLogic.cur_Rewards.has("加压+"):
			GameLogic.call_Info(1, "加压+")
			_PayMult += 1
			_TipMult += 0.5
		if GameLogic.cur_Rewards.has("额外小费"):
			GameLogic.call_Info(1, "额外小费")
			_Tip += 1
		elif GameLogic.cur_Rewards.has("额外小费+"):
			GameLogic.call_Info(1, "额外小费+")
			_Tip += 2
		if GameLogic.cur_Rewards.has("小蜜蜂"):
			GameLogic.call_Info(1, "小蜜蜂")
			_Tip += 1
		elif GameLogic.cur_Rewards.has("小蜜蜂+"):
			GameLogic.call_Info(1, "小蜜蜂+")
			_Tip += 2
		if GameLogic.cur_Rewards.has("丢单重点+"):

			if ReOrder:
				_PayMult += 2


		var OrderNode = GameLogic.Order.OrderNode
		if OrderNode.has_node(str(PickUpID)):
			var _PickOrder = OrderNode.get_node(str(PickUpID))

			var _Rat: float = float(_PickOrder.RefundTimeBar.value) / float(_PickOrder.RefundTimeBar.max_value)
			var _QuickMult = 0.9
			if GameLogic.cur_Rewards.has("快速出杯简化"):
				_QuickMult = 0.8
			if GameLogic.cur_Rewards.has("快速出杯简化+"):
				_QuickMult = 0.7

			if _Rat >= _QuickMult:
				IsQuick = true

				if GameLogic.cur_Rewards.has("快出COMBO"):
					GameLogic.call_Info(1, "快出COMBO")
					GameLogic.call_combo(1)

				elif GameLogic.cur_Rewards.has("快出COMBO+"):
					GameLogic.call_Info(1, "快出COMBO+")
					var _COMBO = 0
					var _rand = randi() % 2 + 2
					for _i in _rand:
						_COMBO += 1
					GameLogic.call_combo(_COMBO)
				if GameLogic.cur_Rewards.has("快出减压"):
					GameLogic.call_Info(1, "快出减压")
					_Pressure -= 1
				if GameLogic.cur_Rewards.has("快出减压+"):
					GameLogic.call_Info(1, "快出减压+")
					_Pressure -= 2

				if GameLogic.cur_Rewards.has("快出加价"):
					GameLogic.call_Info(1, "快出加价")
					_Tip += 2
				if GameLogic.cur_Rewards.has("快出加价+"):
					GameLogic.call_Info(1, "快出加价+")
					_Tip += 4
				if GameLogic.cur_Quick > 0:
					if GameLogic.cur_Rewards.has("连续快出"):
						GameLogic.call_Info(1, "连续快出")
						_PayMult += 1
					if GameLogic.cur_Rewards.has("连续快出+"):
						GameLogic.call_Info(1, "连续快出+")
						_PayMult += 1
						_TipMult += 1
			if _Rat <= 0.25:
				IsSlow = true
				if GameLogic.cur_Rewards.has("极限出杯"):
					GameLogic.call_Info(1, "极限出杯")
					_TipMult += 0.5
				if GameLogic.cur_Rewards.has("极限出杯+"):
					GameLogic.call_Info(1, "极限出杯+")
					_TipMult += 1

		if GameLogic.cur_Challenge.has("小费减少"):
			GameLogic.call_Info(2, "小费减少")
			_Tip -= 1
		if GameLogic.cur_Challenge.has("小费减少+"):
			GameLogic.call_Info(2, "小费减少+")
			_Tip -= 2
		if GameLogic.cur_Challenge.has("小费减少++"):
			GameLogic.call_Info(2, "小费减少++")
			_Tip -= 4
		if GameLogic.cur_Challenge.has("打折"):
			GameLogic.call_Info(2, "打折")
			_PayMult = _PayMult * 0.95
		if GameLogic.cur_Challenge.has("打折+"):
			GameLogic.call_Info(2, "打折+")
			_PayMult = _PayMult * 0.9
		if GameLogic.cur_Challenge.has("打折++"):
			GameLogic.call_Info(2, "打折++")
			_PayMult = _PayMult * 0.8
		if GameLogic.cur_Challenge.has("白嫖"):
			var _rand = randi() % 10
			if _rand == 0:
				GameLogic.call_Info(2, "白嫖")
				_Pay = 0
		if GameLogic.cur_Challenge.has("白嫖+"):
			var _rand = randi() % 5
			if _rand == 0:
				GameLogic.call_Info(2, "白嫖+")
				_Pay = 0
		if GameLogic.cur_Challenge.has("补差价"):
			if PointType == 2:
				GameLogic.call_Info(2, "补差价")
				_PayMult -= 0.75
		if GameLogic.cur_Challenge.has("补差价+"):
			if PointType == 2:
				GameLogic.call_Info(2, "补差价+")
				_PayMult -= 0.5
		if not GameLogic.cur_SellFirst:
			if GameLogic.cur_Challenge.has("首单特卖"):
				GameLogic.call_Info(2, "首单特卖")
				_PayMult -= 0.5
			if GameLogic.cur_Challenge.has("首单特卖+"):
				GameLogic.call_Info(2, "首单特卖+")
				_PayMult -= 1
		if GameLogic.cur_Challenge.has("随机折扣"):
			var _rand = randi() % 10
			if _rand == 0:
				GameLogic.call_Info(2, "随机折扣")
				_PayMult -= 0.1
		if GameLogic.cur_Challenge.has("随机折扣+"):
			var _rand = randi() % 10
			if _rand == 0:
				GameLogic.call_Info(2, "随机折扣+")
				_PayMult -= 0.2
		if GameLogic.cur_Combo < 2:
			if GameLogic.cur_Challenge.has("推广促销"):
				GameLogic.call_Info(2, "推广促销")
				_PayMult -= 0.1
			if GameLogic.cur_Challenge.has("推广促销+"):
				GameLogic.call_Info(2, "推广促销+")
				_PayMult -= 0.2
		if GameLogic.P1_Pressure > 0 or GameLogic.P2_Pressure > 0:
			if GameLogic.cur_Challenge.has("有压无小费"):
				GameLogic.call_Info(2, "有压无小费")
				_TipMult -= 0.25
			if GameLogic.cur_Challenge.has("有压无小费+"):
				GameLogic.call_Info(2, "有压无小费+")
				_TipMult -= 0.5
		else:
			if GameLogic.cur_Challenge.has("无压折扣"):
				GameLogic.call_Info(2, "无压折扣")
				_PayMult -= 0.1
			if GameLogic.cur_Challenge.has("无压折扣+"):
				GameLogic.call_Info(2, "无压折扣+")
				_PayMult -= 0.2
		if PointType > 0:
			if GameLogic.cur_Challenge.has("制作不规范"):
				GameLogic.call_Info(2, "制作不规范")
				_PayMult -= 0.15
			if GameLogic.cur_Challenge.has("制作不规范+"):
				GameLogic.call_Info(2, "制作不规范+")
				_PayMult -= 0.3
			if GameLogic.cur_Challenge.has("制作不规范++"):
				GameLogic.call_Info(2, "制作不规范++")
				_PayMult -= 0.45
			if GameLogic.cur_Challenge.has("退单"):
				var _rand = randi() % 4
				if _rand == 0:
					GameLogic.call_Info(2, "退单")
					_Pay = 0
					_Tip = 0
			if GameLogic.cur_Challenge.has("退单+"):
				var _rand = randi() % 2
				if _rand == 0:
					GameLogic.call_Info(2, "退单+")
					_Pay = 0
					_Tip = 0
		if GameLogic.cur_Rewards.has("加班加单价"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				GameLogic.call_Info(1, "加班加单价")
				_PayMult += 1
		if GameLogic.cur_Rewards.has("加班加单价+"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				GameLogic.call_Info(1, "加班加单价+")
				_PayMult += 2
		if GameLogic.cur_Rewards.has("加班加小费"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				GameLogic.call_Info(1, "加班加小费")
				_Tip += 5
		if GameLogic.cur_Rewards.has("加班加小费+"):
			if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:
				GameLogic.call_Info(1, "加班加小费+")
				_Tip += 10

		if PointType == 0:
			var _CriChance: int = 5
			if GameLogic.cur_Event == "暴击日":
				_CriChance += 25
			if GameLogic.Achievement.cur_EquipList.has("声望提升"):
				_CriChance += 5
			if _CriRand <= _CriChance:
				var _CriMult: float = 0.5
				if GameLogic.cur_Rewards.has("不找零"):
					GameLogic.call_Info(1, "不找零")
					_CriMult = 0.75
				if GameLogic.cur_Rewards.has("不找零+"):
					GameLogic.call_Info(1, "不找零+")
					_CriMult = 1
				IsCri = true
				_Tip += int(float(_Pay) * _CriMult)
				GameLogic.Save.statisticsData["Count_Cri"] += 1
				if GameLogic.cur_Rewards.has("出手阔绰"):
					GameLogic.call_Info(1, "出手阔绰")
				if GameLogic.cur_Rewards.has("出手阔绰+"):
					GameLogic.call_Info(1, "出手阔绰+")
		if GameLogic.cur_Rewards.has("暴击减压") and IsCri:
			GameLogic.call_Info(1, "暴击减压")
			_Pressure -= 3

		if GameLogic.cur_Rewards.has("暴击减压+") and IsCri:
			GameLogic.call_Info(1, "暴击减压+")
			_Pressure -= 6

		if _Pay < 0:
			_Pay = 0
		if _Tip < 0:
			_Tip = 0
		if _PayMult < 0:
			_PayMult = 0
		if _TipMult < 0:
			_TipMult = 0
		_Pay = int(float(_Pay) * _PayMult)
		if GameLogic.Save.gameData.HomeDevList.has("来者不拒"):
			_Tip = int(float(_Tip) * _TipMult + 0.5)
		else:
			_Tip = int(float(_Tip) * _TipMult)
		if GameLogic.Achievement.cur_EquipList.has("饮品加价"):
			var _Plus = int(float(_Pay) * 0.1)
			if _Plus <= 0:
				_Plus = 1
			_Pay += _Plus
		GameLogic.Money_Sell += _Pay
		GameLogic.Money_Tip += _Tip
		GameLogic.Save.statisticsData["Count_Tip"] += _Tip
		GameLogic.level_MoneyTotal += _Pay + _Tip
		GameLogic.level_SellTotal += 1
		GameLogic.level_ProfitTotal += _Pay + _Tip


		var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
		_PickUpDev.PayNode.add_child(_PayEffect)
		_PayEffect.call_init(_BasePay, _Pay, _Tip, IsCri, IsQuick, IsSlow, IsJump)
		GameLogic.call_MoneyChange(_Pay + _Tip)

		GameLogic.call_Sell_add()
		GameLogic.Order.cur_OrderList.erase(PickUpID)

		GameLogic.Order.call_PickUp(PickUpID)
		GameLogic.cur_SellMenu = OrderName
		if not GameLogic.cur_SellFirst:
			GameLogic.cur_SellFirst = true
		if GameLogic.cur_Challenge.has("迅速承诺"):
			if WaitingTimer.time_left < WaitingTimer.wait_time * 0.25:
				GameLogic.call_Info(2, "迅速承诺")
				_Pressure += 1
		if GameLogic.cur_Challenge.has("迅速承诺+"):
			if WaitingTimer.time_left < WaitingTimer.wait_time * 0.5:
				GameLogic.call_Info(2, "迅速承诺+")
				_Pressure += 1
		if _Pressure != 0:
			GameLogic.call_Pressure_Set(_Pressure)
		if not GameLogic.Save.statisticsData["Dic_NPC_SellNum"].has(_selfTypeID):
			GameLogic.Save.statisticsData["Dic_NPC_SellNum"][_selfTypeID] = 1
		else:
			GameLogic.Save.statisticsData["Dic_NPC_SellNum"][_selfTypeID] += 1
func _putDown(_Pos):

	self.Avatar.WeaponNode.remove_child(HoldObj)
	HoldObj.position = _Pos
	ItemYSort.add_child(HoldObj)
	if HoldObj.has_method("call_Collision_Switch"):
		HoldObj.call_Collision_Switch(true)
	if HoldObj.has_method("call_new"):
		HoldObj.call_new()
	HoldObj = null
	Con.IsHold = false
func _thief_putDown():
	var _Pos = self.global_position
	self.Avatar.WeaponNode.remove_child(HoldObj)
	HoldObj.position = _Pos
	ItemYSort.add_child(HoldObj)
	if HoldObj.has_method("call_Collision_Switch"):
		HoldObj.call_Collision_Switch(true)
	HoldObj = null
	Con.IsHold = false

func _on_WaitingTimer_timeout() -> void :
	if not PickUpID:
		if GameLogic.Order.cur_LineUpArray.has(self):
			GameLogic.Order.cur_LineUpArray.erase(self)
			GameLogic.call_NoOrder_add()
			call_leaving()
	else:
		if GameLogic.cur_Day == 1:
			if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
				return
		if GameLogic.cur_Rewards.has("丢单重点"):
			if not ReOrder:
				if GameLogic.Astar.OrderV2:
					GameLogic.call_Info(1, "丢单重点")
					call_customer(GameLogic.Astar.OrderV2)
					ReOrder = true
		elif GameLogic.cur_Rewards.has("丢单重点+"):
			if GameLogic.Astar.OrderV2:
				GameLogic.call_Info(1, "丢单重点")
				call_customer(GameLogic.Astar.OrderV2)
				ReOrder = true
		else:

			if GameLogic.cur_Challenge.has("集体退单"):

				pass
			if GameLogic.cur_Challenge.has("集体退单+"):

				pass
			if GameLogic.cur_Challenge.has("投诉"):

				pass
			if GameLogic.cur_Challenge.has("投诉+"):

				pass
			GameLogic.call_NoSell_add()
			call_leaving()
func _on_LineWaitingTimer_timeout() -> void :
	if not PickUpID:

		if behavior == BEHAVIOR.LINE:
			if GameLogic.cur_Rewards.has("排队+"):
				return
		GameLogic.call_NoOrder_add()
		call_leaving()
	else:
		print("NPC有单情况，排队等待时间错误。")
func _on_OrderAngryTimer_timeout():
	if GameLogic.cur_Day == 1:
		if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
			return
	if not PickUpID:
		if IsSit:
			GameLogic.call_NoOrder_add()
			_on_LogicTimer_timeout()
			ThinkingAni.play("angry_leave")
		elif GameLogic.Order.cur_LineUpArray.has(self):

			if GameLogic.Order.cur_LineUpArray.has(self):
				GameLogic.Order.cur_LineUpArray.erase(self)
				GameLogic.call_NoOrder_add()
				call_leaving()
				ThinkingAni.play("angry_leave")
		else:
			print("顾客不在队伍当中。")
	else:
		print("NPC有单情况，点单等待时间错误。")

func _on_OrderTimer_timeout() -> void :
	if not PickUpID:
		ThinkingAni.play("angry")
		OrderAngryTimer.start(0)

func call_leaving_night():
	if not GameLogic.Order.cur_OrderArray.has(PickUpID):
		if not PickUpID and not GameLogic.Order.cur_LineUpArray.has(self):
			call_leaving()
		if is_in_group("Customers"):
			remove_from_group("Customers")

func call_del():
	if Con.IsHold:
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
	self.queue_free()

func _Add_Customer():
	if not _Is_Customer:
		_Is_Customer = true
		GameLogic.call_Customer_add()
func _on_LogicTimer_timeout():
	if IsSit:
		SeatOBJ.call_leaving(PosSave)
		IsSit = false

		call_leaving()
	pass
func call_leaving():
	StandTimer.stop()
	WaitingTimer.stop()
	LineWaitingTimer.stop()
	if IsSit:
		if LogicTimer.is_stopped():
			LogicTimer.start()
		return

	if GameLogic.Order.cur_LineUpArray.has(self):
		GameLogic.Order.cur_LineUpArray.erase(self)
	Stat._data_instance()
	var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
	_NPC_Create_Array.shuffle()


	call_passer(_NPC_Create_Array.front())
	if PickUpID:
		GameLogic.Order.call_Refund(PickUpID)

func call_Thief_leaving():

	if Con.IsHold:
		Stat.Ins_MAXSPEED = Stat.Ins_MAXSPEED * 0.5
	else:
		Stat._data_instance()
	var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
	_NPC_Create_Array.shuffle()
	_FinalTarget = _NPC_Create_Array.front()
	behavior = BEHAVIOR.PASSER
	_Path_IsFinish = false
	WaitingReset = false
	target = self.position
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _NPC_Create_Array.front())
func call_AcrossItem(_OBJ):
	if SpecialType == 1:
		return
	print("NPC 经过物品的惩罚逻辑。")
	if _OBJ.has_method("_ItemInBox_Create"):
		if _OBJ.CanPass:
			return
	if GameLogic.GameUI.Is_Open and not IsCourier:
		if is_instance_valid(_OBJ_Block):
			if _OBJ_Block != _OBJ:
				_OBJ_Block = _OBJ
				ThinkingAni.play("hide")
				ThinkingAni.play("BlockTheWay")
				GameLogic.call_pressure("BlockWay")
		else:
			_OBJ_Block = _OBJ
			ThinkingAni.play("hide")
			ThinkingAni.play("BlockTheWay")
			GameLogic.call_pressure("BlockWay")

func _Puppet_SYNC(_Pos: Vector2, _Target: Vector2):
	self.global_position = _Pos
	target = _Target
	pass
