extends Head_Object
var SelfDev = "TeaBarrel"
onready var Liquid = $TexNode / liquid
onready var WaterNode = $TexNode / waterposition / water
onready var LiquidAni = $AniNode / LiquidAni
onready var AniPlayer = $AniNode / TeaAni
onready var WaterTimer = get_node("Timer")
onready var IconSprite = $TexNode / IconNode / Icon

onready var FreshAni = $Effect_flies / Ani
onready var TempAni = $AniNode / TempAni
onready var UpgradeAni = get_node("AniNode/Upgrade")
onready var Liquid_Label = $TexNode / IconNode / Icon / LiquidLabel
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
			if not IsPassDay:
				IsPassDay = true
			else:
				IsBroken = true

func _ready() -> void :
	call_init(SelfDev)
	set_physics_process(false)
	$But.show()

	call_deferred("_collision_check")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Audio_Water = GameLogic.Audio.return_Effect("加水")
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
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

func call_NormalCelcius():
	WaterCelcius = 25
	call_celcius()
func call_celcius():
	if WaterCelcius >= 50:
		TempAni.play("hot")
	else:
		TempAni.play("init")
func Update_Check():
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
	if GameLogic.cur_Rewards.has("茶桶升级"):

		UpgradeAni.play("2")
	if GameLogic.cur_Rewards.has("茶桶升级+"):

		UpgradeAni.play("3")
func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	Update_Check()
	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)
	Liquid_Count = _Info.Liquid_Count
	if Liquid_Count > 0:
		HasWater = true
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	Liquid_Label.text = str(Liquid_Count)

	_Liquid_Logic()
	WaterType = _Info.WaterType
	WaterCelcius = _Info.WaterCelcius
	call_celcius()
	_weight_logic()
	if GameLogic.Config.LiquidConfig.has(WaterType):
		var _color8 = GameLogic.Liquid.return_color_set(WaterType)
		Liquid.set_modulate(_color8)
		WaterNode.set_modulate(_color8)

		var _IconName = GameLogic.Config.LiquidConfig[WaterType].IconName
		var _path = GameLogic.TSCNLoad.UI_Path + _IconName + ".tres"
		var _Icon = load(_path)
		IconSprite.set_texture(_Icon)
		IconSprite.show()

	else:
		IconSprite.hide()


	IsPassDay = _Info.IsPassDay
	IsBroken = _Info.IsBroken
	_fressless_check()

func _Liquid_Logic():

	LiquidAni.play("init")
	LiquidAni.play("liquid")

	LiquidAni.advance(_Liquid_per)
	LiquidAni.stop(false)

func _config_SYCN():
	Liquid_Max = FuncTypePara

	pass
func call_WaterInDrinkCup_puppet(_HoldID):
	var _HOLD = null
	if SteamLogic.OBJECT_DIC.has(_HoldID):
		_HOLD = SteamLogic.OBJECT_DIC[_HoldID]
	_HOLD.call_Water_AllIn(self)
func call_WaterInDrinkCup(_ButID, _HoldObj, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
				if HasWater:
					But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if IsBroken:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if not get_parent().name in ["Obj_X", "Obj_Y"]:

				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NeedRack()
				return
			if _HoldObj.get("IsDirty"):
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NeedWash()
				return
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
				if HasWater:
					GameLogic.Liquid.call_WaterStain(_HoldObj.global_position, 1, WaterType, _Player)
					if _HoldObj.Liquid_Count + 1 >= _HoldObj.Liquid_Max:
						But_Switch(false, _Player)
					else:
						if not get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
							if has_method("But_Switch"):
								But_Switch(true, _Player)
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return

					_HoldObj.call_Water_AllIn(self)
					return true
func call_AllIn_puppet(_ID, _CUPID):
	var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
	var _SELF = SteamLogic.OBJECT_DIC[_ID]
	_CUP.call_Water_AllIn(_SELF)

func call_WaterInTeaPort(_ButID, _PortObj, _Player):


	if AniPlayer.is_playing():
		return
	var _check: bool
	if HasWater:
		if WaterType == _PortObj.get("WaterType"):
			if Liquid_Count + _PortObj.Liquid_Count <= Liquid_Max:
				_check = true
	else:
		_check = true

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
			if _PortObj.FuncType in ["BigPot"]:
				if not _PortObj.get("cur_TYPE") in [4]:
					return
				if _PortObj.get("ContentType") in ["西米", "芋头块", "鲜芋"]:
					return
				if Liquid_Count > 20:
					return
			var _return = call_Water_In(_ButID, _PortObj)
			if _return:
				GameLogic.Liquid.call_WaterStain(_Player.global_position, _return, WaterType, _Player)
			if not IsBroken:
				IsBroken = _PortObj.get("IsBroken")
			if not IsPassDay:
				IsPassDay = _PortObj.get("IsPassDay")
			_fressless_check()
			if _PortObj.has_method("call_Water_Out"):
				_PortObj.call_Water_Out(_PortObj.Liquid_Count)
			GameLogic.Device.Call_CheckLogic( - 1, _Player, _PortObj)
			But_Switch(false, _Player)
			_PortObj.But_Switch(true, _Player)
			return 0

func return_DropCount():
	var _Drop_Count = 0
	if HasWater:
		_Drop_Count += Liquid_Count
	if HasTeaLeaf:
		_Drop_Count += 1

	return _Drop_Count
func call_Drop():
	if HasWater:
		call_Water_Out(Liquid_Count, true)
		AniPlayer.play("drop")


	_weight_logic()
func _weight_logic():
	var _Con: int = 0
	if HasContent:
		_Con = 1
	Weight = 1 + _Con + int(Liquid_Count)

func call_Water_In_puppet(_WATERTYPE, _WATERCELCIUS, _LIQUIDCOUNT):
	WaterType = _WATERTYPE
	WaterCelcius = _WATERCELCIUS
	call_celcius()
	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	Liquid.set_modulate(_color8)
	WaterNode.set_modulate(_color8)

	AniPlayer.play("in")

	HasWater = true
	WaterTimer.start(0)
	Liquid_Count = _LIQUIDCOUNT
	_weight_logic()
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	_Liquid_Logic()


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

	_Temp_Ani()
	_fressless_check()
func call_Water_In(_ButReturnBool, _WaterObj):
	if AniPlayer.is_playing():
		AniPlayer.play("init")

	if Liquid_Max == 0:
		Liquid_Max = int(FuncTypePara)

	if Liquid_Count != 0 and WaterType != _WaterObj.WaterType:

		return
	elif _WaterObj.Liquid_Count == 0:

		return
	var _OBJLiquid_Num = _WaterObj.Liquid_Count
	if _WaterObj.SelfDev == "BigPot":
		_OBJLiquid_Num = _WaterObj.Liquid_Count * 10
	if Liquid_Count + _OBJLiquid_Num > Liquid_Max:

		return
	WaterType = _WaterObj.WaterType

	if _WaterObj.WaterCelcius > WaterCelcius:
		WaterCelcius = _WaterObj.WaterCelcius
	call_celcius()

	var _color8 = GameLogic.Liquid.return_color_set(WaterType)
	Liquid.set_modulate(_color8)
	WaterNode.set_modulate(_color8)

	AniPlayer.play("in")

	HasWater = true
	WaterTimer.start(0)
	if _WaterObj.SelfDev == "WaterTank":
		_OBJLiquid_Num = Liquid_Max
		Liquid_Count = Liquid_Max
	else:
		Liquid_Count += _OBJLiquid_Num
	_weight_logic()
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	_Liquid_Logic()

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Water_In_puppet", [WaterType, WaterCelcius, Liquid_Count])

	var _IconName
	if GameLogic.Config.LiquidConfig.has(WaterType):
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

	_Temp_Ani()
	_fressless_check()
	return _OBJLiquid_Num
func _Temp_Ani():
	if Liquid_Count > 0:
		if WaterCelcius >= 85:
			TempAni.play("hot")

		else:
			TempAni.play("init")
	else:
		TempAni.play("init")
func call_Water_Out_puppet(_LIQUID):
	var _OutNum = Liquid_Count - _LIQUID
	if _OutNum <= 6:
		AniPlayer.play("use")
	else:
		AniPlayer.play("drop")
	Audio_Water.play(0)
	Liquid_Count = _LIQUID
	if Liquid_Count > 0:
		_Liquid_per = float(Liquid_Count) / float(Liquid_Max)
	else:
		_Liquid_per = 0
	_Liquid_Logic()
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

func call_Water_Out(_OutNum, _BOOL: bool = false):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not _BOOL:
		if GameLogic.cur_Rewards.has("茶桶升级"):
			var _RAND = GameLogic.return_RANDOM() % 4
			if _RAND == 0:
				_OutNum = _OutNum - 1
			if _OutNum < 0:
				_OutNum = 0
		elif GameLogic.cur_Rewards.has("茶桶升级+"):
			var _RAND = GameLogic.return_RANDOM() % 4
			if _RAND == 0:
				_OutNum = 0

	if _OutNum <= 6:
		AniPlayer.play("use")
	else:
		AniPlayer.play("drop")
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
	_Liquid_Logic()
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

	return 0

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
		SteamLogic.call_puppet_set_sync(self, "WaterCelcius", WaterCelcius)
