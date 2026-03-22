extends Node
class_name Statistics

var IsNPC: bool

var TSCN
var Pressure: int
var BaseSpeed: int = 30
var MoveSpeed: float = 30
var AcrossMult: float = 0.5
var CarryMult: float = 0.5
var CleanLV: int = 3
var OrderLV: int = 3
var CommunicateLV: int = 3
var FixLV: int = 3
var HandWorkLV: int = 3
var MachineWorkLV: int = 3
var KnifeWorkLV: int = 3

var Cur_ROLLMULTI: float = 7

var Ins_BASESPEED: float
var Ins_MAXSPEED = 200
var Ins_ACCELERATION = null
var Ins_FRICTION = 0
var Ins_ROLL_SPEED = null
var Ins_ROLL_FRICTION = null

var Ins_AcrossMult: float = 1
var Ins_CarryMult: float = 1
var Ins_SpeedMult: float = 1
var Ins_ChallengeMult: float = 1
var Ins_Skill_1_Mult: float = 1
var Ins_Skill_2_Mult: float = 1
var Ins_Skill_3_Mult: float = 1
var Ins_Beaver: float = 1
var Info
var EXP: int
var Skills: Array
var IsSlip: bool = false
var IsStick: bool = false
var SlipCount: int = 0
var StickCount: int = 0
var StickPower: int = 0
onready var MainNode = get_parent().get_parent()

func _ready() -> void :
	if MainNode.has_method("_PlayerNode"):
		call_deferred("Update_Check")
		if not GameLogic.is_connected("Reward", self, "Update_Check"):
			var _con = GameLogic.connect("Reward", self, "Update_Check")
func Update_Check():

	var _CHECKARRAY: Array = ["技能-冲刺"]
	var _CHECKBOOL = false
	for _CHECK in _CHECKARRAY:
		if Skills.has(_CHECK):
			_CHECKBOOL = true
			break
	if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454]:
		MainNode.Con.CanRoll = _CHECKBOOL


	_data_instance()
func call_player_init(_ID):
	if GameLogic.Config.PlayerConfig.has(str(_ID)):
		Info = GameLogic.Config.PlayerConfig[str(_ID)]
	else:
		printerr("Player读取错误，call_player_init")
		return
	MainNode.Con._IsSKILL = false

	if GameLogic.Save.statisticsData["Character"].has(_ID):
		EXP = GameLogic.Save.statisticsData["Character"][_ID].EXP
	else:
		EXP = 0
	var _TITLELEVEL: int = 0
	var _LEVEL: int = 0
	if EXP > GameLogic.Staff.EXPMAX:
		EXP = GameLogic.Staff.EXPMAX
	for _Num in GameLogic.Staff.TITLEARRAY:
		_LEVEL += 1
		if EXP < int(_Num):
			break
		_TITLELEVEL = _LEVEL
	if Info.has("Skills"):
		Skills.clear()
		for _i in Info.Skills.size():
			if _i <= _TITLELEVEL:
				Skills.append(Info.Skills[_i])
			else:
				break

	if Info.has("Mass"):
		MainNode.mass = float(Info.Mass)
	if Info.has("MoveSpeed"):
		MoveSpeed = float(Info.MoveSpeed) * 7

	if _ID in [3]:
		Ins_Beaver = 0.8
	else:
		Ins_Beaver = 1




	call_CollisionAni()
	_data_instance()
func call_CollisionAni():
	if MainNode.IsDead:
		get_node("CollisionAni").play("dead")
	elif Skills.has("技能-幽灵基础"):
		print("测试 Skills.has技能-穿越:", Skills.has("技能-穿越"))
		if Skills.has("技能-穿越"):
			if has_node("CollisionAni"):

				get_node("CollisionAni").play("ghost2")
		else:
			if has_node("CollisionAni"):
				get_node("CollisionAni").play("ghost")
	else:
		if has_node("CollisionAni"):
			get_node("CollisionAni").play("init")
func call_NPC_init():

	MoveSpeed = BaseSpeed


	if MoveSpeed < 5:
		MoveSpeed = 5

	_data_instance()
func call_courier_init():

	var _MOVESPEED = MoveSpeed
	MoveSpeed = _MOVESPEED
	_data_instance()
func call_NPC():
	IsNPC = true
func call_Staff_init():

	_data_instance()
func _data_instance():

	Ins_BASESPEED = int((float(MoveSpeed - 5) * Cur_ROLLMULTI))
	Ins_ROLL_SPEED = Ins_BASESPEED * 4
	Ins_ROLL_FRICTION = Ins_BASESPEED * 5

	var _ACCELERATION_LEVEL: int = 0
	var _ACCELERATION_MULT: float = 20
	Ins_ChallengeMult = 1
	if IsNPC:
		if GameLogic.cur_Event == "顾客加速":
			Ins_ChallengeMult += 0.5
		if MainNode.is_in_group("Customers") or MainNode.is_in_group("Passers"):
			if not MainNode.IsPickUp:
				if GameLogic.cur_Challenge.has("顾客迟缓"):
					Ins_ChallengeMult -= 0.1
				if GameLogic.cur_Challenge.has("顾客迟缓+"):
					Ins_ChallengeMult -= 0.2
				if GameLogic.cur_Challenge.has("顾客迟缓++"):
					Ins_ChallengeMult -= 0.4
		if MainNode.IsCustomer and not MainNode.IsFinish:
			if GameLogic.Achievement.cur_EquipList.has("顾客加速") and not GameLogic.SPECIALLEVEL_Int:
				Ins_ChallengeMult += 0.5
		var _FINISH = MainNode.IsFinish
		var _PICK = MainNode.IsPickUp
		if MainNode.IsPickUp:
			if not MainNode.IsFinish:

				if GameLogic.cur_Rewards.has("小蜜蜂+"):
					Ins_ChallengeMult += 1.5
				elif GameLogic.cur_Rewards.has("小蜜蜂"):
					Ins_ChallengeMult += 0.5

				if GameLogic.cur_Challenge.has("不慌不急"):
					Ins_ChallengeMult -= 0.2
				if GameLogic.cur_Challenge.has("不慌不急+"):
					Ins_ChallengeMult -= 0.4
	else:
		if GameLogic.LoadingUI.IsLevel:
			if not Skills.has("技能-幽灵基础"):
				if GameLogic.cur_Rewards.has("小白鞋"):
					Ins_ChallengeMult += 0.1


				elif GameLogic.cur_Rewards.has("小白鞋+"):

					Ins_ChallengeMult += 0.3

			if GameLogic.Achievement.cur_EquipList.has("移动加速") and not GameLogic.SPECIALLEVEL_Int:

				Ins_ChallengeMult += 0.1

		if MainNode.BuffList.has("技能-提速"):
			Ins_ChallengeMult += 0.1

		if MainNode.BuffList.has("补充"):
			Ins_ChallengeMult += 0.15
		if GameLogic.LoadingUI.IsLevel and GameLogic.cur_Event == "加速" and GameLogic.LoadingUI.IsLevel:
			Ins_ChallengeMult += 0.1
		if GameLogic.LoadingUI.IsLevel:
			if GameLogic.cur_Challenge.has("减速"):
				Ins_ChallengeMult -= 0.05
			if GameLogic.cur_Challenge.has("减速+"):
				Ins_ChallengeMult -= 0.1
			if GameLogic.cur_Challenge.has("减速++"):
				Ins_ChallengeMult -= 0.2
		if GameLogic.cur_Challenge.has("起步困难") and GameLogic.LoadingUI.IsLevel:
			_ACCELERATION_LEVEL += 1

		if GameLogic.cur_Challenge.has("起步困难+") and GameLogic.LoadingUI.IsLevel:
			_ACCELERATION_LEVEL += 2
		if not Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("防滑靴"):
				_ACCELERATION_LEVEL -= 1
			if GameLogic.cur_Rewards.has("防滑靴+"):
				_ACCELERATION_LEVEL = 0
		if Skills.has("技能-爆发力"):
			_ACCELERATION_LEVEL = 0
		if _ACCELERATION_LEVEL < 0:
			_ACCELERATION_LEVEL = 0
		var _FRICTION_LEVEL: int = 0
		if Skills.has("技能-敏捷"):
			_FRICTION_LEVEL = 1
		if GameLogic.LoadingUI.IsLevel:
			if GameLogic.cur_Challenge.has("打滑"):
				_FRICTION_LEVEL += 1
			if GameLogic.cur_Challenge.has("打滑+"):
				_FRICTION_LEVEL += 2
			if GameLogic.cur_Challenge.has("打滑++"):
				_FRICTION_LEVEL += 3
			if GameLogic.cur_Rewards.has("防滑靴"):
				_FRICTION_LEVEL -= 1
			if GameLogic.cur_Rewards.has("防滑靴+"):
				_FRICTION_LEVEL = 0
		if _FRICTION_LEVEL < 0:
			_FRICTION_LEVEL = 0
		Ins_FRICTION = GameLogic._FRICTION_ARRAY[_FRICTION_LEVEL]
		if Ins_FRICTION < 0:
			Ins_FRICTION = 0
	_ACCELERATION_MULT = GameLogic._ACCELERATION_ARRAY[_ACCELERATION_LEVEL]
	Ins_ACCELERATION = int(Ins_MAXSPEED * _ACCELERATION_MULT)

	if MainNode.is_in_group("Couriers"):
		if not GameLogic.cur_Rewards.has("高速配送+"):
			if GameLogic.cur_Challenge.has("快递拖沓"):
				Ins_ChallengeMult -= 0.25
			if GameLogic.cur_Challenge.has("快递拖沓+"):
				Ins_ChallengeMult -= 0.5
		if GameLogic.cur_Rewards.has("高速配送+"):
			Ins_ChallengeMult += 1.5
		elif GameLogic.cur_Rewards.has("高速配送"):
			Ins_ChallengeMult += 0.5

	if Ins_ChallengeMult < 0.25:
		Ins_ChallengeMult = 0.25
	_speed_change_logic()
func _speed_change_logic():
	if GameLogic.LoadingUI.IsHome:
		Ins_Beaver = 1
	var _Skill: float = Ins_Skill_1_Mult * Ins_Skill_2_Mult * Ins_Skill_3_Mult * Ins_Beaver * (1 - (0.1 * StickPower))
	var _Ins_SpeedMult = Ins_AcrossMult * Ins_CarryMult * Ins_ChallengeMult * _Skill
	if _Ins_SpeedMult < 0.25:
		_Ins_SpeedMult = 0.25
	Ins_MAXSPEED = Ins_BASESPEED * _Ins_SpeedMult

	if Ins_MAXSPEED > 500:
		Ins_MAXSPEED = 500

	if MainNode.IsCourier:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_SPEED_puppet", [Ins_MAXSPEED])
	if MainNode.Con.has_method("call_velocity"):
		MainNode.Con.call_velocity()

func call_SPEED_puppet(_MULT):
	Ins_MAXSPEED = Ins_MAXSPEED

func call_across_in():

	var _Mult: float = 1
	if GameLogic.cur_Challenge.has("阻挡"):
		_Mult -= 0.15
	if GameLogic.cur_Challenge.has("阻挡+"):
		_Mult -= 0.3
	if GameLogic.cur_Challenge.has("阻挡++"):
		_Mult -= 0.6
	if GameLogic.cur_Rewards.has("学生拖鞋") and not Skills.has("幽灵基础"):
		AcrossMult = 0.75
	Ins_AcrossMult = AcrossMult * _Mult
	if GameLogic.cur_Rewards.has("学生拖鞋+") and not Skills.has("幽灵基础"):
		Ins_AcrossMult = 1
	if Ins_AcrossMult > 1:
		Ins_AcrossMult = 1
	if Ins_AcrossMult < 0.1:
		Ins_AcrossMult = 0.1
	if Skills.has("技能-穿越") or GameLogic.cur_Event == "穿越":
		Ins_AcrossMult = 1
	_data_instance()

func call_across_end():
	if MainNode.cur_Touch_Count <= 0:
		Ins_AcrossMult = 1
		_data_instance()

func call_carryreset_puppet(_MULT):
	if MainNode.has_method("_PlayerNode"):
		MainNode.AVATAR.call_Act_End()
	Ins_CarryMult = _MULT
	_speed_change_logic()
	MainNode.call_touch()

func call_carry_on(_CarryMult):

	if MainNode.has_method("_PlayerNode"):
		MainNode.AVATAR.call_Act_End()
	Ins_CarryMult = 1

	if _CarryMult < 1:
		if Skills.has("技能-敏捷"):
			Ins_CarryMult -= 0.1
		if GameLogic.Save.gameData.HomeDevList.has("健身器材"):
			_CarryMult += 0.1
			if _CarryMult > 1:
				_CarryMult = 1
		if Skills.has("技能-史莱姆基础"):
			Ins_CarryMult -= 0.2
		if GameLogic.cur_Challenge.has("缚鸡之力"):
			Ins_CarryMult -= 0.1
		if GameLogic.cur_Challenge.has("缚鸡之力+"):
			Ins_CarryMult -= 0.2
		if GameLogic.cur_Challenge.has("缚鸡之力++"):
			Ins_CarryMult -= 0.4
		if GameLogic.cur_Rewards.has("小翅膀"):
			Ins_CarryMult += 0.3
		elif GameLogic.cur_Rewards.has("小翅膀+"):
			Ins_CarryMult += 2

		Ins_CarryMult = _CarryMult * Ins_CarryMult
	if Skills.has("技能-强壮") or GameLogic.cur_Event == "搬运":

		if Ins_CarryMult < 1:
			Ins_CarryMult = 1
	if Ins_CarryMult < 0.1:
		Ins_CarryMult = 0.1
	if Ins_CarryMult > 1:
		if _CarryMult < 1:
			if GameLogic.cur_Rewards.has("小翅膀+"):
				var _MAX = 1 + (1 - _CarryMult) / 5
				if Ins_CarryMult > _MAX:
					Ins_CarryMult = _MAX
			else:
				Ins_CarryMult = 1
		else:
			Ins_CarryMult = 1


	_speed_change_logic()
	MainNode.call_touch()

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_carryreset_puppet", [Ins_CarryMult])

func _puppet():
	Ins_CarryMult = 1
	_speed_change_logic()
	MainNode.Con.IsHold = false
	MainNode.Con.NeedPush = false
	MainNode.Con.HoldInsId = 0
	GameLogic.Tutorial.call_Drop_end()
	if MainNode.has_method("_PlayerNode"):
		MainNode.AVATAR.call_Act_End()
	MainNode.call_touch()
func call_carry_off_puppet():
	Ins_CarryMult = 1
	_speed_change_logic()
	MainNode.Con.IsHold = false
	MainNode.Con.NeedPush = false
	MainNode.Con.HoldInsId = 0
	GameLogic.Tutorial.call_Drop_end()
	if MainNode.has_method("_PlayerNode"):
		MainNode.AVATAR.call_Act_End()
	MainNode.call_touch()

func call_carry_off():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_carry_off_puppet")
	Ins_CarryMult = 1
	_speed_change_logic()
	MainNode.Con.IsHold = false
	MainNode.Con.NeedPush = false
	MainNode.Con.HoldInsId = 0
	MainNode.Con.HoldObj = null
	GameLogic.Tutorial.call_Drop_end()
	if MainNode.has_method("_PlayerNode"):
		MainNode.AVATAR.call_Act_End()
	MainNode.call_touch()
func call_slip_in(_NUM, _CHECKBOOL: bool = false):

	if not GameLogic.curLevelList.has("难度-污渍水渍") and not GameLogic.cur_levelInfo.GamePlay.has("难度-污渍水渍") and not _CHECKBOOL:
		return

	SlipCount += 1
	if SlipCount > 0:
		if not IsSlip:
			IsSlip = true

			var _FRINUM: int = int(float(_NUM) / 4)
			if _FRINUM > 3:
				_FRINUM = 3
			var _ACC: int = int(float(_NUM) / 5)
			var _FRICTION_LEVEL: int = _FRINUM
			var _ACCELERATION_LEVEL: int = _ACC + 1
			if Skills.has("技能-敏捷"):
				_FRICTION_LEVEL += 1

			if GameLogic.cur_Challenge.has("打滑"):
				_FRICTION_LEVEL += 1
			if GameLogic.cur_Challenge.has("打滑+"):
				_FRICTION_LEVEL += 2
			if GameLogic.cur_Challenge.has("打滑++"):
				_FRICTION_LEVEL += 3
			if GameLogic.cur_Challenge.has("起步困难") and not Skills.has("技能-爆发力"):
				_ACCELERATION_LEVEL += 1
			if GameLogic.cur_Challenge.has("起步困难+") and not Skills.has("技能-爆发力"):
				_ACCELERATION_LEVEL += 2
			if not Skills.has("技能-幽灵基础"):
				if GameLogic.cur_Rewards.has("防滑靴"):
					_FRICTION_LEVEL -= 2
					_ACCELERATION_LEVEL -= 1
				if GameLogic.cur_Rewards.has("防滑靴+"):
					_ACCELERATION_LEVEL = 0
					_FRICTION_LEVEL = 0
			if GameLogic.cur_Event == "穿越":
				_ACCELERATION_LEVEL = 0
				_FRICTION_LEVEL = 0


			if _FRICTION_LEVEL < 0:
				_FRICTION_LEVEL = 0
			elif _FRICTION_LEVEL > GameLogic._FRICTION_ARRAY.size() - 1:
				_FRICTION_LEVEL = GameLogic._FRICTION_ARRAY.size() - 1
			Ins_FRICTION = GameLogic._FRICTION_ARRAY[_FRICTION_LEVEL]
			if Ins_FRICTION < 0:
				Ins_FRICTION = 0
			if _ACCELERATION_LEVEL > GameLogic._ACCELERATION_ARRAY.size() - 1:
				_ACCELERATION_LEVEL = GameLogic._ACCELERATION_ARRAY.size() - 1
			var _ACCELERATION_MULT = GameLogic._ACCELERATION_ARRAY[_ACCELERATION_LEVEL]
			Ins_ACCELERATION = int(Ins_MAXSPEED * _ACCELERATION_MULT)


func call_slip_end(_CHECKBOOL: bool = false):
	if not GameLogic.curLevelList.has("难度-污渍水渍") and not GameLogic.cur_levelInfo.GamePlay.has("难度-污渍水渍") and not _CHECKBOOL:
		return
	SlipCount -= 1
	if SlipCount <= 0:
		if IsSlip:
			IsSlip = false
			_data_instance()
func call_stick_in(_NUM, _CHECKBOOL: bool = false):

	if not _CHECKBOOL and not GameLogic.curLevelList.has("难度-污渍水渍") and not GameLogic.cur_levelInfo.GamePlay.has("难度-污渍水渍") and not GameLogic.cur_Challenge.has("粘脚") and not GameLogic.cur_Challenge.has("粘脚+"):
		return

	StickCount += 1
	if StickCount > 0:
		IsStick = true

		var _StickMult: float = 2

		if not GameLogic.curLevelList.has("难度-污渍水渍") and not GameLogic.cur_levelInfo.GamePlay.has("难度-污渍水渍"):
			_StickMult = 1.5
		if GameLogic.cur_Challenge.has("粘脚"):
			_StickMult -= 0.2
		if GameLogic.cur_Challenge.has("粘脚+"):
			_StickMult -= 0.5

		StickPower = int(_NUM / _StickMult)

		if not GameLogic.SPECIALLEVEL_Int:
			if GameLogic.Save.gameData.HomeDevList.has("水槽"):
				StickPower = int(float(StickPower) * 0.75)

		if not Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("防滑靴"):
				StickPower = int(float(StickPower) / 2)
			if GameLogic.cur_Rewards.has("防滑靴+"):
				StickPower = 0
		if Skills.has("技能-污渍不粘") or GameLogic.cur_Event == "穿越":
			StickPower = 0

		_speed_change_logic()

func call_stick_end(_CHECKBOOL: bool = false):
	if not _CHECKBOOL and not GameLogic.curLevelList.has("难度-污渍水渍") and not GameLogic.cur_levelInfo.GamePlay.has("难度-污渍水渍") and not GameLogic.cur_Challenge.has("粘脚") and not GameLogic.cur_Challenge.has("粘脚+"):
		return
	StickCount -= 1
	if StickCount <= 0:
		if IsStick:
			StickPower = 0
			IsStick = false
			_data_instance()
