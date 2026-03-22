extends Head_Object
var SelfDev = "BeerMachine"

var LayerA_Obj = null
var LayerB_Obj = null
var LayerX_Obj = null
var LayerY_Obj = null
onready var Layer_A = get_node("TexNode/Obj_A")
onready var Layer_B = $TexNode / GasNode
onready var Layer_X = get_node("TexNode/Obj_X")
onready var Layer_Y = get_node("TexNode/Obj_Y")

onready var Pop_X = $TexNode / UI / X / TextureProgress
onready var Pop_Y = $TexNode / UI / Y / TextureProgress

onready var Pop_X_Level = $TexNode / UI / X / PopLevel
onready var Pop_Y_Level = $TexNode / UI / Y / PopLevel

onready var UpgradeAni = $AniNode / Upgrade
onready var USEANI = $AniNode / Use

onready var _A = get_node("But/A")
onready var _B = get_node("But/B")
onready var _X = get_node("But/X")
onready var _Y = get_node("But/Y")
onready var MoveA = $But / A
var _TurnOn: bool
var IsBlackOut: bool
var UsedPowerCount: float = 0
var powerMult: float = 0.5
var PopList: Array = [25, 55, 100]

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	get_node("But").show()
	if $WarningNode.NeedFix:
		_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_2)
		_Y.show()

	.But_Switch(_bool, _Player)
func _DayClosedCheck():


	pass
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
		var _CON = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.GameUI.is_connected("TimeChange", self, "_GasLogic"):
		var _check = GameLogic.GameUI.connect("TimeChange", self, "_GasLogic")

	MoveA.show()
	get_node("But").show()

func _GasLogic():
	if is_instance_valid(LayerB_Obj):
		LayerB_Obj.call_Used()
func Update_Check():
	var _Mult: float = 1
	if GameLogic.cur_Rewards.has("软饮机升级"):

		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	elif GameLogic.cur_Rewards.has("软饮机升级+"):

		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_turn_logic()

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)

	self.position = _Info.pos

	for _OBJ in Layer_A.get_children():
		Layer_A.remove_child(_OBJ)
		_OBJ.queue_free()
	for _OBJ in Layer_B.get_children():
		Layer_B.remove_child(_OBJ)
		_OBJ.queue_free()
	for _OBJ in Layer_X.get_children():
		Layer_X.remove_child(_OBJ)
		_OBJ.queue_free()
	for _OBJ in Layer_Y.get_children():
		Layer_Y.remove_child(_OBJ)
		_OBJ.queue_free()
	if _Info.has("LayerA_Obj"):
		if _Info.LayerA_Obj != null:
			var _ObjInfo = _Info.LayerA_Obj
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
			var _Obj = _TSCN.instance()
			_Obj.name = _ObjInfo.NAME

			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			_Obj.call_load(_ObjInfo)
	if _Info.LayerB_Obj != null:
		var _ObjInfo = _Info.LayerB_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME

		Layer_B.add_child(_Obj)
		LayerB_Obj = _Obj
		_Obj.call_load(_ObjInfo)
	if _Info.LayerX_Obj != null:
		var _ObjInfo = _Info.LayerX_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME

		Layer_X.add_child(_Obj)
		LayerX_Obj = _Obj
		_Obj.call_load(_ObjInfo)
	if _Info.LayerY_Obj != null:
		var _ObjInfo = _Info.LayerY_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME
		Layer_Y.add_child(_Obj)
		LayerY_Obj = _Obj
		_Obj.call_load(_ObjInfo)

	Update_Check()

func call_Pop_puppet(_XNUM, _YNUM):
	Pop_X.value = _XNUM
	Pop_Y.value = _YNUM
	call_PopShow_Logic()
func call_PopLogic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if is_instance_valid(LayerX_Obj):

		Pop_X.value = LayerX_Obj.GasNum
		if Pop_X.value > 0:
			LayerX_Obj.call_fan_switch(true)
	else:
		Pop_X.value = 0
	if is_instance_valid(LayerY_Obj):
		Pop_Y.value = LayerY_Obj.GasNum
		if Pop_Y.value > 0:
			LayerY_Obj.call_fan_switch(true)
	else:
		Pop_Y.value = 0
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Pop_puppet", [Pop_X.value, Pop_Y.value])
	call_PopShow_Logic()
func call_PopShow_Logic():
	if Pop_X.value == 0:
		Pop_X_Level.play("0")
	elif Pop_X.value <= 25:
		Pop_X_Level.play("1")
	elif Pop_X.value <= 55:
		Pop_X_Level.play("2")
	elif Pop_X.value <= 100:
		Pop_X_Level.play("3")
	if Pop_Y.value == 0:
		Pop_Y_Level.play("0")
	elif Pop_Y.value < 25:
		Pop_Y_Level.play("1")
	elif Pop_Y.value < 55:
		Pop_Y_Level.play("2")
	elif Pop_Y.value < 100:
		Pop_Y_Level.play("3")
func call_DrinkCup_puppet():

	pass
func call_DrinkCup_Logic(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			if LayerA_Obj != null:
				if is_instance_valid(LayerB_Obj):
					if LayerB_Obj.GasNum <= 0:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NeedGas()
						return true
				else:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NeedGas()
					return true
				LayerA_Obj.call_WaterInDrinkCup(0, _Dev, _Player, 1)
				return true
		2:

			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerX_Obj != null:
				if is_instance_valid(LayerB_Obj):
					if LayerB_Obj.GasNum <= 0:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NeedGas()
						return true
				else:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NeedGas()
					return true
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _R = LayerX_Obj.call_WaterInDrinkCup(0, _Dev, _Player, 2)

				return true
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)
			if LayerY_Obj != null:
				if is_instance_valid(LayerB_Obj):
					if LayerB_Obj.GasNum <= 0:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NeedGas()
						return true
				else:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NeedGas()
					return true
				LayerY_Obj.call_WaterInDrinkCup(0, _Dev, _Player, 3)
				return true

func call_Ani(_TYPE):

	if has_node("AniNode/Act"):
		match _TYPE:
			"L":

				$AniNode / Act.play("OpenLeft")

			"R":

				$AniNode / Act.play("OpenRight")
func return_canput_check(_Obj):
	if not is_instance_valid(_Obj):
		return true
	if _Obj.IsItem:
		return true
	else:
		match _Obj.FuncType:
			"Beer":
				return true
			_:
				return false

func call_player_leave(_PLAYER):
	if is_instance_valid(LayerA_Obj):
		if LayerA_Obj._PlayerOBJ == _PLAYER:
			LayerA_Obj.call_Switch(false)
	if is_instance_valid(LayerX_Obj):
		if LayerX_Obj._PlayerOBJ == _PLAYER:
			LayerX_Obj.call_Switch(false)
	if is_instance_valid(LayerY_Obj):
		if LayerY_Obj._PlayerOBJ == _PLAYER:
			LayerY_Obj.call_Switch(false)
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
			var A_bool: bool

			var X_bool: bool
			var Y_bool: bool
			if LayerA_Obj == null:
				A_bool = true
			elif LayerA_Obj.FuncType == "Bottle":
				if LayerA_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
					A_bool = true
			if LayerX_Obj == null:
				X_bool = true
			elif LayerX_Obj.FuncType == "Bottle":
				if LayerX_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
					X_bool = true

			if LayerY_Obj == null:
				Y_bool = true
			elif LayerY_Obj.FuncType == "Bottle":
				if LayerY_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
					Y_bool = true




			if A_bool:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)

			if X_bool:
				_X.call_player_in(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)
			if Y_bool:
				_Y.call_player_in(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)

		2:
			if LayerX_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)
				if not _Check:
					return
				return _PutOn("X", _Player)
			elif LayerX_Obj.FuncType == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)
		3:
			if LayerY_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)
				if not _Check:
					return
				return _PutOn("Y", _Player)
			elif LayerY_Obj.FuncType == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)
func call_PutOn(_butID, _Player):
	print(" BeerMachine butID:", _butID, " LayerX_Obj:", LayerX_Obj)

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
			var A_bool: bool = false
			var B_bool: bool = false
			var X_bool: bool
			var Y_bool: bool

			if LayerB_Obj == null:
				if _Dev.get("SelfDev") == "GasBottle":
					B_bool = true
			if LayerA_Obj == null:
				var _FUNCTYPE = _Dev.get("FuncType")
				if _FUNCTYPE == "Beer":
					if _Dev.get("FuncTypePara") in ["小麦", "IPA", "世涛"]:
						A_bool = true
			if LayerX_Obj == null:
				var _FUNCTYPE = _Dev.get("FuncType")
				if _FUNCTYPE == "Beer":
					if _Dev.get("FuncTypePara") in ["小麦", "IPA", "世涛"]:
						X_bool = true
			if LayerY_Obj == null:
				var _FUNCTYPE = _Dev.get("FuncType")
				if _FUNCTYPE == "Beer":
					if _Dev.get("FuncTypePara") in ["小麦", "IPA", "世涛"]:
						Y_bool = true


			if LayerA_Obj == null:
				_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_Str)
			else:
				_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_1)
			if LayerY_Obj == null:
				_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_Str)
			else:
				_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_1)
			if LayerX_Obj == null:
				_X.InfoLabel.text = GameLogic.CardTrans.get_message(_X.Info_Str)
			else:
				_X.InfoLabel.text = GameLogic.CardTrans.get_message(_X.Info_1)
			if A_bool:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if B_bool:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)
			if X_bool:
				_X.call_player_in(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)
			if Y_bool:
				_Y.call_player_in(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)
			_Dev.But_Switch(false, _Player)
		1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerB_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)

				if _Obj.FuncType in ["GasBottle"]:
					return _PutOn("B", _Player)

		0:
			if LayerA_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				if _Obj.get("FuncType") in ["Beer"]:
					if _Obj.get("FuncTypePara") in ["小麦", "IPA", "世涛"]:
						var _Check = return_canput_check(_Obj)
						if not _Check:
							return
						return _PutOn("A", _Player)
		2:
			if LayerX_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				if _Obj.get("FuncType") in ["Beer"]:
					if _Obj.get("FuncTypePara") in ["小麦", "IPA", "世涛"]:
						var _Check = return_canput_check(_Obj)
						if not _Check:
							return
						return _PutOn("X", _Player)
		3:

			if LayerY_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				if _Obj.get("FuncType") in ["Beer"]:
					if _Obj.get("FuncTypePara") in ["小麦", "IPA", "世涛"]:
						var _Check = return_canput_check(_Obj)
						if not _Check:
							return
						return _PutOn("Y", _Player)

func call_charge_ani(_TYPE: int):
	match _TYPE:
		0:
			USEANI.play("Charge")
		1:
			USEANI.play("init")

func call_PutOn_puppet(_PLAYERPATH, _OBJID, _Layer):
	if not SteamLogic.OBJECT_DIC.has(_OBJID):
		printerr(" BeerM OBJECT_DIC 无：", _OBJID)
		return
	var _Player = get_node(_PLAYERPATH)
	var _Obj = SteamLogic.OBJECT_DIC[_OBJID]
	if _Obj.has_node("But/A"):
		_Obj.get_node("But/A").call_clean()
	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()
	if _Obj.has_method("call_InMachine"):
		_Obj.call_InMachine(true)
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)
	match _Layer:

		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj

			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"A":
			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"X":
			Layer_X.add_child(_Obj)
			LayerX_Obj = _Obj
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"Y":
			Layer_Y.add_child(_Obj)
			LayerY_Obj = _Obj
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)

	call_pick( - 1, _Player)
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
		var _OBJID = _Obj._SELFID
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOn_puppet", [_PLAYERPATH, _OBJID, _Layer])
	if _Obj.has_node("But/A"):
		_Obj.get_node("But/A").call_clean()
	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()
	if _Obj.has_method("call_InMachine"):
		_Obj.call_InMachine(true)
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)

	match _Layer:
		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj

			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"A":
			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"X":
			Layer_X.add_child(_Obj)
			LayerX_Obj = _Obj
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)

		"Y":
			Layer_Y.add_child(_Obj)
			LayerY_Obj = _Obj
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
	call_pick( - 1, _Player)

	return "台架放入"

func call_pick(_butID, _Player):

	match _butID:
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _Player.IsStaff:
				return
			var A_bool: bool
			var B_bool: bool
			var X_bool: bool
			var Y_bool: bool
			if LayerA_Obj != null:
				A_bool = true
			if LayerB_Obj != null:
				B_bool = true
			if LayerX_Obj != null:
				X_bool = true
			if LayerY_Obj != null:
				Y_bool = true

			if $WarningNode.NeedFix:
				_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_2)
			elif LayerY_Obj == null:
				_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_Str)
			else:
				_Y.InfoLabel.text = GameLogic.CardTrans.get_message(_Y.Info_1)
			if LayerX_Obj == null:
				_X.InfoLabel.text = GameLogic.CardTrans.get_message(_X.Info_Str)
			else:
				_X.InfoLabel.text = GameLogic.CardTrans.get_message(_X.Info_1)
			if LayerA_Obj == null:
				_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_Str)
			else:
				_A.InfoLabel.text = GameLogic.CardTrans.get_message(_A.Info_1)
			if A_bool:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if B_bool:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)
			if X_bool:
				_X.call_player_in(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)
			if Y_bool or $WarningNode.NeedFix:
				_Y.call_player_in(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerA_Obj != null:
				_pick("A", _Player)
				call_PutOn( - 1, _Player)
		1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerB_Obj != null:
				_pick("B", _Player)
				call_PutOn( - 1, _Player)
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

				return

			if LayerX_Obj != null:
				_pick("X", _Player)
				call_PutOn( - 1, _Player)

		3:
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)
				return
			if LayerY_Obj != null:
				_pick("Y", _Player)
				call_PutOn( - 1, _Player)

	return "台架取出"
func call_pick_puppet(_PLAYERPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj
	match _Layer:
		"A":
			_Obj = LayerA_Obj

			LayerA_Obj = null

		"B":
			_Obj = LayerB_Obj

			LayerB_Obj = null


		"X":
			_Obj = LayerX_Obj

			LayerX_Obj = null

		"Y":
			_Obj = LayerY_Obj

			LayerY_Obj = null

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)

	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(true, _Player)
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)

func _pick(_Layer, _Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_puppet", [_PLAYERPATH, _Layer])
	var _Obj
	match _Layer:
		"A":
			_Obj = LayerA_Obj

			LayerA_Obj = null

		"B":
			_Obj = LayerB_Obj

			LayerB_Obj = null


		"X":
			_Obj = LayerX_Obj

			LayerX_Obj = null

		"Y":
			_Obj = LayerY_Obj

			LayerY_Obj = null

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _Obj)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(true, _Player)
	if _Obj.has_method("call_InMachine"):
		_Obj.call_InMachine(false)
	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)
func return_InCup_Logic(_ButID, _Player, _DrinkCup, _POPCAP):
	if GameLogic.Device.return_CanUse_bool(_Player):
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if IsBlackOut:
		return
	if $WarningNode.NeedFix:
		return
	if _DrinkCup.FuncType in ["SodaCan"]:
		if _DrinkCup.IsPack:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_PickFinished()
			return
	if _DrinkCup.Liquid_Count >= _DrinkCup.Liquid_Max:
		return
	if _POPCAP != null:
		var _return = _DrinkCup.call_Shelf_Logic(_ButID, _Player, _POPCAP)
		if _return:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Ani_puppet", ["Use"])
			USEANI.play("Use")
			GameLogic.Total_Electricity += 0.5
			$WarningNode.return_Fix()
		call_PopLogic()
		return _return
func call_Ani_puppet(_NAME):
	if USEANI.has_animation(_NAME):
		USEANI.play(_NAME)
func call_In_Cup(_ButID, _DrinkCup, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			But_Switch(true, _Player)
		2:
			return return_InCup_Logic(_ButID, _Player, _DrinkCup, LayerX_Obj)
		3:
			return return_InCup_Logic(_ButID, _Player, _DrinkCup, LayerY_Obj)
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

func call_Fix_Logic(_Player):
	if $WarningNode.return_Fixing(_Player):
		call_Fixing_Ani(_Player)
		But_Switch(true, _Player)
	else:
		call_Fixing_Ani(_Player)

func call_Fixing_Ani(_Player):
	USEANI.play("init")
	USEANI.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func call_turn_logic():

	pass
