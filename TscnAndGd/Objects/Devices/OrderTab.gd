extends Head_Object
var SelfDev = "OrderTab"

export var OFFSET: Vector2 = Vector2.ZERO
var TurnOn: bool
var HasOrder: bool

var OrderList: Array
var LineUp_Array: Array

onready var MenuUI
onready var OrderScreen = get_node("AniNode/OrderScreen")
onready var GuideAni = get_node("AniNode/GuideAni")
onready var UseAni = get_node("AniNode/Use")
onready var A_But = get_node("But/A")

onready var Audio_Order
onready var Audio_Pop
onready var UINode = get_node("Menu")
var GuideBool: bool
var _TimeCheck: float = 0

func call_Tutorial():
	if not TurnOn:
		GuideAni.play("show_red")

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	.But_Switch(_bool, _Player)

func _ready() -> void :
	call_init(SelfDev)
	_CardUI_Load()
	call_deferred("_call_staffLogic_init")
	Audio_Order = GameLogic.Audio.return_Effect("敲键盘1")
	Audio_Pop = GameLogic.Audio.return_Effect("气泡")
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if not GameLogic.is_connected("OpenStore", self, "call_Open"):
		var _con = GameLogic.connect("OpenStore", self, "call_Open")
func call_Open():

	if not TurnOn:

		OrderScreen.play("On")
		TurnOn = true
		if GuideAni.assigned_animation == "show_red":
			GuideAni.play("init")
func Update_Check():
	if GameLogic.cur_Rewards.has("未点单COMBO"):
		if get_node("AniNode/Upgrade").assigned_animation != "1":
			get_node("AniNode/Upgrade").play("1")
	if GameLogic.cur_Rewards.has("未点单COMBO+"):
		if get_node("AniNode/Upgrade").assigned_animation != "2":
			get_node("AniNode/Upgrade").play("2")
	if GameLogic.cur_Rewards.has("未下单COMBO"):
		if get_node("AniNode/Screen").assigned_animation != "1":
			get_node("AniNode/Screen").play("1")
	if GameLogic.cur_Rewards.has("未下单COMBO+"):
		if get_node("AniNode/Screen").assigned_animation != "2":
			get_node("AniNode/Screen").play("2")
func _CardUI_Load():
	var _UILoad = load("res://TscnAndGd/UI/InGame/Menu.tscn")
	MenuUI = _UILoad.instance()
	UINode.add_child(MenuUI)
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("OFFSET"):
		OFFSET = _Info.OFFSET
	call_OrderPoint()
	Update_Check()
func call_OrderPoint():
	GameLogic.Astar.OrderV2 = global_position + OFFSET

func _call_staffLogic_init():
	GameLogic.Staff.call_OrderTab_init(self)
	var _con = GameLogic.Tutorial.connect("Closed", self, "_Tutorial_Logic")

	var _conClose = GameLogic.connect("CloseLight", self, "_close_logic")
func _close_logic():
	OrderScreen.play("Off")
func _Tutorial_Logic():
	GuideBool = true

func _physics_process(_delta: float) -> void :
	_TimeCheck += _delta
	if _TimeCheck > 0.5:
		_TimeChangeLogic()
		_TimeCheck = 0
func _TimeChangeLogic() -> void :
	if GameLogic.Order.cur_LineUpArray.size():
		A_But.show()
		if not HasOrder:
			get_node("AniNode/Audio").play(0)
			if OrderScreen.assigned_animation != "call":
				OrderScreen.play("call")
			HasOrder = true
	else:
		A_But.hide()
		if HasOrder:
			if OrderScreen.assigned_animation != "on":
				OrderScreen.play("On")
			HasOrder = false

	if GuideBool:
		if GameLogic.GameUI.CurTime > GameLogic.cur_CloseTime:

			if not GameLogic.Order.cur_OrderList.size() or not GameLogic.Order.cur_LineUpArray.size():
				if not GuideAni.assigned_animation == "show":
					GuideAni.play("show")
			elif not GuideAni.assigned_animation == "init":
				GuideAni.play("init")
func call_NoOrder_Logic(_Player):
	GameLogic.Order.call_NoOrder()
	UseAni.play("use")
	Audio_Order.play(0)
	OrderList.clear()
	_Player.call_pressure_set(2)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Order_Logic")
func call_Order_Logic(_Player):

	var _IDPLUS: int = 0
	if GameLogic.cur_Rewards.has("虚假单号"):
		if _Player.NoPress:
			_IDPLUS = 1
			GameLogic.call_Info(1, "虚假单号")
	var _TYPE: int = 0
	if GameLogic.cur_Rewards.has("消灾替身"):
		if _Player.HighPress:
			_TYPE = 1
	if GameLogic.cur_Event == "点单员":
		var _RAND = GameLogic.return_randi() % 100
		if _RAND < 25:
			_Player.call_pressure_set( - 1)
	elif GameLogic.cur_Event == "点单员+":
		var _RAND = GameLogic.return_randi() % 100
		if _RAND < 50:
			_Player.call_pressure_set( - 1)
	elif GameLogic.cur_Event == "点单员++":
		_Player.call_pressure_set( - 1)
	GameLogic.Order.call_order(_IDPLUS, _TYPE)
	UseAni.play("use")
	Audio_Order.play(0)
	OrderList.clear()

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_puppet_Order_Logic")
func call_puppet_Order_Logic():
	UseAni.play("use")
	Audio_Order.play(0)
	OrderList.clear()

func call_DevLogic_OrderTab(_ButID, _Player):

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
			if GameLogic.Order.cur_LineUpArray.size():



				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if not OrderList.has(_Player):
					OrderList.append(_Player)

				_Player.return_OrderAni(self)
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(_Player, "return_OrderAni", [self])
				return "点单"
			else:
				return "指挥点单"
		3:
			if not MenuUI.Show:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				Audio_Pop.play(0)
				UseAni.play("use")
				MenuUI.call_show(_Player.cur_Player)
				if _Player.name in [str(SteamLogic.STEAM_ID), "1", "2"]:
					_Player.call_control(4)
				But_Switch(true, _Player)
				return true
		10:
			if GameLogic.Order.cur_LineUpArray.size():
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if not OrderList.has(_Player):
					OrderList.append(_Player)

				_Player.return_NoOrderAni(self)
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(_Player, "return_OrderAni", [self])
				return "点单"

func call_Using():
	UseAni.play("using")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
