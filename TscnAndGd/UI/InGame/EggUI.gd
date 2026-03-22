extends CanvasLayer

onready var ANI = $AnimationPlayer
onready var _GRID = $Control / Info / Scroll / Grid
onready var EggBUT_TSCN = preload("res://TscnAndGd/Buttons/EggBut.tscn")
onready var Egg_TSCN = preload("res://TscnAndGd/Characters/EggMan.tscn")
onready var Group = preload("res://TscnAndGd/UI/Info/RewardInfo.tres")
var CurGroup
var _EGGKEY: Array

func call_DelBut():
	var _BUTLIST = _GRID.get_children()
	for _BUT in _BUTLIST:
		_BUT.queue_free()
func call_init():
	if not CurGroup:
		CurGroup = Group
	call_DelBut()
	if not GameLogic.Save.gameData.has("EggDIC"):
		GameLogic.Save.gameData["EggDIC"] = {}
	_EGGKEY = GameLogic.Save.gameData["EggDIC"].keys()

	var _CURNUM: int = 0
	for _EGGID in _EGGKEY:
		var _EGGBUT = EggBUT_TSCN.instance()
		var _EGG = Egg_TSCN.instance()
		_EGG.SHOWBOOL = true
		_EGG.ID = _EGGID
		var _NUM = GameLogic.Save.gameData["EggDIC"][_EGGID]
		_EGGBUT.ID = _EGGID
		_EGGBUT.EGGNUM = _NUM
		_GRID.add_child(_EGGBUT)

		_EGGBUT.EggPoint.add_child(_EGG)

		if _CURNUM == 0:
			_EGGBUT.pressed = true
			_CURNUM += 1
		_EGGBUT.connect("focus_entered", self, "call_Info")



func call_show():
	call_init()
	if ANI.assigned_animation != "show":
		ANI.play("show")


onready var CURINFO = $Control / CurInfo



func _on_BackBut_pressed():
	if ANI.assigned_animation != "init":
		ANI.play("init")

func call_Info(_ID):
	CURINFO._IDSet(_ID)
