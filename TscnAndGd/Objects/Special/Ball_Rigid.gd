extends RigidBody2D

var _AUDIO
var SpecialType: int = 20
var KnockBack: bool = true

func _ready():
	if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454]:
		self.queue_free()
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("puppet")
			$CollisionShape2D.disabled = true
			custom_integrator = true
func _on_RigidBody2D_body_entered(_body):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	_AUDIO = GameLogic.Audio.return_RandEffect("气泡")
	_AUDIO.play(0)
	input_vector = _body.global_position - self.global_position

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet", [global_position, input_vector])
func call_SYNC():

	pass
var IsPUPPET: bool
var _LastPos: Vector2
var _LastLinear: Vector2
var _LastAngular
func call_puppet(_POS, _input_vector):

	_AUDIO = GameLogic.Audio.return_RandEffect("气泡")
	_AUDIO.play(0)

	_LastPos = _POS
	$CollisionShape2D.disabled = false

	input_vector = _input_vector

	IsPUPPET = true

var input_vector: Vector2 = Vector2.ZERO
var _MaxSpeed: float = 0
var velocity: Vector2 = Vector2.ZERO
export var Ins_ACCELERATION = 1000
export var Ins_FRICTION = 500
func _integrate_forces(s):





	var CURVELOCITY = s.get_linear_velocity()
	if input_vector != Vector2.ZERO:
		global_position = _LastPos
		velocity = input_vector * _MaxSpeed
		input_vector = Vector2.ZERO
		CURVELOCITY = CURVELOCITY.move_toward(velocity, Ins_ACCELERATION * s.get_step())
		set_linear_velocity(CURVELOCITY)

	else:
		CURVELOCITY = CURVELOCITY.move_toward(Vector2.ZERO, Ins_FRICTION * s.get_step())
		set_linear_velocity(CURVELOCITY)
