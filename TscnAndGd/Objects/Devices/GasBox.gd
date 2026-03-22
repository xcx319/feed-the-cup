extends Head_Object
var SelfDev = "GasBox"

var LayerA_Obj = null
var LayerB_Obj = null
var LayerX_Obj = null
var LayerY_Obj = null
onready var Layer_A = $TexNode / ItemNode / Obj_A
onready var Layer_B = $TexNode / ItemNode / Obj_B
onready var Layer_X = $TexNode / ItemNode / Obj_X
onready var Layer_Y = $TexNode / ItemNode / Obj_Y

onready var _A = get_node("But/A")
onready var _B = get_node("But/B")
onready var _X = get_node("But/X")
onready var _Y = get_node("But/Y")
onready var MoveA = get_node("A")
var _TurnOn: bool
var IsBlackOut: bool
func But_Switch(_bool, _Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	_CanMove_Check()

	get_node("But").show()
	if not _bool:
		get_node("But").hide()
	if CanMove:
		if not _Player.Con.IsHold:



			if _bool:
				MoveA.call_player_in(_Player.cur_Player)

				get_node("But").hide()
			else:
				MoveA.call_player_out(_Player.cur_Player)

		else:
			MoveA.call_player_out(_Player.cur_Player)

	else:
		MoveA.call_player_out(_Player.cur_Player)

	.But_Switch(_bool, _Player)
func _ready() -> void :

	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("OpenStore", self, "_CanMove_Check"):
		var _con = GameLogic.connect("OpenStore", self, "_CanMove_Check")

	if CanLayout:
		CanMove = true
	MoveA.InfoLabel.text = GameLogic.CardTrans.get_message(MoveA.Info_Str)
	MoveA.show()
	get_node("But").show()
	_CanMove_Check()
	GameLogic.NPC.GASBOX = self

func _CanMove_Check():
	if get_parent().name != "ObjNode":
		if LayerA_Obj == null and LayerB_Obj == null and LayerX_Obj == null and LayerY_Obj == null:
			CanMove = true
		return
	if CanLayout:
		if LayerA_Obj == null and LayerB_Obj == null and LayerX_Obj == null and LayerY_Obj == null:
			CanMove = true

		else:
			CanMove = false

	else:
		CanMove = false

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if get_parent().name == "ObjNode":
		get_node("CollisionShape2D").disabled = true
	self.position = _Info.pos

	var _AList = Layer_A.get_children()
	for _NODE in _AList:
		Layer_A.remove_child(_NODE)
	var _BList = Layer_B.get_children()
	for _NODE in _BList:
		Layer_B.remove_child(_NODE)
	var _XList = Layer_X.get_children()
	for _NODE in _XList:
		Layer_X.remove_child(_NODE)
	var _YList = Layer_Y.get_children()
	for _NODE in _YList:
		Layer_Y.remove_child(_NODE)
	if _Info.LayerA_Obj != null:
		var _ObjInfo = _Info.LayerA_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME

		Layer_A.add_child(_Obj)
		LayerA_Obj = _Obj
		_Obj.call_load(_ObjInfo)
		if _Obj.has_method("call_Info_Switch"):
			_Obj.call_Info_Switch(false)
	if _Info.LayerB_Obj != null:
		var _ObjInfo = _Info.LayerB_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME

		Layer_B.add_child(_Obj)
		LayerB_Obj = _Obj
		_Obj.call_load(_ObjInfo)
		if _Obj.has_method("call_Info_Switch"):
			_Obj.call_Info_Switch(false)
	if _Info.LayerX_Obj != null:
		var _ObjInfo = _Info.LayerX_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME

		Layer_X.add_child(_Obj)
		LayerX_Obj = _Obj
		_Obj.call_load(_ObjInfo)
		if editor_description == "FreezerOnTable":
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
	if _Info.LayerY_Obj != null:
		var _ObjInfo = _Info.LayerY_Obj
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ObjInfo.TSCN)
		var _Obj = _TSCN.instance()
		_Obj.name = _ObjInfo.NAME
		Layer_Y.add_child(_Obj)
		LayerY_Obj = _Obj
		_Obj.call_load(_ObjInfo)
		if editor_description == "FreezerOnTable":
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
	_CanMove_Check()

func call_DrinkCup_puppet():

	pass
func call_DrinkCup_Logic(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:

			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			var A_bool: bool
			var B_bool: bool
			var X_bool: bool
			var Y_bool: bool
			if LayerA_Obj:
				if LayerA_Obj.FuncType in ["Top"] and _Dev.Top == "":
					A_bool = true
				if LayerA_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					A_bool = true
				if LayerA_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerA_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						A_bool = true
				if LayerA_Obj.FuncType in ["Can"]:

					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								A_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								A_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								A_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								A_bool = true
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
			if LayerX_Obj:
				if LayerX_Obj.FuncType in ["Top"] and _Dev.Top == "":
					X_bool = true
				if LayerX_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					X_bool = true
				if LayerX_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerX_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						X_bool = true

				if LayerX_Obj.FuncType in ["Can"]:


					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								X_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								X_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								X_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								X_bool = true
			if LayerY_Obj:
				if LayerY_Obj.FuncType in ["Top"] and _Dev.Top == "":
					Y_bool = true
				if LayerY_Obj.FuncType in ["Hang"] and _Dev.Hang == "":
					Y_bool = true
				if LayerY_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid"]:
					if LayerY_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
						Y_bool = true
				if LayerY_Obj.FuncType in ["Can"]:

					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 == "":
								Y_bool = true
						"DrinkCup_M":
							if _Dev.Extra_2 == "":
								Y_bool = true
						"DrinkCup_L":
							if _Dev.Extra_3 == "":
								Y_bool = true
						"SuperCup_M":
							if _Dev.Extra_5 == "":
								Y_bool = true


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
			if A_bool or B_bool or X_bool or Y_bool:
				get_node("But").show()

		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerA_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerA_Obj)
				call_Ani("L")

				if LayerA_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerA_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				if LayerA_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)
				return _return
		1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerB_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerB_Obj)

				call_Ani("R")
				if LayerB_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerB_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				if LayerB_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)
				return _return
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerX_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerX_Obj)
				call_Ani("L")

				if LayerX_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerX_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				if LayerX_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)

				return _return
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var _Dev = instance_from_id(_Player.Con.HoldInsId)

			if LayerY_Obj != null:
				var _return = _Dev.call_Shelf_Logic(_ButID, _Player, LayerY_Obj)
				call_Ani("R")

				if LayerY_Obj.FuncType in ["Bottle", "ShakeCup", "Con_Liquid", "Con_TeaPort"]:
					if _Dev.Liquid_Count >= _Dev.Liquid_Max or LayerY_Obj.Liquid_Count <= 0:
						But_Switch(false, _Player)
				elif LayerY_Obj.FuncType in ["Can"]:
					match _Dev.TYPE:
						"DrinkCup_S":
							if _Dev.Extra_1 != "":
								But_Switch(false, _Player)
						"DrinkCup_M":
							if _Dev.Extra_2 != "":
								But_Switch(false, _Player)
						"DrinkCup_L":
							if _Dev.Extra_3 != "":
								But_Switch(false, _Player)
						"SuperCup_M":
							if _Dev.Extra_5 != "":
								But_Switch(false, _Player)
				return _return
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
			"Con_Liquid":
				return true
			"Con_TeaPort":
				return true
			"ShakeCup":
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
			var A_bool: bool
			var B_bool: bool
			var X_bool: bool
			var Y_bool: bool
			if LayerA_Obj == null:
				A_bool = true
			elif LayerA_Obj.FuncType == "Bottle":
				if LayerA_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
					A_bool = true

			if LayerB_Obj == null:
				B_bool = true
			elif LayerB_Obj.FuncType == "Bottle":
				if LayerB_Obj.Liquid_Count > 0 and _Dev.Liquid_Count < _Dev.Liquid_Max:
					B_bool = true

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
		0:
			if LayerA_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)

				if not _Check:
					return
				return _PutOn("A", _Player)
			elif LayerA_Obj.FuncType == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)

		1:
			if LayerB_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)
				if not _Check:
					return
				return _PutOn("B", _Player)
			elif LayerB_Obj.FuncType == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)
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

	if get_parent().name != "ObjNode":
		return
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
			var B_bool: bool
			var X_bool: bool
			var Y_bool: bool
			if LayerA_Obj == null:
				A_bool = true
			if LayerB_Obj == null:
				B_bool = true
			if LayerX_Obj == null:
				X_bool = true
			if LayerY_Obj == null:
				Y_bool = true


			$But.show()
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
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerA_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)

				if not _Check:
					return
				return _PutOn("A", _Player)
			elif LayerA_Obj.TypeStr == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)

		1:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerB_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)
				if not _Check:
					return
				return _PutOn("B", _Player)
			elif LayerB_Obj.TypeStr == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerX_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)
				if not _Check:
					return
				return _PutOn("X", _Player)
			elif LayerX_Obj.TypeStr == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerY_Obj == null:
				var _Obj = instance_from_id(_Player.Con.HoldInsId)
				var _Check = return_canput_check(_Obj)
				if not _Check:
					return
				return _PutOn("Y", _Player)
			elif LayerY_Obj.TypeStr == "Bottle":
				return call_DrinkCup_Logic(_butID, _Player)
func call_PutOn_puppet(_PLAYERPATH, _OBJPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj = get_node(_OBJPATH)
	if not is_instance_valid(_Obj):
		return
	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)
	match _Layer:
		"A":
			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			call_Ani("L")

			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"X":
			Layer_X.add_child(_Obj)
			LayerX_Obj = _Obj
			call_Ani("L")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"Y":
			Layer_Y.add_child(_Obj)
			LayerY_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)

	if editor_description == "FreezerOnTable":

		if _Obj.has_method("call_Info_Switch"):
			_Obj.call_Info_Switch(false)
	else:
		if _Layer in ["A", "B"]:
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
	_CanMove_Check()
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
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutOn_puppet", [_PLAYERPATH, _OBJPATH, _Layer])

	_Player.WeaponNode.remove_child(_Obj)

	_Player.Stat.call_carry_off()

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(false)

	match _Layer:
		"A":
			Layer_A.add_child(_Obj)
			LayerA_Obj = _Obj
			call_Ani("L")

			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"B":
			Layer_B.add_child(_Obj)
			LayerB_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"X":
			Layer_X.add_child(_Obj)
			LayerX_Obj = _Obj
			call_Ani("L")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
		"Y":
			Layer_Y.add_child(_Obj)
			LayerY_Obj = _Obj
			call_Ani("R")
			var _AUDIO = GameLogic.Audio.return_Effect("放下")
			_AUDIO.play(0)
	if editor_description == "FreezerOnTable":
		if _Obj.has_method("call_Freezer_Switch"):
			_Obj.call_Freezer_Switch(true)
		if _Obj.has_method("call_Freezer_ColdTimer"):
			_Obj.call_Freezer_ColdTimer()
		if _Obj.has_method("call_Info_Switch"):
			_Obj.call_Info_Switch(false)
	else:
		if _Layer in ["A", "B"]:
			if _Obj.has_method("call_Info_Switch"):
				_Obj.call_Info_Switch(false)
	_CanMove_Check()
	call_pick( - 1, _Player)
	if _Obj.has_method("But_Switch"):
		_Obj.But_Switch(false, _Player)
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

			$But.show()
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
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if LayerY_Obj != null:
				_pick("Y", _Player)
				call_PutOn( - 1, _Player)
	_CanMove_Check()
	return "台架取出"
func call_pick_puppet(_PLAYERPATH, _Layer):
	var _Player = get_node(_PLAYERPATH)
	var _Obj
	match _Layer:
		"A":
			_Obj = LayerA_Obj
			if not is_instance_valid(_Obj):
				return

			LayerA_Obj = null
			call_Ani("L")
		"B":
			_Obj = LayerB_Obj
			if not is_instance_valid(_Obj):
				return

			LayerB_Obj = null
			call_Ani("R")
		"X":
			_Obj = LayerX_Obj
			if not is_instance_valid(_Obj):
				return

			LayerX_Obj = null
			call_Ani("L")
		"Y":
			_Obj = LayerY_Obj
			if not is_instance_valid(_Obj):
				return

			LayerY_Obj = null
			call_Ani("R")

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _Obj)

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)
	call_PutOn( - 1, _Player)
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
			call_Ani("L")
		"B":
			_Obj = LayerB_Obj

			LayerB_Obj = null
			call_Ani("R")
		"X":
			_Obj = LayerX_Obj

			LayerX_Obj = null
			call_Ani("L")
		"Y":
			_Obj = LayerY_Obj

			LayerY_Obj = null
			call_Ani("R")

	if _Obj.has_method("call_Freezer_Switch"):
		_Obj.call_Freezer_Switch(false)
	GameLogic.Device.call_Player_Pick(_Player, _Obj)

	if _Obj.has_method("call_CupInfo_Switch"):
		if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			_Obj.call_CupInfo_Switch(true)

func call_GAS_FULL():
	if is_instance_valid(LayerA_Obj):
		if LayerA_Obj.has_method("call_full"):
			LayerA_Obj.call_full()
	if is_instance_valid(LayerB_Obj):
		if LayerB_Obj.has_method("call_full"):
			LayerB_Obj.call_full()
	if is_instance_valid(LayerX_Obj):
		if LayerX_Obj.has_method("call_full"):
			LayerX_Obj.call_full()
	if is_instance_valid(LayerY_Obj):
		if LayerY_Obj.has_method("call_full"):
			LayerY_Obj.call_full()

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
