extends StaticBody2D

var cur_Used: bool
onready var ITEMNODE = $Costume / BG / Button
onready var ANI = $Costume / Ani
onready var ButShow = $Button / A

func _ready():
	var _tr = SteamLogic.connect("TriggerItemDrop", self, "_TriggerItemDrop")





	call_MailShow()

func call_MailShow():
	var _NUM = SteamLogic.MAILNUM
	if _NUM == 1:
		$Costume / BG / Label.text = "NEW"
	elif _NUM > 1:
		$Costume / BG / Label.text = str(_NUM)
	if _NUM > 0:
		ANI.play("new")
	else:
		ANI.play("init")

func _inventory_ready(_result: int, _inventory_handle: int):




	var _status = Steam.getResultStatus(_inventory_handle)

	var _ARRAY = Steam.getResultItems(_inventory_handle)

	if not GameLogic.Save.gameData.has("NewGiftLIST"):
		GameLogic.Save.gameData["NewGiftLIST"] = []
	if _ARRAY.size() == 1:
		for _DIC in _ARRAY:
			var _ITEMID = _DIC.item_definition

			if not GameLogic.Save.gameData["NewGiftLIST"].has(_ITEMID):
				GameLogic.Save.gameData["NewGiftLIST"].append(_ITEMID)
	print("MailBox _ARRAY size:", _ARRAY.size(), " _GIFTLIST:", GameLogic.Save.gameData["NewGiftLIST"])





func call_home_device(_butID, _value, _type, _Player):
	print(_butID, " MailBox call:", SteamLogic.IsMultiplay)
	match _butID:
		- 1:
			if SteamLogic.MAILNUM > 0:
				ButShow.call_player_in(_Player.cur_Player)

		- 2:

			ButShow.call_player_out(_Player.cur_Player)
		0, "A":
			if _value == 0:
				return


			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return
			call_show_logic()

func _TenExchangeEnd(_ID, _IDNUM, _TENARRAY: Array):

	var _NUM = _IDNUM
	SteamLogic.MAILNUM = _IDNUM
	if _NUM == 1:
		$Costume / BG / Label.text = "NEW"
	elif _NUM > 1:
		$Costume / BG / Label.text = str(_NUM)
	var _ITEMLIST = get_node("Costume/ItemList").get_children()
	for _NODE in _ITEMLIST:
		_NODE.hide()
	for _i in _TENARRAY.size():
		if get_node("Costume/ItemList").has_node(str(_i)):
			var _NODE = get_node("Costume/ItemList").get_node(str(_i))
			_NODE.show()
			var _COSTUMEID = _TENARRAY[_i]
			_NODE.ID = int(_COSTUMEID)
			_NODE.call_ID_Logic()

	ANI.play("10")
	print(" Ten ExchangeEND:", _TENARRAY, " _ITEMLIST:", _ITEMLIST)
func _ExchangeEnd(_ID, _IDNUM, _COSTUMEID):
	ITEMNODE.ID = int(_COSTUMEID)
	ITEMNODE.call_ID_Logic()
	ANI.play("show")
	var _NUM = SteamLogic.MAILNUM
	if _NUM == 1:
		$Costume / BG / Label.text = "NEW"
	elif _NUM > 1:
		$Costume / BG / Label.text = str(_NUM)

	print(" ExchangeEND:", _COSTUMEID, " 20002:", _IDNUM, " ", _NUM)
func call_ten():

	if SteamLogic.MAILNUM > 10:
		var _AUDIO = GameLogic.Audio.return_Effect("开信箱")
		_AUDIO.play()
		ANI.play("loading")
		exchange_steam_item(20002, 10, 30006, 1)
func call_show_logic():
	if ANI.current_animation in ["new"]:
		var _NUM = SteamLogic.MAILNUM
		if SteamLogic.MAILNUM > 10:

			call_ten()
		elif SteamLogic.MAILNUM > 0:
			var _AUDIO = GameLogic.Audio.return_Effect("开信箱")
			_AUDIO.play()
			ANI.play("loading")
			exchange_steam_item(20002, 1, 422010, 1)
	elif ANI.current_animation in ["show", "10"]:
		GameLogic.Audio.But_Back.play(0)
		ANI.play("init")
		call_MailShow()
func call_show_new():
	if ANI.current_animation == "show":
		return
	if GameLogic.Save.gameData["NewGiftLIST"].size():
		if ANI.current_animation != "new":
			ANI.play("new")
	else:
		if ANI.current_animation == "new":
			ANI.play("init")

func call_check_email():

	call_MailShow()

func _on_Timer_timeout():
	if ANI.current_animation in ["show", "10"]:
		return
	call_MailShow()

func _TriggerItemDrop():

	var result = Steam.triggerItemDrop(50001)
	print("Email: _triggerItemDrop", result)
	if result:

		while true:
			var status = Steam.getResultStatus(result)
			if status != 22:

				Steam.destroyResult(result)

				break
			yield(get_tree().create_timer(0.5), "timeout")

func exchange_steam_item(input_config_id: int, input_qty: int, output_config_id: int, output_qty: int):
	var input_item_id: int = 0
	var eq: = SteamLogic._EQUIPDIC
	if eq.has(input_config_id):
		var item = eq[input_config_id]
		if item.Num < 1:
			print("物品数量不足，无法交换")

			return
		if item.Num < input_qty:
			print("物品数量不足，无法交换")

			return
		input_item_id = int(item.Id)
	else:
		print("未找到输入配置ID对应的物品")

	if input_item_id == 0:
		print("无效的输入配置ID")

		return

	var output_items: PoolIntArray = PoolIntArray([output_config_id])
	var output_quantity: PoolIntArray = PoolIntArray([output_qty])
	var input_items: PoolIntArray = PoolIntArray([input_item_id])
	var input_quantity: PoolIntArray = PoolIntArray([input_qty])

	var result = Steam.exchangeItems(output_items, output_quantity, input_items, input_quantity)
	if result:

		var _WAIT: int = 0
		while true:

			var status = Steam.getResultStatus(result)
			print(_WAIT, " 测试 status:", status)

			if status != 22:

				if status == 1:

					var _ARRAY = Steam.getResultItems(result)
					if _ARRAY.size() > 1:
						if _ARRAY.size() > 2 and _ARRAY.size() <= 12:

							var _OUTARRAY: Array
							var _MAILNUM: int = SteamLogic.MAILNUM
							for _DIC in _ARRAY:
								if _DIC.has("item_definition") and _DIC.has("quantity"):
									if _DIC.item_definition == 20002:
										_MAILNUM = _DIC.quantity
										SteamLogic.MAILNUM = _MAILNUM
									else:
										var _ITEMNUM: int = int(_DIC.quantity)
										var _ITEMID: int = int(_DIC.item_definition)
										if SteamLogic._EQUIPDIC.has(_ITEMID):
											var _test = SteamLogic._EQUIPDIC[_ITEMID]
											if SteamLogic._EQUIPDIC[_ITEMID].Id == _DIC.item_id:
												SteamLogic._EQUIPDIC[_ITEMID].Num = _ITEMNUM
										_OUTARRAY.append(_DIC.item_definition)
							if _OUTARRAY.size() > 0 and _OUTARRAY.size() <= 11:
								_TenExchangeEnd(20002, _MAILNUM, _OUTARRAY)

						if _ARRAY.size() == 2:

							var _INPUTDIC = _ARRAY[0]
							var _OUPUTDIC = _ARRAY[1]
							var _INNUM: int = 0

							var _MAILCHECK: bool = false
							var _OUTID: int = 0

							if _INPUTDIC.has("item_definition") and _INPUTDIC.has("quantity"):
								if _INPUTDIC.item_definition == 20002:
									_INNUM = _INPUTDIC.quantity

									GameLogic.cur_MAILNUM = _INNUM
									_MAILCHECK = true


							if _OUPUTDIC.has("item_definition") and _OUPUTDIC.has("quantity"):
								_OUTID = int(_OUPUTDIC.item_definition)
								var _ITEMNUM: int = int(_OUPUTDIC.quantity)
								if SteamLogic._EQUIPDIC.has(_OUTID):
									var _test = SteamLogic._EQUIPDIC[_OUTID]
									if SteamLogic._EQUIPDIC[_OUTID].Id == _OUPUTDIC.item_id:
										SteamLogic._EQUIPDIC[_OUTID].Num = _ITEMNUM

							if _MAILCHECK and _OUTID != 0:
								_ExchangeEnd(20002, _INNUM, _OUTID)

				else:
					print("交换失败，状态码:", status)

				Steam.destroyResult(result)

				break
			_WAIT += 1
			yield(get_tree().create_timer(0.5), "timeout")
	else:
		print("交换请求发起失败")
