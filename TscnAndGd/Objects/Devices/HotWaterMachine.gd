extends Head_Object
var SelfDev = "HotWaterMachine"

var _TurnOn: bool

var UsedPowerCount: float = 0
var power: float = 0.5
var water: float = 0.5
var UsedWaterCount: float = 0

var Temperature: int = 25
var UseTem: int = 40

onready var TemperatureTimer = get_node("Timer")
onready var MachineAni = get_node("AniNode/Act")
onready var UseAni = get_node("AniNode/Use")
onready var UpgradeAni = get_node("AniNode/Upgrade")

onready var WarningNode = get_node("WarningNode")
onready var IceProgress = get_node("TexNode/Ui/TextureProgress")
onready var A_But = get_node("But/A")

onready var Y_But = get_node("But/Y")

onready var HBox = $TexNode / HBox

var cur_PlayerList: Array
var IsBlackOut: bool = false
var _POWERCOUNT: float
func _DayClosedCheck():


	if _TurnOn:
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.STEAMMACHINE):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.STEAMMACHINE)


		GameLogic.Total_Electricity += float(power) * 10
		GameLogic.Total_Water += float(water) * 2
		_POWERCOUNT += power


func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if CanMove:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
		if _Player.Con.IsHold:
			A_But.hide()
		else:
			A_But.show()
	else:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		if not _Player.Con.IsHold:
			A_But.hide()
	Y_But.show()
	if $WarningNode.NeedFix:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_2)
	else:
		if _TurnOn:
			Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_1)
		else:
			Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)

	.But_Switch(_bool, _Player)

func _ready() -> void :
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	call_deferred("_Steam_Show")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

	_CanMove_Check()
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_Turn()
func call_CanMove_puppet(_CANMOVE):
	CanMove = _CANMOVE
func _CanMove_Check():
	if CanLayout:
		if _TurnOn:
			CanMove = false
		else:
			CanMove = true


func Update_Check():
	var Mult: float = 1 / GameLogic.return_Multiplier_Division()

	if GameLogic.cur_Challenge.has("电压不稳"):

		Mult += Mult * 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):

		Mult += Mult * 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):

		Mult += Mult * 0.4
	if GameLogic.cur_Rewards.has("蒸汽机升级"):

		Mult = Mult * 0.75
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("蒸汽机升级+"):

		Mult = Mult * 0.25
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
	else:
		UpgradeAni.play("1")

	var _TIME = 0.4 * Mult
	$Timer.wait_time = _TIME

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	Update_Check()

	if _Info.has("TurnOn"):
		_TurnOn = _Info.TurnOn

	if _TurnOn:
		if GameLogic.cur_Rewards.has("蒸汽机升级"):
			Temperature = 150
		elif GameLogic.cur_Rewards.has("蒸汽机升级+"):
			Temperature = 200
		else:
			Temperature = 100
		call_Turn()
		MachineAni.play("Full")
	_CanMove_Check()

	_Max_Check()
	call_Tem_show()
	var cur_Timer: float = 0.25
	TemperatureTimer.wait_time = cur_Timer

func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			A_But.hide()
			But_Switch(true, _Player)
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:

				if _TurnOn:
					_TurnOn = false
					call_Turn()
					But_Switch(true, _Player)
					return "关蒸汽机"
				else:
					_TurnOn = true
					call_Turn()
					But_Switch(true, _Player)
					return "开蒸汽机"
		_:
			return 1
func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_TurnOn = true
	call_Turn()
	GameLogic.Audio.But_SwitchOn.play(0)
	But_Switch(true, _Player)
	UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if $WarningNode.return_Fixing(_Player):
		_TurnOn = true
		call_Turn()
		GameLogic.Audio.But_SwitchOn.play(0)
		But_Switch(true, _Player)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Fix_puppet", [_PLAYERPATH])

func call_Fixing_Ani(_Player):
	UseAni.play("init")
	UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_used(_Player):
	if cur_PlayerList.has(_Player):
		cur_PlayerList.erase(_Player)
	if not cur_PlayerList.size():
		TemperatureTimer.start(0)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_used_puppet")
	call_Tem_show()
func call_used_puppet():
	TemperatureTimer.start(0)
	call_Tem_show()
func call_AddHotWater_puppet(_TEM, _SPEED, _ISCOMBO):
	Temperature = _TEM
	UseAni.playback_speed = _SPEED
	UseAni.play("Use")
	call_Tem_show()
	if _ISCOMBO:
		$AniNode / ComboAni.play("init")
		$AniNode / ComboAni.play("combo")
		call_Extra()
func call_AddHotWater(_ButID, _CupObj, _Player):



	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			A_But.show()

			But_Switch(true, _Player)
		0:

			if not _CupObj.FuncType in ["DrinkCup", "SuperCup"]:
				return
			if GameLogic.cur_Rewards.has("蒸汽机升级+"):
				if cur_PlayerList.size() >= 3:
					return
			elif GameLogic.cur_Rewards.has("蒸汽机升级"):
				if cur_PlayerList.size() >= 2:
					return
			else:
				if cur_PlayerList.size() >= 1:
					return
			if _CupObj.Liquid_Count == 0:
				_Player.call_NoEmpty()
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _CupObj.Top != "":
				return
			var _ISCOMBO: bool
			if _CupObj.HasIce:
				if Temperature >= 100:
					if not cur_PlayerList.has(_Player):
						cur_PlayerList.append(_Player)
					_CupObj.HasIce = false
					_Player.call_DeviceAni(self)
					Temperature -= UseTem
					var _SPEED = return_UseAni(_Player)

					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return

					if GameLogic.cur_Rewards.has("蒸汽机升级"):
						var _RAND = GameLogic.return_randi() % 100
						var _RAT = 10
						if _RAND < _RAT:
							_ISCOMBO = true
							$AniNode / ComboAni.play("init")
							$AniNode / ComboAni.play("combo")
							GameLogic.call_combo(1)
					if GameLogic.cur_Rewards.has("蒸汽机升级+"):
						var _RAND = GameLogic.return_randi() % 100
						var _RAT = 30
						if _RAND < _RAT:
							_ISCOMBO = true
							$AniNode / ComboAni.play("init")
							$AniNode / ComboAni.play("combo")
							GameLogic.call_combo(1)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "call_AddHotWater_puppet", [Temperature, _SPEED, _ISCOMBO])
					_CupObj.call_AddNormal()


					if $WarningNode.return_Fix():
						call_Turn()
					call_Tem_show()
			elif _CupObj.Celcius != "Hot":
				if Temperature >= 100:
					if not cur_PlayerList.has(_Player):
						cur_PlayerList.append(_Player)
					_Player.call_DeviceAni(self)
					Temperature -= UseTem
					var _SPEED = return_UseAni(_Player)
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					if GameLogic.cur_Rewards.has("蒸汽机升级"):
						var _RAND = GameLogic.return_randi() % 100
						var _RAT = 10
						if _RAND < _RAT:
							_ISCOMBO = true
							$AniNode / ComboAni.play("init")
							$AniNode / ComboAni.play("combo")
							GameLogic.call_combo(1)
					if GameLogic.cur_Rewards.has("蒸汽机升级+"):
						var _RAND = GameLogic.return_randi() % 100
						var _RAT = 30
						if _RAND < _RAT:
							_ISCOMBO = true
							$AniNode / ComboAni.play("init")
							$AniNode / ComboAni.play("combo")
							GameLogic.call_combo(1)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "call_AddHotWater_puppet", [Temperature, _SPEED, _ISCOMBO])

					_CupObj.call_AddHot()
					if $WarningNode.NeedFix:
						call_Turn()

					call_Tem_show()
			if _ISCOMBO:
				call_Extra()
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _TurnOn:
				_TurnOn = false
				call_Turn()
				return true
			else:
				_TurnOn = true
				call_Turn()
				return true

func return_UseAni(_Player):
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()

	if _Player.Stat.Skills.has("技能-熟练"):
		_SPEED = _SPEED * 2
	if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
		_SPEED += GameLogic.Skill.HandWorkMult
	UseAni.playback_speed = _SPEED
	UseAni.play("Use")
	return _SPEED
func call_Turn_puppet(_TURN, _TEM):

	Temperature = _TEM
	call_Tem_show()
	match _TURN:
		true:
			GameLogic.Audio.But_SwitchOn.play(0)
			TemperatureTimer.start(0)
			MachineAni.play("On")
			$ColdTimer.stop()
		false:
			GameLogic.Audio.But_SwitchOff.play(0)
			if not TemperatureTimer.is_stopped():
				TemperatureTimer.stop()
			$ColdTimer.start(0)
			if MachineAni.assigned_animation == "On":
				MachineAni.play("Off")
	pass
func call_Turn():

	if $WarningNode.NeedFix:
		_TurnOn = false
		_CanMove_Check()
		if MachineAni.assigned_animation == "On":
			UseAni.play("NeedFix")
	if IsBlackOut:
		_TurnOn = false
		if MachineAni.assigned_animation == "On":
			MachineAni.play("Off")
		$ColdTimer.start(0)
		TemperatureTimer.stop()
		return

	_CanMove_Check()
	call_Tem_show()
	match _TurnOn:
		true:

			GameLogic.Audio.But_SwitchOn.play(0)
			TemperatureTimer.start(0)

			MachineAni.play("On")
			$ColdTimer.stop()

		false:
			GameLogic.Audio.But_SwitchOff.play(0)
			if not TemperatureTimer.is_stopped():
				TemperatureTimer.stop()
			$ColdTimer.start(0)
			if MachineAni.assigned_animation in ["On", "Full"]:
				MachineAni.play("Off")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Turn_puppet", [_TurnOn, Temperature])
func _on_Timer_timeout() -> void :

	_Tem_Up()

func _Tem_SYNC_puppet(_TEM):
	Temperature = _TEM
	call_Tem_show()
func _Tem_Up():

	if $WarningNode.NeedFix:
		call_Turn()
	if GameLogic.cur_Rewards.has("蒸汽机升级+"):
		if Temperature < 200:
			Temperature += 1
			UsedPowerCount += 1
		else:
			Temperature = 200
			TemperatureTimer.stop()
	elif GameLogic.cur_Rewards.has("蒸汽机升级"):
		if Temperature < 150:
			Temperature += 1
			UsedPowerCount += 1
		else:
			Temperature = 150
			TemperatureTimer.stop()
	else:
		if Temperature < 100:
			Temperature += 1
			UsedPowerCount += 1
		else:
			Temperature = 100
			TemperatureTimer.stop()
	if Temperature in [100, 150, 200]:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "_Tem_SYNC_puppet", [Temperature])
	call_Tem_show()
	if UsedPowerCount >= 50:
		UsedPowerCount = 0
		GameLogic.Total_Electricity += float(power)
		GameLogic.Total_Water += float(water)
		_POWERCOUNT += power
func call_Tem_Check():
	if GameLogic.cur_Rewards.has("蒸汽机升级+"):
		if Temperature >= 200:
			MachineAni.play("Full")
	elif GameLogic.cur_Rewards.has("蒸汽机升级"):
		if Temperature >= 150:
			MachineAni.play("Full")
	elif Temperature >= 100:
		MachineAni.play("Full")


func _Max_Check():

	_Steam_Show()

func _Steam_Show():




	pass
func call_offcheck():

	pass

func call_Tem_show():
	for _Node in HBox.get_children():
		_Node.hide()

	if Temperature < 100:
		var str_num = str(Temperature)
		var length = len(str_num)
		for _i in length:
			if _i > 2:
				break
			var _PayNum = int(str_num.substr(_i, 1)) + 2

			var _Node = HBox.get_node(str(_i))
			_Node.call_init(3, _PayNum, 1)
			_Node.show()
		$AniNode / Effect.play("0")
	elif Temperature >= 100 and Temperature < 150:
		for _i in [0, 1]:
			var _Node = HBox.get_node(str(_i))
			_Node.call_init(3, 1, 1)
			_Node.show()
		if $AniNode / Effect.assigned_animation != "1":
			$AniNode / Effect.play("1")
	elif Temperature >= 150 and Temperature < 200:
		for _i in [0, 1]:
			var _Node = HBox.get_node(str(_i))
			_Node.call_init(3, 1, 1)
			_Node.show()
		$AniNode / Effect.play("2")
	elif Temperature >= 200:
		for _i in [0, 1]:
			var _Node = HBox.get_node(str(_i))
			_Node.call_init(3, 1, 1)
			_Node.show()
		$AniNode / Effect.play("3")
	if _TurnOn:
		if GameLogic.cur_Rewards.has("蒸汽机升级+"):
			if Temperature < 200:
				MachineAni.play("On")
		elif GameLogic.cur_Rewards.has("蒸汽机升级"):
			if Temperature < 150:
				MachineAni.play("On")
		else:
			if Temperature < 100:
				MachineAni.play("On")
func _on_ColdTimer_timeout():
	if Temperature > 25:
		Temperature -= 1
	call_Tem_show()
	$ColdTimer.start(0)
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
