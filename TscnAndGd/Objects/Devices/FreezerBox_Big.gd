extends Head_Object
var SelfDev = "FreezerBig"

onready var BoxNode = get_node("TexNode/BoxNode")
onready var ActAni = get_node("AniNode/Act")
onready var UseAni = get_node("AniNode/UseAni")
onready var A_Node = BoxNode.get_node("A")
onready var B_Node = BoxNode.get_node("B")
onready var X_Node = BoxNode.get_node("X")
onready var Y_Node = BoxNode.get_node("Y")

onready var A_Box
onready var B_Box
onready var X_Box
onready var Y_Box
onready var _A = get_node("But/A")
onready var _B = get_node("But/B")
onready var _X = get_node("But/X")
onready var _Y = get_node("But/Y")
var _TurnOn: bool
export var powerMult: int = 50

var CanPutInList = ["柠檬片", "西米"]
var _EXTRA_LIST: Array = [
	"西米", "红豆", "椰果", "仙草冻", "燕麦", "花生", "脆波波",
	"果冻", "葡萄干", "原味珍珠", "黑糖珍珠", "鲜芋",
	"栗子", "奇亚籽", "芝士片", "酒酿"]
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :
	call_init(SelfDev)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
			var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():
	pass
func call_Box_Switch(_But, _Switch: bool, _HoldObj, _Player):
	var _Box
	var _ButID
	match _But:

		0:
			_Box = A_Box
			_ButID = _A
		1:
			_Box = B_Box
			_ButID = _B
		2:
			_Box = X_Box
			_ButID = _X
		3:
			_Box = Y_Box
			_ButID = _Y
	match _Switch:
		true:
			match _HoldObj.FuncType:
				"WorkBoard":
					if not _Box.ItemArray.size():
						_ButID.call_player_in(_Player.cur_Player)
					elif _Box.ItemType == _HoldObj.ItemType and _Box.ItemArray.size() < 10 and _Box.ItemArray.size() > 0 and _HoldObj.SaveNodeList.size() > 0:

						_ButID.call_player_in(_Player.cur_Player)
				"Can", "WorkBoard":

					if not _Box.ItemArray.size():
						_ButID.call_player_in(_Player.cur_Player)
					elif _Box.ItemType == str(_HoldObj.FuncTypePara) and _Box.ItemArray.size() <= 20 and _Box.ItemArray.size() > 0 and _HoldObj.Num > 0:

						_ButID.call_player_in(_Player.cur_Player)


				"SuperCup":
					if _Box.ItemType in _EXTRA_LIST:
						var _FUNCTYPE = _HoldObj.FuncType
						match _HoldObj.TYPE:

							"SuperCup_M":
								if _HoldObj.Extra_1 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_2 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_3 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_4 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_5 == "":
									_ButID.call_player_in(_Player.cur_Player)

					elif _Box.ItemType in ["柠檬片"]:
						if not _HoldObj.Condiment_1:
							_ButID.call_player_in(_Player.cur_Player)
				"DrinkCup":
					if _Box.ItemType in _EXTRA_LIST:
						var _FUNCTYPE = _HoldObj.FuncType
						match _HoldObj.TYPE:
							"DrinkCup_S":
								if _HoldObj.Extra_1 == "":
									_ButID.call_player_in(_Player.cur_Player)
							"DrinkCup_M":
								if _HoldObj.Extra_1 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_2 == "":
									_ButID.call_player_in(_Player.cur_Player)
							"DrinkCup_L":
								if _HoldObj.Extra_1 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_2 == "":
									_ButID.call_player_in(_Player.cur_Player)
								elif _HoldObj.Extra_3 == "":
									_ButID.call_player_in(_Player.cur_Player)
					elif _Box.ItemType in ["柠檬片"]:
						if not _HoldObj.Condiment_1:
							_ButID.call_player_in(_Player.cur_Player)

		false:

			_ButID.call_player_out(_Player.cur_Player)

func call_put_in_cup(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:

			call_Box_Switch(0, false, _HoldObj, _Player)

			call_Box_Switch(1, false, _HoldObj, _Player)

			call_Box_Switch(2, false, _HoldObj, _Player)

			call_Box_Switch(3, false, _HoldObj, _Player)
		- 1:
			if A_Box:

				call_Box_Switch(0, true, _HoldObj, _Player)
			if B_Box:
				call_Box_Switch(1, true, _HoldObj, _Player)
			if X_Box:
				call_Box_Switch(2, true, _HoldObj, _Player)
			if Y_Box:
				call_Box_Switch(3, true, _HoldObj, _Player)
		0:

			if A_Box:
				var _FUNC = _HoldObj.FuncType
				match _HoldObj.FuncType:
					"WorkBoard":
						var _return = A_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
							call_put_in_cup( - 2, _Player, _HoldObj)
						call_turn_check()
						return _return
					"Can":
						var _return = A_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
						call_turn_check()
						return _return
					"DrinkCup":
						if A_Box.ItemType:
							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							var _return = A_Box.call_put_in_cup(0, _Player, _HoldObj)
							if _return:
								UseAni.play("Use")
							call_turn_check()
							return _return
		1:

			if B_Box:
				match _HoldObj.FuncType:
					"WorkBoard":
						var _return = B_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
							call_put_in_cup( - 2, _Player, _HoldObj)
						call_turn_check()
						return _return
					"Can":
						var _return = B_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
						call_turn_check()
						return _return
					"DrinkCup":
						if B_Box.ItemType:
							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							var _return = B_Box.call_put_in_cup(0, _Player, _HoldObj)
							if _return:
								UseAni.play("Use")
							call_turn_check()
							return _return
		2:

			if X_Box:
				match _HoldObj.FuncType:
					"WorkBoard":
						var _return = X_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
							call_put_in_cup( - 2, _Player, _HoldObj)
						call_turn_check()
						return _return
					"Can":
						var _return = X_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
						call_turn_check()
						return _return
					"DrinkCup":
						if X_Box.ItemType:
							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							var _return = X_Box.call_put_in_cup(0, _Player, _HoldObj)
							if _return:
								UseAni.play("Use")
							call_turn_check()
							return _return
		3:

			if Y_Box:
				match _HoldObj.FuncType:
					"WorkBoard":
						var _return = Y_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
							call_put_in_cup( - 2, _Player, _HoldObj)
						call_turn_check()
						return _return
					"Can":
						var _return = Y_Box.call_put_in_cup(0, _Player, _HoldObj)
						if _return == "装小料盒":
							UseAni.play("Use")
						call_turn_check()
						return _return
					"DrinkCup":
						if Y_Box.ItemType:
							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							var _return = Y_Box.call_put_in_cup(0, _Player, _HoldObj)
							if _return:
								UseAni.play("Use")
							call_turn_check()
							return _return

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if GameLogic.cur_Day < 1 or GameLogic.SPECIALLEVEL_Int:
		_new_Box()

	if _Info.A_Box != null:
		call_MaterialBox_load("A", _Info.A_Box)
	if _Info.B_Box != null:
		call_MaterialBox_load("B", _Info.B_Box)
	if _Info.X_Box != null:

		call_MaterialBox_load("X", _Info.X_Box)
	if _Info.Y_Box != null:

		call_MaterialBox_load("Y", _Info.Y_Box)
	call_turn_check()


func call_MaterialBox_load(_BoxType, _BoxInfo):

	var _Pos = Vector2.ZERO
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN(_BoxInfo.TSCN)
	var _Box = _BoxLoad.instance()
	var _BoxTypeNode
	match _BoxType:
		"A":
			_BoxTypeNode = A_Node
			A_Box = _Box
		"B":
			_BoxTypeNode = B_Node
			B_Box = _Box
		"X":
			_BoxTypeNode = X_Node
			X_Box = _Box
		"Y":
			_BoxTypeNode = Y_Node
			Y_Box = _Box
	_BoxTypeNode.add_child(_Box)
	_Box.call_load(_BoxInfo)
	_Box.call_InFreezerBox(true)
	_Box.call_Collision_Switch(false)

func call_turn_check():
	if A_Box:

		if A_Box.get("ItemType") != "":
			call_Turn(true)
			return
	if B_Box:

		if B_Box.get("ItemType") != "":
			call_Turn(true)
			return
	if X_Box:

		if X_Box.get("ItemType") != "":
			call_Turn(true)
			return
	if Y_Box:

		if Y_Box.get("ItemType") != "":
			call_Turn(true)
			return
	call_Turn(false)
func call_Turn(_Switch: bool):

	match _Switch:
		true:
			if not _TurnOn:
				_TurnOn = _Switch
				ActAni.play("On")

		false:
			if _TurnOn:
				_TurnOn = _Switch
				ActAni.play("Off")

func call_new_puppet(_A_NAME, _B_NAME, _X_NAME, _Y_NAME):
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN("MaterialBox")
	var _BoxTypeNode
	for i in 4:
		var _Box = _BoxLoad.instance()
		var _NAME: String
		match i:
			0:
				_NAME = _A_NAME
			1:
				_NAME = _B_NAME
			2:
				_NAME = _X_NAME
			3:
				_NAME = _Y_NAME
		var _Info = {
			"TSCN": "MaterialBox",
			"NAME": _NAME,
			"pos": Vector2.ZERO,
			"Type": null,
			"Number": 0,
			"IsPassDay": false,
			"IsBroken": false,
			"IsFreezer": false,
			"ItemFreshType": 0,
		}
		match i:
			0:
				_BoxTypeNode = A_Node
				A_Box = _Box
			1:
				_BoxTypeNode = B_Node
				B_Box = _Box
			2:
				_BoxTypeNode = X_Node
				X_Box = _Box
			3:
				_BoxTypeNode = Y_Node
				Y_Box = _Box
		_BoxTypeNode.add_child(_Box)
		_Box.call_load(_Info)
func _new_Box():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN("MaterialBox")
	var _BoxTypeNode
	for i in 4:
		var _Box = _BoxLoad.instance()

		var _Info = {
			"TSCN": "MaterialBox",
			"NAME": str(_Box.get_instance_id()),
			"pos": Vector2.ZERO,
			"Type": null,
			"Number": 0,
			"IsPassDay": false,
			"IsBroken": false,
			"IsFreezer": false,
			"ItemFreshType": 0,
		}
		match i:
			0:
				_BoxTypeNode = A_Node
				A_Box = _Box
			1:
				_BoxTypeNode = B_Node
				B_Box = _Box
			2:
				_BoxTypeNode = X_Node
				X_Box = _Box
			3:
				_BoxTypeNode = Y_Node
				Y_Box = _Box
		_BoxTypeNode.add_child(_Box)
		_Box.call_load(_Info)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_new_puppet", [A_Box.name, B_Box.name, X_Box.name, Y_Box.name])

func call_take_puppet(_ButID, _PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	match _ButID:
		0:

			GameLogic.Device.call_Player_Pick(_Player, A_Box)
			A_Box = null
		1:

			GameLogic.Device.call_Player_Pick(_Player, B_Box)
			B_Box = null
		2:

			GameLogic.Device.call_Player_Pick(_Player, X_Box)
			X_Box = null
		3:

			GameLogic.Device.call_Player_Pick(_Player, Y_Box)
			Y_Box = null
	_But_Show(_Player)
	UseAni.play("Use")
	call_turn_check()

func call_Box_puppet(_ABOX, _BBOX, _XBOX, _YBOX):

	pass
func call_take(_ButID, _Player):

	match _ButID:
		- 2:
			_But_Hide(_Player)
		- 1:
			_But_Show(_Player)

		0:
			if A_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					A_Box = null

					return

				GameLogic.Device.call_Player_Pick(_Player, A_Box)
				call_put( - 1, A_Box, _Player)
				A_Box = null


				return "取出"
		1:
			if B_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					B_Box = null


					return

				GameLogic.Device.call_Player_Pick(_Player, B_Box)
				call_put( - 1, B_Box, _Player)
				B_Box = null

				return "取出"
		2:
			if X_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					X_Box = null


					return

				GameLogic.Device.call_Player_Pick(_Player, X_Box)
				call_put( - 1, X_Box, _Player)
				X_Box = null

				return "取出"
		3:
			if Y_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					Y_Box = null


					return

				GameLogic.Device.call_Player_Pick(_Player, Y_Box)
				call_put( - 1, Y_Box, _Player)
				Y_Box = null

				return "取出"
func call_put(_ButID, _Dev, _Player):

	match _ButID:
		- 2:
			_But_Hide(_Player)
		- 1:
			_But_Show(_Player)
		0:
			if _Dev.SelfDev == "MaterialBox":
				if not A_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					A_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, A_Node)
					return "放入"
		1:
			if _Dev.SelfDev == "MaterialBox":
				if not B_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					B_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, B_Node)
					return "放入"
		2:
			if _Dev.SelfDev == "MaterialBox":
				if not X_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					X_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, X_Node)
					return "放入"
		3:
			if _Dev.SelfDev == "MaterialBox":
				if not Y_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					Y_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, Y_Node)
					return "放入"
func call_MaterialBox_PutIn_puppet(_DEVPATH, _PLAYERPATH, _DEVNODEPATH):
	var _Player = get_node(_PLAYERPATH)
	var _Dev = get_node(_DEVPATH)
	var _DevNode = get_node(_DEVNODEPATH)
	UseAni.play("Use")
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
	call_take( - 1, _Player)
	call_turn_check()
func MaterialBox_PutIn(_Dev, _Player, _DevNode):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		var _DEVPATH = _Dev.get_path()
		var _DEVNODEPATH = _DevNode.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_MaterialBox_PutIn_puppet", [_DEVPATH, _PLAYERPATH, _DEVNODEPATH])
	UseAni.play("Use")
	_Player.WeaponNode.remove_child(_Dev)
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	_Audio.play(0)
	_Dev.position = Vector2.ZERO
	_DevNode.add_child(_Dev)
	_Dev.call_InFreezerBox(true)
	_Dev.call_Collision_Switch(false)
	_Player.Con.NeedPush = false
	_Player.Stat.call_carry_off()
	call_take( - 1, _Player)
	call_turn_check()

func _But_Hide(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	_A.call_player_out(_Player.cur_Player)
	_B.call_player_out(_Player.cur_Player)
	_X.call_player_out(_Player.cur_Player)
	_Y.call_player_out(_Player.cur_Player)
func _But_Show(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	var _Dev = instance_from_id(_Player.Con.HoldInsId)

	if not _Dev:
		if A_Box:
			_A.call_player_in(_Player.cur_Player)
		else:
			_A.call_player_out(_Player.cur_Player)
		if B_Box:
			_B.call_player_in(_Player.cur_Player)
		else:
			_B.call_player_out(_Player.cur_Player)
		if X_Box:
			_X.call_player_in(_Player.cur_Player)
		else:
			_X.call_player_out(_Player.cur_Player)
		if Y_Box:
			_Y.call_player_in(_Player.cur_Player)
		else:
			_Y.call_player_out(_Player.cur_Player)
	else:
		if _Dev.SelfDev in ["MaterialBox", "FreezerBox"]:
			if not A_Box:
				_A.call_player_in(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if not B_Box:
				_B.call_player_in(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)
			if not X_Box:
				_X.call_player_in(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)
			if not Y_Box:
				_Y.call_player_in(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)
		elif _Dev.selfDev == "DrinkCup":
			pass
