extends Head_Object
var SelfDev = "EggRollMachine"

var _TurnOn: bool
export var powerMult: float = 20
var power: float = 0.5

var _EGGROLLTSCN = preload("res://TscnAndGd/Objects/Items/EggRoll.tscn")
onready var UseAni = get_node("AniNode/UseAni")
onready var UpgradeAni = get_node("AniNode/Upgrade")

onready var WarningNode = get_node("WarningNode")
onready var A_But = get_node("But/A")
onready var Y_But = get_node("But/Y")

onready var Audio_Add

var MakingType: int = 0
var CurKEY: int = 0
var IsBlackOut: bool = false
var _POWERCOUNT: float
var _KEYLIST: Array
var EggRollNum: int = 0
var EggRollType: int = 0
var IsBroken: bool
var IsPassDay: bool
var ItemMax: int = 12
func _DayClosedCheck():
	if not GameLogic.cur_Rewards.has("蛋卷机升级+"):
		if EggRollNum > 0:
			if not IsPassDay and not IsBroken:
				IsPassDay = true
			elif IsPassDay and not IsBroken:
				IsBroken = true
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	A_But.hide()
	if _Player.Con.IsHold:
		var _OBJ = instance_from_id(_Player.Con.HoldInsId)
		var _FUNC = _OBJ.FuncType
		if _FUNC == "EggRollCup":
			var _PARA = _OBJ.FuncTypePara
			var _CHECK: bool
			if EggRollNum <= 0:
				_CHECK = true
			elif _PARA in ["蛋卷白"] and EggRollType == 1:
				_CHECK = true
			elif _PARA in ["蛋卷黑"] and EggRollType == 2:
				_CHECK = true
			if _CHECK:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
				A_But.show()
		elif _FUNC in ["EggRollPot"]:
			if _OBJ.Liquid_Count > 0:
				if not _TurnOn:
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
					A_But.show()
	else:
		if EggRollNum > 0:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
			A_But.show()
		else:
			if CanMove:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
				A_But.show()

	if WarningNode.NeedFix:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)
		Y_But.show()
	else:
		Y_But.hide()

	.But_Switch(_bool, _Player)

func _ready() -> void :
	call_init(SelfDev)

	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
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
		if not _TurnOn and not EggRollNum and not MakingType:
			CanMove = true
		else:
			CanMove = false
	else:
		CanMove = false
func _BlackOut(_Switch):
	IsBlackOut = _Switch
func call_Effect_files():
	if IsBroken:
		$Effect_flies / Ani.play("Flies")
	elif IsPassDay:
		$Effect_flies / Ani.play("OverDay")
	else:
		$Effect_flies / Ani.play("init")
func Update_Check():
	var _Mult: float = 1

	if GameLogic.cur_Rewards.has("蛋卷机升级"):
		ItemMax = 24
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("蛋卷机升级+"):
		ItemMax = 24
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

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)

	_TurnOn = _Info.TurnOn


	if _Info.has("EggRollNum"):
		EggRollNum = _Info.EggRollNum
		MakingType = 0
		EggRollType = _Info.EggRollType
		CurKEY = _Info.CurKEY
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay
		IsBroken = _Info.IsBroken
	call_Effect_files()
	Update_Check()

	_Reset_EggRoll()
func _Reset_EggRoll():
	var _NODELIST = $TexNode / Machine / EggNode.get_children()

	for _i in _NODELIST.size():
		var _NODE = _NODELIST[_i]
		if (_i + 1) <= EggRollNum:
			if EggRollType == 1:
				var _tex = "res://Resources/Devices/device2_pack.sprites/item_eggroll_white.tres"
				var _texload = load(_tex)
				_NODE.set_texture(_texload)
			elif EggRollType == 2:
				var _tex = "res://Resources/Devices/device2_pack.sprites/item_eggroll_black.tres"
				var _texload = load(_tex)
				_NODE.set_texture(_texload)
			_NODE.show()

		else:
			_NODE.hide()

	_CanMove_Check()

func call_MachineControl_puppet(_TURN, _PLAYERPATH):
	_TurnOn = _TURN
	var _Player = get_node(_PLAYERPATH)
	if _TurnOn:
		GameLogic.Audio.But_SwitchOn.play(0)

		But_Switch(true, _Player)
	else:
		GameLogic.Audio.But_SwitchOff.play(0)

		But_Switch(true, _Player)
func call_EggRoll_In(_ButID, _HoldObj, _Player):
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
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if _HoldObj.IsBroken:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if MakingType == 0:
				if EggRollType == 1 and _HoldObj.WaterType != "蛋卷白" and EggRollNum > 0:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
					return
				if EggRollType == 2 and _HoldObj.WaterType != "蛋卷黑" and EggRollNum > 0:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if _HoldObj.Liquid_Count > 0:
					if EggRollNum <= ItemMax - 4:
						_HoldObj.call_Use_Machine()
						MakingEggRoll(_HoldObj.WaterType)
						But_Switch(true, _Player)
					else:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoAdd()
						return

		1, 2, 3:
			if MakingType in [3, 4]:
				call_QTE(_ButID)
				return true
func call_QTE(_BUTID):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _BOOL: bool
	if CurKEY < 4:
		var _KEY = _KEYLIST[CurKEY]
		match _BUTID:

			1:
				if _KEY == "B":
					call_Right()
					_BOOL = true
				else:
					call_Wrong()
			2:
				if _KEY == "X":
					call_Right()
					_BOOL = true
				else:
					call_Wrong()
			3:
				if _KEY == "Y":
					call_Right()
					_BOOL = true
				else:
					call_Wrong()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_QTE_puppet", [_BOOL, CurKEY, EggRollNum])
	if CurKEY >= 4:
		MakingType = 0
		CurKEY = 0
		$TexNode / UI / show.play("hide")
		_CanMove_Check()
		WarningNode.return_Fix()
		_TurnOn = false
func call_QTE_puppet(_BOOL, _KEY, _NUM):
	CurKEY = _KEY
	EggRollNum = _NUM
	match CurKEY:
		1:
			if _BOOL:
				$TexNode / UI / QTE / BT1 / sprite / QTEAni.play("right")
			else:
				$TexNode / UI / QTE / BT1 / sprite / QTEAni.play("wrong")
			$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("now")
		2:
			if _BOOL:
				$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("right")
			else:
				$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("wrong")
			$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("now")
		3:
			if _BOOL:
				$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("right")
			else:
				$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("wrong")
			$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("now")
		4:
			if _BOOL:
				$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("right")
			else:
				$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("wrong")
	if $TexNode / Machine / EggNode.has_node(str(EggRollNum)):
		$TexNode / Machine / EggNode.get_node(str(EggRollNum)).show()
	if CurKEY >= 4:
		MakingType = 0
		CurKEY = 0
		$TexNode / UI / show.play("hide")
func call_Right():
	CurKEY += 1
	match CurKEY:
		1:
			$TexNode / UI / QTE / BT1 / sprite / QTEAni.play("right")
			$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("now")
		2:
			$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("right")
			$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("now")
		3:
			$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("right")
			$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("now")
		4:
			$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("right")
	if $AniNode / EggRollAni.assigned_animation in ["蛋卷白"] and EggRollType != 1:
		EggRollType = 1
	elif $AniNode / EggRollAni.assigned_animation in ["蛋卷黑"] and EggRollType != 2:
		EggRollType = 2
	EggRollNum += 1
	$TexNode / Machine / EggNode.get_node(str(EggRollNum)).show()
func call_Wrong():
	CurKEY += 1
	match CurKEY:
		1:
			$TexNode / UI / QTE / BT1 / sprite / QTEAni.play("wrong")
			$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("now")
		2:
			$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("wrong")
			$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("now")
		3:
			$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("wrong")
			$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("now")
		4:
			$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("wrong")
func MakingEggRoll(_WaterType):
	CanMove = false
	match _WaterType:
		"蛋卷白":
			MakingType = 1
			EggRollType = 1
			UseAni.play("cook_white")
			$AniNode / EggRollAni.play("蛋卷白")
		"蛋卷黑":
			MakingType = 2
			EggRollType = 2
			UseAni.play("cook_black")
			$AniNode / EggRollAni.play("蛋卷黑")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "MakingEggRoll", [_WaterType])
func call_Making_Finish():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	_KEYLIST.clear()
	for _i in 4:
		var _RAND = GameLogic.return_RANDOM() % 3 + 1
		match _RAND:

			1:
				_KEYLIST.append("B")
			2:
				_KEYLIST.append("X")
			3:
				_KEYLIST.append("Y")
	match MakingType:
		1:
			MakingType = 3
		2:
			MakingType = 4
	CurKEY = 0
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_KeySet_puppet", [_KEYLIST, MakingType])
	call_KeySet()
	$TexNode / UI / show.play("show")
func call_KeySet_puppet(_LIST, _TYPE):
	CurKEY = 0
	MakingType = _TYPE
	_KEYLIST = _LIST
	call_KeySet()
	$TexNode / UI / show.play("show")
func call_KeySet():
	for _i in _KEYLIST.size():
		match _i:
			0:
				$TexNode / UI / QTE / BT1 / sprite / Type.play(_KEYLIST[_i])
				$TexNode / UI / QTE / BT1 / sprite / QTEAni.play("now")
			1:
				$TexNode / UI / QTE / BT2 / sprite / Type.play(_KEYLIST[_i])
				$TexNode / UI / QTE / BT2 / sprite / QTEAni.play("show")
			2:
				$TexNode / UI / QTE / BT3 / sprite / Type.play(_KEYLIST[_i])
				$TexNode / UI / QTE / BT3 / sprite / QTEAni.play("show")
			3:
				$TexNode / UI / QTE / BT4 / sprite / Type.play(_KEYLIST[_i])
				$TexNode / UI / QTE / BT4 / sprite / QTEAni.play("show")
func call_EggRollCup(_ButID, _HoldObj, _Player):
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
			if EggRollType == 1 and _HoldObj.FuncTypePara == "蛋卷白" and EggRollNum < ItemMax:
				if _HoldObj.return_EmptyCheck(IsPassDay):
					call_EggRoll_PutOn(_HoldObj, _Player)
					But_Switch(true, _Player)
				elif _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			elif EggRollType == 2 and _HoldObj.FuncTypePara == "蛋卷黑" and EggRollNum < ItemMax:
				if _HoldObj.return_EmptyCheck(IsPassDay):
					call_EggRoll_PutOn(_HoldObj, _Player)
					But_Switch(true, _Player)
				elif _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			elif EggRollType == 0 and EggRollNum < ItemMax:
				if _HoldObj.return_EmptyCheck(IsPassDay):
					call_EggRoll_PutOn(_HoldObj, _Player)
					But_Switch(true, _Player)
				elif _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			else:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
func call_EggRoll_PutOn(_HoldObj, _Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _CUPPATH = _HoldObj.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_CupIn_puppet", [_PLAYERPATH, _CUPPATH])
	match _HoldObj.FuncTypePara:
		"蛋卷白":
			EggRollType = 1
		"蛋卷黑":
			EggRollType = 2
	EggRollNum += 1
	_Reset_EggRoll()

	GameLogic.Order.call_OutLine(_HoldObj.cur_ID, 0)
	_HoldObj.call_cleanID()
	_HoldObj.call_del()
	_Player.Stat.call_carry_off()
func call_CupIn_puppet(_PLAYERPATH, _CUPPATH):
	var _Player = get_node(_PLAYERPATH)
	var _CupObj = get_node(_CUPPATH)
	if not is_instance_valid(_CupObj):
		return
	match _CupObj.FuncTypePara:
		"蛋卷白":
			EggRollType = 1
		"蛋卷黑":
			EggRollType = 2
	EggRollNum += 1
	_Reset_EggRoll()

	GameLogic.Order.call_OutLine(_CupObj.cur_ID, 0)
	_CupObj.call_cleanID()

	_CupObj.call_del()
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
			But_Switch(true, _Player)
		0:
			if EggRollNum > 0 and not _Player.Con.IsHold:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				call_Pick_EggRoll(_Player)
				But_Switch(true, _Player)
		1:
			if MakingType in [3, 4]:
				call_QTE(_ButID)
		2:
			if MakingType in [3, 4]:
				call_QTE(_ButID)
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				if MakingType in [3, 4]:
					call_QTE(_ButID)
func call_Trashbag_init(_Player, Trashbag_TSCN, _CarryWeight, _COUNT):
	_Player.Con.HoldInsId = Trashbag_TSCN.get_instance_id()

	Trashbag_TSCN.call_load({"NAME": Trashbag_TSCN.name, "Weight": _CarryWeight})
	Trashbag_TSCN.call_Trashbag_init(_COUNT, false)
	if _CarryWeight < 0.5:
		_CarryWeight = 0.5
	Trashbag_TSCN.CarrySpeed = _CarryWeight

	_Player.Con.IsHold = true
	_Player.Con.HoldObj = Trashbag_TSCN
	_Player.Con.NeedPush = true
	_Player.Stat.call_carry_on(_CarryWeight)

func call_Trashbin_puppet(_PLAYER, _NAME, _CarryWeight, _COUNT):
	var _Player = get_node(_PLAYER)
	var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
	Trashbag_TSCN.name = _NAME
	SteamLogic.OBJECT_DIC[int(_NAME)] = Trashbag_TSCN
	_Player.WeaponNode.add_child(Trashbag_TSCN)
	call_Trashbag_init(_Player, Trashbag_TSCN, _CarryWeight, _COUNT)
	if _Player.cur_Player == SteamLogic.STEAM_ID:
		GameLogic.Tutorial.call_DrapTrashbag(true)
	EggRollNum = 0
	_Reset_EggRoll()
	EggRollType = 0
	IsPassDay = false
	IsBroken = false
	call_Effect_files()
	_CanMove_Check()
func call_Pick_EggRoll(_Player):
	if EggRollNum > 0:
		if IsBroken:
			var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
			var _NAME = str(Trashbag_TSCN.get_instance_id())
			Trashbag_TSCN.name = _NAME
			SteamLogic.OBJECT_DIC[int(_NAME)] = Trashbag_TSCN
			_Player.WeaponNode.add_child(Trashbag_TSCN)
			var _COUNT = EggRollNum
			var _CarryWeight: float = 1.0 - (float(_COUNT) / 10 * 0.5)
			call_Trashbag_init(_Player, Trashbag_TSCN, _CarryWeight, EggRollNum)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYER = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Trashbin_puppet", [_PLAYER, _NAME, _CarryWeight, _COUNT])
			EggRollNum = 0
			_Reset_EggRoll()
			EggRollType = 0
			IsPassDay = false
			IsBroken = false
			call_Effect_files()
		else:
			EggRollNum -= 1
			_Reset_EggRoll()
			var _EGGROLL = _EGGROLLTSCN.instance()
			var _ID = _EGGROLL.get_instance_id()
			_EGGROLL._SELFID = _ID
			_EGGROLL.name = str(_ID)
			SteamLogic.OBJECT_DIC[_EGGROLL._SELFID] = _EGGROLL
			GameLogic.Device.call_Pick_Logic(_Player, _EGGROLL)
			var _TYPE = "EggRoll_white"
			if EggRollType == 1:
				_TYPE = "EggRoll_white"
			elif EggRollType == 2:
				_TYPE = "EggRoll_black"
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYERPATH = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Pick_EggRoll_puppet", [_PLAYERPATH, _ID, EggRollNum, EggRollType])
			_EGGROLL.call_CupType_init(_TYPE, true, _Player.cur_Player)

			_Player.Stat.call_carry_on(_EGGROLL.CarrySpeed)
			if IsBroken:
				_EGGROLL.call_add_Stale()
			if IsPassDay:
				_EGGROLL.call_add_PassDay()
			if EggRollNum <= 0:
				EggRollType = 0
				IsPassDay = false
				IsBroken = false
				call_Effect_files()
	_CanMove_Check()
func call_Pick_EggRoll_puppet(_PLAYERPATH, _ID, _NUM, _TYPE):
	var _Player = get_node(_PLAYERPATH)
	var _EGGROLL = _EGGROLLTSCN.instance()
	_EGGROLL._SELFID = _ID
	_EGGROLL.name = str(_EGGROLL._SELFID)
	SteamLogic.OBJECT_DIC[_EGGROLL._SELFID] = _EGGROLL
	GameLogic.Device.call_Pick_Logic(_Player, _EGGROLL)
	var _CUPTYPE: String = ""
	if _TYPE == 1:
		_CUPTYPE = "EggRoll_white"
	elif _TYPE == 2:
		_CUPTYPE = "EggRoll_black"
	_EGGROLL.call_CupType_init(_CUPTYPE, true, _Player.cur_Player)
	if IsPassDay:
		_EGGROLL.call_add_PassDay()
	if IsBroken:
		_EGGROLL.call_add_Stale()
	_Player.Stat.call_carry_on(_EGGROLL.CarrySpeed)
	EggRollNum = _NUM
	if EggRollNum <= 0:
		EggRollType = 0
		IsPassDay = false
		IsBroken = false
		call_Effect_files()
	_Reset_EggRoll()
	_CanMove_Check()
func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_TurnOn = true

	GameLogic.Audio.But_SwitchOn.play(0)

func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if WarningNode.return_Fixing(_Player):
		_TurnOn = true

		GameLogic.Audio.But_SwitchOn.play(0)
		But_Switch(true, _Player)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Fix_puppet", [_PLAYERPATH])

func call_Fixing_Ani(_Player):
	UseAni.play("init")
	UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
