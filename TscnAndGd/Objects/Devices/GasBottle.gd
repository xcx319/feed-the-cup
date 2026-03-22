extends Head_Object
var SelfDev = "GasBottle"

var GasNum: int = 200
var GasMax: int = 200
onready var NumPro = $TexNode / Ui / TextureProgress
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

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

onready var ChargeTimer = $ChargeTimer
var _CHARGEOBJ
var _CHARGEPLAYER
var _MACHINE
func call_ChargeGas(_Obj, _Player, _Machine):
	var _CHECK = _Obj.WaterType
	var _CHECKTYPE = _Obj.TYPE

	if GasNum > 0 and not _Obj._GasChargeBool and _Obj.GasNum < 100 and _Obj.Liquid_Count > 0:

		call_Charge_Hold(_Obj, _Player, _Machine)
		return "充气"
func call_Charge_Logic(_Obj, _Player, _Machine):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	_CHARGEOBJ = _Obj
	_MACHINE = _Machine
	_CHARGEPLAYER = _Player
	_CHARGEOBJ._GasChargeBool = true
	ChargeTimer.start(0)
	if _MACHINE.has_method("call_charge_ani"):
		_MACHINE.call_charge_ani(0)

func call_Charge_puppet(_PLAYERPATH):

	pass
func call_Charge_Hold(_Obj, _Player, _Machine):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return

	var _CHECK = return_SHAKE(_Player)
	if _CHECK:
		_CHARGEPLAYER = _Player
		_Player.call_GasChargeAni()

		call_Charge_Logic(_Obj, _Player, _Machine)

func _ADD_Logic(_OBJ):

	pass
func return_SHAKE(_Player):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_SHAKE_start", [_PLAYERPATH])
	return true

func call_puppet_SHAKE_start(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_CHARGEPLAYER = _Player

	_Player.Con.call_SHAKE()
func call_WORKING_end(_Player):

	if _CHARGEPLAYER == _Player:
		call_ChargeFinished()



		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH])
func call_puppet_STIR_end(_PATH):
	var _Player = get_node(_PATH)
	_Player.call_reset_stat_puppet()
	call_ChargeFinished()

func call_ChargeFinished():

	if not is_instance_valid(_CHARGEOBJ):
		return
	ChargeTimer.stop()
	_CHARGEOBJ._GasChargeBool = false
	_CHARGEPLAYER._on_OrderTimer_timeout()
	_CHARGEOBJ = null
	_CHARGEPLAYER = null
	if _MACHINE.has_method("call_charge_ani"):
		_MACHINE.call_charge_ani(1)
	_MACHINE = null
	pass
func call_full():
	GasNum = GasMax
	call_Num_Set()
	var _AUDIO = GameLogic.Audio.return_Effect("充气")
	_AUDIO.play(0)
func return_full_num():
	var _ChargeNum: int = GasMax - GasNum
	GasNum = GasMax
	call_Num_Set()
	return _ChargeNum

var _ChargeMult: float = 0.1
func _on_ChargeTimer_timeout():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GasNum > 0:
		if is_instance_valid(_CHARGEOBJ):
			if _CHARGEOBJ.GasNum < 100:
				if GameLogic.cur_Rewards.has("软饮机升级"):
					_ChargeMult = 0.05
				elif GameLogic.cur_Rewards.has("软饮机升级+"):
					_ChargeMult = 0.01
				GasNum -= 1

				var _CHARGENUM: int = (_CHARGEOBJ.Liquid_Max - _CHARGEOBJ.Liquid_Count) * _ChargeMult + 1
				_CHARGEOBJ.call_GasChange(_CHARGENUM)

				_MACHINE.call_PopLogic()
				call_Num_Set()
				if GasNum <= 0:
					call_ChargeFinished()
			else:
				call_ChargeFinished()

	pass

func _ready() -> void :
	call_init(SelfDev)
	call_deferred("_collision_check")

	GameLogic.NPC.GASLIST.append(self)
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

func call_Used():
	GasNum -= 1
	call_Num_Set()

func call_NumSet_puppet(_GASNUM):
	GasNum = _GASNUM
	call_Num_Set()

func call_Gas_Used(_NUM: int):
	GasNum -= _NUM
	if GasNum <= 0:
		GasNum = 0
	call_Num_Set()
func call_Num_Set():
	NumPro.max_value = GasMax
	NumPro.value = GasNum
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_NumSet_puppet", [GasNum])
func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	GasNum = int(_Info.GasNum)
	call_Num_Set()

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)


func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
