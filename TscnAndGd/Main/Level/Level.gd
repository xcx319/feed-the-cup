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
var CustomerList: Array
var CustomerRank: int
var Traffic_Array: Array
var ShopPopular
var BrandPopular
var _NPCArray: Array
var _NPCRatio: Array

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
onready var Ysort_Update = get_node("YSort/Updates")
onready var Ysort_Players = get_node("YSort/Players")

onready var P1_pos = get_node("PlayerPos2D/1").position
onready var P2_pos = get_node("PlayerPos2D/2").position
onready var Camera_Limit_Left = get_node("CameraPos2D/LeftTop").position.x
onready var Camera_Limit_Top = get_node("CameraPos2D/LeftTop").position.y
onready var Camera_Limit_Right = get_node("CameraPos2D/RightBottom").position.x
onready var Camera_Limit_Bottom = get_node("CameraPos2D/RightBottom").position.y
onready var CameraNode = get_node("Camera2D")

onready var DayLight = get_node("DayLight")
onready var LightNode = get_node("LightNode")
onready var LevelData = get_node("LevelData")
onready var NPCNode = LevelData.get_node("NPCs")
onready var MenuNode = LevelData.get_node("Menu")
onready var CHALLENGETSCN = preload("res://TscnAndGd/UI/InGame/ChallengeUI.tscn")
var MenuList: Array

func call_update_get():
	GameLogic.cur_Level_Update.clear()
	var _UpdateList = Ysort_Update.get_children()
	for i in _UpdateList.size():
		GameLogic.cur_Level_Update.append(_UpdateList[i])
func _name_set():
	for i in GameLogic.cur_Level_Update.size():
		var _Obj = GameLogic.cur_Level_Update[i]
		var _Name = _Obj.editor_description
		if not GameLogic.cur_Update_Name.has(_Name):
			GameLogic.cur_Update_Name.append(_Name)

func _CloseLight():
	LightNode.visible = false

func _ready() -> void :
	set_process(false)


	GameLogic.cur_LevelDifficult.clear()
	if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		var _Difficult = GameLogic.Config.SceneConfig[GameLogic.cur_level].Difficult
		for _DifName in _Difficult:
			GameLogic.cur_LevelDifficult.append(str(_DifName))


	MenuList = MenuNode.get_children()





	if not GameLogic.cur_Menu.size():
		if GameLogic.Save.levelData.has("cur_Menu"):
			if GameLogic.Save.levelData.cur_Menu.size() > 0:
				for _Menu in GameLogic.Save.levelData.cur_Menu:
					GameLogic.cur_Menu.append(_Menu)
			else:

				if GameLogic.cur_level:
					if GameLogic.new_bool:
						var _NewMenu: Array = GameLogic.Config.SceneConfig[GameLogic.cur_level].Menu

						if _NewMenu.size():
							GameLogic.cur_Menu = _NewMenu
						else:
							var _NewMenuNum: int = int(GameLogic.Config.SceneConfig[GameLogic.cur_level].MenuStart)
							GameLogic.Order.call_NewMenu(_NewMenuNum)
					else:
						var _NewMenuNum: int = int(GameLogic.Config.SceneConfig[GameLogic.cur_level].MenuStart)

						GameLogic.Order.call_NewMenu(_NewMenuNum)
		else:
			if GameLogic.cur_level:
				var _NewMenuNum: int = int(GameLogic.Config.SceneConfig[GameLogic.cur_level].MenuStart)
				GameLogic.Order.call_NewMenu(_NewMenuNum)

	var _TeaPortNode = LevelData.get_node("Buy/TeaPort")
	var _TeaPortNodeList = _TeaPortNode.get_children()
	var _TeaInfoList: Dictionary
	for i in _TeaPortNodeList.size():
		var _id = i + 1
		var _info = {
			"Start": _TeaPortNode.get_node(str(_id)).Start,
			"Money": _TeaPortNode.get_node(str(_id)).Money,
			"Day": _TeaPortNode.get_node(str(_id)).SellDay,
			"Popular": _TeaPortNode.get_node(str(_id)).SellPopular,
			"Menu": _TeaPortNode.get_node(str(i + 1)).SellMenu
		}
		_TeaInfoList[_id] = _info

	GameLogic.cur_Dev_Info["TeaPort"] = _TeaInfoList


	var _WaterPortNode = LevelData.get_node("Buy/WaterPort")
	var _WaterPortNodeList = _WaterPortNode.get_children()
	var _WaterInfoList: Dictionary
	for i in _WaterPortNodeList.size():
		var _id = i + 1
		var _info = {
			"Start": _WaterPortNode.get_node(str(_id)).Start,
			"Money": _WaterPortNode.get_node(str(_id)).Money,
			"Day": _WaterPortNode.get_node(str(_id)).SellDay,
			"Popular": _WaterPortNode.get_node(str(_id)).SellPopular,
			"Menu": _WaterPortNode.get_node(str(i + 1)).SellMenu
		}
		_WaterInfoList[_id] = _info
	GameLogic.cur_Dev_Info["WaterPort"] = _WaterInfoList


	GameLogic.Buy.call_init()
	if GameLogic.ShowLevel_bool:
		call_update_get()
		_name_set()
		DayLight.visible = false
		call_camera_init()
		_CloseLight()
		if has_node("CameraShow"):
			get_node("CameraShow").current = true




		if GameLogic.ComputerLevel_bool:
			if not GameLogic.Save.levelData.has("Devices"):
				_newGame()
			elif GameLogic.Save.levelData["Devices"] == []:
				_newGame()
			_LoadGame()
		return

	if GameLogic.new_bool:
		_newGame()

	var _check = GameLogic.connect("CloseLight", self, "_CloseLight")
	_LoadGame()
	_Auto_Buy()

	_Level_init()
	if not GameLogic.ComputerLevel_bool:
		GameLogic.GameUI.call_init()
		TMap_AStarLogic()

		call_deferred("Logic_Init")

	if GameLogic.LoadingUI.Tutorial:
		GameLogic.Save.call_levelData_load()
		GameLogic.LoadingUI.Tutorial = false


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
	GameLogic.player_1P = _Player1P
	GameLogic.Con.call_player1P_set()

	if GameLogic.Player2_bool:
		var _Player2P = GameLogic.TSCNLoad.return_player(2).instance()
		_TSCNName = GameLogic.Config.PlayerConfig[str(GameLogic.player_2P_ID)].TSCN
		_Player2P.cur_ID = int(GameLogic.player_2P_ID)
		_Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
		_Avatar.name = "Avatar"
		_Player2P.position = P2_pos
		Ysort_Players.add_child(_Player2P)
		GameLogic.AllStaff.append(_Player2P)
		_Player2P.add_child(_Avatar)
		_Player2P.call_init()
		GameLogic.player_2P = _Player2P
		GameLogic.Con.call_player2P_set()
		call_camera_init()
		var _Pos = ((GameLogic.player_2P.position + Vector2(0, - 60)) + (GameLogic.player_1P.position + Vector2(0, - 60))) / 2
		CameraNode.position = _Pos.round()
		CameraNode.current = true
	else:
		GameLogic.player_2P = null




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

func call_level_save():

	_dev_save()
	_item_save()
	GameLogic.Save.call_save()

func _Auto_Buy():



	var _Delivery_Array: Array
	var _UsedArray = TMap_Delivery.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
		_Delivery_Array.append(_pointV2)
	_Delivery_Array.shuffle()



	var _CostTotal: int = 0
	var _DelNum: int = 0
	for i in GameLogic.Buy.Sell_1.size():
		var _itemName = GameLogic.Buy.Sell_1[i]

		if GameLogic.Config.ItemConfig.has(_itemName):
			if not GameLogic.cur_Item_List.has(_itemName):

				_CostTotal += return_Box_Create(_itemName, _Delivery_Array[_DelNum])
				if _DelNum > _Delivery_Array.size():
					_DelNum = 0
				else:
					_DelNum += 1
	for i in GameLogic.Buy.Sell_2.size():
		var _itemName = GameLogic.Buy.Sell_2[i]
		if GameLogic.Config.ItemConfig.has(_itemName):

			var _NameInList = _itemName
			match _itemName:
				"DrinkCup_S":
					_NameInList = "DrinkCup_Group_S"
				"DrinkCup_M":
					_NameInList = "DrinkCup_Group_M"
				"DrinkCup_L":
					_NameInList = "DrinkCup_Group_L"
			if not GameLogic.cur_Item_List.has(_NameInList):

				_CostTotal += return_Box_Create(_itemName, _Delivery_Array[_DelNum])
				if _DelNum > _Delivery_Array.size():
					_DelNum = 0
				else:
					_DelNum += 1
	for i in GameLogic.Buy.Sell_3.size():
		var _itemName = GameLogic.Buy.Sell_3[i]
		if GameLogic.Config.ItemConfig.has(_itemName):
			if not GameLogic.cur_Item_List.has(_itemName):

				_CostTotal += return_Box_Create(_itemName, _Delivery_Array[_DelNum])
				if _DelNum > _Delivery_Array.size():
					_DelNum = 0
				else:
					_DelNum += 1




	if _CostTotal:
		GameLogic.level_ProfitTotal += _CostTotal * - 1

		GameLogic.Cost_Items += _CostTotal
func return_Box_Create(_ItemName, _pos):
	var _Num = GameLogic.Config.ItemConfig[_ItemName]["BuyNum"]
	var _ItemData: Dictionary = {
		"TSCN": "Box_M_Paper",
		"IsOpen": false,
		"pos": _pos,
		"HasItem": true,
		"ItemName": _ItemName,
		"ItemNum": _Num,
		}
	var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemData.TSCN)
	var _Item = _TSCN.instance()
	_Item.position = _ItemData.pos
	Ysort_Items.add_child(_Item)
	_Item.call_load(_ItemData)

	var _Cost = int(_Num) * int(GameLogic.Config.ItemConfig[_ItemName].Sell)

	var _Mult: float = 1
	if GameLogic.cur_Rewards.has("物料供应"):
		_Mult -= 0.25
	if GameLogic.cur_Rewards.has("物料供应+"):
		_Mult -= 0.5
	if GameLogic.cur_Challenge.has("坐地起价"):
		_Mult += 0.25
	if GameLogic.cur_Challenge.has("坐地起价+"):
		_Mult += 0.5
	_Cost = int(float(_Cost) * _Mult)


	return _Cost
func _newGame():
	GameLogic.Save.levelData["Devices"] = []
	GameLogic.Save.levelData["Items"] = []

	GameLogic.new_bool = false

	_dev_save()
	_item_save()

	GameLogic.call_save()
func _del_Dev():
	var _DevList = Ysort_Dev.get_children()
	for i in _DevList.size():
		var _Dev = _DevList[i]
		_Dev.queue_free()

	var _UpdateList = Ysort_Update.get_children()
	for i in _UpdateList.size():
		var _UpdateObj = _UpdateList[i]
		if GameLogic.ComputerLevel_bool:
			_UpdateObj.hide()
		else:
			_UpdateObj.queue_free()
func _del_Item():
	var _DevList = Ysort_Items.get_children()
	for i in _DevList.size():
		var _Dev = _DevList[i]
		_Dev.queue_free()
func _LoadGame():

	_del_Dev()
	_del_Item()
	GameLogic.cur_Item_List.clear()

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

	GameLogic.OrderStaff.clear()
func call_NPC_Set():
	_NPCArray.clear()
	_NPCRatio.clear()
	var _NodeArray = NPCNode.get_children()
	for i in _NodeArray.size():
		var _Node = _NodeArray[i]
		var _Name = _Node.Name
		var _Ratio = _Node.Ratio
		_NPCArray.append(_Name)
		_NPCRatio.append(_Ratio)

func Logic_Init():
	_Extra_init()
	call_NPC_Set()
	GameLogic.NPC.call_level_init(_NPCArray, _NPCRatio)
	GameLogic.Staff.call_level_init()

	_npc_passer()
	DayLight.show()
	_PlayerCreate()
	set_process(true)
	GameLogic.Audio.call_TileSet(get_node("MapNode/Audio"))

func _Extra_init():

	GameLogic.cur_Extra.clear()
	for _MenuName in GameLogic.cur_Menu:
		if GameLogic.Config.FormulaConfig.has(_MenuName):
			var _MenuType = GameLogic.Config.FormulaConfig[_MenuName].Type

			if "CAN" in _MenuType:
				GameLogic.cur_Extra.append(_MenuName)

func _npc_passer():
	var _pos_array: Array
	var _UsedArray = TMap_StreetMain.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
		_pos_array.append(_pointV2)
	_pos_array.shuffle()

	var _Num: int = int(float(GameLogic.GameUI.cur_Traffic) / 12)

	for _i in _Num:
		GameLogic.NPC.call_passer_start(_pos_array.pop_back())
	pass
func TMap_AStarLogic():
	GameLogic.Astar.call_Path2D_init()
	GameLogic.Astar.call_TMap_init(TMap_Floor)
	GameLogic.Astar.call_TMap_init_NPC(TMap_NPCFloor)
	GameLogic.Astar.call_TMap_Street_init(TMap_StreetMain, TMap_Street)
	GameLogic.Astar.connect_init()

func _Level_init():

	LevelName = GameLogic.cur_level
	self.name = "Level"

	GameLogic.call_StoreStar_Logic()

func call_camera_init():

	CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
	CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
	CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
	CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)



	CameraNode.smoothing_enabled = true

	pass
func _process(_delta: float) -> void :

	if GameLogic.Player2_bool:
		if is_instance_valid(GameLogic.player_1P) and is_instance_valid(GameLogic.player_2P):
			var _Pos = ((GameLogic.player_2P.position + Vector2(0, - 60)) + (GameLogic.player_1P.position + Vector2(0, - 60))) / 2
			CameraNode.position = _Pos.round()


			var _space_x: float = abs(GameLogic.player_1P.position.x - GameLogic.player_2P.position.x)
			var _space_y: float = abs(GameLogic.player_1P.position.y - GameLogic.player_2P.position.y)
			if _space_x > 1600 or _space_y > 900:
				var _zoom_x: float = 0.0
				var _zoom_y: float = 0.0
				var _zoom: float = 0.0

				_zoom_x = _space_x / 1600
				_zoom_y = _space_y / 900
				if _zoom_x > _zoom_y:
					_zoom = _zoom_x
				else:
					_zoom = _zoom_y

				CameraNode.zoom = Vector2(_zoom, _zoom)
				if CameraNode.zoom > Vector2(2, 2):
					CameraNode.zoom = Vector2(2, 2)
			else:
				CameraNode.zoom = Vector2(1, 1)

	else:

		var _check = is_instance_valid(GameLogic.player_1P)
		if not _check:
			return
		GameLogic.player_1P.CameraNode.zoom = CameraNode.zoom
		CameraNode.zoom = Vector2.ONE

		GameLogic.player_1P.CameraNode.current = true
		GameLogic.player_1P.CameraNode.reset_smoothing()
		GameLogic.player_1P.set_process(true)
		set_process(false)
