extends Node

var cur_level: String

var AStar_Func = AStar2D.new()
var AStar_Staff = AStar2D.new()
var AStar_NPC = AStar2D.new()
var AStar_NPC_Wait = AStar2D.new()
var AStar_Leave = AStar2D.new()
var _move_bool: bool
var target: Vector2

var _checktime: float

var _WorldNode
var _Point_Dir: Dictionary
var _Point_NPC_Dir: Dictionary
var _Point_Staff_Dir: Dictionary
var _Point_Leave_Dir: Dictionary
var OrderV2

func call_clear():
	AStar_Func.clear()
	AStar_NPC.clear()
	AStar_Staff.clear()
	AStar_Leave.clear()
	_Point_Dir.clear()
	_Point_NPC_Dir.clear()
	_Point_Staff_Dir.clear()
	_Point_Leave_Dir.clear()
func call_Path2D_init():

	cur_level = GameLogic.cur_level
	_WorldNode = get_tree().get_root().get_node("Level")
	call_clear()

var ASTAR_LEAVE_TYPE: int = 0
var ASTAR_NPC_TYPE: int = 0
var ASTAR_STAFF_TYPE: int = 0
var ASTAR_MAIN_TYPE: int = 0
func call_Leave_Init(_LeaveNode):
	if _LeaveNode.editor_description == "8":
		ASTAR_LEAVE_TYPE = 1
	else:
		ASTAR_LEAVE_TYPE = 0
	var _UsedArray = _LeaveNode.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		var id = AStar_Func.get_available_point_id()
		var npc_id = AStar_Leave.get_available_point_id()
		_Point_Dir[_pointV2] = id
		_Point_Leave_Dir[_pointV2] = npc_id
		AStar_Func.add_point(id, _pointV2, 10)
		AStar_Leave.add_point(npc_id, _pointV2, 10)

func call_TMap_init_NPC(_TMapNode):

	if _TMapNode.editor_description == "8":
		ASTAR_NPC_TYPE = 1
	else:
		ASTAR_NPC_TYPE = 0
	var _UsedArray = _TMapNode.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		var id = AStar_Func.get_available_point_id()
		var npc_id = AStar_NPC.get_available_point_id()
		_Point_Dir[_pointV2] = id
		_Point_NPC_Dir[_pointV2] = npc_id
		AStar_Func.add_point(id, _pointV2, 10)
		AStar_NPC.add_point(npc_id, _pointV2, 10)
		AStar_NPC_Wait.add_point(npc_id, _pointV2, 10)
func call_TMap_init(_TMapNode):
	if _TMapNode.editor_description == "8":
		ASTAR_STAFF_TYPE = 1
	else:
		ASTAR_STAFF_TYPE = 0

	var _UsedArray = _TMapNode.get_used_cells()

	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
		var id = AStar_Func.get_available_point_id()
		_Point_Dir[_pointV2] = id
		AStar_Func.add_point(id, _pointV2, 10)
		var staff_id = AStar_Staff.get_available_point_id()
		_Point_Staff_Dir[_pointV2] = staff_id
		AStar_Staff.add_point(staff_id, _pointV2, 5)

func call_TMap_Street_init(_TMapNode1, _TMapNode2):
	if _TMapNode1.editor_description == "8":
		ASTAR_MAIN_TYPE = 1
	else:
		ASTAR_MAIN_TYPE = 0
	var tileID_Array = _TMapNode1.tile_set.get_tiles_ids()

	for _i in tileID_Array.size():
		var _id = tileID_Array[_i]
		var _UsedArray = _TMapNode1.get_used_cells_by_id(tileID_Array[_i])
		for _y in _UsedArray.size():
			var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
			var id = AStar_Func.get_available_point_id()
			var npc_id = AStar_NPC.get_available_point_id()
			_Point_Dir[_pointV2] = id
			_Point_NPC_Dir[_pointV2] = npc_id
			_Point_Staff_Dir[_pointV2] = id
			AStar_Func.add_point(id, _pointV2, 10)
			AStar_NPC.add_point(npc_id, _pointV2, 10)
			AStar_Staff.add_point(id, _pointV2, 10)
	tileID_Array = _TMapNode2.tile_set.get_tiles_ids()
	for _i in tileID_Array.size():
		var _id = tileID_Array[_i]
		var _UsedArray = _TMapNode2.get_used_cells_by_id(tileID_Array[_i])
		for _y in _UsedArray.size():
			var _pointV2 = _UsedArray.pop_front() * 100 + Vector2(50, 50)
			var id = AStar_Func.get_available_point_id()
			var npc_id = AStar_NPC.get_available_point_id()
			_Point_Dir[_pointV2] = id
			_Point_NPC_Dir[_pointV2] = npc_id
			_Point_Staff_Dir[_pointV2] = id
			AStar_Func.add_point(id, _pointV2, 20)
			AStar_NPC.add_point(npc_id, _pointV2, 20)
			AStar_Staff.add_point(id, _pointV2, 20)

func connect_init():

	_WorldNode = get_tree().get_root().get_node("Level")
	var _MAINNUM: int = 4
	if ASTAR_MAIN_TYPE == 1:
		_MAINNUM = 8
	for a in AStar_Func.get_points():

		var _point = AStar_Func.get_point_position(a)
		for i in _MAINNUM:
			var _PointAround = _point - _return_pointaround(i, _MAINNUM)
			var _PointDir_Key_Array = _Point_Dir.keys()
			if _PointDir_Key_Array.has(_PointAround):
				var b = _Point_Dir[_PointAround]
				if not AStar_Func.are_points_connected(a, b):
					var space_state = _WorldNode.get_world_2d().direct_space_state
					var result = space_state.intersect_ray(AStar_Func.get_point_position(a), AStar_Func.get_point_position(b))
					if not result:
						AStar_Func.connect_points(a, b, true)

	var _NPCNUM: int = 4
	if ASTAR_NPC_TYPE == 1:
		_NPCNUM = 8
	for a in AStar_NPC.get_points():

		var _point = AStar_NPC.get_point_position(a)

		for i in _NPCNUM:
			var _PointAround = _point - _return_pointaround(i, _NPCNUM)
			var _PointDir_Key_Array = _Point_NPC_Dir.keys()
			if _PointDir_Key_Array.has(_PointAround):
				var b = _Point_NPC_Dir[_PointAround]
				if not AStar_NPC.are_points_connected(a, b):
					var space_state = _WorldNode.get_world_2d().direct_space_state
					var result = space_state.intersect_ray(AStar_NPC.get_point_position(a), AStar_NPC.get_point_position(b))
					if not result:
						AStar_NPC.connect_points(a, b, true)

	var _STAFFNUM: int = 4
	if ASTAR_STAFF_TYPE == 1:
		_STAFFNUM = 8
	for a in AStar_Staff.get_points():
		var _point = AStar_Staff.get_point_position(a)

		for i in _STAFFNUM:
			var _PointAround = _point - _return_pointaround(i, _STAFFNUM)
			var _PointDir_Key_Array = _Point_Staff_Dir.keys()
			if _PointDir_Key_Array.has(_PointAround):
				var b = _Point_Staff_Dir[_PointAround]
				if not AStar_Staff.are_points_connected(a, b):

					AStar_Staff.connect_points(a, b, true)
	var _LEAVENUM: int = 4
	if ASTAR_LEAVE_TYPE == 1:
		_LEAVENUM = 8
	for a in AStar_Leave.get_points():
		var _point = AStar_Leave.get_point_position(a)

		for i in _LEAVENUM:
			var _PointAround = _point - _return_pointaround(i, _LEAVENUM)
			var _PointDir_Key_Array = _Point_Leave_Dir.keys()
			if _PointDir_Key_Array.has(_PointAround):
				var b = _Point_Leave_Dir[_PointAround]
				if not AStar_Leave.are_points_connected(a, b):
					AStar_Leave.connect_points(a, b, true)

func _return_pointaround(_location, _max):
	if _max == 4:
		match _location:
			0:
				return Vector2(0, - 100)
			1:
				return Vector2( - 100, 0)
			2:
				return Vector2(100, 0)
			3:
				return Vector2(0, 100)
	elif _max == 8:
		match _location:
			0:
				return Vector2( - 100, - 100)
			1:
				return Vector2(0, - 100)
			2:
				return Vector2(100, - 100)
			3:
				return Vector2( - 100, 0)
			4:
				return Vector2(100, 0)
			5:
				return Vector2( - 100, 100)
			6:
				return Vector2(0, 100)
			7:
				return Vector2(100, 100)

func return_closest_NPCFloor_pos(_pos):
	var _closePoint = AStar_NPC_Wait.get_closest_point(AStar_NPC_Wait.get_closest_position_in_segment(_pos))
	if _closePoint == - 1:
		printerr("错误 NPCFloor_pos")
		return Vector2.ZERO
	var _closePoint_pos = AStar_NPC_Wait.get_point_position(_closePoint)


	return _closePoint_pos
func return_closest_Staff_pos(_pos):
	var _closePoint = AStar_Staff.get_closest_point(AStar_Staff.get_closest_position_in_segment(_pos))
	if _closePoint == - 1:

		return Vector2(0, 0)
	var _closePoint_pos = AStar_Staff.get_point_position(_closePoint)

	return _closePoint_pos

func return_WayPoint_Array(_startPoint, _targetPoint):



	var _startAStarPoint = AStar_Func.get_closest_point(AStar_Func.get_closest_position_in_segment(_startPoint))
	var _targetAStarPoint = AStar_Func.get_closest_point(AStar_Func.get_closest_position_in_segment(_targetPoint))
	if _startAStarPoint == - 1 or _targetAStarPoint == - 1:

		return []
	var _WayPoint_Array = Array(AStar_Func.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 20 + 10
	for i in _WayPoint_Array.size():
		if i != _WayPoint_Array.size() - 1:
			var _NewArray = _WayPoint_Array[i]
			_step += 1
			if _step >= _stepMax:
				_step = 0
				var _rand = float(GameLogic.return_RANDOM() % 100 - 50)
				_NewArray.x += _rand
				_rand = float(GameLogic.return_RANDOM() % 100 - 50)
				_NewArray.y += _rand
			else:
				var _rand = float(GameLogic.return_RANDOM() % 51 - 25)
				_NewArray.x += _rand
				_NewArray.y += _rand
			_WayPoint_Array[i] = _NewArray
	if _WayPoint_Array.size():
		_WayPoint_Array.remove(0)

	return _WayPoint_Array
func return_Bug_WayPoint_Array(_startPoint, _targetPoint):
	var _startAStarPoint = AStar_Staff.get_closest_point(AStar_Staff.get_closest_position_in_segment(_startPoint))
	var _targetAStarPoint = AStar_Staff.get_closest_point(AStar_Staff.get_closest_position_in_segment(_targetPoint))


	var _WayPoint_Array = Array(AStar_Staff.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 3
	for i in _WayPoint_Array.size():
		var _NewArray = _WayPoint_Array[i]
		_step += 1
		if _step >= _stepMax:
			_step = 0
			var _rand = float(GameLogic.return_RANDOM() % 100 - 50)
			_NewArray.x += _rand
			_rand = float(GameLogic.return_RANDOM() % 100 - 50)
			_NewArray.y += _rand
		else:
			var _rand = float(GameLogic.return_RANDOM() % 51 - 25)
			_NewArray.x += _rand
			_NewArray.y += _rand
		_WayPoint_Array[i] = _NewArray
	if _WayPoint_Array.size():
		_WayPoint_Array.remove(0)

	return _WayPoint_Array
func return_Staff_WayPoint_Array(_startPoint, _targetPoint):
	var _startAStarPoint = AStar_Staff.get_closest_point(AStar_Staff.get_closest_position_in_segment(_startPoint))
	var _targetAStarPoint = AStar_Staff.get_closest_point(AStar_Staff.get_closest_position_in_segment(_targetPoint))


	var _WayPoint_Array = Array(AStar_Staff.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 20 + 10
	for i in _WayPoint_Array.size():
		var _NewArray = _WayPoint_Array[i]
		_step += 1
		if _step >= _stepMax:
			_step = 0
			var _rand = float(GameLogic.return_RANDOM() % 100 - 50)
			_NewArray.x += _rand
			_rand = float(GameLogic.return_RANDOM() % 100 - 50)
			_NewArray.y += _rand
		else:
			var _rand = float(GameLogic.return_RANDOM() % 51 - 25)
			_NewArray.x += _rand
			_NewArray.y += _rand
		_WayPoint_Array[i] = _NewArray
	if _WayPoint_Array.size():
		_WayPoint_Array.remove(0)

	return _WayPoint_Array
func return_NPC_WayPoint_Array(_startPoint, _targetPoint):

	if not _startPoint or not _targetPoint:
		return []
	var _startAStarPoint = AStar_NPC.get_closest_point(AStar_NPC.get_closest_position_in_segment(_startPoint))

	var _targetAStarPoint = AStar_NPC.get_closest_point(AStar_NPC.get_closest_position_in_segment(_targetPoint))

	if not AStar_NPC.has_point(_startAStarPoint) and not AStar_NPC.has_point(_targetAStarPoint):
		return []
	var _WayPoint_Array = Array(AStar_NPC.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 2 + 1
	var _Offset: Vector2 = Vector2(float(GameLogic.return_RANDOM() % 51 - 25), float(GameLogic.return_RANDOM() % 51 - 25))
	for i in _WayPoint_Array.size():
		var _NewArray = _WayPoint_Array[i]
		_step += 1
		if _step >= _stepMax:
			_step = 0
			_Offset = Vector2(float(GameLogic.return_RANDOM() % 51 - 25), float(GameLogic.return_RANDOM() % 51 - 25))
			_NewArray += _Offset
		else:
			_NewArray += _Offset

		_WayPoint_Array[i] = _NewArray



	return _WayPoint_Array
func return_NPCWait_WayPoint_Array(_startPoint, _targetPoint):

	if not _startPoint or not _targetPoint:
		return []
	var _startAStarPoint = AStar_NPC.get_closest_point(AStar_NPC.get_closest_position_in_segment(_startPoint))

	var _targetAStarPoint = AStar_NPC.get_closest_point(AStar_NPC.get_closest_position_in_segment(_targetPoint))

	if not AStar_NPC.has_point(_startAStarPoint) and not AStar_NPC.has_point(_targetAStarPoint):
		return []
	var _WayPoint_Array = Array(AStar_NPC.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 10 + 5
	var _Offset: Vector2 = Vector2(float(GameLogic.return_RANDOM() % 51 - 25), float(GameLogic.return_RANDOM() % 51 - 25))
	for i in _WayPoint_Array.size():
		var _NewArray = _WayPoint_Array[i]
		_step += 1

		if _step >= _stepMax:
			_step = 0
			_Offset = Vector2(float(GameLogic.return_RANDOM() % 51 - 25), float(GameLogic.return_RANDOM() % 51 - 25))
			_NewArray += _Offset
		else:
			_NewArray += _Offset

		_WayPoint_Array[i] = _NewArray



	return _WayPoint_Array
func return_NPC_Leave_Array(_startPoint, _targetPoint):

	if not _startPoint or not _targetPoint:
		return []
	var _startAStarPoint = AStar_Leave.get_closest_point(AStar_Leave.get_closest_position_in_segment(_startPoint))

	var _targetAStarPoint = AStar_Leave.get_closest_point(AStar_Leave.get_closest_position_in_segment(_targetPoint))

	if not AStar_Leave.has_point(_startAStarPoint) and not AStar_Leave.has_point(_targetAStarPoint):
		return []
	var _WayPoint_Array = Array(AStar_Leave.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 20 + 5

	var _Offset: Vector2 = Vector2(float(GameLogic.return_RANDOM() % 100 - 50), float(GameLogic.return_RANDOM() % 100 - 50))
	for i in _WayPoint_Array.size():
		var _NewArray = _WayPoint_Array[i]
		_step += 1

		if _step >= _stepMax:
			_step = 0
			_Offset = Vector2(float(GameLogic.return_RANDOM() % 100 - 50), float(GameLogic.return_RANDOM() % 100 - 50))

			_NewArray += _Offset

		else:

			_NewArray += _Offset

		_WayPoint_Array[i] = _NewArray



	return _WayPoint_Array

func return_courier_WayPoint_Array(_startPoint, _targetPoint):
	if not _startPoint or not _targetPoint:
		return
	var _startAStarPoint = AStar_Func.get_closest_point(AStar_Func.get_closest_position_in_segment(_startPoint))

	var _targetAStarPoint = AStar_Func.get_closest_point(AStar_Func.get_closest_position_in_segment(_targetPoint))

	var _WayPoint_Array = Array(AStar_Func.get_point_path(_startAStarPoint, _targetAStarPoint))


	var _step = 0
	var _stepMax = GameLogic.return_RANDOM() % 20 + 20
	for i in _WayPoint_Array.size():
		var _NewArray = _WayPoint_Array[i]
		_step += 1
		var _Offset: Vector2 = Vector2(float(GameLogic.return_RANDOM() % 100 - 50), float(GameLogic.return_RANDOM() % 100 - 50))
		if _step >= _stepMax:
			_step = 0
			_Offset = Vector2(float(GameLogic.return_RANDOM() % 100 - 50), float(GameLogic.return_RANDOM() % 100 - 50))
			_NewArray += _Offset
		else:
			_NewArray += _Offset

		_WayPoint_Array[i] = _NewArray


	return _WayPoint_Array
