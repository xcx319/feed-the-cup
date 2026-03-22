extends StaticBody2D

export (String, "BOTH", "L", "R") var TYPE: String = "BOTH"
export (int, 1, 2, 3) var TEX: int = 1
var HasTable: bool
var OnTableObj
var FuncType = "GuestSeat"
var CanMove: bool = false
var IsOrder: bool
var OrderList: Array
var L_CanPick: bool
var R_CanPick: bool
var _L_OBJ
var _R_OBJ

onready var PayNode = get_node("OrderNode/PayNode")

var _SELFID: int
func _ready():

	call_init()
	if not GameLogic.is_connected("DayStart", self, "call_dayStart"):
		var _CON = GameLogic.connect("DayStart", self, "call_dayStart")
func call_dayStart():
	get_node("OrderNode/Ani").play("init")
	IsOrder = false
	if is_instance_valid(OnTableObj):
		OnTableObj.queue_free()
	for _NPC in OrderList:
		if is_instance_valid(_NPC):
			_NPC.queue_free()
	OrderList.clear()
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
func _OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("OutLineAni").play("show")
		false:
			get_node("OutLineAni").play("init")
func call_init():
	if not has_node("L") or not has_node("R"):
		return
	_Type_Init()
	_Tex_Init()
func call_NPC_order_puppet():
	get_node("OrderNode/Ani").play("show")
func call_NPC_order(_NPC):
	if OrderList.has(_NPC):

		return
	IsOrder = true
	OrderList.append(_NPC)
	GameLogic.Order.call_NPC_TableOrder(_NPC)
	get_node("OrderNode/Ani").play("show")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_NPC_order_puppet")

func _ButLogic(_Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if OrderList.size():
		get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)
		get_node("But/A").show()
		_OutLine(true)
	else:
		get_node("But/A").hide()
		if _Player.Con.IsHold:
			var _OBJ = instance_from_id(_Player.Con.HoldInsId)
			if _OBJ:
				if _OBJ.has_method("call_FinishUpdate"):
					get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_1)
					get_node("But/A").show()
					_OutLine(true)
					return
		_OutLine(false)

func call_call_master(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	call_home_device(0, 1, 0, _Player)

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			_ButLogic(_Player)
			get_node("But/A").call_player_in(_Player.cur_Player)
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			_ButLogic(_Player)
			get_node("But/A").call_player_out(_Player.cur_Player)
			_OutLine(false)
		0, "A":
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				var _PlayerPath = _Player.get_path()
				SteamLogic.call_master_node_sync(self, "call_call_master", [_PlayerPath])

				return

			if _value == 1:
				if _Player.Con.IsHold:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return




					var _OBJ = instance_from_id(_Player.Con.HoldInsId)
					if _OBJ:
						if _OBJ.has_method("call_FinishUpdate"):
							if has_node("L"):
								var _NPC = get_node("L")._SittingNPC
								if is_instance_valid(_NPC):
									var _PickID = _NPC.PickUpID
									if _PickID != 0:
										if _OBJ.cur_ID != 0:
											if _NPC.PickUpID == _OBJ.cur_ID:
												if L_CanPick:
													return
												call_pickUp_Logic("L", _Player, _NPC)
												return true
							if has_node("R"):
								var _NPC = get_node("R")._SittingNPC
								if is_instance_valid(_NPC):
									var _PickID = _NPC.PickUpID
									if _PickID != 0:
										if _OBJ.cur_ID != 0:
											if _NPC.PickUpID == _OBJ.cur_ID:
												if R_CanPick:
													return
												call_pickUp_Logic("R", _Player, _NPC)
												return true









				if L_CanPick:
					if not _Player.Con.IsHold:
						call_Trashbag_Pick(_Player, "L")
					return true
				elif R_CanPick:
					if not _Player.Con.IsHold:
						call_Trashbag_Pick(_Player, "R")
					return true
				if IsOrder:
					if GameLogic.Device.return_CanUse_bool(_Player):
						return
					call_order(_Player)
					_ButLogic(_Player)
					return true
func call_Study_Logic(_SEATNAME):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	match _SEATNAME:
		"L":
			_add_Trash("L")
		"R":
			_add_Trash("R")
func call_add_trash_puppet(_TYPE, _NAME):
	var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
	Trashbag_TSCN._SELFID = int(_NAME)
	Trashbag_TSCN.name = _NAME
	SteamLogic.OBJECT_DIC[Trashbag_TSCN._SELFID] = Trashbag_TSCN
	_TrashAdd(_TYPE, Trashbag_TSCN)

	Trashbag_TSCN.call_load({"NAME": _NAME, "Weight": 1})
	Trashbag_TSCN.call_Trashbag_init(1, false)
func _add_Trash(_TYPE):
	var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
	Trashbag_TSCN._SELFID = Trashbag_TSCN.get_instance_id()
	var _NAME = str(Trashbag_TSCN._SELFID)
	Trashbag_TSCN.name = _NAME
	SteamLogic.OBJECT_DIC[Trashbag_TSCN._SELFID] = Trashbag_TSCN
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_add_trash_puppet", [_TYPE, _NAME])
	_TrashAdd(_TYPE, Trashbag_TSCN)
	Trashbag_TSCN.call_load({"NAME": _NAME, "Weight": 1})
	Trashbag_TSCN.call_Trashbag_init(1, false)
func _TrashAdd(_TYPE, Trashbag_TSCN):
	match _TYPE:
		"L":
			for _Node in get_node("L_OBJ").get_children():
				get_node("L_OBJ").remove_child(_Node)
				_Node.queue_free()
			get_node("L_OBJ").add_child(Trashbag_TSCN)
			_L_OBJ = Trashbag_TSCN
			L_CanPick = true
			$L.IsOrder = false
		"R":
			for _Node in get_node("R_OBJ").get_children():
				get_node("R_OBJ").remove_child(_Node)
				_Node.queue_free()
			get_node("R_OBJ").add_child(Trashbag_TSCN)
			_R_OBJ = Trashbag_TSCN
			R_CanPick = true
			$R.IsOrder = false
func call_Trashbag_Pick(_Player, _TYPE):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_Pick_puppet", [_PLAYERPATH, _TYPE])
	match _TYPE:
		"L":

			get_node("L_OBJ").remove_child(_L_OBJ)
			_Player.WeaponNode.add_child(_L_OBJ)
			_Player.Con.HoldInsId = _L_OBJ.get_instance_id()
			_Player.Con.IsHold = true
			_Player.Con.NeedPush = true
			L_CanPick = false
		"R":

			get_node("R_OBJ").remove_child(_R_OBJ)
			_Player.WeaponNode.add_child(_R_OBJ)
			_Player.Con.HoldInsId = _R_OBJ.get_instance_id()
			_Player.Con.IsHold = true
			_Player.Con.NeedPush = true
			R_CanPick = false
func call_Pick_puppet(_PLAYERPATH, _TYPE):
	var _Player = get_node(_PLAYERPATH)
	match _TYPE:
		"L":

			get_node("L_OBJ").remove_child(_L_OBJ)
			_Player.WeaponNode.add_child(_L_OBJ)
			_Player.Con.HoldInsId = _L_OBJ.get_instance_id()
			_Player.Con.IsHold = true
			_Player.Con.NeedPush = true
			L_CanPick = false
		"R":

			get_node("R_OBJ").remove_child(_R_OBJ)
			_Player.WeaponNode.add_child(_R_OBJ)
			_Player.Con.HoldInsId = _R_OBJ.get_instance_id()
			_Player.Con.IsHold = true
			_Player.Con.NeedPush = true
			R_CanPick = false
func call_pickUp_puppet(_PLAYERPATH, _TYPE):
	var _Player = get_node(_PLAYERPATH)
	var _OBJ = instance_from_id(_Player.Con.HoldInsId)
	if not is_instance_valid(_OBJ):
		return
	_OBJ.get_parent().remove_child(_OBJ)
	match _TYPE:
		"L":
			for _Node in get_node("L_OBJ").get_children():
				get_node("L_OBJ").remove_child(_Node)
				_Node.queue_free()
			get_node("L_OBJ").add_child(_OBJ)
		"R":
			for _Node in get_node("R_OBJ").get_children():
				get_node("R_OBJ").remove_child(_Node)
				_Node.queue_free()
			get_node("R_OBJ").add_child(_OBJ)
	_Player.Stat.call_carry_off()

	_ButLogic(_Player)
func call_pickUp_Logic(_Type, _Player, _NPC):

	var _OBJ = instance_from_id(_Player.Con.HoldInsId)
	var _check = GameLogic.Order.return_CanPickCheck_Bool(_OBJ)
	if _Player.Stat.Skills.has("技能-强卖"):
		if _check.WrongType < 0:
			_check.WrongType = 1
	if _check.WrongType != 1:


		_OBJ.call_finish(false)
		if _check in [ - 3]:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_WrongCup()
		elif _check in [ - 1]:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_NoHang()
		elif _check in [ - 2]:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_NoTop()
		else:
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Player.call_Say_DrinkWrong()
		return

	if _Player.Stat.Skills.has("技能-出杯"):
		_NPC.CRIBONUS += 5

	_OBJ.get_parent().remove_child(_OBJ)
	match _Type:
		"L":
			for _Node in get_node("L_OBJ").get_children():
				get_node("L_OBJ").remove_child(_Node)
				_Node.queue_free()
			get_node("L_OBJ").add_child(_OBJ)
			L_CanPick = false
		"R":
			for _Node in get_node("R_OBJ").get_children():
				get_node("R_OBJ").remove_child(_Node)
				_Node.queue_free()
			get_node("R_OBJ").add_child(_OBJ)
			R_CanPick = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_pickUp_puppet", [_PLAYERPATH, _Type])
	_Player.Stat.call_carry_off()
	_OBJ.SELLPLAYER = _Player
	_OBJ.call_finish(true)
	_OBJ.But_Switch(false, _Player)
	_NPC.call_pickup(self, _check)
	_NPC._pickUp()
	_ButLogic(_Player)
	pass

func call_order_puppet(_TYPENAME, _PICKUPID, _ANINAME, _ID):
	match _ANINAME:
		"show":
			get_node("OrderNode/Ani").play("show")
		"init":
			get_node("OrderNode/Ani").play("init")

	match _TYPENAME:
			"L":
				if L_CanPick:
					if _ID == SteamLogic.STEAM_ID:
						pass
					return
				var _PickUp = load("res://TscnAndGd/Effects/Ticket.tscn")
				var _PickNode = _PickUp.instance()

				_PickNode._Num = _PICKUPID
				get_node("L_OBJ").add_child(_PickNode)
				L_CanPick = false
				var _ORDERAUDIO = GameLogic.Audio.return_Effect("堂食点单")
				_ORDERAUDIO.play(0)
			"R":
				if R_CanPick:
					if _ID == SteamLogic.STEAM_ID:
						pass
					return
				var _PickUp = load("res://TscnAndGd/Effects/Ticket.tscn")
				var _PickNode = _PickUp.instance()

				_PickNode._Num = _PICKUPID
				get_node("R_OBJ").add_child(_PickNode)
				R_CanPick = false
				var _ORDERAUDIO = GameLogic.Audio.return_Effect("堂食点单")
				_ORDERAUDIO.play(0)
func call_order(_Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _NPC
	var _IDPLUS: int = 0
	if GameLogic.cur_Rewards.has("虚假单号"):
		if _Player.NoPress:
			_IDPLUS = 1
			GameLogic.call_Info(1, "虚假单号")
	if OrderList:
		_NPC = OrderList.pop_front()
		GameLogic.Order.call_TableOrder(_NPC, _IDPLUS)
	var _ANINAME: String
	if OrderList.size():
		_ANINAME = "show"
		get_node("OrderNode/Ani").play("show")
	else:
		_ANINAME = "init"
		get_node("OrderNode/Ani").play("init")
		IsOrder = false

	if _NPC:


		if _NPC.PickUpID == 0:
			_NPC.SeatOBJ.call_leaving(_NPC.PosSave)
			_NPC.IsSit = false
			_NPC.call_leaving()
			return
		var _Name = _NPC.get_parent().get_parent()

		match _Name.name:
			"L":
				if L_CanPick:

					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						pass
					return
				var _PickUp = load("res://TscnAndGd/Effects/Ticket.tscn")
				var _PickNode = _PickUp.instance()
				_PickNode._Num = _NPC.PickUpID
				get_node("L_OBJ").add_child(_PickNode)
				L_CanPick = false
				var _ORDERAUDIO = GameLogic.Audio.return_Effect("堂食点单")
				_ORDERAUDIO.play(0)
			"R":
				if R_CanPick:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						pass
					return
				var _PickUp = load("res://TscnAndGd/Effects/Ticket.tscn")
				var _PickNode = _PickUp.instance()

				_PickNode._Num = _NPC.PickUpID
				get_node("R_OBJ").add_child(_PickNode)
				R_CanPick = false
				var _ORDERAUDIO = GameLogic.Audio.return_Effect("堂食点单")
				_ORDERAUDIO.play(0)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_order_puppet", [_Name.name, _NPC.PickUpID, _ANINAME, _Player.cur_Player])
func _Type_Init():

	match TYPE:
		"BOTH":
			get_node("L").TEX = TEX
			get_node("R").TEX = TEX

		"L":
			get_node("R").queue_free()
			get_node("L").TEX = TEX

		"R":
			get_node("L").queue_free()
			get_node("R").TEX = TEX

func _Tex_Init():
	get_node("Ani").play(str(TEX))

func call_PickUp_Del(_Type):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_PickUp_Del", [_Type])
	match _Type:
		"L":
			if not L_CanPick:
				for _Node in get_node("L_OBJ").get_children():
					get_node("L_OBJ").remove_child(_Node)
					_Node.queue_free()
		"R":
			if not R_CanPick:
				for _Node in get_node("R_OBJ").get_children():
					get_node("R_OBJ").remove_child(_Node)
					_Node.queue_free()

func call_Order_Del(_NPC):
	if OrderList.has(_NPC):
		OrderList.erase(_NPC)
	_OrderAni()

func _OrderAni():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _NAME = "init"
		if OrderList.size():
			_NAME = "show"
		SteamLogic.call_puppet_node_sync(self, "call_order_puppet", ["", 0, _NAME, 0])
	if OrderList.size():
		get_node("OrderNode/Ani").play("show")
	else:
		get_node("OrderNode/Ani").play("init")
		IsOrder = false
