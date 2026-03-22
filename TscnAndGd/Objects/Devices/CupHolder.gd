extends Head_Object
var SelfDev = "CupHolder"

var Cup_Max: int = 14
var S_Num: int = 0
var M_Num: int = 0
var L_Num: int = 0
var CanTake_bool: bool
var Take_DEV = null
var Take_CupType: String
var _Take_ID
var _Cur_ID
var _TakeList: Array
onready var S_Label = get_node("Logic/S")
onready var M_Label = get_node("Logic/M")
onready var L_Label = get_node("Logic/L")
onready var S_TP = get_node("Logic/SP/TP")
onready var M_TP = get_node("Logic/MP/TP")
onready var L_TP = get_node("Logic/LP/TP")
onready var S_Ani = S_TP.get_node("Ani")
onready var M_Ani = M_TP.get_node("Ani")
onready var L_Ani = L_TP.get_node("Ani")
onready var IDLabel = get_node("TexNode/Cups/CupNode/IDLabel")
onready var CupNode = get_node("TexNode/Cups/Node")
onready var CupAni = get_node("Logic/CupAni")
onready var InAni = get_node("AniNode/InAni")
onready var WarningAni = get_node("WarningNode/WarningAni")
onready var UseAni = get_node("AniNode/Use")
onready var UpgradeAni = get_node("AniNode/Upgrade")
onready var RunOut = get_node("AniNode/RunOutAni")
onready var A_But = get_node("But/A")
onready var X_But = get_node("But/X")

onready var Audio_Put
onready var Audio_Pick
onready var Audio_Order
onready var Audio_Wrong
func But_Switch(_bool, _Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _bool:
		if _Player.Con.IsHold:

			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			A_But.show()
			X_But.hide()
		else:
			if CanMove:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
			else:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
			if CanTake_bool or CanMove:

				A_But.show()
			else:
				A_But.hide()

	else:
		if _Player.Con.IsHold:
			But_hide(_bool, _Player)
			return

	var _OrderList = GameLogic.Order.cur_OrderList.keys()
	for _CUP in GameLogic.Order.cur_CupArray:
		_OrderList.erase(_CUP)
	if _OrderList.size() > 1:

		X_But.show()
	else:
		X_But.hide()


	.But_Switch(_bool, _Player)

func _ready() -> void :
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	GameLogic.Order.connect("NewOrder", self, "call_new_order")
	Audio_Put = GameLogic.Audio.return_Effect("放下包")
	Audio_Pick = GameLogic.Audio.return_Effect("拿起")
	Audio_Order = GameLogic.Audio.return_Effect("气泡")
	Audio_Wrong = GameLogic.Audio.return_Effect("错误1")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("CloseLight", self, "_call_init"):
		var _con = GameLogic.connect("CloseLight", self, "_call_init")

	if CanLayout:
		CanMove = true
	GameLogic.NPC.CUPHOLDER = self


func _CanMove_Check():



	if CanTake_bool:
		CanMove = false
	else:
		CanMove = true
func _call_init():
	_TakeList.clear()
func Update_Check():
	if GameLogic.cur_Rewards.has("杯架升级"):

		if UpgradeAni.assigned_animation != "2":
			UpgradeAni.play("2")
	if GameLogic.cur_Rewards.has("杯架升级+"):

		if UpgradeAni.assigned_animation != "3":
			UpgradeAni.play("3")

func call_load(_Info):
	Update_Check()
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	S_Num = int(_Info.S_Num)
	M_Num = int(_Info.M_Num)
	L_Num = int(_Info.L_Num)
	_Show_Num_Logic()
func call_Num_puppet(_S, _M, _L):
	S_Num = _S
	M_Num = _M
	L_Num = _L
	_Show_Num_Logic()
func _Show_Num_Logic():
	S_Label.text = str(S_Num)
	M_Label.text = str(M_Num)
	L_Label.text = str(L_Num)
	S_TP.value = S_Num
	S_TP.max_value = (Cup_Max - 10)
	M_TP.value = M_Num
	M_TP.max_value = (Cup_Max - 10)
	L_TP.value = L_Num
	L_TP.max_value = (Cup_Max - 10)
	if S_Num <= 2:
		S_Ani.play("Less")
	elif S_Num <= 4:
		S_Ani.play("Few")
	else:
		S_Ani.play("Full")
	if M_Num <= 2:
		M_Ani.play("Less")
	elif M_Num <= 4:
		M_Ani.play("Few")
	else:
		M_Ani.play("Full")
	if L_Num <= 2:
		L_Ani.play("Less")
	elif L_Num <= 4:
		L_Ani.play("Few")
	else:
		L_Ani.play("Full")

func _Full_Effect(_Player):
	WarningAni.play("Full")
	Audio_Wrong.play(0)
	if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		_Player.call_Say_NoAdd()
		pass
func call_CupIn_puppet(_PLAYERPATH, _CUPPATH, _S, _M, _L):
	var _Player = get_node(_PLAYERPATH)
	var _CupObj = get_node(_CUPPATH)
	if _CupObj.FuncType == "DrinkCup":
		GameLogic.Order.call_OutLine(_CupObj.cur_ID, 0)
	Audio_Put.play(0)
	_CupObj.call_cleanID()
	var _Node = _CupObj.get_parent()
	_Node.remove_child(_CupObj)
	_Player.Stat.call_carry_off_puppet()
	_CupObj.call_del()
	S_Num = _S
	M_Num = _M
	L_Num = _L
	L_Label.text = str(L_Num)

	But_Switch(true, _Player)
func call_CupIn(_ButID, _CupObj, _Player):

	if _CupObj.Liquid_Count == 0 and _CupObj.Extra_1 == "" and _CupObj.Condiment_1 == "" and not _CupObj.SugarType and not _CupObj.HasIce:
		match _CupObj.TYPE:
			"DrinkCup_S":
				if S_Num < Cup_Max:
					match _ButID:
						- 2:
							But_Switch(false, _Player)
						- 1:
							But_Switch(true, _Player)
						0:

							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
								return
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _PLAYERPATH = _Player.get_path()
								var _CUPPATH = _CupObj.get_path()
								SteamLogic.call_puppet_node_sync(self, "call_CupIn_puppet", [_PLAYERPATH, _CUPPATH, S_Num, M_Num, L_Num])
							if _CupObj.FuncType == "DrinkCup":
								GameLogic.Order.call_OutLine(_CupObj.cur_ID, 0)
							Audio_Put.play(0)
							_CupObj.call_cleanID()
							_CupObj.call_del()
							_Player.Stat.call_carry_off()

							S_Num += 1
							call_PutOn( - 1, _Player)
							S_Label.text = str(S_Num)
							call_new_order(0)
							But_Switch(true, _Player)
					return 0
				else:
					_Full_Effect(_Player)
			"DrinkCup_M":
				if M_Num < Cup_Max:
					match _ButID:
						- 2:
							But_Switch(false, _Player)
						- 1:
							But_Switch(true, _Player)
						0:
							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							if _CupObj.FuncType == "DrinkCup":
								GameLogic.Order.call_OutLine(_CupObj.cur_ID, 0)

							Audio_Put.play(0)
							_CupObj.call_cleanID()
							_CupObj.call_del()

							_Player.Stat.call_carry_off()

							M_Num += 1
							call_PutOn( - 1, _Player)
							M_Label.text = str(M_Num)
							call_new_order(0)
							But_Switch(true, _Player)
					return 0
				else:
					_Full_Effect(_Player)
			"DrinkCup_L":
				if L_Num < Cup_Max:
					match _ButID:
						- 2:
							But_Switch(false, _Player)
						- 1:
							But_Switch(true, _Player)
						0:
							if GameLogic.Device.return_CanUse_bool(_Player):
								return
							if _CupObj.FuncType == "DrinkCup":
								GameLogic.Order.call_OutLine(_CupObj.cur_ID, 0)

							Audio_Put.play(0)
							_CupObj.call_cleanID()
							_CupObj.call_del()

							_Player.Stat.call_carry_off()

							L_Num += 1
							call_PutOn( - 1, _Player)
							L_Label.text = str(L_Num)
							call_new_order(0)
							But_Switch(true, _Player)
					return 0
				else:
					_Full_Effect(_Player)

func call_PutOn(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			var _CupGroupTSCN = instance_from_id(_Player.Con.HoldInsId)
			if not is_instance_valid(_CupGroupTSCN):
				return
			var _CupTypeStr = _CupGroupTSCN.TypeStr
			match _CupTypeStr:
				"DrinkCup_Group_S":
					if S_Num + 10 > Cup_Max:

						return
				"DrinkCup_Group_M":
					if M_Num + 10 > Cup_Max:

						return
				"DrinkCup_Group_L":
					if L_Num + 10 > Cup_Max:

						return
			But_Switch(true, _Player)
		0:

			var _CupGroupTSCN = instance_from_id(_Player.Con.HoldInsId)
			var _CupTypeStr = _CupGroupTSCN.TypeStr
			match _CupTypeStr:
				"DrinkCup_Group_S":
					if S_Num + 10 > Cup_Max:

						_Full_Effect(_Player)
						return
					S_Num += 10
					Audio_Put.play(0)

					_CupGroupTSCN.call_del()

					_Player.Stat.call_carry_off()

					InAni.play("S")
					call_new_order(0)

				"DrinkCup_Group_M":
					if M_Num + 10 > Cup_Max:
						_Full_Effect(_Player)
						return
					M_Num += 10
					Audio_Put.play(0)

					_CupGroupTSCN.call_del()

					_Player.Stat.call_carry_off()

					InAni.play("M")
					call_new_order(0)
				"DrinkCup_Group_L":
					if L_Num + 10 > Cup_Max:
						_Full_Effect(_Player)
						return
					L_Num += 10
					Audio_Put.play(0)

					_CupGroupTSCN.call_del()

					_Player.Stat.call_carry_off()

					InAni.play("L")
					call_new_order(0)
			But_Switch(true, _Player)
			_Show_Num_Logic()
			_CanMove_Check()
			return "放入杯组"

func _return_TakeID(_CurInt):
	var _OrderListArray = GameLogic.Order.cur_OrderList.keys()

	for i in _OrderListArray.size():

		var _NewInt = _CurInt + i
		if _NewInt >= _OrderListArray.size():
			_NewInt = 0
		var _NewID = _OrderListArray[_NewInt]

		if not GameLogic.Order.cur_CupArray.has(_NewID):

			return _NewID

	var _OrderArray = GameLogic.Order.cur_OrderArray
	for y in _OrderArray.size():
		var _NewCup_Bool: bool = true
		for i in GameLogic.Order.cur_CupArray.size():
			if _OrderArray[y] == GameLogic.Order.cur_CupArray[i]:
				_NewCup_Bool = false
				break
		if _NewCup_Bool:
			return _OrderArray[y]

	return
func return_new_order(_type):
	var _CurID = _Take_ID
	var _OrderArray = GameLogic.Order.cur_OrderArray
	if _type == 1:

		if _OrderArray.size() > 0:
			if _Take_ID == null:
				_Take_ID = 0
			if _Take_ID < _OrderArray.max():
				var _OrderListArray = GameLogic.Order.cur_OrderList.keys()
				if _OrderListArray.has(_Take_ID):
					var _NewInt = _OrderListArray.find(_Take_ID)
					if _NewInt != - 1:
						_NewInt += 1
					if _OrderListArray.size() >= _NewInt:

						_Take_ID = _return_TakeID(_NewInt)
					else:

						_Take_ID = _return_TakeID(0)
				else:

					_Take_ID = _return_TakeID(0)
			else:

				_Take_ID = _return_TakeID(0)

	elif _OrderArray.size() > 0:

		if CanTake_bool:
			return

		_CurID = null
		_Take_ID = null
		var _OrderListArray = GameLogic.Order.cur_OrderList.keys()
		if GameLogic.Order.cur_CupArray.size() == 0:
			if _OrderListArray:
				_Take_ID = _OrderListArray[0]
			else:
				return
		else:
			for y in _OrderListArray.size():
				var _NewCup_Bool: bool = true
				for i in GameLogic.Order.cur_CupArray.size():
					if _OrderListArray[y] == GameLogic.Order.cur_CupArray[i]:
						_NewCup_Bool = false
						break
				if _NewCup_Bool:
					_Take_ID = _OrderListArray[y]
					if not GameLogic.Order.cur_OrderList.has(_Take_ID):
						print(GameLogic.Order.cur_OrderList.keys(), "TakeID错误：", _OrderListArray, GameLogic.Order.cur_CupArray)
					break

	if _Take_ID == null:
		CanTake_bool = false
		return

	if _CurID == _Take_ID:
		return

	return true

func call_new_order(_type):

	if return_new_order(_type) == true:

		call_NextCup_Logic()

func call_NextCup_puppet(_TYPE, _CUPID, _CUPTYPE, _CUPANI, _TAKEID):

	match _TYPE:
		0, 1:
			CanTake_bool = true
			Take_CupType = _CUPTYPE
			_Take_ID = _TAKEID
			if _TYPE == 0:
				var _TSCN = GameLogic.TSCNLoad.return_TSCN("DrinkCup")
				var _DrinkCup = _TSCN.instance()
				_DrinkCup._SELFID = _CUPID
				_DrinkCup.name = str(_DrinkCup._SELFID)
				CupNode.add_child(_DrinkCup)
				Take_DEV = _DrinkCup
				SteamLogic.OBJECT_DIC[_CUPID] = Take_DEV
			Take_DEV.call_CupType_init(Take_CupType, false, - 1)
			Take_DEV.call_CupInfo_Switch(false)
			CupAni.play(_CUPANI)
			_CanMove_Check()
			IDLabel.text = str(_Take_ID)
			_Cur_ID = _Take_ID
			RunOut.play("init")
			Audio_Order.play(0)
		2:
			CanTake_bool = false
			Take_CupType = _CUPTYPE
			_Take_ID = _TAKEID
			RunOut.play(_CUPANI)
			CupAni.play("init")
func call_NextCup_Logic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var CupType_menu: String
	var _OrderName
	if GameLogic.Order.cur_OrderList.has(_Take_ID):
		_OrderName = GameLogic.Order.cur_OrderList[_Take_ID]["Name"]
	else:
		var _ListKey = GameLogic.Order.cur_OrderList.keys()
		_OrderName = GameLogic.Order.cur_OrderList[_ListKey[0]]["Name"]
	CupType_menu = GameLogic.Config.FormulaConfig[_OrderName]["CupType"]

	var _checkCupNum: int = 0

	match CupType_menu:
		"S":
			Take_CupType = "DrinkCup_S"
			_checkCupNum = S_Num
		"M":
			Take_CupType = "DrinkCup_M"
			_checkCupNum = M_Num
		"L":
			Take_CupType = "DrinkCup_L"
			_checkCupNum = L_Num
	if _checkCupNum > 0:
		CanTake_bool = true
		if not is_instance_valid(Take_DEV):
			var _TSCN = GameLogic.TSCNLoad.return_TSCN("DrinkCup")
			var _DrinkCup = _TSCN.instance()
			_DrinkCup._SELFID = _DrinkCup.get_instance_id()
			_DrinkCup.name = str(_DrinkCup._SELFID)
			CupNode.add_child(_DrinkCup)

			SteamLogic.OBJECT_DIC[_DrinkCup._SELFID] = _DrinkCup
			Take_DEV = _DrinkCup
			Take_DEV.call_CupType_init(Take_CupType, false, - 1)
			Take_DEV.call_CupInfo_Switch(false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_NextCup_puppet", [0, _DrinkCup._SELFID, Take_CupType, CupType_menu, _Take_ID])
		else:
			Take_DEV.call_CupType_init(Take_CupType, false, - 1)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_NextCup_puppet", [1, "", Take_CupType, CupType_menu, _Take_ID])
		CupAni.play(CupType_menu)
		_CanMove_Check()
		IDLabel.text = str(_Take_ID)
		_Cur_ID = _Take_ID
		RunOut.play("init")
		Audio_Order.play(0)
	else:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_NextCup_puppet", [2, "", Take_CupType, CupType_menu, _Take_ID])
		CanTake_bool = false
		RunOut.play(CupType_menu)
		CupAni.play("init")

func call_DevLogic(_butID, _Player, _DevObj):

	match _butID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)

		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if CanTake_bool:

				_TakeACup(_Cur_ID, _Player, _DevObj)
				_CanMove_Check()
				return "取出饮品杯"
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			call_new_order(1)
			call_DevLogic( - 1, _Player, _DevObj)
			_CanMove_Check()
			pass

func call_TakeCup_puppet(_ID, _TYPE, _PLAYERPATH, _S, _M, _L, _CUPID, _ISCOMBO: bool = false):

	Take_CupType = _TYPE
	var _Player = get_node(_PLAYERPATH)
	if _ISCOMBO:
		$AniNode / ComboAni.play("init")
		$AniNode / ComboAni.play("combo")
		call_Extra()
	if SteamLogic.IsMultiplay and _Player.cur_Player == SteamLogic.STEAM_ID:
		GameLogic.Order.call_pickup_cup_logic(_ID, _Player.cur_Player)
	elif not SteamLogic.IsMultiplay:
		GameLogic.Order.call_pickup_cup_logic(_ID, _Player.cur_Player)
	if not is_instance_valid(Take_DEV):
		var _TSCN = GameLogic.TSCNLoad.return_TSCN("DrinkCup")
		var _DrinkCup = _TSCN.instance()
		_DrinkCup._SELFID = _CUPID
		_DrinkCup.name = str(_CUPID)
		CupNode.add_child(_DrinkCup)
		Take_DEV = _DrinkCup
		Take_DEV.call_CupType_init(Take_CupType, false, - 1)
		Take_DEV.call_CupInfo_Switch(false)
		SteamLogic.OBJECT_DIC[_CUPID] = Take_DEV

	Take_DEV.cur_ID = _ID

	GameLogic.Device.call_Pick_Logic(_Player, Take_DEV)
	Take_DEV.call_CupType_init(Take_CupType, true, _Player.cur_Player)
	_Player.Stat.call_carry_on(Take_DEV.CarrySpeed)
	_Take_ID = null
	Take_DEV.get_node("CupInfo/IDLabel").text = str(_ID)
	Take_DEV = null
	CupAni.play("init")
	CanTake_bool = false
	if not Audio_Pick.is_playing():
		Audio_Pick.play(0)
	UseAni.play("use")
	_CanMove_Check()
	call_Num_puppet(_S, _M, _L)
	call_DevLogic( - 1, _Player, null)
func _TakeACup(_ID, _Player, _DevObj):
	match Take_CupType:
		"DrinkCup_S":
			if S_Num <= 0:
				Audio_Wrong.play(0)
				return
		"DrinkCup_M":
			if M_Num <= 0:
				Audio_Wrong.play(0)
				return
		"DrinkCup_L":
			if L_Num <= 0:
				Audio_Wrong.play(0)
				return



	GameLogic.Order.call_pickup_cup_logic(_ID, _Player.cur_Player)

	var _ISCOMBO: bool
	if not Audio_Pick.is_playing():
		Audio_Pick.play(0)
	if GameLogic.cur_Rewards.has("杯架升级"):
		if not _TakeList.has(_ID):
			_TakeList.append(_ID)
			var _rand = GameLogic.return_randi() % 4
			if _rand == 0:
				match Take_CupType:
					"DrinkCup_S":
						S_Num += 1
					"DrinkCup_M":
						M_Num += 1
					"DrinkCup_L":
						L_Num += 1
			var _ComboRand = GameLogic.return_randi() % 100
			var _MAX = 10
			if _ComboRand < _MAX:
				$AniNode / ComboAni.play("init")
				$AniNode / ComboAni.play("combo")
				GameLogic.call_combo(1)
				_ISCOMBO = true
	elif GameLogic.cur_Rewards.has("杯架升级+"):
		if not _TakeList.has(_ID):
			_TakeList.append(_ID)
			var _rand = GameLogic.return_randi() % 4
			if _rand > 0:
				match Take_CupType:
					"DrinkCup_S":
						S_Num += 1
					"DrinkCup_M":
						M_Num += 1
					"DrinkCup_L":
						L_Num += 1
			var _ComboRand = GameLogic.return_randi() % 100
			var _MAX = 30
			if _ComboRand < _MAX:
				$AniNode / ComboAni.play("init")
				$AniNode / ComboAni.play("combo")
				GameLogic.call_combo(1)
				_ISCOMBO = true
	match Take_CupType:
		"DrinkCup_S":
			S_Num -= 1
		"DrinkCup_M":
			M_Num -= 1
		"DrinkCup_L":
			L_Num -= 1
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_TakeCup_puppet", [_ID, Take_CupType, _PLAYERPATH, S_Num, M_Num, L_Num, Take_DEV._SELFID, _ISCOMBO])

	Take_DEV.cur_ID = _ID
	GameLogic.Device.call_Pick_Logic(_Player, Take_DEV)
	Take_DEV.call_CupType_init(Take_CupType, true, _Player.cur_Player)
	_Player.Stat.call_carry_on(Take_DEV.CarrySpeed)
	_Take_ID = null

	Take_DEV.get_node("CupInfo/IDLabel").text = str(_ID)
	Take_DEV = null
	CupAni.play("init")
	CanTake_bool = false
	if _ISCOMBO:
		call_Extra()
	_Show_Num_Logic()
	UseAni.play("use")
	call_new_order(0)
	call_DevLogic( - 1, _Player, _DevObj)

func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
