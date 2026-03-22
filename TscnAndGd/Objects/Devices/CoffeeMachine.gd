extends Head_Object
var SelfDev = "CoffeeMachine"

var cur_CoffeeBean: int
var cur_Milk: int
var CoffeeBeanMax: int = 14
var HasMilk: bool
var HasCup: bool
var MilkOBJ
var CupOBJ
var cur_TYPE: int = 1
var cur_NUM: int = 0
var cur_Dic: Dictionary = {
	"water": false,
	"coffee": false,
	"milk": false,
	"foam": false
}

onready var CupNode = $TexNode / DrinkCupNode
onready var MilkNode = $TexNode / MilkNode
onready var SettingAni = $AniNode / Setting
onready var ChooseAni = $UI / ChooseBG / Ani / AnimationPlayer
onready var WaterNode = $TexNode / WaterPosition / water

onready var Choose_1 = $UI / Record / Process_1
onready var Choose_2 = $UI / Record / Process_2
onready var Choose_3 = $UI / Record / Process_3
onready var Choose_4 = $UI / Record / Process_4
var _CHECKLIST: Array
var _CHOOSELIST: Array
var _FINISHLIST: Array
var Can_Pick: bool = true
var _SPEEDMULT: float = 1
var _POWERBASE: float = 0.5
var IsBlackOut: bool = false
var _POWERCOUNT: float
func _DayClosedCheck():

	pass
func _ready() -> void :
	call_init(SelfDev)
	call_deferred("Update_Check")
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("DayStart", self, "call_UI_init"):
		var _con = GameLogic.connect("DayStart", self, "call_UI_init")

	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	_CanMove_Check()
func _CanMove_Check():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if CanLayout:
		if not HasMilk and not HasCup:
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
	_SPEEDMULT = 1 / GameLogic.return_Multiplier_Division()
	var _MULT: float = 1
	if GameLogic.cur_Rewards.has("咖啡机升级"):
		CoffeeBeanMax = 24
		_MULT += 1
		$AniNode / Upgrade.play("2")

	elif GameLogic.cur_Rewards.has("咖啡机升级+"):
		CoffeeBeanMax = 24

		_MULT += 5
		$AniNode / Upgrade.play("3")
	else:
		$AniNode / Upgrade.play("1")

	if GameLogic.cur_Challenge.has("电压不稳"):
		_MULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_MULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_MULT -= 0.4
	if GameLogic.Achievement.cur_EquipList.has("制冰装置") and not GameLogic.SPECIALLEVEL_Int:
		_MULT += 0.2
	_SPEEDMULT = _SPEEDMULT * _MULT
	if _SPEEDMULT < 0:
		_SPEEDMULT = 0
func _BlackOut(_Switch):
	IsBlackOut = _Switch

	call_Make_Continue()

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	cur_CoffeeBean = _Info.CoffeeBean
	HasMilk = _Info.HasMilk
	HasCup = _Info.HasCup

	if _Info.Cup == null:
		HasCup = false
	if _Info.MilkBottle == null:
		HasCup = false

	if HasMilk:
		var _MilkData = _Info.MilkBottle
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_MilkData.TSCN)
		var _Dev = _TSCN.instance()
		_Dev.position = _MilkData.pos
		_Dev.name = _MilkData.NAME
		MilkNode.add_child(_Dev)
		MilkOBJ = _Dev
		_Dev.call_load(_MilkData)
		call_Milk_logic()
	if HasCup:

		var _CupData = _Info.Cup
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_CupData.TSCN)
		var _Dev = _TSCN.instance()
		_Dev.position = _CupData.pos
		_Dev.name = _CupData.NAME
		CupNode.add_child(_Dev)
		_Dev.call_load(_CupData)
		CupOBJ = _Dev

	_Coffee_Show()
	_CanMove_Check()
func But_Switch(_Switch, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if is_instance_valid(MilkOBJ):
		get_node("But/B").show()
	else:
		get_node("But/B").hide()
	if is_instance_valid(CupOBJ):
		$But / X.show()
	else:
		$But / X.hide()
	if CanMove and not _Player.Con.IsHold:
		get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message("BUT-搬运")
		get_node("But/A").show()
		$But / Y.show()
	elif is_instance_valid(_Player.Con.HoldObj):
		var _TYPE = _Player.Con.HoldObj.FuncType
		if _Player.Con.HoldObj.FuncTypePara in ["milk"]:
			get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_2)
			get_node("But/A").show()
			$But / X.hide()
		elif _Player.Con.HoldObj.FuncType in ["DrinkCup"]:
			get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
			get_node("But/A").show()
			get_node("But/B").hide()
		elif _Player.Con.HoldObj.FuncType in ["CoffeeBean"]:
			get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message("BUT-加入")
			get_node("But/A").show()
			get_node("But/B").hide()
			$But / X.hide()
		else:
			get_node("But/A").hide()
			get_node("But/B").hide()
			$But / X.hide()
	else:
		if is_instance_valid(MilkOBJ):
			get_node("But/A").hide()
	if not _Player.Con.IsHold and is_instance_valid(CupOBJ):
		get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_1)
		get_node("But/A").show()



	match _Switch:
		true:
			if not _PLAYERLIST.has(_Player.name):
				_PLAYERLIST.append(_Player.name)
			if _PLAYERLIST.size():
				if SettingAni.assigned_animation != "show":
					SettingAni.play("show")
		false:
			if _PLAYERLIST.has(_Player.name):
				_PLAYERLIST.erase(_Player.name)
			if not _PLAYERLIST.size():
				SettingAni.play("init")

	.But_Switch(_Switch, _Player)
var _PLAYERLIST: Array

func call_WaterStain():
	if _FINISHLIST.size():
		var _LastFINISH = _FINISHLIST.back()
		match _LastFINISH:
			"coffee":
				GameLogic.Liquid.call_WaterStain(CupOBJ.global_position, 1, "coffee_1", null)
			"foam":
				GameLogic.Liquid.call_WaterStain(CupOBJ.global_position, 1, "white_1", null)
			"milk":
				GameLogic.Liquid.call_WaterStain(CupOBJ.global_position, 1, "white_1", null)
			"water":
				GameLogic.Liquid.call_WaterStain(CupOBJ.global_position, 1, "water", null)

func call_Cup_Take(_Player):
	GameLogic.Device.call_Player_Pick(_Player, CupOBJ)

func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				return
			But_Switch(false, _Player)

		- 1:
			if not _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				return

			$But / X.show()
			$But / Y.show()
			But_Switch(true, _Player)

		0:
			if not Can_Pick:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_Making()
				return
			if is_instance_valid(CupOBJ):
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return

				call_Cup_Take(_Player)




		1:
			if is_instance_valid(MilkOBJ):

				var _OBJ = MilkOBJ

				GameLogic.Device.call_Player_Pick(_Player, MilkOBJ)
				call_Milk_logic()
				call_Milk_Put( - 1, _OBJ, _Player)
		2:

			if $WarningNode.NeedFix:
				return
			if IsBlackOut:
				return
			if is_instance_valid(CupOBJ):
				var _NUM = CupOBJ.Liquid_Max - CupOBJ.Liquid_Count
				var _CHOOSE = _CHECKLIST[cur_TYPE - 1]

				if _CHOOSELIST.size() < _NUM:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return
					_CHOOSELIST.append(_CHOOSE)
					var _AUDIO = GameLogic.Audio.return_Effect("敲键盘1")
					_AUDIO.play(0)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "call_Choose_puppet", [_CHOOSELIST])
				else:
					if _CHOOSELIST.size() - _FINISHLIST.size() < _NUM:
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return
						_CHOOSELIST.append(_CHOOSE)
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_id_sync(_SELFID, "call_Choose_puppet", [_CHOOSELIST])
						var _AUDIO = GameLogic.Audio.return_Effect("敲键盘1")
						_AUDIO.play(0)
					else:
						if _Player.name in [str(SteamLogic.STEAM_ID), "1", "2"]:
							_Player.call_Say_NoAdd()
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			call_CHOOSE_logic()
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

				return
			if $WarningNode.NeedFix:
				if not _Player.Con.IsHold:

					call_Fix_Logic(_Player)
				return
			if IsBlackOut:
				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_turn_logic")
			call_turn_logic()

func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	GameLogic.Audio.But_SwitchOn.play(0)
	But_Switch(true, _Player)
	$AniNode / Add.play("fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if $WarningNode.return_Fixing(_Player):
		$AniNode / Add.play("fix")
		But_Switch(true, _Player)

func call_Fixing_Ani(_Player):
	$AniNode / Add.play("init")
	$AniNode / Add.play("fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_pick_puppet(_TYPE, _OBJPATH, _PLAYERPATH):

	var _Player = get_node(_PLAYERPATH)
	var _OBJ
	if has_node(_OBJPATH):
		_OBJ = get_node(_OBJPATH)
	match _TYPE:
		0:
			if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				CupOBJ.call_CupInfo_Switch(true)
			CupOBJ = null
			HasCup = false
			call_CHOOSE_RESET()
			if _Player.name in [str(SteamLogic.STEAM_ID), "1", "2"]:
				call_drinkcup_logic( - 1, CupOBJ, _Player)
			if is_instance_valid(_OBJ):
				CupNode.remove_child(_OBJ)
				GameLogic.Device.call_Player_Pick(_Player, _OBJ)

		1:

			MilkOBJ = null
			HasMilk = false

			if is_instance_valid(_OBJ):
				MilkNode.remove_child(_OBJ)
				GameLogic.Device.call_Player_Pick(_Player, _OBJ)
				if _Player.name in [str(SteamLogic.STEAM_ID), "1", "2"]:
					call_Milk_Put( - 1, _OBJ, _Player)
func call_Choose_puppet(_LIST):
	_CHOOSELIST = _LIST
	var _AUDIO = GameLogic.Audio.return_Effect("敲键盘1")
	_AUDIO.play(0)
	call_CHOOSE_logic()
func call_CHOOSE_logic():
	var _NUM: int = 1


	for _NAME in _CHOOSELIST:
		if _NUM >= 5:
			_CHOOSELIST.erase(_NAME)
		else:
			var _NODENAME = "Process_" + str(_NUM)
			var _ANINAME = _NAME
			var _ANI = get_node("UI/Record").get_node(_NODENAME).get_node("AnimationPlayer")
			if _ANI.assigned_animation == "init":

				_ANI.play(_ANINAME)
				if _CHOOSELIST.size() - _FINISHLIST.size() == 1:
					call_Make_Logic(_NUM - 1)
		_NUM += 1

func call_Make_Continue():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if IsBlackOut:
		return

	for _i in 4:
		var _NAME = "Process_" + str(_i + 1)
		var _Ani = get_node("UI/Record").get_node(_NAME).get_node("AnimationPlayer")
		var _COFFEEANINAME = "init"
		if _Ani.current_animation in ["coffee_run", "foam_run", "milk_run", "water_run"]:

			break
		elif _Ani.assigned_animation == "coffee":
			if cur_CoffeeBean > 0:
				_Ani.playback_speed = _SPEEDMULT

				$AniNode / Use.playback_speed = _SPEEDMULT
				_Ani.play("coffee_run")
				$AniNode / Coffee.play("init")
				cur_CoffeeBean -= 1
				_Coffee_Show()
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_i, Can_Pick, 1, "coffee_run", _COFFEEANINAME, _SPEEDMULT])
			else:
				$AniNode / Coffee.play("Empty")
				_COFFEEANINAME = "Empty"
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_i, Can_Pick, 0, "Coffee", _COFFEEANINAME, _SPEEDMULT])
			break

		elif _Ani.assigned_animation in ["foam", "milk"]:
			var _ANINAME
			if cur_Milk > 0:
				_ANINAME = _Ani.assigned_animation + "_run"
				_Ani.playback_speed = _SPEEDMULT
				$AniNode / Use.playback_speed = _SPEEDMULT
				_Ani.play(_ANINAME)
				$AniNode / Milk.play("init")
				MilkOBJ.Liquid_Count -= 1
				MilkOBJ.call_Milk_Show()

				if MilkOBJ.Liquid_Count <= 0:
					MilkOBJ.call_Empty()
				call_Milk_logic()
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_i, Can_Pick, 2, _ANINAME, _COFFEEANINAME, _SPEEDMULT])
			else:
				$AniNode / Milk.play("Empty")
				_COFFEEANINAME = "Empty"
				$AniNode / Use.playback_speed = 1
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_i, Can_Pick, 0, "Milk", _COFFEEANINAME, _SPEEDMULT])
			break

func call_Make_Logic(_NUM: int):
	Can_Pick = true
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _NUM == 4:
		return
	if $WarningNode.NeedFix:
		return
	var _NAME = "Process_" + str(_NUM + 1)
	var _Ani = get_node("UI/Record").get_node(_NAME).get_node("AnimationPlayer")
	if _Ani.assigned_animation == "coffee":
		var _COFFEEANINAME = "init"
		if cur_CoffeeBean > 0:
			_Ani.playback_speed = _SPEEDMULT
			_Ani.play("coffee_run")

			Can_Pick = false
			cur_CoffeeBean -= 1
			$WarningNode.return_Fix()
			_Coffee_Show()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_NUM, Can_Pick, 1, "coffee_run", _COFFEEANINAME, _SPEEDMULT])
		else:
			$AniNode / Coffee.play("Empty")
			Can_Pick = true
			_COFFEEANINAME = "Empty"
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_NUM, Can_Pick, 0, "Coffee", _COFFEEANINAME, _SPEEDMULT])
	elif _Ani.assigned_animation in ["foam", "milk"]:
		var _MILKANINAME = "init"
		var _ANINAME
		if cur_Milk > 0 and not MilkOBJ.Freshless_bool:
			_Ani.playback_speed = _SPEEDMULT
			_ANINAME = _Ani.assigned_animation + "_run"
			_Ani.play(_ANINAME)
			Can_Pick = false
			MilkOBJ.Liquid_Count -= 1
			MilkOBJ.call_Milk_Show()
			if MilkOBJ.Liquid_Count <= 0:
				MilkOBJ.call_Empty()
			$WarningNode.return_Fix()

			call_Milk_logic()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_NUM, Can_Pick, 2, _ANINAME, _MILKANINAME, _SPEEDMULT])
		else:
			$AniNode / Milk.play("Empty")
			Can_Pick = true
			_MILKANINAME = "Empty"
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_NUM, Can_Pick, 0, "Milk", _MILKANINAME, _SPEEDMULT])
	elif _Ani.assigned_animation == "water":
		var _COFFEEANINAME = "init"
		_Ani.playback_speed = _SPEEDMULT
		_Ani.play("water_run")
		Can_Pick = false
		GameLogic.Total_Water += float(1)
		$WarningNode.return_Fix()
		_Coffee_Show()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_puppet", [_NUM, Can_Pick, 1, "water_run", _COFFEEANINAME, _SPEEDMULT])

	else:
		Can_Pick = true
	if $WarningNode.NeedFix:
		$Audio3.play(0)
		pass
func call_Make_puppet(_NUM, _CANPICK, _TYPE, _ANINAME, _EMPTYANI, _MULT):
	_SPEEDMULT = _MULT
	match _TYPE:
		0:
			Can_Pick = _CANPICK
			match _ANINAME:
				"Milk":
					$AniNode / Milk.play("Empty")
				"Coffee":
					$AniNode / Coffee.play("Empty")
		1:
			Can_Pick = _CANPICK
			var _NAME = "Process_" + str(_NUM + 1)
			var _Ani = get_node("UI/Record").get_node(_NAME).get_node("AnimationPlayer")
			_Ani.playback_speed = _SPEEDMULT
			_Ani.play(_ANINAME)
			$AniNode / Coffee.play(_EMPTYANI)
		2:
			Can_Pick = _CANPICK
			var _NAME = "Process_" + str(_NUM + 1)
			var _Ani = get_node("UI/Record").get_node(_NAME).get_node("AnimationPlayer")
			_Ani.playback_speed = _SPEEDMULT
			_Ani.play(_ANINAME)
			$AniNode / Milk.play(_EMPTYANI)
		3:
			Can_Pick = _CANPICK
			GameLogic.Total_Water += float(1)
			var _NAME = "Process_" + str(_NUM + 1)
			var _Ani = get_node("UI/Record").get_node(_NAME).get_node("AnimationPlayer")
			_Ani.playback_speed = _SPEEDMULT
			_Ani.play(_ANINAME)
func call_add_show(_WATERTYPE):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_add_puppet", [_WATERTYPE])
	var _color8 = GameLogic.Liquid.return_color_set(_WATERTYPE)
	WaterNode.set_modulate(_color8)

	$AniNode / Add.play("add")
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
func call_add_puppet(_WATERTYPE):
	var _color8 = GameLogic.Liquid.return_color_set(_WATERTYPE)
	WaterNode.set_modulate(_color8)

	$AniNode / Add.play("add")
	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)
func call_Coffee_InCup(_CurNum: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		Can_Pick = true
		return
	_FINISHLIST.append("coffee")
	var _WATERTYPE = "coffeemaker_coffee"
	var _CELCIUS = 25
	GameLogic.Total_Electricity += _POWERBASE
	_POWERCOUNT += _POWERBASE
	call_add_show(_WATERTYPE)
	CupOBJ.call_CoffeeMachine_In(_WATERTYPE, SelfDev, _CELCIUS)
	call_Make_Logic(_CurNum)
func call_Water_InCup(_CurNum: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		Can_Pick = true
		return
	_FINISHLIST.append("water")
	var _WATERTYPE = "water"
	var _CELCIUS = 85
	GameLogic.Total_Electricity += _POWERBASE
	_POWERCOUNT += _POWERBASE
	GameLogic.Total_Water += 1
	call_add_show(_WATERTYPE)
	CupOBJ.call_CoffeeMachine_In(_WATERTYPE, SelfDev, _CELCIUS)
	call_Make_Logic(_CurNum)
func call_Milk_InCup(_CurNum: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		Can_Pick = true
		return
	_FINISHLIST.append("milk")
	var _WATERTYPE = "ice_milk"
	var _CELCIUS = 25
	GameLogic.Total_Electricity += _POWERBASE * 0.1
	_POWERCOUNT += _POWERBASE
	call_add_show(_WATERTYPE)
	CupOBJ.call_CoffeeMachine_In(_WATERTYPE, SelfDev, _CELCIUS)
	if is_instance_valid(MilkOBJ):
		if MilkOBJ.IsPassDay:
			CupOBJ.call_add_PassDay()
	call_Make_Logic(_CurNum)
func call_Foam_InCup(_CurNum: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		Can_Pick = true
		return
	_FINISHLIST.append("foam")
	var _WATERTYPE = "coffeemaker_milkfoam"
	var _CELCIUS = 85
	GameLogic.Total_Electricity += _POWERBASE * 2
	_POWERCOUNT += _POWERBASE
	call_add_show(_WATERTYPE)
	CupOBJ.call_CoffeeMachine_In(_WATERTYPE, SelfDev, _CELCIUS)
	call_Make_Logic(_CurNum)
func call_CHOOSE_RESET():

	_FINISHLIST.clear()
	_CHOOSELIST.clear()
	for _NUM in 4:
		var _NODENAME = "Process_" + str(_NUM + 1)
		get_node("UI/Record").get_node(_NODENAME).get_node("AnimationPlayer").play("init")
	$AniNode / Milk.play("init")
	$AniNode / Coffee.play("init")
	_CanMove_Check()
func call_turn_logic():

	match cur_NUM:
		1:
			return
		2:
			match cur_TYPE:
				1:
					ChooseAni.play("0-180")
					cur_TYPE = 2
				2:
					ChooseAni.play("180-360")
					cur_TYPE = 1
		3:
			match cur_TYPE:
				1:
					ChooseAni.play("0-120")
					cur_TYPE = 2
				2:
					ChooseAni.play("120-240")
					cur_TYPE = 3
				3:
					ChooseAni.play("240-360")
					cur_TYPE = 1
		4:
			match cur_TYPE:
				1:
					ChooseAni.play("0-90")
					cur_TYPE = 2
				2:
					ChooseAni.play("90-180")
					cur_TYPE = 3
				3:
					ChooseAni.play("180-270")
					cur_TYPE = 4
				4:
					ChooseAni.play("270-360")
					cur_TYPE = 1
	_Icon_Set()
	var _AUDIO = GameLogic.Audio.return_Effect("气泡")
	_AUDIO.play(0)
func call_Milk_logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if is_instance_valid(MilkOBJ):
		var _NUM = MilkOBJ.Liquid_Count
		cur_Milk = _NUM
	else:
		cur_Milk = 0
	$TexNode / Milk / Progress.value = cur_Milk
	if cur_Milk > 0:
		$AniNode / Milk.play("init")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Milk_puppet", [cur_Milk])
	_CanMove_Check()
func call_Milk_puppet(_MILKNUM):
	cur_Milk = _MILKNUM
	$TexNode / Milk / Progress.value = cur_Milk
	if cur_Milk > 0:
		$AniNode / Milk.play("init")
func _Icon_Set():
	var _TEX = get_node("UI/ChooseBG").get_node(str(cur_TYPE)).get_texture()
	get_node("TexNode/box/Icon").set_texture(_TEX)

func call_UI_puppet(_LIST):
	_CHECKLIST = _LIST
	var _waterTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_water_hot.tres"
	var _coffeeTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_condensed_coffee.tres"
	var _milkTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_bottle_milk.tres"
	var _foamTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_condensed_milkfoam.tres"
	cur_NUM = 0
	for _NAME in _CHECKLIST:
		cur_NUM += 1
		var _TEX
		match _NAME:
			"water":
				_TEX = _waterTEX
			"coffee":
				_TEX = _coffeeTEX
			"milk":
				_TEX = _milkTEX
			"foam":
				_TEX = _foamTEX
		if not _TEX:
			printerr("错误，未获得任何可使用咖啡机的配方。")
			return
		var _LOAD = load(_TEX)
		var _NODENAME = "UI/ChooseBG/" + str(cur_NUM)
		get_node(_NODENAME).set_texture(_LOAD)
	if cur_NUM > 0:
		$UI / ChooseBG / Ani / TypeAni.play(str(cur_NUM))
	_Icon_Set()
func call_UI_init():


	var _waterTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_water_hot.tres"
	var _coffeeTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_condensed_coffee.tres"
	var _milkTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_bottle_milk.tres"
	var _foamTEX = "res://Resources/UI/GameUI/ui_pack.sprites/Icon_liquid_condensed_milkfoam.tres"
	var _NUM: int = 0

	for _MENU in GameLogic.cur_Menu:
		var _INFO = GameLogic.Config.FormulaConfig[_MENU]
		var _FormulaNum = _INFO.FormulaNum

		for _i in int(_FormulaNum):
			var _NAME = "For_" + str(_i + 1)
			var _FOR = _INFO[_NAME]

			if _FOR == "water" and cur_Dic.water == false:
				cur_Dic.water = true
				_NUM += 1
			if _FOR == "coffeemaker_coffee" and cur_Dic.coffee == false:
				cur_Dic.coffee = true
				_NUM += 1
			if _FOR == "ice_milk" and cur_Dic.milk == false:
				cur_Dic.milk = true
				_NUM += 1
			if _FOR == "coffeemaker_milkfoam" and cur_Dic.foam == false:
				cur_Dic.foam = true
				_NUM += 1


	if cur_Dic.water:
		if not _CHECKLIST.has("water"):
			_CHECKLIST.append("water")
	if cur_Dic.coffee:
		if not _CHECKLIST.has("coffee"):
			_CHECKLIST.append("coffee")
	if cur_Dic.milk:
		if not _CHECKLIST.has("milk"):
			_CHECKLIST.append("milk")
	if cur_Dic.foam:
		if not _CHECKLIST.has("foam"):
			_CHECKLIST.append("foam")

	cur_NUM = 0
	for _NAME in _CHECKLIST:
		cur_NUM += 1
		var _TEX
		match _NAME:
			"water":
				_TEX = _waterTEX
			"coffee":
				_TEX = _coffeeTEX
			"milk":
				_TEX = _milkTEX
			"foam":
				_TEX = _foamTEX
		if not _TEX:
			printerr("错误，未获得任何可使用咖啡机的配方。")
			return
		var _LOAD = load(_TEX)
		var _NODENAME = "UI/ChooseBG/" + str(cur_NUM)
		get_node(_NODENAME).set_texture(_LOAD)
	if cur_NUM > 0:
		$UI / ChooseBG / Ani / TypeAni.play(str(cur_NUM))
	_Icon_Set()

func call_Milk_Put(_ButID, _MilkOBJ, _Player):

	if _MilkOBJ.FuncTypePara == "milk":
		match _ButID:
			- 2:
				if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					return
				But_Switch(false, _Player)
				SettingAni.play("init")
			- 1:
				if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					return

				if is_instance_valid(MilkOBJ):
					return
				get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
				$But / A.show()
				$But / B.hide()
				$But / X.hide()
				$But / Y.hide()
				But_Switch(true, _Player)
				SettingAni.play("show")
			0:
				if is_instance_valid(MilkOBJ):
					return
				if GameLogic.Device.return_CanUse_bool(_Player):
					return

				if not _MilkOBJ.IsOpen:

					if _Player.name in [str(SteamLogic.STEAM_ID), "1", "2"]:
						_Player.call_Say_NeedOpen()
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				_Milk_Put_Logic(_MilkOBJ, _Player)
func _Milk_Put_Logic(_MilkOBJ, _Player):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _OBJPATH = _MilkOBJ.get_path()
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_MilkPut_puppet", [_OBJPATH, _PLAYERPATH])
	HasMilk = true
	MilkOBJ = _MilkOBJ
	_Player.WeaponNode.remove_child(_MilkOBJ)
	_MilkOBJ.position = Vector2.ZERO
	_Player.Stat.call_carry_off()
	MilkNode.add_child(_MilkOBJ)

	var _AUDIO = GameLogic.Audio.return_Effect("放下包")
	_AUDIO.play(0)
	$AniNode / AddMilkBox.play("AddMilkBox")
	call_MachineControl( - 1, _Player)
	call_Milk_logic()
	call_Make_Continue()
func call_MilkPut_puppet(_OBJPATH, _PLAYERPATH):
	var _MilkOBJ = get_node(_OBJPATH)
	var _Player = get_node(_PLAYERPATH)
	_Milk_Put_Logic(_MilkOBJ, _Player)

func call_addCoffeeBean(_butID, _Item, _Player):

	var _check = int(_Item.FuncTypePara) + cur_CoffeeBean
	if _check <= CoffeeBeanMax:
		match _butID:
			- 2:
				if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					return
				But_Switch(false, _Player)
			- 1:
				if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					return
				if _Item.Used:
					return
				get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_2)
				$But / A.show()
				$But / B.hide()
				$But / X.hide()
				$But / Y.hide()
				But_Switch(true, _Player)
			0:
				if _Item.get("Freshless_bool"):
					return
				if _Item.Used:
					return
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				_add_bean()
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				cur_CoffeeBean += int(_Item.FuncTypePara)
				_Coffee_Show()
				_Item.call_used()

				_Player.Stat.call_carry_on(_Item.CarrySpeed)
				call_Make_Continue()
func _add_bean():
	$AniNode / AddCoffeeBean.play("AddCoffeeBean")
	var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
	_AUDIO.play(0)
	$But / A.hide()
func call_drinkcup_logic(_butID, _Cup, _Player):
	match _butID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
			SettingAni.play("init")
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if is_instance_valid(CupOBJ):
				return

			get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
			$But / A.show()
			$But / B.hide()
			$But / X.hide()
			$But / Y.hide()
			But_Switch(true, _Player)
			SettingAni.play("show")
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if not is_instance_valid(CupOBJ):
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAYERPATH = _Player.get_path()
					var _OBJPATH = _Cup.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_drinkcup_puppet", [_PLAYERPATH, _OBJPATH])
				_DrinkCup_Put(_Cup, _Player)
func call_drinkcup_puppet(_PLAYERPATH, _OBJPATH):
	var _Player = get_node(_PLAYERPATH)
	var _CupOBJ = get_node(_OBJPATH)
	_DrinkCup_Put(_CupOBJ, _Player)
func _DrinkCup_Put(_Cup, _Player):
	_Player.WeaponNode.remove_child(_Cup)
	_Player.Stat.call_carry_off()
	_Cup.position = Vector2.ZERO
	CupNode.add_child(_Cup)
	var _AUDIO = GameLogic.Audio.return_Effect("放下塑料")
	_AUDIO.play(0)
	_Cup.call_CupInfo_Hide()
	CupOBJ = _Cup
	HasCup = true
	Can_Pick = true
	call_MachineControl( - 1, _Player)
	_CanMove_Check()
func _Coffee_Show():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CoffeeShow_puppet", [cur_CoffeeBean])
	var _Pro = $TexNode / Coffee / Progress
	_Pro.max_value = CoffeeBeanMax - 9
	_Pro.value = cur_CoffeeBean
	if cur_CoffeeBean > 0:
		$AniNode / Coffee.play("init")
func call_CoffeeShow_puppet(_BEAN):
	cur_CoffeeBean = _BEAN
	var _Pro = $TexNode / Coffee / Progress
	_Pro.value = cur_CoffeeBean
	if cur_CoffeeBean > 0:
		$AniNode / Coffee.play("init")
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
