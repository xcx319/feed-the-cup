extends CanvasLayer

onready var ANI = $Ani

onready var EquipGrid = $Control / Info / BG / Scroll / Grid
onready var EQUIPBUTTON_TSCN = preload("res://TscnAndGd/Buttons/EquipButton.tscn")
onready var Group = preload("res://TscnAndGd/UI/Info/RewardInfo.tres")
var CurGroup

var _TYPE: int = 8
var _FASHION: int = 1
var EquipList: Array
var _AVATARID: int

var RecycleIcons: int = 0
var CurRecycle: int = 0
var IsLock: bool = false
var LockID: int = 0
var LockNum: int = 0

onready var TYPEBUT = $Control / Info / TYPEButton
onready var FASHIONBUT = $Control / Info / FashionButton
func _ready():

	if not GameLogic.is_connected("RecycleID", self, "call_RecycleSet"):
		var _CON = GameLogic.connect("RecycleID", self, "call_RecycleSet")

func call_IconShow():
	if SteamLogic._EQUIPDIC.has(20001):
		var _INFO = SteamLogic._EQUIPDIC[20001]
		RecycleIcons = int(_INFO.Num)
	$Control / RecycleCoin / CoinLabel.text = str(RecycleIcons)
func call_EquipList_init(_FASHIONCHECK: String):
	EquipList.clear()
	var _IDKEYS: Array = SteamLogic._EQUIPDIC.keys()
	for _ID in _IDKEYS:
		if GameLogic.Config.CostumeConfig.has(str(_ID)):
			var _INFO = GameLogic.Config.CostumeConfig[str(_ID)]
			if _INFO. class == "Costume":
				var _PART = _INFO.part
				var _ROLE = _INFO.role
				var _ROLECHECK: String = ""
				match _TYPE:
					0:
						_ROLECHECK = "Bear"
					1:
						_ROLECHECK = "Wolf"
					2:
						_ROLECHECK = "Fox"
					3:
						_ROLECHECK = "Beaver"
					4:
						_ROLECHECK = "Ghost"
					5:
						_ROLECHECK = "Slime"
					6:
						_ROLECHECK = "Panda"
					7:
						_ROLECHECK = "Crocodile"
					_:
						_ROLECHECK = ""
				var _ROLEBOOL: bool = false
				if _ROLECHECK == "" or _ROLECHECK == _ROLE:
					_ROLEBOOL = true
				if _PART == _FASHIONCHECK and _ROLEBOOL:
					EquipList.append(_ID)

func call_EQUIPSHOW():
	call_IconShow()
	call_clean_Grid()

	call_CARD_Set(str(_FASHION))

func call_clean_Grid():

	pass
func return_RoleCheck(_ID):
	var _EQUIPID: String = str(_ID)
	if GameLogic.Config.CostumeConfig.has(_EQUIPID):
		var _role = GameLogic.Config.CostumeConfig[_EQUIPID].role
		var _RoleInt: int
		match _role:
			"Bear":
				_RoleInt = 0
			"Wolf":
				_RoleInt = 1
			"Fox":
				_RoleInt = 2
			"Beaver":
				_RoleInt = 3
			"Ghost":
				_RoleInt = 4
			"Slime":
				_RoleInt = 5
			"Panda":
				_RoleInt = 6
			"Crocodile":
				_RoleInt = 7
		if _RoleInt == _AVATARID:
			return true
	return false

func return_But_Check():
	var _BUTLIST = EquipGrid.get_children()
	var _BUTIDLIST: Array
	for _BUT in _BUTLIST:
		var _IDCHECK = _BUT.ID
		_BUTIDLIST.append(_IDCHECK)
		if _BUT.ID in EquipList:
			_BUT.call_ID_Logic()
		else:
			_BUT.queue_free()
	return _BUTIDLIST
func _AddBUT(_EQUIPPART: String):

	var _BUTIDLIST = return_But_Check()
	for _ID in EquipList:
		var _CHECK: bool
		if not _ID in _BUTIDLIST:
			_CHECK = true
		if _CHECK:
			var _BUT = EQUIPBUTTON_TSCN.instance()
			_BUT.ID = int(_ID)
			_BUT.AVATARID = _AVATARID
			_BUT.PLAYERID = get_parent().cur_PlayerID
			match _EQUIPPART:
				"Accessory":
					_BUT.EQUIPPART = "Accessory_1"
				"Hand":
					if _AVATARID in [4]:
						_BUT.EQUIPPART = "Accessory_2"
					else:
						_BUT.EQUIPPART = "Hand"
				"Foot":
					if _AVATARID in [4]:
						_BUT.EQUIPPART = "Accessory_3"
					elif _AVATARID in [5]:
						_BUT.EQUIPPART = "Accessory_2"
					else:
						_BUT.EQUIPPART = "Foot"
				"Head":
					_BUT.EQUIPPART = _EQUIPPART
				"Face":
					_BUT.EQUIPPART = _EQUIPPART
				"Body":
					_BUT.EQUIPPART = _EQUIPPART
			_BUT.set_button_group(CurGroup)
			EquipGrid.add_child(_BUT)
			_BUT.IsRecycle = true
			_BUT.DISABLEBOOL = false
			_BUT.call_ID_Logic()

func call_CARD_Set(_NAMEID: String):
	if not CurGroup:
		CurGroup = Group
	match _NAMEID:
		"1":
			call_EquipList_init("Head")
			_AddBUT("Head")

		"2":
			call_EquipList_init("Face")
			_AddBUT("Face")
		"3":
			call_EquipList_init("Body")
			_AddBUT("Body")
		"4":
			match _TYPE:
				4:
					call_EquipList_init("Accessory")
				_:
					call_EquipList_init("Hand")
			_AddBUT("Hand")

		"5":
			match _TYPE:
				4, 5:
					call_EquipList_init("Accessory")
				_:
					call_EquipList_init("Foot")
			_AddBUT("Foot")
		"6":
			call_EquipList_init("Accessory")
			_AddBUT("Accessory")
	call_GrabFocus()
func call_GrabFocus():
	yield(get_tree().create_timer(0.1), "timeout")
	if EquipGrid.get_child_count() > 0:
		EquipGrid.get_child(0).grab_focus()

func call_ESC_true():
	GameLogic.Can_ESC = true

func call_hide():
	if ANI.assigned_animation == "show":
		ANI.play("hide")

func call_show():

	GameLogic.Can_ESC = false
	if ANI.assigned_animation != "show":
		ANI.play("show")


	var _PLAYERID = get_parent().cur_PlayerID
	if _PLAYERID == SteamLogic.STEAM_ID:
		_PLAYERID = 1



	call_FashionButton_show()
	call_TypeButton_show()
	call_EQUIPSHOW()

func call_closed():
	get_parent().call_close()

func _on_But_pressed():
	get_parent().call_apply()
func call_RecycleFinish():

	call_LockCheck()



func call_exchange_finish():

	var _FINISHANI = $Control / BG / Recycle / TextureProgress / FinishAni

	_FINISHANI.play("finish")
	call_finish()

func call_finish():

	call_FashionButton_show()
	call_TypeButton_show()
	call_EQUIPSHOW()
	$Control / BG / Recycle / Button.call_RecycleShow(CurRecycle)
	call_LockCheck()
func call_RecycleSet(_ID):

	if IsLock:

		return
	if CurRecycle == _ID:
		CurRecycle = 0
	else:
		CurRecycle = _ID
	$Control / BG / Recycle / Button.call_RecycleShow(CurRecycle)
	if CurRecycle:
		if GameLogic.Config.CostumeConfig.has(str(CurRecycle)):
			var _Rarity = GameLogic.Config.CostumeConfig[str(CurRecycle)].rarity
			var _NUM: String = "0"
			match _Rarity:
				"Common":
					_NUM = "1"
				"Classy":
					_NUM = "2"
				"Rare":
					_NUM = "3"
				"Epic":
					_NUM = "4"
				"Unique":
					_NUM = "5"
			$Control / BG / Recycle / RecycleCoin / CoinLabel.text = _NUM
	call_RecycleAni()
func call_RecycleAni():
	var _ANI = $Control / BG / Recycle / TextureProgress / Ani
	if CurRecycle == 0:
		_ANI.play("init")
	else:
		var eq: = SteamLogic._EQUIPDIC
		if eq.has(CurRecycle):
			var item = eq[CurRecycle]
			if item.Num < 2:
				_ANI.play("init")
				_ANI.play("OnlyOne")
			else:
				_ANI.play("init")
				_ANI.play("play")

func call_Recycle():
	if IsLock:

		return
	if GameLogic.Config.CostumeConfig.has(str(CurRecycle)):
		var _Rarity = GameLogic.Config.CostumeConfig[str(CurRecycle)].rarity
		var _EXID: int
		match _Rarity:
			"Common":
				_EXID = 34001
			"Classy":
				_EXID = 34002
			"Rare":
				_EXID = 34003
			"Epic":
				_EXID = 34004
			"Unique":
				_EXID = 34005
		if _EXID:
			var eq: = SteamLogic._EQUIPDIC
			if eq.has(CurRecycle):
				var item = eq[CurRecycle]
				LockID = CurRecycle
				LockNum = item.Num
				IsLock = true
				var _LOCKANI = $Control / BG / Recycle / Lock / LockAni
				_LOCKANI.play("Lock")
				var _ANI = $Control / BG / Recycle / TextureProgress / Ani
				_ANI.play("Waiting")
				exchange_steam_item(CurRecycle, 1, _EXID, 1)
func _on_Timer_timeout():
	if IsLock:
		SteamLogic.LoadInventory()
		call_LockCheck()

func call_LockCheck():
	if IsLock:
		var eq: = SteamLogic._EQUIPDIC
		if eq.has(LockID):
			var _NUM = eq[LockID].Num
			if _NUM < LockNum:
				IsLock = false
			else:
				$Timer.start(0)
		else:
			IsLock = false

		if not IsLock:
			var _LOCKANI = $Control / BG / Recycle / Lock / LockAni
			_LOCKANI.play("init")
			CurRecycle = 0
			$Control / BG / Recycle / Button.call_RecycleShow(CurRecycle)
			call_EQUIPSHOW()

			var _ANI = $Control / BG / Recycle / TextureProgress / Ani
			if _ANI.assigned_animation == "Waiting":
				_ANI.play("init")

		else:
			var _ANI = $Control / BG / Recycle / TextureProgress / Ani
			_ANI.play("Waiting")
func call_TYPE_Change(_BOOL: bool):
	if _BOOL:
		if _TYPE < 6:
			_TYPE += 1
		else:
			_TYPE = 1
	else:
		if _TYPE > 1:
			_TYPE -= 1
		else:
			_TYPE = 6
	call_EQUIPSHOW()

func return_Focus_But():
	var _BUTLIST = EquipGrid.get_children()
	if _BUTLIST:
		for _BUT in _BUTLIST:
			if _BUT.has_focus():
				return _BUT

	else:
		return

func call_FashionButton_show():

	var _ANI = $Control / Info / FashionButton / LockANI
	if _ANI.has_animation(str(_FASHION)):
		_ANI.play(str(_FASHION))
	else:
		_ANI.play("All")
func call_TypeButton_show():

	var _ANI = $Control / Info / TYPEButton / LockANI
	if _ANI.has_animation(str(_TYPE)):
		_ANI.play(str(_TYPE))
	else:
		_ANI.play("All")
func _on_FashionButton_pressed():
	match _FASHION:
		1, 2, 3, 4, 5:
			_FASHION += 1
		_:
			_FASHION = 1

	call_FashionButton_show()
	call_EQUIPSHOW()
func _on_TYPEButton_pressed():

	match _TYPE:
		0, 1, 2, 3, 4, 5, 6, 7:
			_TYPE += 1
		_:
			_TYPE = 0
	call_TypeButton_show()
	call_EQUIPSHOW()

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
		print("交换请求发起失败 1")

func exchange_steam_item(input_config_id: int, input_qty: int, output_config_id: int, output_qty: int):
	var input_item_id: int = 0
	var eq: = SteamLogic._EQUIPDIC
	if eq.has(input_config_id):
		var item = eq[input_config_id]
		if item.Num < 2:
			print("物品数量不足，无法交换")
			var _ANI = $Control / BG / Recycle / TextureProgress / Ani

			_ANI.play("OnlyOne")
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

	while true:
		var status = Steam.getResultStatus(result)
		if status != 22:

			if status == 1:
				var _ARRAY = Steam.getResultItems(result)
				if _ARRAY.size() >= 1:
					print(" 分解测试：", _ARRAY)
					for _DIC in _ARRAY:
						if _DIC.has("item_definition"):
							var _ITEMID: int = int(_DIC.item_definition)
							var _ITEMNUM: int = int(_DIC.quantity)
							if SteamLogic._EQUIPDIC.has(_ITEMID):
								var _test = SteamLogic._EQUIPDIC[_ITEMID]
								if SteamLogic._EQUIPDIC[_ITEMID].Id == _DIC.item_id:
									SteamLogic._EQUIPDIC[_ITEMID].Num = _ITEMNUM
								pass
				print("交换成功")
				call_exchange_finish()
				call_RecycleFinish()
				GameLogic.GameUI.call_CostumeCoin_change()
			else:
				print("交换失败，状态码:", status)
			Steam.destroyResult(result)

			break
		yield(get_tree().create_timer(0.5), "timeout")

func call_LoadInventory():
	SteamLogic.LoadInventory()
