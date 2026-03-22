extends Head_Object
var SelfDev = "JuiceMachine"

var FRUITLIST: Array = ["甘蔗", "胡萝卜", "西芹", "黄瓜", "生姜", "苹果"]
var FRUIT: String
var Liquid_Count: int
var Liquid_Max: int = 10
var Trash_Count: int
var Trash_Max: int = 5
var WaterCelcius: int = 25
var _SPEEDMULT: float = 1
var HasFruit: bool
export var CanJuice: bool
var HasWater: bool
var WaterType

onready var UseANI = $AniNode / UseAni
onready var FruitANI = $AniNode / FruitAni
onready var MachineANI = $AniNode / MachineAni
onready var TrashANI = $AniNode / TrashAni
onready var TrashWarnANI = $AniNode / TrashWarning
onready var LiquidPro = $TexNode / UINode / Ui / TextureProgress

onready var But_A = $But / A
onready var But_X = $But / X
onready var But_Y = $But / Y
var IsBroken: bool
var IsPassDay: bool

var IsBlackOut: bool = false

func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_Machine_Logic()
func _DayClosedCheck():

	if HasFruit:
		match FRUIT:
			"苹果":
				Liquid_Count += 4 - JUICETYPE
				if JUICETYPE < 4:
					Trash_Count += 1
			"甘蔗":
				Liquid_Count += 10 - JUICETYPE
				Trash_Count += int(float(10 - JUICETYPE) / 2)

			"胡萝卜":
				Liquid_Count += 4 - JUICETYPE
				if JUICETYPE < 4:
					Trash_Count += 1

			"西芹":
				Liquid_Count += 7 - JUICETYPE
				if JUICETYPE < 3:
					Trash_Count += 2
				elif JUICETYPE < 7:
					Trash_Count += 1

			"黄瓜":
				Liquid_Count += 5 - JUICETYPE

			"生姜":
				Liquid_Count += 3 - JUICETYPE
				if JUICETYPE < 3:
					Trash_Count += 1

		call_Juice_finish()
	if Liquid_Count > 0:

		IsBroken = true
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.JUICEMACHINE):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.JUICEMACHINE)
func _ready() -> void :
	call_init(SelfDev)
	call_deferred("Update_Check")
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	_CanMove_Check()
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")

func _CanMove_Check():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if CanLayout:
		if MachineANI.current_animation != "榨汁" and not HasFruit:
			CanMove = true
		else:
			CanMove = false
	else:
		CanMove = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CanMove_puppet", [CanMove])
func call_CanMove_puppet(_CANMOVE):
	CanMove = _CANMOVE
func Update_Check():
	_SPEEDMULT = 1
	var _MULT: float = 1
	if GameLogic.cur_Rewards.has("榨汁机升级"):
		_MULT += 0.3
		$AniNode / Upgrade.play("2")
		Liquid_Max = 15
		Trash_Max = 7
	elif GameLogic.cur_Rewards.has("榨汁机升级+"):
		_MULT += 0.6
		$AniNode / Upgrade.play("3")
		Liquid_Max = 20
		Trash_Max = 10
	else:
		$AniNode / Upgrade.play("1")
	if GameLogic.cur_Challenge.has("电压不稳"):

		_MULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):

		_MULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):

		_MULT -= 0.4

	_SPEEDMULT = _SPEEDMULT * _MULT
	if _SPEEDMULT <= 0:
		_SPEEDMULT = 0.1

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	HasFruit = bool(_Info.HasFruit)
	if HasFruit:
		MachineANI.play("拥有")
	FRUIT = _Info.FRUIT
	if FruitANI.has_animation(FRUIT):
		FruitANI.play(FRUIT)
	else:
		FruitANI.play("init")
	Liquid_Count = _Info.Liquid_Count
	if Liquid_Count > Liquid_Max:
		Liquid_Count = Liquid_Max
	Trash_Count = int(_Info.Trash_Count)
	call_TrashANI()
	if _Info.has("WaterType"):
		WaterType = _Info.WaterType
	IsPassDay = _Info.IsPassDay
	IsBroken = _Info.IsBroken
	call_Check()
	call_Broken_Check()
	call_Machine_Logic()
func call_Broken_Check():
	if IsBroken:
		$AniNode / Fresh.play("rot")
		$TexNode / Fressless / Effect_flies / Ani.play("Flies")
	elif IsPassDay:
		$AniNode / Fresh.play("freshless")
		$TexNode / Fressless / Effect_flies / Ani.play("OverDay")
	else:
		$AniNode / Fresh.play("init")
		$TexNode / Fressless / Effect_flies / Ani.play("init")
func But_Switch(_Switch, _Player):
	But_Y.hide()
	But_X.hide()
	if _Player.Con.IsHold:
		if _Player.Con.HoldObj.FuncType in ["WaterPort"]:
				But_X.hide()
	else:
		if CanMove:
			But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_2)
			But_A.show()
		else:
			But_A.hide()
		if Trash_Count > 0 and not _Player.Con.IsHold:
			But_X.show()
		if $WarningNode.NeedFix and _Switch:
			But_Y.show()

	.But_Switch(_Switch, _Player)

func call_Fruit_In(_ButID, _HoldObj, _Player):
	if _HoldObj.TypeStr in FRUITLIST:
		match _ButID:
			- 2:
				But_Switch(false, _Player)
			- 1:
				if Liquid_Count > 0 and _HoldObj.TypeStr != FRUIT:
					return
				if HasFruit:
					return
				But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_Str)
				But_A.show()
				But_Switch(true, _Player)
			0:
				if FRUIT:
					if _HoldObj.TypeStr != FRUIT:
						return
				if HasFruit:
					return


				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				call_Fruit_Logic(_HoldObj, _Player)
func call_Fruit_Logic(_FRUITOBJ, _Player):
	HasFruit = true
	FRUIT = _FRUITOBJ.TypeStr
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _OBJPATH = _FRUITOBJ.get_path()
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_puppet", [FRUIT, _PLAYERPATH, _OBJPATH])
	if FruitANI.has_animation(FRUIT):
		FruitANI.play(FRUIT)
	MachineANI.playback_speed = 1
	MachineANI.play("放入")
	_FRUITOBJ.call_del()

	_Player.Stat.call_carry_off()
	_CanMove_Check()
	But_Switch(false, _Player)
func call_Fruit_puppet(_FRUIT, _PLAYERPATH, _OBJPATH):
	FRUIT = _FRUIT
	var _Player = get_node(_PLAYERPATH)
	var _FRUITOBJ = get_node(_OBJPATH)
	HasFruit = true
	if FruitANI.has_animation(FRUIT):
		FruitANI.play(FRUIT)
	MachineANI.playback_speed = 1
	MachineANI.play("放入")
	_FRUITOBJ.call_del()

	_Player.Stat.call_carry_off()

	But_Switch(false, _Player)
func call_Machine_Logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if $WarningNode.NeedFix or IsBlackOut:
		if MachineANI.current_animation in ["榨汁_甘蔗", "榨汁_胡萝卜", "榨汁_西芹", "榨汁_黄瓜", "榨汁_生姜", "榨汁_苹果"]:
			MachineANI.stop(false)
		return
	var _LiquidNUM: int = 1
	JUICETYPE = 0
	match FRUIT:
		"甘蔗":

			WaterType = "甘蔗汁"
			_LiquidNUM = 10

		"胡萝卜":

			WaterType = "胡萝卜汁"
			_LiquidNUM = 3
		"西芹":

			WaterType = "西芹汁"
			_LiquidNUM = 7
		"黄瓜":

			WaterType = "黄瓜汁"
			_LiquidNUM = 5
		"生姜":
			WaterType = "生姜汁"
			_LiquidNUM = 3
		"苹果":
			WaterType = "苹果汁"
			_LiquidNUM = 4
	if Trash_Count >= Trash_Max or Liquid_Count >= Liquid_Max:
		CanJuice = false
		if Trash_Count >= Trash_Max:
			TrashWarnANI.play("Full")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_TrashWarn_puppet", [1])
	else:
		CanJuice = true
		TrashWarnANI.play("init")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_TrashWarn_puppet", [0])

	if CanJuice and HasFruit:
		var _SPEED = _SPEEDMULT * GameLogic.return_Multiplier_Division()
		MachineANI.playback_speed = _SPEED
		var _NAME = "榨汁_" + FRUIT
		MachineANI.play(_NAME)

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Machine_puppet", [FRUIT, _SPEED])
	_CanMove_Check()
func call_TrashWarn_puppet(_Type: int):
	match _Type:
		0:
			TrashWarnANI.play("init")
		_:
			TrashWarnANI.play("Full")
func call_Machine_puppet(_FRUIT, _SPEED):
	FRUIT = _FRUIT
	MachineANI.playback_speed = _SPEED
	var _NAME = "榨汁_" + FRUIT
	MachineANI.play(_NAME)

func call_Juice_finish():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	JUICETYPE = 0
	HasFruit = false
	MachineANI.play("init")

	call_Check()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_finish_puppet")
	call_TrashANI()
func call_Check():
	LiquidPro.max_value = Liquid_Max
	LiquidPro.value = Liquid_Count
	if Liquid_Count > 0:
		HasWater = true
	else:
		HasWater = false
		IsBroken = false
		IsPassDay = false
		if not HasFruit:
			FRUIT = ""
			FruitANI.play("init")
	_CanMove_Check()
	call_Broken_Check()
func call_finish_puppet():
	HasFruit = false
	call_Check()
	MachineANI.play("init")
func call_TrashANI():
	if Trash_Count == 0:
		TrashANI.play("empty")
	elif Trash_Count >= Trash_Max:
		TrashANI.play("full")
	else:
		TrashANI.play("few")

func return_Juice_In_Cup(_ButID, _CupObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if IsBroken or Liquid_Count <= 0:
				return
			But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_Str)
			But_A.show()
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsBroken or Liquid_Count <= 0:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NoUse()
				return
			return return_InCupLogic(_CupObj, _Player)
func return_InCupLogic(_CupObj, _Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return false
	if Liquid_Count > 0:
		var _CHECK = _CupObj.call_Water_In(0, self)
		if _CHECK:
			Liquid_Count -= 1
			UseANI.play("use")
			var _AUDIO = GameLogic.Audio.return_Effect("加水")
			_AUDIO.play(0)



			GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, WaterType, _Player)
			call_Check()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_InCup_puppet", [Liquid_Count])
			call_Machine_Logic()
			return true
	return false

func call_InCup_puppet(_COUNT):
	Liquid_Count = _COUNT
	UseANI.play("use")
	var _AUDIO = GameLogic.Audio.return_Effect("加水")
	_AUDIO.play(0)
	call_Check()

func return_JuiceInPot(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
				return
			if Liquid_Count <= 0:
				return
			But_A.InfoLabel.text = GameLogic.CardTrans.get_message(But_A.Info_Str)
			if WaterType == _HoldObj.get("WaterType") or not _HoldObj.get("WaterType"):
				But_A.show()
			But_X.hide()


			But_Switch(true, _Player)
		0:

			if Liquid_Count <= 0 or _HoldObj.Liquid_Count >= _HoldObj.Liquid_Max:
				return
			if WaterType != _HoldObj.get("WaterType") and _HoldObj.get("WaterType"):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				But_Switch(false, _Player)
				return
			return call_WaterInPot_Logic(_HoldObj, _Player)

func call_WaterInPot_Logic(_HoldObj, _Player):
	var _Count = _HoldObj.Liquid_Max - _HoldObj.Liquid_Count
	var _return = _HoldObj.call_WaterInTeaPort(0, self, _Player, 1)
	if _return:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_WaterInPot_puppet")
		var _AUDIO = GameLogic.Audio.return_Effect("倒水")
		_AUDIO.play(0)
		GameLogic.Liquid.call_WaterStain(_Player.global_position, _Count, WaterType, _Player)
		Liquid_Count -= _Count
		if Liquid_Count < 0:
			Liquid_Count = 0
		call_Check()
		call_Machine_Logic()
	return _return
func call_WaterInPot_puppet():
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
	Liquid_Count = 0
	call_Check()


func call_DevLogic_Trashbin(_ButID, _Player, _DevObj):

	match _ButID:
		- 1:
			But_A.hide()
			pass

		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if Trash_Count <= 0:
				return
			var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
			var _NAME = str(Trashbag_TSCN.get_instance_id())
			Trashbag_TSCN.name = _NAME

			_Player.WeaponNode.add_child(Trashbag_TSCN)
			call_Trashbag_init(_Player, Trashbag_TSCN)
			if SteamLogic.IsMultiplay:
				if _Player.cur_Player == SteamLogic.STEAM_ID:
					GameLogic.Tutorial.call_DrapTrashbag(true)
			else:
				GameLogic.Tutorial.call_DrapTrashbag(true)

			But_Switch(false, _Player)
			var _PickAudio = GameLogic.Audio.return_Effect("拿起")
			_PickAudio.play(0)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYER = _Player.get_path()
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Trashbin_puppet", [_PLAYER, _NAME])
			call_Machine_Logic()
			return "取垃圾"
func call_Trashbin_puppet(_PLAYER, _NAME):
	var _Player = get_node(_PLAYER)
	var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
	Trashbag_TSCN.name = _NAME
	_Player.WeaponNode.add_child(Trashbag_TSCN)
	call_Trashbag_init(_Player, Trashbag_TSCN)
	if _Player.cur_Player == SteamLogic.STEAM_ID:
		GameLogic.Tutorial.call_DrapTrashbag(true)
	But_Switch(true, _Player)
	var _PickAudio = GameLogic.Audio.return_Effect("拿起")
	_PickAudio.play(0)
func call_Trashbag_init(_Player, Trashbag_TSCN):
	_Player.Con.HoldInsId = Trashbag_TSCN.get_instance_id()
	Trashbag_TSCN.call_load({"NAME": Trashbag_TSCN.name, "Weight": Trash_Count})
	Trashbag_TSCN.call_Trashbag_init(Trash_Count, false)

	var _COUNT = Trash_Count
	if _COUNT > 10:
		_COUNT = 10
	var _CarryWeight: float = 1
	if _COUNT > 0:
		_CarryWeight = 1.0 - (float(_COUNT) / float(10) * 0.5)
	Trashbag_TSCN.CarrySpeed = _CarryWeight

	_Player.Con.IsHold = true
	_Player.Con.HoldObj = Trashbag_TSCN
	_Player.Con.NeedPush = true
	_Player.Stat.call_carry_on(_CarryWeight)
	Trash_Count = 0
	call_TrashANI()

func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

var JUICETYPE: int
func call_Trash():

	Trash_Count += 1
	call_TrashANI()
	if Trash_Count >= Trash_Max:
		CanJuice = false
		MachineANI.stop(false)
		TrashWarnANI.play("Full")
func call_Juice():
	JUICETYPE += 1
	Liquid_Count += 1

	GameLogic.Total_Electricity += 0.5
	call_Check()

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Juice_puppet", [Liquid_Count, Trash_Count])

	$WarningNode.return_Fix()
	if $WarningNode.NeedFix:
		MachineANI.stop(false)
	if Liquid_Count >= Liquid_Max:
		CanJuice = false
		MachineANI.stop(false)
func call_Juice_1(_NUM: int):

	var _LiquidNUM: int = 1
	match FRUIT:
		"甘蔗":
			if _NUM in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
				WaterType = "甘蔗汁"
				Liquid_Count += 1
			if _NUM in [2, 4, 6, 8, 10]:
				Trash_Count += 1
		"胡萝卜":
			if _NUM in [3, 6, 9]:
				Liquid_Count += 1
				WaterType = "胡萝卜汁"
			if _NUM in [10]:
				Trash_Count += 1
		"西芹":
			if _NUM in [1, 2, 3, 4, 5, 7, 10]:
				Liquid_Count += 1
				WaterType = "西芹汁"
			if _NUM in [5, 10]:
				Trash_Count += 1
		"黄瓜":
			if _NUM in [1, 2, 4, 7, 10]:
				Liquid_Count += 1
				WaterType = "黄瓜汁"
		"生姜":
			if _NUM in [3, 6, 9]:
				Liquid_Count += 1
				WaterType = "生姜汁"
			if _NUM in [10]:
				Trash_Count += 1
		"苹果":
			if _NUM in [2, 4, 7, 10]:
				Liquid_Count += 1
				WaterType = "苹果汁"
			if _NUM in [7, 10]:
				Trash_Count += 1
	JUICETYPE = _NUM
	call_TrashANI()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	GameLogic.Total_Electricity += 2
	call_Check()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Juice_puppet", [Liquid_Count, Trash_Count])

	$WarningNode.return_Fix()
	if $WarningNode.NeedFix:
		MachineANI.stop(false)
func call_Juice_puppet(_NUM, _TRASHNUM):

	Liquid_Count = _NUM
	call_Check()
	Trash_Count = _TRASHNUM
	call_TrashANI()
func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			But_Switch(true, _Player)

		2:
			call_DevLogic_Trashbin(2, _Player, null)
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	GameLogic.Audio.But_SwitchOn.play(0)
	But_Switch(true, _Player)
	UseANI.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_Fix_Logic(_Player):
	if $WarningNode.return_Fixing(_Player):
		call_Fixing_Ani(_Player)
		But_Switch(true, _Player)
		call_Machine_Logic()
	else:
		call_Fixing_Ani(_Player)

func call_Fixing_Ani(_Player):
	UseANI.play("init")
	UseANI.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
