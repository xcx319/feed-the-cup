extends StaticBody2D

var _OpenTime: int = 19
var _CloseTime: int = 6

onready var LampAni = get_node("Aninode/LampAni")
var _delay: int
var cur_delay: int = 0
var OpenBool: bool
func _ready() -> void :

	set_process(false)
	_delay = GameLogic.return_RANDOM() % 100

	var _OpenCon = GameLogic.connect("OpenLight", self, "_OpenLightLogic")
	var _CloseCon = GameLogic.connect("DayStart", self, "_Light_Init")
func _OpenLightLogic():
	_OpenTime = GameLogic.GameUI.CurTime
	_Logic()
func _Light_Init():
	set_process(false)
	if LampAni.assigned_animation != "close":
		LampAni.play("close")

	OpenBool = false
func call_notouch():
	pass
func _Logic():

	if not bool(GameLogic.GlobalData.globalini.NightSwitch):
		return
	if GameLogic.GameUI.CurTime > _OpenTime or GameLogic.GameUI.CurTime < _CloseTime:

		if not OpenBool:
			set_process(true)

			OpenBool = true
	else:
		if LampAni.assigned_animation != "close":
			LampAni.play("close")
			OpenBool = false
func call_LampOpen():
	if LampAni.assigned_animation != "open":
		LampAni.play("open")

func _process(_delta):
	if cur_delay >= _delay:
		call_LampOpen()
		set_process(false)
	else:
		cur_delay += int(_delta * 100)
