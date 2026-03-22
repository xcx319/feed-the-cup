extends RigidBody2D

export var IsStaff: bool
var IsCourier: bool

var IsDead: bool
var IsSave: bool
var IsJoy: bool
var JoyDevice: int
var velocity = Vector2.ZERO
var GearList: Array
var Touch_Old
var input_vector: Vector2
var StaffNode = null
var SavePlayer: Array
onready var Stat = get_node("LogicNode/Stat")
onready var Con = get_node("LogicNode/Control")

onready var AVATAR
onready var WeaponNode
onready var RIGHTNode
var cur_Player
var cur_ID: int
var cur_RayObj
var cur_TouchObj
var cur_Touch_Count: int
var cur_Touch_List: Array
var cur_face
var Can_PressA: bool
var cur_Pressure: int = 0
var cur_PressureMax: int
onready var AvatarNode = get_node("Player")
onready var FaceRay = AvatarNode.get_node("RayCast2D")
onready var FaceRayAniPlayer = FaceRay.get_node("AnimationPlayer")
onready var CameraNode = AvatarNode.get_node("Camera2D")
onready var Collision = get_node("CollisionShape2D")
onready var EffectNode = AvatarNode.get_node("EffectNode")
onready var InfoLabel = AvatarNode.get_node("InfoLabel")
onready var InfoAni = InfoLabel.get_node("Ani")
onready var QTEinfo = AvatarNode.get_node("QTE/QTEinfo")
onready var QTEAni = AvatarNode.get_node("QTE/QTEAni")
onready var NameLabel = AvatarNode.get_node("NameLabel")
onready var SayLabel = AvatarNode.get_node("SayNode/SayLabel")
onready var NameAni = NameLabel.get_node("Ani")

var _Pressure_1_Bool: bool
var _Pressure_1_Time: float
var FootPrint: int = 0
var FootWaterColor: Color = Color8(137, 228, 245, 100)

onready var PressurePro = AvatarNode.get_node("PressureNode")
onready var PressureNode

var NoPress: bool
var HasPress: bool
var HighPress: bool
var AddPressTime: float
var SaveState
var OBJNODE

var BuffList: Array
var ServiceType: String
var CanQTE: bool
var _TIMECHECK: float
var _TOUCHLIST: Array
signal StepOn(_POS, _TYPE)
signal StatChange
func call_StatChange():
	emit_signal("StatChange")
func _PlayerNode():
	pass
func call_StepOn(_TYPE):


	emit_signal("StepOn", self.global_position, _TYPE)

func call_Special_Logic(_TYPE, _VALUE):

	pass
func call_Smash_Start():
	var _ExtraNum: float = 0
	if not is_instance_valid(Con.HoldObj):
		return
	var _SMASHLIST: Array = ["草莓", "香蕉块", "西瓜块", "凤梨块", "西柚块", "杨梅块", "芒果块", "桃子块", "葡萄块"]
	if Con.HoldObj.Extra_1 in _SMASHLIST:
		_ExtraNum += 1
	if Con.HoldObj.Extra_2 in _SMASHLIST:
		_ExtraNum += 1
	if Con.HoldObj.Extra_3 in _SMASHLIST:
		_ExtraNum += 0.5
	if Con.HoldObj.get("Extra_4") in _SMASHLIST:
		_ExtraNum += 0.5
	if Con.HoldObj.get("Extra_5") in _SMASHLIST:
		_ExtraNum += 0.5
	if _ExtraNum == 0:
		return
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		Con.CanControl = false

	SaveState = Con.ArmState
	Con.ArmState = GameLogic.NPC.STATE.SMASH

	var _MULT: float = 1
	var _TIMEMULT: float = 1
	if BuffList.has("技能-手速"):
		_MULT += 0.5
		_TIMEMULT -= 0.5
	if Stat.Skills.has("技能-修理"):


		_TIMEMULT = _TIMEMULT * 0.5
	if GameLogic.cur_Rewards.has("尖爪手套"):
		_MULT += 0.25
		_TIMEMULT = _TIMEMULT * 0.75
	elif GameLogic.cur_Rewards.has("尖爪手套+"):
		_MULT += 1
		_TIMEMULT = _TIMEMULT * 0.25

	if not Stat.Skills.has("技能-幽灵基础"):
		if GameLogic.cur_Challenge.has("手笨+"):
			_MULT = _MULT * 0.75
			_TIMEMULT = _TIMEMULT / 0.75
	if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
		_MULT += GameLogic.Skill.HandWorkMult
		_TIMEMULT = _TIMEMULT * 0.75
	if GameLogic.cur_Event == "手速":
		_MULT = 1
		_TIMEMULT = 0.25
	if _TIMEMULT < 0.1:
		_TIMEMULT = 0.1


	if is_instance_valid(Con.HoldObj):

		Con.HoldObj.call_Smash(true, _MULT)

	var _TIME: float = _ExtraNum

	_TIME = _TIME * _TIMEMULT
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
	call_control(1)
func call_ToiletNum_Change(_NUM: int):
	$Player / SpecialNode / PlayerSpecialEffect.call_ToiletNum_Change(_NUM)

func call_Net_Name(_NAME):

	if typeof(_NAME) == TYPE_STRING:
		NameLabel.text = _NAME
		NameLabel.rect_position.x = int(float(NameLabel.rect_size.x) / 2) * - 1
		if GameLogic.LoadingUI.IsHome:
			NameAni.play("Home")
		else:
			_MultName_Logic()

func _MultName_Logic():
	if not SteamLogic.IsMultiplay:
		NameAni.play("init")
		return
	var _NAME: String = Steam.getFriendPersonaName(cur_Player)
	if typeof(_NAME) == TYPE_STRING:
		NameLabel.text = _NAME
		NameLabel.rect_position.x = int(float(NameLabel.rect_size.x) / 2) * - 1
	if GameLogic.LoadingUI.IsHome:
		NameAni.play("Home")
	elif not GameLogic.GlobalData.globalini.has("NameShowType"):
		NameAni.play("show")
		return
	elif GameLogic.GlobalData.globalini.NameShowType == 0:
		NameAni.play("show")
	else:
		NameAni.play("Home")

func call_NoCollision_Switch(_SWITCH: bool):
	$CollisionShape2D.disabled = _SWITCH
func call_SetPause(_SWITCH: bool):
	Con.IsPause = _SWITCH

func call_control(_type: int):
	if cur_Player == 2 and not GameLogic.Player2_bool:
		InfoAni.play("0")
		return
	match _type:
		0:

			mass = float(Stat.Info.Mass)
			Con.CanControl = true
			InfoAni.play("0")

		1:
			Con.CanControl = false
			mass = 100

		2:
			Con.CanControl = false
			InfoAni.play("2")
			mass = 100

		3:
			Con.CanControl = false
			mass = 100

		4:
			Con.CanControl = false
			mass = 100

		5:
			Con.CanControl = false
			mass = 100

func call_touch():

	if cur_Touch_List:
		var _Obj = cur_Touch_List.front()
		if is_instance_valid(_Obj):
			if is_instance_valid(cur_TouchObj):
				if self.name in ["1", "2", str(SteamLogic.STEAM_ID)]:

					GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_TouchObj)
			cur_TouchObj = _Obj
			if self.name in ["1", "2", str(SteamLogic.STEAM_ID)]:

				GameLogic.Device.call_TouchDev_Logic( - 1, self, cur_TouchObj)
	else:
		if is_instance_valid(cur_TouchObj):
			if self.name in ["1", "2", str(SteamLogic.STEAM_ID)]:

				GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_TouchObj)
				if cur_TouchObj.has_method("call_ChangeID"):
					cur_TouchObj.call_ChangeID( - 2, cur_TouchObj, self)
		cur_TouchObj = null

func _Del_Hold():

	var _HOLDLIST = WeaponNode.get_children()
	if _HOLDLIST.size():
		for _ITEM in _HOLDLIST:
			WeaponNode.remove_child(_ITEM)
			_ITEM.queue_free()
		Con.IsHold = false
		Con.HoldInsId = 0
		Con.HoldObj = null

func _Put_OnGround():

	if WeaponNode.get_child_count() > 0:
		var _NodeList = WeaponNode.get_children()
		for _DEV in _NodeList:
			var _check = GameLogic.Device.call_PutOnGround(3, self, _DEV)
			if _DEV.has_method("call_Shovel_end"):
				_DEV.call_Shovel_end(self)
	if Con.ArmState == GameLogic.NPC.STATE.SHOVEL:
		Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
func _ready():

	var _R_Pre = GameLogic.connect("OpenStore", self, "call_Pressure_Logic")
	var _TimeChange = GameLogic.GameUI.connect("TimeChange", self, "_TimeCheck")
	var _check = GameLogic.connect("Pressure_Set", self, "call_pressure_set")
	var _PressureMultCheck = GameLogic.connect("Pressure_Mult", self, "call_Pressure_Mult")
	var _PressureTEST = GameLogic.connect("Pressure_Test", self, "call_Pressure_Test")
	var _con = GameLogic.connect("Pressure_reset", self, "call_pressure_reset")
	var _Reset = GameLogic.connect("DayStart", self, "call_reset")
	var _Put = GameLogic.connect("CloseLight", self, "_Put_OnGround")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _Reward = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("DayStart", self, "Update_Check"):
		var _Reward = GameLogic.connect("DayStart", self, "Update_Check")

	if not cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		if not SteamLogic.is_connected("DelNetPlayer", self, "DelNetPlayer"):
			var _SteamCon = SteamLogic.connect("DelNetPlayer", self, "DelNetPlayer")
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		if not GameLogic.is_connected("OrderQTE", self, "call_QTE"):
			var _RETURN = GameLogic.connect("OrderQTE", self, "call_QTE")
	var _OPCON = GameLogic.connect("OPTIONSYNC", self, "_MultName_Logic")

	set_process(false)
	$Player / QTE / L1.ButPlayer = cur_Player
	if not cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		$Player / QTE / L1.hide()
	else:
		$Player / QTE / L1.show()
	call_Pressure_Logic()

	call_deferred("call_FootPrint_Logic")
	call_deferred("call_QTE_Init")

func call_QTE_Init():
	if cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
		$Player / QTE / MultAni.play("init")
	else:
		$Player / QTE / MultAni.play("other")
func _TimeCheck():

	pass
func call_Second_TimeCheck():

	pass

func Update_Check():
	call_Pressure_init()
func call_reset():
	self.name = str(cur_Player)
	_Pressure_Show(0)
	AddPressTime = GameLogic.GameUI.CurTime

func call_courier(_targetPos, _itemName):

	pass
func call_Fashion_init(_INFO: Dictionary = {}):
	AVATAR.call_EquipInit(_INFO)
func call_change_avatar(_ID, _INFO: Dictionary = {}):

	if cur_Player != 1 and _INFO.size() > 0:
		if SteamLogic.LOBBY_IsMaster:
			SteamLogic._FASHIONDIC[int(cur_Player)] = _INFO

	if AvatarNode.has_node(str(cur_ID)):
		var _oldAvatar = AvatarNode.get_node(str(cur_ID))
		_oldAvatar.hide()
	cur_ID = int(_ID)
	if AvatarNode.has_node(str(_ID)):
		var _Avatar = AvatarNode.get_node(str(_ID))

		call_Pressure_init()
		_Avatar.PressureNode.call_init(cur_Pressure, cur_PressureMax)

		_Avatar.show()

		_Avatar.call_EquipInit(_INFO)
	Stat.call_player_init(_ID)
	Con.CanRoll = true

func call_pressure_reset():


	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		if GameLogic.PressureDic.has(cur_Player):
			GameLogic.PressureDic[cur_Player] = 0
	cur_Pressure = 0
	call_Pressure_init()

	if AvatarNode.has_node(str(cur_ID)):
		var _Avatar = AvatarNode.get_node(str(cur_ID))
		_Avatar.PressureNode.call_set(cur_Pressure, cur_PressureMax)
	AVATAR.PressureNode.call_set(cur_Pressure, cur_PressureMax)

func call_Pressure_Test(_TYPE: int):
	match _TYPE:
		- 1:

			call_pressure_set(cur_PressureMax * - 1)
		0:
			if cur_Pressure > 0:
				call_pressure_set(cur_Pressure * - 1)
		1:

			var _P = cur_PressureMax - cur_Pressure - 1
			call_pressure_set(_P)
func call_Pressure_Near():
	var _value = 0
	if cur_Pressure >= cur_PressureMax:
		_value = cur_Pressure - (cur_PressureMax - 1)
		call_pressure_set(_value)
func call_Pressure_Mult(_Mult: int):

	if _Mult != 0:
		var _value = int(float(cur_PressureMax) * (float(_Mult) / 100))
		if cur_Pressure > cur_PressureMax:
			_value += cur_PressureMax - cur_Pressure

		call_pressure_set(_value)

func call_Meteorite_Hit():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_master_node_sync(self, "Master_Mete_Hit")
	else:
		Master_Mete_Hit()
func Master_Mete_Hit():
	call_pressure_set(1)
func call_pressure_set(_value, _type: int = 0):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if _value != 0:

		if _type == 1 and _value > 0:
			if HighPress:
				return
		if GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime and GameLogic.GameUI.CurTime > GameLogic.cur_OpenTime:
			if _value > 0 and GameLogic.cur_Event == "无压":
				return
			elif _value > 0 and GameLogic.cur_Event == "抗压":
				_value = int(float(_value) * 0.75)
			elif _value > 0 and GameLogic.cur_Event == "抗压+":
				_value = int(float(_value) * 0.5)
		if _type == 2:
			if not Stat.Skills.has("技能-鳄鱼"):
				return
			if not GameLogic.GameUI.Is_Open:
				return

		if _value > 0:
			if GameLogic.cur_Challenge.has("压力增高"):
				if cur_Player != SteamLogic.MasterID:
					GameLogic.call_Info(2, "压力增高")
				_value += int(float(_value) * 0.5 + 0.5)
			if GameLogic.cur_Challenge.has("压力增高+"):
				if cur_Player != SteamLogic.MasterID:
					GameLogic.call_Info(2, "压力增高+")

				_value += int(float(_value) + 0.5)
			if Stat.Skills.has("技能-木讷"):
				var _RAND = GameLogic.return_RANDOM() % 10
				if _RAND < 2:

					var _Effect = GameLogic.TSCNLoad.PressureEffect_TSCN.instance()
					_Effect.Num = 0
					_Effect.position = Vector2(0, EffectNode.get_child_count() * 10)
					EffectNode.add_child(_Effect)
					_Effect._Skill_logic()
					return
		_Pressure_Logic(_value)
func call_Money_Effect(_MONEY):
	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = self.global_position
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
func call_Money(_MONEY: int, _KEY: int = 0):
	if _KEY != GameLogic.HomeMoneyKey:
		return

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Money_Effect", [_MONEY])
	GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

	call_Money_Effect(_MONEY)

func _Pressure_Logic(_value):
	if not GameLogic.LoadingUI.IsLevel:
		return
	if _value != 0:
		if _value < 0:
			if GameLogic.cur_Rewards.has("降压药丸"):

				var _MONEY = abs((1 + abs(cur_Pressure) / 2) * 1 * _value * GameLogic.return_Multiplayer_Base())
				if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
					_MONEY = abs(float(_MONEY) * 1.5)
				call_Money(_MONEY, GameLogic.HomeMoneyKey)
			elif GameLogic.cur_Rewards.has("降压药丸+"):
				var _MONEY = abs((1 + abs(cur_Pressure) / 2) * 3 * _value * GameLogic.return_Multiplayer_Base())
				if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
					_MONEY = abs(float(_MONEY) * 1.5)
				call_Money(_MONEY, GameLogic.HomeMoneyKey)
		if cur_Pressure < 0 and _value > 0:
			if GameLogic.cur_Rewards.has("负压雨伞+"):
				_value += _value
			else:
				cur_Pressure = 0
		if _value > 0:
			AddPressTime = GameLogic.GameUI.CurTime
		cur_Pressure += _value
		if cur_Pressure > cur_PressureMax:
			cur_Pressure = cur_PressureMax
		if cur_Pressure < 0:
			if GameLogic.cur_Rewards.has("负压雨伞"):
				if cur_Pressure < int(cur_PressureMax * - 1):
					cur_Pressure = int(cur_PressureMax * - 1)
			elif GameLogic.cur_Rewards.has("负压雨伞+"):
				if cur_Pressure < int(cur_PressureMax * - 1):
					cur_Pressure = int(cur_PressureMax * - 1)
			else:
				cur_Pressure = 0
		_Pressure_Show(_value)


func call_puppet_Pressure_Show(_MAX, _CURPRESSURE, _value):
	cur_PressureMax = _MAX
	cur_Pressure = _CURPRESSURE


	if _value != 0:
		var _Effect = GameLogic.TSCNLoad.PressureEffect_TSCN.instance()
		_Effect.Num = _value
		EffectNode.add_child(_Effect)
		_Effect._Skill_logic()

	_Press_Logic()
	PressureNode.call_set(cur_Pressure, cur_PressureMax)
	PressurePro.call_PressurePro_Set(cur_Pressure, cur_PressureMax, NoPress, HasPress, HighPress)


	call_Pressure_Logic()

func call_Pressure_STEAM():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Pressure_Show", [cur_PressureMax, cur_Pressure, 0])

func call_Pressure_Logic():

	var _SPEEDMULT: float = 1
	if cur_PressureMax == 0:
		return
	if cur_Pressure >= int(float(cur_PressureMax) * 0.5):
		if GameLogic.cur_Challenge.has("身体不适"):
			_SPEEDMULT -= 0.1
		if GameLogic.cur_Challenge.has("身体不适+"):
			_SPEEDMULT -= 0.2

	var _HIGHLIMIT: float = 0.8
	if GameLogic.cur_Rewards.has("外放音响"):
		_HIGHLIMIT = 0.7
	elif GameLogic.cur_Rewards.has("外放音响+"):
		_HIGHLIMIT = 0.5

	if Con._IsSKILL and Stat.Skills.has("技能-穿透"):
		if GameLogic.cur_Rewards.has("幽灵增强"):
			_SPEEDMULT += 0.1
		else:
			_SPEEDMULT -= 0.5
	if _SPEEDMULT < 0.1:
		_SPEEDMULT = - 0.1
	Stat.Ins_Skill_1_Mult = _SPEEDMULT
	Stat._speed_change_logic()
	_Press_Logic()

func _Save_Add(_value):
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.call_StatisticsData_Set("Count_SaveFriend", null, 1)

		GameLogic.Achievement.call_SetAchievement("SAVE_1")
	else:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_SaveFriend_puppet")
	_Pressure_Show(_value)
func call_SaveFriend_puppet():
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.call_StatisticsData_Set("Count_SaveFriend", null, 1)

func _Press_Logic():
	NoPress = false
	HasPress = false
	HighPress = false
	if cur_Pressure <= 0:
		NoPress = true
		if GameLogic.cur_Rewards.has("精神寄托new"):
			HighPress = true
	else:
		HasPress = true
		if GameLogic.cur_Rewards.has("内卷饭碗"):
			if cur_Pressure <= float(cur_PressureMax) * 0.1:
				NoPress = true
				if GameLogic.cur_Rewards.has("精神寄托new"):
					HighPress = true
		elif GameLogic.cur_Rewards.has("内卷饭碗+"):
			if cur_Pressure <= float(cur_PressureMax) * 0.3:
				NoPress = true
				if GameLogic.cur_Rewards.has("精神寄托new"):
					HighPress = true

	var _HIGHLIMIT: float = 0.8
	if GameLogic.cur_Rewards.has("外放音响"):
		_HIGHLIMIT = 0.7
	if GameLogic.cur_Rewards.has("外放音响+"):
		_HIGHLIMIT = 0.5
	if float(cur_Pressure) >= float(cur_PressureMax) * _HIGHLIMIT:
		HighPress = true
		if GameLogic.cur_Rewards.has("精神寄托new"):
			NoPress = true

func _Pressure_Show(_value):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	else:
		GameLogic.PressureDic[cur_Player] = cur_Pressure
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Pressure_Show", [cur_PressureMax, cur_Pressure, _value])


	if _value != 0:
		var _Effect = GameLogic.TSCNLoad.PressureEffect_TSCN.instance()
		_Effect.Num = _value
		_Effect.position = Vector2(0, EffectNode.get_child_count() * 10)
		EffectNode.add_child(_Effect)
		_Effect._Skill_logic()

	_Press_Logic()
	PressureNode.call_set(cur_Pressure, cur_PressureMax)
	PressurePro.call_PressurePro_Set(cur_Pressure, cur_PressureMax, NoPress, HasPress, HighPress)
	if cur_Pressure >= cur_PressureMax:
		if GameLogic.cur_Rewards.has("员工帽"):
			if not _Pressure_1_Bool:
				_Pressure_1_Bool = true
				GameLogic.call_Info(1, "员工帽")
				_value = cur_PressureMax * - 0.1
				call_pressure_set(_value)

				GameLogic.call_Reward()
				GameLogic.call_Info(1, "员工帽")
				return
		if GameLogic.cur_Rewards.has("员工帽+"):
			if not _Pressure_1_Bool:
				_Pressure_1_Bool = true
				GameLogic.call_Info(1, "员工帽+")
				_value = cur_PressureMax * - 0.3
				call_pressure_set(_value)
				GameLogic.call_Reward()
				GameLogic.call_Info(1, "员工帽+")
				return


	if GameLogic.LoadingUI.IsLevel:



		if cur_Pressure >= cur_PressureMax:
			IsDead = true
			Stat.call_CollisionAni()
			_Put_OnGround()
			call_control(1)
			AVATAR.CryAni.play("DeadCry")
			$HelpArea / DeadAudio2D.play(0)
			Con.state = GameLogic.NPC.STATE.DEAD
			var _CANSAVE: bool
			if not SteamLogic.IsMultiplay and not GameLogic.Player2_bool:
				if $HelpArea / AnimationPlayer.assigned_animation in ["init", "finish"]:
					$HelpArea / AnimationPlayer.play("solo")
				pass
			elif $HelpArea / AnimationPlayer.assigned_animation in ["init", "finish"]:
				$HelpArea / AnimationPlayer.play("showdead")
				_CANSAVE = true
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_dead_puppet", [IsDead])
		else:
			if Con.state == GameLogic.NPC.STATE.DEAD:
				IsDead = false
				Stat.call_CollisionAni()
				call_control(0)
				AVATAR.CryAni.play("init")
				$HelpArea / DeadAudio2D.stop()
				Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
				if $HelpArea / AnimationPlayer.assigned_animation in ["dead", "showdead"]:
					$HelpArea / AnimationPlayer.play("init")
				if $HelpArea / AnimationPlayer.assigned_animation in ["save"]:
					$HelpArea / AnimationPlayer.play("finish")
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_dead_puppet", [IsDead])
		call_Pressure_Logic()
func call_dead_puppet(_DEADBOOL):
	IsDead = _DEADBOOL
	match IsDead:
		true:
			call_control(1)
			AVATAR.CryAni.play("DeadCry")
			$HelpArea / DeadAudio2D.play(0)
			Con.state = GameLogic.NPC.STATE.DEAD
			if $HelpArea / AnimationPlayer.assigned_animation in ["init", "finish"]:
				$HelpArea / AnimationPlayer.play("showdead")
		false:
			IsDead = false
			call_control(0)
			AVATAR.CryAni.play("init")
			$HelpArea / DeadAudio2D.stop()
			Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
			if $HelpArea / AnimationPlayer.assigned_animation in ["dead", "showdead"]:
				$HelpArea / AnimationPlayer.play("init")
			if $HelpArea / AnimationPlayer.assigned_animation in ["save"]:
				$HelpArea / AnimationPlayer.play("finish")

func call_dead_area_ani():

	if cur_Pressure >= cur_PressureMax:
		if $HelpArea / AnimationPlayer.assigned_animation in ["showdead"]:
			$HelpArea / AnimationPlayer.play("dead")
func return_Equip_Logic():
	if cur_Pressure >= cur_PressureMax:
		if GameLogic.cur_Rewards.has("员工帽"):
			if not _Pressure_1_Bool:
				_Pressure_1_Bool = true
				GameLogic.call_Info(1, "员工帽")



				call_Pressure_Mult( - 5)

				call_Saying()


				return true
		if GameLogic.cur_Rewards.has("员工帽+"):

			if not _Pressure_1_Bool:
				_Pressure_1_Bool = true
				_Pressure_1_Time = GameLogic.GameUI.CurTime
				GameLogic.call_Info(1, "员工帽+")

				call_Pressure_Mult( - 15)

				call_Saying()

				return true
func call_Saying():
	if SavePlayer.size() > 0:
		call_Say_Thanks()
	else:
		call_Say_Back()
func call_init():
	Stat.call_player_init(cur_ID)
	call_note_set()
	_Shadow_Init()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if cur_ID in [6]:
		if not GameLogic.is_connected("NoPerfect", self, "call_NoPerfect_Logic"):
			var _CON = GameLogic.connect("NoPerfect", self, "call_NoPerfect_Logic")
func call_NoPerfect_Logic():
	call_pressure_set(1)
func _Shadow_Init():

	if SteamLogic.IsMultiplay:
		if SteamLogic.SLOT == cur_Player:
			$Player / Shadow / Ani.play("1")
		elif SteamLogic.SLOT_2 == cur_Player:
			$Player / Shadow / Ani.play("2")
			AVATAR.call_HeadType("2")
		elif SteamLogic.SLOT_3 == cur_Player:
			$Player / Shadow / Ani.play("3")
			AVATAR.call_HeadType("3")
		elif SteamLogic.SLOT_4 == cur_Player:
			$Player / Shadow / Ani.play("4")
			AVATAR.call_HeadType("4")
	else:
		if cur_Player == 2:
			$Player / Shadow / Ani.play("2")
			AVATAR.call_HeadType("2")
		else:
			$Player / Shadow / Ani.play("1")

func call_Pressure_init():

	cur_PressureMax = int(GameLogic.Config.PlayerConfig[str(cur_ID)].Pressure)

	if not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.Save.gameData.HomeDevList.has("猫猫照片"):
			cur_PressureMax += 5
		if GameLogic.Save.gameData.HomeDevList.has("狐狸照片"):
			cur_PressureMax += 5
		if GameLogic.Save.gameData.HomeDevList.has("灰狼照片"):
			cur_PressureMax += 5
		if GameLogic.Save.gameData.HomeDevList.has("熊熊照片"):
			cur_PressureMax += 5

	if GameLogic.cur_Rewards.has("闭路电视"):
		cur_PressureMax = cur_PressureMax + 25
	elif GameLogic.cur_Rewards.has("闭路电视+"):
		cur_PressureMax = cur_PressureMax + 50
	if Stat.Skills.has("技能-灵巧"):
		cur_PressureMax = int(float(cur_PressureMax) * 0.8)
	if Stat.Skills.has("技能-抗压"):
		cur_PressureMax = int(float(cur_PressureMax) * 1.2)


	var _Mult: float = 1
	if GameLogic.cur_Challenge.has("抗压力差"):
		_Mult -= 0.1

	if GameLogic.cur_Challenge.has("抗压力差+"):
		_Mult -= 0.2



	if GameLogic.cur_Day == 0:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			SteamLogic.PuppetPreDic.clear()
		else:
			GameLogic.PressureDic.clear()
			SteamLogic.PuppetPreDic.clear()

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.PuppetPreDic.has(cur_Player):
			cur_Pressure = SteamLogic.PuppetPreDic[cur_Player]
	elif GameLogic.PressureDic.has(cur_Player):
		cur_Pressure = GameLogic.PressureDic[cur_Player]

	else:
		cur_Pressure = 0
	if _Mult != 1:
		var _CURMULT: float = 0
		if cur_Pressure > 0:
			_CURMULT = float(cur_Pressure) / float(cur_PressureMax)
			if _CURMULT >= 1:
				_CURMULT = 0

		cur_PressureMax = int(float(cur_PressureMax) * _Mult)
		if cur_Pressure >= cur_PressureMax and _CURMULT != 0:
			cur_Pressure = int(float(cur_PressureMax) * _CURMULT)
	PressureNode.call_init(cur_Pressure, cur_PressureMax)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		call_Pressure_STEAM()
	_Pressure_Show(0)

func call_note_set():
	AVATAR = AvatarNode.get_node("Avatar")
	WeaponNode = AVATAR.get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note")
	if AVATAR.has_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/RIGHT_Node"):
		RIGHTNode = AVATAR.get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm/Pose/RIGHT_Node")
	PressureNode = AVATAR.PressureNode
	call_Pressure_init()
	PressureNode.call_init(cur_Pressure, cur_PressureMax)



func Call_CanMove(_BOOL: bool):
	Con.CanMove = _BOOL
	if not _BOOL:
		Con.input_vector = Vector2.ZERO
func return_Move_Control():
	if IsJoy == true:
		input_vector.x = Input.get_joy_axis(JoyDevice, JOY_AXIS_0)
		input_vector.y = Input.get_joy_axis(JoyDevice, JOY_AXIS_1)
	else:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	var Ix = abs(input_vector.x)
	var Iy = abs(input_vector.y)
	if Ix + Iy > 1:
		input_vector = input_vector.normalized()

	return input_vector
func FaceAni_Set():
	cur_face = AVATAR.FACE

	match AVATAR.FACE:
		AVATAR.face_up:
			FaceRayAniPlayer.play("up")
		AVATAR.face_down:
			FaceRayAniPlayer.play("down")
		AVATAR.face_right:
			FaceRayAniPlayer.play("right")
		AVATAR.face_left:
			FaceRayAniPlayer.play("left")
func FaceRay_Cast():
	if Con.input_vector != Vector2.ZERO:
		var normalized_x = Con.input_vector.x
		var normalized_y = Con.input_vector.y

		var targetAngle = rad2deg(atan2(normalized_y, normalized_x)) - 90
		FaceRay.rotation_degrees = targetAngle

	if AVATAR == null:
		return


	if FaceRay.is_colliding():
		if cur_RayObj != FaceRay.get_collider():
			var collider = FaceRay.get_collider()


			if is_instance_valid(cur_RayObj):

				if cur_RayObj.has_method("call_player_leave"):
					cur_RayObj.call_player_leave(self)
				if cur_RayObj.has_method("call_PickFruitInCup"):

					cur_RayObj.call_PickFruitInCup( - 2, Con.HoldObj, self)
				if cur_RayObj.has_method("call_home_device"):
					cur_RayObj.call_home_device( - 2, 1, 0, self)
				if cur_RayObj.has_method("call_Staff_Study"):
					cur_RayObj.But_Switch(false, self)
				else:
					GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_RayObj)





			cur_RayObj = collider

			if cur_RayObj.has_method("call_home_device"):
				cur_RayObj.call_home_device( - 1, 1, 0, self)
				return
			if cur_RayObj.has_method("call_notouch"):
				return



			if is_instance_valid(cur_RayObj):
				if cur_RayObj.has_method("call_Staff_Study"):

					if not Con.IsHold and StaffNode == null:
						cur_RayObj.But_Switch(true, self)
				else:
					GameLogic.Device.call_TouchDev_Logic( - 1, self, cur_RayObj)

	else:
		if is_instance_valid(cur_RayObj):

			if cur_RayObj.has_method("call_player_leave"):
				cur_RayObj.call_player_leave(self)
			if cur_RayObj.has_method("call_PickFruitInCup"):
				cur_RayObj.call_PickFruitInCup( - 2, Con.HoldObj, self)
			if cur_RayObj.has_method("call_home_device"):
				cur_RayObj.call_home_device( - 2, 1, 0, self)
				cur_RayObj = null
				return
			if cur_RayObj.has_method("call_notouch"):
				cur_RayObj = null
				return


			if cur_RayObj.has_method("_ready"):
				if cur_RayObj.has_method("call_Staff_Study"):
					cur_RayObj.But_Switch(false, self)
				else:
					GameLogic.Device.call_TouchDev_Logic( - 2, self, cur_RayObj)
		cur_RayObj = null



var _ROLLING: bool = false

func _integrate_forces(s):

	if GearList:
		var GearVelocity: Vector2 = Vector2.ZERO
		if GearList:
			GearVelocity = GearList.back().Direction
		velocity = Con.velocity + GearVelocity
	else:
		velocity = Con.velocity

	if Con.IsRoll:

		var _CURVELOCITY = s.get_linear_velocity()
		var _FACEVEC = Con._Vector_Save.normalized()

		if _FACEVEC == Vector2.ZERO:
			match AVATAR.FACE:
				0:
					_FACEVEC = Vector2(0, - 1)
				1:
					_FACEVEC = Vector2(0, 1)
				2:
					_FACEVEC = Vector2( - 1, 0)
				3:
					_FACEVEC = Vector2(1, 0)
		var _BASESPEED = Stat.Ins_BASESPEED
		var _MaxSpeed = _FACEVEC * 1500
		if FaceRay.is_colliding():
			set_linear_velocity(_FACEVEC * 1000)
		else:
			set_linear_velocity(_MaxSpeed)

		if not _ROLLING:
			_ROLLING = true














			return
	elif _ROLLING:
		_ROLLING = false

		var _CURVELOCITY = s.get_linear_velocity()
		var _FACEVEC = Con.input_vector

		if _FACEVEC == Vector2.ZERO:
			match AVATAR.FACE:
				0:
					_FACEVEC = Vector2(0, - 1)
				1:
					_FACEVEC = Vector2(0, 1)
				2:
					_FACEVEC = Vector2( - 1, 0)
				3:
					_FACEVEC = Vector2(1, 0)
		var _MaxSpeed = _FACEVEC * Stat.Ins_MAXSPEED
		set_linear_velocity(_MaxSpeed)

		return

	var CURVELOCITY = s.get_linear_velocity()
	if Con.input_vector != Vector2.ZERO:

		var _MaxSpeed = Con._Vector_Save.normalized() * Stat.Ins_MAXSPEED
		CURVELOCITY = CURVELOCITY.move_toward(velocity, Stat.Ins_ACCELERATION * s.get_step())

		set_linear_velocity(CURVELOCITY)

	else:

		if GearList:
			var _step = Stat.Ins_ACCELERATION * s.get_step()
			CURVELOCITY = CURVELOCITY.move_toward(velocity, _step)
		else:
			var _step = Stat.Ins_FRICTION * s.get_step() / Stat.Ins_AcrossMult
			CURVELOCITY = CURVELOCITY.move_toward(Vector2.ZERO, _step)

		set_linear_velocity(CURVELOCITY)
		AvatarNode.position = Vector2.ZERO





func call_reset_stat_puppet():
	if Con.state == GameLogic.NPC.STATE.FALLDOWN:
		Con.IsMixing = false
		return
	if Con.input_vector != Vector2.ZERO:
		Con.state = GameLogic.NPC.STATE.MOVE
	else:
		Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
	Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
	Con.IsMixing = false
	call_StatChange()
func call_reset_stat():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_reset_stat_puppet")
	if Con.state != GameLogic.NPC.STATE.FALLDOWN:
		if Con.input_vector != Vector2.ZERO:
			Con.state = GameLogic.NPC.STATE.MOVE
		else:
			Con.state = GameLogic.NPC.STATE.IDLE_EMPTY
		Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
	Con.IsMixing = false
	call_StatChange()

func call_Mix_Start_Puppet(_ARMSTATE):
	Con.IsMixing = true
	Con.ArmState = _ARMSTATE

func call_Mix_Start(_HoldObj):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	Con.IsMixing = true
	if _HoldObj.TypeStr == "ShakeCup":
		Con.ArmState = GameLogic.NPC.STATE.SHAKE
	else:
		Con.ArmState = GameLogic.NPC.STATE.STIR
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Mix_Start_Puppet", [Con.ArmState])

func call_DelNetPlayer_puppet(_SteamID):

	if SteamLogic.IsMultiplay:
		if _SteamID == SteamLogic.STEAM_ID or _SteamID == SteamLogic.MasterID:
			return
		self.queue_free()
func DelNetPlayer(_SteamID):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if cur_Player in [2]:

		return

	if cur_Player == _SteamID:
		if Con.IsHold:

			var _Obj = instance_from_id(Con.HoldInsId)
			var _check = GameLogic.Device.call_PutOnGround(3, self, _Obj)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_DelNetPlayer_puppet", [_SteamID])
		self.queue_free()
func call_Say_Making():
	if SayLabel.get_node("AnimationPlayer").current_animation == "正在制作":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("正在制作")

	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoOrder():
	var _SAYANI = $Player / SayNode / SayLabel / AnimationPlayer
	if _SAYANI.current_animation == "无法下单":
		_SAYANI.play("init")
	printerr(" _CHECK:", _SAYANI.has_animation("无法下单"))
	_SAYANI.play("无法下单")

	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedBox():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需小料盒":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需小料盒")

	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedGas():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需要气罐":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需要气罐")

	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedWash():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需清洗":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需清洗")
func call_Say_Busy():

	if SayLabel.get_node("AnimationPlayer").current_animation == "正在忙":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("正在忙")

	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_DrinkWrong():
	if SayLabel.get_node("AnimationPlayer").current_animation == "制作错误":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("制作错误")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_OverID():
	if SayLabel.get_node("AnimationPlayer").current_animation == "过号":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("过号")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoAdd():
	if SayLabel.get_node("AnimationPlayer").current_animation == "会溢出":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("会溢出")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedOpen():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需开盖":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需开盖")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_FormulaWrong():
	if SayLabel.get_node("AnimationPlayer").current_animation == "配比不对":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("配比不对")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_IntoSink():
	if SayLabel.get_node("AnimationPlayer").current_animation == "倒入水槽":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("倒入水槽")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoUse():
	if SayLabel.get_node("AnimationPlayer").current_animation == "不可用":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("不可用")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoPick():
	if SayLabel.get_node("AnimationPlayer").current_animation == "未封口":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("未封口")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_WrongCup():
	if SayLabel.get_node("AnimationPlayer").current_animation == "杯子不对":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("杯子不对")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_PickFinished():
	if SayLabel.get_node("AnimationPlayer").current_animation == "已封口":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("已封口")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoTicket():
	if SayLabel.get_node("AnimationPlayer").current_animation == "未贴票":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("未贴票")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoPutOnGround():
	if SayLabel.get_node("AnimationPlayer").current_animation == "不可放地上":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("不可放地上")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoPassBox():
	if SayLabel.get_node("AnimationPlayer").current_animation == "不可滑箱子":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("不可滑箱子")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedEmptyHand():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需空手":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需空手")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedBreak():

	SayLabel.get_node("AnimationPlayer").play("休息一下")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedWaterOnFoot():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需踩水":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需踩水")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoBoil():
	if SayLabel.get_node("AnimationPlayer").current_animation == "煮开加西米":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("煮开加西米")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_IsEmptyCup():
	if SayLabel.get_node("AnimationPlayer").current_animation == "已经空杯":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("已经空杯")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_TooHot():
	if SayLabel.get_node("AnimationPlayer").current_animation == "温度过高":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("温度过高")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_WaterNotEnough():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需更多水":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需更多水")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoHang():
	if SayLabel.get_node("AnimationPlayer").current_animation == "未加糖浆":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("未加糖浆")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoTop():
	if SayLabel.get_node("AnimationPlayer").current_animation == "未加封顶":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("未加封顶")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_MixOnCooker():
	if SayLabel.get_node("AnimationPlayer").current_animation == "加热搅拌":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("加热搅拌")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_DropWater():
	if SayLabel.get_node("AnimationPlayer").current_animation == "滤水":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("滤水")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NoFullMilk():
	if SayLabel.get_node("AnimationPlayer").current_animation == "牛奶不足":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("牛奶不足")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedClean():
	if SayLabel.get_node("AnimationPlayer").current_animation == "拖把脏":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("拖把脏")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_AddSugar():
	if SayLabel.get_node("AnimationPlayer").current_animation == "加糖闷":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("加糖闷")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_NeedRack():
	if SayLabel.get_node("AnimationPlayer").current_animation == "需要茶架":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("需要茶架")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_Say_Back():
	if SayLabel.get_node("AnimationPlayer").current_animation == "复活":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("复活")
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)
func call_Say_Thanks():
	if SayLabel.get_node("AnimationPlayer").current_animation == "谢谢":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("谢谢")
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)
func call_Say_Perfect():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Say_Perfect")
	var _SAYANI = $Player / SayNode / SayLabel / AnimationPlayer
	if _SAYANI.current_animation == "请好评":
		_SAYANI.play("init")
	_SAYANI.play("请好评")
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)
func call_Say_Repeated():
	if SayLabel.get_node("AnimationPlayer").current_animation == "重复":
		SayLabel.get_node("AnimationPlayer").play("init")
	SayLabel.get_node("AnimationPlayer").play("重复")
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)

func _Audio_play():
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)

func call_GasChargeAni():

	SaveState = Con.ArmState
	call_control(1)
	Con.ArmState = GameLogic.NPC.STATE.WORK
	pass
func call_DevAni_puppet(_TIME):
	SaveState = Con.ArmState
	call_control(1)
	Con.ArmState = GameLogic.NPC.STATE.WORK
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.Con.call_vibration(cur_Player, 0.3, 0.3, _TIME)
func call_DeviceAni(_OBJ, _Time: float = 1, _MultiBool: bool = true):
	if Con.ArmState in [GameLogic.NPC.STATE.SQUEEZE,
	GameLogic.NPC.STATE.SHAKE,
	GameLogic.NPC.STATE.STIR,
	GameLogic.NPC.STATE.WORK]:
		call_Say_Busy()
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	OBJNODE = _OBJ
	SaveState = Con.ArmState
	call_control(1)
	Con.ArmState = GameLogic.NPC.STATE.WORK

	var _TIME: float = _Time * GameLogic.return_Multiplier_Division()

	if Stat.Skills.has("技能-熟练"):
		_TIME = _TIME * 0.5
	if not BuffList.has("技能-手速"):
		_TIME = _TIME * 0.5
	if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
		_TIME = _TIME * (1 - GameLogic.Skill.HandWorkMult)
	if not _MultiBool:
		_TIME = _Time
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_DevAni_puppet", [_TIME])
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.Con.call_vibration(cur_Player, 0.7, 0, _TIME)

func call_Canning_puppet():
	SaveState = Con.ArmState
	Con.ArmState = GameLogic.NPC.STATE.WORK

func call_Working_Start():

	SaveState = Con.ArmState
	Con.ArmState = GameLogic.NPC.STATE.WORK
	call_control(1)

func call_NoOrderAni_puppet(_POS, _SAVE, _TIME):
	self.position = _POS
	SaveState = _SAVE
	call_control(1)
	call_Say_NoOrder()
	Con.ArmState = GameLogic.NPC.STATE.ORDER
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
func call_OrderAni_puppet(_POS, _SAVE, _TIME):
	self.position = _POS
	SaveState = _SAVE
	call_control(1)
	SayLabel.get_node("AnimationPlayer").play("Order")
	Con.ArmState = GameLogic.NPC.STATE.ORDER
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
func return_OrderAni(_ORDER):
	if Con.IsHold:
		if Con.NeedPush:
			SayLabel.get_node("AnimationPlayer").play("PushOrder")
			return false
		if Con.ArmState in [GameLogic.NPC.STATE.SQUEEZE,
		GameLogic.NPC.STATE.SHAKE,
		GameLogic.NPC.STATE.STIR,
		GameLogic.NPC.STATE.WORK]:
			SayLabel.get_node("AnimationPlayer").play("PushOrder")
			return false
	if Con.ArmState == GameLogic.NPC.STATE.ORDER:
		return
	GameLogic.call_StatisticsData_Set("Count_Order", null, 1)

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return


	if GameLogic.cur_Rewards.has("防沫口罩"):
		var _rand = GameLogic.return_randi() % 4
		if _rand == 0:
			GameLogic.call_Info(1, "防沫口罩")
			call_pressure_set( - 1)
	if GameLogic.cur_Rewards.has("防沫口罩+"):
		var _rand = GameLogic.return_randi() % 4
		if _rand == 0:
			GameLogic.call_Info(1, "防沫口罩+")
			call_pressure_set( - 2)

	var _TIME: float = 1 * GameLogic.return_Multiplier_Division()

	if GameLogic.cur_Rewards.has("耳麦"):
		_TIME = _TIME * 0.75
	OBJNODE = _ORDER
	if Stat.Skills.has("技能-河狸基础") or GameLogic.cur_Rewards.has("耳麦+"):
		OBJNODE.call_Order_Logic(self)
		return

	SaveState = Con.ArmState
	call_control(1)
	SayLabel.get_node("AnimationPlayer").play("Order")

	Con.ArmState = GameLogic.NPC.STATE.ORDER
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_OrderAni_puppet", [position, SaveState, _TIME])
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
	return true
func return_NoOrderAni(_ORDER):
	if Con.IsHold:
		if Con.NeedPush:
			SayLabel.get_node("AnimationPlayer").play("PushOrder")
			return false
		if Con.ArmState in [GameLogic.NPC.STATE.SQUEEZE,
		GameLogic.NPC.STATE.SHAKE,
		GameLogic.NPC.STATE.STIR,
		GameLogic.NPC.STATE.WORK]:
			SayLabel.get_node("AnimationPlayer").play("PushOrder")
			return false
	if Con.ArmState == GameLogic.NPC.STATE.ORDER:
		return

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return


	var _TIME: float = 3 * GameLogic.return_Multiplier_Division()

	OBJNODE = _ORDER

	SaveState = Con.ArmState
	call_control(1)

	call_Say_NoOrder()

	Con.ArmState = GameLogic.NPC.STATE.ORDER
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_NoOrderAni_puppet", [position, SaveState, _TIME])
	$LogicNode / LogicTimer.wait_time = _TIME
	$LogicNode / LogicTimer.start(0)
	Con.IsRoll = true

	return true

func _on_PlayerNode_body_entered(_body):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _body.has_method("_PlayerNode"):
		if GameLogic.LoadingUI.IsLevel:
			if Stat.Skills.has("技能-分担") and not _body.IsDead:
				if cur_Pressure + 5 > 0:
					var _Check = float(cur_Pressure + 5) / float(cur_PressureMax)
					if _Check < 1:
						if _body.cur_Pressure >= cur_Pressure and _body.cur_Pressure > 0:
							if _TIMECHECK + 0.5 <= GameLogic.GameUI.CurTime:
								_TIMECHECK = GameLogic.GameUI.CurTime
							else:
								return
							var _PRESSURE: int = _body.cur_Pressure
							if _PRESSURE > 5:
								_PRESSURE = 5
							_body._TIMECHECK = _TIMECHECK
							_body._Pressure_Logic( - 1 * _PRESSURE)
							self._Pressure_Logic(_PRESSURE)

			if Stat.Skills.has("技能-提速"):
				if not _body.BuffList.has("技能-提速"):
					_body.BuffList.append("技能-提速")
					var _SPEEDUP_EFFECT = GameLogic.TSCNLoad.SpeedEffect_TSCN.instance()
					_body.add_child(_SPEEDUP_EFFECT)
					_SPEEDUP_EFFECT.call_init("技能-提速", 1, 5)
					_body.Stat.Update_Check()
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(_body, "call_SpeedSkill_puppet")
	elif _body.get("SpecialType") in [1]:
		_body.KnockBack = true

		var CURVELOCITY: Vector2 = _body.linear_velocity.move_toward(Con.velocity * 10, 10000)
		_body.set_linear_velocity(CURVELOCITY)
	elif _body.get("SpecialType") in [20]:

		pass
func call_SpeedSkill_puppet():
	BuffList.append("技能-提速")
	var _SPEEDUP_EFFECT = GameLogic.TSCNLoad.SpeedEffect_TSCN.instance()
	add_child(_SPEEDUP_EFFECT)
	_SPEEDUP_EFFECT.call_init(1, 5)
	Stat.Update_Check()

func _on_OrderTimer_timeout():
	if SayLabel.get_node("AnimationPlayer").assigned_animation == "Order":
		SayLabel.get_node("AnimationPlayer").play("OrderEnd")
	match Con.ArmState:
		GameLogic.NPC.STATE.SMASH:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				pass
			if is_instance_valid(Con.HoldObj):


				Con.HoldObj.call_Smash(false, 1)
				Con.HoldObj.call_Smash_Logic()
				pass
			call_control(0)
			Con.ArmState = SaveState
		GameLogic.NPC.STATE.ORDER:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				pass
			elif is_instance_valid(OBJNODE):
				if Con.IsRoll:
					Con.IsRoll = false
					OBJNODE.call_NoOrder_Logic(self)
				else:
					OBJNODE.call_Order_Logic(self)
			call_control(0)
			Con.ArmState = SaveState
		GameLogic.NPC.STATE.WORK:
			if is_instance_valid(OBJNODE):
				if OBJNODE.has_method("call_used"):
					OBJNODE.call_used(self)
				if OBJNODE.has_method("call_CanUse"):
					OBJNODE.call_CanUse()
			call_control(0)
			Con.ArmState = SaveState
		_:
			call_control(0)
func _on_HelpArea_body_entered(_body):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _body != self:
		if _body.has_method("_PlayerNode"):
			if not _body.IsDead and IsDead:
				if not SavePlayer.has(_body):
					SavePlayer.append(_body)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_Save_puppet", [SavePlayer])
					call_SaveLogic()
			elif not _body.IsDead and GameLogic.LoadingUI.IsLevel:
				if Stat.Skills.has("技能-贴贴"):
					if not _TOUCHLIST.has(_body):
						_TOUCHLIST.append(_body)

func _on_HelpArea_body_exited(_body):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SavePlayer.has(_body):
		SavePlayer.erase(_body)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Save_puppet", [SavePlayer])
		call_SaveLogic()
	if Stat.Skills.has("技能-幽灵基础"):
		if _TOUCHLIST.has(_body):
			_TOUCHLIST.erase(_body)
func call_Save_puppet(_LIST):
	SavePlayer = _LIST
	call_SaveLogic()
func call_SaveLogic():
	if SavePlayer.size():
		var _SaveSpeed: float = 1 * float(SavePlayer.size())
		if GameLogic.Save.gameData.HomeDevList.has("健身器材"):
			_SaveSpeed += 0.1
		if $HelpArea / AnimationPlayer.assigned_animation in ["dead", "save"]:
			$HelpArea / AnimationPlayer.playback_speed = _SaveSpeed
			$HelpArea / AnimationPlayer.play("save")
			$HelpArea / BGArea.play("in")
	else:
		var _SaveSpeed: float = 1
		var _Time: float = $HelpArea / AnimationPlayer.get_current_animation_position()
		if $HelpArea / AnimationPlayer.assigned_animation in ["save"]:
			$HelpArea / AnimationPlayer.play("save", - 1, - 1.0, false)
			$HelpArea / BGArea.play("out")

func call_Saved():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SavePlayer.size():
		var _PressurePlus: int = 0
		if cur_Pressure < cur_PressureMax:
			return
		var _PreNum: int = cur_Pressure - cur_PressureMax + 1
		for _PLAYER in SavePlayer:
			if _PreNum > 0:
				var _ADD: int = int(float(_PreNum) / float(SavePlayer.size()))
				var _CHECK: int = _PLAYER.cur_PressureMax - _PLAYER.cur_Pressure - 1
				if _ADD > _CHECK:
					_ADD = _CHECK
				_PLAYER.cur_Pressure += _ADD

				_PLAYER._Save_Add(_ADD)

		_PressurePlus = _PreNum * - 1
		cur_Pressure += _PressurePlus
		_Pressure_Show(_PressurePlus)
		if cur_Pressure >= cur_PressureMax:
			call_SaveLogic()
	else:
		$HelpArea / AnimationPlayer.play("save", - 1, - 1.0, true)

func call_NoEmpty():
	SayLabel.get_node("AnimationPlayer").play("空杯不可加热")

func call_perfect():
	ServiceType = "Perfect"

	var _NAME = str(self.name)
	GameLogic.QTEDic[_NAME] = "Perfect"
func call_good():
	ServiceType = "Good"
	var _NAME = str(self.name)
	GameLogic.QTEDic[_NAME] = "Good"
func call_bad():
	ServiceType = "Miss"
	var _NAME = str(self.name)
	GameLogic.QTEDic[_NAME] = "Miss"
	call_QTE_press()
	CanQTE = false
func call_QTE():
	if not CanQTE:
		var _NAME = str(self.name)
		if not GameLogic.QTEDic.has(_NAME):
			GameLogic.QTEDic[_NAME] = "Miss"
		if Stat.Skills.has("技能-自动欢迎"):
			if GameLogic.QTESELF_BOOL:
				QTEAni.play("QTE_3")
			else:
				QTEAni.play("QTE_4")
		else:
			if GameLogic.QTESELF_BOOL:
				QTEAni.play("QTE_1")
			else:
				QTEAni.play("QTE_2")
		if cur_Player in [1, SteamLogic.STEAM_ID]:
			$Player / QTE / QTEAudioAni.play("show")
		CanQTE = true
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_QTE")
func call_puppet_QTE():
	if Stat.Skills.has("技能-自动欢迎"):
		if GameLogic.QTESELF_BOOL:
			QTEAni.play("QTE_3")
		else:
			QTEAni.play("QTE_4")
	else:
		if GameLogic.QTESELF_BOOL:
			QTEAni.play("QTE_1")
		else:
			QTEAni.play("QTE_2")
	CanQTE = true
func call_QTE_press():
	if CanQTE:
		if SteamLogic.IsMultiplay:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_press", [ServiceType])
		CanQTE = false
		if QTEAni.assigned_animation != "press":
			QTEAni.play("press")

			match ServiceType:
				"Perfect":
					QTEinfo.play("Perfect")
				"Good":
					QTEinfo.play("Good")
				"Miss":
					QTEinfo.play("Miss")
			if cur_Player in [1, SteamLogic.STEAM_ID]:
				$Player / QTE / QTEAudioAni.play(ServiceType)
func call_puppet_press(_Type):

	ServiceType = _Type
	if CanQTE:
		CanQTE = false
		if QTEAni.assigned_animation != "press":
			if ServiceType != "Miss":
				QTEAni.play("press")

			match ServiceType:
				"Perfect":
					QTEinfo.play("Perfect")
				"Good":
					QTEinfo.play("Good")
				"Miss":
					QTEinfo.play("Miss")

func call_PlayerPos_SYNC(_POS):
	self.position = _POS

func _on_Timer_timeout():


	if cur_Player == SteamLogic.STEAM_ID:
		GameLogic.GameUI.call_Check(GameLogic.HomeMoneyKey)
		if SteamLogic.IsMultiplay:
			SteamLogic.call_master_node_sync(self, "call_PlayerPos_SYNC", [position])

	if SteamLogic.return_check(cur_Player):
		DelNetPlayer(cur_Player)

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _TOUCHLIST.size():
		for _PLAYER in _TOUCHLIST:
			var _RAND = GameLogic.return_randi() % 3
			if _RAND == 0:
				_PLAYER.call_pressure_set( - 1)
	call_Second_TimeCheck()

func call_FootPrint_Logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if Stat.Skills.has("技能-河狸基础"):
		var _CHECK = BuffList
		if BuffList.has("技能-手速"):
			FootPrint = 15
			if Stat.Ins_Beaver != 1:
				call_Beaver_SpeedChange(1)

		elif FootPrint == 0:
			call_Beaver_SpeedChange(0.8)



		else:
			call_Beaver_SpeedChange(1)

func call_Beaver_SpeedChange(_Mult):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Beaver_SpeedChange", [_Mult])
	Stat.Ins_Beaver = _Mult
	Stat._speed_change_logic()
func call_Portal_Pos(_POS: Vector2):
	self.set_deferred("mode", 3)
	self.position = _POS

	self.set_deferred("mode", 0)
func call_reset_Pos(_POS: Vector2):

	self.mode = 3
	self.position = _POS
	yield(get_tree().create_timer(0.25), "timeout")
	self.mode = 0
	AVATAR.MOVESAVE = AVATAR.global_position

func call_FallDown(_FORCE: float = 0):
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:

		call_FallDownLogic(_FORCE)

func call_FallDownLogic(_FORCE):
	if _FORCE != 0:
		if _FORCE > 1:
			_FORCE = 1
		elif _FORCE < 0:
			_FORCE = 0
		if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			GameLogic.Con.call_vibration(cur_Player, _FORCE, _FORCE, 0.2)

	var _x = Con.state
	var _y = Con.CanControl
	if Con.CanControl:

		if Con.IsHold:
			var _HoldObj = instance_from_id(Con.HoldInsId)
			if _HoldObj.has_method("call_WORKING_end"):
				_HoldObj.call_WORKING_end(self)
			if _HoldObj.has_method("call_SQUEEZE_end"):
				_HoldObj.call_SQUEEZE_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			elif _HoldObj.has_method("call_STIR_end"):
				_HoldObj.call_STIR_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			if _HoldObj.has_method("call_SHAKE_end"):
				_HoldObj.call_SHAKE_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			if _HoldObj.has_method("call_WORKING_end"):
				_HoldObj.call_WORKING_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			if _HoldObj.has_method("call_CanMix_Finish"):
				call_reset_stat()
				Con.CanControl = true
		if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			if SteamLogic.IsMultiplay:
				SteamLogic.call_puppet_node_sync(self, "call_FallDown_puppet")
		_Put_OnGround()
	Con.call_FallDown()
func call_FallDown_puppet():
	if Con.CanControl:

		if Con.IsHold:
			var _HoldObj = instance_from_id(Con.HoldInsId)
			if _HoldObj.has_method("call_WORKING_end"):
				_HoldObj.call_WORKING_end(self)
			if _HoldObj.has_method("call_SQUEEZE_end"):
				_HoldObj.call_SQUEEZE_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			elif _HoldObj.has_method("call_STIR_end"):
				_HoldObj.call_STIR_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			if _HoldObj.has_method("call_SHAKE_end"):
				_HoldObj.call_SHAKE_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			if _HoldObj.has_method("call_WORKING_end"):
				_HoldObj.call_WORKING_end(self)
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
			if _HoldObj.has_method("call_CanMix_Finish"):
				call_reset_stat()
				Con.CanControl = true
	_Put_OnGround()
	Con.call_FallDown()
func call_BaseBall_Hit():
	if cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		$Player / SpecialNode / PlayerSpecialEffect.call_BaseBall_Hit()
