extends Node2D

var _TimeCheck: float = 0

func _CheckLogic():

	if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.GamePlay.has("新手引导1"):
			if GameLogic.cur_Day > 1:
				if GameLogic.GameUI.CurTime > GameLogic.cur_OpenTime:
					_SugarCheck()
				elif GameLogic.GameUI.Is_Open:
					_SugarCheck()

func _SugarCheck():

	var _LevelYSortNode = "YSort/Devices"
	if GameLogic.Staff.LevelNode.has_node(_LevelYSortNode):
		var _ItemYSort = GameLogic.Staff.LevelNode.get_node(_LevelYSortNode)
		for _Node in _ItemYSort.get_children():
			if _Node.TypeStr in ["WorkBench_Immovable", "WorkBench"]:
				if _Node.OnTableObj:
					var _CupHolder = _Node.OnTableObj
					if _CupHolder.TypeStr == "SugarMachine":

						if _CupHolder.cur_sugar == 0:

							if get_node("Ani").assigned_animation != "show":
								get_node("Ani").play("show")
								return

						elif get_node("Ani").assigned_animation == "show":
								get_node("Ani").play("hide")
								return

func _physics_process(_delta: float) -> void :
	_TimeCheck += _delta
	if _TimeCheck > 1:
		_CheckLogic()
		_TimeCheck = 0
