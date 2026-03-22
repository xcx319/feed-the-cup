extends Head_Object
var SelfDev = "ReliefToy"

var MixPlayer
var IsMixing: bool

onready var USEANI = $AniNode / UseAni
onready var A_But = $But / A
onready var X_But = $But / X

onready var MixANI = $MixNode / MixAni
onready var FreshANI = $Effect_flies / Ani

var CanInList: Array = ["蛋卷白", "蛋卷黑"]

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
func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	self.position = _Info.pos

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
	if is_instance_valid(MixPlayer):
		if MixPlayer.BuffList.has("技能-手速"):
			_Mult += 1
		if MixPlayer.Stat.Skills.has("技能-熟练"):
			_Mult += 1
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult
		if not MixPlayer.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("工作手套"):
				_Mult += 1
			if GameLogic.cur_Rewards.has("工作手套+"):
				_Mult += 2
		if GameLogic.cur_Event == "手速":
			_Mult = 5

	if _Mult <= 0:
		_Mult = 1
	_SPEED = _SPEED * _Mult

	return _SPEED
func return_STIR_start(_Player):
	var _x = get_parent().name
	if get_parent().name != "Weapon_note":

		return


	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PlayerPath = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_start")
	return true

func call_puppet_STIR_start(_PlayerPath):

	var _Player = get_node(_PlayerPath)
	if is_instance_valid(_Player):
		MixPlayer = _Player
		_Player.Con.call_ArmState(GameLogic.NPC.STATE.STIR)
func call_STIR_end(_Player):

	if MixPlayer == _Player:
		MixPlayer = null

		IsMixing = false

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH, MixANI.current_animation_position, MixANI.playback_speed])
func call_puppet_STIR_end(_PATH, _TIME, _SPEED):
	var _Player = get_node(_PATH)
	if is_instance_valid(_Player):
		_Player.call_reset_stat_puppet()

	IsMixing = false

func _Mix_Finished():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PATH = MixPlayer.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix_end_puppet", [_PATH])

	But_Switch(false, MixPlayer)
	call_STIR_end(MixPlayer)

	MixANI.play("init")


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
