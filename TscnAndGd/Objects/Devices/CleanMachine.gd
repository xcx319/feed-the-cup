extends Head_Object
var SelfDev = "CleanMachine"

var CUPLIST: Array
onready var Layer1 = get_node("TexNode/layer1")
onready var Layer2 = get_node("TexNode/layer2")
onready var MachineAni = $AniNode / MachineAni
onready var UseAni = $AniNode / UseAni

var _MAX: int = 4
var _TurnOn: bool = false
var CleanTime: float = 10
var ANI_Mult: float = 1

var cur_Cups: int = 0
var cleaningQueue: Array = []
var cleanedCups: Array = []

onready var UpgradeAni = get_node("AniNode/Upgrade")

onready var WarningNode = get_node("WarningNode")
onready var A_But = get_node("But/A")

onready var Y_But = get_node("But/Y")
onready var Audio_Add

var IsBlackOut: bool = false
var _POWERCOUNT: float

func _DayClosedCheck():

	if _TurnOn and not IsBlackOut:

		GameLogic.Total_Electricity += 6
		GameLogic.Total_Water += 4
		if CUPLIST.size():
			for _CUP in CUPLIST:
				_CUP.call_wash()

	cur_Cups = 0
	cleaningQueue.clear()
	cleanedCups.clear()

func _CleanLogic(_bool, _Player):
	But_Switch(_bool, _Player)
func But_Switch(_bool, _Player):


	if not _bool:
		get_node("But").hide()
		OpenLogic(false)
	else:
		OpenLogic(true)
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	get_node("But").show()
	if _TurnOn:
		A_But.hide()
	elif _Player.Con.IsHold:
		if CUPLIST.size() < _MAX:
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			if is_instance_valid(_Dev):
				var _FUNC = _Dev.FuncType
				if _Dev.FuncType in ["Plate"]:
					if _Dev._OBJLIST.size():
						A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
						A_But.show()
					else:
						if CUPLIST.size():
							A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
							A_But.show()
				elif _Dev.FuncType in ["DrinkCup"]:
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
					A_But.show()
		else:
			A_But.hide()
	else:
		if not _TurnOn and CUPLIST.size():
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			A_But.show()
		else:
			A_But.hide()
	if WarningNode.NeedFix:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_2)
	elif _TurnOn:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_1)
	else:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_Str)
	.But_Switch(_bool, _Player)

func _ready() -> void :
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")

export var powerMult: float = 20
func Update_Check():
	ANI_Mult = 1 / GameLogic.return_Multiplier_Division()

	if GameLogic.cur_Challenge.has("电压不稳"):
		ANI_Mult -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		ANI_Mult -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		ANI_Mult -= 0.4
	if GameLogic.cur_Rewards.has("清洗机升级"):
		ANI_Mult += 1

		_MAX = 4
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("清洗机升级+"):
		ANI_Mult += 1
		_MAX = 8
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")


	print("清洗机速度：", ANI_Mult)

func _BlackOut(_Switch):
	IsBlackOut = _Switch
	if IsBlackOut:
		call_Turn()

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if get_parent().name == "ObjNode":
		get_node("CollisionShape2D").disabled = true
	self.position = _Info.pos
	var _CUPSAVELIST: Array
	if _Info.has("OBJLIST"):
		_CUPSAVELIST = _Info.OBJLIST
	var _NUM: int = 1
	for _CUPINFO in _CUPSAVELIST:
		var _TSCN = load("res://TscnAndGd/Objects/Items/BeerCup.tscn")
		var _Obj = _TSCN.instance()
		_Obj.name = _CUPINFO.NAME

		call_Plate_Logic(_Obj)
		_Obj.call_load(_CUPINFO)
		_NUM += 1
func call_wash():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _test = MachineAni.assigned_animation
	match MachineAni.assigned_animation:
		"init", "3":

			call_Machine(0)
		"0":

			call_Machine(1)


		"1":

			call_Machine(2)
		"2":

			call_Machine(3)
func call_wash_logic():
	for _CUP in CUPLIST:
		if _CUP.has_method("call_wash"):
			_CUP.call_wash()

func Turn_puppet(_TURN):
	_TurnOn = _TURN
	_Turn_Logic()
func call_Turn():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if IsBlackOut or WarningNode.NeedFix:

		_TurnOn = false
		call_Machine( - 1)
		return

	_TurnOn = not _TurnOn

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "Turn_puppet", [_TurnOn])
	_Turn_Logic()
func _Turn_Logic():
	match _TurnOn:
		true:
			GameLogic.Audio.But_SwitchOn.play(0)
			call_wash()

		false:
			GameLogic.Audio.But_SwitchOff.play(0)
			MachineAni.play("init")
			OpenLogic(true)

func OpenLogic(_OpenBool: bool):
	match _OpenBool:
		true:
			if not _TurnOn:
				if not UseAni.assigned_animation in ["open"]:
					UseAni.play("open")
					if MachineAni.current_animation in ["3"]:
						call_Machine( - 1)
		false:
			if UseAni.assigned_animation in ["open"]:
				UseAni.play("close")

func call_Machine(_TYPE):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Machine", [_TYPE])
	match _TYPE:
		- 1:
			MachineAni.playback_speed = 1
			MachineAni.play("init")
			UseAni.play("init")
		0:
			MachineAni.playback_speed = ANI_Mult
			MachineAni.play("0")
			UseAni.play("wash")
		1:
			MachineAni.playback_speed = ANI_Mult
			MachineAni.play("1")
			GameLogic.Total_Water += 4
		2:
			MachineAni.playback_speed = ANI_Mult
			MachineAni.play("2")
			GameLogic.Total_Electricity += 3
		3:
			_TurnOn = false
			MachineAni.playback_speed = 1
			if UseAni.assigned_animation == "wash":
				UseAni.play("end")
			call_wash_logic()
			MachineAni.play("3")
			GameLogic.Total_Electricity += 3
			if WarningNode.return_Fix():
				call_Turn()

func call_Plate_Logic(_CUP):
	CUPLIST.append(_CUP)
	var _NUM = CUPLIST.size()
	if _NUM <= 4:
		if Layer1.has_node(str(_NUM)):
			var _NODE = Layer1.get_node(str(_NUM))
			_NODE.add_child(_CUP)
	elif _NUM > 4 and _NUM <= 8:
		if Layer2.has_node(str(_NUM - 4)):
			var _NODE = Layer2.get_node(str(_NUM - 4))
			_NODE.add_child(_CUP)

func Plate_pup(_PLATEID, _IDLIST):
	if not SteamLogic.OBJECT_DIC.has(_PLATEID):
		printerr(" Plate_pup OBJECT_DIC 无_PLATEID：", _PLATEID)
		return
	var _PLATE = SteamLogic.OBJECT_DIC[_PLATEID]
	for _CUPID in _IDLIST:
		if not SteamLogic.OBJECT_DIC.has(_CUPID):
			printerr(" Plate_pup OBJECT_DIC 无_IDLIST：", _CUPID)
			return
		var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
		var _CHECK: bool = _PLATE.return_Remove_CUP(_CUP)
		if _CHECK:
			call_Plate_Logic(_CUP)

func PlateOn_pup(_PLATEID, _IDLIST):
	if not SteamLogic.OBJECT_DIC.has(_PLATEID):
		printerr(" Plate_pup OBJECT_DIC 无_PLATEID：", _PLATEID)
		return
	var _PLATE = SteamLogic.OBJECT_DIC[_PLATEID]
	for _CUPID in _IDLIST:
		if not SteamLogic.OBJECT_DIC.has(_CUPID):
			printerr(" Plate_pup OBJECT_DIC 无_IDLIST：", _CUPID)
			return
		var _CUP = SteamLogic.OBJECT_DIC[_CUPID]
		if CUPLIST.has(_CUP):
			CUPLIST.erase(_CUP)
			_CUP.get_parent().remove_child(_CUP)
			_PLATE.call_CupOn(_CUP)
func call_Plate(_ButID, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)

		- 1:
			But_Switch(true, _Player)
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			if _TurnOn:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_NoUse()
				return
			var _Obj = instance_from_id(_Player.Con.HoldInsId)
			var _CUPNUM: int = _Obj._OBJLIST.size()
			var _SaveCupNum: int = CUPLIST.size()

			if _CUPNUM > 0:
				if _SaveCupNum < _MAX:
					var _CUPLIST: Array
					for _i in _CUPNUM:
						var _CUP = _Obj.return_CUP()
						var _CHECK: bool = _Obj.return_Remove_CUP(_CUP)
						if _CHECK:
							_CUPLIST.append(_CUP._SELFID)
							call_Plate_Logic(_CUP)

						if CUPLIST.size() >= _MAX:
							break

					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "Plate_pup", [_Obj._SELFID, _CUPLIST])
					var _AUDIO = GameLogic.Audio.return_Effect("放下")
					_AUDIO.play(0)
			else:
				if _SaveCupNum > 0:
					var _CUPLIST: Array
					for _i in _SaveCupNum:
						if _Obj._OBJLIST.size() >= 4:
							break
						var _CUP = CUPLIST.pop_back()
						_CUPLIST.append(_CUP._SELFID)
						_CUP.get_parent().remove_child(_CUP)
						_Obj.call_CupOn(_CUP)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_id_sync(_SELFID, "PlateOn_pup", [_Obj._SELFID, _CUPLIST])
					var _AUDIO = GameLogic.Audio.return_Effect("放下")
					_AUDIO.play(0)
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				call_Turn()
				But_Switch(true, _Player)
				return "开关"
func call_DrinkCup_Logic(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)

		- 1:

			But_Switch(true, _Player)

		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Obj = instance_from_id(_Player.Con.HoldInsId)
			if CUPLIST.size() < _MAX and not _TurnOn:

				var _Check = return_canput_check(_Obj)

				if not _Check:
					return
				return _PutOn(_Player)

		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				call_Turn()
				But_Switch(true, _Player)
func call_Ani(_TYPE):

	if has_node("AniNode/Act"):
		match _TYPE:
			"L":

				$AniNode / Act.play("OpenLeft")

			"R":

				$AniNode / Act.play("OpenRight")

func return_canput_check(_Obj):

	var _X = _Obj.FuncType
	match _Obj.FuncType:
		"DrinkCup":
			return true

func call_PutOn_puppet(_PLAYERPATH, _OBJID):
	if not SteamLogic.OBJECT_DIC.has(_OBJID):
		printerr(" OBJECT_DIC 未找到物品：", _OBJID)
		return
	var _Player = get_node(_PLAYERPATH)
	var _Obj = SteamLogic.OBJECT_DIC[_OBJID]
	if not is_instance_valid(_Obj):
		return

	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)
	call_Plate_Logic(_Obj)
	if _Obj.has_method("call_cleanID"):
		_Obj.call_cleanID()
	if _Obj.has_method("call_Info_Switch"):
		_Obj.call_Info_Switch(false)
	call_pick( - 1, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)
	var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
	_AUDIO.play(0)
func _PutOn(_Player):
	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Obj = instance_from_id(_Player.Con.HoldInsId)


	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)

	call_Plate_Logic(_Obj)
	if _Obj.has_method("call_cleanID"):
		_Obj.call_cleanID()

	if _Obj.has_method("call_Info_Switch"):
		_Obj.call_Info_Switch(false)
	call_pick( - 1, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _OBJPATH = _Obj.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOn_puppet", [_PLAYERPATH, _Obj._SELFID])
	var _AUDIO = GameLogic.Audio.return_Effect("碰杯子")
	_AUDIO.play(0)
	return "台架放入"

func return_CUPLIST():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "return_CUPLIST")
	return CUPLIST.pop_back()

func call_pick(_butID, _Player):

	match _butID:
		- 2:

			But_Switch(false, _Player)

		- 1:

			But_Switch(true, _Player)
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if not _TurnOn:
				if CUPLIST.size() > 0:
					var _CUP = return_CUPLIST()
					GameLogic.Device.call_Player_Pick(_Player, _CUP)
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
			else:
				call_Turn()
				But_Switch(true, _Player)

func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_TurnOn = true
	call_Turn()
	GameLogic.Audio.But_SwitchOn.play(0)

func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if WarningNode.return_Fixing(_Player):
		_TurnOn = true
		call_Turn()
		GameLogic.Audio.But_SwitchOn.play(0)
		But_Switch(true, _Player)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_Fix_puppet", [_PLAYERPATH])

func call_Fixing_Ani(_Player):
	UseAni.play("init")
	UseAni.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_pick_puppet(_PLAYERPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj
	GameLogic.Device.call_Player_Pick(_Player, _Obj)

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)
	call_pick( - 1, _Player)

func _pick(_Layer, _Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_puppet", [_PLAYERPATH, _Layer])
	var _Obj

	GameLogic.Device.call_Player_Pick(_Player, _Obj)

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)

func call_turn_logic():
	if IsBlackOut:

		return










	_Cup_Show()

func _Cup_Show():


	pass
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)

func _on_Timer_timeout():
	GameLogic.Total_Electricity += 0.1
func _on_CheckArea_area_entered(_area: Area2D) -> void :

	IsOverlap = true
