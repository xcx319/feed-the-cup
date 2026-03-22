extends Head_Object
var SelfDev = "MixerMachine"

onready var WarningNode = get_node("WarningNode")
var IsBlackOut: bool = false
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if not _Player.Con.IsHold:
		$But / A.InfoLabel.text = GameLogic.CardTrans.get_message($But / A.Info_2)
	else:
		$But / A.InfoLabel.text = GameLogic.CardTrans.get_message($But / A.Info_Str)
	if WarningNode.NeedFix:
		$But / Y.show()
	else:
		$But / Y.hide()

	.But_Switch(_bool, _Player)
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	if IsBlackOut:
		call_Use_Ani(0)
func _DayClosedCheck():
	pass
func _ready() -> void :
	call_init(SelfDev)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	if GameLogic.is_connected("DayStart", self, "Update_Check"):
		var _CON = GameLogic.connect("DayStart", self, "Update_Check")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

var _POWER: float = 0.25
func Update_Check():
	var UpgradeAni = $AniNode / Upgrade
	if GameLogic.cur_Rewards.has("搅拌机升级"):

		_POWER = 0.75
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("搅拌机升级+"):

		_POWER = 0.5
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
func call_Elec():
	GameLogic.Total_Electricity += _POWER
func call_Mix_End():
	call_Audio_End()
	GameLogic.Total_Electricity += _POWER
	if WarningNode.return_Fix():
		pass
func call_DrinkCup(_ButID, _DrinkCup, _Player):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if WarningNode.NeedFix or IsBlackOut:
				return
			if $AniNode / Use.current_animation in ["Use"]:
				return
			if _DrinkCup.Liquid_Count == 0:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NoUse()
				return
			if _DrinkCup.Top != "" or _DrinkCup.Hang in ["上层焦糖", "上层巧克力"]:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NoUse()
				return
			var _CHECK_1 = Check_Logic(_DrinkCup.Extra_1)
			var _CHECK_2 = Check_Logic(_DrinkCup.Extra_2)
			var _CHECK_3 = Check_Logic(_DrinkCup.Extra_3)
			var _CHECK_4 = Check_Logic(_DrinkCup.Extra_4)
			var _CHECK_5 = Check_Logic(_DrinkCup.Extra_5)
			if _CHECK_1 or _CHECK_2 or _CHECK_3 or _CHECK_4 or _CHECK_5:

				if _CHECK_1 != "":
					_DrinkCup.Extra_1 = _CHECK_1

				if _CHECK_2 != "":
					_DrinkCup.Extra_2 = _CHECK_2

				if _CHECK_3 != "":
					_DrinkCup.Extra_3 = _CHECK_3

				if _CHECK_4 != "":
					_DrinkCup.Extra_4 = _CHECK_4

				if _CHECK_5 != "":
					_DrinkCup.Extra_5 = _CHECK_5

				var _TIME: float = 4
				if GameLogic.cur_Rewards.has("搅拌机升级"):
					_TIME = 3
				elif GameLogic.cur_Rewards.has("搅拌机升级+"):
					_TIME = 1.5
				if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
					_TIME -= 1
				if GameLogic.cur_Challenge.has("电压不稳"):
					_TIME += 0.1
				if GameLogic.cur_Challenge.has("电压不稳+"):
					_TIME += 0.2
				if GameLogic.cur_Challenge.has("电压不稳++"):
					_TIME += 0.4
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				_Player.call_DeviceAni(self, _TIME, false)
				_DrinkCup.call_add_extra()
				_DrinkCup.call_CanMix_Finish()
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, _DrinkCup.LIQUID_ARRAY[0], _Player)
				call_Use_Ani(1)
func Check_Logic(_Check: String):
	match _Check:
		"椰果":
			return "椰果碎"
		"脆波波":
			return "脆波波碎"
		"仙草冻":
			return "仙草冻碎"
		"葡萄干":
			return "葡萄干碎"
		"黑曲奇块":
			return "黑曲奇碎"
		"脆波波":
			return "脆波波碎"
		"粉巧克力块":
			return "粉巧克力碎"
		"布朗尼块":
			return "布朗尼碎"
		"栗子":
			return "栗子碎"
		"红豆":
			return "红豆碎"
	return ""

func call_Fix_Logic(_Player):
	if WarningNode.return_Fixing(_Player):
		call_Fixing_Ani(_Player.cur_Player)

		GameLogic.Audio.But_SwitchOn.play(0)
		But_Switch(true, _Player)
	else:
		call_Fixing_Ani(_Player.cur_Player)

func call_Fixing_Ani(_ID):
	$AniNode / Fix.play("init")
	$AniNode / Fix.play("fix")
	GameLogic.Con.call_vibration_Type(_ID, 1)

func call_Use_Ani(_TYPE: int):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Use_Ani", [_TYPE])
	var _USEANI = $AniNode / Use
	match _TYPE:
		0:
			_USEANI.stop(false)
		_:
			var _SPEEDMULT: float = 1
			if GameLogic.cur_Rewards.has("搅拌机升级"):
				_SPEEDMULT = 1.5
			elif GameLogic.cur_Rewards.has("搅拌机升级+"):
				_SPEEDMULT = 2.5
			if GameLogic.cur_Challenge.has("电压不稳"):
				_SPEEDMULT -= 0.1
			if GameLogic.cur_Challenge.has("电压不稳+"):
				_SPEEDMULT -= 0.2
			if GameLogic.cur_Challenge.has("电压不稳++"):
				_SPEEDMULT -= 0.4
			$AniNode / Use.playback_speed = _SPEEDMULT
			_USEANI.play("Use")
			$Audio.play(0)
func call_Audio_End():
	$Audio.stop()

func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)

func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)
		3:

			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				call_Fix_Logic(_Player)
				return
