extends Control

var cur_Used: bool = false
var cur_pressed: bool

func call_init():
	if get_node("Ani").assigned_animation == "show":
		get_node("Ani").play("hide")

func call_AllHide():
	for _NODE in get_node("BG").get_children():
		_NODE.hide()

func call_Ani_end():
	cur_Used = true
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.connect("P2_Control", self, "_control_logic")

func call_ShowLogic(_Name: String):
	call_AllHide()
	var BG = get_node("BG")
	if BG.has_node(_Name):
		BG.get_node(_Name).show()
		if get_node("Ani").assigned_animation != "show":
			get_node("Ani").play("show")
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		call_hide()

func call_hide_puppet():
	GameLogic.Audio.But_Apply.play(0)
	get_node("Ani").play("hide")
	cur_Used = false
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
func call_hide():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	GameLogic.Audio.But_Apply.play(0)
	if get_node("Ani").assigned_animation == "show":
		get_node("Ani").play("hide")
		cur_Used = false
	if not GameLogic.LoadingUI.IsLevel:
		return

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_hide_puppet")
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _checkP1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _checkP2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	if GameLogic.Staff.LevelNode.has_method("_LEVELSTAT_LOGIC"):
		GameLogic.Staff.LevelNode._LEVELSTAT_LOGIC(1)


func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value != 1 and _value != - 1:
		cur_pressed = false
	match _but:
		"A", "B":
			if _value == 1 or _value == - 1:

				call_hide()

	if _type == 0:
		cur_pressed = false

func return_TutorialCheck():
	var _LEVEL = GameLogic.cur_level
	var _DAY = GameLogic.cur_Day
	var _DEVIL = GameLogic.cur_Devil
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_LEVEL = SteamLogic.LevelDic.Level

		_DEVIL = SteamLogic.LevelDic.Devil
	match _LEVEL:
		"新手引导第一关":
			match _DAY:
				1:
					call_ShowLogic("111-D1")
					return true
				2:
					call_ShowLogic("111-D2")
					return true
				3:
					call_ShowLogic("111-D3")
					return true
				4:
					call_ShowLogic("111-D4")
					return true
				5:
					call_ShowLogic("111-D5")
					return true
		"社区店1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("121-D1")
							return true
						1:
							call_ShowLogic("ND-中杯")
							return true
						2:
							call_ShowLogic("ND-客流")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("121-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("121-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("121-D4")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("121-D5")
							return true
				6:
					match _DEVIL:
						0:
							call_ShowLogic("121-D6")
							return true
				7:
					match _DEVIL:
						0:
							call_ShowLogic("121-D7")
							return true
		"社区店2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("131-D1")
							return true
						1:
							call_ShowLogic("132-D1")
							return true
						2:
							call_ShowLogic("ND-混混")
							return true
						3:
							call_ShowLogic("ND-每日随机高峰期")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("131-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("131-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("131-D4")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("131-D5")
							return true
				7:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true

		"社区店3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("141-D1")
							return true
						1:
							call_ShowLogic("ND-英式茶杯顾客")
							return true
						2:
							call_ShowLogic("ND-初始星级")
							return true
						3:
							call_ShowLogic("ND-客流")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("141-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("141-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("141-D4")
							return true
				7:
					match _DEVIL:
						0:
							call_ShowLogic("ND-大杯")
							return true
		"美食街1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("211-D1")
							return true
						1:
							call_ShowLogic("ND-污渍水渍")
							return true
						2:
							call_ShowLogic("ND-英式茶杯顾客")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("211-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("211-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("211-D4")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("211-D5")
							return true
		"美食街2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("221-D1")
							return true
						1:
							call_ShowLogic("ND-批评家")
							return true
						2:
							call_ShowLogic("ND-每日随机高峰期")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("221-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("221-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("221-D4")
							return true
		"美食街3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("231-D1")
							return true
						1:
							call_ShowLogic("ND-污渍水渍")
							return true
						2:
							call_ShowLogic("ND-批评家")
							return true
						3:
							call_ShowLogic("ND-探店客")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("231-D2")
							return true
				6:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"美食街4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("241-D1")
							return true
						1:
							call_ShowLogic("ND-设备故障")
							return true
						2:
							call_ShowLogic("ND-初始星级")
							return true
						3:
							call_ShowLogic("ND-混混")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("241-D2")
							return true

				6:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"写字楼1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("311-D1")
							return true
						1:
							call_ShowLogic("ND-污渍水渍")
							return true
						2:
							call_ShowLogic("ND-每日随机停电")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("311-D2")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("311-D4")
							return true
		"写字楼2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("321-D1")
							return true
						1:
							call_ShowLogic("ND-日式茶杯顾客")
							return true
						2:
							call_ShowLogic("ND-每日随机高峰期")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("321-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("321-D3")
							return true
				6:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"写字楼3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("331-D1")
							return true
						1:
							call_ShowLogic("ND-日式茶杯顾客Seat")
							return true
						2:
							call_ShowLogic("ND-每日随机停电")
							return true
						3:
							call_ShowLogic("ND-探店客")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("331-D2")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"写字楼4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("341-D1")
							return true
						1:
							call_ShowLogic("ND-学咖族")
							return true
						2:
							call_ShowLogic("ND-设备故障")
							return true
						3:
							call_ShowLogic("ND-混混Seat")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("341-D2")
							return true

				4:
					match _DEVIL:
						0:
							call_ShowLogic("341-D4")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"公园1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("411-D1")
							return true
						1:
							call_ShowLogic("ND-订单遮挡")
							return true
						2:
							call_ShowLogic("ND-英式茶杯顾客")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("411-D2")
							return true

				4:
					match _DEVIL:
						0:
							call_ShowLogic("411-D4")
							return true
		"公园2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("421-D1")
							return true
						1:
							call_ShowLogic("ND-小偷")
							return true
						2:
							call_ShowLogic("ND-批评家")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("421-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("421-D3")
							return true

				6:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"公园3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("431-D1")
							return true
						1:
							call_ShowLogic("ND-双耳茶杯顾客")
							return true
						2:
							call_ShowLogic("ND-学咖族")
							return true
						3:
							call_ShowLogic("ND-污渍水渍")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("431-D2")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"公园4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("441-D1")
							return true
						1:
							call_ShowLogic("ND-厕所")
							return true
						2:
							call_ShowLogic("ND-设备故障")
							return true
						3:
							call_ShowLogic("ND-日式茶杯顾客Seat")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("441-D2")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("ND-点单服务")
							return true
		"体育场1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("511-D1")
							return true
						1:
							call_ShowLogic("ND-玻璃瓶顾客")
							return true
						2:
							call_ShowLogic("ND-厕所")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("511-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("511-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("511-D4")
							return true
		"体育场2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("521-D1")
							return true
						1:
							call_ShowLogic("ND-跑圈")
							return true
						2:
							call_ShowLogic("ND-学咖族")

				2:
					match _DEVIL:
						0:
							call_ShowLogic("521-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("521-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("521-D4")
							return true
		"体育场3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("531-D1")
							return true
						1:
							call_ShowLogic("ND-棒球")
							return true
						2:
							call_ShowLogic("ND-玻璃瓶顾客2")
							return true
						3:
							call_ShowLogic("ND-混混")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("531-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("531-D3")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("531-D5")
							return true
		"体育场4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("541-D1")
							return true
						1:
							call_ShowLogic("ND-菜单上限汽水")
							return true
						2:
							call_ShowLogic("ND-耀眼光线")
							return true
						3:
							call_ShowLogic("ND-探店客")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("541-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("541-D3")
							return true

		"古街1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("611-D1")
							return true
						1:
							call_ShowLogic("ND-检查员")
							return true
						2:
							call_ShowLogic("ND-双耳茶杯顾客")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("611-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("611-D3")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("611-D5")
							return true
		"古街2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("621-D1")
							return true
						1:
							call_ShowLogic("ND-虫虫")
							return true
						2:
							call_ShowLogic("ND-学咖族")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("621-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("621-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("621-D4")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("621-D5")
							return true
		"古街3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("631-D1")
							return true
						1:
							call_ShowLogic("ND-扫雪")
							return true
						2:
							call_ShowLogic("ND-初始星级")
							return true
						3:
							call_ShowLogic("ND-菜单上限")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("631-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("631-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("631-D4")
							return true
		"古街4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("641-D1")
							return true
						1:
							call_ShowLogic("ND-大瓶顾客")
							return true
						2:
							call_ShowLogic("ND-双耳茶杯顾客")
							return true
						3:
							call_ShowLogic("ND-检查员")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("641-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("641-D3")
							return true

		"游乐园1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("711-D1")
							return true
						1:
							call_ShowLogic("ND-插队客")
							return true
						2:
							call_ShowLogic("ND-每日随机停电")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("711-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("711-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("711-D4")
							return true
		"游乐园2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("721-D1")
							return true
						1:
							call_ShowLogic("ND-小火车")
							return true
						2:
							call_ShowLogic("ND-随机日")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("721-D2")
							return true

				4:
					match _DEVIL:
						0:
							call_ShowLogic("721-D4")
							return true
		"游乐园3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("731-D1")
							return true
						1:
							call_ShowLogic("ND-流浪杯")
							return true
						2:
							call_ShowLogic("ND-日式茶杯顾客Seat")
							return true
						3:
							call_ShowLogic("ND-菜单上限")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("731-D2")
							return true

				4:
					match _DEVIL:
						0:
							call_ShowLogic("731-D4")
							return true
		"游乐园4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("741-D1")
							return true
						1:
							call_ShowLogic("ND-插队客")
							return true
						2:
							call_ShowLogic("ND-双选小料")
							return true
						3:
							call_ShowLogic("ND-捡垃圾")
							return true
				2:
					match _DEVIL:
						0:
							call_ShowLogic("741-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("741-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("741-D4")
							return true
				5:
					match _DEVIL:
						0:
							call_ShowLogic("741-D5")
							return true
				7:
					match _DEVIL:
						0:
							call_ShowLogic("741-D7")
							return true
		"酒吧1":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("811-D1")
							return true
						1:
							call_ShowLogic("ND-啤酒泡")
							return true
						2:
							call_ShowLogic("ND-菜单上限")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("811-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("811-D3")
							return true
				4:
					match _DEVIL:
						0:
							call_ShowLogic("811-D4")
							return true
		"酒吧2":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("821-D1")
							return true
						1:
							call_ShowLogic("ND-啤酒泡")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("821-D2")
							return true
				3:
					match _DEVIL:
						0:
							call_ShowLogic("821-D3")
							return true

		"酒吧3":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("831-D1")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("831-D2")
							return true

		"酒吧4":
			match _DAY:
				1:
					match _DEVIL:
						0:
							call_ShowLogic("841-D1")
							return true

				2:
					match _DEVIL:
						0:
							call_ShowLogic("841-D2")
							return true

	return false
