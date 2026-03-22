extends Head_Object
var SelfDev = "SodaPack"
var HasSodaCan: bool
var Can_Pick: bool = true

var PowerMult: float = 1
var IsBlackOut: bool = false

var SodaObj
onready var CanNode = $TexNode / CanNode
onready var UseAni = $AniNode / Use

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

	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	_CanMove_Check()
func _CanMove_Check():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if CanLayout:
		if not HasSodaCan:
			CanMove = true
		else:
			CanMove = false
	else:
		CanMove = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CanMove_puppet", [CanMove])

func call_CanMove_puppet(_CANMOVE):
	CanMove = _CANMOVE

var ANISPEED: float = 1
func Update_Check():

	if GameLogic.cur_Rewards.has("封盖机升级"):

		$AniNode / Upgrade.play("2")

	elif GameLogic.cur_Rewards.has("封盖机升级+"):

		$AniNode / Upgrade.play("3")
	else:
		$AniNode / Upgrade.play("1")
	var _SPEEDMULT: float = GameLogic.return_Multiplier_Division()

	if GameLogic.cur_Challenge.has("电压不稳"):
		_SPEEDMULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_SPEEDMULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_SPEEDMULT -= 0.4
	ANISPEED = _SPEEDMULT

func _BlackOut(_Switch):
	IsBlackOut = _Switch

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)

	if _Info.SodaObj:
		var _SODACANINFO = _Info.SodaObj
		var _SODACAN_TSCN = GameLogic.TSCNLoad.return_TSCN(_SODACANINFO.TSCN)
		var _SODACAN = _SODACAN_TSCN.instance()
		CanNode.add_child(_SODACAN)
		_SODACAN.call_load(_SODACANINFO)
		SodaObj = _SODACAN
		HasSodaCan = true
		Can_Pick = true
	_CanMove_Check()
	Update_Check()
func But_Switch(_Switch, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	.But_Switch(_Switch, _Player)
var _PLAYERLIST: Array

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
func call_SodaCan_Pack(_ButID, _HoldObj, _Player):
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
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if IsBlackOut:
				return
			if $WarningNode.NeedFix:
				return
			if not _HoldObj.get("IsPack") and not HasSodaCan and not _Player.Con.IsMixing:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _HOLDOBJPATH = _HoldObj.get_path()
					var _PLAYERPATH = _Player.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_SodaPack_puppet", [_HOLDOBJPATH, _PLAYERPATH])
				_SodaPackLogic(_HoldObj, _Player)
				GameLogic.Total_Electricity += 0.5 * PowerMult


func call_SodaPack_puppet(_HOLDOBJPATH, _PLAYERPATH):
	if has_node(_HOLDOBJPATH) and has_node(_PLAYERPATH):
		var _HoldObj = get_node(_HOLDOBJPATH)
		var _Player = get_node(_PLAYERPATH)
		_SodaPackLogic(_HoldObj, _Player)
func _SodaPackLogic(_SODAOBJ, _PLAYER):
	HasSodaCan = true
	Can_Pick = false
	_CanMove_Check()

	SodaObj = _SODAOBJ
	_PLAYER.WeaponNode.remove_child(_SODAOBJ)
	_SODAOBJ.position = Vector2.ZERO
	_PLAYER.Stat.call_carry_off()
	CanNode.add_child(_SODAOBJ)
	_SODAOBJ.call_CupInfo_Switch(false)
	UseAni.playback_speed = ANISPEED
	if GameLogic.cur_Rewards.has("封盖机升级"):
		UseAni.play("Use_2")
	elif GameLogic.cur_Rewards.has("封盖机升级+"):
		UseAni.play("Use")
	else:

		UseAni.play("Use_3")
	_SODAOBJ.get_node("Hold/X").hide()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

func call_CanPick_Switch(_Switch: bool):
	Can_Pick = _Switch

func call_SodaPack():
	if is_instance_valid(SodaObj):
		if SodaObj.has_method("call_pack"):
			SodaObj.call_pack()
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _ISCOMBO: bool = false
	if GameLogic.cur_Rewards.has("封盖机升级"):
		var _RAND = GameLogic.return_randi() % 100
		var _RAT = 10
		if _RAND < _RAT:
			$AniNode / ComboAni.play("init")
			$AniNode / ComboAni.play("combo")
			GameLogic.call_combo(1)
			_ISCOMBO = true
	elif GameLogic.cur_Rewards.has("封盖机升级+"):
		var _RAND = GameLogic.return_randi() % 100
		var _RAT = 30
		if _RAND < _RAT:
			$AniNode / ComboAni.play("init")
			$AniNode / ComboAni.play("combo")
			GameLogic.call_combo(1)
			_ISCOMBO = true
	if _ISCOMBO:
		call_Extra()

func call_Fix_Logic(_Player):
	if $WarningNode.return_Fixing(_Player):
		call_Fix_Ani(_Player)
		But_Switch(true, _Player)
	else:
		call_Fix_Ani(_Player)

func call_Fix_Ani(_Player):
	$AniNode / Add.play("fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func call_pick(_ButID, _Player):
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
			if Can_Pick and is_instance_valid(SodaObj):
				GameLogic.Device.call_Pick_Logic(_Player, SodaObj)
				SodaObj = null
				Can_Pick = false
				HasSodaCan = false
				_CanMove_Check()
				call_pick( - 2, _Player)
			elif not Can_Pick and is_instance_valid(SodaObj):
				if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					_Player.call_Say_Making()
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
