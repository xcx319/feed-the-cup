extends Head_Object
var SelfDev = "IceCreamBox"

var MilkBool: bool
var CreamBool: bool
var FlavorType: int = 0
var IsFreezer: bool
var IsPassDay: bool
var IsBroken: bool
var Liquid_Count: int = 0
var ItemMax: int = 20
var WaterType: String = ""
var CreamType: int
var WaterCelcius: int = - 30
var HasWater: bool
func _DayClosedCheck():
	if not IsFreezer:
		if MilkBool or CreamBool or FlavorType:

			IsBroken = true
	call_PassDay()
func _ready() -> void :
	call_init(SelfDev)

	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if get_parent().name in ["A", "B", "X", "Y"]:
		call_InFreezerBox(true)
	$TexNode / IconNode / Capacity / NumProgress.max_value = ItemMax
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if GameLogic.is_connected("DayStart", self, "Update_Check"):
		var _CON = GameLogic.connect("DayStart", self, "Update_Check")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
func Update_Check():
	var UpgradeAni = $AniNode / Upgrade
	if GameLogic.cur_Rewards.has("冰淇淋机升级"):
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("冰淇淋机升级+"):
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
			ItemMax = 30
			call_Number_Show()
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	MilkBool = _Info.MilkBool
	CreamBool = _Info.CreamBool
	FlavorType = _Info.FlavorType
	IsPassDay = _Info.IsPassDay
	IsBroken = _Info.IsBroken
	IsFreezer = _Info.IsFreezer
	Liquid_Count = _Info.Liquid_Count

	if _Info.has("CreamType"):
		CreamType = _Info.CreamType
	if _Info.has("WaterType"):
		WaterType = _Info.WaterType
	.call_Ins_Save(_SELFID)
	if get_parent().name in ["A", "B", "X", "Y"]:
		call_InFreezerBox(true)
	call_Milk_Switch(MilkBool)
	call_Cream_Switch(CreamBool)
	call_FlavorType(FlavorType)
	call_Icon_Show()
	call_IceCreamType()
	call_Number_Show()
	call_PassDay()
	print(FlavorType, " Liquid2", Liquid_Count)
func call_InFreezerBox(_Switch: bool):
	match _Switch:
		true:
			IsFreezer = true
			$TexNode / UI / UIShow.play("hide")
		false:
			IsFreezer = false
			$TexNode / UI / UIShow.play("show")
func call_Milk_Switch(_SWITCH: bool):
	MilkBool = _SWITCH
	if MilkBool:
		$TexNode / UI / Milk / AnimationPlayer.play("Add")
		$AniNode / UseAni.play("in")
	else:
		$TexNode / UI / Milk / AnimationPlayer.play("init")
	call_Ready_Check()
func call_Cream_Switch(_SWITCH: bool):
	CreamBool = _SWITCH
	if CreamBool:
		$TexNode / UI / Cream / AnimationPlayer.play("Add")
		$AniNode / UseAni.play("in")
	else:
		$TexNode / UI / Cream / AnimationPlayer.play("init")
	call_Ready_Check()
func call_FlavorType(_INT: int = 0):
	$AniNode / UseAni.play("in")
	FlavorType = _INT
	match FlavorType:
		0:
			$TexNode / UI / Type / AnimationPlayer.play("init")
		1:
			$TexNode / UI / Type / AnimationPlayer.play("Sugar")
		2:
			$TexNode / UI / Type / AnimationPlayer.play("Coco")
		3:
			$TexNode / UI / Type / AnimationPlayer.play("Mocha")

		4:
			$TexNode / UI / Type / AnimationPlayer.play("Vanilla")
		5:
			$TexNode / UI / Type / AnimationPlayer.play("Yogurt")
		6:
			$TexNode / UI / Type / AnimationPlayer.play("BlueBerry")
		7:
			$TexNode / UI / Type / AnimationPlayer.play("Cheery")
		8:
			$TexNode / UI / Type / AnimationPlayer.play("Pistachio")
		9:
			$TexNode / UI / Type / AnimationPlayer.play("Rum")
	call_Ready_Check()
func call_Ready_Check():
	call_Number_Show()
	if WaterType == "" and CreamType == 0:
		if Liquid_Count >= 20 and MilkBool and CreamBool and FlavorType != 0:
			CreamType = 1
	call_PassDay()
func call_Number_Show():
	call_Icon_Show()
	if Liquid_Count > 0:
		$TexNode / IconNode / Capacity.show()
	else:
		$TexNode / IconNode / Capacity.hide()

	if CreamType == 2:
		$TexNode / IconNode / Capacity / NumProgress.max_value = ItemMax
	else:
		$TexNode / IconNode / Capacity / NumProgress.max_value = 20
	$TexNode / IconNode / Capacity / NumProgress.value = Liquid_Count
	if Liquid_Count > 0:
		HasWater = true
	else:
		HasWater = false
func call_MakeIceCream(_SWITCH: bool):
	match _SWITCH:
		true:
			var _TIME: float = 1
			if GameLogic.cur_Challenge.has("电压不稳"):
				_TIME -= 0.1
			if GameLogic.cur_Challenge.has("电压不稳+"):
				_TIME -= 0.2
			if GameLogic.cur_Challenge.has("电压不稳++"):
				_TIME -= 0.4
			if GameLogic.cur_Rewards.has("冰淇淋机升级"):
				_TIME += 0.5
			elif GameLogic.cur_Rewards.has("冰淇淋机升级+"):
				_TIME += 0.5
			$TexNode / Progress / Start.playback_speed = _TIME
			$TexNode / Progress / Start.play("Start")

		false:
			$TexNode / Progress / Start.stop(false)

func call_UI_Switch(_SWITCH: bool):
	if _SWITCH:
		$TexNode / UI / UIShow.play("show")
	else:
		$TexNode / UI / UIShow.play("hide")

func But_Switch(_bool, _Player):

	if _bool and not get_parent().name in ["A", "B", "X", "Y"]:
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			call_UI_Switch(true)
	else:
		if _Player.Con.IsHold:
			var _OBJ = instance_from_id(_Player.Con.HoldInsId)
			if _OBJ != self:
				call_UI_Switch(false)
		else:
			call_UI_Switch(false)
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.Con.IsHold:
		var _OBJ = instance_from_id(_Player.Con.HoldInsId)
		var _Func = ""
		if _OBJ.get("FuncType"):
			_Func = _OBJ.get("FuncType")

		if _Func in ["Bottle"]:
			var _WaterType = _OBJ.get("WaterType")
			if _OBJ.get("WaterType") in ["ice_milk"] and not MilkBool:
				$But / A.InfoLabel.text = GameLogic.CardTrans.get_message($But / A.Info_1)
				$But / A.show()
			elif _OBJ.get("WaterType") in ["ice_cream"] and not CreamBool:
				$But / A.InfoLabel.text = GameLogic.CardTrans.get_message($But / A.Info_1)
				$But / A.show()
			elif FlavorType == 0:
				$But / A.InfoLabel.text = GameLogic.CardTrans.get_message($But / A.Info_1)
				$But / A.show()
			else:
				$But / A.hide()
		else:
			$But / A.hide()
	else:
		if CanMove:
			$But / A.InfoLabel.text = GameLogic.CardTrans.get_message($But / A.Info_Str)
			$But / A.show()
		else:
			$But / A.hide()

	.But_Switch(_bool, _Player)

func call_IceCream_Finish():
	if WaterType == "":
		match FlavorType:
			1:
				WaterType = "icecream_milk"
			2:
				WaterType = "icecream_coco"
			3:
				WaterType = "icecream_mocha"
			4:
				WaterType = "icecream_vanilla"
			5:
				WaterType = "icecream_yogurt"
			6:
				WaterType = "icecream_blueberry"
			7:
				WaterType = "icecream_cheery"
			8:
				WaterType = "icecream_pistachio"
			9:
				WaterType = "icecream_rum"
	if WaterType != "":
		GameLogic.Total_Electricity += 10
		CreamType = 2
		Liquid_Count = ItemMax
		$TexNode / IconNode / Capacity / NumProgress.max_value = ItemMax
		$TexNode / IconNode / Capacity / NumProgress.value = Liquid_Count
		call_Icon_Show()
		call_IceCreamType()
	var _MACHINE = get_parent().get_parent().get_parent().get_parent()
	if _MACHINE.has_method("call_turn_check"):
		_MACHINE.call_turn_check()

func call_Icon_Show():
	if CreamType == 2:
		$TexNode / IconNode / Icon.show()
	else:
		$TexNode / IconNode / Icon.hide()
func call_IceCreamType():
	match WaterType:
		"":
			$TexNode / IconNode / IceCreamType.play("init")
		"icecream_coco":
			$TexNode / IconNode / IceCreamType.play("Coco")
		"icecream_mocha":
			$TexNode / IconNode / IceCreamType.play("Mocha")
		"icecream_milk":
			$TexNode / IconNode / IceCreamType.play("Milk")
		"icecream_vanilla":
			$TexNode / IconNode / IceCreamType.play("Vanilla")
		"icecream_yogurt":
			$TexNode / IconNode / IceCreamType.play("Yogurt")
		"icecream_blueberry":
			$TexNode / IconNode / IceCreamType.play("BlueBerry")
		"icecream_cheery":
			$TexNode / IconNode / IceCreamType.play("Cheery")
		"icecream_pistachio":
			$TexNode / IconNode / IceCreamType.play("Pistachio")
		"icecream_rum":
			$TexNode / IconNode / IceCreamType.play("Rum")
func call_InBox(_ButID, _OBJ, _Player):

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
			if _OBJ.get("Freshless_bool"):
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _OBJ.get("WaterType") == "ice_milk" and not MilkBool:
				if _OBJ.Liquid_Count == 10 and _OBJ.get("IsOpen"):
					if _OBJ.get("Freshless_bool"):
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if _OBJ.has_method("call_Num_Out"):
						if _OBJ.get("IsPassDay"):
							IsPassDay = true
						_OBJ.call_Num_Out(10)
						Liquid_Count += 10
						$TexNode / IconNode / Capacity / NumProgress.max_value = 20
						call_Milk_Switch(true)
						But_Switch(true, _Player)
						return "倒入牛奶"
			if _OBJ.get("WaterType") == "ice_cream" and not CreamBool:
				if _OBJ.Liquid_Count == 10 and _OBJ.get("IsOpen"):
					if _OBJ.get("Freshless_bool"):
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if _OBJ.has_method("call_Num_Out"):
						if _OBJ.get("IsPassDay"):
							IsPassDay = true
						_OBJ.call_Num_Out(10)
						Liquid_Count += 10
						$TexNode / IconNode / Capacity / NumProgress.max_value = 20
						call_Cream_Switch(true)
						But_Switch(true, _Player)
						return "倒入Cream"

			var _TYPESTR = _OBJ.get("TypeStr")
			if FlavorType == 0:
				var _TYPE: int = 0
				match _TYPESTR:
					"bag_whitesugar":
						if not _OBJ.get("Used"):
							_OBJ.call_used()
							_TYPE = 1
					"powder_coco":
						if not _OBJ.get("Used"):
							_OBJ.call_used()
							_TYPE = 2
							var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
							_AUDIO.play(0)
					"powder_mocha":
						if not _OBJ.get("Used"):
							_OBJ.call_used()
							_TYPE = 3
							var _AUDIO = GameLogic.Audio.return_Effect("倒粉末")
							_AUDIO.play(0)
					"bottle_vanilla":
						if _OBJ.get("IsOpen") and _OBJ.get("Liquid_Count") == 10:
							if _OBJ.has_method("call_Num_Out"):
								_OBJ.call_Num_Out(10)
								_TYPE = 4
					"ice_yogurt":
						if _OBJ.get("IsOpen") and _OBJ.get("Liquid_Count") == 10:
							if _OBJ.has_method("call_Num_Out"):
								_OBJ.call_Num_Out(10)
								_TYPE = 5
					"bottle_blueberry":
						if _OBJ.get("IsOpen") and _OBJ.get("Liquid_Count") == 10:
							if _OBJ.has_method("call_Num_Out"):
								_OBJ.call_Num_Out(10)
								_TYPE = 6
					"bottle_cheery":
						if _OBJ.get("IsOpen") and _OBJ.get("Liquid_Count") == 10:
							if _OBJ.has_method("call_Num_Out"):
								_OBJ.call_Num_Out(10)
								_TYPE = 7
					"bottle_pistachio":
						if _OBJ.get("IsOpen") and _OBJ.get("Liquid_Count") == 10:
							if _OBJ.has_method("call_Num_Out"):
								_OBJ.call_Num_Out(10)
								_TYPE = 8
					"bottle_wine_rum":
						if _OBJ.get("IsOpen") and _OBJ.get("Liquid_Count") == 10:
							if _OBJ.has_method("call_Num_Out"):
								_OBJ.call_Num_Out(10)
								_TYPE = 9
				if _TYPE > 0:
					call_FlavorType(_TYPE)
					But_Switch(true, _Player)
					return "加入"

func call_PassDay():
	if IsBroken:

		$Effect_flies / Ani.play("Flies")
	elif IsPassDay:
		$Effect_flies / Ani.play("OverDay")
	else:
		$Effect_flies / Ani.play("init")
func call_Drop():
	call_Empty()
func call_Empty():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Empty")
	MilkBool = false
	CreamBool = false
	CreamType = 0
	FlavorType = 0

	call_Milk_Switch(MilkBool)
	call_Cream_Switch(CreamBool)
	call_FlavorType(FlavorType)
	WaterType = ""
	call_Icon_Show()
	call_IceCreamType()
	IsPassDay = false
	IsBroken = false
	call_PassDay()
func call_Use():

	if Liquid_Count > 0:
		Liquid_Count -= 1
	call_Number_Show()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Use_puppet", [Liquid_Count])
	if Liquid_Count == 0:
		call_Empty()

func call_Use_puppet(_LIQUID_COUNT: int):
	Liquid_Count = _LIQUID_COUNT
	call_Number_Show()
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
