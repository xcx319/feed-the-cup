extends Head_Object

onready var CupTypeAni = get_node("CupTypeAni")
onready var CupAni = get_node("CupAni")
var Num

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :
	IsItem = true
	Weight = 1
	Num = 10
	call_Collision_set()
func call_bag_tex_set():
	call_CupType_Set()
func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	call_CupType_Set()
	IsItem = true
	Weight = 1
	Num = 10
	.call_Ins_Save(_SELFID)
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	if not TypeStr:
		call_init(_Info.TSCN)
	call_CupType_Set()
	IsItem = true
	Weight = 1
	Num = 10

func call_CupType_Set():
	CupTypeAni.play(FuncTypePara)

func call_Put_Ani():
	CupAni.play("in")
func _on_body_entered(body: Node) -> void :

	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
func call_Collision_set():
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)

func call_Info_Switch(_Switch: bool):
	match _Switch:
		true:
			$Icon.show()
		false:
			$Icon.hide()
