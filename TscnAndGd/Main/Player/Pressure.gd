extends Node2D

var cur_Pressure: int = 0
var cur_PressureMax: int
var Old_Pressure: int
var _time: float

onready var PrePro = get_node("TextureProgress")
onready var MaxLabel = PrePro.get_node("Label/Max")
onready var CurLabel = PrePro.get_node("Label/Cur")
onready var PreAni = get_node("PreAni")
onready var PreProAni = get_node("PreProAni")
onready var PreTimer = get_node("Timer")

func _ready() -> void :
	var _OPCON = GameLogic.connect("OPTIONSYNC", self, "_StressShow_Logic")

func call_PressurePro_Set(_cur: int, _Max: int, _NoPress: bool = false, _HasPress: bool = false, _HighPress: bool = false):
	PrePro.max_value = _Max
	MaxLabel.text = str(_Max)
	PrePro.value = _cur
	CurLabel.text = str(_cur)
	if GameLogic.LoadingUI.IsHome:
		return


	if _cur >= _Max:
		PreAni.play("full")
	elif _HighPress:
		PreAni.play("high")
	elif _NoPress:
		PreAni.play("none")
	else:
		PreAni.play("normal")
	PreProAni.play("show")

	_StressShow_Logic()
func _StressShow_Logic():

	if not GameLogic.GlobalData.globalini.has("StressShowType"):
		GameLogic.GlobalData.globalini.StressShowType = 0
	match GameLogic.GlobalData.globalini.StressShowType:
		0:
			PreTimer.start(0)
		_:
			PreTimer.stop()
			if GameLogic.LoadingUI.IsLevel:
				if PreProAni.assigned_animation != "show":
					PreProAni.play("show")

func _on_Timer_timeout() -> void :
	if PreProAni.assigned_animation in ["show"]:
		PreProAni.play("hide")
