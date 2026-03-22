extends StaticBody2D

export var NAME: String
onready var Ani = get_node("TexNode/Sprite/Ani")
var ShowBool: bool

var cur_Used: bool
var cur_PlayerID: int = 1
var cur_pressed: bool
var Can_Press: bool = true
var _pressed: bool
var _ALLArray: Array
var _0ARRAY: Array
var _1ARRAY: Array
var _2ARRAY: Array
var _3ARRAY: Array
var _4ARRAY: Array
var _5ARRAY: Array
var _6ARRAY: Array
var _7ARRAY: Array

var cur_TYPE: int = 8
onready var ApplyBut = get_node("ButControl/ApplyBut")
onready var A_But = ApplyBut.get_node("A")

onready var EXANI = $UI / Scroll / Control / ANI
onready var SPEEDANI = $UI / Scroll / Control / SPEEDANI
func _ready():

	var _con = SteamLogic.connect("CostumeExchange", self, "_ExchangeEnd")
	A_But.connect("HoldFinish", self, "_Apply_Logic")
	var _KEYS = GameLogic.Config.CostumeConfig.keys()
	for _ID in _KEYS:
		var _INFO = GameLogic.Config.CostumeConfig[_ID]
		if _INFO.part in ["Head", "Face", "Body", "Hand", "Foot", "Accessory"]:
			if _INFO.USED == "1":
				_ALLArray.append(_ID)
				match _INFO.role:
					"Bear":
						_0ARRAY.append(_ID)
					"Wolf":
						_1ARRAY.append(_ID)
					"Fox":
						_2ARRAY.append(_ID)
					"Beaver":
						_3ARRAY.append(_ID)
					"Ghost":
						_4ARRAY.append(_ID)
					"Slime":
						_5ARRAY.append(_ID)
					"Panda":
						_6ARRAY.append(_ID)
					"Crocodile":
						_7ARRAY.append(_ID)

	_TYPE_ANI()
	call_ItemShow(1)
	call_ItemShow(2)
	call_ItemShow(3)
	call_ItemShow(4)
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
func return_Check(_value):
	if SteamLogic._EQUIPDIC.has(20001):
		var _INFO = SteamLogic._EQUIPDIC[20001]
		var _CHECKNUM: int = 5
		match cur_TYPE:
			8:
				_CHECKNUM = 3
		if int(_INFO.Num) < _CHECKNUM:
			if _value == 1:
				var _audio = GameLogic.Audio.return_Effect("错误1")
				_audio.play(0)
			$ANI / MachineANI.play("wrong")
			return false
	else:
		if _value == 1:
			var _audio = GameLogic.Audio.return_Effect("错误1")
			_audio.play(0)
		$ANI / MachineANI.play("wrong")
		return false
	return true
func call_home_device(_butID, _value, _type, _Player):

	match _butID:
		- 2:
			$ANI / ButAni.play("init")
		- 1:
			call_ButLogic(true)
			$ANI / ButAni.play("show")
		0, "A":

			if _USEBOOL:
				return
			if not return_Check(_value):
				return
			if cur_pressed:
				if _value == 0:
					cur_pressed = false
					_pressed = false
					A_But.ShowAni.play("Hold_Init")
					_on_Apply_button_up()

				return
			if not Can_Press:
				if _value == 1:
					cur_pressed = true
					var _audio = GameLogic.Audio.return_Effect("错误1")
					_audio.play(0)
				return
			if _value == 1 or _value == - 1:

				cur_pressed = true
				if not _pressed:
					_pressed = true
					_on_Apply_button_down()
			else:
				_on_Apply_button_up()
				_pressed = false
		2:
			if _USEBOOL:
				return
			call_TYPE()
func call_TYPE():
	match cur_TYPE:
		0, 1, 2, 3, 4, 5, 6, 7:
			cur_TYPE += 1
		_:
			cur_TYPE = 0
	_TYPE_ANI()
func _TYPE_ANI():
	var _ANI = $UI / HBoxAni
	if _ANI.has_animation(str(cur_TYPE)):
		_ANI.play(str(cur_TYPE))
	GameLogic.Audio.But_EasyClick.play(0)
func call_ButLogic(_BOOL: bool):
	var _BUT = $ButControl / TypeBut
	match _BOOL:
		true:
			_BUT.show()
		false:
			_BUT.hide()
func _on_Apply_button_down() -> void :

	if not Can_Press:
		return
	call_ButLogic(false)
	A_But.call_holding(true)
	ApplyBut.call_down()
	call_Start()

func _on_Apply_button_up() -> void :
	if not Can_Press:
		return
	call_ButLogic(true)
	A_But.call_holding(false)
	ApplyBut.call_up()
	call_End()

var _STOPNUM: int = 0
func call_UseANI(_TYPE: int = 0):
	var _USEANI = $TexNode / UseAni
	if _TYPE == 1:
		_USEANI.play("light")
	elif _TYPE == 0:
		if _USEBOOL or (_STOPNUM > 0 and _STOPNUM < 5):

			_USEANI.play("run")
		else:
			_USEANI.play("init")
func call_Start():
	if not EXANI.is_playing():
		match _STOPNUM:
			- 2, 0:
				EXANI.play("run1")
			- 3:
				EXANI.play("run2")
			- 4:
				EXANI.play("run3")
			- 1:
				EXANI.play("run4")
	SPEEDANI.playback_speed = 1
	SPEEDANI.play("start")

func call_End():
	if not _USEBOOL:
		if SPEEDANI.current_animation == "start":
			SPEEDANI.playback_speed = - 1

func call_EndCheck():

	pass
func _run1_end():
	call_EndCheck()
	call_ItemShow(1)
	if _STOPNUM == 3:
		_STOPNUM = - 3
		printerr(" STOP 3")
		call_ex_finish()
		var _NODE = $UI / Scroll / Control
		if _NODE.has_node(str(3)):
			var _ITEMNODE = _NODE.get_node(str(3)).get_node("Control/Button")
			_ITEMNODE.disabled = false
			call_UseANI(1)
	else:

		EXANI.play("run2")
		call_UseANI()
func _run2_end():
	call_EndCheck()
	call_ItemShow(2)
	if _STOPNUM == 4:
		_STOPNUM = - 4
		printerr(" STOP 4")
		call_ex_finish()
		var _NODE = $UI / Scroll / Control
		if _NODE.has_node(str(4)):
			var _ITEMNODE = _NODE.get_node(str(4)).get_node("Control/Button")
			_ITEMNODE.disabled = false
			call_UseANI(1)
	else:
		EXANI.play("run3")
		call_UseANI()
func _run3_end():
	call_EndCheck()
	call_ItemShow(3)
	if _STOPNUM == 1:
		_STOPNUM = - 1
		printerr(" STOP 1")
		call_ex_finish()
		var _NODE = $UI / Scroll / Control
		if _NODE.has_node(str(1)):
			var _ITEMNODE = _NODE.get_node(str(1)).get_node("Control/Button")
			_ITEMNODE.disabled = false
			call_UseANI(1)
	else:
		EXANI.play("run4")
		call_UseANI()
func _run4_end():
	call_EndCheck()
	call_ItemShow(4)
	if _STOPNUM == 2:
		_STOPNUM = - 2
		printerr(" STOP 2")
		call_ex_finish()
		var _NODE = $UI / Scroll / Control
		if _NODE.has_node(str(2)):
			var _ITEMNODE = _NODE.get_node(str(2)).get_node("Control/Button")
			_ITEMNODE.disabled = false
			call_UseANI(1)
	else:
		EXANI.play("run1")
		call_UseANI()
func call_ItemShow(_TYPE: int):
	var _ARRAY: Array
	match cur_TYPE:
		0:
			_ARRAY = _0ARRAY
		1:
			_ARRAY = _1ARRAY
		2:
			_ARRAY = _2ARRAY
		3:
			_ARRAY = _3ARRAY
		4:
			_ARRAY = _4ARRAY
		5:
			_ARRAY = _5ARRAY
		6:
			_ARRAY = _6ARRAY
		7:
			_ARRAY = _7ARRAY
		_:
			_ARRAY = _ALLArray
	if _NEWID != 0:
		if _ALLArray.has(str(_NEWID)):
			var _NODE = $UI / Scroll / Control
			if _NODE.has_node(str(_TYPE)):
				var _ITEMNODE = _NODE.get_node(str(_TYPE)).get_node("Control/Button")
				_ITEMNODE.call_ButShow(_NEWID, "")

				_STOPNUM = _TYPE
				_NEWID = 0
				_ITEMNODE.disabled = true
				return
	var _MAX: int = _ARRAY.size()
	if _MAX:
		var _RAND = GameLogic.return_RANDOM() % _MAX
		var _ID: int = int(_ARRAY[_RAND])
		var _NODE = $UI / Scroll / Control
		if _NODE.has_node(str(_TYPE)):
			var _ITEMNODE = _NODE.get_node(str(_TYPE)).get_node("Control/Button")
			_ITEMNODE.call_ButShow(_ID, "")
			_ITEMNODE.disabled = true
var _NEWID: int = 0
var _USEBOOL: bool = false
func _ExchangeEnd(_ID, _IDNUM, _COSTUMEID):
	_NEWID = _COSTUMEID
	print(" ExchangeEND:", _COSTUMEID, " 20001:", _IDNUM)

func _Apply_Logic() -> void :
	_USEBOOL = true
	get_node("Timer").start(0)

func call_Exchange():
	_STOPNUM = 5
	var _Input_ID: int = 20001
	var _Output_ID: int = 402010
	var _Input_Num: int = 3
	match cur_TYPE:
		0:
			_Output_ID = 402011
			_Input_Num = 5
		1:
			_Output_ID = 402012
			_Input_Num = 5
		2:
			_Output_ID = 402013
			_Input_Num = 5
		3:
			_Output_ID = 402014
			_Input_Num = 5
		4:
			_Output_ID = 402015
			_Input_Num = 5
		5:
			_Output_ID = 402016
			_Input_Num = 5
		6:
			_Output_ID = 402017
			_Input_Num = 5
		7:
			_Output_ID = 402018
			_Input_Num = 5
		_:
			_Output_ID = 402010
			_Input_Num = 3
	exchange_steam_item(_Input_ID, _Input_Num, _Output_ID, 1)
func exchange_steam_item(input_config_id: int, input_qty: int, output_config_id: int, output_qty: int):
	var input_item_id: int = 0
	var eq: = SteamLogic._EQUIPDIC
	if eq.has(input_config_id):
		var item = eq[input_config_id]
		if item.Num < 3:
			print("物品数量不足，无法交换")
			call_ex_finish()
			$ANI / MachineANI.play("wrong")

			return
		if item.Num < input_qty:
			print("物品数量不足，无法交换")
			call_ex_finish()
			$ANI / MachineANI.play("wrong")
			return
		input_item_id = int(item.Id)
	else:
		print("未找到输入配置ID对应的物品")
		call_ex_finish()
		$ANI / MachineANI.play("wrong")
	if input_item_id == 0:
		print("无效的输入配置ID")
		call_ex_finish()
		$ANI / MachineANI.play("wrong")
		return

	var output_items: PoolIntArray = PoolIntArray([output_config_id])
	var output_quantity: PoolIntArray = PoolIntArray([output_qty])
	var input_items: PoolIntArray = PoolIntArray([input_item_id])
	var input_quantity: PoolIntArray = PoolIntArray([input_qty])

	var result = Steam.exchangeItems(output_items, output_quantity, input_items, input_quantity)
	if result:

		while true:

			var status = Steam.getResultStatus(result)
			if status != 22:

				if status == 1:
					print("交换成功")

				else:
					print("交换失败，状态码:", status)
					call_ex_finish()
					$ANI / MachineANI.play("wrong")
				Steam.destroyResult(result)
				SteamLogic.LoadInventory()
				break
			yield(get_tree().create_timer(0.5), "timeout")
	else:
		print("交换请求发起失败")
		$ANI / MachineANI.play("wrong")
		call_ex_finish()
func call_ex_finish():
	_USEBOOL = false
	cur_pressed = false
	_pressed = false
	_on_Apply_button_up()
func _on_Timer_timeout():
	SPEEDANI.play("end")
