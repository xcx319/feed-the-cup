extends Head_Object
var SelfDev = "SnowShovel"

var StainCount: int = 0
var StainMax: int = 150
var _COLOR: Color = Color8(255, 255, 255, 0)
var _PLAYERNODE
var Face = face_down

enum {
	face_up,
	face_down,
	face_left,
	face_right
}

func call_Check():
	if not GameLogic.curLevelList.has("难度-下雪"):
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_del")
		call_del()
		return
func _ready() -> void :
	call_init(SelfDev)

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		CanGround = true
		if get_parent().name in ["Items", "Devices"]:
			call_Collision_Switch(true)
		else:
			call_Collision_Switch(false)
		$X.hide()
		return
	if not GameLogic.is_connected("DayStart", self, "call_Check"):
		var _CON = GameLogic.connect("DayStart", self, "call_Check")



	CanGround = true
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

	$X.hide()

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME

	.call_Ins_Save(_SELFID)

func call_used_face():

	Face = _PLAYERNODE.AVATAR.FACE

	match Face:
		face_up:
			_PLAYERNODE.Con.input_vector = Vector2.UP

		face_down:
			_PLAYERNODE.Con.input_vector = Vector2.DOWN

		face_left:
			_PLAYERNODE.Con.input_vector = Vector2.LEFT
		face_right:
			_PLAYERNODE.Con.input_vector = Vector2.RIGHT

func return_Shovel_start(_Player, _Speed):

	if get_parent().name != "Weapon_note":
		return false
	if StainCount >= StainMax:
		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			_Player.call_Say_NeedClean()
	else:
		_PLAYERNODE = _Player
		StainSave = StainCount

	_PLAYERNODE.Con.CanMove = false

	call_used_face()
	$SnowArea / CollisionShape2D.disabled = false
	return true
var StainSave: int = 0
func call_Shovel_end_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	if is_instance_valid(_Player):
		_Player.Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
		$SnowArea / CollisionShape2D.disabled = true
		_Player.Con.CanMove = true

func call_Shovel_end(_Player):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Shovel_end_puppet", [_PLAYERPATH])

	$SnowArea / CollisionShape2D.disabled = true
	_PLAYERNODE.Con.CanMove = true

func call_ZAni(_Type):

	get_node("ZAni").play(_Type)

func _on_Area2D_area_entered(area):

	if StainCount >= StainMax:
		return
	var _WATERCOLOR = area.WaterColor
	if _COLOR != _WATERCOLOR:

		if _WATERCOLOR.r8 == 137 and _WATERCOLOR.g8 == 228 and _WATERCOLOR.b8 == 245:
			_WATERCOLOR.a = _COLOR.a

		if StainCount > 0:
			var _STAIN: float = float(StainCount) / float(StainMax)
			var _modulate_Mix = (_COLOR + _WATERCOLOR) * _STAIN
			_COLOR = _modulate_Mix

	area.call_clean(true, self, 1)

func _on_Area2D_area_exited(area):

	area.call_clean(false, self, 1)

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
	if body.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		But_Switch(true, body)

func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
	if body.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		But_Switch(false, body)

func call_X_Switch(_Switch: bool):
	match _Switch:
		true:
			$X.show()
		false:
			$X.hide()

func _on_SnowArea_area_entered(_area):

	if _area.NUM >= 20:
		$Audio.play()
		$Audio2.stop()
	else:
		$Audio.stop()
		$Audio2.play()


	_area.call_move(true, Face)

func _on_SnowArea_area_exited(_area):
	_area.call_move(false, Face)
