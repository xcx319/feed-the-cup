extends Head_Object
var SelfDev = "IceCreamMachine"

onready var BoxNode = get_node("TexNode/BoxNode")

onready var UseAni = get_node("AniNode/Use")
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

var _L_Check: bool
var _R_Check: bool

var IsBlackOut: bool = false
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :
	$But.show()
	call_init(SelfDev)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")
func _BlackOut(_Switch):
	IsBlackOut = _Switch
	call_turn_check()
func _DayClosedCheck():
	if A_Box != null:
		if A_Box.Liquid_Count > 0:
			GameLogic.Total_Electricity += 3
	if B_Box != null:
		if B_Box.Liquid_Count > 0:
			GameLogic.Total_Electricity += 3
	if X_Box != null:
		if X_Box.Liquid_Count > 0:
			GameLogic.Total_Electricity += 3
	if Y_Box != null:
		if Y_Box.Liquid_Count > 0:
			GameLogic.Total_Electricity += 3

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if GameLogic.cur_Day < 1 or GameLogic.SPECIALLEVEL_Int:
		_new_Box()

	else:
		if _Info.A_Box != null:
			call_Box_load("A", _Info.A_Box)
		if _Info.B_Box != null:
			call_Box_load("B", _Info.B_Box)
		if _Info.X_Box != null:

			call_Box_load("X", _Info.X_Box)
		if _Info.Y_Box != null:

			call_Box_load("Y", _Info.Y_Box)
	call_turn_check()


func call_Box_load(_BoxType, _BoxInfo):

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

		match A_Box.get("CreamType"):
			0:
				$TexNode / Switch / ALight / Ani.play("init")
			1:
				if IsBlackOut:
					$TexNode / Switch / ALight / Ani.play("init")
					A_Box.call_MakeIceCream(false)
				else:
					$TexNode / Switch / ALight / Ani.play("Process")
					A_Box.call_MakeIceCream(true)
			2:
				if IsBlackOut:
					$TexNode / Switch / ALight / Ani.play("init")
				else:
					$TexNode / Switch / ALight / Ani.play("Ready")
	else:
		$TexNode / Switch / ALight / Ani.play("init")
	if B_Box:
		match B_Box.get("CreamType"):
			0:
				$TexNode / Switch / BLight / Ani.play("init")
			1:
				if IsBlackOut:
					$TexNode / Switch / BLight / Ani.play("init")
					B_Box.call_MakeIceCream(false)
				else:
					$TexNode / Switch / BLight / Ani.play("Process")
					B_Box.call_MakeIceCream(true)
			2:
				if IsBlackOut:
					$TexNode / Switch / BLight / Ani.play("init")
				else:
					$TexNode / Switch / BLight / Ani.play("Ready")
	else:
		$TexNode / Switch / BLight / Ani.play("init")
	if X_Box:
		match X_Box.get("CreamType"):
			0:
				$TexNode / Switch / XLight / Ani.play("init")
			1:
				if IsBlackOut:
					$TexNode / Switch / XLight / Ani.play("init")
					X_Box.call_MakeIceCream(false)
				else:
					$TexNode / Switch / XLight / Ani.play("Process")
					X_Box.call_MakeIceCream(true)
			2:
				if IsBlackOut:
					$TexNode / Switch / XLight / Ani.play("init")
				else:
					$TexNode / Switch / XLight / Ani.play("Ready")
	else:
		$TexNode / Switch / XLight / Ani.play("init")
	if Y_Box:
		match Y_Box.get("CreamType"):
			0:
				$TexNode / Switch / YLight / Ani.play("init")
			1:
				if IsBlackOut:
					$TexNode / Switch / YLight / Ani.play("init")
					Y_Box.call_MakeIceCream(false)
				else:
					$TexNode / Switch / YLight / Ani.play("Process")
					Y_Box.call_MakeIceCream(true)
			2:
				if IsBlackOut:
					$TexNode / Switch / YLight / Ani.play("init")
				else:
					$TexNode / Switch / YLight / Ani.play("Ready")
	else:
		$TexNode / Switch / YLight / Ani.play("init")
	call_Turn(false)
func call_Turn(_Switch: bool):

	match _Switch:
		true:
			if not _TurnOn:
				_TurnOn = _Switch

		false:
			if _TurnOn:
				_TurnOn = _Switch

func call_new_puppet(_A_NAME, _B_NAME, _X_NAME, _Y_NAME):
	var _TSCNNAME: String = "IceCreamBox"
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN(_TSCNNAME)
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
			"TSCN": _TSCNNAME,
			"NAME": _NAME,
			"pos": Vector2.ZERO,
			"MilkBool": false,
			"CreamBool": false,
			"FlavorType": 0,
			"IsPassDay": false,
			"IsBroken": false,
			"IsFreezer": false,
			"Liquid_Count": 0,
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
	var _BOXNAME: String = "IceCreamBox"
	var _BoxLoad = GameLogic.TSCNLoad.return_TSCN(_BOXNAME)
	var _BoxTypeNode
	for i in 4:
		var _Box = _BoxLoad.instance()

		var _Info = {
			"TSCN": _BOXNAME,
			"NAME": str(_Box.get_instance_id()),
			"pos": Vector2.ZERO,
			"MilkBool": false,
			"CreamBool": false,
			"FlavorType": 0,
			"IsPassDay": false,
			"IsBroken": false,
			"IsFreezer": false,
			"Liquid_Count": 0,
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

			A_Box.call_MakeIceCream(false)
			GameLogic.Device.call_Player_Pick(_Player, A_Box)

			A_Box = null
			call_turn_check()

		1:

			B_Box.call_MakeIceCream(false)
			GameLogic.Device.call_Player_Pick(_Player, B_Box)
			B_Box = null
		2:

			X_Box.call_MakeIceCream(false)
			GameLogic.Device.call_Player_Pick(_Player, X_Box)
			X_Box = null
		3:

			Y_Box.call_MakeIceCream(false)
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

				A_Box.call_MakeIceCream(false)
				GameLogic.Device.call_Player_Pick(_Player, A_Box)
				call_put( - 1, A_Box, _Player)

				A_Box = null
				call_turn_check()

				UseAni.play("Use")


				return "取出"
		1:
			if B_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					B_Box = null


					return

				B_Box.call_MakeIceCream(false)
				GameLogic.Device.call_Player_Pick(_Player, B_Box)
				call_put( - 1, B_Box, _Player)
				B_Box = null

				UseAni.play("Use")

				return "取出"
		2:
			if X_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					X_Box = null


					return

				X_Box.call_MakeIceCream(false)
				GameLogic.Device.call_Player_Pick(_Player, X_Box)
				call_put( - 1, X_Box, _Player)
				X_Box = null

				UseAni.play("Use")

				return "取出"
		3:
			if Y_Box:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					Y_Box = null


					return

				Y_Box.call_MakeIceCream(false)
				GameLogic.Device.call_Player_Pick(_Player, Y_Box)
				call_put( - 1, Y_Box, _Player)
				Y_Box = null

				UseAni.play("Use")

				return "取出"
func call_put(_ButID, _Dev, _Player):

	var _DevName: String = "IceCreamBox"
	match _ButID:
		- 2:
			_But_Hide(_Player)
		- 1:
			_But_Show(_Player)
		0:
			if _Dev.SelfDev == _DevName:
				if not A_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					A_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, A_Node)
					return "放入"
		1:
			if _Dev.SelfDev == _DevName:
				if not B_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					B_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, B_Node)
					return "放入"
		2:
			if _Dev.SelfDev == _DevName:
				if not X_Box:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					X_Box = _Dev
					MaterialBox_PutIn(_Dev, _Player, X_Node)
					return "放入"
		3:
			if _Dev.SelfDev == _DevName:
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

	call_ShowUI(_Player)
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

		if _Dev.get("FuncType") in ["IceCreamBox"]:
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
		elif _Dev.get("FuncType") in ["DrinkCup", "EggRollCup"]:
			if A_Box:
				if A_Box.get("CreamType") == 2 and A_Box.get("Liquid_Count") > 0:
					_A.call_player_in(_Player.cur_Player)
				else:
					_A.call_player_out(_Player.cur_Player)
			else:
				_A.call_player_out(_Player.cur_Player)
			if B_Box:
				if B_Box.get("CreamType") == 2 and B_Box.get("Liquid_Count") > 0:
					_B.call_player_in(_Player.cur_Player)
				else:
					_B.call_player_out(_Player.cur_Player)
			else:
				_B.call_player_out(_Player.cur_Player)
			if X_Box:
				if X_Box.get("CreamType") == 2 and X_Box.get("Liquid_Count") > 0:
					_X.call_player_in(_Player.cur_Player)
				else:
					_X.call_player_out(_Player.cur_Player)
			else:
				_X.call_player_out(_Player.cur_Player)
			if Y_Box:
				if Y_Box.get("CreamType") == 2 and Y_Box.get("Liquid_Count") > 0:
					_Y.call_player_in(_Player.cur_Player)
				else:
					_Y.call_player_out(_Player.cur_Player)
			else:
				_Y.call_player_out(_Player.cur_Player)
func call_Light_Logic():
	if A_Box:
		pass
	else:
		$TexNode / Switch / ALight / Ani.play("init")
	if X_Box:
		pass
	else:
		$TexNode / Switch / XLight / Ani.play("init")
	if Y_Box:
		pass
	else:
		$TexNode / Switch / YLight / Ani.play("init")
	if B_Box:
		pass
	else:
		$TexNode / Switch / BLight / Ani.play("init")

func call_DrinkCup(_ButID, _DrinkCup, _Player):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_But_Hide(_Player)

		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_But_Show(_Player)


		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsBlackOut:
				return

			if _DrinkCup.Liquid_Count < _DrinkCup.Liquid_Max:
				if A_Box != null:
					if _DrinkCup.Top != "":
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if A_Box.get("IsBroken"):
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if A_Box.get("CreamType") == 2 and A_Box.get("Liquid_Count") > 0:
						if _L_Check and _R_Check:
							if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
								_Player.call_Say_Repeated()
								return
							return

						call_Use_Logic(_ButID, _DrinkCup, _Player)
						return true
		1:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsBlackOut:
				return
			if _DrinkCup.Liquid_Count < _DrinkCup.Liquid_Max:
				if B_Box != null:
					if _DrinkCup.Top != "":
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if B_Box.get("IsBroken"):
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if B_Box.get("CreamType") == 2 and B_Box.get("Liquid_Count") > 0:
						if _L_Check and _R_Check:
							if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
								_Player.call_Say_Repeated()
								return
							return

						call_Use_Logic(_ButID, _DrinkCup, _Player)
						return true
		2:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsBlackOut:
				return
			if _DrinkCup.Liquid_Count < _DrinkCup.Liquid_Max:
				if X_Box != null:
					if _DrinkCup.Top != "":
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if X_Box.get("IsBroken"):
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if X_Box.get("CreamType") == 2 and X_Box.get("Liquid_Count") > 0:
						if _L_Check and _R_Check:
							if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
								_Player.call_Say_Repeated()
								return
							return

						call_Use_Logic(_ButID, _DrinkCup, _Player)
						return true
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if IsBlackOut:
				return
			if _DrinkCup.Liquid_Count < _DrinkCup.Liquid_Max:
				if Y_Box != null:
					if _DrinkCup.Top != "":
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if Y_Box.get("IsBroken"):
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
					if Y_Box.get("CreamType") == 2 and Y_Box.get("Liquid_Count") > 0:
						if _L_Check and _R_Check:
							if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
								_Player.call_Say_Repeated()
								return
							return

						call_Use_Logic(_ButID, _DrinkCup, _Player)
						return true

var _PRESSDIC: Dictionary
var _EggRollBut: int = - 1
func call_Use_Logic(_ID, _DrinkCup, _Player):
	if _Player.global_position < self.global_position:
		_L_Check = true
		_R_Check = false
	else:
		_R_Check = true
		_L_Check = false
	GameLogic.Total_Electricity += 0.1
	var _x = _DrinkCup.FuncType
	if _DrinkCup.FuncType in ["EggRollCup"]:
		if _ID == _EggRollBut:
			return
		match _ID:
			0:

				$TexNode / Switch / A / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _WATERTYPE = A_Box.get("WaterType")
				var _FUNCTYPE = A_Box.get("FuncType")
				var _CELCIUS = A_Box.get("WaterCelcius")
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, A_Box.WaterType, _Player)
				_DrinkCup.EggRoll_In_Logic(A_Box)
				call_DrinkCup_Ice(_DrinkCup)

				A_Box.call_Use()
				var _Liquid = _DrinkCup.Liquid_Count
				yield(get_tree().create_timer(0.2), "timeout")
				if _DrinkCup.Liquid_Count == _Liquid and _Liquid in [1, 3, 5]:

					_DrinkCup.call_IceCream(_WATERTYPE, _FUNCTYPE, _CELCIUS)

			1:

				$TexNode / Switch / B / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _WATERTYPE = B_Box.get("WaterType")
				var _FUNCTYPE = B_Box.get("FuncType")
				var _CELCIUS = B_Box.get("WaterCelcius")
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, B_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(B_Box)
				call_DrinkCup_Ice(_DrinkCup)
				B_Box.call_Use()
				var _Liquid = _DrinkCup.Liquid_Count
				yield(get_tree().create_timer(0.2), "timeout")
				if _DrinkCup.Liquid_Count == _Liquid and _Liquid in [1, 3, 5]:
					_DrinkCup.call_IceCream(_WATERTYPE, _FUNCTYPE, _CELCIUS)

			2:

				$TexNode / Switch / X / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _WATERTYPE = X_Box.get("WaterType")
				var _FUNCTYPE = X_Box.get("FuncType")
				var _CELCIUS = X_Box.get("WaterCelcius")
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, X_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(X_Box)
				call_DrinkCup_Ice(_DrinkCup)
				X_Box.call_Use()

				var _Liquid = _DrinkCup.Liquid_Count
				yield(get_tree().create_timer(0.2), "timeout")
				if _DrinkCup.Liquid_Count == _Liquid and _Liquid in [1, 3, 5]:
					_DrinkCup.call_IceCream(_WATERTYPE, _FUNCTYPE, _CELCIUS)

			3:

				$TexNode / Switch / Y / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _WATERTYPE = Y_Box.get("WaterType")
				var _FUNCTYPE = Y_Box.get("FuncType")
				var _CELCIUS = Y_Box.get("WaterCelcius")
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, Y_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(Y_Box)
				call_DrinkCup_Ice(_DrinkCup)
				Y_Box.call_Use()
				var _Liquid = _DrinkCup.Liquid_Count
				yield(get_tree().create_timer(0.2), "timeout")
				if _DrinkCup.Liquid_Count == _Liquid and _Liquid in [1, 3, 5]:
					_DrinkCup.call_IceCream(_WATERTYPE, _FUNCTYPE, _CELCIUS)

	else:
		match _ID:
			0:
				$TexNode / Switch / A / Use.play("init")
				$TexNode / Switch / A / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, A_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(A_Box)
				call_DrinkCup_Ice(_DrinkCup)
				A_Box.call_Use()
			1:
				$TexNode / Switch / B / Use.play("init")
				$TexNode / Switch / B / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, B_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(B_Box)
				call_DrinkCup_Ice(_DrinkCup)
				B_Box.call_Use()
			2:
				$TexNode / Switch / X / Use.play("init")
				$TexNode / Switch / X / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, X_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(X_Box)
				call_DrinkCup_Ice(_DrinkCup)
				X_Box.call_Use()
			3:
				$TexNode / Switch / Y / Use.play("init")
				$TexNode / Switch / Y / Use.play("use")
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 1, Y_Box.WaterType, _Player)
				_DrinkCup.Water_In_Logic(Y_Box)
				call_DrinkCup_Ice(_DrinkCup)
				Y_Box.call_Use()

func _on_L_body_entered(_Player):
	pass

func _on_L_body_exited(_Player):
	pass


var _PLAYERLIST: Array
func call_UI():

	$TexNode / UI / R / Ani.play("out")
	$TexNode / UI / L / Ani.play("out")
	for _Player in _PLAYERLIST:
		if _Player.global_position < self.global_position:
			$TexNode / UI / L / Ani.play("in")
		else:
			$TexNode / UI / R / Ani.play("in")

func call_ShowEnd(_Player):
	if not is_instance_valid(_Player):
		return
	if _PLAYERLIST.has(_Player):
		_PLAYERLIST.erase(_Player)
	if not _PLAYERLIST.size():
		if $TexNode / UI / ShowUI.assigned_animation == "show":
			$TexNode / UI / ShowUI.play("hide")

func call_ShowUI(_Player):
	if not is_instance_valid(_Player):
		return
	if not _PLAYERLIST.has(_Player):
		_PLAYERLIST.append(_Player)

	if $TexNode / UI / ShowUI.assigned_animation != "show":
		$TexNode / UI / ShowUI.play("show")

	set_process(true)

func _process(_delta):
	call_UI()
func call_DrinkCup_Ice(_DrinkCup):
	if _L_Check:
		_DrinkCup.call_AddIceBreak(2)
	elif _R_Check:
		_DrinkCup.call_AddIceBreak(3)
func call_player_leave(_Player):
	call_ShowEnd(_Player)
