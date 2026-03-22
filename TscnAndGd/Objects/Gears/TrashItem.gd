extends Head_Object

onready var Collision = get_node("CollisionShape2D")

var _ParentName
var _check: bool
var Is_Smelly: bool
var IsPick: bool
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :

	FuncType = "Trashbag"
	Weight = 1
	call_deferred("call_Collision_set")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	$AudioStreamPlayer.play(0)

func _DayClosedCheck():
	if not is_instance_valid(self):
		return

	if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.TRASHITEM):
		GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.TRASHITEM)
	GameLogic.call_Pressure_Set(2)

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

func call_load(_info):
	call_init("Trashbag")
	_SELFID = int(_info.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	IsItem = true
	Weight = 1

	var _NAME = _info.ANI
	$Ani.play(_NAME)

	CarrySpeed = 1



func call_Collision_Switch(_Switch):
	match _Switch:
		true:
			Collision.disabled = not _Switch
		false:
			Collision.disabled = not _Switch
func _TrashItem():
	$Ani.play("0")
	if not IsPick:
		IsPick = true
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
		GameLogic.call_StatisticsData_Set("Count_CleanTrash", null, 1)

func call_Trashbag_init(_weight, _CollisionSwitch):
	IsItem = true

	Weight = _weight

	call_Collision_Switch(_CollisionSwitch)

var _TIME: int = 0
func call_TimeLogic():
	if GameLogic.SPECIALLEVEL_Int:
		_TIME += 1
		if _TIME > 10:
			_TIME = 0
			GameLogic.call_Pressure_Set(1)
			$Icon / AnimationPlayer.play("Check")

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
