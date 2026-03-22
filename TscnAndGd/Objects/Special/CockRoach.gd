extends KinematicBody2D

func _DayClosedCheck():
	pass

var WayPoint_array: Array
var _Path_IsFinish: bool = true
var CheckPos: Vector2
var target: Vector2
onready var _TIMER = $LogicTimer

enum {
	face_up,
	face_down,
	face_left,
	face_right
}

var FACE = face_down
onready var FaceAni = $FaceAni
onready var BugAni = $BugAni
var velocity: Vector2
var _input_vector: Vector2
var _MAXSPEED: int = 100
var _HP: int = 3
var _CHECK: int = 0
var _MAXHP: int = 3
var _SPEEDMULT: float = 1
export var _BASEMULT: float = 1
onready var _AUDIO = $Audio2D
onready var EFFECT_TSCN = preload("res://TscnAndGd/Effects/Effect_Hit_01.tscn")
var _ISSTART: bool
func _ready():

	if GameLogic.NPC.LevelNode.has_node("YSort/Players"):
		for _PLAYER in GameLogic.NPC.LevelNode.get_node("YSort/Players").get_children():
			if _PLAYER.has_method("call_StepOn"):
				if not _PLAYER.is_connected("StepOn", self, "call_StepCheck"):
					var _checkP1 = _PLAYER.connect("StepOn", self, "call_StepCheck")
	target = self.position
	_TIMER.start(0)

	if _BASEMULT > 1.05:
		_HP = 2
		_MAXHP = 2
	elif _BASEMULT < 0.95:
		_HP = 1
		_MAXHP = 1
	self.scale = Vector2(_BASEMULT, _BASEMULT)

func next_point():

	if WayPoint_array.size():
		CheckPos = self.position

		target = WayPoint_array.pop_front()

	else:
		_Path_IsFinish = true
		_TIMER.start(0)
		_SPEEDMULT = 1.5
func call_puppet_nextpoint(_POS, _TARGET):
	if self.position != _POS:
		self.position = self.position.move_toward(_POS, _MAXSPEED)

	CheckPos = _POS
	target = _TARGET
	_Path_IsFinish = false

func _physics_process(_delta):
	if not _Path_IsFinish:
		if self.position.distance_to(target) < 30:
			next_point()
	elif self.position != target:
		if _HP > 0:
			self.position = target


	_face_logic()
	_move(_delta)
func _move(_delta):

	if _HP <= 0:
		return
	if self.position.distance_to(target) >= 30:
		_input_vector = position.direction_to(target).normalized()

	else:
		_input_vector = Vector2.ZERO

	if _input_vector != Vector2.ZERO:
		var _C = 3000 * _HP
		if _HP <= 0:
			_C = 3000
		velocity = velocity.move_toward(_input_vector * (_MAXSPEED * _SPEEDMULT * _BASEMULT), _C * _delta)
	else:

		velocity = velocity.move_toward(Vector2.ZERO, 2000 * _delta)
	velocity = move_and_slide(velocity)

func _on_LogicTimer_timeout():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.LoadingUI.IsLevel:
		return
	if _SPEEDMULT > 1:
		_SPEEDMULT -= 0.25
	if _Path_IsFinish:
		if not _ISSTART:
			call_new_way()
			_ISSTART = true
			return
		_CHECK += 1

		if _CHECK > 5:
			_CHECK = 0
			if _HP <= _MAXHP and _HP > 0:

				call_new_way()
				GameLogic.call_Pressure_Set(1)
		else:
			_TIMER.start(0)

func call_new_way():

	if GameLogic.NPC.LevelNode.has_node("MapNode/Floor"):
		var _FLOORLIST = GameLogic.NPC.LevelNode.get_node("MapNode/Floor").get_used_cells()
		var _randfloor = GameLogic.return_RANDOM() % _FLOORLIST.size()
		var _pointV2 = _FLOORLIST[_randfloor] * 100 + Vector2(50, 50)
		WayPoint_array = GameLogic.Astar.return_Bug_WayPoint_Array(self.global_position, _pointV2)
		_Path_IsFinish = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_way_puppet", [WayPoint_array, _SPEEDMULT])
func call_way_puppet(_WAY, _SPEED):
	_SPEEDMULT = _SPEED
	WayPoint_array = _WAY
	_Path_IsFinish = false

func call_StepLogic():
	if _HP <= 0:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _MaxSpeedMult: float = 1
	if _HP > 0:
		_MaxSpeedMult = 3 * float(_HP) / float(_MAXHP)

	_SPEEDMULT = _MaxSpeedMult
	if _SPEEDMULT > _MaxSpeedMult:
		_SPEEDMULT = _MaxSpeedMult
	_HP -= 1
	call_Effect()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Hit_puppet", [_HP, _SPEEDMULT])
	if _HP > 0:
		call_new_way()
	else:
		call_DIE_Logic()
func call_Hit_puppet(_HPPOINT, _SPEED):
	_SPEEDMULT = _SPEED
	_HP = _HPPOINT
	call_Effect()
	if _HP <= 0:
		call_DIE_Logic()
func call_DIE_Logic():
	var _Popular: int = 30
	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Save.gameData.HomeDevList.has("唱片机"):
			_Popular += 30
	if _Popular != 0:
		_Popular = GameLogic.return_Popular(_Popular, GameLogic.HomeMoneyKey)

	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = self.global_position
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	_PayEffect.call_REP(_Popular)
	GameLogic.call_StatisticsData_Set("Count_KillBugs", null, 1)
	WayPoint_array.clear()
	_Path_IsFinish = true
	_input_vector = Vector2.ZERO
	BugAni.playback_speed = 1
	BugAni.play("Die")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	GameLogic.cur_Item_List["Bug"] -= 1
func call_Effect():
	if GameLogic.NPC.LevelNode.has_node("YSort/NPCs"):
		var _EFF = EFFECT_TSCN.instance()
		_EFF.position = self.position
		GameLogic.NPC.LevelNode.get_node("YSort/NPCs").add_child(_EFF)
		_AUDIO.play(0)
func _face_logic():



	if _HP <= 0:
		BugAni.playback_speed = 1
		BugAni.play("Die")
		return
	if _input_vector != Vector2.ZERO:
		BugAni.playback_speed = _SPEEDMULT
		BugAni.playback_speed = _SPEEDMULT
		BugAni.play("run")
		if _input_vector.y < 0 and abs(_input_vector.y) > abs(_input_vector.x):
			match FACE:
				face_left:
					if abs(_input_vector.y) > abs(_input_vector.x - 0.2):
						FACE = face_up
				face_right:
					if abs(_input_vector.y) > abs(_input_vector.x + 0.2):
						FACE = face_up
				_:
					FACE = face_up
		elif _input_vector.y > 0 and abs(_input_vector.y) > abs(_input_vector.x):
			match FACE:
				face_left:
					if abs(_input_vector.y) > abs(_input_vector.x - 0.2):
						FACE = face_down
				face_right:
					if abs(_input_vector.y) > abs(_input_vector.x + 0.2):
						FACE = face_down
				_:
					FACE = face_down
		elif _input_vector.x < 0:
			FACE = face_left
		elif _input_vector.x > 0:
			FACE = face_right
		match FACE:
			face_up:
				FaceAni.play("Up")
			face_down:
				FaceAni.play("Down")
			face_left:
				FaceAni.play("Left")
			face_right:
				FaceAni.play("Right")

	else:
		BugAni.playback_speed = 1
		BugAni.play("idle")
		match FACE:
			face_up:
				FaceAni.play("Up")
			face_down:
				FaceAni.play("Down")
			face_left:
				FaceAni.play("Left")
			face_right:
				FaceAni.play("Right")

var _PLAYERLIST: Array
func _on_CheckPlayerArea2D_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not _body.has_method("call_StepOn"):
		return

	if _HP > 0:
		var _MaxSpeedMult = 3 * float(_HP) / float(_MAXHP)

	call_new_way()

func call_del():
	self.queue_free()
func call_StepCheck(_PLAYERPOS, _TYPE):
	var _CHECKDISTANCE: int = 25
	match _TYPE:
		0:
			_CHECKDISTANCE = 25
		1:
			_CHECKDISTANCE = 40
	if _PLAYERPOS.distance_to(self.global_position) <= _CHECKDISTANCE:
		call_StepLogic()

func _on_CheckPlayerArea2D_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):

	pass
