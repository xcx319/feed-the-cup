extends Node2D

var _TimeCheck: float = 0
var CanTake: bool
func _ready():
	call_init()
	set_physics_process(false)

func call_init():
	if not GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		get_parent().queue_free()
		return

	if not get_parent().SkillList.has("技能-加班狂"):
		get_parent().SkillList.append("技能-加班狂")
	get_parent().IsStaff = true
	get_parent().IsWork = true
	get_parent().get_node("Devil").call_HeadType("3")
	get_parent().get_node("Devil").hide()
	get_parent().cur_PressureMax = 100

func call_hide():
	get_node("Ani").play("hide")

func call_Devil_Hide():

	if get_node("MainAni").assigned_animation != "hide":
		get_node("MainAni").play("hide")
func call_Devil_show():
	if get_node("MainAni").assigned_animation != "show":
		get_node("MainAni").play("show")
func call_free():
	get_parent().queue_free()
func call_follow():

	if is_instance_valid(GameLogic.player_1P):
		get_parent().call_FollowPlayer(GameLogic.player_1P)
	get_parent().get_node("Devil").show()
	if GameLogic.cur_Day == 1:
		get_node("Ani").play("1_1_0")
	elif GameLogic.cur_Day == 3:
		call_Devil_show()
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.GamePlay.has("新手引导1"):
			if GameLogic.cur_Day == 3:
				get_node("Ani").play("Q料")
func call_OrderTab_Tutorial():
	GameLogic.Staff.OrderTab_OBJ.call_Tutorial()
func call_OpenStore():
	var _LEVELINFO = GameLogic.cur_levelInfo

	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day > 1:
			call_Devil_Hide()
			return
	get_node("Ani").play("1_1_1")
	GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)
func _physics_process(_delta: float) -> void :
	_TimeCheck += _delta
	if _TimeCheck > 1:
		_TimeChangeLogic()
		_TimeCheck = 0
func _TimeChangeLogic() -> void :
	if not GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		return
	var _LEVELINFO = GameLogic.cur_levelInfo

	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 2 and GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
			if get_node("Ani").assigned_animation != "1_1_5":
				get_node("Ani").play("1_1_5")
				return
		elif GameLogic.cur_Day == 3:
			if get_node("Ani").assigned_animation != "Q料":
				get_node("Ani").play("Q料")
				return
		if GameLogic.cur_Day == 1:
			if GameLogic.cur_SellNum == 1:

				if not GameLogic.Order.cur_LineUpArray.size() and not GameLogic.Order.cur_OrderList.size():

					if get_node("Ani").assigned_animation != "1_1_3":
						get_node("Ani").play("1_1_3")
						GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)
						return
			elif GameLogic.cur_SellNum == 2:
				if not GameLogic.Order.cur_LineUpArray.size() and not GameLogic.Order.cur_OrderList.size():

					if get_node("Ani").assigned_animation != "1_1_4":
						get_node("Ani").play("1_1_4")
				if GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
					GameLogic.GameUI.CurTime = GameLogic.cur_CloseTime

			if GameLogic.Order.return_Order_Check():

				if GameLogic.Tutorial.CheckList:

					for _Bottle in GameLogic.Tutorial.CheckList:
						if is_instance_valid(_Bottle):

							if _Bottle.Liquid_Count > 0:
								if get_node("Ani").assigned_animation != "橙汁制作出杯" and not CanTake:
									get_node("Ani").play("橙汁制作出杯")
									return
						else:
							GameLogic.Tutorial.CheckList.erase(_Bottle)
							if get_node("Ani").assigned_animation != "橙汁开盖":
								get_node("Ani").play("橙汁开盖")
								return
				else:
					if get_node("Ani").assigned_animation != "橙汁开盖":
						get_node("Ani").play("橙汁开盖")
						return

			if GameLogic.Order.cur_LineUpArray.size():
				if get_node("Ani").assigned_animation in ["1_1_1", "1_1_3"]:
					get_node("Ani").play("1_1_2")
			elif GameLogic.Order.cur_OrderList:
				var _LevelYSortNode = "YSort/Devices"
				if GameLogic.Staff.LevelNode.has_node(_LevelYSortNode):
					var _ItemYSort = GameLogic.Staff.LevelNode.get_node(_LevelYSortNode)
					for _Node in _ItemYSort.get_children():
						if _Node.TypeStr in ["WorkBench_Immovable", "WorkBench"]:
							if _Node.OnTableObj:
								var _CupHolder = _Node.OnTableObj
								if _CupHolder.TypeStr == "CupHolder":
									if _CupHolder.CanTake_bool:
										CanTake = true
									else:
										CanTake = false

									if _CupHolder.RunOut.assigned_animation != "init":
										if get_node("Ani").assigned_animation != "添加杯组":
											get_node("Ani").play("添加杯组")
											return
									elif CanTake:
										if get_node("Ani").assigned_animation != "取杯":
											get_node("Ani").play("取杯")
											return
									else:
										print("新手引导 不可取杯")
