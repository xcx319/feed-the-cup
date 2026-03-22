extends KinematicBody2D

var _SPEED = 50

var WAIT_TIME: float
var velocity: Vector2
var input_vector: Vector2 = Vector2.ZERO
onready var TypeAni = $Type
onready var ActAni = $ActAni
var _IDLENAME: String

export var SHOWBOOL: bool
export var ID: String

func _ready():
	set_physics_process(false)
	call_Type()
	if SHOWBOOL:
		ActAni.play("init")
		return
	var _RAND = GameLogic.return_RANDOM() % 5 + 1
	_IDLENAME = "Idle" + str(_RAND)

func call_Type():

	if TypeAni.has_animation(ID):
		TypeAni.play(ID)
func call_start():
	set_physics_process(true)

func _physics_process(delta):
	if get_parent().get_parent().get_node("Players").has_node(str(SteamLogic.STEAM_ID)):
		var _PLAYER = get_parent().get_parent().get_node("Players").get_node(str(SteamLogic.STEAM_ID))
		if WAIT_TIME > 0:
			WAIT_TIME = 0
			var new_vector = _PLAYER.global_position - self.global_position
			var _NUM_CHECK: int = 100
			if abs(new_vector.x) > _NUM_CHECK or abs(new_vector.y) > _NUM_CHECK:
				input_vector = new_vector.normalized()
			else:
				input_vector = Vector2.ZERO

		WAIT_TIME += delta
		if input_vector != Vector2.ZERO:
			velocity = velocity.move_toward(input_vector * 300, 500 * delta)

		else:
			velocity = velocity.move_toward(Vector2.ZERO, 1000 * delta)
		velocity = move_and_slide(velocity)
		_ani_logic()
func _ani_logic():
	if input_vector == Vector2.ZERO:

		ActAni.play(_IDLENAME)
	else:
		ActAni.play("Jump")
