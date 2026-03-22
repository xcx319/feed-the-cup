extends Node

var Staff_Max: int
var Staff_Order = null
var Need_Order: bool
var OrderTab_OBJ
var StaffLocker_OBJ
var OrderTab_StaffPos: Vector2
var OrderTab_direction: Vector2
var StaffLocker_StaffPos: Vector2
var StaffLocker_direction: Vector2
var InStore_Staff_Array: Array

onready var LevelNode = null

var EXPMAX: int = 18000
var TITLEARRAY: Array = [1000, 5000, 18000]
func call_StaffLocker_init(_OBJ):
	StaffLocker_OBJ = _OBJ
	if StaffLocker_OBJ.is_inside_tree():
		var _pos = StaffLocker_OBJ.global_position

		StaffLocker_StaffPos = GameLogic.Astar.return_closest_Staff_pos(_pos)
		var _x = abs(StaffLocker_StaffPos.x) - abs(_pos.x)
		var _y = abs(StaffLocker_StaffPos.y) - abs(_pos.y)
		if _x == 0:
			if _y < 0:
				StaffLocker_direction = Vector2(0, 1)
			else:
				StaffLocker_direction = Vector2(0, - 1)
		elif _x < 0:
			StaffLocker_direction = Vector2(1, 0)
		else:
			StaffLocker_direction = Vector2( - 1, 0)

func call_OrderTab_init(_OBJ):

	Staff_Order = null
	Need_Order = false
	OrderTab_OBJ = _OBJ
	if OrderTab_OBJ.is_inside_tree():
		var _pos = OrderTab_OBJ.global_position + Vector2(0, 70)
		OrderTab_StaffPos = GameLogic.Astar.return_closest_Staff_pos(_pos)
		var _x = abs(OrderTab_StaffPos.x) - abs(_pos.x)
		var _y = abs(OrderTab_StaffPos.y) - abs(_pos.y)
		if _x == 0:
			if _y < 0:
				OrderTab_direction = Vector2(0, 1)
			else:
				OrderTab_direction = Vector2(0, - 1)
		elif _x < 0:
			OrderTab_direction = Vector2(1, 0)
		else:
			OrderTab_direction = Vector2( - 1, 0)

func call_level_init():
	LevelNode = get_tree().get_root().get_node("Level")

	_Staff_Array_init()

func _Staff_Array_init():

	InStore_Staff_Array.clear()
	var _UsedArray = LevelNode.TMap_Floor.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		InStore_Staff_Array.append(_pointV2)

func return_StaffStorePoint():
	var _array = InStore_Staff_Array
	if _array.size():
		var _rand = randi() % _array.size()
		return _array[_rand]
	else:
		return null

func _Customer_Array_init():

	InStore_Staff_Array.clear()
	var _UsedArray = LevelNode.TMap_Floor.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		InStore_Staff_Array.append(_pointV2)

func call_new_staff(_Num: int):
	for _StaffID in _Num:
		var _StaffNode = GameLogic.TSCNLoad.Staff_TSCN.instance()
		var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
		var _rand = randi() % _NPC_Create_Array.size()
		_StaffNode.position = _NPC_Create_Array[_rand]
		LevelNode.Ysort_Players.add_child(_StaffNode)
		_StaffNode.HomePoint = _NPC_Create_Array[_rand]
		_StaffNode.call_load(GameLogic.cur_Staff[_StaffID])
func call_interview(_Num: int, _Type: String, _Rank: int):
	if not LevelNode.is_inside_tree():
		printerr("召唤面试者失败，LevelNode错误")
		return
	for _StaffID in _Num:
		var _StaffNode = GameLogic.TSCNLoad.Staff_TSCN.instance()
		var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
		var _rand = randi() % _NPC_Create_Array.size()
		_StaffNode.position = _NPC_Create_Array[_rand]
		LevelNode.Ysort_Players.add_child(_StaffNode)
		_StaffNode.IsStaff = true
		_StaffNode.call_load(return_Staff_Info(_Type, _Rank))
		_StaffNode.HomePoint = _StaffNode.position
		print("面试者：", _StaffNode.position, _StaffNode.HomePoint)

func return_Staff_Info(_Type: String, _Rank: int):



	var StaffList: Array = []
	var _TypeKeys = GameLogic.Config.StaffConfig.keys()
	for _ID in _TypeKeys:
		if int(GameLogic.Config.StaffConfig[_ID].Rank) == _Rank:
			StaffList.append(_ID)
	var _AvatarID = StaffList[randi() % StaffList.size()]
	var _TYPEINFO = GameLogic.Config.StaffConfig[_AvatarID]
	var _Act = randi() % _Rank

	var _BaseDaily = 10 + _Act
	var _SkillList: Array = GameLogic.Skill.return_skills(_TYPEINFO.Skills, _Type, _Rank)
	var _SkillValue: int = 0

	var _NAMEKeys = GameLogic.Config.NameConfig.keys()
	var _Name = str(_NAMEKeys[randi() % _NAMEKeys.size()])
	while GameLogic.cur_Staff.has(_Name):
		_Name = str(_NAMEKeys[randi() % _NAMEKeys.size()]) + GameLogic.Config.NameConfig[str(randi() % _NAMEKeys.size())].Name
	var _STAFFINFO: Dictionary = {
		"NAME": _Name,
		"cur_Pressure": 0,
		"AvatarID": _AvatarID,
		"AvatarType": (randi() % 3 + 2),
		"SkillList": _SkillList,
		"DayActionDic": {},
		"ActionMax": 3 + _Act,
		"HomePoint": Vector2.ZERO,
		}
	return _STAFFINFO
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

		if GameLogic.Astar._Point_Dir.has(_point_Array[i]):
			return _point_Array[i]

	return false
