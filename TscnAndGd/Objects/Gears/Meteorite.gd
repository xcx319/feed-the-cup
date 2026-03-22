extends RigidBody2D

var input_vector: Vector2
export var SPEED: int

export var Rotation: float
var _FALLBOOL: bool

onready var ANI = $AnimationPlayer
func call_ThrowObj():
	pass

func call_roll_end():
	self.queue_free()
	pass
func _process(_delta):

	if _FALLBOOL:

		var _CHECKVec: Vector2 = input_vector * _CURSPEED
		Rotation = _CHECKVec.x / 5
		if input_vector.x < 0:
			Rotation = Rotation * - 1

	$RigidBody2D / Sprite.rotation += Rotation * _delta
	if Rotation < 1 and Rotation > - 1:
		set_process(false)

var _CURSPEED: Vector2
func _integrate_forces(s):

	var CURVELOCITY = s.get_linear_velocity()

	if _FALLBOOL:
		var _CHECK = input_vector
		CURVELOCITY = CURVELOCITY.move_toward(Vector2.ZERO, SPEED * s.get_step())


		set_linear_velocity(CURVELOCITY)
	elif input_vector != Vector2.ZERO:
		var _MaxSpeed = input_vector.normalized() * SPEED
		CURVELOCITY = _MaxSpeed

		set_linear_velocity(CURVELOCITY)
	else:
		CURVELOCITY = Vector2.ZERO

		set_linear_velocity(CURVELOCITY)

	_CURSPEED = CURVELOCITY
func _on_BaseBall_body_entered(_body):
	if _body.has_method("call_FallDown"):
		if not _body.cur_Player in [2, SteamLogic.STEAM_ID]:
			return
		if _body.Stat.Skills.has("技能-穿越") and _body.Con._IsSKILL:
			return
		var _POWER: float = float(SPEED) / 1000
		_body.call_FallDown(_POWER)
		_body.call_BaseBall_Hit()
		_body.call_Meteorite_Hit()
		input_vector = (self.position - _body.position).normalized()
		_FALLBOOL = true
		ANI.play("end")
		call_Effect()
		if SteamLogic.IsMultiplay:
			SteamLogic.call_puppet_node_sync(self, "call_end_puppet", [input_vector])
func call_end_puppet(_input_vector):
	input_vector = _input_vector
	_FALLBOOL = true
	ANI.play("end")
	call_Effect()

func call_Effect():
	var _HITTSCN = GameLogic.TSCNLoad.HitEffect_TSCN
	var _HitNode = _HITTSCN.instance()
	_HitNode.position = self.global_position + Vector2(0, - 100)
	get_parent().add_child(_HitNode)
	_HitNode.get_node("Ani").play("hit")
