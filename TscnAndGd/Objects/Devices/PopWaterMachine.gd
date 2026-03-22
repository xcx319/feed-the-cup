extends Head_Object
var SelfDev = "PopWaterMachine"

var LayerB_Obj = null

onready var Layer_B = $TexNode / GasNode

onready var UIANI = $TexNode / UI / UIAni
onready var UseAni = $AniNode / Use

onready var _A = get_node("But/A")
onready var _B = get_node("But/B")

onready var _Y = get_node("But/Y")
onready var UpgradeAni = $AniNode / Upgrade

export var Pop: int = 0
var WaterType = "water"
var WaterMult: float = 1
var PowerMult: float = 1
var Liquid_Count: int = 10
var HasWater: bool = true
var IsPassDay: bool = false
var WaterCelcius: int = 25
var _TurnOn: bool
var IsBlackOut: bool
var UsedPowerCount: float = 0
var power: float = 0.5
var PopList: Array = [25, 55, 100]

var PopUseList: Array = [5, 8, 10]

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	_CanMove_Check()

	get_node("But").show()
	_B.hide()

	if $WarningNode.NeedFix:
		_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_2)

	else:
		_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_Str)
	if is_instance_valid(LayerB_Obj):
		_Y.show()
	else:
		_Y.hide()
	if CanMove:
		if not _Player.Con.IsHold:
			if _bool:
				_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_Str)
				_A.show()

		else:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			_A.hide()
			if is_instance_valid(_Dev):
				if _Dev.get("FuncType") == "GasBottle":
					_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_2)
					_A.show()

			_B.hide()

	else:
		if not _Player.Con.IsHold:
			_A.hide()
			if is_instance_valid(LayerB_Obj):
				_B.show()
		else:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			if is_instance_valid(_Dev):

				if _Dev.get("FuncType") in ["DrinkCup", "SodaCan"]:
					_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_1)
					_A.show()
			_B.hide()

	.But_Switch(_bool, _Player)
func _DayClosedCheck():

	if is_instance_valid(LayerB_Obj):
		if LayerB_Obj.GasNum > 0:
			GameLogic.Total_Electricity += float(LayerB_Obj.GasNum) * 0.1 * PowerMult

	pass
func _ready() -> void :

	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("OpenStore", self, "_CanMove_Check"):
		var _con = GameLogic.connect("OpenStore", self, "_CanMove_Check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _CON = GameLogic.connect("Reward", self, "Update_Check")
	if CanLayout:
		CanMove = true

	_A.show()
	get_node("But").show()
	_CanMove_Check()
func Update_Check():
	var _Mult: float = 1
	if GameLogic.cur_Rewards.has("气泡水机升级"):
		PopUseList = [3, 6, 9]

		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("气泡水机升级+"):
		PopUseList = [1, 2, 3]

		$WarningNode.FixBase = 20
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	if IsBlackOut:
		call_turn_logic( - 1)
func _CanMove_Check():
	if get_parent().name != "ObjNode":
		if LayerB_Obj == null:
			CanMove = true
		return
	if CanLayout:
		if LayerB_Obj == null:
			CanMove = true
		else:
			CanMove = false
	else:
		CanMove = false

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	self.position = _Info.pos
	for _OBJ in Layer_B.get_children():
		Layer_B.remove_child(_OBJ)
		_OBJ.queue_free()

	if _Info.LayerB_Obj != null:
		var _ObjInfo = _Info.LayerB_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME

		Layer_B.add_child(_Obj)
		LayerB_Obj = _Obj
		_Obj.call_load(_ObjInfo)

		call_turn_logic(1)

	_CanMove_Check()
	Update_Check()
func call_DrinkCup_puppet():

	pass
func call_DrinkCup_Logic(_ButID, _Player):

	match _ButID:
		- 2:
			pass
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			var B_bool: bool

			if LayerB_Obj:
				if LayerB_Obj.FuncType in ["Top"] and _Dev.Top == "":
					B_bool = true
				if LayerB_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					B_bool = true
				if LayerB_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerB_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						B_bool = true
				if LayerB_Obj.FuncType in ["Can"]:

					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								B_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								B_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								B_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								B_bool = true

			if B_bool:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)

func return_canput_check(_Obj):
	if not is_instance_valid(_Obj):
		return true
	if _Obj.IsItem:
		return true
	else:
		match _Obj.FuncType:
			"PopCap":
				return true
			_:
				return false

func call_ShakeCup_Logic(_butID, _Player):

	match _butID:
		- 1:


			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _Player.IsStaff:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			var _Check = return_canput_check(_Dev)
			if not _Check:
				return

func call_PutOn(_butID, _Player):

	if get_parent().name != "ObjNode":
		return
	match _butID:
		- 1:


			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _Player.IsStaff:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			if not is_instance_valid(_Dev):
				return
			var _Check = return_canput_check(_Dev)
			if not _Check:
				return
			var A_bool: bool
			var B_bool: bool = false

			if LayerB_Obj == null:
				if _Dev.get("SelfDev") == "GasBottle":
					A_bool = true

			if A_bool:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if B_bool:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)

		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerB_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				if _Obj.FuncType in ["GasBottle"]:
					return _PutOn("B", _Player)

		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			call_Turn()

func call_PutOn_puppet(_PLAYERPATH, _OBJPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj = get_node(_OBJPATH)
	if _Obj.has_node("But/A"):
		_Obj.get_node("But/A").call_clean()
	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)
	match _Layer:

		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj
			UIANI.play("Pop1")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)

	_CanMove_Check()
	call_pick( - 1, _Player)
	But_Switch(true, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)
func _PutOn(_Layer, _Player):
	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Obj = instance_from_id(_Player.Con.HoldInsId)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _OBJPATH = _Obj.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOn_puppet", [_PLAYERPATH, _OBJPATH, _Layer])
	if _Obj.has_node("But/A"):
		_Obj.get_node("But/A").call_clean()
	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)

	match _Layer:

		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj
			UIANI.play("Pop1")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
			call_turn_logic(1)

	_CanMove_Check()

	But_Switch(true, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)

	return "台架放入"

func call_Turn():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if is_instance_valid(LayerB_Obj):
		GameLogic.Audio.But_EasyClick.play(0)
		call_turn_logic(1, true)
		return true
func call_MachineControl(_ButID, _Player):

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
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
func call_pick(_butID, _Player):

	match _butID:
		- 1:
			But_Switch(true, _Player)

		1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerB_Obj != null:
				_pick("B", _Player)

				But_Switch(true, _Player)

		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				call_Turn()
	_CanMove_Check()
	return "台架取出"
func call_pick_puppet(_PLAYERPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj
	match _Layer:

		"B":
			_Obj = LayerB_Obj

			LayerB_Obj = null
			UIANI.play("init")

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)

	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(true, _Player)
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)
	But_Switch(true, _Player)

func _pick(_Layer, _Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_puppet", [_PLAYERPATH, _Layer])
	var _Obj
	match _Layer:

		"B":
			_Obj = LayerB_Obj

			LayerB_Obj = null
			UIANI.play("init")

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _Obj)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(true, _Player)
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)
func call_Water_Out_puppet():

	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)

func call_Water_Out(_num):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Water_Out_puppet")

	var _AUDIO = GameLogic.Audio.return_Effect("倒水")
	_AUDIO.play(0)

	GameLogic.Total_Water += float(_num) * WaterMult
	GameLogic.Total_Electricity += float(_num) * 0.5 * PowerMult

	if $WarningNode.NeedFix:
		pass

	if Pop > 0:
		if is_instance_valid(LayerB_Obj):
			var _USEDNUM: int = int(PopUseList[Pop - 1] * _num)
			LayerB_Obj.call_Gas_Used(_USEDNUM)
			call_turn_logic(0, false)

func return_Combo():
	var _ISCOMBO: bool = false
	if GameLogic.cur_Rewards.has("气泡水机升级"):
		var _RAND = GameLogic.return_randi() % 100
		var _RAT = 10
		if _RAND < _RAT:
			$AniNode / ComboAni.play("init")
			$AniNode / ComboAni.play("combo")
			GameLogic.call_combo(1)
			_ISCOMBO = true
	elif GameLogic.cur_Rewards.has("气泡水机升级+"):
		var _RAND = GameLogic.return_randi() % 100
		var _RAT = 30
		if _RAND < _RAT:
			$AniNode / ComboAni.play("init")
			$AniNode / ComboAni.play("combo")
			GameLogic.call_combo(1)
			_ISCOMBO = true
	return _ISCOMBO

func call_In_Cup(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if _HoldObj.FuncType in ["SodaCan"]:
				if _HoldObj.IsPack:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_PickFinished()
					return true

			if IsBlackOut:
				return
			if $WarningNode.NeedFix:
				return
			if Pop <= 0:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NeedGas()
				return
			if _HoldObj.LIQUID_DIR.has("啤酒泡"):

				_HoldObj.Beer_In_Logic(self)
				var _RETURN = $WarningNode.return_Fix()
				if _RETURN:
					But_Switch(true, _Player)
				UseAni.play("init")
				UseAni.play("Use")
				var _ISCOMBO: bool = return_Combo()
				if _ISCOMBO:
					call_Extra()
				return true
			if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:

				GameLogic.Liquid.call_WaterStain(_HoldObj.global_position, 1, WaterType, _Player)
				if _HoldObj.Liquid_Count + 1 >= _HoldObj.Liquid_Max:
					But_Switch(false, _Player)
				else:
					if not get_parent().name in ["Obj_A", "Obj_B", "Obj_X", "Obj_Y"]:
						if has_method("But_Switch"):
							But_Switch(true, _Player)
				_HoldObj.Water_In_Logic(self)
				var _RETURN = $WarningNode.return_Fix()
				if _RETURN:
					But_Switch(true, _Player)
				UseAni.play("init")
				UseAni.play("Use")

				var _ISCOMBO: bool = return_Combo()
				if _ISCOMBO:
					call_Extra()
				return true

		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				return call_Turn()

func call_Fix_Logic(_Player):
	if $WarningNode.return_Fixing(_Player):
		call_Fix_Ani(_Player)
		But_Switch(true, _Player)
	else:
		call_Fix_Ani(_Player)
func call_Fix_Ani(_Player):
	UseAni.play("init")
	UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func call_turn_puppet(_POPNUM, _AUDIO: bool = false):
	if _AUDIO:
		GameLogic.Audio.But_EasyClick.play(0)
	Pop = _POPNUM
	if Pop > 0:
		var _ANINAME = "Pop" + str(Pop)
		UIANI.play(_ANINAME)
	else:
		UIANI.play("init")
func call_turn_logic(_NUM: int, _AUDIOBOOL: bool = false):
	if _NUM < 0:
		Pop = 0
		WaterType = "water"
	else:
		Pop += _NUM
		if Pop > 3:
			Pop = 1
		WaterType = "气泡水"
	if is_instance_valid(LayerB_Obj):
		if LayerB_Obj.GasNum <= 0:
			Pop = 0
			WaterType = "water"
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_turn_puppet", [Pop, _AUDIOBOOL])
	if Pop > 0:
		var _ANINAME = "Pop" + str(Pop)
		UIANI.play(_ANINAME)
	else:
		UIANI.play("init")

	pass

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
