extends Control

func _ready():
	if OS.has_feature("standalone"):
		self.queue_free()

	self.hide()

	$ItemList.call_hide()
func call_show():


	self.show()
	pass

func call_Cheat():

	pass

func call_hide():
	self.hide()
	$ItemList.call_hide()
func _on_DayEnd_pressed():

	if not GameLogic.Order.return_CanClosed():

		printerr(" 不可关店，有订单")
		return
	elif GameLogic.Buy.buy_Array.size():

		printerr(" 不可关店，正在配送")
		return
	else:
		var _PlayerArray = get_tree().get_root().get_node("Level/YSort/Players").get_children()
		for _PLAYER in _PlayerArray:
			if is_instance_valid(_PLAYER):
				if is_instance_valid(instance_from_id(_PLAYER.Con.HoldInsId)):

					printerr(" 不可关店，holding")
					return
				if _PLAYER.IsDead:

					printerr(" 不可关店，角色哭")
					return

		var _CouriersList = get_tree().get_nodes_in_group("Couriers")
		var _CheckList: Array
		for _Courier in _CouriersList:
			_CheckList.append(_Courier.return_Courier_Check())
		if false in _CheckList:

			printerr(" 不可关店，正在配送")
			return
		else:

			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_master_node_sync(self, "call_Power_puppet")
			else:
				GameLogic.call_dayover()
				print(" 调试 dayover")
	call_Cheat()

func _on_Money_pressed():

	GameLogic.call_MoneyOther_Change(10000, GameLogic.HomeMoneyKey)
	call_Cheat()

func _on_REP_pressed():

	var _NUM = GameLogic.GameUI.Popularity._CurMax - GameLogic.GameUI.Popularity._CurNum

	GameLogic.return_Popular(_NUM, GameLogic.HomeMoneyKey)
	call_Cheat()

func _on_Challenge_pressed():

	if $ItemList._TYPE != 2:
		$ItemList.call_Challenge_show()
	else:
		$ItemList.call_hide()
	call_Cheat()

func _on_UnPre_pressed():

	GameLogic.call_Pressure_Test( - 1)
	call_Cheat()
func _on_Pre0_pressed():

	GameLogic.call_Pressure_Test(0)
	call_Cheat()
func _on_PreHigh_pressed():

	GameLogic.call_Pressure_Test(1)
	call_Cheat()

func _on_Reward_pressed():

	if $ItemList._TYPE != 1:
		$ItemList.call_Reward_show()
	else:
		$ItemList.call_hide()
	call_Cheat()

func _on_Time_toggled(button_pressed: bool):

	GameLogic.GameUI.call_TimeStop(button_pressed, GameLogic.HomeMoneyKey)

	call_Cheat()

func _on_Customer_pressed():



	GameLogic.NPC.call_Thug(GameLogic.HomeMoneyKey)
	call_Cheat()
