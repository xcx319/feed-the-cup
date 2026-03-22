extends Control

var _TimeCheck: float = 0
var CanTake: bool = true

var _DrinkCupCheck: bool
var LearnSugar: bool
var LearnAddIn: bool

onready var InfoLabel = get_node("Main/Info/Label")
onready var Ani = get_node("Ani")

func _ready():

	set_physics_process(false)
	call_deferred("_connect_init")
func _connect_init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.is_connected("DayStart", self, "_Day_Start"):
		var _con = GameLogic.connect("DayStart", self, "_Day_Start")
	if not GameLogic.is_connected("OpenStore", self, "call_OpenStore"):
		var _con = GameLogic.connect("OpenStore", self, "call_OpenStore")
	if not GameLogic.is_connected("CloseLight", self, "call_hide"):
		var _con = GameLogic.connect("CloseLight", self, "call_hide")
	if not GameLogic.Tutorial.is_connected("AddSugar", self, "_AddSugar_Check"):
		var _con = GameLogic.Tutorial.connect("AddSugar", self, "_AddSugar_Check")
	if not GameLogic.Tutorial.is_connected("AddIn", self, "_AddIn_Check"):
		var _con = GameLogic.Tutorial.connect("AddIn", self, "_AddIn_Check")
func call_NewDifficult():

	set_physics_process(false)
	if GameLogic.cur_level == "":
		if Ani.assigned_animation != "选择新难度":
			Ani.play("选择新难度")
func call_TutorialFinished():

	set_physics_process(false)
	if GameLogic.Save.gameData["HomeUpdate"] == 0:
		if GameLogic.Save.gameData.HomeDevList.has("书架"):
			if GameLogic.cur_level == "":
				if Ani.assigned_animation != "选择新关卡":
					Ani.play("选择新关卡")
func _AddIn_Check():
	if not LearnAddIn:
		if Ani.assigned_animation == "橙汁加料":
			LearnAddIn = true
			if not LearnSugar:

				pass
			else:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
				Ani.play("hide")
func _AddSugar_Check():
	if not LearnSugar:
		if Ani.assigned_animation == "橙汁加糖":
			LearnSugar = true
			if not LearnAddIn:
				if GameLogic.cur_Day == 3:
					if Ani.assigned_animation != "橙汁加料":
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["橙汁加料"])
						Ani.play("橙汁加料")
			else:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
				Ani.play("hide")


func call_init():
	pass
func call_Switch(_Switch: bool):

	match _Switch:
		true:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["init"])
			Ani.play("init")

		false:
			set_physics_process(false)
			if Ani.assigned_animation == "hide":
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["init"])
				Ani.play("init")
			elif not Ani.assigned_animation in ["hide", "init"]:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
				Ani.play("hide")
func call_hide():

	if not Ani.assigned_animation in ["init", "hide"]:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
		Ani.play("hide")
	set_physics_process(false)

func call_free():
	get_parent().queue_free()
func call_puppet_show(_NAME: String):
	Ani.play(_NAME)
func _Day_Start():
	if GameLogic.cur_Day == 2:
		LearnSugar = false

	set_physics_process(true)

	var _LEVELINFO = GameLogic.cur_levelInfo

	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 1:

			Ani.play("教学关卡初始")
		if GameLogic.cur_Day == 2 and GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime and not GameLogic.GameUI.Is_Open:
			if Ani.assigned_animation in ["init", "hide"]:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["时间概念"])
				Ani.play("时间概念")
				return
		if GameLogic.cur_Day == 3 and GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime and not GameLogic.GameUI.Is_Open:
			if Ani.assigned_animation != "代价":
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["代价"])
				Ani.play("代价")
				return
		if GameLogic.cur_Day == 4 and GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime and not GameLogic.GameUI.Is_Open:
			if Ani.assigned_animation != "介绍手册人":
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["介绍手册人"])
				Ani.play("介绍手册人")
				return
		if GameLogic.cur_Day == 5 and GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime and not GameLogic.GameUI.Is_Open:
			if Ani.assigned_animation != "契约":
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["契约"])
				Ani.play("契约")
				return
		_ItemCheck()

func call_OrderTab_Tutorial():
	GameLogic.Staff.OrderTab_OBJ.call_Tutorial()
func call_OpenStore():
	var _LEVELINFO = GameLogic.cur_levelInfo

	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day in [2, 3, 4, 5, 6, 7]:
			if not Ani.assigned_animation in ["init", "hide"]:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
				Ani.play("hide")
	if _LEVELINFO.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day == 1:
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["等待顾客"])
			Ani.play("等待顾客")
			GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)
func _physics_process(_delta: float) -> void :
	_TimeCheck += _delta
	if _TimeCheck > 1:
		_TimeChangeLogic()
		_OrderCheckLogic()
		_SugarCheckLogic()

		_TimeCheck = 0
func _TimeChangeLogic() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["init"])
		Ani.play("init")
		return
	var _LEVELINFO = GameLogic.cur_levelInfo

	if _LEVELINFO.GamePlay.has("新手引导1"):

		if GameLogic.cur_Day == 5:
			if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:
				if not Ani.assigned_animation in ["周期结束", "订货罐头", "订货罐头补救", "订货橙汁", "订货杯子", "订货糖"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["周期结束"])
					Ani.play("周期结束")
		elif GameLogic.cur_Day == 4:
			if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:
				if not Ani.assigned_animation in ["恶魔能力"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["恶魔能力"])
					Ani.play("恶魔能力")
		elif GameLogic.cur_Day == 3:
			if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:
				if not Ani.assigned_animation in ["资金管理", "橙汁加料", "订货罐头", "订货罐头补救", "订货橙汁", "订货杯子", "订货糖"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["资金管理"])
					Ani.play("资金管理")
		elif GameLogic.cur_Day == 2:
			_ItemCheck()
			if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime:
				if Ani.assigned_animation in ["init", "hide"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["加班提示"])
					Ani.play("加班提示")
		elif GameLogic.cur_Day == 1:
			if GameLogic.cur_SellNum == 1:

				if not GameLogic.Order.cur_LineUpArray.size() and not GameLogic.Order.cur_OrderList.size():

					if Ani.assigned_animation != "卖出第一杯":
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["卖出第一杯"])
						Ani.play("卖出第一杯")
						GameLogic.NPC.call_customer(GameLogic.HomeMoneyKey)
						return

			elif GameLogic.cur_SellNum == 2:
				if not GameLogic.Order.cur_LineUpArray.size() and not GameLogic.Order.cur_OrderList.size():

					if GameLogic.GameUI.Is_Open:
						if Ani.assigned_animation != "关店":
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["关店"])
							Ani.play("关店")
				if GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
					GameLogic.GameUI.CurTime = GameLogic.cur_CloseTime

			if GameLogic.Order.cur_LineUpArray.size():
				if Ani.assigned_animation in ["等待顾客", "卖出第一杯"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["进行点单"])
					Ani.play("进行点单")
					GameLogic.Tutorial.NeedSell = false
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
										if Ani.assigned_animation != "添加杯组":
											if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
												SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["添加杯组"])
											Ani.play("添加杯组")
										return
									elif CanTake:
										if _CupHolder._Cur_ID == 2:
											if Ani.assigned_animation != "取杯2":
												if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
													SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["取杯2"])
												Ani.play("取杯2")
										else:
											if Ani.assigned_animation != "取杯":
												if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
													SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["取杯"])
												Ani.play("取杯")
										return
									else:
										print("新手引导 不可取杯")

			if GameLogic.Order.return_Order_Check():

				if GameLogic.Tutorial.NeedSell:
					if Ani.assigned_animation != "橙汁出杯" and not CanTake:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["橙汁出杯"])
						Ani.play("橙汁出杯")
					return
				if GameLogic.Tutorial.CheckList:

					for _Bottle in GameLogic.Tutorial.CheckList:
						if is_instance_valid(_Bottle):

							if _Bottle.Liquid_Count > 0:
								if Ani.assigned_animation != "橙汁制作" and not CanTake:
									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["橙汁制作"])
									Ani.play("橙汁制作")
									return
						else:
							GameLogic.Tutorial.CheckList.erase(_Bottle)

				else:
					if Ani.assigned_animation != "橙汁开盖":
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["橙汁开盖"])
						Ani.play("橙汁开盖")
						return


	else:
		set_physics_process(false)
func _SugarCheckLogic():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not is_instance_valid(GameLogic.Staff.LevelNode):
		return
	if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.GamePlay.has("新手引导1"):
			if GameLogic.cur_Day == 2:

				if GameLogic.GameUI.Is_Open:
					_SugarCheck()
				if GameLogic.Order.return_Order_SugarNeed():
					if not Ani.assigned_animation in ["橙汁加糖", "订货罐头", "订货罐头补救", "订货橙汁", "订货杯子", "订货糖"]:

						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["橙汁加糖"])
						Ani.play("橙汁加糖")
				elif Ani.assigned_animation in ["橙汁加糖"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
					Ani.play("hide")
			if GameLogic.cur_Day == 3:
				if GameLogic.Order.return_Order_AddInNeed():
					if not Ani.assigned_animation in ["橙汁加糖", "橙汁加料", "订货罐头", "订货罐头补救", "订货橙汁", "订货杯子", "订货糖"]:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["橙汁加料"])

						Ani.play("橙汁加料")
				elif Ani.assigned_animation in ["橙汁加料"]:
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
					Ani.play("hide")
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
							if Ani.assigned_animation in ["hide", "init"]:
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["添加糖"])
								Ani.play("添加糖")
								return

						elif get_node("Ani").assigned_animation == "添加糖":
							if not Ani.assigned_animation in ["init", "hide"]:
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
								Ani.play("hide")
							return

func _OrderCheckLogic():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.GamePlay.has("新手引导1"):

			if GameLogic.GameUI.Is_Open:
				_ItemCheck()

func _ItemCheck():

	var _Keys = GameLogic.cur_Item_List.keys()

	if GameLogic.GameUI.Is_Open:
		if not _Keys.has("can_coco") and GameLogic.cur_Day == 3:

			var _Item = "can_coco"
			var _Check: bool
			if not GameLogic.cur_Buy.has(_Item):
				for i in GameLogic.Buy.buy_Array.size():
					var _buyInfo = GameLogic.Buy.buy_Array[i][1]
					if _buyInfo.has(_Item):
						_Check = true
				if not _Check:
					if not GameLogic.cur_Item_List.has(_Item):
						GameLogic.cur_Item_List[_Item] = 0
					if GameLogic.cur_Item_List[_Item] == 0:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["订货罐头补救"])

						Ani.play("订货罐头补救")
					return

		for _Item in _Keys:
			match _Item:
				"can_coco":
					var _Check: bool

					if not GameLogic.cur_Buy.has(_Item):
						for i in GameLogic.Buy.buy_Array.size():
							var _buyInfo = GameLogic.Buy.buy_Array[i][1]
							if _buyInfo.has(_Item):
								_Check = true
						if not _Check:

							if GameLogic.cur_Item_List[_Item] == 0:
								if Ani.assigned_animation in ["hide", "init"]:
									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["订货罐头"])
									Ani.play("订货罐头")
								return
							else:
								if Ani.assigned_animation in ["订货罐头"]:
									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
									Ani.play("hide")
						else:
							if Ani.assigned_animation in ["订货罐头"]:
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
								Ani.play("hide")
					else:
						if Ani.assigned_animation in ["订货罐头"]:
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
							Ani.play("hide")

				"Sugar":
					var _Check: bool
					if not GameLogic.cur_Buy.has(_Item):
						for i in GameLogic.Buy.buy_Array.size():
							var _buyInfo = GameLogic.Buy.buy_Array[i][1]
							if _buyInfo.has(_Item):
								_Check = true
						if not _Check:
							if GameLogic.cur_Item_List[_Item] == 0:
								if not Ani.assigned_animation in ["订货糖"]:
									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["订货糖"])
									Ani.play("订货糖")
								return
							elif Ani.assigned_animation in ["订货糖"]:
								Ani.play("hide")
						else:
							if Ani.assigned_animation in ["订货糖"]:
								Ani.play("hide")
				"bottle_orange":
					var _Check: bool
					if not GameLogic.cur_Buy.has(_Item):
						for i in GameLogic.Buy.buy_Array.size():
							var _buyInfo = GameLogic.Buy.buy_Array[i][1]
							if _buyInfo.has(_Item):
								_Check = true
						if not _Check:
							if GameLogic.cur_Item_List[_Item] < 2:
								if not Ani.assigned_animation in ["订货橙汁"]:

									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["订货橙汁"])
									Ani.play("订货橙汁")
								return















				"DrinkCup_Group_S":
					var _Check: bool

					if not GameLogic.cur_Buy.has(_Item):
						for i in GameLogic.Buy.buy_Array.size():
							var _buyInfo = GameLogic.Buy.buy_Array[i][1]

							if _buyInfo.has("DrinkCup_S"):
								_Check = true
						if not _Check:
							if GameLogic.cur_Item_List[_Item] == 0:
								if not Ani.assigned_animation in ["订货杯子"]:
									if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
										SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["订货杯子"])
									Ani.play("订货杯子")
								return

	if Ani.assigned_animation in ["订货罐头", "订货罐头补救", "订货橙汁", "订货杯子", "订货糖"]:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_puppet_show", ["hide"])
		Ani.play("hide")
