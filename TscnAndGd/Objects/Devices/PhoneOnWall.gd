extends Head_Object

var cur_player
var cur_usedID: int

onready var A_But = get_node("But/Y")
onready var B_But = get_node("But/B")

onready var TutorialAni = get_node("Tutorial/Ani")

onready var Audio_Call

var _ProcessCount: float
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :
	Audio_Call = GameLogic.Audio.return_Effect("打电话")

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
func _physics_process(_delta):
	_ProcessCount += _delta

	if _ProcessCount >= 5:
		_ProcessCount = 0
		_ItemCheck()
func _ItemCheck():

	if not GameLogic.Tutorial.Tutorial_Bool:
		return

	var _Sell_Array: Array
	for _Item in GameLogic.Buy.Sell_1:
		_Sell_Array.append(_Item)
	for _Item in GameLogic.Buy.Sell_2:
		match _Item:
			"DrinkCup_S":
				_Sell_Array.append("DrinkCup_Group_S")
			"DrinkCup_M":
				_Sell_Array.append("DrinkCup_Group_M")
			"DrinkCup_L":
				_Sell_Array.append("DrinkCup_Group_L")
			_:
				_Sell_Array.append(_Item)

	for _Item in _Sell_Array:
		if not GameLogic.Config.ItemConfig.has(_Item):
			continue

		if not GameLogic.cur_Item_List.has(_Item):

			_Buy_Check(_Item)
			return
		else:
			var _Num = int(GameLogic.cur_Item_List[_Item])
			if _Num == 0:
				_Buy_Check(_Item)
				return
	_TutorialShow_Logic(false)
func _Buy_Check(_Item):

	var _Tutorial: bool = true
	if not GameLogic.Buy.buy_Array:
		_Tutorial = true
	else:
		for _Array in GameLogic.Buy.buy_Array:
			var _Dic = _Array[1]
			var _Keys = _Dic.keys()

			if _Keys[0] == _Item:
				_Tutorial = false
	_TutorialShow_Logic(_Tutorial)
func _TutorialShow_Logic(_Switch):
	match _Switch:
		true:
			GameLogic.call_pressure("NoInventory")
			if TutorialAni.assigned_animation != "show":
				TutorialAni.play("show")
		false:
			if TutorialAni.assigned_animation != "init":
				TutorialAni.play("init")
func But_Switch(_bool, _Player):
	if not GameLogic.GameUI.OrderNode.cur_used:
		A_But.show()
		B_But.hide()
	else:
		A_But.hide()
		B_But.show()
	.But_Switch(_bool, _Player)

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if not SteamLogic.IsMultiplay:
				if not cur_player:
					cur_player = _Player
					cur_usedID = _Player.cur_Player

			But_Switch(true, _Player)
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if not SteamLogic.IsMultiplay:

				if cur_usedID == _Player.cur_Player:
					cur_usedID = 0

			But_Switch(false, _Player)
		3, "Y":

			if not cur_usedID in [SteamLogic.STEAM_ID, 0, 1, 2]:
				return
			if SteamLogic.IsMultiplay and _Player.name != str(SteamLogic.STEAM_ID):
				return
			if GameLogic.GameUI.DayEnd:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			match GameLogic.GameUI.OrderNode.cur_used:
				false:
					Audio_Call.play(0)
					GameLogic.GameUI.OrderAni.play("show")
					GameLogic.GameUI.OrderNode.call_by_player(_Player)

					cur_player = _Player
					GameLogic.Can_ESC = false
					_Player.call_control(3)
					if not GameLogic.GameUI.OrderNode.is_connected("CallClose", self, "call_Close_logic"):
						var _CON = GameLogic.GameUI.OrderNode.connect("CallClose", self, "call_Close_logic")
			But_Switch(true, _Player)
			return true

func call_Close_logic():
	But_Switch(true, cur_player)
	if GameLogic.GameUI.OrderNode.is_connected("CallClose", self, "call_Close_logic"):
		var _CON = GameLogic.GameUI.OrderNode.disconnect("CallClose", self, "call_Close_logic")

	cur_player = null
	yield(get_tree().create_timer(0.1), "timeout")
	GameLogic.Can_ESC = true
