extends CanvasModulate

var Weather

var _A: int
var _color: Color

func _ready() -> void :
	GameLogic.GameUI.connect("TimeChange", self, "_DayLight_Set")
	var _OPCON = GameLogic.connect("OPTIONSYNC", self, "_LightNode_Logic")

func _LightNode_Logic():
	if get_tree().get_root().has_node("Level/LightNode"):
		if GameLogic.GlobalData.globalini.NightSwitch:
			get_tree().get_root().get_node("Level/LightNode").show()
		else:
			get_tree().get_root().get_node("Level/LightNode").hide()
func _DayLight_Set():
	if not bool(GameLogic.GlobalData.globalini.NightSwitch):
		if get_node("Ani").assigned_animation != "init":
			get_node("Ani").play("init")
		return
	var _Time = GameLogic.GameUI.CurTime
	if _Time > 9 and _Time < 18:
		if has_node("Ani"):
			if get_node("Ani").assigned_animation != "init":
				get_node("Ani").play("init")

	elif _Time > 18:
		if has_node("Ani"):
			if get_node("Ani").assigned_animation != "show":
				get_node("Ani").play("show")
				_LightNode_Logic()
