extends Head_Object
var SelfDev = "SugarMachine"

var UsedPowerCount: float = 0
var power: int = 1

var cur_sugar: int = 0
var cur_free: int = 0
var sugar_max: int = 9

onready var sugar_capacity_ani = $AniNode / SugarCapacity
onready var free_capacity_ani = $AniNode / FreeCapacity
onready var sugar_ani = $AniNode / Use
onready var UpgradeAni = $AniNode / Upgrade
onready var WarningNode = get_node("WarningNode")
onready var sugar_pro = $TexNode / UiPosition / Ui / TextureProgress
onready var free_pro = $TexNode / UiPosition / Ui_Free / TextureProgress
onready var A_But = get_node("But/A")
onready var Audio_Water = get_node("Audio")
onready var Audio_In
onready var Audio_Wrong

onready var MachineTypeAni = $AniNode / MachineType

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if $WarningNode.NeedFix and not _Player.Con.IsHold:
		$But / Y.show()
		$But / Y.InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/Y").Info_Str)
	else:
		$But / Y.hide()
	if CanMove and not _Player.Con.IsHold:
		get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_2)
	else:

		get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
		var _HOLD = null
		if _Player.Con.IsHold:
			_HOLD = _Player.Con.HoldObj.FuncType
			if _HOLD in ["SodaCan", "DrinkCup", "SuperCup"]:
				if cur_free:

					$But / Y.show()
				if cur_sugar:

					$But / A.show()
				else:
					$But / A.hide()

	.But_Switch(_bool, _Player)
	print(" 按键显示：", get_node("But/Y").visible)
func _ready() -> void :
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	get_node("But/Y").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/Y").Info_2)

	Audio_In = GameLogic.Audio.return_Effect("加糖")
	Audio_Wrong = GameLogic.Audio.return_Effect("错误1")

	if not GameLogic.is_connected("DayStart", self, "Update_Check"):
		var _CON = GameLogic.connect("DayStart", self, "Update_Check")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if CanLayout:
		CanMove = true

func _CanMove_Check():
	if CanLayout:
		CanMove = false
func call_sugar_puppet(_SUGAR, _FREE, _SUGARNAME, _FREENAME):
	cur_sugar = _SUGAR
	cur_free = _FREE
	sugar_pro.value = _SUGAR
	free_pro.value = _FREE
	if sugar_capacity_ani.has_animation(_SUGARNAME):
		sugar_capacity_ani.play(_SUGARNAME)
	if free_capacity_ani.has_animation(_FREENAME):
		free_capacity_ani.play(_FREENAME)
func sugar_capacity_show():

	sugar_pro.max_value = 4
	sugar_pro.value = cur_sugar
	free_pro.max_value = 4
	free_pro.value = cur_free

	var _SUGARNAME: String = "init"
	var _FREENAME: String = "init"
	var _LIST = GameLogic.Buy.Sell_1
	if not cur_sugar:
		if UpgradeAni.assigned_animation in ["EggRoll1", "EggRoll2", "EggRoll3"]:
			sugar_capacity_ani.play("ChocoEmpty")
			_SUGARNAME = "ChocoEmpty"
		elif _LIST.has("Sugar"):
			sugar_capacity_ani.play("Empty")
			_SUGARNAME = "Empty"
		else:
			sugar_capacity_ani.play("init")
			_SUGARNAME = "init"
	elif cur_sugar <= 1:
		sugar_capacity_ani.play("Few")
		_SUGARNAME = "Few"
	elif cur_sugar >= 4:
		sugar_capacity_ani.play("Full")
		_SUGARNAME = "Full"
	else:
		sugar_capacity_ani.play("Many")
		_SUGARNAME = "Many"
	if not cur_free:
		if _LIST.has("FreeSugar"):
			free_capacity_ani.play("Empty")
			_FREENAME = "Empty"
	elif cur_free <= 1:
		free_capacity_ani.play("Few")
		_FREENAME = "Few"
	elif cur_free >= 4:
		free_capacity_ani.play("Full")
		_FREENAME = "Full"
	else:
		free_capacity_ani.play("Many")
		_FREENAME = "Many"

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_sugar_puppet", [cur_sugar, cur_free, _SUGARNAME, _FREENAME])

	_CarrySpeed_Logic()

func Update_Check():
	if GameLogic.Order.SUGAR_FREE_BOOL or cur_free > 0:
		MachineTypeAni.play("two")
	else:
		MachineTypeAni.play("init")
	if GameLogic.cur_Rewards.has("果糖机升级"):
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	if GameLogic.cur_Rewards.has("果糖机升级+"):
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
	var _x = GameLogic.Buy.Sell_1
	var _y = GameLogic.cur_Menu
	var _z = GameLogic.cur_level
	if GameLogic.Buy.Sell_1.has("bag_eggroll_white") or GameLogic.Buy.Sell_1.has("bag_eggroll_black"):
		if GameLogic.cur_Rewards.has("果糖机升级"):
			if UpgradeAni.assigned_animation != "EggRoll2":
				UpgradeAni.play("EggRoll2")
		elif GameLogic.cur_Rewards.has("果糖机升级+"):
			if UpgradeAni.assigned_animation != "EggRoll3":
				UpgradeAni.play("EggRoll3")
		else:
			if UpgradeAni.assigned_animation != "EggRoll1":
				UpgradeAni.play("EggRoll1")

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)

	cur_sugar = int(_Info.cur_sugar)
	if _Info.has("cur_free"):
		cur_free = int(_Info.cur_free)
	sugar_capacity_show()

func call_Audio():
	Audio_In.play(0)
func _CarrySpeed_Logic():
	if cur_sugar + cur_free > 0:
		CarrySpeed = 0.75 - (float(cur_sugar + cur_free) / float(18)) * 0.7
	if CarrySpeed < 0.1:
		CarrySpeed = 0.1

func call_sugar_in_cup(_ButID, _CupObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _CupObj.has_method("call_Sugar_In"):
				if cur_sugar > 0 or cur_free > 0:
					But_Switch(true, _Player)

		0:

			if $WarningNode.NeedFix:
				return
			if _CupObj.has_method("call_Sugar_In"):
				if cur_sugar:

					if _CupObj.FuncType in ["EggRollCup"]:
						if _CupObj.Liquid_Count == 0:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
							return
					if _CupObj.FuncType in ["SodaCan"]:
						if _CupObj.IsPack:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_PickFinished()
							return
					if not _CupObj.SugarType:
						if GameLogic.Device.return_CanUse_bool(_Player):
							return

						if _CupObj.Top != "":
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
							return
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return
						var _UsedSugar: bool = true
						if GameLogic.cur_Rewards.has("果糖机升级"):
							var _rand = GameLogic.return_randi() % 4
							if _rand == 0:
								_UsedSugar = false
						elif GameLogic.cur_Rewards.has("果糖机升级+"):
							var _rand = GameLogic.return_randi() % 4
							if _rand > 0:
								_UsedSugar = false
						if GameLogic.Achievement.cur_EquipList.has("节糖装置") and not GameLogic.SPECIALLEVEL_Int:
							if _UsedSugar:
								var _rand = GameLogic.return_randi() % 4
								if _rand == 0:
									_UsedSugar = false

						if _UsedSugar:
							cur_sugar -= 1
						GameLogic.Tutorial.call_AddSugar()
						_CupObj.call_Sugar_In(1)
						GameLogic.call_StatisticsData_Set("Count_Sugar", null, 1)

						$WarningNode.return_Fix()
						var _ISCOMBO: bool
						if GameLogic.cur_Rewards.has("果糖机升级"):

							var _Rand = GameLogic.return_randi() % 100
							var _RAT = 10
							if _Rand < _RAT:

								$AniNode / ComboAni.play("init")
								$AniNode / ComboAni.play("combo")
								GameLogic.call_combo(1)
								_ISCOMBO = true
						elif GameLogic.cur_Rewards.has("果糖机升级+"):
							var _Rand = GameLogic.return_randi() % 100
							var _RAT = 30
							if _Rand < _RAT:

								$AniNode / ComboAni.play("init")
								$AniNode / ComboAni.play("combo")
								GameLogic.call_combo(1)
								_ISCOMBO = true
						if _ISCOMBO:
							call_Extra()
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _PLAYERPATH = _Player.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_Ani_puppet", ["use", cur_sugar, cur_free, _PLAYERPATH, _ISCOMBO])
						sugar_ani.play("use")
						sugar_capacity_show()
						if $WarningNode.NeedFix:
							$AudioStreamPlayer2D.play(0)

						But_Switch(false, _Player)
						return "加糖"
				else:
					WarningNode.call_Empty()
		3:

			if $WarningNode.NeedFix:
				return
			if _CupObj.has_method("call_Sugar_In"):
				if cur_free:
					if _CupObj.FuncType in ["SodaCan"]:
						if _CupObj.IsPack:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_PickFinished()
							return
					if not _CupObj.SugarType:
						if GameLogic.Device.return_CanUse_bool(_Player):
							return
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return
						if _CupObj.Top != "":
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NoUse()
							return
						var _UsedSugar: bool = true
						if GameLogic.cur_Rewards.has("果糖机升级"):
							var _rand = GameLogic.return_randi() % 4
							if _rand == 0:
								_UsedSugar = false
						elif GameLogic.cur_Rewards.has("果糖机升级+"):
							var _rand = GameLogic.return_randi() % 2
							if _rand == 0:
								_UsedSugar = false
						if GameLogic.Achievement.cur_EquipList.has("节糖装置") and not GameLogic.SPECIALLEVEL_Int:
							if _UsedSugar:
								var _rand = GameLogic.return_randi() % 4
								if _rand == 0:
									_UsedSugar = false

						if _UsedSugar:
							cur_free -= 1
						GameLogic.Tutorial.call_AddSugar()
						_CupObj.call_Sugar_In(2)

						GameLogic.call_StatisticsData_Set("Count_Sugar", null, 1)
						$WarningNode.return_Fix()
						var _ISCOMBO: bool
						if GameLogic.cur_Rewards.has("果糖机升级"):

							var _Rand = GameLogic.return_randi() % 100
							if _Rand < 15:

								$AniNode / ComboAni.play("init")
								$AniNode / ComboAni.play("combo")
								GameLogic.call_combo(1)
								_ISCOMBO = true
						elif GameLogic.cur_Rewards.has("果糖机升级+"):
							var _Rand = GameLogic.return_randi() % 100
							if _Rand < 30:

								$AniNode / ComboAni.play("init")
								$AniNode / ComboAni.play("combo")
								GameLogic.call_combo(1)
								_ISCOMBO = true
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _PLAYERPATH = _Player.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_Ani_puppet", ["use", cur_sugar, cur_free, _PLAYERPATH, _ISCOMBO])
						if _ISCOMBO:
							call_Extra()
						sugar_ani.play("use")
						sugar_capacity_show()
						if $WarningNode.NeedFix:
							$AudioStreamPlayer2D.play(0)

						But_Switch(false, _Player)
						return "加糖"
				else:
					WarningNode.call_Empty()

func call_Ani_puppet(_NAME, _CURSUGAR, _FREE, _PLAYERPATH, _ISCOMBO: bool):
	var _Player = get_node(_PLAYERPATH)
	cur_sugar = _CURSUGAR
	cur_free = _FREE
	sugar_ani.play(_NAME)
	match _NAME:

		"use":

			GameLogic.call_StatisticsData_Set("Count_Sugar", null, 1)
	sugar_capacity_show()
	if _ISCOMBO:
		$AniNode / ComboAni.play("init")
		$AniNode / ComboAni.play("combo")
		call_Extra()
	But_Switch(false, _Player)
func call_addsugar(_butID, _sugarItem, _Player):
	var _FUNCTYPE = _sugarItem.get("FuncType")
	if not _FUNCTYPE in ["Sugar", "FreeSugar", "Choco"]:
		return

	var _sugarcheck = 5 + cur_sugar
	match _FUNCTYPE:
		"FreeSugar":
			_sugarcheck = 5 + cur_free
	if _sugarcheck <= sugar_max:
		match _butID:
			- 2:
				But_Switch(false, _Player)
			- 1:
				But_Switch(true, _Player)
			0:
				if _sugarItem.get("Freshless_bool"):
					return
				if _sugarItem.Used:
					return
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _SugarAniName: String = "in"
				match _FUNCTYPE:
					"Choco":
						cur_sugar += 5
						if cur_sugar > sugar_max:
							cur_sugar = sugar_max
						_SugarAniName = "in_choco"

					"Sugar":
						cur_sugar += 5
						if cur_sugar > sugar_max:
							cur_sugar = sugar_max
					"FreeSugar":
						cur_free += 5
						if cur_free > sugar_max:
							cur_free = sugar_max
						_SugarAniName = "in_free"

				_sugarItem.call_used()
				sugar_ani.play(_SugarAniName)
				_Player.Stat.call_carry_on(_sugarItem.CarrySpeed)
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAERPATH = _Player.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Ani_puppet", [_SugarAniName, cur_sugar, cur_free, _PLAERPATH, false])
					SteamLogic.call_puppet_id_sync(_sugarItem._SELFID, "call_used")
				sugar_capacity_show()

				Audio_Water.play(0)
				But_Switch(false, _Player)
				return "补糖"
	else:
		if not _sugarItem.Used:
			WarningNode.call_Full()

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

func call_Fix_Logic(_Player):
	if $WarningNode.return_Fixing(_Player):
		sugar_ani.play("fix")
		GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

		But_Switch(true, _Player)
	else:
		sugar_ani.play("fix")
func call_Fix_Ani(_Player):
	sugar_ani.play("init")
	sugar_ani.play("fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
