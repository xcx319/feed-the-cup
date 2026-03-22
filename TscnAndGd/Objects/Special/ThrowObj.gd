extends RigidBody2D

onready var ObjNode = $ObjNode
onready var Coll = $CollisionShape2D
var _PLAYER
var cur_Touch_Count: int = 0
var OBJ
var IsSlow: bool = false
var IsThrow: bool
var cur_Player: int = 0
var SpecialType: int = - 1
func _ready():
	if not GameLogic.is_connected("CloseLight", self, "call_closed"):
		var _CON = GameLogic.connect("CloseLight", self, "call_closed")
func call_closed():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	call_puppet(self.position)
func call_ThrowObj():
	pass

var _Vector: Vector2
var _POWER: int = 2500
func call_Throw(_VECTOR, _P: int = 2500):
	if _VECTOR != Vector2.ZERO:
		_Vector = _VECTOR
	_POWER = 2500

	$Timer.start(0)

func _on_ThrowObj_body_entered(_body):
	IsSlow = true
	if _body.has_method("_PlayerNode"):
		var _ANGLE = self.position.angle_to(_body.position)
		var _POS = (_body.position - position) * CURVELOCITY
		var _CURVELOCITY: Vector2 = _body.linear_velocity.move_toward(_POS, 2000)
		if abs(_CURVELOCITY.x) > 100 and _CURVELOCITY.x > 0:
			_CURVELOCITY.x = 100
		elif abs(_CURVELOCITY.x) > 100 and _CURVELOCITY.x < 0:
			_CURVELOCITY.x = - 100
		if abs(_CURVELOCITY.y) > 100 and _CURVELOCITY.y > 0:
			_CURVELOCITY.y = 100
		elif abs(_CURVELOCITY.y) > 100 and _CURVELOCITY.y < 0:
			_CURVELOCITY.y = - 100
		_body.set_linear_velocity(_CURVELOCITY)

var CURVELOCITY: Vector2
func call_puppet(_POS):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet", [self.position])
	GameLogic.Device.Box_OnGround(OBJ, _POS)
	OBJ = null
	self.queue_free()

func _integrate_forces(s):
	if IsSlow:
		applied_force = Vector2.ZERO
		var _CURVELOCITY = s.get_linear_velocity()
		CURVELOCITY = _CURVELOCITY

		if not is_instance_valid(OBJ):
			self.queue_free()
			return
		if abs(_CURVELOCITY.x) < 1 and abs(_CURVELOCITY.y) < 1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				call_puppet(self.position)
				return


			call_puppet(self.position)

		else:
			_CURVELOCITY = _CURVELOCITY.move_toward(Vector2.ZERO, 2000 * s.get_step())

			set_linear_velocity(_CURVELOCITY)

	else:
		if not IsThrow and _Vector != Vector2.ZERO:
			IsThrow = true
			var _CURVELOCITY = s.get_linear_velocity()

			_CURVELOCITY = _CURVELOCITY.move_toward(_Vector * _POWER, 100000 * s.get_step())
			set_linear_velocity(_CURVELOCITY)


func _physics_process(_delta):

	pass

func _on_Timer_timeout():

	IsSlow = true
	$CollAni.play("Touch")
