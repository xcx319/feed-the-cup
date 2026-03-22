extends Head_Object
var SelfDev = "BreakMachine"

onready var UpgradeAni = $AniNode / Upgrade
onready var UseAni = $AniNode / UseAni

var Liquid_Count: int = 0
var Liquid_Max: int = 10
var WaterCelcius: int = 20
var IsPassDay: bool
var IsBroken: bool
var WaterType: String
var PowerInt: int = 1
var _Electricity: float = 0.08
var HasWater: bool
var IsOpen: bool
var MachineStat: int = 0
var SugarType: int = 0
var IceType: int = 0
onready var WarningNode = get_node("WarningNode")
var IsBlackOut: bool = false
func call_Electricity():
	GameLogic.Total_Electricity += _Electricity
	if WarningNode.return_Fix():
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix_puppet", [false])
		call_UI_ANI(5)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("Liquid_Count"):
		Liquid_Count = _Info.Liquid_Count
	if _Info.has("WaterCelcius"):
		WaterCelcius = _Info.WaterCelcius
	if _Info.has("WaterType"):
		WaterType = _Info.WaterType
	if _Info.has("MachineStat"):
		MachineStat = _Info.MachineStat
	if _Info.has("IsOpen"):
		IsOpen = _Info.IsOpen
	if IsOpen:
		MachineStat = 3
		call_UseANI(3)
		call_UI_ANI(3)
	if _Info.has("SugarType"):
		SugarType = _Info.SugarType
	if Liquid_Count > 0:
		IsBroken = true
	call_Liquid()
	call_PassDay()
func Update_Check():
	var _Mult: float = 1
	if GameLogic.cur_Rewards.has("破壁机升级"):
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
		PowerInt = 2
		_Electricity = 0.05
	elif GameLogic.cur_Rewards.has("破壁机升级+"):
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
		PowerInt = 3
		_Electricity = 0.04
func _collision_check():
	if not self.is_inside_tree():
		return
	var _parentName = get_parent().name
	if _parentName == "Devices":
		call_Collision_Switch(true)
	elif _parentName == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func _ready() -> void :
	set_physics_process(false)
	$TexNode / UI / FinishView / UiPoptipWrong.hide()
	call_init(SelfDev)

	call_deferred("_collision_check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _CON = GameLogic.connect("Reward", self, "Update_Check")
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func _BlackOut(_Switch):
	IsBlackOut = _Switch
	if IsOpen:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix_puppet", [false])
		call_UI_ANI(5)
func _DayClosedCheck():
	if Liquid_Count > 0:
		if not IsPassDay:
			IsPassDay = true
		else:
			IsBroken = true
	pass
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	var A_But = $But / A
	var Y_But = $But / Y
	match MachineStat:
		0:
			if _Player.Con.IsHold:
				var _OBJ = instance_from_id(_Player.Con.HoldInsId)
				if _OBJ.FuncType == "DrinkCup":
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
					A_But.show()

			else:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
				A_But.show()

		1:

			Y_But.show()
			if IsOpen:
				Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_1)
			else:
				Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)
			if _Player.Con.IsHold:
				A_But.show()
			else:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
				A_But.show()
		2, 3:
			Y_But.show()
			if IsOpen:
				Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_1)
			else:
				Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)
			if _Player.Con.IsHold:
				var _OBJ = instance_from_id(_Player.Con.HoldInsId)
				if _OBJ.FuncType == "DrinkCup":
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
					A_But.show()
			else:
				if IsOpen:
					A_But.show()
				else:
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
					A_But.show()
	if WarningNode.NeedFix:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_2)
		Y_But.show()

	.But_Switch(_bool, _Player)

func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if WarningNode.return_Fixing(_Player):
		But_Switch(true, _Player)

func call_Fixing_Ani(_Player):
	$AniNode / UseAni.play("init")
	$AniNode / UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)
		3:
			if $AniNode / UseAni.current_animation in ["in"]:
				return
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				call_Fix_Logic(_Player)
				return
			else:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _Re = return_Mix()
				But_Switch(true, _Player)
				return _Re
func return_Mix(_START: int = 0):
	if WarningNode.NeedFix or IsBlackOut:
		return
	if MachineStat > 0 and not IsOpen:

		call_UseANI(3)
		call_UI_ANI(MachineStat)

		return "开"
	elif _START == 1:

		call_UseANI(3)
		call_UI_ANI(MachineStat)

		return "开"
	elif IsOpen:

		call_UI_ANI(5)
		return "关"
func call_Mix_puppet(_SWITCH: bool):
	if _SWITCH:
		call_UseANI(3)
		call_UI_ANI(MachineStat)
		return "开"
	else:
		call_UI_ANI(5)
		return "关"
func call_UIANI_puppet(_TYPE: int, _MACHINE):
	MachineStat = _MACHINE
	call_UI_ANI(_TYPE)
func call_UI_ANI(_TYPE: int):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_UIANI_puppet", [_TYPE, MachineStat])
	var _SHOWANI = $TexNode / UI / show
	var _SPEEDMULT: float = 1
	if GameLogic.cur_Rewards.has("破壁机升级"):
		_SPEEDMULT = 1.5
	if GameLogic.cur_Rewards.has("破壁机升级+"):
		_SPEEDMULT = 5
	if GameLogic.cur_Challenge.has("电压不稳"):
		_SPEEDMULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_SPEEDMULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_SPEEDMULT -= 0.4
	_SHOWANI.set_speed_scale(_SPEEDMULT)
	match _TYPE:
		0:
			IsOpen = false
			_SHOWANI.play("hide")
		1:
			IsOpen = true
			_SHOWANI.play(str(_TYPE))
		2:
			HasWater = true
			MachineStat = 2
			if GameLogic.cur_Rewards.has("破壁机升级"):
				match MachineStat:
					1:
						$AniNode / UseAni.play("run2")
					2:
						$AniNode / UseAni.play("run2")
					3:
						$AniNode / UseAni.play("run1")
			elif GameLogic.cur_Rewards.has("破壁机升级+"):

				match MachineStat:
					1:
						$AniNode / UseAni.play("run3")
					2:
						$AniNode / UseAni.play("run2")
					3:
						$AniNode / UseAni.play("run1")
				_SHOWANI.set_speed_scale(1.5)
			if IceType:
				_SHOWANI.play(str(_TYPE))
				WaterCelcius = - 10
			else:
				_SHOWANI.play("4")
			IsOpen = true
		3:

			MachineStat = 3
			if GameLogic.cur_Rewards.has("破壁机升级"):
				match MachineStat:
					1:
						$AniNode / UseAni.play("run2")
					2:
						$AniNode / UseAni.play("run2")
					3:
						$AniNode / UseAni.play("run1")
			elif GameLogic.cur_Rewards.has("破壁机升级+"):
				match MachineStat:
					1:
						$AniNode / UseAni.play("run3")
					2:
						$AniNode / UseAni.play("run2")
					3:
						$AniNode / UseAni.play("run1")
			if IceType:
				WaterCelcius = - 5
			_SHOWANI.play(str(_TYPE))
			IsOpen = true
		4:

			MachineStat = 3
			if GameLogic.cur_Rewards.has("破壁机升级"):
				match MachineStat:
					1:
						$AniNode / UseAni.play("run2")
					2:
						$AniNode / UseAni.play("run2")
					3:
						$AniNode / UseAni.play("run1")
			elif GameLogic.cur_Rewards.has("破壁机升级+"):

				match MachineStat:
					1:
						$AniNode / UseAni.play("run3")
					2:
						$AniNode / UseAni.play("run2")
					3:
						$AniNode / UseAni.play("run1")
			_SHOWANI.play("3")
			IsOpen = true
		5:
			_SHOWANI.stop(false)
			IsOpen = false
			call_UseANI(5)
			$Audio.stop()
func call_Turn(_ButID, _Player, _DrinkCup):
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
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Re = return_Mix()
			But_Switch(true, _Player)
			return _Re
func call_DrinkCup(_ButID, _Player, _DrinkCup):
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
			if $AniNode / UseAni.current_animation in ["in"]:
				return
			match MachineStat:
				0:
					WaterType = _Type_Check(_DrinkCup)

					if WaterType == "":
						if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
							_Player.call_Say_FormulaWrong()
							return
					else:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							GameLogic.Con.call_vibration(_Player.cur_Player, 0.4, 0.4, 0.1)
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return

						call_Cup_Off(_DrinkCup)
						call_Type()

						But_Switch(true, _Player)
						return true
				1:
					if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
						_Player.call_Say_Making()
						return
				2, 3:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						GameLogic.Con.call_vibration(_Player.cur_Player, 0.4, 0.4, 0.1)
					if _DrinkCup.Liquid_Count + Liquid_Count <= _DrinkCup.Liquid_Max and MachineStat > 1:
						call_DrinkCup_in(_DrinkCup, _Player)
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Re = return_Mix()
			But_Switch(true, _Player)
			return _Re
func call_Type_puppet(_WATERTYPE):
	WaterType = _WATERTYPE
	call_Type()
func call_Type():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Type_puppet", [WaterType])
	if $TexNode / UI / ShakeType.has_animation(WaterType):
		$TexNode / UI / ShakeType.play(WaterType)
		$TexNode / UI / show.play("show")
	else:
		$TexNode / UI / ShakeType.play("init")
func call_Cup_in_puppet(_CUPID):
	var _DrinkCup = SteamLogic.OBJECT_DIC[_CUPID]
	_DrinkCup.call_Water_AllIn(self)

func call_DrinkCup_in(_DrinkCup, _Player):
	if IsBroken:
		return
	if _DrinkCup.get("IsStale"):
		if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
			_Player.call_Say_NeedWash()
		return
	var _CHECK: bool = false
	if WaterType != "":
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			return

		_DrinkCup.call_Water_AllIn(self)
		if SugarType:
			_DrinkCup.call_Sugar_In(SugarType)
		if IceType:
			_DrinkCup.call_AddIceBreak(MachineStat)
		if IsPassDay:
			_DrinkCup.call_add_PassDay()
		_CHECK = true

	if _CHECK:
		GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, WaterType, _Player)
		call_UseANI(2)
		call_Type()
		But_Switch(true, _Player)
	else:
		if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
			_Player.call_Say_NoUse()
func call_Drop():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Drop")
	call_UseANI(2)
	call_Type()
func call_UseANI(_TYPE: int):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_UseANI", [_TYPE])
	var _ANI = $AniNode / UseAni
	match _TYPE:
		0:
			_ANI.play("init")
			CanMove = true
		1:
			_ANI.play("in")
			CanMove = true
		2:
			_ANI.play("drop")
			call_UI_ANI(0)
			MachineStat = 0
			WaterType = ""

			HasWater = false
			Liquid_Count = 0
			call_Liquid()
			CanMove = true
			IsPassDay = false
			IsBroken = false
			call_PassDay()

		3:
			if GameLogic.cur_Rewards.has("破壁机升级"):
				_ANI.play("run2")
				CanMove = false
			elif GameLogic.cur_Rewards.has("破壁机升级+"):
				if not _ANI.current_animation in ["in"]:
					match MachineStat:
						1:
							_ANI.play("run3")
						2:
							_ANI.play("run2")
						3:
							_ANI.play("run1")
				CanMove = false
			else:
				_ANI.play("run1")
				CanMove = false
			$Audio.play()
		4:
			_ANI.play("run2")
			CanMove = false
			$Audio.play()
		5:
			_ANI.stop(false)
			CanMove = true
func _Type_Check(_DrinkCup):
	var _x = _DrinkCup.LIQUID_ARRAY
	var _y = _DrinkCup.LIQUID_DIR


	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 1:
		if _DrinkCup.LIQUID_DIR.has("water"):
			if _DrinkCup.LIQUID_DIR["water"] == 1:
				if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
					Liquid_Count = 2
					return "沙冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 2:
		if _DrinkCup.LIQUID_DIR.has("ice_milk"):
			if _DrinkCup.LIQUID_DIR["ice_milk"] == 2:
				if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
					Liquid_Count = 3
					return "牛奶冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 1:
		if _DrinkCup.LIQUID_DIR.has("ice_coconutwater"):
			if _DrinkCup.LIQUID_DIR["ice_coconutwater"] == 1:
				if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
					Liquid_Count = 2
					return "椰子冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 2:
		if _DrinkCup.LIQUID_DIR.has("柠檬汁") and _DrinkCup.LIQUID_DIR.has("water"):
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 3
				return "柠檬冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 1:
		if _DrinkCup.LIQUID_DIR.has("ice_yogurt"):
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 2
				return "酸奶冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0 and _DrinkCup.Extra_1 == "桃子块":
		if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_2 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
			Liquid_Count = 2
			return "桃子冰"

	if not _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 1 and _DrinkCup.Extra_1 == "草莓":
		if _DrinkCup.LIQUID_DIR.has("water"):
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_2 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 2
				return "草莓冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if _DrinkCup.Extra_1 == "桑葚" and _DrinkCup.Extra_2 == "桑葚":
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_3 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 3
				return "桑葚冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 2 and _DrinkCup.Extra_1 == "火龙果块":
		if _DrinkCup.LIQUID_DIR.has("ice_lactobacillus"):
			if _DrinkCup.LIQUID_DIR["ice_lactobacillus"] == 2:
				if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_2 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
					Liquid_Count = 4
					return "火龙果冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if _DrinkCup.Extra_1 == "牛油果块" and _DrinkCup.Extra_2 == "牛油果块":
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_3 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 3
				return "牛油果冰"

	if not _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if _DrinkCup.Extra_1 == "西瓜块" and _DrinkCup.Extra_2 == "西瓜块":
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_3 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 2
				return "西瓜冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if (_DrinkCup.Extra_1 == "牛油果块" and _DrinkCup.Extra_2 == "草莓") or (_DrinkCup.Extra_1 == "草莓" and _DrinkCup.Extra_2 == "牛油果块"):
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_3 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 3
				return "1号冰"

	if not _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if (_DrinkCup.Extra_1 == "西瓜块" and _DrinkCup.Extra_2 == "桑葚") or (_DrinkCup.Extra_1 == "桑葚" and _DrinkCup.Extra_2 == "西瓜块"):
			if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_3 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
				Liquid_Count = 2
				return "2号冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 2:
		if _DrinkCup.LIQUID_DIR.has("ice_yogurt") and _DrinkCup.LIQUID_DIR.has("ice_cream"):
			if _DrinkCup.Extra_1 == "桃子块" and _DrinkCup.Extra_2 == "桃子块":
				if _DrinkCup.Condiment_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
					Liquid_Count = 5
					return "3号冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 2:
		if _DrinkCup.LIQUID_DIR.has("ice_yogurt") and _DrinkCup.LIQUID_DIR.has("ice_oat"):
			if _DrinkCup.Extra_1 == "火龙果块" or _DrinkCup.Extra_2 == "火龙果块" or _DrinkCup.Extra_3 == "火龙果块":
				if _DrinkCup.Extra_1 == "草莓" or _DrinkCup.Extra_2 == "草莓" or _DrinkCup.Extra_3 == "草莓":
					if _DrinkCup.Extra_1 == "桃子块" or _DrinkCup.Extra_2 == "桃子块" or _DrinkCup.Extra_3 == "桃子块":
						if _DrinkCup.Condiment_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
							Liquid_Count = 6
							return "4号冰"

	if _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if _DrinkCup.Extra_1 == "桑葚" or _DrinkCup.Extra_2 == "桑葚" or _DrinkCup.Extra_3 == "桑葚":
			if _DrinkCup.Extra_1 == "火龙果块" or _DrinkCup.Extra_2 == "火龙果块" or _DrinkCup.Extra_3 == "火龙果块":
				if _DrinkCup.Extra_1 == "西瓜块" or _DrinkCup.Extra_2 == "西瓜块" or _DrinkCup.Extra_3 == "西瓜块":
					if _DrinkCup.Condiment_1 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
						Liquid_Count = 4
						return "5号冰"

	if not _DrinkCup.HasIce and _DrinkCup.Liquid_Count == 0:
		if _DrinkCup.Extra_1 == "桑葚" or _DrinkCup.Extra_2 == "桑葚":
			if _DrinkCup.Extra_1 == "牛油果块" or _DrinkCup.Extra_2 == "牛油果块":
				if _DrinkCup.Condiment_1 == "" and _DrinkCup.Extra_3 == "" and _DrinkCup.Top == "" and _DrinkCup.Hang == "":
					Liquid_Count = 2
					return "6号冰"
	return ""
func call_Liquid():
	_ColorShow()
	var _SCALE = 0
	match Liquid_Count:
		1:
			_SCALE = 0.3
		2:
			_SCALE = 0.5
		3:
			_SCALE = 0.6
		4:
			_SCALE = 0.7
		5:
			_SCALE = 0.8
		6:
			_SCALE = 0.9
	$TexNode / Cup / Water.scale.y = _SCALE
func _ColorShow():

	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	$TexNode / Cup / Water.set_self_modulate(_color8)

func call_CupOff_puppet(_CUPID, _WaterType, _IsPassDay, _SugarType, _IceType, _WaterCelcius):
	WaterType = _WaterType
	IsPassDay = _IsPassDay
	SugarType = _SugarType
	IceType = _IceType
	WaterCelcius = _WaterCelcius
	var _DrinkCup = SteamLogic.OBJECT_DIC[_CUPID]

	MachineStat = 1
	call_Liquid()
	call_PassDay()
func call_Cup_Off(_DrinkCup):

	if _DrinkCup.IsStale:
		IsBroken = true
	elif _DrinkCup.IsPassDay:
		IsPassDay = true
	if _DrinkCup.get("SugarType"):
		SugarType = _DrinkCup.get("SugarType")
	else:
		SugarType = 0
	if _DrinkCup.get("HasIce"):
		IceType = 1
		WaterCelcius = - 10
	else:
		IceType = 0
		WaterCelcius = 20
	MachineStat = 1
	call_Liquid()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _CUPID = _DrinkCup._SELFID
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CupOff_puppet", [_CUPID, WaterType, IsPassDay, SugarType, IceType, WaterCelcius])
	call_UseANI(1)
	_DrinkCup.call_clear()

	call_PassDay()
func call_PassDay():
	if IsBroken:

		$Effect_flies / Ani.play("Flies")
	elif IsPassDay:
		$Effect_flies / Ani.play("OverDay")
	else:
		$Effect_flies / Ani.play("init")
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)

func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
