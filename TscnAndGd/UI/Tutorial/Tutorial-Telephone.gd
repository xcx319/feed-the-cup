extends Node2D
var _TimeCheck: float = 0

func _CheckLogic():
	if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		var _LEVELINFO = GameLogic.cur_levelInfo

		if _LEVELINFO.GamePlay.has("新手引导1"):

			if GameLogic.GameUI.Is_Open or GameLogic.GameUI.CurTime > GameLogic.cur_OpenTime:
				_ItemCheck()
			else:
				if get_node("Ani").assigned_animation != "init":
					get_node("Ani").play("init")
func _ItemCheck():

	var _Keys = GameLogic.cur_Item_List.keys()
	if GameLogic.GameUI.CurTime < GameLogic.cur_OpenTime:
		if not _Keys.has("can_coco") and GameLogic.cur_Day == 3:

			var _Item = "can_coco"
			var _Check: bool
			if not GameLogic.cur_Buy.has(_Item):
				for i in GameLogic.Buy.buy_Array.size():
					var _buyInfo = GameLogic.Buy.buy_Array[i][1]
					if _buyInfo.has(_Item):
						_Check = true
				if not _Check:

					get_node("InfoNode/Label").call_Tr_TEXT("新手引导-罐头不足")
					if get_node("Ani").assigned_animation != "show":
						get_node("Ani").play("show")
					return
		if not _Keys.has("bottle_lemon") and GameLogic.cur_Day == 4:

			var _Item = "bottle_lemon"
			var _Check: bool
			if not GameLogic.cur_Buy.has(_Item):
				for i in GameLogic.Buy.buy_Array.size():
					var _buyInfo = GameLogic.Buy.buy_Array[i][1]
					if _buyInfo.has(_Item):
						_Check = true
				if not _Check:

					get_node("InfoNode/Label").call_Tr_TEXT("新手引导-柠檬汁不足")
					if get_node("Ani").assigned_animation != "show":
						get_node("Ani").play("show")
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
							get_node("InfoNode/Label").call_Tr_TEXT("新手引导-罐头不足")
							if get_node("Ani").assigned_animation != "show":
								get_node("Ani").play("show")
							return

			"Sugar":
				var _Check: bool
				if not GameLogic.cur_Buy.has(_Item):
					for i in GameLogic.Buy.buy_Array.size():
						var _buyInfo = GameLogic.Buy.buy_Array[i][1]
						if _buyInfo.has(_Item):
							_Check = true
					if not _Check:
						if GameLogic.cur_Item_List[_Item] == 0:
							get_node("InfoNode/Label").call_Tr_TEXT("新手引导-果糖不足")
							if get_node("Ani").assigned_animation != "show":
								get_node("Ani").play("show")
							return

			"bottle_orange", "bottle_lemon":

				var _Check: bool
				if not GameLogic.cur_Buy.has(_Item):
					for i in GameLogic.Buy.buy_Array.size():
						var _buyInfo = GameLogic.Buy.buy_Array[i][1]
						if _buyInfo.has(_Item):
							_Check = true
					if not _Check:
						if GameLogic.cur_Item_List[_Item] < 2:
							var _TEXT: String
							match _Item:
								"bottle_orange":
									_TEXT = "新手引导-原料不足"
								"bottle_lemon":
									if GameLogic.cur_Day >= 4:
										_TEXT = "新手引导-柠檬汁不足"
									else:
										return
							get_node("InfoNode/Label").call_Tr_TEXT(_TEXT)
							if get_node("Ani").assigned_animation != "show":
								get_node("Ani").play("show")
							return

			"DrinkCup_Group_S":
				var _Check: bool

				if not GameLogic.cur_Buy.has(_Item):
					for i in GameLogic.Buy.buy_Array.size():
						var _buyInfo = GameLogic.Buy.buy_Array[i][1]
						if _buyInfo.has(_Item):
							_Check = true
					if not _Check:
						if GameLogic.cur_Item_List[_Item] == 0:
							get_node("InfoNode/Label").call_Tr_TEXT("新手引导-杯组不足")
							if get_node("Ani").assigned_animation != "show":
								get_node("Ani").play("show")
							return

	if get_node("Ani").assigned_animation == "show":
		get_node("Ani").play("hide")

func _physics_process(_delta: float) -> void :
	_TimeCheck += _delta
	if _TimeCheck > 1:
		_CheckLogic()
		_TimeCheck = 0
