extends Head_Object

onready var Collision = get_node("CollisionShape2D")
onready var TexNode = get_node("TexNode")

onready var EffectNode = get_node("TexNode/Effect_flies")
var _ParentName
var _check: bool
var Is_Smelly: bool

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :

	FuncType = "Trashbag"
	call_deferred("call_Collision_set")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():
	if not is_instance_valid(self):
		return

	if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.TRASHBAG):
		GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.TRASHBAG)
	if get_parent().name == "Items":
		self.queue_free()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	.But_Switch(_bool, _Player)

func call_Collision_set():
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
func _effect_set():
	if Weight <= 5:
		EffectNode.hide()
func call_load(_info):
	call_init("Trashbag")
	_SELFID = int(_info.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	IsItem = true
	Weight = _info.Weight
	_effect_set()
	_Scale_set()
	call_Collision_set()
	var _WEIGHT = Weight
	if _WEIGHT > 10:
		_WEIGHT = 10
	if _WEIGHT > 0:
		var _CarryWeight: float = 1.0 - (float(_WEIGHT) / float(10) * 0.5)
		if _CarryWeight < 0.5:
			_CarryWeight = 0.5

		CarrySpeed = _CarryWeight

func call_Collision_Switch(_Switch):
	match _Switch:
		true:
			Collision.disabled = not _Switch
		false:
			Collision.disabled = not _Switch

func call_Trashbag_init(_weight, _CollisionSwitch):
	IsItem = true

	Weight = _weight
	_effect_set()
	_Scale_set()
	call_Collision_Switch(_CollisionSwitch)
func _Scale_set():

	if CarrySpeed < 0.5:
		CarrySpeed = 0.5
	var _scale: float = 0.5 + float(int(float(Weight) / (float(Weight) + 10) * 100)) / 100
	if _scale < 0.5:
		_scale = 0.5
	Collision.scale = Vector2(_scale, _scale)
	TexNode.set_scale(Vector2(_scale, _scale))

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
