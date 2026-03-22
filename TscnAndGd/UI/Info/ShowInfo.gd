extends Control

onready var ShowInfoLabel = preload("res://TscnAndGd/UI/Info/ShowInfoLabel.tscn")
onready var OrderInfoLabel = preload("res://TscnAndGd/UI/Info/OrderInfoLabel.tscn")
onready var VBox = get_node("VBoxContainer")

func _ready() -> void :
	call_deferred("call_init")

func call_init():
	if not GameLogic.is_connected("NewInfo", self, "call_NewInfo"):
		var _Con = GameLogic.connect("NewInfo", self, "call_NewInfo")
		var _NetCon = GameLogic.connect("NewNetInfo", self, "call_NetInfo")
		var _BuyCon = GameLogic.Buy.connect("BuyNew", self, "call_NewBuyInfo")
	call_del()
func call_del():
	var _List = VBox.get_children()
	for i in _List.size():
		var _Node = _List[i]
		VBox.remove_child(_Node)
		_Node.queue_free()
func call_NetInfo(_Type: int, _Info: String, _SteamID):
	var NewInfo = ShowInfoLabel.instance()
	VBox.add_child(NewInfo)
	NewInfo.call_net(str(_Type), _Info, _SteamID)
func call_NewInfo(_Type: int, _Info: String, _Num = null, _MaxBool: bool = false):

	var _STR = ""
	if _Num != null:
		_STR = str(_Num)
	match _Type:
		1:
			var NewInfo = ShowInfoLabel.instance()
			VBox.add_child(NewInfo)
			NewInfo.call_init(str(_Type), _Info, _STR, _MaxBool)
			pass
		2:
			var NewInfo = ShowInfoLabel.instance()
			VBox.add_child(NewInfo)
			NewInfo.call_init(str(_Type), _Info, _STR, _MaxBool)
			pass
		3:
			var NewInfo = OrderInfoLabel.instance()
			VBox.add_child(NewInfo)
			NewInfo.call_init(str(_Type), _Info, _STR, _MaxBool)
			pass

func call_NewBuyInfo(_Type, _Time):
	var NewInfo = OrderInfoLabel.instance()
	VBox.add_child(NewInfo)
	NewInfo.call_init(str(_Type), _Time)
