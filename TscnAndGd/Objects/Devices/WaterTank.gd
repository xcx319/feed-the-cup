extends Head_Object
var SelfDev = "WaterTank"

var HasTeaLeaf: bool
var HasWater: bool
var WaterType = "water"
var WaterCelcius: int
var DrawTeaRate: int
var Liquid_Count: int = 1
var IsPassDay: bool
var IsBroken: bool
onready var Liquid = get_node("TexNode/water")
onready var WaterAni = get_node("AniNode/WaterAni")

onready var A_But = get_node("But/A")
onready var Y_But = get_node("But/Y")

onready var Audio_Water
onready var Audio_Drop

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func But_Switch(_bool, _Player):
	if not _Player.Con.IsHold:
		if $WarningNode.NeedFix:
			Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_2)
			Y_But.show()
			.But_Switch(_bool, _Player)
		else:

			.But_Switch(false, _Player)
		return
	else:

		var _HoldObj = instance_from_id(_Player.Con.HoldInsId)

		if _HoldObj.get("TypeStr") == "Can":
			Y_But.hide()
			if _HoldObj.get("ProType") == 2 and not _HoldObj.get("CanUse"):
				A_But.show()
			else:
				A_But.hide()
		if _HoldObj.get("SelfDev") == "BigPot":
			Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)

			if _HoldObj.Liquid_Count > 0:
				Y_But.show()
				if _HoldObj.ContentType in ["西米"]:
					Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_1)
			else:
				Y_But.hide()
			if _HoldObj.Liquid_Count >= 2:
				A_But.hide()
			else:
				A_But.show()
			.But_Switch(_bool, _Player)
			return
		if _HoldObj.TypeStr == "MilkPot":
			if _HoldObj.TypeStr == "MilkPot":
				if _HoldObj.HasContent or _HoldObj.HasMilk:
					Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)

					Y_But.show()
				else:
					Y_But.hide()
				if not _HoldObj.HasMilk:
					A_But.show()
				else:
					A_But.hide()
		elif _HoldObj.has_method("call_Drop"):
			if _HoldObj.get("SelfDev") in ["BobaMachine"]:
				if not _HoldObj.get("cur_TYPE") in [1, 2, 4]:
					.But_Switch(false, _Player)
					return
			Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)

			if _HoldObj.TypeStr in ["IceCreamBox"]:
				if _HoldObj.get("Liquid_Count") > 0:
					Y_But.show()
					A_But.hide()
				else:
					Y_But.hide()
					A_But.hide()
				.But_Switch(_bool, _Player)
				return
			if not _HoldObj.TypeStr in ["FreezerBox", "MaterialBox", "MaterialBig"]:
				if _HoldObj.get("Liquid_Count") is int:
					if _HoldObj.get("Liquid_Count") >= _HoldObj.get("Liquid_Max"):
						A_But.hide()
					else:
						A_But.show()
			if _HoldObj.get("Liquid_Count") is int:
				if _HoldObj.get("Liquid_Count") > 0:

					Y_But.show()
					A_But.hide()
				else:

					Y_But.hide()
					A_But.show()
		if _HoldObj.FuncType == "PopCap":
			if _HoldObj.get("Liquid_Count") < _HoldObj.Liquid_Max:
				A_But.show()
		if _HoldObj.FuncType == "DrinkCup":
			if _HoldObj.get("Liquid_Count") < _HoldObj.Liquid_Max:
				A_But.show()
				Y_But.hide()
			else:
				A_But.hide()
				Y_But.hide()
		if _HoldObj.FuncType in ["Con_TeaPort"]:

			if _HoldObj.get("Liquid_Count") < _HoldObj.Liquid_Max:
				A_But.show()
				Y_But.hide()
			else:
				Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)
				A_But.hide()
				Y_But.show()

	.But_Switch(_bool, _Player)

func _ready() -> void :
	WaterCelcius = 25
	HasWater = true
	call_init(SelfDev)
	Audio_Water = GameLogic.Audio.return_Effect("倒水")
	Audio_Drop = GameLogic.Audio.return_Effect("倒入水槽")
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	pass

func call_Water_Out_puppet():
	WaterAni.play("water")
	Audio_Water.play(0)

func call_Water_Out(_num):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Water_Out_puppet")
	WaterAni.play("water")
	Audio_Water.play(0)

	GameLogic.Total_Water += float(_num)
	$WarningNode.return_Fix()
	if $WarningNode.NeedFix:
		$AudioStreamPlayer2D.play(0)
func call_WaterInPort(_ButID, _PortObj, _Player):

	match _ButID:
		- 2:
			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return
			if _PortObj.get("FuncType") in ["Can"]:
				Y_But.hide()
				if _PortObj.get("ProType") == 2 and not _PortObj.get("CanUse"):
					pass
				else:
					return

			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):

				return
			if $WarningNode.NeedFix:
				return
			if _PortObj.get("FuncType") in ["Can"]:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					call_WaterInPort( - 2, _PortObj, _Player)
					return
				if _PortObj.get("ProType") == 2 and not _PortObj.get("CanUse"):
					_PortObj.call_AddWater()
					call_Water_Out(1)
					GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, WaterType, _Player)
					call_WaterInPort( - 2, _PortObj, _Player)
					return true
				return
			if _PortObj.get("FuncType") in ["SodaCan"]:
				if _PortObj.IsPack:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_PickFinished()
					return true
			if _PortObj.has_method("call_Water_In"):
				var _WaterIn = 1

				match _PortObj.get("FuncType"):
					"PopCap":
						if not _PortObj.NeedWater:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_FormulaWrong()
							return
						var _CHECK = _PortObj.WaterType
						if _PortObj.HasWater and _PortObj.WaterType != "气泡水":
							return
						_WaterIn = _PortObj.NeedWaterNum
						call_Water_Out(_WaterIn)
						GameLogic.Liquid.call_WaterStain(_Player.global_position, _WaterIn, WaterType, _Player)
					"DrinkCup", "SodaCan":
						GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, WaterType, _Player)
					"Con_Liquid", "Con_TeaPort":
						_WaterIn = _PortObj.Liquid_Max - _PortObj.Liquid_Count
						call_Water_Out(_WaterIn)
						GameLogic.Liquid.call_WaterStain(_Player.global_position, _WaterIn, WaterType, _Player)
				_PortObj.call_Water_In(_ButID, self)

			if _PortObj.has_method("return_Water_Logic"):
				var _return = _PortObj.return_Water_Logic(_ButID, self, _Player)
				if _return:
					call_Water_Out(10)
					GameLogic.Liquid.call_WaterStain(_Player.global_position, 10, WaterType, _Player)
			But_Switch(true, _Player)
			return "加水"
		3:
			if _PortObj.get("Liquid_Count") == 0:
				return
			if _PortObj.get("SelfDev") in ["BobaMachine"]:
				if _PortObj.get("cur_TYPE") in [1, 2, 4]:
					return call_WaterDrop(_ButID, _PortObj, _Player)
				return
			return call_WaterDrop(_ButID, _PortObj, _Player)

func call_WaterDrop(_ButID, _PortObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		3:
			if _PortObj.has_method("call_Water_Out"):
				if _PortObj.has_method("call_Drop"):
					_PortObj.call_Drop()
					Audio_Drop.play(0)
					But_Switch(true, _Player)

					return "倒水"
			elif _PortObj.get("SelfDev") in ["MilkPot", "BobaMachine"]:
				_PortObj.call_Drop()
				But_Switch(true, _Player)
				return "倒"
			elif _PortObj.get("SelfDev") in ["BreakMachine", "IceCreamBox"]:
				_PortObj.call_Drop()
				Audio_Drop.play(0)
				But_Switch(false, _Player)
				return "倒"
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
		call_Fix_Ani(_Player.cur_Player)
		But_Switch(true, _Player)
	else:
		call_Fix_Ani(_Player.cur_Player)
func call_Fix_Ani(_Player):
	WaterAni.play("init")
	WaterAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player, 1)

func call_CreamMachine_Trash(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.CreamBool or _HoldObj.CreamTYPE:
				But_Switch(true, _Player)

		3:
			if _HoldObj.CreamBool or _HoldObj.CreamTYPE:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					But_Switch(false, _Player)
					return
				var _TrashCount = 10
				if not _HoldObj.CreamBool:
					_TrashCount = 1
				_HoldObj.call_Drop()
				return "入垃圾桶"
