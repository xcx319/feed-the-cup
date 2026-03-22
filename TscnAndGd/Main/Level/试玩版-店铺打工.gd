extends Node2D

onready var Player = get_node("YSort/Players/Player2P")
var Path2D_node_point_array = []
var AStar_begin_end_back_array = []
var begin_id
var end_id
var astar = AStar2D.new()
var walk = 0
var target = Vector2.ZERO
var speed = 50
var velocity = Vector2.ZERO
onready var Path2D_node = $Path2D

onready var TMap_Floor = get_node("MapNode/Floor")
onready var TMap_Street = get_node("MapNode/Street")
onready var TMap_StreetMain = get_node("MapNode/StreetMain")
onready var TMap_NPCFloor = get_node("MapNode/NPCFloor")
onready var TMap_Delivery = get_node("MapNode/Delivery")

onready var Ysort_Dev = get_node("YSort/Devices")
onready var NPCLogic = get_node("Logic/NPCLogic")
func _ready() -> void :

	_dev_init()
	_item_init()

	TMap_AStarLogic()




func TMap_AStarLogic():
	AStarLogic.call_Path2D_init()
	AStarLogic.call_TMap_init(TMap_Floor)
	AStarLogic.call_TMap_init_NPC(TMap_NPCFloor)
	AStarLogic.call_TMap_Street_init(TMap_StreetMain, TMap_Street)
	AStarLogic.connect_init()

func _dev_init():

	var _Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	var LeftObj = _Dev.get_node("LeftObj")

	var RightObj = _Dev.get_node("RightObj")

	_Dev.position = Vector2(1500, 550)
	Ysort_Dev.add_child(_Dev)
	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")

	RightObj = _Dev.get_node("RightObj")

	_Dev.position = Vector2(1300, 550)
	Ysort_Dev.add_child(_Dev)

	var _Dev2 = AutoLoad.CupHolder_TSCN.instance()

	LeftObj = _Dev.get_node("LeftObj")
	LeftObj.get_node("ObjNode").add_child(_Dev2)
	LeftObj.OnTableObj = _Dev2

	_Dev2 = AutoLoad.OrderTab_TSCN.instance()

	RightObj = _Dev.get_node("RightObj")
	RightObj.get_node("ObjNode").add_child(_Dev2)
	RightObj.OnTableObj = _Dev2
	_Dev2.call_OrderPoint()

	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	RightObj = _Dev.get_node("RightObj")
	_Dev.position = Vector2(1100, 550)
	Ysort_Dev.add_child(_Dev)
	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	RightObj = _Dev.get_node("RightObj")
	_Dev.position = Vector2(900, 550)
	Ysort_Dev.add_child(_Dev)

	_Dev2 = AutoLoad.PickUp_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	LeftObj.get_node("ObjNode").add_child(_Dev2)
	LeftObj.OnTableObj = _Dev2

	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	RightObj = _Dev.get_node("RightObj")
	_Dev.position = Vector2(1500, 300)
	Ysort_Dev.add_child(_Dev)
	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	RightObj = _Dev.get_node("RightObj")
	_Dev.position = Vector2(1500, 50)
	Ysort_Dev.add_child(_Dev)

	_Dev2 = AutoLoad.WaterTank_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	LeftObj.get_node("ObjNode").add_child(_Dev2)
	LeftObj.OnTableObj = _Dev2

	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")
	RightObj = _Dev.get_node("RightObj")

	_Dev.position = Vector2(1300, 50)
	Ysort_Dev.add_child(_Dev)

	_Dev2 = AutoLoad.InductionCooker_TSCN.instance()

	LeftObj = _Dev.get_node("LeftObj")
	LeftObj.get_node("ObjNode").add_child(_Dev2)
	LeftObj.OnTableObj = _Dev2

	_Dev2 = AutoLoad.WorkBoard_TSCN.instance()

	RightObj = _Dev.get_node("RightObj")
	RightObj.get_node("ObjNode").add_child(_Dev2)
	RightObj.OnTableObj = _Dev2

	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")

	RightObj = _Dev.get_node("RightObj")

	_Dev.position = Vector2(1100, 50)
	Ysort_Dev.add_child(_Dev)

	_Dev2 = AutoLoad.WaterPort_TSCN.instance()

	LeftObj = _Dev.get_node("LeftObj")
	LeftObj.get_node("ObjNode").add_child(_Dev2)
	LeftObj.OnTableObj = _Dev2

	_Dev2 = AutoLoad.SugarMachine_TSCN.instance()

	RightObj = _Dev.get_node("RightObj")
	RightObj.get_node("ObjNode").add_child(_Dev2)
	RightObj.OnTableObj = _Dev2

	_Dev = AutoLoad.WorkBench_M_Wood_TSCN.instance()
	LeftObj = _Dev.get_node("LeftObj")

	RightObj = _Dev.get_node("RightObj")

	_Dev.position = Vector2(900, 50)
	Ysort_Dev.add_child(_Dev)

	_Dev2 = AutoLoad.TeaPort_M_Plastic_TSCN.instance()

	LeftObj = _Dev.get_node("LeftObj")
	LeftObj.get_node("ObjNode").add_child(_Dev2)
	LeftObj.OnTableObj = _Dev2
	_Dev2 = AutoLoad.TeaPort_M_Plastic_TSCN.instance()

	RightObj = _Dev.get_node("RightObj")
	RightObj.get_node("ObjNode").add_child(_Dev2)
	RightObj.OnTableObj = _Dev2

	_Dev = AutoLoad.Shelf_M_Steel_TSCN.instance()

	_Dev.position = Vector2(350, 50)
	Ysort_Dev.add_child(_Dev)


	_Dev = AutoLoad.Shelf_M_Steel_TSCN.instance()

	_Dev.position = Vector2(250, 50)
	Ysort_Dev.add_child(_Dev)

	_Dev = AutoLoad.WorkBench_S_Wood_TSCN.instance()

	_Dev.position = Vector2(750, 550)
	Ysort_Dev.add_child(_Dev)

	_Dev = AutoLoad.Trashbin_L_Plastic_TSCN.instance()

	_Dev.position = Vector2(650, 550)
	Ysort_Dev.add_child(_Dev)

func _item_init():


	pass

func _process(delta: float) -> void :

	pass
