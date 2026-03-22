extends Node2D

export var NAME: String
onready var Ani = get_node("TexNode/Sprite/Ani")
onready var EquipmentUI = $EquipmentUI
onready var ButShow = $Button / A
var ShowBool: bool
var cur_Used: bool
var cur_PlayerID: int = 1
var cur_pressed: bool
func _ready() -> void :
	call_deferred("call_init")

func call_init():
	if GameLogic.Save.gameData.has("HomeDevList"):
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LOBBY_gameData.has("HomeDevList"):
				if SteamLogic.LOBBY_gameData.HomeDevList.has(NAME):
					Ani.play("show_init")
					ShowBool = true
		elif GameLogic.Save.gameData.HomeDevList.has(NAME):
			Ani.play("show_init")
			ShowBool = true
	var _con = GameLogic.connect("SYNC", self, "call_show")

func call_show():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not ShowBool:

		if GameLogic.Save.gameData.has("HomeDevList"):
			if GameLogic.Save.gameData.HomeDevList.has(NAME):
				Ani.play("show")
				ShowBool = true
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_show_puppet")


func call_show_puppet():
	Ani.play("show")
	ShowBool = true

func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 1:
			ButShow.call_player_in(_Player.cur_Player)
		- 2:
			ButShow.call_player_out(_Player.cur_Player)

		3, "Y":
			if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
				return
			SteamLogic.LoadInventory()
		2, "X":
			if not SteamLogic.STEAM_ID in [76561198024456526, 76561198061275454, 76561199510302905]:
				return











		0, "A":
			if _value == 0:
				return


			SteamLogic.LoadInventory()


			if not _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				return
			if not cur_Used:

				match _Player.cur_Player:
					1, SteamLogic.STEAM_ID:
						if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
							GameLogic.Con.connect("P1_Control", self, "_control_logic")

						cur_PlayerID = 1
						EquipmentUI.get_node("ButPlayer").play("1")


					2:
						if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
							GameLogic.Con.connect("P2_Control", self, "_control_logic")

						cur_PlayerID = 2
						EquipmentUI.get_node("ButPlayer").play("2")

				GameLogic.player_1P.call_control(1)
				if GameLogic.Player2_bool:
					GameLogic.player_2P.call_control(1)
				cur_Used = true
				GameLogic.Audio.But_SwitchOn.play(0)
				EquipmentUI._AVATARID = _Player.cur_ID
				EquipmentUI.call_show()
				return true
func _control_logic(_but, _value, _type):

	if not cur_Used:
		return
	if _value == 1 or _value == - 1:
		match _but:
			"l", "L":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_left"
					_input.pressed = true
					Input.parse_input_event(_input)
			"r", "R":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_right"
					_input.pressed = true
					Input.parse_input_event(_input)
			"u", "U":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					Input.parse_input_event(_input)
			"d", "D":
				if cur_pressed == false:
					cur_pressed = true
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					Input.parse_input_event(_input)
			"X":
				if cur_pressed == false:
					cur_pressed = true
					EquipmentUI._on_TYPEButton_pressed()
					EquipmentUI.TYPEBUT._button_down()
			"A":
				if cur_pressed == false:
					cur_pressed = true
					var _FOCUSBUT = EquipmentUI.return_Focus_But()
					if is_instance_valid(_FOCUSBUT):
						if _FOCUSBUT.has_method("_on_Button_pressed"):
							if not _FOCUSBUT.disabled:
								_FOCUSBUT._on_Button_pressed()
			"B", "START":
				if _value != 0:
					call_close()
			"L1":
				EquipmentUI.call_TYPE_Change(false)
			"R1":
				EquipmentUI.call_TYPE_Change(true)

	if _type == 0 or _value == 0:
		cur_pressed = false
func call_close():
	EquipmentUI.call_hide()
	GameLogic.player_1P.call_control(0)
	if GameLogic.Player2_bool:
		GameLogic.player_2P.call_control(0)
	cur_Used = false
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")

	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

func _on_1_pressed():
	var item_definitions = PoolIntArray([20002])
	var quantities = PoolIntArray([100])
	var _result = Steam.generateItems(item_definitions, quantities)
	Steam.destroyResult(_result)

	SteamLogic.LoadInventory()
func _on_2_pressed():

	exchange_steam_item(20001, 3, 21001, 1)

func _on_3_pressed():

	var _INFO = SteamLogic._EQUIPDIC
	pass

func call_exchange(_InArray, _OutID):

	var _INPUTARRAY: Array

	var eq: = SteamLogic._EQUIPDIC
	for _InputID in _InArray:
		if eq.has(_InputID):
			var item = eq[_InputID]
			if item.Num >= 1:
				_INPUTARRAY.append(int(item.Id))
			else:
				print("物品数量不足，无法交换")
				return
	if not _INPUTARRAY.size():
		print("无效的输入配置ID")
		return
	var output_items: PoolIntArray = PoolIntArray([_OutID])
	var output_quantity: PoolIntArray = PoolIntArray([1])
	var input_items: PoolIntArray = PoolIntArray(_INPUTARRAY)
	var input_quantity: PoolIntArray = PoolIntArray([1])
	print("交换物品参数 - 输入ID:", _INPUTARRAY, " 输出ID:", _OutID)
	var result = Steam.exchangeItems(output_items, output_quantity, input_items, input_quantity)
	if result:
		print("交换请求已发起，结果句柄:", result)
		while true:
			var status = Steam.getResultStatus(result)
			if status != 22:
				print("交换结果句柄:", result, " 状态:", status)
				if status == 1:
					print("交换成功")
				else:
					print("交换失败，状态码:", status)
				Steam.destroyResult(result)
				Steam.loadItemDefinitions()
				break
			yield(get_tree().create_timer(0.5), "timeout")
	else:
		print("交换请求发起失败")

func exchange_steam_item(input_config_id: int, input_qty: int, output_config_id: int, output_qty: int):
	var input_item_id: int = 0
	var eq: = SteamLogic._EQUIPDIC
	if eq.has(input_config_id):
		var item = eq[input_config_id]
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
	print(input_config_id, "交换物品参数 - 输入ID:", input_item_id, " 数量:", input_qty, " 输出ID:", output_config_id, " 数量:", output_qty)
	var result = Steam.exchangeItems(output_items, output_quantity, input_items, input_quantity)
	if result:
		print("交换请求已发起，结果句柄:", result)
		while true:
			var status = Steam.getResultStatus(result)
			if status != 22:
				print("交换结果句柄:", result, " 状态:", status)
				if status == 1:
					print("交换成功")
				else:
					print("交换失败，状态码:", status)
				Steam.destroyResult(result)
				Steam.loadItemDefinitions()
				break
			yield(get_tree().create_timer(0.5), "timeout")
	else:
		print("交换请求发起失败")
