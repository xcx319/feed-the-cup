extends Head_Object
var SelfDev = "InductionCooker"

var HasTeaLeaf: bool
var HasWater: bool
var PutOffset = Vector2(0, - 10)

var CookedDelta: float

var powerMult: float = 5
var _power: float = 0.05

onready var CookerAni = get_node("AniNode/CookerAni")
onready var UpgradeAni = get_node("AniNode/Upgrade")
onready var A_But = get_node("But/A")
onready var Audio_100
onready var Audio_Put
var IsAudio: bool
var IsBlackOut: bool
var _POWERCOUNT: float
func But_Switch(_bool, _Player):
	A_But.show()
	if is_instance_valid(OnTableObj):
		if OnTableObj.SelfDev == "MilkPot":
			OnTableObj.But_Switch(_bool, _Player)
			A_But.hide()
		else:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	else:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)

	.But_Switch(_bool, _Player)

func _DayClosedCheck():

	if OnTableObj and not GameLogic.cur_Rewards.has("电磁炉升级+"):
		if OnTableObj.HasWater:
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.INDUCTIONCOOKER)

			var Hour: float
			if GameLogic.cur_CloseTime > 12:
				Hour = 24 - GameLogic.cur_CloseTime + GameLogic.cur_OpenTime
			else:
				Hour = GameLogic.cur_OpenTime - GameLogic.cur_CloseTime
			var _morepower = Hour * _power * 60
			GameLogic.Total_Electricity += _morepower
			_POWERCOUNT += _morepower


func _ready() -> void :
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	Audio_100 = GameLogic.Audio.return_Effect("水烧开")
	Audio_Put = GameLogic.Audio.return_Effect("放下")
func _BlackOut(_Switch):
	IsBlackOut = _Switch

func _CanMove_Check():
	if CanLayout:
		if OnTableObj:
			CanMove = false
		else:
			CanMove = true
func Update_Check():

	powerMult = 8 / GameLogic.return_Multiplier_Division()
	if GameLogic.cur_Rewards.has("电磁炉升级"):

		powerMult = 12 / GameLogic.return_Multiplier_Division()
		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")

	elif GameLogic.cur_Rewards.has("电磁炉升级+"):

		powerMult = 20 / GameLogic.return_Multiplier_Division()
		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")

	var _MULT: float = 1
	if GameLogic.cur_Challenge.has("电压不稳"):

		_MULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):

		_MULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):

		_MULT -= 0.4
	if is_instance_valid(OnTableObj):
		if OnTableObj.WaterCelcius >= 85:
			powerMult = powerMult / 5
			return
	powerMult = float(powerMult) * _MULT

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	Update_Check()
	if _Info.Obj:
		var _TableData = _Info.Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_TableData.TSCN)
		var _Dev = _TSCN.instance()
		_Dev.position = _TableData.pos
		_Dev.name = _TableData.NAME
		SavedNode.add_child(_Dev)
		OnTableObj = _Dev
		CanPick = true
		_Dev.call_load(_TableData)
		call_Cooked()
		_CanMove_Check()
	else:
		OnTableObj = null
		_CanMove_Check()


func call_Cooked():

	if OnTableObj:
		if not OnTableObj.HasWater:
			CookerAni.play("close")
			set_process(false)
			return

		CookedDelta = 0.0
		set_process(true)
		Update_Check()
		if IsBlackOut:
			CookerAni.play("close")
			return
		CookerAni.play("open")

func call_Picked():
	CookerAni.play("close")
	CanPick = false
	_CanMove_Check()

func call_cooker_puppet(_CELCIUS):
	OnTableObj.WaterCelcius = _CELCIUS
	if OnTableObj.WaterCelcius >= 100:
		OnTableObj.WaterCelcius = 100
		if not IsAudio:
			IsAudio = true
			Audio_100.play(0)
		CookerAni.play("boiling")
	else:
		if IsAudio:
			IsAudio = false
			Audio_100.stop()
		CookerAni.play("open")
	OnTableObj.call_WaterCelcius_change()
func _process(delta: float) -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		set_process(false)
		return
	if OnTableObj:
		if IsBlackOut:
			return


		if OnTableObj.WaterCelcius < 85:
			CookedDelta += delta * powerMult
		else:

			CookedDelta += delta * powerMult
		if CookedDelta > 1:


			OnTableObj.WaterCelcius += int(CookedDelta)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_cooker_puppet", [OnTableObj.WaterCelcius])
			if OnTableObj.WaterCelcius >= 100:
				OnTableObj.WaterCelcius = 100
				if not GameLogic.cur_Rewards.has("电磁炉升级+"):
					GameLogic.Total_Electricity += float(_power)
					_POWERCOUNT += _power

				if not IsAudio:
					IsAudio = true

					Audio_100.play(0)
				CookerAni.play("boiling")
			else:
				if IsAudio:
					IsAudio = false

					Audio_100.stop()
				CookerAni.play("open")
				Update_Check()
				GameLogic.Total_Electricity += float(_power)
				_POWERCOUNT += _power
			OnTableObj.call_WaterCelcius_change()
			CookedDelta = 0

func call_PutOnCooker_puppet(_PLAYERPATH, _OBJPATH):
	var _Player = get_node(_PLAYERPATH)
	var _HoldObj = get_node(_OBJPATH)
	_Player.WeaponNode.remove_child(_HoldObj)
	_Player.Stat.call_carry_off()
	SavedNode.add_child(_HoldObj)
	OnTableObj = _HoldObj
	_CanMove_Check()
	call_Cooked()
	But_Switch(true, _Player)
	Audio_Put.play(0)
func call_DevLogic_PutLiquidCon_On_Cooker(_But, _Player):


	match _But:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _Player.Con.IsHold and not OnTableObj:
				But_Switch(true, _Player)
			else:
				But_Switch(true, _Player)

		0:
			if not OnTableObj:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				var _HoldObj = instance_from_id(_Player.Con.HoldInsId)

				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAYERPATH = _Player.get_path()
					var _OBJPATH = _HoldObj.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOnCooker_puppet", [_PLAYERPATH, _OBJPATH])
				_Player.WeaponNode.remove_child(_HoldObj)
				_Player.Stat.call_carry_off()
				SavedNode.add_child(_HoldObj)
				_HoldObj.IsCooking = true
				CanPick = true
				OnTableObj = _HoldObj
				_CanMove_Check()
				call_Cooked()
				But_Switch(true, _Player)
				Audio_Put.play(0)

				return true

func call_Pick_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	var _Obj = OnTableObj
	SavedNode.remove_child(_Obj)
	OnTableObj = null
	_CanMove_Check()
	if _Obj.WaterCelcius >= 100:
		_Obj.WaterCelcius = 99
		Audio_100.stop()
		_Obj.call_WaterCelcius_change()
	GameLogic.Device.call_Player_Pick(_Player, _Obj)
	if _Obj.has_method("call_ColdTimer"):
		_Obj.call_ColdTimer()
	CookerAni.play("close")
	But_Switch(true, _Player)
	set_process(false)

	pass
func call_DevLogic_Pick(_ButID, _Player):

	if OnTableObj:
		match _ButID:

			- 2:
				But_Switch(false, _Player)
				var _Obj = OnTableObj

			- 1:
				if not _Player.Con.IsHold and OnTableObj:
					But_Switch(true, _Player)
				var _Obj = OnTableObj

			0:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return

				_CanMove_Check()


				GameLogic.Device.call_Player_Pick(_Player, OnTableObj)

				return true

	else:
		if not _Player.Con.IsHold:
			But_Switch(false, _Player)
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
