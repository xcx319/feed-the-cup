extends Head_Object
var SelfDev = "Mop"
onready var UseAni = get_node("Area2D/Ani")
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

func _ready() -> void :
	call_deferred("call_init", SelfDev)
	StainMax = 30
	CanGround = true
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if GameLogic.is_connected("DayStart", self, "_Stain_Logic"):
		GameLogic.disconnect("DayStart", self, "_Stain_Logic")
	$X.hide()

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	StainCount = _Info.StainCount
	if _Info.has("Color"):
		_COLOR = _Info.Color
	call_deferred("_Stain_Logic")
func call_stain_puppet(_STAIN, _WATERCOLOR):
	_COLOR = _WATERCOLOR
	StainCount = _STAIN
	$Audio.play(0)
	_Stain_Logic()
func call_add_stain():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	StainCount += 1
	$Audio.play(0)
	if StainCount > StainMax:
		StainCount = StainMax
	_Stain_Logic()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_stain_puppet", [StainCount, _COLOR])
func call_Stain(_WATERCOLOR):
	_COLOR = _WATERCOLOR

	$TexNode / DeviceMopRod / Mop.modulate = _WATERCOLOR
	$TexNode / DeviceMopRod / Mop_Dirty.modulate.a = _WATERCOLOR.a

func _Stain_Logic():

	if get_parent().name in ["Items", "ObjNode"]:
		if StainCount > 0:
			var _STAIN: float = float(StainCount) / float(StainMax)
			_COLOR.a = _STAIN
			$TexNode / DeviceMopRod / Mop.modulate = _COLOR
			$TexNode / DeviceMopRod / Mop_Dirty.modulate.a = _STAIN

		return
	call_PlayerMop_Color()
func call_PlayerMop_Color():
	var _x = get_parent().name
	var _TOPNOTE = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	if StainCount > 0:
		var _STAIN: float = float(StainCount) / float(StainMax)
		_COLOR.a = _STAIN
		$TexNode / DeviceMopRod / Mop.modulate = _COLOR
		$TexNode / DeviceMopRod / Mop_Dirty.modulate.a = _STAIN

	else:
		_COLOR.a = 0
		$TexNode / DeviceMopRod / Mop.modulate = _COLOR
		$TexNode / DeviceMopRod / Mop_Dirty.modulate.a = 0
	if _TOPNOTE.name == "All_note":
		if _TOPNOTE.has_node("StaffMop/Body_note/BodyPose/Arm_hold/Pose_Hold/Weapon_note/Mop_pool"):
			_TOPNOTE.get_node("StaffMop/Body_note/BodyPose/Arm_hold/Pose_Hold/Weapon_note/Mop_pool").call_Stain(_COLOR)

func call_used_face():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		call_PlayerMop_Color()
		return
	match Face:
		face_up:
			UseAni.play("up")
		face_down:
			UseAni.play("down")
		_:
			UseAni.play("use")
	call_PlayerMop_Color()
func return_WORK_start(_Player, _Speed):

	if get_parent().name != "Weapon_note":
		return false
	if StainCount >= StainMax:
		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			_Player.call_Say_NeedClean()
	else:
		_PLAYERNODE = _Player
		StainSave = StainCount
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return true
	call_used_face()

	return true
var StainSave: int = 0
func call_STIR_end_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_Player.Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
	UseAni.play("init")
	if is_instance_valid(_PLAYERNODE):
		if _PLAYERNODE.cur_Player in [1, 2, SteamLogic.STEAM_ID]:

			GameLogic.call_StatisticsData_Set("CleanNum", null, StainCount - StainSave)
func call_STIR_end(_Player):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_STIR_end_puppet", [_PLAYERPATH])
	if is_instance_valid(_PLAYERNODE):
		if _PLAYERNODE.cur_Player in [1, 2, SteamLogic.STEAM_ID]:

			GameLogic.call_StatisticsData_Set("CleanNum", null, StainCount - StainSave)
	UseAni.play("init")

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
		else:
			_COLOR = Color8(0, 0, 0, 0)

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
