extends Head_Object
var SelfDev = "WaterPort"
onready var Liquid = get_node("TexNode/liquid")
onready var AniPlayer = get_node("AniNode/AnimationPlayer")
onready var WaterTimer = get_node("Timer")
onready var IconSprite = get_node("IconNode/IconSprite")

onready var FreshAni = $Effect_flies / Ani
onready var TempAni = get_node("AniNode/Temp")
onready var UpgradeAni = get_node("AniNode/Upgrade")
onready var Liquid_Label = get_node("IconNode/IconSprite/LiquidLabel")
var HasContent: bool
var HasTeaLeaf: bool
var HasWater: bool
var WaterType
var WaterCelcius: int
var CanWaterOut: bool
var IsDrawTea: bool
var DrawTeaRate: int
onready var Liquid_Color = Liquid.modulate

var Liquid_Max: int
var Liquid_Count: int
var _Liquid_per: float

var _Water_Num: float

var InTime
var Freshless: int = 0
var IsFreezer: bool
var IsPassDay: bool
var IsBroken: bool
onready var Audio_Water

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func call_Freezer_Switch(_Switch: bool):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	IsFreezer = _Switch
	if not IsFreezer:
		$ColdTimer.stop()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(self, "IsFreezer", IsFreezer)
func call_Freezer_ColdTimer():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	IsFreezer = true
	$ColdTimer.wait_time = 0.2
	$ColdTimer.start(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_set_sync(self, "IsFreezer", IsFreezer)
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.Con.IsHold:
		var _PortObj = instance_from_id(_Player.Con.HoldInsId)
		if _PortObj.get("IsBroken"):
			.But_Switch(false, _Player)
			return
		if _PortObj.get("SelfDev") == "BigPot":
			if _PortObj.ContentType in ["西米"]:
				return
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	else:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	.But_Switch(_bool, _Player)

func _fressless_check():
	if IsBroken:
		FreshAni.play("Flies")
	elif IsPassDay:
		FreshAni.play("OverDay")
	else:
		FreshAni.play("init")

func _DayClosedCheck():

	if Liquid_Count > 0:
		if WaterType != "water":
			if not IsFreezer:
				IsBroken = true
			else:
				if not IsPassDay:
					IsPassDay = true
				else:
					IsBroken = true
			if not IsFreezer:
				if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.WATERPORT):
					GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.WATERPORT)

func _ready() -> void :
	call_init(SelfDev)

	set_process(false)
	$But.show()

	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Audio_Water = GameLogic.Audio.return_Effect("加水")
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
func _collision_check():
	var _parentName = get_parent().name
	if _parentName == "Devices":
		call_Collision_Switch(true)
	elif _parentName == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func call_celcius():
	if WaterCelcius >= 50:
		TempAni.play("hot")
	else:
		TempAni.play("init")
func Update_Check():
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
	if GameLogic.cur_Rewards.has("量杯升级"):
		Liquid_Max = Liquid_Max * 2
		UpgradeAni.play("2")
	if GameLogic.cur_Rewards.has("量杯升级+"):
		Liquid_Max = Liquid_Max * 3
		UpgradeAni.play("3")

func call_load_TSCN(_TSCN):

	.call_Ins_Save(_SELFID)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	Update_Check()
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
	Liquid_Count = _Info.Liquid_Count
	Liquid_Label.text = str(Liquid_Count)
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	WaterType = _Info.WaterType
	WaterCelcius = _Info.WaterCelcius
	call_celcius()
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	Liquid.set_modulate(_color8)
	AniPlayer.play("in")
	AniPlayer.advance(AniPlayer.get_current_animation_length())

	CanWaterOut = _Info.CanWaterOut
	_weight_logic()
	if Liquid_Count > 0:
		HasWater = true

		var _IconName = GameLogic.Config.LiquidConfig[WaterType].IconName
		var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
		var _Icon = load(_path)
		IconSprite.set_texture(_Icon)
		IconSprite.show()


	if not GameLogic.cur_Rewards.has("茶桶升级+"):
		IsPassDay = _Info.IsPassDay
		IsBroken = _Info.IsBroken
		_fressless_check()

	set_process(true)

func _config_SYCN():
	Liquid_Max = FuncTypePara

func call_WaterInDrinkCup_puppet():
	pass

func call_WaterInDrinkCup(_ButID, _HoldObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
				if Liquid_Count > 0:
					But_Switch(true, _Player)
			else:
				if _HoldObj.LIQUID_DIR.has("啤酒泡"):
					if _HoldObj.LIQUID_DIR["啤酒泡"] > 0:
						if Liquid_Count > 0:
							But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if IsBroken:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return

			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
				if Liquid_Count > 0:
					GameLogic.Liquid.call_WaterStain(_HoldObj.global_position, 1, WaterType, _Player)
					if _HoldObj.Liquid_Count + 1 >= _HoldObj.Liquid_Max:
						But_Switch(false, _Player)
					else:
						if not get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
							if has_method("But_Switch"):
								But_Switch(true, _Player)
					_HoldObj.call_Water_In(_ButID, self)
					return true
			else:
				if _HoldObj.LIQUID_DIR.has("啤酒泡"):
					if _HoldObj.LIQUID_DIR["啤酒泡"] > 0:
						if Liquid_Count > 0:
							GameLogic.Liquid.call_WaterStain(_HoldObj.global_position, 1, WaterType, _Player)

							_HoldObj.call_Water_In(_ButID, self)
							if _HoldObj.LIQUID_DIR["啤酒泡"] == 0:
								But_Switch(false, _Player)
							else:
								if not get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
									if has_method("But_Switch"):
										But_Switch(true, _Player)
							return true

func call_WaterInTeaPort(_ButID, _PortObj, _Player, _TYPE: int = 0):


	if AniPlayer.is_playing():
		return
	var _check: bool
	if _TYPE == 1:
		if Liquid_Count < Liquid_Max and _PortObj.Liquid_Count > 0:
			_check = true
	if Liquid_Count > 0:
		if WaterType == _PortObj.get("WaterType") and _PortObj.Liquid_Count > 0:
			if Liquid_Count + _PortObj.Liquid_Count <= Liquid_Max:
				_check = true
	else:
		_check = true

	if _PortObj.TypeStr in ["MilkPot"]:
		if _PortObj.WaterType in ["water"] and _PortObj.HasContent:
			return
	if not _check:
		return
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:

			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsBroken and not _PortObj.get("IsBroken"):
				return
			if _PortObj.SelfDev == "BigPot":
				if _PortObj.ContentType in ["西米"]:
					return
			var _return = call_Water_In(_ButID, _PortObj, _TYPE)
			if _return > 0:

				_fressless_check()
				if _PortObj.has_method("call_Water_Out"):
					_PortObj.call_Water_Out(_PortObj.Liquid_Count)
				GameLogic.Device.Call_CheckLogic( - 1, _Player, _PortObj)
				But_Switch(false, _Player)
				_PortObj.But_Switch(true, _Player)
				return true
			elif _return == - 1:
				if _Player.get("cur_player") in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoAdd()
			return 0

func return_DropCount():
	var _Drop_Count = 0
	if Liquid_Count > 0:
		_Drop_Count += Liquid_Count
	if HasTeaLeaf:
		_Drop_Count += 1

	return _Drop_Count
func call_Drop():
	if Liquid_Count > 0:
		call_Water_Out(Liquid_Count, 1)

	if HasTeaLeaf:
		AniPlayer.play("drop")
		HasTeaLeaf = false

	IsDrawTea = false
	_weight_logic()
func _weight_logic():
	var _Con: int = 0
	if HasContent:
		_Con = 1
	Weight = 1 + _Con + int(Liquid_Count)

func call_Water_In_puppet(_WATERTYPE, _WATERCELCIUS, _LIQUIDCOUNT, _BROKEN: bool = false, _PASSDAY: bool = false):
	WaterType = _WATERTYPE
	WaterCelcius = _WATERCELCIUS
	call_celcius()
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	Liquid.set_modulate(_color8)

	AniPlayer.play("in")
	IsBroken = _BROKEN
	IsPassDay = _PASSDAY
	HasWater = true
	WaterTimer.start(0)
	Liquid_Count = _LIQUIDCOUNT
	_weight_logic()
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	set_process(true)
	if Liquid_Count > 0:

		var _IconName
		if WaterType == "water" and WaterCelcius >= 50:
			_IconName = "Icon_liquid_water_hot"
		elif WaterType == "water" and WaterCelcius < 25:
			_IconName = "Icon_liquid_water_ice"
		else:
			_IconName = GameLogic.Config.LiquidConfig[WaterType].IconName

		var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
		var _Icon = load(_path)
		IconSprite.set_texture(_Icon)
		IconSprite.show()
		Liquid_Label.text = str(Liquid_Count)

		call_Info_Switch(true)
	_Temp_Ani()
	_fressless_check()
func call_Water_In(_ButReturnBool, _WaterObj, _TYPE: int = 0):
	if AniPlayer.is_playing():
		AniPlayer.play("init")

	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)

	if Liquid_Count != 0 and WaterType != _WaterObj.WaterType:

		return 0
	if _WaterObj.FuncType in ["BigPot"]:
		if _WaterObj.CookPro in [1]:
			return - 1
		if Liquid_Count + _WaterObj.Liquid_Count * 10 > Liquid_Max:
			return - 1
	if _TYPE == 1:
		if Liquid_Count >= Liquid_Max or _WaterObj.Liquid_Count <= 0:
			return - 1
	elif Liquid_Count + _WaterObj.Liquid_Count > Liquid_Max:

		return - 1
	WaterType = _WaterObj.WaterType

	if _WaterObj.get("WaterCelcius") != null:
		if _WaterObj.get("WaterCelcius") > WaterCelcius:
			WaterCelcius = _WaterObj.get("WaterCelcius")
	call_celcius()
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	Liquid.set_modulate(_color8)

	AniPlayer.play("in")
	if not IsBroken:
		IsBroken = _WaterObj.get("IsBroken")
	if not IsPassDay:
		IsPassDay = _WaterObj.get("IsPassDay")
	HasWater = true
	WaterTimer.start(0)
	var _NUM: int = 0
	if _WaterObj.SelfDev == "WaterTank":
		_NUM = Liquid_Max
		Liquid_Count = Liquid_Max
	elif _WaterObj.SelfDev == "BigPot":
		_NUM = _WaterObj.Liquid_Count * 10
		Liquid_Count += _NUM
	else:
		if _TYPE == 1:
			if _WaterObj.Liquid_Count + Liquid_Count <= Liquid_Max:
				_NUM = _WaterObj.Liquid_Count
				Liquid_Count += _WaterObj.Liquid_Count
			else:
				_NUM = Liquid_Max - Liquid_Count
				Liquid_Count = Liquid_Max
		else:
			_NUM = _WaterObj.Liquid_Count
			Liquid_Count += _WaterObj.Liquid_Count
	_weight_logic()
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0

	set_process(true)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_In_puppet", [WaterType, WaterCelcius, Liquid_Count, IsBroken, IsPassDay])
	if Liquid_Count > 0:

		var _IconName
		if WaterType == "water" and WaterCelcius >= 50:
			_IconName = "Icon_liquid_water_hot"
		elif WaterType == "water" and WaterCelcius < 25:
			_IconName = "Icon_liquid_water_ice"
		else:
			_IconName = GameLogic.Config.LiquidConfig[WaterType].IconName

		var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
		var _Icon = load(_path)
		IconSprite.set_texture(_Icon)
		IconSprite.show()
		Liquid_Label.text = str(Liquid_Count)

		call_Info_Switch(true)
	_Temp_Ani()
	_fressless_check()
	return _NUM
func call_temp_puppet(_CELCIUS):
	WaterCelcius = _CELCIUS
	_Temp_Ani()
func _Temp_Ani():
	if Liquid_Count > 0:
		if WaterCelcius >= 50:
			TempAni.play("hot")
		elif WaterCelcius < 25:
			TempAni.play("Ice")
		else:
			TempAni.play("cold")
	else:
		TempAni.play("init")
func call_Water_Out_puppet(_LIQUID):
	AniPlayer.play("drop")
	Audio_Water.play(0)
	Liquid_Count = _LIQUID
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	Liquid_Label.text = str(Liquid_Count)
	if Liquid_Count <= 0:
		Liquid_Count = 0
		HasWater = false
		WaterType = null
		WaterCelcius = 0
		call_celcius()
		CanWaterOut = false
		_weight_logic()
		IconSprite.hide()
		IsPassDay = false
		IsBroken = false
		_fressless_check()
	_Temp_Ani()
	set_process(true)
func call_Water_Out(_OutNum, _TYPE: int = 0):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	AniPlayer.play("drop")
	if _TYPE == 0:
		Audio_Water.play(0)

	var _curScale = Liquid.scale
	_Water_Num = _OutNum
	Liquid_Count -= _OutNum
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_Out_puppet", [Liquid_Count])
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0

	Liquid_Label.text = str(Liquid_Count)

	if Liquid_Count <= 0:
		Liquid_Count = 0
		HasWater = false
		WaterType = null
		WaterCelcius = 0
		call_celcius()
		CanWaterOut = false
		_weight_logic()
		IconSprite.hide()
		IsPassDay = false
		IsBroken = false
		_fressless_check()
	_Temp_Ani()
	set_process(true)
	return 0
func call_WaterLess():
	if Liquid.scale.y > _Liquid_per:
		Liquid.scale.y -= 0.05
		if Liquid.scale.y - 0.05 <= _Liquid_per:
			set_process(false)

	elif Liquid.scale.y < _Liquid_per:
		Liquid.scale.y += 0.05
		if Liquid.scale.y + 0.05 >= _Liquid_per:
			set_process(false)
	if Liquid.scale.y < 0:
		Liquid.scale.y = 0
	if Liquid.scale.y > 1:
		Liquid.scale.y = 1

func _process(_delta: float) -> void :

	call_WaterLess()

func _on_Timer_timeout() -> void :
	CanWaterOut = true
	pass

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)



func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func _on_ColdTimer_timeout():
	if WaterCelcius > 25:
		WaterCelcius -= 1
	else:
		$ColdTimer.stop()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_temp_puppet", [WaterCelcius])
	_Temp_Ani()
func call_Temp_puppet(_CELCIUS):
	WaterCelcius = _CELCIUS
	_Temp_Ani()

func call_Info_Switch(_Switch: bool):
	match _Switch:
		true:
			if Liquid_Count > 0:
				$IconNode.show()
		false:
			$IconNode.hide()
