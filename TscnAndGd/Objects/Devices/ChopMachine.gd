extends Head_Object
var SelfDev = "ChopMachine"

var _BOX
onready var BoxNode = $TexNode / BoxNode
var FRUIT
onready var MachineANI = $AniNode / MachineAni
onready var FruitANI = $AniNode / FruitAni
onready var UseANI = $AniNode / UseAni
onready var _FruitInList: Array = ["芒果", "桃子", "西柚", "牛油果"]
onready var A_But = get_node("But/A")
onready var X_But = get_node("But/X")
var IsChoping: bool
var ChopingFruit: String
var IsBlackOut: bool = false
onready var But_Y = $But / Y
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
func Update_Check():
	if GameLogic.cur_Rewards.has("切块机升级"):
		$AniNode / Upgrade.play("2")
	elif GameLogic.cur_Rewards.has("切块机升级+"):
		$AniNode / Upgrade.play("3")
	else:
		$AniNode / Upgrade.play("1")
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_Machine_Logic()
func _DayClosedCheck():
	if IsChoping:
		call_Juice_finish()

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	A_But.show()
	But_Y.hide()
	if not _Player.Con.IsHold:
		if is_instance_valid(_BOX):
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)

		elif CanMove:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
		if $WarningNode.NeedFix:
			But_Y.show()
	else:
		var _Fruit = _Player.Con.HoldObj.FuncTypePara
		if _Player.Con.HoldObj.FuncType in ["Fruit"]:
			if _Fruit in _FruitInList:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		elif _Player.Con.HoldObj.FuncType in ["MaterialBig", "MaterialBox"] and not is_instance_valid(_BOX):
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		else:
			A_But.hide()
		if is_instance_valid(_BOX) and not _bool:
			_BOX.call_put_in_cup( - 2, _Player, null)

	.But_Switch(_bool, _Player)
func call_Machine_Logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if $WarningNode.NeedFix or IsBlackOut:
		if MachineANI.current_animation in ["切块", "切块2", "切块3"]:
			MachineANI.stop(false)
		return
	if not ChopingFruit:
		return
	if not is_instance_valid(_BOX):
		return
	var _SPEEDMULT: float = 1
	if GameLogic.cur_Challenge.has("电压不稳"):
		_SPEEDMULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_SPEEDMULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_SPEEDMULT -= 0.4
	MachineANI.playback_speed = _SPEEDMULT
	if GameLogic.cur_Rewards.has("切块机升级"):
		MachineANI.play("切块2")
	elif GameLogic.cur_Rewards.has("切块机升级+"):
		MachineANI.play("切块3")
	else:
		MachineANI.play("切块")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Machine_puppet")

func _CanMove_Check():
	pass
func call_Machine_puppet():
	var _SPEEDMULT: float = 1
	if GameLogic.cur_Challenge.has("电压不稳"):
		_SPEEDMULT -= 0.1
	if GameLogic.cur_Challenge.has("电压不稳+"):
		_SPEEDMULT -= 0.2
	if GameLogic.cur_Challenge.has("电压不稳++"):
		_SPEEDMULT -= 0.4
	MachineANI.playback_speed = _SPEEDMULT

	if GameLogic.cur_Rewards.has("切块机升级"):
		MachineANI.play("切块2")
	elif GameLogic.cur_Rewards.has("切块机升级+"):
		MachineANI.play("切块3")
	else:
		MachineANI.play("切块")

func call_Juice_finish():
	MachineANI.playback_speed = 1
	IsChoping = false
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if _BOX:

		var _NUM: int = 4
		var _FruitNAME: String
		var _ELE_Mult: float = 1
		match ChopingFruit:

			"牛油果":
				_NUM = 2
				_FruitNAME = "牛油果块"
				_ELE_Mult = 4
			"芒果":
				_NUM = 2
				_FruitNAME = "芒果块"
				_ELE_Mult = 2
			"桃子":
				_NUM = 3
				_FruitNAME = "桃子块"
				_ELE_Mult = 2
			"西柚":
				_NUM = 4
				_FruitNAME = "西柚块"
				_ELE_Mult = 2
		if GameLogic.cur_Rewards.has("切块机升级+"):
			_NUM += 1
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_finish_puppet", [_FruitNAME, _NUM])
		var _ItemTSCN = GameLogic.TSCNLoad.Fruit_TSCN
		_BOX.ItemType = _FruitNAME
		if GameLogic.Config.ItemConfig.has(_FruitNAME):
			_BOX.ItemFreshType = int(GameLogic.Config.ItemConfig[_FruitNAME].FreshType)
		for _i in _NUM:
			var _Item = _ItemTSCN.instance()
			_BOX.call_ItemInBox(_Item)
			_Item.call_load_TSCN(_FruitNAME)
		GameLogic.Total_Electricity += _ELE_Mult
		ChopingFruit = ""

func call_finish_puppet(_NAME, _NUM):
	var _ItemTSCN = GameLogic.TSCNLoad.Fruit_TSCN
	_BOX.ItemType = _NAME
	if GameLogic.Config.ItemConfig.has(_NAME):
		_BOX.ItemFreshType = int(GameLogic.Config.ItemConfig[_NAME].FreshType)
	for _i in _NUM:
		var _Item = _ItemTSCN.instance()
		_BOX.call_ItemInBox(_Item)
		_Item.call_load_TSCN(_NAME)
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("_BOX"):
		if _Info._BOX != null:
			call_MaterialBox_load(_Info._BOX)
			CanMove = false
		else:
			CanMove = true
func call_MaterialBox_load(_BoxInfo):

	var _Pos = Vector2.ZERO
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN(_BoxInfo.TSCN)
	var _Box = _BoxLoad.instance()

	_BOX = _Box

	BoxNode.add_child(_Box)
	_Box.call_load(_BoxInfo)
	_Box.call_InFreezerBox(true)
	_Box.call_Collision_Switch(false)

func call_fix():
	$WarningNode.return_Fix()
	if $WarningNode.NeedFix:
		if MachineANI.current_animation in ["切块", "切块2", "切块3"]:
			MachineANI.stop(false)
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)

func call_put(_ButID, _HoldObj, _Player):
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
			if not _BOX and not IsChoping:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return

				MaterialBox_PutIn(_HoldObj, _Player, BoxNode)
				But_Switch(true, _Player)
				return "放入"

func call_Fruit_puppet(_PLAYERPATH, _TYPE):
	MachineANI.playback_speed = 1
	var _Player = get_node(_PLAYERPATH)
	IsChoping = true
	ChopingFruit = _TYPE

	FruitANI.play(_TYPE)
	MachineANI.play("放入")
	_Player.Stat.call_carry_off()
	But_Switch(true, _Player)
	pass
func call_Fruit_In(_ButID, _Player, _HoldObj):
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
			if IsChoping:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_Making()
				return
			if _HoldObj.get("IsBroken"):
				return
			var _TYPE = _HoldObj.TypeStr
			if _TYPE in _FruitInList:
				if _BOX:
					var _BOXITEM = _BOX.get("ItemType")
					var _CHECK: bool = false
					if _BOXITEM == "":
						_CHECK = true
					else:
						match _TYPE:
							"牛油果":
								if _BOXITEM == "牛油果块":
									_CHECK = true
							"西柚":
								if _BOXITEM == "西柚块":
									_CHECK = true
							"芒果":
								if _BOXITEM == "芒果块":
									_CHECK = true
							"桃子":
								if _BOXITEM == "桃子块":
									_CHECK = true

					if _CHECK:

						var _NUM: int = 4
						match _TYPE:
							"芒果", "牛油果":
								_NUM = 2
							"桃子":
								_NUM = 3
							"西柚":
								_NUM = 4
						if GameLogic.cur_Rewards.has("切块机升级+"):
							_NUM += 1
						if _BOX.ItemArray.size() + _NUM <= _BOX.ItemMax:
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _PLAYERPATH = _Player.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_Fruit_puppet", [_PLAYERPATH, _TYPE])
							IsChoping = true
							ChopingFruit = _TYPE
							_HoldObj.call_del()
							FruitANI.play(_TYPE)
							MachineANI.playback_speed = 1
							MachineANI.play("放入")
							_Player.Stat.call_carry_off()
							But_Switch(true, _Player)
							return true
						else:
							if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
								_Player.call_Say_NoAdd()
							return
					else:
						if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
						return
				else:
					if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
						_Player.call_Say_NeedBox()
					return
func call_pick_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	GameLogic.Device.call_Player_Pick(_Player, _BOX)
	_BOX = null
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
			if IsChoping:
				if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
					_Player.call_Say_Making()
				return true
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if not is_instance_valid(_BOX):
				return
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYERPATH = _Player.get_path()
				SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_puppet", [_PLAYERPATH])
			GameLogic.Device.call_Player_Pick(_Player, _BOX)

			_BOX = null
			CanMove = true
			But_Switch(true, _Player)
			return "取出"
		3:
			call_MachineControl(3, _Player)
func call_MaterialBox_PutIn_puppet(_DEVPATH, _PLAYERPATH, _DEVNODEPATH):
	var _Player = get_node(_PLAYERPATH)
	var _Dev = get_node(_DEVPATH)
	var _DevNode = get_node(_DEVNODEPATH)

	_BOX = _Dev
	_Player.WeaponNode.remove_child(_Dev)
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	_Audio.play(0)
	_Dev.position = Vector2.ZERO
	_DevNode.add_child(_Dev)
	_Dev.call_InFreezerBox(true)
	_Dev.call_Collision_Switch(false)
	_Player.Con.IsHold = false
	_Player.Con.NeedPush = false
	_Player.Con.HoldInsId = 0
	_Player.Con.HoldObj = null

func MaterialBox_PutIn(_Dev, _Player, _DevNode):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _DEVPATH = _Dev.get_path()
		var _DEVNODEPATH = _DevNode.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_MaterialBox_PutIn_puppet", [_DEVPATH, _PLAYERPATH, _DEVNODEPATH])

	_BOX = _Dev
	CanMove = false
	_Player.WeaponNode.remove_child(_Dev)
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	_Audio.play(0)
	_Dev.position = Vector2.ZERO
	_DevNode.add_child(_Dev)
	_Dev.call_InFreezerBox(true)
	_Dev.call_Collision_Switch(false)
	_Player.Con.NeedPush = false
	_Player.Stat.call_carry_off()

func call_put_in_cup(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:

			if is_instance_valid(_BOX):
				_BOX.call_put_in_cup(_ButID, _Player, _HoldObj)
		- 1:

			if is_instance_valid(_BOX):
				_BOX.call_put_in_cup(_ButID, _Player, _HoldObj)
		0:

			if is_instance_valid(_BOX):

				var _return = _BOX.call_put_in_cup(0, _Player, _HoldObj)

				return _return
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
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
func call_Fix_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	GameLogic.Audio.But_SwitchOn.play(0)
	But_Switch(true, _Player)
	UseANI.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
func call_Fix_Logic(_Player):
	call_Fixing_Ani(_Player)
	if $WarningNode.return_Fixing(_Player):
		But_Switch(true, _Player)
		call_Machine_Logic()

func call_Fixing_Ani(_Player):
	UseANI.play("init")
	UseANI.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)
