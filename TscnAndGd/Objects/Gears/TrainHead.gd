extends KinematicBody2D

var _SPECIAL: int
var RUNTIME: int = - 1
var _UPDOWNBool: bool
var IsRunning: bool
var _TYPE: int = 0
var TimeList: Array

func _ready():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _LEVELINFO = GameLogic.cur_levelInfo
	if GameLogic.curLevelList.has("难度-小火车"):
		pass
	else:
		self.queue_free()
	if not GameLogic.GameUI.is_connected("TimeChange", self, "_TimeChange_Logic"):
		var _check = GameLogic.GameUI.connect("TimeChange", self, "_TimeChange_Logic")
	if not GameLogic.is_connected("DayStart", self, "call_init"):
		var _CON = GameLogic.connect("DayStart", self, "call_init")
func call_init():
	position = Vector2(3000, 850)

	TimeList.clear()
	RUNTIME = - 1
	IsRunning = false
	if not GameLogic.LoadingUI.IsLevel:
		return
	_SPECIAL = GameLogic.return_randi() % 6

	for _i in 6:
		var _NUM = 0.5 + float(GameLogic.return_randi() % 6) / 10
		TimeList.append(_NUM)

func _TimeChange_Logic():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not TimeList.size():
		return
	if RUNTIME == - 1:
		for _TIME in TimeList.size():
			if _TIME == 0:
				TimeList[_TIME] = GameLogic.GameUI.CurTime + TimeList[_TIME]
			else:
				TimeList[_TIME] = TimeList[_TIME - 1] + TimeList[_TIME]
		RUNTIME = 0
	if RUNTIME >= TimeList.size():
		return
	var _TIME = TimeList[RUNTIME]
	if GameLogic.GameUI.CurTime >= _TIME:
		if RUNTIME == _SPECIAL:
			$Type.play("1")
		else:
			$Type.play("init")
		call_Run()
		RUNTIME += 1

func call_Run_puppet(_UPDOWN, _SPEED):
	_UPDOWNBool = _UPDOWN
	speed = _SPEED
	IsRunning = true
	if not _UPDOWNBool:
		position = Vector2(2000, 850)
		scale.x = - 1
		$AnimationPlayer.play("run")
	else:
		position = Vector2( - 750, 550)
		_UPDOWNBool = true
		scale.x = - 1
func call_Run():
	IsRunning = true

	if _UPDOWNBool:
		position = Vector2(2000, 850)
		_UPDOWNBool = false
		scale.x = - 1

		speed = 140 + GameLogic.return_randi() % 20 * 10


	else:
		position = Vector2( - 750, 550)
		_UPDOWNBool = true
		scale.x = - 1
		speed = 140 + GameLogic.return_randi() % 20 * 10

	print("call_Run:", speed, _UPDOWNBool, scale.x)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Run_puppet", [_UPDOWNBool, speed])
func call_RunEnd():
	IsRunning = false
func _integrate_forces(s):
	var CURVELOCITY = s.get_linear_velocity()

	CURVELOCITY = CURVELOCITY.move_toward(Vector2( - 20, 0), 100)
	s.set_linear_velocity(CURVELOCITY)

var speed = 150
func _physics_process(_delta):
	if IsRunning:
		if _TYPE == 0:
			$AnimationPlayer.play("Start")
			_TYPE = 1
		elif _TYPE == 1 and not $AnimationPlayer.current_animation == "Start":

			$AnimationPlayer.play("run")
			_TYPE = 2
		if _UPDOWNBool:
			var velocity = Vector2.RIGHT * speed
			move_and_collide(velocity * _delta)
		else:
			var velocity = Vector2.LEFT * speed
			move_and_collide(velocity * _delta)

		if _UPDOWNBool:

			if global_position.x >= 2500:
				IsRunning = false
				_TYPE = 0
				$AnimationPlayer.play("init")

		else:

			if global_position.x < - 1500:
				IsRunning = false
				_TYPE = 0
				$AnimationPlayer.play("init")
