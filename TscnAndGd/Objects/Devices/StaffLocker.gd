extends Head_Object

var cur_player
var cur_used: bool

onready var A_But = get_node("But/A")
onready var B_But = get_node("But/B")

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :
	call_deferred("call_StaffLocker_init")
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
func call_StaffLocker_init():
	Update_Check()
	GameLogic.Staff.call_StaffLocker_init(self)
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
func Update_Check():
	var _Max = 2
	if GameLogic.cur_Rewards.has("员工柜升级"):
		_Max += 2
		get_node("AniNode/Upgrade").play("2")
	if GameLogic.cur_Rewards.has("员工柜升级+"):
		_Max += 2
		get_node("AniNode/Upgrade").play("3")
	else:
		get_node("AniNode/Upgrade").play("1")
	GameLogic.Staff.Staff_Max = _Max

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if not GameLogic.GameUI.OrderNode.cur_used:
		A_But.show()
		B_But.hide()
	else:
		A_But.hide()
		B_But.show()
	.But_Switch(_bool, _Player)
