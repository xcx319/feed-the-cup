extends Head_Object

var DevName: String

var CanOpen: bool
var IsOpen: bool
var Assemble: int
var Table: int
var Is_Ass: bool

var CanPass: bool = false
var DevOBJ

onready var DevNode = get_node("DevNode")

onready var BoxAni = get_node("AniNode/BoxAni")

onready var EffectAni = get_node("Effect_Device/AnimationPlayer")

onready var SettingAni = get_node("AniNode/SettingAni")

onready var A_But = get_node("But/A")
onready var X_But = get_node("But/X")
onready var Y_But = get_node("But/Y")
func call_new():
	CanPass = true
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("Label/Ani").play("New")
	get_node("Label/Timer").start(0)
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if CanOpen:
		X_But.show()
		Y_But.hide()
	else:
		X_But.hide()
	var _Node = get_parent().get_parent()
	if _Node.has_method("call_OnTable"):
		if Table == 0 and _Node.SelfDev == "WorkBench":
			Y_But.show()
		elif Table > 0 and _Node.SelfDev == "WorkBench_Immovable":
			Y_But.show()
		else:
			Y_But.hide()
	.But_Switch(_bool, _Player)

	pass

func _ready() -> void :
	IsItem = true
	call_init("Box_Wood")

func call_Collision_set():
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
func call_load(_info):

	_SELFID = int(_info.NAME)
	self.name = _info.NAME
	var Info = null
	if _info.has("DevObj"):
		Info = _info.DevObj
	if _info.has("DevOBJ"):
		Info = _info.DevOBJ
	if Info != null:
		var _DevName = Info.TSCN

		call_create(_DevName)
	call_Collision_set()

func call_create_num(_devName, _Num):
	DevName = _devName

func call_create(_devName):
	DevName = _devName
	_ItemInBox_Create()


func _ItemInBox_Create():
	var _DevName
	match DevName:

		_:
			_DevName = DevName
	var _TSCN = GameLogic.TSCNLoad.return_TSCN(_DevName)
	var _Obj = _TSCN.instance()
	DevOBJ = _Obj

	DevNode.add_child(_Obj)


	if not GameLogic.Config.DeviceConfig.has(_DevName):
		print("箱子生成设备错误。无对应设备")
		return
	if GameLogic.Config.DeviceConfig[_DevName].CanMove:

		CanOpen = true
	else:
		Assemble = int(GameLogic.Config.DeviceConfig[_DevName].Assemble)

	Table = int(GameLogic.Config.DeviceConfig[_DevName].Table)
func call_pickup_by(_Player, _BoxObj):

	_Player.Con.NeedPush = true
	.call_pickup_by(_Player, _BoxObj)
	pass

func call_But_Logic(_ButID, _Player):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if not IsOpen:
				But_Switch(true, _Player)
		2:
			if CanOpen and not IsOpen:
				call_Collision_Switch(false)
				CanOpen = false
				BoxAni.play("open")
		3:
			if not IsOpen:
				var _Node = get_parent().get_parent()
				if _Node.has_method("call_OnTable"):
					if Table == 0 and _Node.SelfDev == "WorkBench":
						_Assemble_Logic()
					elif Table > 0 and _Node.SelfDev == "WorkBench_Immovable":
						_Assemble_Logic()
func _Assemble_Logic():
	if Is_Ass:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_1)

		BoxAni.play("hide")
		SettingAni.play("RESET")
	else:
		Y_But.InfoLabel.text = GameLogic.CardTrans.get_message(Y_But.Info_2)


		BoxAni.play("set")
		SettingAni.play("set")
	Is_Ass = not Is_Ass

func call_OpenBox():
	if IsOpen:
		return
	IsOpen = true
	IsItem = false
	CanMove = false
	CanPick = false
	var _Node = get_parent().get_parent()
	DevNode.remove_child(DevOBJ)
	var _Parent = get_parent()
	if _Parent.name == "ObjNode":
		DevOBJ.position = Vector2.ZERO
		_Node.OnTableObj = DevOBJ
	elif _Parent.name == "Items" or _Parent.name == "Devices":
		DevOBJ.position = self.position
	self.get_parent().add_child(DevOBJ)

	DevOBJ._collision_check()

	self.queue_free()
func call_set_finished():

	pass


func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
