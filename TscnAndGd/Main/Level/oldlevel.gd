extends Node2D

var LevelName: String
var OpenTime: int
var CloseTime: int
var _Type: int
var IndoorArea: int
var OutdoorArea: int
var Rent: int
var RentPayDay: int
var Cost: int

var ShopPopular
var BrandPopular

onready var Player
var Path2D_node_point_array = []
var AStar_begin_end_back_array = []
var begin_id
var end_id
var astar = AStar2D.new()
var walk = 0
var target = Vector2.ZERO
var speed = 50
var velocity = Vector2.ZERO

onready var TMap_Floor = get_node("MapNode/Floor")
onready var TMap_Street = get_node("MapNode/Street")
onready var TMap_StreetMain = get_node("MapNode/StreetMain")
onready var TMap_NPCFloor = get_node("MapNode/NPCFloor")
onready var TMap_Delivery = get_node("MapNode/Delivery")

onready var Ysort_Items = get_node("YSort/Items")
onready var Ysort_Dev = get_node("YSort/Devices")
onready var Ysort_Players = get_node("YSort/Players")

onready var P1_pos = get_node("PlayerPos2D/1").position
onready var P2_pos = get_node("PlayerPos2D/2").position
onready var Camera_Limit_Left = get_node("CameraPos2D/LeftTop").position.x
onready var Camera_Limit_Top = get_node("CameraPos2D/LeftTop").position.y
onready var Camera_Limit_Right = get_node("CameraPos2D/RightBottom").position.x
onready var Camera_Limit_Bottom = get_node("CameraPos2D/RightBottom").position.y
onready var CameraNode = get_node("Camera2D")
onready var DayLight = get_node("DayLight")

func _ready() -> void :

	if GameLogic.NewGame_Bool:
		_newGame()
		GameLogic.NewGame_Bool = false
	_LoadGame()


	_Level_init()
	GameLogic.GameUI.call_init()
	TMap_AStarLogic()


	call_deferred("Logic_Init")


func _PlayerCreate():
	GameLogic.AllStaff.clear()

	var _Player1P = GameLogic.TSCNLoad.return_player(1).instance()
	var _TSCNName = GameLogic.Config.PlayerConfig[str(GameLogic.player_1P_ID)].TSCN
	_Player1P.cur_ID = int(GameLogic.player_1P_ID)
	var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = "Avatar"
	_Player1P.position = P1_pos
	Ysort_Players.add_child(_Player1P)

	_Player1P.CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
	_Player1P.CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
	_Player1P.CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
	_Player1P.CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)

	GameLogic.AllStaff.append(_Player1P)
	_Player1P.add_child(_Avatar)
	_Player1P.call_init()

	if not GameLogic.Player2_bool:
		return
	var _Player2P = GameLogic.TSCNLoad.return_player(1).instance()
	_TSCNName = GameLogic.Config.PlayerConfig[str(GameLogic.player_2P_ID)].TSCN
	_Player2P.cur_ID = int(GameLogic.player_2P_ID)
	_Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = "Avatar"
	_Player2P.position = P2_pos
	Ysort_Players.add_child(_Player2P)
	GameLogic.AllStaff.append(_Player2P)
	_Player2P.add_child(_Avatar)
	_Player2P.call_init()

	GameLogic.player_1P = _Player1P
	GameLogic.player_2P = _Player2P
	GameLogic.Con.call_player1P_set()
	GameLogic.Con.call_player2P_set()


func _dev_save():

	GameLogic.Save.levelData["Devices"] = []
	var _DevList = Ysort_Dev.get_children()
	for i in _DevList.size():
		var _Dev = _DevList[i]
		var _Data = GameLogic.Save.return_savedata(_Dev)
		GameLogic.Save.levelData["Devices"].insert(GameLogic.Save.levelData["Devices"].size(), _Data)


func _item_save():
	GameLogic.Save.levelData["Items"] = []
	var _ItemList = Ysort_Items.get_children()
	for i in _ItemList.size():
		var _ItemOBJ = _ItemList[i]
		var _ItemName = _ItemOBJ.TypeStr
		var _Data = GameLogic.Save.return_savedata(_ItemOBJ)
		GameLogic.Save.levelData["Items"].insert(GameLogic.Save.levelData["Items"].size(), _Data)





func _level_save():
	_dev_save()
	_item_save()
	GameLogic.Save.call_save()

func _newGame():
	GameLogic.Save.levelData["Devices"] = []
	GameLogic.Save.levelData["Items"] = []


	_dev_save()
	_item_save()



	var _Delivery_Array: Array
	var _UsedArray = TMap_Delivery.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
		_Delivery_Array.append(_pointV2)
	_Delivery_Array.shuffle()


	var _BoxObj = GameLogic.Buy.return_create_box()
	for i in GameLogic.Buy.Sell_1.size():
		var _itemName = GameLogic.Buy.Sell_1[i]
		var _Num = GameLogic.Config.ItemConfig[_itemName]["BuyNum"]
		var _ItemData: Dictionary = {
			"TSCN": "Box_M_Paper",
			"IsOpen": false,
			"pos": _Delivery_Array.pop_front(),
			"HasItem": true,
			"ItemName": _itemName,
			"ItemNum": _Num,
			}
		GameLogic.Save.levelData["Items"].insert(GameLogic.Save.levelData["Items"].size(), _ItemData)

	for i in GameLogic.Buy.Sell_2.size():
		var _itemName = GameLogic.Buy.Sell_2[i]
		var _Num = GameLogic.Config.ItemConfig[_itemName]["BuyNum"]
		var _ItemData: Dictionary = {
			"TSCN": "Box_M_Paper",
			"IsOpen": false,
			"pos": _Delivery_Array.pop_front(),
			"HasItem": true,
			"ItemName": _itemName,
			"ItemNum": _Num,
			}
		GameLogic.Save.levelData["Items"].insert(GameLogic.Save.levelData["Items"].size(), _ItemData)

	GameLogic.Save.call_save()
func _del_Dev():
	var _DevList = Ysort_Dev.get_children()

	for i in _DevList.size():
		var _Dev = _DevList[i]
		_Dev.queue_free()
func _del_Item():
	var _DevList = Ysort_Items.get_children()

	for i in _DevList.size():
		var _Dev = _DevList[i]
		_Dev.queue_free()
func _LoadGame():
	_del_Dev()
	_del_Item()
	if GameLogic.Save.levelData.has("Devices"):
		for i in GameLogic.Save.levelData["Devices"].size():
			var _DevInfo = GameLogic.Save.levelData["Devices"][i]
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_DevInfo.TSCN)
			var _Dev = _TSCN.instance()
			_Dev.position = _DevInfo.pos
			Ysort_Dev.add_child(_Dev)
			_Dev.call_load(_DevInfo)
	if GameLogic.Save.levelData.has("Items"):
		for i in GameLogic.Save.levelData["Items"].size():
			var _ItemInfo = GameLogic.Save.levelData["Items"][i]
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemInfo.TSCN)
			var _Item = _TSCN.instance()
			_Item.position = _ItemInfo.pos
			Ysort_Items.add_child(_Item)
			_Item.call_load(_ItemInfo)

func Logic_Init():
	GameLogic.NPC.call_level_init()
	GameLogic.Staff.call_level_init()
	GameLogic.Buy.call_level_init()
	_npc_passer()
	DayLight.show()
	_PlayerCreate()

func _npc_passer():
	var _pos_array: Array
	var _UsedArray = TMap_StreetMain.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
		_pos_array.append(_pointV2)
	_pos_array.shuffle()

	for _i in int(GameLogic.GameUI.PV_Max):
		GameLogic.NPC.call_passer_start(_pos_array.pop_back())
	pass
func TMap_AStarLogic():
	GameLogic.Astar.call_Path2D_init()
	GameLogic.Astar.call_TMap_init(TMap_Floor)
	GameLogic.Astar.call_TMap_init_NPC(TMap_NPCFloor)
	GameLogic.Astar.call_TMap_Street_init(TMap_StreetMain, TMap_Street)
	GameLogic.Astar.connect_init()

func _Level_init():

	LevelName = self.name
	self.name = "Level"

	OpenTime = int(GameLogic.Config.SceneConfig[LevelName].OpenTime)
	CloseTime = int(GameLogic.Config.SceneConfig[LevelName].CloseTime)
	_Type = int(GameLogic.Config.SceneConfig[LevelName].Type)
	IndoorArea = int(GameLogic.Config.SceneConfig[LevelName].IndoorArea)
	OutdoorArea = int(GameLogic.Config.SceneConfig[LevelName].OutdoorArea)
	Rent = int(GameLogic.Config.SceneConfig[LevelName].Rent)
	RentPayDay = int(GameLogic.Config.SceneConfig[LevelName].RentPayDay)
	Cost = int(GameLogic.Config.SceneConfig[LevelName].Cost)
	ShopPopular = int(GameLogic.Config.SceneConfig[LevelName].PV)
