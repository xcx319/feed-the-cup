extends Head_Object
var SelfDev = "IceMachine"

var _TurnOn: bool
export var powerMult: float = 20
var cur_Timer: float
var UsedPowerCount: float = 0
var power: float = 0.5
var water: float = 1
var UsedWaterCount: float = 0
var Ice_Max: int = 5
var cur_Ice: int = 0

onready var CreateIceTimer = get_node("Timer")
onready var Timer1c = get_node("Timer1c")

onready var MechineAni = get_node("AniNode/Act")
onready var UseAni = get_node("AniNode/Use")
onready var IceAni = get_node("AniNode/Capacity")
onready var UpgradeAni = get_node("AniNode/Upgrade")
onready var NumAni = get_node("AniNode/NumAni")

onready var IceProgress = get_node("TexNode/Ui/TextureProgress")
onready var WarningNode = get_node("WarningNode")
onready var A_But = get_node("But/A")
onready var Y_But = get_node("But/Y")

onready var Audio_Add
onready var HBox = get_node("TexNode/HBox")
var IsBlackOut: bool = false
var _POWERCOUNT: float
func _DayClosedCheck():


	if _TurnOn:
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.ICEMACHINE):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.ICEMACHINE)

		var _Ice = Ice_Max - cur_Ice

		_Ice = int(10 + (Ice_Max - cur_Ice))

		GameLogic.Total_Electricity += float(power * _Ice)
		GameLogic.Total_Water += float(water * _Ice)
		_POWERCOUNT += float(power * _Ice)

		cur_Ice = Ice_Max

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.Con.IsHold:
		var _OBJ = instance_from_id(_Player.Con.HoldInsId)
		if _OBJ.FuncType == "DrinkCup":
			if _OBJ.Celcius != "Cold":
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
				A_But.show()
	if CanMove:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
		if _Player.Con.IsHold:
			A_But.hide()
		else:

			A_But.show()
	else:
		if not _Player.Con.IsHold:
			A_But.hide()


	if WarningNode.NeedFix:
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
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Audio_Add = GameLogic.Audio.return_Effect("加冰块")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("OpenStore", self, "_CanMove_Check"):
		var _con = GameLogic.connect("OpenStore", self, "_CanMove_Check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	if GameLogic.is_connected("DayStart", self, "Update_Check"):
		var _CON = GameLogic.connect("DayStart", self, "Update_Check")
	_CanMove_Check()
	GameLogic.NPC.ICEMACHINE = self
func _CanMove_Check():
	if CanLayout:
		if not _TurnOn:
			CanMove = true
		else:
			CanMove = false
	else:
		CanMove = false
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_Turn()
func Update_Check():
	cur_Timer = powerMult / GameLogic.return_Multiplier_Division()
	var _Mult: float = 1

	if GameLogic.cur_Rewards.has("制冰机升级"):
		_Mult = _Mult * 0.75

		Ice_Max = 10
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("制冰机升级+"):
		_Mult = _Mult * 0.25
		Ice_Max = 15
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
	if GameLogic.cur_Challenge.has("电压不稳"):
		_Mult += 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_Mult += 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_Mult += 0.4
	if GameLogic.Achievement.cur_EquipList.has("制冰装置") and not GameLogic.SPECIALLEVEL_Int:
		_Mult -= 0.25
	if _Mult != 1:
		cur_Timer = cur_Timer * _Mult
	call_Turn()

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	cur_Ice = int(_Info.cur_Ice)
	_TurnOn = _Info.TurnOn


	Update_Check()
	call_Turn()

func call_MachineControl_puppet(_TURN, _PLAYERPATH):
	_TurnOn = _TURN
	var _Player = get_node(_PLAYERPATH)
	if _TurnOn:
		GameLogic.Audio.But_SwitchOn.play(0)
		call_Turn()
		But_Switch(true, _Player)
	else:
		GameLogic.Audio.But_SwitchOff.play(0)
		call_Turn()
		But_Switch(true, _Player)
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
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				if _TurnOn:
					_TurnOn = false
					GameLogic.Audio.But_SwitchOff.play(0)
					call_Turn()
					But_Switch(true, _Player)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _PLAYERPATH = _Player.get_path()
						SteamLogic.call_puppet_id_sync(_SELFID, "call_MachineControl_puppet", [_TurnOn, _PLAYERPATH])
					return "关制冰机"
				else:
					_TurnOn = true
					call_Turn()
					GameLogic.Audio.But_SwitchOn.play(0)
					But_Switch(true, _Player)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _PLAYERPATH = _Player.get_path()
						SteamLogic.call_puppet_id_sync(_SELFID, "call_MachineControl_puppet", [_TurnOn, _PLAYERPATH])
					return "开制冰机"
		_:
			return
func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_TurnOn = true
	call_Turn()
	GameLogic.Audio.But_SwitchOn.play(0)

func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if WarningNode.return_Fixing(_Player):
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
func call_AddIce_puppet(_ICENUM, _TIMELEFT, _ISCOMBO):
	CreateIceTimer.start(_TIMELEFT)
	cur_Ice = _ICENUM
	Audio_Add.play(0)
	_Ice_Show()
	UseAni.play("Use")
	call_Turn()
	if _ISCOMBO:
		$AniNode / ComboAni.play("init")
		$AniNode / ComboAni.play("combo")
		call_Extra()
func call_Barrel_AddIce(_ButID, _Obj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
			A_But.show()
			Y_But.hide()
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _Obj.get("WaterCelcius") >= 85 and _Obj.get("Liquid_Count") > 0:
				var _Cost: int = int(float(_Obj.Liquid_Count) / 8)
				if _Cost == 0:
					_Cost = 1
				if cur_Ice >= _Cost:

					call_UseIce_Logic(_Cost, _Player)
					_Obj.call_NormalCelcius()
					return "加冰"
func call_AddIce(_ButID, _CupObj, _Player):




	if not _CupObj.FuncType in ["DrinkCup", "ShakeCup", "SuperCup"]:
		return
	match _ButID:

		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			A_But.show()
			Y_But.show()
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if _CupObj.TypeStr == "SodaCan":
				return
			if _CupObj.Top != "":
				return
			if _CupObj.Celcius != "Cold":
				var _NeedIce: int = 1
				if _CupObj.TypeStr == "ShakeCup":
					if _CupObj.Liquid_Count <= 2:
						_NeedIce = 1
					elif _CupObj.Liquid_Count <= 4:
						_NeedIce = 1
					elif _CupObj.Liquid_Count <= 6:
						_NeedIce = 1

					if _CupObj.WaterCelcius == 10:
						_NeedIce = 1
					elif _CupObj.WaterCelcius == 15:
						_NeedIce = 1
				else:
					match _CupObj.TYPE:
						"DrinkCup_S":
							_NeedIce = 1
						"DrinkCup_M", "SuperCup_M":
							_NeedIce = 1
						"DrinkCup_L":
							_NeedIce = 1
				if cur_Ice >= _NeedIce:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						GameLogic.Con.call_vibration(_Player.cur_Player, 0.5, 0.5, 0.1)
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					Audio_Add.play(0)
					if _CupObj.HasHot:

						_CupObj.call_AddNormal()
					else:

						_CupObj.call_AddIce()
					call_UseIce_Logic(_NeedIce, _Player)
					return "加冰"
				else:
					WarningNode.call_Empty()
		3:
			return call_MachineControl(3, _Player)
func call_UseIce_Logic(_NeedIce, _Player):

	GameLogic.call_StatisticsData_Set("Count_Ice", null, 1)
	cur_Ice -= _NeedIce
	_Ice_Show()
	var _ISCOMBO: bool = false
	if GameLogic.cur_Rewards.has("制冰机升级"):
		var _RAND = GameLogic.return_randi() % 100
		var _RAT = 10
		if _RAND < _RAT:
			$AniNode / ComboAni.play("init")
			$AniNode / ComboAni.play("combo")
			GameLogic.call_combo(1)
			_ISCOMBO = true
	elif GameLogic.cur_Rewards.has("制冰机升级+"):
		var _RAND = GameLogic.return_randi() % 100
		var _RAT = 30
		if _RAND < _RAT:
			$AniNode / ComboAni.play("init")
			$AniNode / ComboAni.play("combo")
			GameLogic.call_combo(1)
			_ISCOMBO = true
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_AddIce_puppet", [cur_Ice, CreateIceTimer.time_left, _ISCOMBO])
	if _ISCOMBO:
		call_Extra()
	GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, "water", _Player)
	call_Turn()

func call_Turn():
	if IsBlackOut:
		CreateIceTimer.stop()
		Timer1c.stop()
		MechineAni.play("Off")
		NumAni.play("hide")
		return
	if WarningNode.NeedFix:
		_TurnOn = false
		_CanMove_Check()
		if MechineAni.assigned_animation == "On":
			$AudioStreamPlayer2D.play(0)
	match _TurnOn:
		true:
			if cur_Ice >= Ice_Max:
				if MechineAni.assigned_animation != "Full":
					MechineAni.play("Full")
					CreateIceTimer.stop()
					Timer1c.stop()
				if NumAni.assigned_animation == "show":
					NumAni.play("hide")
			if cur_Ice < Ice_Max:
				if MechineAni.assigned_animation != "On":
					MechineAni.play("On")

					$WorkAudio / Ani.play("work")
					CreateIceTimer.start()
					Timer1c.start()
				if NumAni.assigned_animation != "show":
					Timer1c.start()
					_First_TimeSet()
					NumAni.play("show")
		false:
			if MechineAni.assigned_animation != "Off":
				MechineAni.play("Off")
				CreateIceTimer.stop()
				Timer1c.stop()
				if NumAni.assigned_animation == "show":
					NumAni.play("hide")
	_Ice_Show()
	_CanMove_Check()
func call_Turn_Old():

	match _TurnOn:
		true:
			if CreateIceTimer.is_stopped():
				CreateIceTimer.start()
				Timer1c.start()

				$WorkAudio / Ani.play("work")
			if cur_Ice < Ice_Max:
				if CreateIceTimer.is_paused():
					CreateIceTimer.set_paused(false)
					Timer1c.start()
				MechineAni.play("On")

				$WorkAudio / Ani.play("work")
				_Max_Set()

			else:

				CreateIceTimer.set_paused(true)
				Timer1c.stop()
				MechineAni.play("Full")
		false:
			if not CreateIceTimer.is_stopped():
				CreateIceTimer.stop()
				Timer1c.stop()
			MechineAni.play("Off")

	_CanMove_Check()
func _on_Timer_timeout() -> void :
	_Create_Ice()
func _Max_Set():
	for _Node in HBox.get_children():
		_Node.hide()
	var _Num = int(CreateIceTimer.wait_time)
	var str_num = str(_Num)
	var length = len(str_num)
	for _i in length:
		if _i > 2:
			break
		var _PayNum = int(str_num.substr(_i, 1)) + 2
		var _Node = HBox.get_node(str(_i))
		_Node.call_init(3, _PayNum, - 1)
		_Node.show()
func _First_TimeSet():
	for _Node in HBox.get_children():
		_Node.hide()
	var _Num = int(CreateIceTimer.time_left)
	var str_num = str(_Num)
	var length = len(str_num)
	for _i in length:
		if _i > 2:
			break
		var _PayNum = int(str_num.substr(_i, 1)) + 2
		var _Node = HBox.get_node(str(_i))
		_Node.call_init(3, _PayNum, - 1)
		_Node.show()
func _on_Timer1c_timeout():
	for _Node in HBox.get_children():
		_Node.hide()
	var _Num = int(CreateIceTimer.time_left) + 1
	var str_num = str(_Num)
	var length = len(str_num)
	for _i in length:
		if _i > 2:
			break
		var _PayNum = int(str_num.substr(_i, 1)) + 2
		var _Node = HBox.get_node(str(_i))
		_Node.call_init(3, _PayNum, - 1)
		_Node.show()

func call_Create_Ice_puppet(_ICENUM):
	cur_Ice = _ICENUM
	var _RAND = str(1 + GameLogic.return_RANDOM() % 4)
	get_node("IceAudio/Ani").play(_RAND)
	$AniNode / Ice.play("play")
	call_Turn()
func _Create_Ice():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	cur_Ice += 1
	if cur_Ice >= Ice_Max:
		cur_Ice = Ice_Max

	GameLogic.Total_Electricity += float(power)
	GameLogic.Total_Water += float(water)
	_POWERCOUNT += float(power)

	call_Turn()
	var _RAND = str(1 + GameLogic.return_RANDOM() % 4)
	get_node("IceAudio/Ani").play(_RAND)
	$AniNode / Ice.play("play")
	if WarningNode.return_Fix():
		call_Turn()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Create_Ice_puppet", [cur_Ice])
func _Max_Check():
	if cur_Ice >= Ice_Max:
		CreateIceTimer.set_paused(true)
		Timer1c.stop()
		if _TurnOn:
			MechineAni.play("Full")
		else:
			MechineAni.play("Off")
	else:
		CreateIceTimer.set_paused(false)
		Timer1c.start()
		if _TurnOn:
			MechineAni.play("On")

			$WorkAudio / Ani.play("work")
		else:
			MechineAni.play("Off")
	_Ice_Show()
func _CarrySpeed_Logic():
	if cur_Ice > 0:
		CarrySpeed = 0.5 - (float(cur_Ice) / float(20)) * 0.25
	if CarrySpeed < 0.1:
		CarrySpeed = 0.1
func call_IceShow_puppet(_TIMER):
	cur_Timer = _TIMER
	CreateIceTimer.wait_time = _TIMER
func _Ice_Show():

	_CarrySpeed_Logic()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	else:
		CreateIceTimer.wait_time = cur_Timer
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_IceShow_puppet", [cur_Timer])

	IceProgress.max_value = Ice_Max
	IceProgress.value = cur_Ice
	if cur_Ice == 0:
		IceAni.play("Empty")

		$WorkAudio / Ani.play("work")

	elif cur_Ice > 0 and cur_Ice < int(Ice_Max * 0.5):
		IceAni.play("Few")

		$WorkAudio / Ani.play("work")

	elif cur_Ice >= int(Ice_Max * 0.5) and cur_Ice < Ice_Max:
		IceAni.play("Many")

		$WorkAudio / Ani.play("work")

	elif cur_Ice >= Ice_Max:
		IceAni.play("Full")

func call_offcheck():

	pass

func call_add_ice():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	cur_Ice += 5
	if cur_Ice >= Ice_Max:
		cur_Ice = Ice_Max
	var _RAND = str(1 + GameLogic.return_RANDOM() % 4)
	get_node("IceAudio/Ani").play(_RAND)
	$AniNode / Ice.play("play")
	UseAni.play("Use")
	call_Turn()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_addice_puppet", [cur_Ice])
	_Ice_Show()
func call_addice_puppet(_ICENUM):
	cur_Ice = _ICENUM
	var _RAND = str(1 + GameLogic.return_RANDOM() % 4)
	get_node("IceAudio/Ani").play(_RAND)
	$AniNode / Ice.play("play")
	UseAni.play("Use")
	call_Turn()

func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
