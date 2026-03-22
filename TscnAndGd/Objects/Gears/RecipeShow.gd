extends Node2D

export var Audio_Bool: bool = true

var _Num: int
var _curAni
onready var aniPlayer = $AniNode / AnimationPlayer

onready var Audio_Open
onready var Audio_Close = null

onready var InfoNode = $TexNode / Info

var PopList: Array = [
	"可乐",
	"柠汽",
	"蓝汽",
	"薄汽",
	"荔汽",
	"柠可",
	"炸弹",
	"薄可",
	"醒脑",
	"蓝可",
	"变异",
	"荔可",
	"爱恋",
	"青柠蓝柑",
	"薄荷青柠",
	"荔枝蓝柑",
	"薄荷荔枝",
	]

var CurList: Array

func _ready() -> void :
	if has_node("Audio"):
		Audio_Open = get_node("Audio")
	else:
		Audio_Open = GameLogic.Audio.return_Effect("开门")
		Audio_Close = GameLogic.Audio.return_Effect("关门")
	if not GameLogic.is_connected("DayStart", self, "call_init"):
		var _CON = GameLogic.connect("DayStart", self, "call_init")

func call_init():

	CurList.clear()
	for _Node in InfoNode.get_children():
		_Node.hide()

	for _MenuName in GameLogic.cur_Menu:
		if GameLogic.Config.FormulaConfig.has(_MenuName):
			var _INFO = GameLogic.Config.FormulaConfig[_MenuName]
			var _ForNum: int = int(_INFO.FormulaNum)
			for _i in _ForNum:
				var _INFONAME: String = "For_" + str(_i + 1)
				var _FORNAME = _INFO[_INFONAME]
				if _FORNAME in PopList:
					if not CurList.has(_FORNAME):
						CurList.append(_FORNAME)
	for _NAME in CurList:
		if InfoNode.has_node(_NAME):
			InfoNode.get_node(_NAME).show()
	if CurList:
		if not CurList.size():
			$TexNode / NinePatchRect.rect_size = Vector2(300, 80 + 50 * CurList.size())
			$TexNode / NinePatchRect.rect_position = Vector2(50, - 86 + - 50 * CurList.size())
		else:
			$TexNode / NinePatchRect.rect_size = Vector2(300, 80 + 50 * (CurList.size() - 1))
			$TexNode / NinePatchRect.rect_position = Vector2(50, - 86 + - 50 * (CurList.size() - 1))
func _StaticLogic():

	if aniPlayer.has_animation("opentime"):
		aniPlayer.play("opentime")
func _on_player_entered(_body: Node) -> void :
	if not CurList:
		return
	if _Num == 0:
		aniPlayer.play("open")
		if Audio_Bool:
			Audio_Open.play(0)
			if Audio_Close != null:
				Audio_Close.stop()
	_Num += 1

func _on_player_exited(_body: Node) -> void :
	if not CurList:
		return
	_Num -= 1

	if _Num == 0:

		aniPlayer.play("close")

		if Audio_Bool:
			if Audio_Close != null:
				Audio_Close.play(0)
				Audio_Open.stop()

func _on_Timer_timeout() -> void :
	aniPlayer.play("close")
	if Audio_Bool:
		if Audio_Close != null:
			Audio_Close.play(0)
func AniCall_Closed():
	_curAni = "close"
