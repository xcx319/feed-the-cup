extends Head_Object
var SelfDev = "TicketMachine"

onready var TicketLabel = $TexNode / Label
onready var UseAni = $AniNode / Use

var cur_Ticket: int

func _ready() -> void :
	call_init(SelfDev)
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	GameLogic.Order.connect("NewOrder", self, "call_new_order")

	GameLogic.Order.connect("OrderUpdate", self, "call_Order_Logic")
	_CanMove_Check()

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	_Ticket_Show()
func _CanMove_Check():
	CanMove = true
func call_Order_Logic(_ID):
	if cur_Ticket == _ID or cur_Ticket == 0:
		cur_Ticket = _return_TakeID(0)

		_Ticket_Show()
	print("call_Order_Logic 3：", cur_Ticket)
func call_new_order(_TYPE):
	print("new order 1：", cur_Ticket)
	if not cur_Ticket:
		cur_Ticket = _return_TakeID(0)
		_Ticket_Show()
	print("new order 2：", cur_Ticket)
func _Ticket_Show():
	if cur_Ticket:
		TicketLabel.show()
		if not UseAni.current_animation == "use":
			UseAni.play("ticket")
	else:
		TicketLabel.hide()
		UseAni.play("init")
	TicketLabel.text = str(cur_Ticket)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Ticket_pupper", [cur_Ticket])
func call_Ticket_pupper(_TICKET):
	cur_Ticket = _TICKET
	_Ticket_Show()
func call_Ticket(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)
		0:

			if cur_Ticket:
				if _HoldObj.IsStale:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
					return
				call_Ticket_Logic(_HoldObj, _Player)
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			call_ChangeTicket(true)
			return true

		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			call_ChangeTicket(false)
			return true
func call_Ticket_Ani():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Ticket_Ani")
	UseAni.play("use")
func call_Ticket_Logic(_HoldObj, _Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if GameLogic.Order.cur_CupArray.has(cur_Ticket):

		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			_Player.call_Say_Repeated()
		return
	call_Ticket_Ani()
	_HoldObj.call_Ticket(cur_Ticket, _Player)

	cur_Ticket = _return_TakeID(0)
	print("最终：", cur_Ticket)
	_Ticket_Show()
func call_ChangeTicket(_TYPEBOOL: bool):
	var _OrderListArray = GameLogic.Order.cur_OrderList.keys()
	var _Text = GameLogic.Order.cur_OrderArray
	var _test2 = GameLogic.Order.cur_CupArray
	match _TYPEBOOL:
		true:
			if cur_Ticket in _OrderListArray and _OrderListArray.size() > 1:
				var _i = _OrderListArray.find(cur_Ticket)
				if _OrderListArray.size() - 1 > _i:
					cur_Ticket = _OrderListArray[_i + 1]
				else:
					cur_Ticket = _OrderListArray[0]
			else:
				_return_TakeID(cur_Ticket)

		false:
			if cur_Ticket in _OrderListArray and _OrderListArray.size() > 1:
				var _i = _OrderListArray.find(cur_Ticket)
				if _i > 0:
					cur_Ticket = _OrderListArray[_i - 1]
				else:
					cur_Ticket = _OrderListArray[_OrderListArray.size() - 1]
			else:
				_return_TakeID(cur_Ticket)

	_Ticket_Show()
func _return_TakeID(_CurInt):
	var _OrderListArray = GameLogic.Order.cur_OrderList.keys()

	for i in _OrderListArray.size():

		var _NewInt = _CurInt + i
		if _NewInt >= _OrderListArray.size():
			_NewInt = 0
		var _NewID = _OrderListArray[_NewInt]

		if not GameLogic.Order.cur_CupArray.has(_NewID):

			return _NewID
	print("未找到新的可拿取的杯子", _CurInt, _OrderListArray, GameLogic.Order.cur_CupArray)

	return 0
func But_Switch(_Switch, _Player):
	if _Switch:
		var _OrderListArray = GameLogic.Order.cur_OrderList.keys()
		if _OrderListArray.size() > 1:
			$But / X.show()
			$But / Y.show()
		else:
			$But / X.hide()
			$But / Y.hide()
		$But / A.hide()
		if _Player.Con.IsHold:
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			if not is_instance_valid(_HoldObj):
				return
			var _x = _HoldObj.get("FuncType")
			if _HoldObj.get("FuncType") in ["DrinkCup", "SodaCan"]:
				$But / A.show()
	.But_Switch(_Switch, _Player)
func call_DevLogic(_ButID, _Player, _DevObj):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			But_Switch(true, _Player)

		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			call_ChangeTicket(true)

			return true
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			call_ChangeTicket(false)
			return true
func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
