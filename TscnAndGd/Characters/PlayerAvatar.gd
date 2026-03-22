extends Node2D

var Show_bool: bool
var type = 0
var _speedscale
var input_vector setget _vector_change
enum {
	face_up,
	face_down,
	face_left,
	face_right
}

var FACE = face_down
var idleAni = "IdleDown"
onready var aniPlayer = get_node("BodyPose")
onready var ArmAni = get_node("ArmAct")
onready var body = get_parent().get_parent()
onready var Controller

onready var Stat
onready var Con
onready var WeaponNode = get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note")
onready var RightHandNode = $SpriteTex / Top_note / All_note / Body_note / BodyPose / Arm / Pose / RIGHT_Node
onready var PressureNode = get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Texturenode")
onready var IdleTimer = get_node("IdleTimer")
onready var CryAni = $SpriteTex / Top_note / All_note / Body_note / BodyPose / Body / HeadPose / Head / Effect_StaffHead / HeadEffect
onready var FaceAni = null
onready var BodyAni

var MoveBool: bool
var IdleBool: bool = true
var CleanTimes: int

var CURPLAYER: int
var CURAVATAR: int
var MOVECOUNT: int
var MOVENUM: int
var MOVESTANCE: float = 0
var MOVESAVE: Vector2 = Vector2.ZERO
func call_Pressure_Tex():
	PressureNode.call_texture_init()

func call_Act_End():
	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		_rand_idle_ani(false)
	call_Ani()
func call_FootPrint_puppet(_PRINTNUM, _POS, _NAME, _ROT, _COLOR, _PRINT, _CHECKINT: int = 0):
	var _FootPrint_TSCN = GameLogic.TSCNLoad.FootPrintEffect_TSCN.instance()
	_FootPrint_TSCN.position = _POS
	_FootPrint_TSCN.name = _NAME
	_FootPrint_TSCN.rotation = _ROT
	_FootPrint_TSCN._CHECKINT = _CHECKINT

	if get_tree().get_root().has_node("Home"):
		get_tree().get_root().get_node("Home/YSort/Items").add_child(_FootPrint_TSCN)
	else:
		GameLogic.Staff.LevelNode.Ysort_Update.add_child(_FootPrint_TSCN)

	_FootPrint_TSCN.WaterColor = _COLOR
	_FootPrint_TSCN.Concentration = _PRINT
	body.FootPrint = _PRINTNUM
	body.call_FootPrint_Logic()

func _FootPrint_Logic():
	if not body.has_method("_PlayerNode"):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _CHECK = body.FootPrint
	if body.FootPrint > 0:
		var _FootPrint_TSCN = GameLogic.TSCNLoad.FootPrintEffect_TSCN.instance()
		var _POS = self.global_position
		var _NAME = str(_FootPrint_TSCN.get_instance_id())
		_FootPrint_TSCN.position = _POS
		_FootPrint_TSCN.name = _NAME
		match FACE:
			face_up:
				_FootPrint_TSCN.rotation = 0
			face_down:
				_FootPrint_TSCN.rotation = 180
			face_left:
				_FootPrint_TSCN.rotation = - 90
			face_right:
				_FootPrint_TSCN.rotation = 90

		if Stat.Skills.has("技能-史莱姆基础"):
			_FootPrint_TSCN.TYPE = 1

		if get_tree().get_root().has_node("Home"):

			get_tree().get_root().get_node("Home/YSort/Items").add_child(_FootPrint_TSCN)
		else:
			GameLogic.Staff.LevelNode.Ysort_Update.add_child(_FootPrint_TSCN)
		var _ROT = _FootPrint_TSCN.rotation
		var _COLOR = body.FootWaterColor
		var _PRINT = body.FootPrint
		_FootPrint_TSCN.WaterColor = body.FootWaterColor
		if Stat.Skills.has("技能-史莱姆基础"):
			_FootPrint_TSCN.Concentration = body.FootPrint
		else:
			_FootPrint_TSCN.Concentration = body.FootPrint
		body.FootPrint -= 1
		body.call_FootPrint_Logic()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_FootPrint_puppet", [body.FootPrint, _POS, _NAME, _ROT, _COLOR, _PRINT])

func call_StepOn():
	if body.has_method("call_StepOn"):
		if Stat.Skills.has("技能-史莱姆基础"):
			body.call_StepOn(1)
		else:
			body.call_StepOn(0)
func call_Audio_Move():
	if IdleBool:
		IdleBool = false
	else:
		_Audio_Play()
	_FootPrint_Logic()
func call_Audio_Left():

	if MoveBool:
		MoveBool = false
		_Audio_Play()
	_FootPrint_Logic()
	call_StepOn()
func call_Audio_Right():

	MoveBool = true
	_Audio_Play()
	_FootPrint_Logic()
	call_StepOn()
	call_MOVE_Logic()

func call_MOVE_Logic():
	if not GameLogic.LoadingUI.IsLevel:
		return
	if body.get("IsCourier"):
		return
	if GameLogic.GameUI.CurTime >= GameLogic.GameUI.cur_OverTime:
		return
	MOVENUM += 2
	if MOVESAVE == Vector2.ZERO:
		MOVESAVE = self.global_position
	if MOVESAVE != self.global_position:
		var _x = MOVESAVE.distance_to(self.global_position)
		MOVESAVE = self.global_position
		MOVESTANCE += _x

	var _CHECK: bool
	if not body.Stat.Skills.has("技能-幽灵基础"):
		if GameLogic.cur_Rewards.has("运动手表"):
			if MOVENUM >= 30 and MOVESTANCE >= 3000:
				_CHECK = true
		elif GameLogic.cur_Rewards.has("运动手表+"):
			if MOVENUM >= 10 and MOVESTANCE >= 1000:
				_CHECK = true
	if _CHECK:

		MOVENUM = 0
		MOVESTANCE = 0
		MOVECOUNT += 1
		var _STANCE: int = 0
		var _MAXPRICE: int = 5
		if MOVECOUNT >= 100:
			MOVECOUNT = 100
		if _MAXPRICE > 0:
			match SteamLogic.PlayerNum:
				1:
					_STANCE = _MAXPRICE * 4
				2:
					_STANCE = _MAXPRICE * 3
				3:
					_STANCE = _MAXPRICE * 2
				4:
					_STANCE = _MAXPRICE * 1
			if _STANCE > 0:
				if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
					_STANCE = int(float(_STANCE) * 1.5)
				call_Money(_STANCE)
func call_Money(_MONEY: int):
	GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = self.global_position
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)

func call_Audio_Idle():
	call_StepOn()
	call_IdleTimer()
	if not IdleBool:
		IdleBool = true
		MoveBool = false
		_Audio_Play()
func _Audio_Play():
	if not self.visible:
		return
	if NPCTYPE > 0:
		return
	var _Audio = GameLogic.Audio.return_FootSteps(self.global_position)

	if body.has_method("_PlayerNode"):

		if Stat.Skills.has("技能-幽灵基础"):
			return
		if Stat.Skills.has("技能-史莱姆基础"):
			var _AUDIO = GameLogic.Audio.return_RandEffect("气泡")
			_AUDIO.play(0)
			return
	if _Audio:
		_Audio.play(0)

func call_HeadType(_Type: String):
	if not has_node("HeadType"):
		printerr("角色HeadType无相关node")
		return
	if get_node("HeadType").has_animation(_Type):
		get_node("HeadType").play(_Type)

func _ready() -> void :

	if not IdleTimer.is_connected("timeout", self, "_on_IdleTimer_timeout"):
		IdleTimer.connect("timeout", self, "_on_IdleTimer_timeout")
	if not GameLogic.is_connected("EQUIPCHANGE", self, "call_EquipInit"):
		var _CON = GameLogic.connect("EQUIPCHANGE", self, "call_EquipInit")


	call_EquipInit()
	if get_parent().name == "C":
		return

	set_process(false)
	set_physics_process(false)
	call_deferred("start")
	if has_node("FaceAni"):
		FaceAni = get_node("FaceAni")
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/BodyAni"):
		BodyAni = get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/BodyAni")
	if body.has_method("call_pressure_set"):
		PressureNode = get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Texturenode")

	body = get_parent().get_parent()
	if body.has_method("call_StatChange"):
		if not body.is_connected("StatChange", self, "call_Stat_Change"):
			body.connect("StatChange", self, "call_Stat_Change")
	if body.has_node("LogicNode"):
		Controller = body.get_node("LogicNode/Control")
		Stat = body.get_node("LogicNode/Stat")
		Con = body.get_node("LogicNode/Control")
	if body.has_method("_PlayerNode"):
		var _CON = GameLogic.connect("Reward", self, "_UpdateCheck")
	if body.name == "Scroll":
		aniPlayer.play("StandDown")
	call_deferred("_UpdateCheck")
	_HeadType_Init()

func call_Stat_Change():
	call_Ani()
func _HeadType_Init():
	if not body.has_method("_PlayerNode"):
		if NPCTYPE == 1:
			call_HeadType(str(1))
			return
		var _Rand = GameLogic.return_RANDOM() % 4 + 1
		call_HeadType(str(_Rand))
		return
	if SteamLogic.IsMultiplay:
		if str(SteamLogic.SLOT) == body.name:
			call_HeadType("1")
		elif str(SteamLogic.SLOT_2) == body.name:
			call_HeadType("2")
		elif str(SteamLogic.SLOT_3) == body.name:
			call_HeadType("3")
		elif str(SteamLogic.SLOT_4) == body.name:
			call_HeadType("4")
	else:
		if body.get("cur_Player") == 2:
			call_HeadType("2")
		else:
			call_HeadType("1")
func start():
	call_Ani()

func call_personality_init(_id):
	var PersonalityAni = get_node("AniNode/PersonalityAni")
	PersonalityAni.play(str(_id))

func _vector_change(_VECTOR):
	input_vector = _VECTOR

	call_Ani()

func _on_Ani_F(_Ani_Name):
	call_Ani()
func call_Ani():
	if not Controller:
		return
	_face_logic()
	_ArmState_ani()
	call_Ani_Logic()

func call_Ani_Logic():
	if name in ["Avatar"]:
		if get_parent().name in ["Player"]:

			get_parent().position = Vector2.ZERO

			pass

	if not Con:

		return
	if not body.has_method("_PlayerNode"):


		match Con.state:
			GameLogic.NPC.STATE.SMASH:
				pass
			GameLogic.NPC.STATE.IDLE_ANI_1:
				_IDLEANI_ani(1)

			GameLogic.NPC.STATE.MOVE:

				_move_ani()
			GameLogic.NPC.STATE.IDLE_EMPTY:

				_idle_ani()
			GameLogic.NPC.STATE.WORK:
				_work_ani()
			GameLogic.NPC.STATE.SHOW:
				_show_ani()
			GameLogic.NPC.STATE.DISABLE:
				aniPlayer.stop(true)
			GameLogic.NPC.STATE.STIR:

				_stir_ani()
		return

	match Con.ArmState:
		GameLogic.NPC.STATE.IDLE_EMPTY, null:
			if not Con.state in [GameLogic.NPC.STATE.RUBBING,
			GameLogic.NPC.STATE.DUMPING,
			GameLogic.NPC.STATE.EATTING,
			GameLogic.NPC.STATE.CUTE]:
				_Arm_idle_ani()
		GameLogic.NPC.STATE.SMASH:
			_Smash_ani()
		GameLogic.NPC.STATE.IDLE_ACT:
			_Act_ani()
		GameLogic.NPC.STATE.WORK:
			_work_ani()
		GameLogic.NPC.STATE.ORDER:
			_order_ani()
		GameLogic.NPC.STATE.STIR:

			_stir_ani()
		GameLogic.NPC.STATE.SQUEEZE:
			_squeeze_ani(Con.SQUEEZESPEED)
		GameLogic.NPC.STATE.SHAKE:

			_shake_ani()
		GameLogic.NPC.STATE.DEAD:

			pass

	match Con.state:
		GameLogic.NPC.STATE.IDLE_ANI_1:
			pass
		GameLogic.NPC.STATE.IDLE_ANI_2:
			pass
		GameLogic.NPC.STATE.IDLE_ANI_3:
			pass
		GameLogic.NPC.STATE.IDLE_ANI_4:
			pass
		GameLogic.NPC.STATE.SITUP:
			call_SitUp_ani()
		GameLogic.NPC.STATE.SITDOWN:
			call_SitDown_ani()
		GameLogic.NPC.STATE.SITLEFT:
			call_SitLeft_ani()
		GameLogic.NPC.STATE.SITRIGHT:
			call_SitRight_ani()
		GameLogic.NPC.STATE.SIT:
			call_Sit_ani()
		GameLogic.NPC.STATE.CUTE:
			call_Cute_ani()
		GameLogic.NPC.STATE.FALLDOWN:
			_falldown_ani()
		GameLogic.NPC.STATE.DUMPING:
			call_Dumping_ani()
		GameLogic.NPC.STATE.EATTING:
			call_Eatting_ani()
		GameLogic.NPC.STATE.RUBBING:
			call_Rubbing_ani()
		GameLogic.NPC.STATE.MOVE:

			_move_ani()
		GameLogic.NPC.STATE.IDLE_EMPTY:

			_idle_ani()
		GameLogic.NPC.STATE.IDLE_ACT:
			_Act_ani()

		GameLogic.NPC.STATE.SHOW:
			_show_ani()
		GameLogic.NPC.STATE.DISABLE:
			aniPlayer.stop(true)

		GameLogic.NPC.STATE.DEAD:

			aniPlayer.playback_speed = 1
			FaceAni.play("down")
			ArmAni.play("init")

			if not aniPlayer.assigned_animation in ["Deading"]:
				aniPlayer.play("Dead")






func _show_ani():
	aniPlayer.play("WaveDown")

func _work_ani():

	var _speed: float
	if body.IsStaff:
		match body.behavior:
			body.BEHAVIOR.ORDER:
				_speed = float(body.Lv_Order) / 4 + 0.5
			_:
				_speed = 1.0

	aniPlayer.playback_speed = _speed
	match FACE:
		face_up:
			ArmAni.play("WorkUp")
		face_down:
			var _NodeList = WeaponNode.get_children()
			if _NodeList.size():
				var _Dev = _NodeList[0]
				if _Dev.TypeStr == "Mop":
					ArmAni.play("WorkDown_Mop")
					WeaponNode.modulate = Color(1, 1, 1, 0)

				else:
					ArmAni.play("WorkDown")
			else:
				ArmAni.play("WorkDown")
		face_left:
			ArmAni.play("WorkLeft")
		face_right:
			ArmAni.play("WorkRight")
	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		_rand_idle_ani(false)
func _face_logic():

	input_vector = Con.input_vector



	if input_vector != Vector2.ZERO:
		if input_vector.y < 0 and abs(input_vector.y) > abs(input_vector.x):
			match FACE:
				face_left:
					if abs(input_vector.y) > abs(input_vector.x - 0.2):
						FACE = face_up
				face_right:
					if abs(input_vector.y) > abs(input_vector.x + 0.2):
						FACE = face_up
				_:
					FACE = face_up
		elif input_vector.y > 0 and abs(input_vector.y) > abs(input_vector.x):
			match FACE:
				face_left:
					if abs(input_vector.y) > abs(input_vector.x - 0.2):
						FACE = face_down
				face_right:
					if abs(input_vector.y) > abs(input_vector.x + 0.2):
						FACE = face_down
				_:
					FACE = face_down
		elif input_vector.x < 0:
			FACE = face_left
		elif input_vector.x > 0:
			FACE = face_right
		match FACE:
			face_up:
				FaceAni.play("up")
			face_down:
				FaceAni.play("down")
			face_left:
				FaceAni.play("left")
			face_right:
				FaceAni.play("right")
	else:
		match FACE:
			face_up:
				FaceAni.play("up")
			face_down:
				FaceAni.play("down")
			face_left:
				FaceAni.play("left")
			face_right:
				FaceAni.play("right")
func _ArmState_ani():

	match FACE:
		face_down:
			if Controller.get("IsMixing"):
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeDown")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirDown")
			else:
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeDown")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirDown")
					GameLogic.NPC.STATE.SHOVEL:
						ArmAni.play("ShovelDown")
					GameLogic.NPC.STATE.WORK:
						var _NodeList = WeaponNode.get_children()
						if _NodeList.size():
							var _Dev = _NodeList[0]
							if _Dev.TypeStr == "Mop":
								ArmAni.play("WorkDown_Mop")
								WeaponNode.modulate = Color(1, 1, 1, 0)
							else:
								ArmAni.play("WorkDown")
						else:
							ArmAni.play("WorkDown")
					GameLogic.NPC.STATE.SQUEEZE:
						ArmAni.play("SqueezeDown")
					_:
						if Controller.IsHold:
							if Controller.NeedPush:
								ArmAni.play("PushDown")
							else:
								ArmAni.play("HoldDown")
						else:
							ArmAni.play("EmptyDown")
		face_left:
			if Controller.get("IsMixing"):
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeLeft")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirLeft")
			else:
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeLeft")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirLeft")
					GameLogic.NPC.STATE.WORK:
						ArmAni.play("WorkLeft")
					GameLogic.NPC.STATE.SHOVEL:
						ArmAni.play("ShovelLeft")
					GameLogic.NPC.STATE.SQUEEZE:
						ArmAni.play("SqueezeLeft")
					_:
						if Controller.IsHold:
							if Controller.NeedPush:
								ArmAni.play("PushLeft")
							else:
								ArmAni.play("HoldLeft")
						else:
							ArmAni.play("EmptyLeft")
		face_up:
			if Controller.get("IsMixing"):
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeUp")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirUp")
			else:
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeUp")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirUp")
					GameLogic.NPC.STATE.SHOVEL:
						ArmAni.play("ShovelUp")
					GameLogic.NPC.STATE.WORK:
						ArmAni.play("WorkUp")
					GameLogic.NPC.STATE.SQUEEZE:
						ArmAni.play("SqueezeUp")
					_:
						if Controller.IsHold:
							if Controller.NeedPush:

								ArmAni.play("PushUp")
							else:

								ArmAni.play("HoldUp")
						else:
							ArmAni.play("EmptyUp")
		face_right:
			if Controller.get("IsMixing"):
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeRight")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirRight")
			else:
				match Controller.get("ArmState"):
					GameLogic.NPC.STATE.SHAKE:
						ArmAni.play("ShakeRight")
					GameLogic.NPC.STATE.STIR:
						ArmAni.play("StirRight")
					GameLogic.NPC.STATE.SHOVEL:
						ArmAni.play("ShovelRight")
					GameLogic.NPC.STATE.WORK:
						ArmAni.play("WorkRight")
					GameLogic.NPC.STATE.SQUEEZE:
						ArmAni.play("SqueezeRight")
					_:
						if Controller.IsHold:
							if Controller.NeedPush:
								ArmAni.play("PushRight")
							else:
								ArmAni.play("HoldRight")
						else:
							ArmAni.play("EmptyRight")

	_HoldLogic()
func _HoldLogic():
	WeaponNode.modulate = Color(1, 1, 1, 1)
	var _NodeList = WeaponNode.get_children()
	if _NodeList.size():
		var _Dev = _NodeList[0]
		if _Dev.get("TypeStr") == "Mop":
			match ArmAni.assigned_animation:
				"HoldLeft", "WorkLeft":
					_Dev.Face = face_left
					_Dev.position.x = 15
					_Dev.position.y = 20
					if ArmAni.assigned_animation == "WorkLeft":
						_Dev.call_used_face()

				"HoldRight", "WorkRight":
					_Dev.Face = face_right
					_Dev.position.x = - 15
					_Dev.position.y = 25
					if ArmAni.assigned_animation == "WorkRight":
						_Dev.call_used_face()

				"HoldUp", "WorkUp":
					_Dev.Face = face_up
					_Dev.position.x = 0
					_Dev.position.y = 25
					if ArmAni.assigned_animation == "WorkUp":
						_Dev.call_used_face()

				"WorkDown_Mop":
					_Dev.Face = face_down

					_Dev.position.x = 0
					_Dev.position.y = 25
					$SpriteTex / Top_note / All_note / StaffMop.position.y = 25
					WeaponNode.modulate = Color(1, 1, 1, 0)
					_Dev.call_used_face()

				"HoldDown":
					_Dev.Face = face_down
					_Dev.position.x = 0
					_Dev.position.y = 20

func _move_ani():

	if aniPlayer.playback_speed != _return_ani_speed():
		aniPlayer.playback_speed = _speedscale
	if NPCTYPE == 1:
		aniPlayer.playback_speed = 0.8
	if Stat.IsSlip and Con.input_vector == Vector2.ZERO:
		aniPlayer.stop(false)
	else:
		match FACE:
			face_up:
				aniPlayer.play("RunUp")
			face_down:
				aniPlayer.play("RunDown")
			face_left:
				aniPlayer.play("RunLeft")
			face_right:
				aniPlayer.play("RunRight")
	IdleTimer.stop()

func _return_ani_speed():


	var velocity = Con.velocity

	var _Mult: float = (float(Stat.Ins_MAXSPEED) / 350)
	var _x = abs(velocity.x / Stat.Ins_MAXSPEED)
	var _y = abs(velocity.y / Stat.Ins_MAXSPEED)

	if _x >= _y:
		_speedscale = float(int(_x * 100)) / 100 * _Mult
	else:
		_speedscale = float(int(_y * 100)) / 100 * _Mult
	if _speedscale == 0:
		_speedscale = 1
	var _check = Vector2(_x, _y)
	_check = _check.normalized()

	return _speedscale
func _shake_ani():
	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		_rand_idle_ani(false)
	aniPlayer.playback_speed = 1
	match FACE:
		face_up:
			ArmAni.play("ShakeUp")
		face_down:
			ArmAni.play("ShakeDown")
		face_left:
			ArmAni.play("ShakeLeft")
		face_right:
			ArmAni.play("ShakeRight")
	call_IdleTimer()
func _IDLEANI_ani(_TYPE: int):
	Con.IDLE_TYPE = 0

func _Smash_ani():


	var _speed: float = 1.0

	aniPlayer.playback_speed = _speed
	match FACE:
		face_up:
			ArmAni.play("WorkUp")
			aniPlayer.play("StandUp")
		face_down:
			ArmAni.play("WorkDown")
			aniPlayer.play("StandDown")
		face_left:
			ArmAni.play("WorkLeft")
			aniPlayer.play("StandLeft")
		face_right:
			ArmAni.play("WorkRight")
			aniPlayer.play("StandRight")
	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		_rand_idle_ani(false)
func _falldown_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("FallDown"):
		if aniPlayer.assigned_animation != "FallDown":

			FACE = face_down
			FaceAni.play("down")
			ArmAni.play("EmptyDown")
			aniPlayer.play("FallDown")

func call_IDLEANI_end():
	Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
	Con.IDLE_TYPE = 0
func call_falldown_end():
	Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
	Con.CanControl = true
	Con.call_return_fall()
func call_Smash_end():
	Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
	Con.CanControl = true
func call_Dumping_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("Dumping"):
		aniPlayer.play("Dumping")

		FaceAni.play("down")
func call_Cute_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("Greeting"):
		FaceAni.play("down")

		aniPlayer.play("Greeting")
		$Panda_Flower / EffectAni.play("play")
func call_SitUp_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("SitUp"):
		FaceAni.play("up")
		ArmAni.play("EmptyUp")
		aniPlayer.play("SitUp")
func call_SitDown_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("SitDown"):
		FaceAni.play("down")
		ArmAni.play("EmptyDown")
		aniPlayer.play("SitDown")
func call_SitLeft_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("SitLeft"):
		FaceAni.play("left")
		ArmAni.play("EmptyLeft")
		aniPlayer.play("SitLeft")

func call_SitRight_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("SitRight"):
		FaceAni.play("right")
		ArmAni.play("EmptyRight")
		aniPlayer.play("SitRight")

func call_Sit_ani():
	aniPlayer.playback_speed = 1
	match FACE:
		face_up:

			aniPlayer.play("SitUp")
		face_down:
			aniPlayer.play("SitDown")
		face_left:
			aniPlayer.play("SitLeft")
		face_right:
			aniPlayer.play("SitRight")

func call_Eatting_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("Eat_Push"):
		aniPlayer.play("Eat_Push")

		FaceAni.play("down")

func call_Rubbing_ani():
	aniPlayer.playback_speed = 1
	if aniPlayer.has_animation("Rubbing"):
		aniPlayer.play("Rubbing")

		FaceAni.play("down")
func _stir_ani():
	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		_rand_idle_ani(false)
	aniPlayer.playback_speed = 1
	match FACE:
		face_up:
			ArmAni.play("StirUp")
		face_down:
			ArmAni.play("StirDown")
		face_left:
			ArmAni.play("StirLeft")
		face_right:
			ArmAni.play("StirRight")
	call_IdleTimer()
func call_squeeze_end():
	pass
func _squeeze_ani(_SPEEDMULT: float):

	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		_rand_idle_ani(false)

	var _SPEED: float = 1

	aniPlayer.playback_speed = _SPEEDMULT
	match FACE:
		face_up:
			ArmAni.play("SqueezeUp")
		face_down:
			ArmAni.play("SqueezeDown")
		face_left:
			ArmAni.play("SqueezeLeft")
		face_right:
			ArmAni.play("SqueezeRight")

func _order_ani():
	aniPlayer.playback_speed = 1
	match FACE:
		face_up:
			ArmAni.play("OrderUp")
		face_down:
			ArmAni.play("OrderDown")
		face_left:
			ArmAni.play("OrderLeft")
		face_right:
			ArmAni.play("OrderRight")
	call_IdleTimer()
	call_Order_Audio()

func call_Order_Audio():
	var _AUDIO_1 = GameLogic.Audio.return_Effect("敲键盘2")
	var _AUDIO_2 = GameLogic.Audio.return_Effect("敲键盘3")
	var _AUDIO_3 = GameLogic.Audio.return_Effect("敲键盘4")
	if not _AUDIO_1.is_playing():
		if not _AUDIO_2.is_playing():
			if not _AUDIO_3.is_playing():
				var _rand = GameLogic.return_RANDOM() % 3
				match _rand:
					0:
						_AUDIO_1.play(0)
					1:
						_AUDIO_2.play(0)
					2:
						_AUDIO_3.play(0)
func _Act_ani():

	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		return
	aniPlayer.playback_speed = 1
	match ArmAni.assigned_animation:
		"HoldLeft", "HoldRight", "HoldUp":
			ArmAni.play("HoldDown")
			_HoldLogic()
		"PushLeft", "PushRight", "PushUp":
			ArmAni.play("PushDown")
		"EmptyLeft", "EmptyRight", "EmptyUp":
			ArmAni.play("EmptyDown")
	FaceAni.play("down")
	var _Rand = GameLogic.return_RANDOM() % 3
	match _Rand:
		0:
			aniPlayer.play("IdleAct1")
		1:
			aniPlayer.play("IdleAct2")
		2:
			aniPlayer.play("IdleAct3")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if body.has_method("_PlayerNode"):
		var _Pressure: int = 0

		if GameLogic.LoadingUI.IsLevel and not GameLogic.LoadingUI.Is_Loading:
			if body.Stat.Skills.has("技能-发呆"):
				if GameLogic.GameUI.CurTime >= GameLogic.GameUI.cur_OverTime:
					return

				var _rand = GameLogic.return_randi() % 2
				if _rand:
					_Pressure -= 1
			if not body.Stat.Skills.has("技能-幽灵基础"):
				if GameLogic.cur_Rewards.has("冥思"):
					if GameLogic.GameUI.CurTime < GameLogic.GameUI.cur_OverTime:
						var _rand = GameLogic.return_randi() % 2
						if _rand:
							GameLogic.call_Info(1, "冥思")
							_Pressure -= 1
				if GameLogic.cur_Rewards.has("冥思+"):
					if GameLogic.GameUI.CurTime < GameLogic.GameUI.cur_OverTime:
						var _rand = GameLogic.return_randi() % 2
						if _rand:
							GameLogic.call_Info(1, "冥思+")
							_Pressure -= 3
		if GameLogic.cur_Challenge.has("多动症") and GameLogic.LoadingUI.IsLevel and not GameLogic.LoadingUI.Is_Loading:
			if not GameLogic.GameUI.Is_Open or GameLogic.GameUI.CurTime >= GameLogic.GameUI.cur_OverTime:
				pass
			else:
				GameLogic.call_Info(2, "多动症")
				_Pressure += 1
		if GameLogic.cur_Challenge.has("多动症+") and GameLogic.LoadingUI.IsLevel and not GameLogic.LoadingUI.Is_Loading:
			if not GameLogic.GameUI.Is_Open or GameLogic.GameUI.CurTime >= GameLogic.GameUI.cur_OverTime:
				pass
			else:
				GameLogic.call_Info(2, "多动症+")
				_Pressure += 2
		if _Pressure != 0:
			body.call_pressure_set(_Pressure)
func _Arm_idle_ani():

	if aniPlayer.current_animation in ["IdleAct1", "IdleAct2", "IdleAct3", "Rubbing", "Dumping", "Eat_Hold", "Eat_Push", "Sale"]:
		return
	aniPlayer.playback_speed = 1

func _idle_ani():
	aniPlayer.playback_speed = 1
	match FACE:
		face_down:
			aniPlayer.play("StandDown")
		face_left:
			aniPlayer.play("StandLeft")
		face_up:
			aniPlayer.play("StandUp")
		face_right:
			aniPlayer.play("StandRight")

func _Control_Ani(_type):
	if type != _type:
		type = _type

func _rand_idle_ani(_OnlyIdle: bool):
	if not Con:
		return
	if _OnlyIdle:

		if self.has_method("call_HeadType"):
			if Con.state == GameLogic.NPC.STATE.IDLE_EMPTY and Con.ArmState in [GameLogic.NPC.STATE.IDLE_EMPTY]:
				Con.state = GameLogic.NPC.STATE.IDLE_ACT
	elif Con.state == GameLogic.NPC.STATE.IDLE_ACT:

		Con.state = GameLogic.NPC.STATE.IDLE_EMPTY

func call_Run_Start():
	var _TYPE: int
	if SteamLogic.IsMultiplay:
		if SteamLogic.SLOT == body.cur_Player:
			_TYPE = 1
		elif SteamLogic.SLOT_2 == body.cur_Player:
			_TYPE = 2
		elif SteamLogic.SLOT_3 == body.cur_Player:
			_TYPE = 3
		elif SteamLogic.SLOT_4 == body.cur_Player:
			_TYPE = 4
	else:
		if body.cur_Player == 2:
			_TYPE = 2
		else:
			_TYPE = 1
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_Running(_TYPE)
func call_Run_End():
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_Running_end()

func call_EquipInit(_INFO: Dictionary = {}):
	var _HEADID: int
	var _BODYID: int
	var _FACEID: int
	var _FOOTID: int
	var _HANDID: int
	var _ACCLIST: Array
	if _INFO.size():
		_HEADID = int(_INFO.Head)
		_BODYID = int(_INFO.Body)
		_FACEID = int(_INFO.Face)
		_FOOTID = int(_INFO.Foot)
		_HANDID = int(_INFO.Hand)
		_ACCLIST = [int(_INFO.Accessory_1), int(_INFO.Accessory_2), int(_INFO.Accessory_3)]

	var _PLAYERID = CURPLAYER
	var _AVATARID = CURAVATAR
	if body.has_method("_PlayerNode"):
		_PLAYERID = int(body.cur_Player)
		_AVATARID = body.cur_ID
	if _PLAYERID == SteamLogic.STEAM_ID:
		_PLAYERID = 1
	if not _PLAYERID in [1, 2] and not _INFO.size():
		return
	if _PLAYERID in [1, 2]:
		if not GameLogic.Save.gameData["EquipDic"].has(_PLAYERID):
			GameLogic.Save.gameData["EquipDic"].clear()
			GameLogic.Save.gameData["EquipDic"] = {1: {}, 2: {}}
		if not GameLogic.Save.gameData["EquipDic"][_PLAYERID].has(_AVATARID):
			GameLogic.Save.gameData["EquipDic"][_PLAYERID][_AVATARID] = {
				"Head": 0,
				"Body": 0,
				"Hand": 0,
				"Face": 0,
				"Foot": 0,
				"Accessory_1": 0,
				"Accessory_2": 0,
				"Accessory_3": 0
			}

	if _PLAYERID == 1 and SteamLogic.IsMultiplay and not _INFO.size():
		var _FashionDic: Dictionary = GameLogic.Save.gameData["EquipDic"][1][_AVATARID]
		SteamLogic.call_everybody_node_sync(self, "call_EquipInit", [_FashionDic])

	if has_node("SpriteTex/Top_note/All_note/Leg_L/Shoe"):
		get_node("SpriteTex/Top_note/All_note/Leg_L/Shoe").call_EquipFoot(_PLAYERID, _AVATARID, _FOOTID)
	if has_node("SpriteTex/Top_note/All_note/Leg_R/Shoe"):
		get_node("SpriteTex/Top_note/All_note/Leg_R/Shoe").call_EquipFoot(_PLAYERID, _AVATARID, _FOOTID)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_EquipHand(_PLAYERID, _AVATARID, _HANDID)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_EquipBody(_PLAYERID, _AVATARID, _BODYID)
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_EquipAccessory(_PLAYERID, _AVATARID, _ACCLIST)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask").call_EquipFace(_PLAYERID, _AVATARID, _FACEID)
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask").call_EquipAccessory(_PLAYERID, _AVATARID, _ACCLIST)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_EquipHead(_PLAYERID, _AVATARID, _HEADID)
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_EquipAccessory(_PLAYERID, _AVATARID, _ACCLIST)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker").call_EquipInit(_PLAYERID, _AVATARID, _INFO)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_EquipHand(_PLAYERID, _AVATARID, _HANDID)
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffWatch"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffWatch").call_EquipAccessory(_PLAYERID, _AVATARID, _ACCLIST)

func call_Overseer():
	if has_node("SpriteTex/Top_note/All_note/Leg_L/Shoe"):
		$SpriteTex / Top_note / All_note / Leg_L / Shoe.call_show()
	if has_node("SpriteTex/Top_note/All_note/Leg_R/Shoe"):
		$SpriteTex / Top_note / All_note / Leg_R / Shoe.call_show()
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_Overseek()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Overseek()
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_Overseek()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffWatch").call_show()

	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Mask(true)

func _UpdateCheck():
	if body.name == "Scroll":
		var _RAND_SHOE = GameLogic.return_RANDOM()
		if has_node("SpriteTex/Top_note/All_note/Leg_L/Shoe"):
			$SpriteTex / Top_note / All_note / Leg_L / Shoe.call_Devil(_RAND_SHOE)
		if has_node("SpriteTex/Top_note/All_note/Leg_R/Shoe"):
			$SpriteTex / Top_note / All_note / Leg_R / Shoe.call_Devil(_RAND_SHOE)

		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_Devil(GameLogic.return_RANDOM())
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask").call_Devil(GameLogic.return_RANDOM())
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Devil(GameLogic.return_RANDOM())
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker").call_Devil(GameLogic.return_RANDOM())
		var _RAND_Clove = GameLogic.return_RANDOM()
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_Devil(_RAND_Clove)
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_Devil(_RAND_Clove)
		return
	if not body.has_method("_PlayerNode"):

		return
	if is_instance_valid(Stat):
		if Stat.Skills.has("技能-幽灵基础"):
			get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_show()
			get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask").call_show()

			get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_show()
			get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Mask(body._Pressure_1_Bool)
			if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker"):
				get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker").call_show()
			return

	if has_node("SpriteTex/Top_note/All_note/Leg_L/Shoe"):
		$SpriteTex / Top_note / All_note / Leg_L / Shoe.call_show()
	if has_node("SpriteTex/Top_note/All_note/Leg_R/Shoe"):
		$SpriteTex / Top_note / All_note / Leg_R / Shoe.call_show()
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffClove").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/StaffApron").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffMask").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_show()
	if has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker"):
		get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/StaffSpeaker").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/StaffClove").call_show()
	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/StaffWatch").call_show()

	get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Staffhat").call_Mask(body._Pressure_1_Bool)
func call_IdleTimer():

	IdleTimer.start()
func _on_IdleTimer_timeout():

	_rand_idle_ani(true)
func call_DeadAni_End():
	aniPlayer.play("Deading")

	if GameLogic.LoadingUI.IsLevel:
		GameLogic.call_dead_logic()
export var NPCTYPE: int = 0
func _on_Area2D_area_entered(area):

	var CLEANPOWER: float = 3
	if NPCTYPE == 1:
		CLEANPOWER = 10
	area.call_clean(true, self, CLEANPOWER)

func _on_Area2D_area_exited(area):

	var CLEANPOWER: float = 3
	if NPCTYPE == 1:
		CLEANPOWER = 10
	area.call_clean(false, self, CLEANPOWER)

func call_clean_logic():
	if Stat.Skills.has("技能-拖地减压"):
		if GameLogic.GameUI.CurTime >= GameLogic.GameUI.cur_OverTime:
			return
		CleanTimes += 1
		_Satiety += 1
		if CleanTimes >= 10:
			CleanTimes = 0
			body.call_pressure_set( - 1)

var _Satiety: int = 0

func call_Eating():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if WeaponNode.get_children():
		var _NODE = WeaponNode.get_child(0)
		var _Weight: int = _NODE.get("Weight")
		_Satiety += _Weight


		if is_instance_valid(_NODE):
			if _NODE.has_method("call_del"):
				_NODE.call_del()
			else:
				_NODE.queue_free()

			body.Stat.call_carry_off()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Eating_puppet")
			call_EatLogic()

func call_Eating_puppet():
	if WeaponNode.get_children():
		var _NODE = WeaponNode.get_child(0)
		if is_instance_valid(_NODE):
			_NODE.queue_free()
			body.Stat.call_carry_off()
func call_EatLogic():
	if Stat.Skills.has("技能-补充"):
		if _Satiety >= 10:
			if not body.BuffList.has("补充"):
				_Satiety -= 10
				body.BuffList.append("补充")
				var _BUFF = GameLogic.TSCNLoad.SpeedEffect_TSCN.instance()
				body.AvatarNode.add_child(_BUFF)

				_BUFF.call_init("补充", 1, 10)
				body.Stat.Update_Check()

				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_EatLogic_puppet")

func call_EatLogic_puppet():
	body.BuffList.append("补充")
	var _BUFF = GameLogic.TSCNLoad.SpeedEffect_TSCN.instance()
	body.AvatarNode.add_child(_BUFF)
	_BUFF.call_init("补充", 1, 10)
	body.Stat.Update_Check()
