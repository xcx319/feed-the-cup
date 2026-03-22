extends Head_Object
var SelfDev = "HighStressToy"

var MixPlayer
var IsMixing: bool
var TYPE: int = 2

onready var USEANI = $AniNode / UseAni
onready var A_But = $But / A
onready var X_But = $But / X

func _ready() -> void :
	call_init(SelfDev)
	call_deferred("_collision_check")

func _collision_check():
	var _parentName = get_parent().name
	if _parentName == "Devices":
		call_Collision_Switch(true)
	elif _parentName == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
func _TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):

	call_init(SelfDev)
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	self.position = _Info.pos
	IsItem = true
	if _Info.has("TYPE"):
		TYPE = _Info.TYPE
	call_TYPE()
func call_TYPE():
	var _ANI = $AniNode / TypeAni
	if _ANI.has_animation(str(TYPE)):
		_ANI.play(str(TYPE))
func call_Cooker_Logic():
	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _bool:
		if _Player.Con.IsHold:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		else:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	if get_parent().name == "Weapon_note" and _bool == false:
		_bool = true
		X_But.show()
		A_But.hide()
	else:
		X_But.hide()
		A_But.show()
	.But_Switch(_bool, _Player)

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func call_SQUEEZE_SPEED_puppet(_SPEED, _ANIPOS):
	return



func return_SQUEEZE_SPEED():
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()


	var _Mult: float = 1

	return _SPEED
func return_WORK_start(_Player, _Speed):
	var _x = get_parent().name
	if get_parent().name != "Weapon_note":

		return
	USEANI.play("init")
	USEANI.play("use")
	IsMixing = true
	MixPlayer = _Player


	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PlayerPath = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_start")
	return true

func call_puppet_STIR_start():

	pass
func call_STIR_end(_Player):

	if MixPlayer == _Player:
		MixPlayer = null

		IsMixing = false

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH, USEANI.current_animation_position, USEANI.playback_speed])
func call_puppet_STIR_end(_PATH, _TIME, _SPEED):
	var _Player = get_node(_PATH)
	if is_instance_valid(_Player):
		_Player.call_reset_stat_puppet()

	IsMixing = false


func call_Mix_end_puppet(_PATH):
	var _PLAYER = get_node(_PATH)

	if get_parent().name == "SavedNode":
		get_parent().get_parent().call_Cooked()
	But_Switch(false, _PLAYER)
func call_player_leave(_PLAYER):
	if MixPlayer == _PLAYER:
		call_STIR_end(MixPlayer)

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func call_use_end():
	if IsMixing:
		USEANI.play("init")
		USEANI.play("use")
		call_used()
func call_used():
	if is_instance_valid(MixPlayer):
		if not MixPlayer.HighPress:
			MixPlayer.call_pressure_set(1)
