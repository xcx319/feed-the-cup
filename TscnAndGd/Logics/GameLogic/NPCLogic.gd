extends Node

var NPC_traffic
var BrandRate
var CurRate
var CPP

var NPC_Array: Array

var LineUp_Array: Array

var NPCNUM: int = 0

var LevelNode
var NPCYSort
var Path2D_Node
var _DeliveryMap
var _NPCFloorMap
var Path2D_Array: Array

var _INOUT_Bool: bool
var _InPathNode
var _OutPathNode
var In_Array: Array
var Out_Array: Array

var Delivery_Path: Array
var Delivery_Node
var _Delivery_Array: Array
var _InStore_Customer_Array: Array
onready var NPC_TSCN = preload("res://TscnAndGd/Main/NPC/NPC_Rigid.tscn")
onready var NPC_Show_TSCN = preload("res://TscnAndGd/Main/NPC/NPC_Show.tscn")

onready var MarkCup = preload("res://TscnAndGd/Characters/MarkCup.tscn")
onready var PaperCup = preload("res://TscnAndGd/Characters/PaperCup.tscn")
onready var BigBottle = preload("res://TscnAndGd/Characters/BigBottle.tscn")
onready var BritishCup = preload("res://TscnAndGd/Characters/BritishCup.tscn")
onready var BilateralCup = preload("res://TscnAndGd/Characters/BilateralCup.tscn")
onready var LittleCup = preload("res://TscnAndGd/Characters/LittleCup.tscn")
onready var GlassBottle = preload("res://TscnAndGd/Characters/GlassBottle.tscn")
onready var TeaCup = preload("res://TscnAndGd/Characters/TeaCup.tscn")

onready var DeliverCar = preload("res://TscnAndGd/Characters/DeliverCar.tscn")

var GASBOX
var GASLIST: Array = []
var BEERLIST: Array = []
var ICEMACHINE
var CUPHOLDER
var WORKBENCH: Array = []
var SHELF: Array = []
var FRUITSHELF: Array = []
var FREEZER: Array = []
var FROZEN: Array = []

var ThugNum: int = - 1
var StudyHolics: int = - 1
enum STATE{
	IDLE_EMPTY
	MOVE
	IDLE_THINK
	IDLE_ORDER
	WORK
	STIR
	SHAKE
	ORDER
	SQUEEZE
	SHOW
	DISABLE
	DEAD
	IDLE_ACT
	DISABLE
	RUBBING
	DUMPING
	FALLDOWN
	EATTING
	IDLE_ANI_1
	IDLE_ANI_2
	IDLE_ANI_3
	IDLE_ANI_4
	SMASH
	URGE
	SHOVEL
	CUTE
	SITUP
	SITDOWN
	SITLEFT
	SITRIGHT
	SIT
}

func call_reset():
	GASBOX = null
	GASLIST = []
	BEERLIST = []
	ICEMACHINE = null
	CUPHOLDER = null
	WORKBENCH = []
	SHELF = []
	FREEZER = []
	FROZEN = []
	FRUITSHELF = []
	print(" call_reset")
func call_StudyHolics_rand():
	if StudyHolics <= 0:
		StudyHolics = GameLogic.return_randi() % 2 + 1
func call_Thug_rand():
	if ThugNum <= 0:
		ThugNum = GameLogic.return_randi() % 8

func return_NPC(_type):
	match _type:
		"MarkCup":
			return MarkCup
		"PaperCup":
			return PaperCup
		"BigBottle":
			return BigBottle
		"BritishCup":
			return BritishCup
		"BilateralCup":
			return BilateralCup
		"LittleCup":
			return LittleCup
		"GlassBottle":
			return GlassBottle
		"TeaCup":
			return TeaCup

func call_level_init():
	call_NPC_init()
	LevelNode = get_tree().get_root().get_node("Level")
	NPCYSort = LevelNode.get_node("YSort/NPCs")
	Path2D_Node = LevelNode.get_node("Pos2DNode")
	if LevelNode.has_node("InPos"):
		_INOUT_Bool = true
		_InPathNode = LevelNode.get_node("InPos")
		_OutPathNode = LevelNode.get_node("OutPos")
		_InOut_Array_init()
	else:
		_INOUT_Bool = false
		_InPathNode = null
		_OutPathNode = null
	if LevelNode.has_node("DeliverPos"):
		Delivery_Node = LevelNode.get_node("DeliverPos")
	_DeliveryMap = LevelNode.TMap_Delivery
	_NPCFloorMap = LevelNode.TMap_NPCFloor
	_Delivery_Array_init()
	_path2D_array_init()
	_Customer_Array_init()

func _InOut_Array_init():
	In_Array.clear()
	Out_Array.clear()
	var _In_Array = _InPathNode.get_children()
	var _Out_Array = _OutPathNode.get_children()
	for i in range(_In_Array.size()):
		In_Array.append(_In_Array[i].position)
	for i in range(_Out_Array.size()):
		Out_Array.append(_Out_Array[i].position)

func call_NPC_init():
	NPC_Array.clear()
	var _LEVELINFO = GameLogic.cur_levelInfo

	var _NPCList = _LEVELINFO.CustomersList
	var _NPCKeys = GameLogic.Config.NPCConfig.keys()
	for _NPCType in _NPCList:
		for _NPCName in _NPCKeys:
			if _NPCType == GameLogic.Config.NPCConfig[_NPCName].Avatar:
				NPC_Array.append(_NPCName)

func _Customer_Array_init():

	_InStore_Customer_Array.clear()
	var _UsedArray = _NPCFloorMap.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		_InStore_Customer_Array.append(_pointV2)

	if Delivery_Node:
		Delivery_Path.clear()
		var _Pos2D_Array = Delivery_Node.get_children()
		for i in range(_Pos2D_Array.size()):
			Delivery_Path.append(_Pos2D_Array[i].position)

func _Delivery_Array_init():

	_Delivery_Array.clear()
	var _UsedArray = _DeliveryMap.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		_Delivery_Array.append(_pointV2)

func _path2D_array_init():
	Path2D_Array.clear()
	var _Pos2D_Array = Path2D_Node.get_children()
	for i in range(_Pos2D_Array.size()):

		Path2D_Array.append(_Pos2D_Array[i].position)

func return_NPC_ID_TYPE(_Rank: int, _TYPE: String):
	var _PickArray: Array

	var _NPCARRAY = GameLogic.Config.NPCConfig.keys()
	for _NPCName in _NPCARRAY:
		var _NPCRank: int = int(GameLogic.Config.NPCConfig[_NPCName].Rank)
		var _NPCType: String = GameLogic.Config.NPCConfig[_NPCName].Avatar
		if _NPCRank <= _Rank and _TYPE == _NPCType:
			_PickArray.append(_NPCName)

	var _RatioArray: Array
	var _RatioMax: int = 0
	for _NPCName in _PickArray:
		var _Ratio = GameLogic.Config.NPCConfig[_NPCName].Ratio
		_RatioArray.append(_Ratio)
		_RatioMax += int(_Ratio)
	var _rand = GameLogic.return_randi() % _RatioMax
	var _RandCheck: int = 0
	for i in _RatioArray.size():
		_RandCheck += int(_RatioArray[i])
		if _rand < _RandCheck:

			return _PickArray[i]

func return_NPC_ID(_Rank: int):
	if not NPC_Array.size():
		call_NPC_init()
	if not NPC_Array.size():
		return
	var _PickArray: Array

	for _NPCName in NPC_Array:
		var _NPCRank: int = int(GameLogic.Config.NPCConfig[_NPCName].Rank)
		if _NPCRank <= _Rank:
			_PickArray.append(_NPCName)

	var _RatioArray: Array
	var _RatioMax: int = 0
	for _NPCName in _PickArray:
		var _Ratio = GameLogic.Config.NPCConfig[_NPCName].Ratio
		_RatioArray.append(_Ratio)
		_RatioMax += int(_Ratio)
	var _rand = GameLogic.return_randi() % _RatioMax
	var _RandCheck: int = 0
	for i in _RatioArray.size():
		_RandCheck += int(_RatioArray[i])
		if _rand < _RandCheck:

			return _PickArray[i]

func return_NPCNUM():
	return NPCYSort.get_child_count()
func call_passer(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return


	var _NPC_Create_Array: Array
	for _INFO in Path2D_Array:
		_NPC_Create_Array.append(_INFO)

	var _NewPasser = NPC_TSCN.instance()
	var _NAME = str(_NewPasser.get_instance_id())
	_NewPasser.name = _NAME

	var _RAND = GameLogic.return_RANDOM() % _NPC_Create_Array.size()
	var _POS = _NPC_Create_Array[_RAND]
	_NPC_Create_Array.remove(_RAND)
	_NewPasser.position = _POS

	NPCYSort.add_child(_NewPasser)
	var _rand = GameLogic.return_randi() % 30
	var _NPCID
	match _rand:
		0:
			_NPCID = "PaperCupbadguy"
		1:
			_NPCID = "BigBottleinspector"
		2:
			_NPCID = "BritishCupcritic"
		_:
			_NPCID = return_NPC_ID(5)
	_NewPasser.call_personality_init(_NPCID)

	var _RANDTARGET = GameLogic.return_RANDOM() % _NPC_Create_Array.size()
	var _TARGET = _NPC_Create_Array[_RANDTARGET]
	_NewPasser.call_passer(_TARGET)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, _NPCID, "passer", _TARGET])

func call_GlassBottle(_KEY: int = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewBottle = NPC_TSCN.instance()
	var _NAME = str(_NewBottle.get_instance_id())
	_NewBottle.name = _NAME
	_NewBottle.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewBottle.position = _POS
	NPCYSort.add_child(_NewBottle)
	var _NPCID = return_NPC_ID_TYPE(GameLogic.cur_NPC_Rank, "GlassBottle")
	_NewBottle.call_personality_init(_NPCID)

	if GameLogic.Astar.OrderV2:
		_NewBottle.call_GlassBottle(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, _NPCID, "GlassBottle", GameLogic.Astar.OrderV2])
func call_Critic(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewCritic = NPC_TSCN.instance()
	var _NAME = str(_NewCritic.get_instance_id())
	_NewCritic.name = _NAME
	_NewCritic.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewCritic.position = _POS
	NPCYSort.add_child(_NewCritic)

	_NewCritic.call_personality_init("BritishCupcritic")
	if GameLogic.Astar.OrderV2:
		_NewCritic.call_Critic(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "BritishCupcritic", "Critic", GameLogic.Astar.OrderV2])

func call_Thug(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewThug = NPC_TSCN.instance()
	var _NAME = str(_NewThug.get_instance_id())
	_NewThug.name = _NAME
	_NewThug.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewThug.position = _POS
	NPCYSort.add_child(_NewThug)

	_NewThug.call_personality_init("PaperCupbadguy")
	if GameLogic.Astar.OrderV2:
		_NewThug.call_Thug(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "PaperCupbadguy", "Thug", GameLogic.Astar.OrderV2])
func call_Uper(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME
	_NewSPECIAL.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)

	_NewSPECIAL.call_personality_init("LittleCupupper")
	if GameLogic.Astar.OrderV2:
		_NewSPECIAL.call_Uper(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "LittleCupupper", "Upper", GameLogic.Astar.OrderV2])
func call_Homeless(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME
	_NewSPECIAL.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)
	_NewSPECIAL.call_personality_init("GlassBottlehomeless")
	if GameLogic.Astar.OrderV2:
		_NewSPECIAL.call_Homeless(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "GlassBottlehomeless", "Homeless", GameLogic.Astar.OrderV2])
func call_Cupmother(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME
	_NewSPECIAL.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)

	_NewSPECIAL.call_personality_init("BilateralCupmother")
	if GameLogic.Astar.OrderV2:
		_NewSPECIAL.call_Cupmother(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "BilateralCupmother", "Cupmother", GameLogic.Astar.OrderV2])
func call_Supervisor(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME
	_NewSPECIAL.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)

	_NewSPECIAL.call_personality_init("LittleCupupper")
	if GameLogic.Astar.OrderV2:
		_NewSPECIAL.call_Supervisor(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "LittleCupupper", "Supervisor", GameLogic.Astar.OrderV2])
func call_Studyholics(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME
	_NewSPECIAL.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)

	_NewSPECIAL.call_personality_init("TeaCupstudent")
	if GameLogic.Astar.OrderV2:
		_NewSPECIAL.call_Studyholics(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "TeaCupstudent", "Studyholics", GameLogic.Astar.OrderV2])
func call_Taster(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME
	_NewSPECIAL.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)

	_NewSPECIAL.call_personality_init("LittleCupupper")
	if GameLogic.Astar.OrderV2:
		_NewSPECIAL.call_Taster(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "LittleCupupper", "Taster", GameLogic.Astar.OrderV2])

func call_Overseer(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME

	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)
	var _Avatar = GameLogic.TSCNLoad.return_character("Devil").instance()
	_Avatar.name = "Avatar"
	_NewSPECIAL.AvatarNode.add_child(_Avatar)
	_Avatar.call_deferred("call_Overseer")

	_NewSPECIAL.call_Overseer()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "BigBottleinspector", "Overseer", GameLogic.Astar.OrderV2])

func call_Checker(_KEY):
	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NewSPECIAL = NPC_TSCN.instance()
	var _NAME = str(_NewSPECIAL.get_instance_id())
	_NewSPECIAL.name = _NAME

	var _POS = return_NPC_CreateOrLeave_Point()
	_NewSPECIAL.position = _POS
	NPCYSort.add_child(_NewSPECIAL)
	var _NPCID = return_NPC_ID(GameLogic.cur_NPC_Rank)

	_NewSPECIAL.call_personality_init("BigBottleinspector")

	_NewSPECIAL.call_Checker()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "BigBottleinspector", "Checker", GameLogic.Astar.OrderV2])

func call_thief(_KEY):

	if _KEY != GameLogic.HomeMoneyKey:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _NewNPC = NPC_TSCN.instance()

	var _NAME: String = str(_NewNPC.get_instance_id())
	_NewNPC.name = _NAME
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewNPC.position = _POS
	NPCYSort.add_child(_NewNPC)
	_NewNPC.call_personality_init("MarkCupthief")
	_NewNPC.call_thief()
	var _TARGET = _NewNPC._FinalTarget
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, "MarkCupthief", "thief", _TARGET])

func call_passer_start(_pos):
	var _NewPasser = NPC_TSCN.instance()

	var _NAME: String = str(_NewPasser.get_instance_id())
	_NewPasser.name = _NAME
	_NewPasser.position = _pos
	NPCYSort.add_child(_NewPasser)
	var _NPCID = return_NPC_ID(5)
	_NewPasser.call_personality_init(_NPCID)

	var _TARGET = return_NPC_CreateOrLeave_Point()
	_NewPasser.call_passer(_TARGET)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _pos, _NPCID, "passer", _TARGET])
func call_Steam_NPC_Create(_name: String, _pos: Vector2, _AvatarID: String, _Type: String, _Target):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		var _NewNPC = NPC_TSCN.instance()
		_NewNPC.name = _name
		_NewNPC.position = _pos
		if not is_instance_valid(NPCYSort):
			LevelNode = get_tree().get_root().get_node("Level")
			NPCYSort = LevelNode.get_node("YSort/NPCs")
		if not is_instance_valid(NPCYSort):
			return
		NPCYSort.add_child(_NewNPC)
		if not _Type in ["passer", "thief"]:
			_NewNPC.NOPRESSURE = return_NoPressure_Customer()
		if _Type in ["Overseer"]:
			var _Avatar = GameLogic.TSCNLoad.return_character("Devil").instance()
			_Avatar.name = "Avatar"
			_NewNPC.AvatarNode.add_child(_Avatar)
			_Avatar.call_deferred("call_Overseer")

		else:
			_NewNPC.call_personality_init(_AvatarID)

		match _Type:
			"Homeless":
				_NewNPC.call_Homeless(_Target)
			"GlassBottle":
				_NewNPC.call_GlassBottle(_Target)
			"Upper":
				_NewNPC.call_Uper(_Target)
			"passer":
				_NewNPC.call_passer(_Target)
			"customer":

				_NewNPC.call_customer(_Target)
			"thief":
				_NewNPC.call_puppet_thief(_Target)
			"Thug":

				_NewNPC.call_Thug(_Target)
			"Critic":

				_NewNPC.call_Critic(_Target)
			"Checker":

				_NewNPC.call_Checker()
			"Overseer":
				_NewNPC.call_Overseer()
			"Taster":

				_NewNPC.call_Taster(_Target)
			"Studyholics":

				_NewNPC.call_Studyholics(_Target)
			"Supervisor":

				_NewNPC.call_Supervisor(_Target)
			"Cupmother":

				_NewNPC.call_Cupmother(_Target)


func call_leaving(_NPC):

	_NPC.call_passer(return_NPC_CreateOrLeave_Point())

func return_NoPressure_Customer():
	var _NoPressure: bool = false
	if GameLogic.cur_Event == "开店长队":
		if GameLogic.GameUI.CurTime >= GameLogic.cur_OpenTime - 0.1 and GameLogic.GameUI.CurTime <= GameLogic.cur_OpenTime + 1.5:
			_NoPressure = true
	if GameLogic.cur_Event == "关店长队":
		if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime - 1 and GameLogic.GameUI.CurTime <= GameLogic.cur_CloseTime:
			_NoPressure = true
	return _NoPressure

func call_customer(_KEY: int = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if Path2D_Array.size() == 0:
		return

	var _NewCustomer = NPC_TSCN.instance()
	var _NAME = str(_NewCustomer.get_instance_id())
	_NewCustomer.name = _NAME
	_NewCustomer.NOPRESSURE = return_NoPressure_Customer()
	var _POS = return_NPC_CreateOrLeave_Point()
	_NewCustomer.position = _POS
	NPCYSort.add_child(_NewCustomer)
	var _NPCID = return_NPC_ID(GameLogic.cur_NPC_Rank)
	_NewCustomer.call_personality_init(_NPCID)

	if GameLogic.Astar.OrderV2:
		_NewCustomer.call_customer(GameLogic.Astar.OrderV2)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Steam_NPC_Create", [_NAME, _POS, _NPCID, "customer", GameLogic.Astar.OrderV2])

func return_besidePoint(_basePoint):
	var _point_Array: Array
	for i in 8:
		var _Point
		match i:
			0:
				_Point = _basePoint - Vector2( - 100, - 100)
			1:
				_Point = _basePoint - Vector2( - 100, 0)
			2:
				_Point = _basePoint - Vector2( - 100, 100)
			3:
				_Point = _basePoint - Vector2(0, - 100)
			4:
				_Point = _basePoint - Vector2(0, 100)
			5:
				_Point = _basePoint - Vector2(100, - 100)
			6:
				_Point = _basePoint - Vector2(100, 0)
			7:
				_Point = _basePoint - Vector2(100, 100)
		_point_Array.append(_Point)
	_point_Array.shuffle()
	for i in _point_Array.size():

		if GameLogic.Astar._Point_NPC_Dir.has(_point_Array[i]):
			return _point_Array[i]

	return false
func return_inStorePoint():
	var _array = _InStore_Customer_Array
	if not _array.size():

		return
	_array.shuffle()
	return _array.front()

func return_deliverypoint():

	var _rand = GameLogic.return_randi() % _Delivery_Array.size()

	return _Delivery_Array[_rand]

func call_puppet_courier(_itemName, _createPoint, _deliveryPoint, _CourierName, _BoxID, _CurNum, _MaxNum, _CurItemNameDic):
	if _itemName in ["ICE", "GAS", "拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛", "BEER"]:
		var _NewGoblin = NPC_TSCN.instance()
		_NewGoblin.name = _CourierName
		_NewGoblin.position = _createPoint
		NPCYSort.add_child(_NewGoblin)
		var _Avatar = GameLogic.TSCNLoad.return_character("Goblin").instance()
		_Avatar.name = "Avatar"
		_NewGoblin.AvatarNode.add_child(_Avatar)

		_NewGoblin.call_Goblin_puppet(_deliveryPoint, _itemName, _BoxID, _CurNum, _MaxNum, _CurItemNameDic)
	else:
		var _NewCourier = NPC_TSCN.instance()
		_NewCourier.name = _CourierName
		_NewCourier.position = _createPoint
		NPCYSort.add_child(_NewCourier)
		_NewCourier.call_courier_init()
		_NewCourier.call_puppet_courier(_deliveryPoint, _itemName, _BoxID, _CurNum, _MaxNum, _CurItemNameDic)

func call_courier(_itemName, _createPoint):
	var _NewCourier = NPC_TSCN.instance()
	var _NAME: String = str(_NewCourier.get_instance_id())
	_NewCourier.name = _NAME
	_NewCourier.position = _createPoint
	NPCYSort.add_child(_NewCourier)
	_NewCourier.call_courier_init()
	var _deliveryPoint = return_deliverypoint()
	_NewCourier.call_courier(_deliveryPoint, _itemName)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _BoxID = _NewCourier.HoldObj._SELFID
		var _CurItemNameDic: Dictionary = _NewCourier.HoldObj._ItemNameDic
		var _CurNum = _CurItemNameDic.size()
		var _MaxNum = _NewCourier.HoldObj.BuyNum
		SteamLogic.call_puppet_node_sync(self, "call_puppet_courier", [_itemName, _createPoint, _deliveryPoint, _NAME, _BoxID, _CurNum, _MaxNum, _CurItemNameDic])

func call_goblin(_itemName, _createPoint):

	var _NewGoblin = NPC_TSCN.instance()
	var _NAME: String = str(_NewGoblin.get_instance_id())
	_NewGoblin.name = _NAME
	_NewGoblin.position = _createPoint
	NPCYSort.add_child(_NewGoblin)
	var _Avatar = GameLogic.TSCNLoad.return_character("Goblin").instance()
	_Avatar.name = "Avatar"
	_NewGoblin.AvatarNode.add_child(_Avatar)
	var _deliveryPoint
	if _itemName in ["拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛"]:
		_deliveryPoint = return_deliverypoint()
	else:
		_deliveryPoint = return_inStorePoint()
	_NewGoblin.call_Goblin(_deliveryPoint, _itemName)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _BoxID: int = 0
		if is_instance_valid(_NewGoblin.HoldObj):
			_BoxID = _NewGoblin.HoldObj._SELFID
		var _CurItemNameDic: Dictionary
		var _CurNum = _CurItemNameDic.size()
		var _MaxNum
		SteamLogic.call_puppet_node_sync(self, "call_puppet_courier", [_itemName, _createPoint, _deliveryPoint, _NAME, _BoxID, _CurNum, _MaxNum, _CurItemNameDic])
	pass
func call_(_createPoint):
	var _CLEANER = NPC_TSCN.instance()
	var _NAME: String = str(_CLEANER.get_instance_id())
	_CLEANER.name = _NAME
	_CLEANER.position = _createPoint
	NPCYSort.add_child(_CLEANER)
	var _Avatar = GameLogic.TSCNLoad.return_character("SlimeCleaner").instance()
	_Avatar.name = "Avatar"
	_CLEANER.AvatarNode.add_child(_Avatar)

	_CLEANER.call_Cleaner()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_cleaner", [_createPoint, _NAME])
func call_Cleaner(_createPoint):
	var _CLEANER = NPC_TSCN.instance()
	var _NAME: String = str(_CLEANER.get_instance_id())
	_CLEANER.name = _NAME
	_CLEANER.position = _createPoint
	NPCYSort.add_child(_CLEANER)
	var _Avatar = GameLogic.TSCNLoad.return_character("SlimeCleaner").instance()
	_Avatar.name = "Avatar"
	_CLEANER.AvatarNode.add_child(_Avatar)

	_CLEANER.call_Cleaner()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_cleaner", [_createPoint, _NAME])
func call_puppet_cleaner(_createPoint, _CourierName):
		var _CLEANER = NPC_TSCN.instance()
		_CLEANER.name = _CourierName
		_CLEANER.position = _createPoint
		NPCYSort.add_child(_CLEANER)
		var _Avatar = GameLogic.TSCNLoad.return_character("SlimeCleaner").instance()
		_Avatar.name = "Avatar"
		_CLEANER.AvatarNode.add_child(_Avatar)

		_CLEANER.call_Cleaner()

func return_NPC_CreateOrLeave_Point():

	if _INOUT_Bool and In_Array.size():
		var _RandInArray = GameLogic.return_randi() % In_Array.size()
		return In_Array[_RandInArray]
	var _Rand = GameLogic.return_randi() % Path2D_Array.size()
	return Path2D_Array[_Rand]
func return_Courier_CreateOrLeave_Point():
	var _Delivery_Create_Array = Delivery_Path
	_Delivery_Create_Array.shuffle()
	return _Delivery_Create_Array.front()
