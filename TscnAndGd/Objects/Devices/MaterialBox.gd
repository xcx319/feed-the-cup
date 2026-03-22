extends Head_Object
export (String, "MaterialBox", "MaterialBig") var SelfDev: String = "MaterialBox"

onready var A_But = get_node("But/A")
onready var ItemNode = get_node("TexNode/ItemNode")
onready var FreshAni = $Effect_flies / Ani

var ItemType: String
var ItemFreshType: int
var ItemArray: Array
var ItemMax: int = 20
var CanPutInList = ["薄荷叶", "桑葚", "柠檬片", "西米", "芝士片", "原味珍珠", "黑糖珍珠", "鲜芋", "栗子", "奇亚籽", "草莓", "西瓜块", "香蕉块", "火龙果块", "凤梨块", "芒果块", "葡萄块", "桃子块", "西柚块", "杨梅块", "青桔块", "布朗尼块"]

var HasContent: bool
var HasWater: bool
var IsFreezer: bool
var IsPassDay: bool
var IsBroken: bool
var Liquid_Count: int = 0
var Audio
var _EXTRA_LIST: Array = ["小熊软糖", "话梅", "布朗尼块", "黑曲奇块", "西米", "红豆", "椰果", "仙草冻", "燕麦", "花生", "脆波波", "果冻", "葡萄干", "原味珍珠", "黑糖珍珠", "鲜芋", "栗子", "奇亚籽", "酒酿", "仙草冻"]
var _FRUIT_LIST: Array = ["桑葚", "草莓", "西瓜块", "香蕉块", "火龙果块", "凤梨块", "芒果块", "葡萄块", "桃子块", "西柚块", "杨梅块", "牛油果块"]
var _CONDIMENT_LIST: Array = ["薄荷叶", "柠檬片", "芝士片", "青桔块", "黑曲奇完整", "糖渍樱桃"]

func But_Switch(_Switch, _Player):
	if not _Player.Con.IsHold:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	.But_Switch(_Switch, _Player)
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ready() -> void :
	call_init(SelfDev)
	if SelfDev == "MaterialBig":
		ItemMax = 30

	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	Audio = GameLogic.Audio.return_Effect("气泡")
	call_NumShow()
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if get_parent().name in ["A", "B", "X", "Y"]:
		call_InFreezerBox(true)
func return_DropCount():
	return Weight
func call_InFreezerBox(_Switch: bool):
	match _Switch:
		true:
			IsFreezer = true
		false:
			IsFreezer = false
func _DayClosedCheck():
	match ItemFreshType:
		1, 2:
			if IsFreezer:
				if not IsPassDay:
					IsPassDay = true
				else:
					IsBroken = true
			else:
				IsBroken = true
		3:
			if not IsFreezer:
				if not IsPassDay:
					IsPassDay = true
				else:
					IsBroken = true
		4:
			IsBroken = true
	if ItemArray.size():
		if not IsFreezer:
			if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.MATERIALBOX):
				GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.MATERIALBOX)

func call_NumShow():

	if ItemArray.size():
		$NumLabel.text = str(ItemArray.size())
		$NumLabel.show()
	else:
		$NumLabel.text = str(0)
		$NumLabel.hide()
	pass

func call_ItemInBox(_Item):
	ItemArray.append(_Item)
	if not is_instance_valid(_Item):
		ItemArray.erase(_Item)
	else:
		if SelfDev in ["MaterialBig"]:
			_Item.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
		else:
			_Item.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
		ItemNode.add_child(_Item)
	if not HasContent:
		HasContent = true
	if not Weight:
		Weight = 1

	call_NumShow()

func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("Type"):
		if _Info.Type:

			ItemType = _Info.Type
			call_ItemLoad(_Info.Number)
	if _Info.Number > 0:
		if _Info.has("IsPassDay"):
			IsPassDay = _Info.IsPassDay
			IsBroken = _Info.IsBroken
			IsFreezer = _Info.IsFreezer
	if _Info.has("ItemFreshType"):
		ItemFreshType = _Info.ItemFreshType

	_fressless_check()
	call_NumShow()

func _fressless_check():
	if IsBroken:
		FreshAni.play("Flies")
	elif IsPassDay:
		FreshAni.play("OverDay")
	else:
		FreshAni.play("init")
func call_ItemLoad(_Num):
	call_SaveClear()
	if ItemType in _FRUIT_LIST:
		var _FruitTSCN = GameLogic.TSCNLoad.Fruit_TSCN
		for i in _Num:
			var _FruitObj = _FruitTSCN.instance()
			call_ItemInBox(_FruitObj)
			_FruitObj.call_load_TSCN(ItemType)
	elif ItemType in _EXTRA_LIST:
		var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
		for i in _Num:
			var _ExtraObj = _EXTRATSCN.instance()
			call_ItemInBox(_ExtraObj)
			_ExtraObj.call_init(ItemType)
	elif ItemType in _CONDIMENT_LIST:
		var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
		for i in _Num:
			if ItemType in ["黑曲奇完整"]:
				var _ExtraObj = _EXTRATSCN.instance()
				call_ItemInBox(_ExtraObj)
				_ExtraObj.call_init(ItemType)
			else:
				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				call_ItemInBox(_FruitObj)
				_FruitObj.call_init(ItemType)
				_FruitObj.call_bag_tex_set()

func call_SaveClear():
	if ItemArray.size():
		for _Node in ItemArray:
			if is_instance_valid(_Node):
				_Node.get_parent().remove_child(_Node)
				_Node.queue_free()
	ItemArray.clear()

func call_PutInBox_puppet(_TYPE, _DEVPATH):
	match _TYPE:
		"Material1":
			var _DevObj = get_node(_DEVPATH)
			var _NUM: int = _DevObj.ItemArray.size()
			for _i in _NUM:
				var _Node = _DevObj.ItemArray.pop_back()
				_DevObj.ItemNode.remove_child(_Node)
				if SelfDev in ["MaterialBig"]:
					_Node.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
				else:
					_Node.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
				ItemArray.append(_Node)
				ItemNode.add_child(_Node)
			ItemType = _DevObj.ItemType
			if _DevObj.get("IsBroken"):
				IsBroken = true
			if _DevObj.get("IsPassDay"):
				IsPassDay = true
			_fressless_check()
			_DevObj._fressless_check()
			_DevObj.ItemType = ""
			call_Item_Check()
			_DevObj.call_Item_Check()

			HasContent = true
			_DevObj.HasContent = false
			if GameLogic.Config.ItemConfig.has(ItemType):
				ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
			_DevObj.ItemFreshType = 0
			call_NumShow()
			_DevObj.call_NumShow()
			Audio.play(0)

		"Material2":
			var _DevObj = get_node(_DEVPATH)
			var _NUM: int = ItemArray.size()
			for _i in _NUM:
				var _Node = ItemArray.pop_back()
				ItemNode.remove_child(_Node)
				if _DevObj.SelfDev in ["MaterialBig"]:
					_Node.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
				else:
					_Node.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
				_DevObj.ItemArray.append(_Node)
				_DevObj.ItemNode.add_child(_Node)
			_DevObj.ItemType = ItemType
			ItemType = ""
			if GameLogic.Config.ItemConfig.has(_DevObj.ItemType):
				_DevObj.ItemFreshType = int(GameLogic.Config.ItemConfig[_DevObj.ItemType].FreshType)
			ItemFreshType = 0
			if IsBroken:
				_DevObj.IsBroken = true
			if IsPassDay:
				_DevObj.IsPassDay = true
			_fressless_check()
			_DevObj._fressless_check()
			call_Item_Check()
			_DevObj.call_Item_Check()
			HasContent = false
			_DevObj.HasContent = true

			call_NumShow()
			_DevObj.call_NumShow()
			Audio.play(0)

		"Material3":
			var _DevObj = get_node(_DEVPATH)
			var _NUM: int = _DevObj.ItemArray.size()
			for _i in _NUM:
				var _Node = _DevObj.ItemArray.pop_back()
				_DevObj.ItemNode.remove_child(_Node)
				if SelfDev in ["MaterialBig"]:
					_Node.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
				else:
					_Node.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
				ItemArray.append(_Node)
				ItemNode.add_child(_Node)
			ItemType = _DevObj.ItemType
			_DevObj.ItemType = ""
			if GameLogic.Config.ItemConfig.has(ItemType):
				ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
			_DevObj.ItemFreshType = 0
			if _DevObj.get("IsBroken"):
				IsBroken = true
			if _DevObj.get("IsPassDay"):
				IsPassDay = true
			_fressless_check()
			_DevObj._fressless_check()
			call_Item_Check()
			_DevObj.call_Item_Check()
			HasContent = true
			_DevObj.HasContent = false
			call_NumShow()
			_DevObj.call_NumShow()
			Audio.play(0)
		"BigPot_Fruit":
			var _DevObj = get_node(_DEVPATH)
			if _DevObj.get("IsBroken"):
				IsBroken = true
			if _DevObj.get("IsPassDay"):
				IsPassDay = true
			_fressless_check()
			if ItemType != _DevObj.ContentType:
				ItemType = _DevObj.ContentType
			if GameLogic.Config.ItemConfig.has(ItemType):
				ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
			var _ItemTSCN = GameLogic.TSCNLoad.Fruit_TSCN
			for _i in 10:
				var _Item = _ItemTSCN.instance()
				call_ItemInBox(_Item)
				_Item.call_load_TSCN(ItemType)
			_DevObj.call_content_out()
		"FruitCore":
			var _DevObj = get_node(_DEVPATH)
			var _NUM: int = ItemMax - ItemArray.size()
			if _NUM > _DevObj.FruitNum:
				_NUM = _DevObj.FruitNum
			if ItemType != _DevObj.FruitName:
				ItemType = _DevObj.FruitName
			if _DevObj.get("IsPassDay"):
				IsPassDay = _DevObj.IsPassDay
			if _DevObj.get("IsBroken"):
				IsBroken = _DevObj.IsBroken
			var _ItemTSCN = GameLogic.TSCNLoad.Fruit_TSCN
			for _i in _NUM:
				var _Item = _ItemTSCN.instance()
				call_ItemInBox(_Item)
				_Item.call_load_TSCN(_DevObj.FruitName)
			_DevObj.call_Fruit_Out_Num(_NUM)
			Audio.play(0)
			return "装小料盒"

		"Can":

			var _CANOBJ = get_node(_DEVPATH)
			if ItemType != _CANOBJ.FuncTypePara:
				ItemType = _CANOBJ.FuncTypePara
			if _CANOBJ.get("CanUse") and ItemType in ["黑曲奇完整"]:
				ItemType = "黑曲奇块"
			ItemFreshType = _CANOBJ.FreshType
			if _CANOBJ.get("IsPassDay"):
				IsPassDay = _CANOBJ.IsPassDay
			if _CANOBJ.get("Freshless_bool"):
				IsBroken = _CANOBJ.Freshless_bool
			_fressless_check()
			var _ItemTSCN = GameLogic.TSCNLoad.Extra_TSCN
			for _i in _CANOBJ.Num:
				var _Item = _ItemTSCN.instance()
				call_ItemInBox(_Item)
				_Item.call_init(ItemType)
			_CANOBJ.call_AddAll()
		"WorkBoard":
			var _DevObj = get_node(_DEVPATH)
			if _DevObj.get("IsBroken"):
				IsBroken = true
			if _DevObj.get("IsPassDay"):
				IsPassDay = true
			_fressless_check()
			if ItemType != _DevObj.ItemType:
				ItemType = _DevObj.ItemType

			if GameLogic.Config.ItemConfig.has(ItemType):
				ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
			var _ReturnList = _DevObj.return_MoveInBoxList(ItemMax - ItemArray.size())
			if _ReturnList:
				for _Item in _ReturnList:
					call_ItemInBox(_Item)
		"BigPot":
			var _DevObj = get_node(_DEVPATH)
			if _DevObj.get("IsBroken"):
				IsBroken = true
			if _DevObj.get("IsPassDay"):
				IsPassDay = true
			_fressless_check()
			if ItemType != _DevObj.ContentType:
				ItemType = _DevObj.ContentType
			if GameLogic.Config.ItemConfig.has(ItemType):
				ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
			var _ItemTSCN = GameLogic.TSCNLoad.Extra_TSCN
			for _i in 10:
				var _Item = _ItemTSCN.instance()
				call_ItemInBox(_Item)
				_Item.call_init(ItemType)
			_DevObj.call_content_out()

func call_PutInBox(_ButID, _DevObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if IsBroken:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if _DevObj.get("SelfDev") == "WorkBoard":
				if _DevObj.SaveNodeList.size():
					if ItemArray.size() < ItemMax:
						if not ItemType:
							A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
							But_Switch(true, _Player)
						elif _DevObj.ItemType == ItemType:
							A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
							But_Switch(true, _Player)
						else:
							A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)

			if _DevObj.get("SelfDev") == "BigPot" and ItemArray.size() <= 10:

				if _DevObj.cur_TYPE in [6, 7] and _DevObj.Liquid_Count == 0:
					if _DevObj.ContentType in CanPutInList:
						A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
						But_Switch(true, _Player)
					else:
						A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
			if _DevObj.FuncType == "Can":
				if not _DevObj.CanUse or _DevObj.Num == 0:
					return
				if ItemType == str(_DevObj.FuncTypePara) and ItemArray.size() <= 10 and ItemArray.size() > 0:
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
					But_Switch(true, _Player)
				elif ItemArray.size() == 0:
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
					But_Switch(true, _Player)
				else:
					A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
			if _DevObj.FuncType in ["MaterialBox", "MaterialBig"]:
				if ItemType != "" and _DevObj.ItemType == ItemType:
					if ItemArray.size() + _DevObj.ItemArray.size() <= ItemMax:
						A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
						But_Switch(true, _Player)
				elif ItemType != "" and _DevObj.ItemType == "":
					if ItemArray.size() + _DevObj.ItemArray.size() <= _DevObj.ItemMax:
						_DevObj.A_But.InfoLabel.text = GameLogic.CardTrans.get_message(_DevObj.A_But.Info_1)
						_DevObj.But_Switch(true, _Player)
				elif ItemType == "" and _DevObj.ItemType != "":
					if ItemArray.size() + _DevObj.ItemArray.size() <= ItemMax:
						A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
						But_Switch(true, _Player)
		0:

			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				if _DevObj.get("FuncType") == "Can":
					if not _DevObj.CanUse or _DevObj.Num == 0:
						return
					if ItemType == str(_DevObj.FuncTypePara) and ItemArray.size() <= 10 and ItemArray.size() > 0 and _DevObj.Num > 0:
						return "装小料盒"
					elif ItemArray.size() == 0 and _DevObj.Num > 0:
						return "装小料盒"
				if _DevObj.get("SelfDev") == "BigPot" and ItemArray.size() <= 10:

					if _DevObj.Liquid_Count > 0:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_DropWater()
							return
				if _DevObj.get("SelfDev") == "BobaMachine" and ItemArray.size() <= 10:

					if _DevObj.cur_TYPE == 4:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_DropWater()
							return
					if _DevObj.cur_TYPE == 5:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_AddSugar()
							return
				if _DevObj.get("SelfDev") == "WorkBoard" and ItemArray.size() < ItemMax:
					if _DevObj.ItemType in CanPutInList:
						if ItemType == "" or ItemType == _DevObj.ItemType:
							pass
						else:
							_Player.call_Say_NoUse()
							return
				return

			if _DevObj.get("FuncType") in ["MaterialBox", "MaterialBig"]:

				if ItemType != "" and _DevObj.ItemType == ItemType:
					if ItemArray.size() + _DevObj.ItemArray.size() <= ItemMax:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["Material1", _DEVPATH])
						var _NUM: int = _DevObj.ItemArray.size()
						for _i in _NUM:
							var _Node = _DevObj.ItemArray.pop_back()
							_DevObj.ItemNode.remove_child(_Node)
							if SelfDev in ["MaterialBig"]:
								_Node.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
							else:
								_Node.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
							ItemArray.append(_Node)
							ItemNode.add_child(_Node)
						ItemType = _DevObj.ItemType
						if _DevObj.get("IsBroken"):
							IsBroken = true
						if _DevObj.get("IsPassDay"):
							IsPassDay = true
						_fressless_check()
						_DevObj._fressless_check()
						_DevObj.ItemType = ""
						call_Item_Check()
						_DevObj.call_Item_Check()

						HasContent = true
						_DevObj.HasContent = false
						if GameLogic.Config.ItemConfig.has(ItemType):
							ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
						_DevObj.ItemFreshType = 0
						call_NumShow()
						_DevObj.call_NumShow()
						Audio.play(0)
						_DevObj.call_PutInBox( - 1, self, _Player)
						call_PutInBox( - 2, _DevObj, _Player)
						pass
				elif ItemType != "" and _DevObj.ItemType == "":
					if ItemArray.size() + _DevObj.ItemArray.size() <= _DevObj.ItemMax:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["Material2", _DEVPATH])
						var _NUM: int = ItemArray.size()
						for _i in _NUM:
							var _Node = ItemArray.pop_back()
							ItemNode.remove_child(_Node)
							if _DevObj.SelfDev in ["MaterialBig"]:
								_Node.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
							else:
								_Node.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
							_DevObj.ItemArray.append(_Node)
							_DevObj.ItemNode.add_child(_Node)
						_DevObj.ItemType = ItemType
						ItemType = ""
						if GameLogic.Config.ItemConfig.has(_DevObj.ItemType):
							_DevObj.ItemFreshType = int(GameLogic.Config.ItemConfig[_DevObj.ItemType].FreshType)
						ItemFreshType = 0
						if IsBroken:
							_DevObj.IsBroken = true
						if IsPassDay:
							_DevObj.IsPassDay = true
						_fressless_check()
						_DevObj._fressless_check()
						call_Item_Check()
						_DevObj.call_Item_Check()
						HasContent = false
						_DevObj.HasContent = true

						call_NumShow()
						_DevObj.call_NumShow()
						Audio.play(0)
						_DevObj.call_PutInBox( - 2, self, _Player)
						call_PutInBox( - 1, _DevObj, _Player)
				elif ItemType == "" and _DevObj.ItemType != "":
					if ItemArray.size() + _DevObj.ItemArray.size() <= ItemMax:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["Material3", _DEVPATH])
						var _NUM: int = _DevObj.ItemArray.size()
						for _i in _NUM:
							var _Node = _DevObj.ItemArray.pop_back()
							_DevObj.ItemNode.remove_child(_Node)
							if SelfDev in ["MaterialBig"]:
								_Node.position = Vector2(rand_range( - 30, 30), rand_range( - 30, - 14))
							else:
								_Node.position = Vector2(rand_range( - 10, 10), rand_range( - 30, - 14))
							ItemArray.append(_Node)
							ItemNode.add_child(_Node)
						ItemType = _DevObj.ItemType
						_DevObj.ItemType = ""
						if GameLogic.Config.ItemConfig.has(ItemType):
							ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
						_DevObj.ItemFreshType = 0
						if _DevObj.get("IsBroken"):
							IsBroken = true
						if _DevObj.get("IsPassDay"):
							IsPassDay = true
						_fressless_check()
						_DevObj._fressless_check()
						call_Item_Check()
						_DevObj.call_Item_Check()
						HasContent = true
						_DevObj.HasContent = false
						call_NumShow()
						_DevObj.call_NumShow()
						Audio.play(0)
						_DevObj.call_PutInBox( - 1, self, _Player)
						call_PutInBox( - 2, _DevObj, _Player)
			if _DevObj.get("FuncType") == "Box" and ItemArray.size() < ItemMax:
				if _DevObj.ItemName in CanPutInList:
					if ItemType == "" or ItemType == _DevObj.ItemName:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["WorkBoard", _DEVPATH])

						if ItemType != _DevObj.ItemName:
							ItemType = _DevObj.ItemName

						_fressless_check()
						var _ReturnList = _DevObj.return_MoveInBoxList(ItemMax - ItemArray.size())
						if _ReturnList:
							But_Switch(false, _Player)
							for _Item in _ReturnList:
								call_ItemInBox(_Item)
							return "装小料盒"
			if _DevObj.get("SelfDev") == "WorkBoard" and ItemArray.size() < ItemMax:

				if _DevObj.ItemType in CanPutInList:
					if ItemType == "" or ItemType == _DevObj.ItemType:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["WorkBoard", _DEVPATH])

						if ItemType != _DevObj.ItemType:
							ItemType = _DevObj.ItemType
						if GameLogic.Config.ItemConfig.has(ItemType):
							ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
						if _DevObj.get("IsBroken"):
							IsBroken = true
						if _DevObj.get("IsPassDay"):
							IsPassDay = true
						_fressless_check()

						var _ReturnList = _DevObj.return_MoveInBoxList(ItemMax - ItemArray.size())
						if _ReturnList:
							But_Switch(false, _Player)
							for _Item in _ReturnList:
								call_ItemInBox(_Item)
							return "装小料盒"
					else:
						_Player.call_Say_NoUse()
						return
			elif _DevObj.get("SelfDev") == "FruitCore":
				if _DevObj.FruitName in ["杨梅块"]:
					if ItemType == "" or ItemType == _DevObj.FruitName:
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["FruitCore", _DEVPATH])
						if ItemArray.size() + _DevObj.FruitNum <= ItemMax:
							var _NUM: int = ItemMax - ItemArray.size()
							if _NUM > _DevObj.FruitNum:
								_NUM = _DevObj.FruitNum
							if ItemType != _DevObj.FruitName:
								ItemType = _DevObj.FruitName
							if GameLogic.Config.ItemConfig.has(ItemType):
								ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
							if _DevObj.get("IsBroken"):
								IsBroken = true
							_fressless_check()

							var _ItemTSCN = GameLogic.TSCNLoad.Fruit_TSCN
							for _i in _NUM:
								var _Item = _ItemTSCN.instance()
								call_ItemInBox(_Item)
								_Item.call_load_TSCN(_DevObj.FruitName)
							_DevObj.call_Fruit_Out_Num(_NUM)
							Audio.play(0)
							return "装小料盒"
						elif _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:

							return
				pass
			elif _DevObj.get("SelfDev") == "BigPot" and ItemArray.size() + 10 <= ItemMax:

				if _DevObj.Liquid_Count > 0:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_DropWater()
						return
				if _DevObj.cur_TYPE == 6 and _DevObj.Liquid_Count == 0:
					if ItemType == "" or ItemType == _DevObj.ContentType:
						if _DevObj.ContentType in CanPutInList:
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _DEVPATH = _DevObj.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["BigPot", _DEVPATH])
							if ItemType == "":
								ItemType = _DevObj.ContentType
							if _DevObj.get("IsBroken"):
								IsBroken = true
							if _DevObj.get("IsPassDay"):
								IsPassDay = true
							_fressless_check()
							if GameLogic.Config.ItemConfig.has(ItemType):
								ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
							var _ItemTSCN = GameLogic.TSCNLoad.Extra_TSCN
							for _i in 10:
								var _Item = _ItemTSCN.instance()
								call_ItemInBox(_Item)
								_Item.call_init(_DevObj.ContentType)
							_DevObj.call_content_out()
					return "装小料盒"
				if _DevObj.ContentType in ["葡萄块"]:
					if ItemType == "" or ItemType == _DevObj.ContentType:
						if ItemArray.size() + 10 > ItemMax:
							return
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _DEVPATH = _DevObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["BigPot_Fruit", _DEVPATH])
						if ItemType == "":
							ItemType = _DevObj.ContentType
						if GameLogic.Config.ItemConfig.has(ItemType):
							ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
						if _DevObj.get("IsBroken"):
								IsBroken = true
						if _DevObj.get("IsPassDay"):
							IsPassDay = true
						_fressless_check()
						if GameLogic.Config.ItemConfig.has(ItemType):
							ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
						var _ItemTSCN = GameLogic.TSCNLoad.Fruit_TSCN
						for _i in 10:
							var _Item = _ItemTSCN.instance()
							call_ItemInBox(_Item)
							_Item.call_load_TSCN(_DevObj.ContentType)
						_DevObj.call_content_out()
						return "装小料盒"
			elif _DevObj.get("SelfDev") == "BobaMachine" and ItemArray.size() <= 10:

				if _DevObj.cur_TYPE == 4:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_DropWater()
						return
				if _DevObj.cur_TYPE == 5:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_AddSugar()
						return
				if _DevObj.cur_TYPE == 7:
					if ItemType == "" or ItemType == _DevObj.ContentType:
						if _DevObj.ContentType in CanPutInList:
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _DEVPATH = _DevObj.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["BigPot", _DEVPATH])
							if ItemType == "":
								ItemType = _DevObj.ContentType
							if _DevObj.get("IsBroken"):
								IsBroken = true
							if _DevObj.get("IsPassDay"):
								IsPassDay = true
							_fressless_check()
							if GameLogic.Config.ItemConfig.has(ItemType):
								ItemFreshType = int(GameLogic.Config.ItemConfig[ItemType].FreshType)
							var _ItemTSCN = GameLogic.TSCNLoad.Extra_TSCN
							for _i in 10:
								var _Item = _ItemTSCN.instance()
								call_ItemInBox(_Item)
								_Item.call_init(ItemType)
							_DevObj.call_content_out()
					return "装小料盒"
			elif _DevObj.FuncType == "Can":
				if _DevObj.Num <= 0:
					return
				if _DevObj.TypeStr in ["bag_BlackCookie"]:
					if not _DevObj.CanUse:
						if ItemArray.size() > 0:
							if ItemType == "黑曲奇完整":
								if ItemArray.size() + 10 <= ItemMax:
									_Can_In_Logic(_DevObj)
									return "装小料盒"
						elif ItemArray.size() + 10 <= ItemMax:
							_Can_In_Logic(_DevObj)
							return "装小料盒"
					elif _DevObj.CanUse:
						if ItemArray.size() > 0:
							if ItemType == "黑曲奇块":
								if ItemArray.size() + 10 <= ItemMax:
									_Can_In_Logic(_DevObj)
									return "装小料盒"
						elif ItemArray.size() + 10 <= ItemMax:
							_Can_In_Logic(_DevObj)
							return "装小料盒"
					return
				if not _DevObj.CanUse:
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Player.call_Say_NoUse()
					return
				if ItemType == str(_DevObj.FuncTypePara) and ItemArray.size() + _DevObj.Num <= ItemMax:
					_Can_In_Logic(_DevObj)
					return "装小料盒"
				elif ItemArray.size() == 0 and _DevObj.Num > 0:
					_Can_In_Logic(_DevObj)
					return "装小料盒"

func _Can_In_Logic(_CANOBJ):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _DEVPATH = _CANOBJ.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_PutInBox_puppet", ["Can", _DEVPATH])
	if ItemType != str(_CANOBJ.FuncTypePara):
		ItemType = str(_CANOBJ.FuncTypePara)
	if _CANOBJ.get("CanUse") and ItemType in ["黑曲奇完整"]:
		ItemType = "黑曲奇块"
	ItemFreshType = _CANOBJ.FreshType
	if _CANOBJ.get("IsPassDay"):
		IsPassDay = _CANOBJ.IsPassDay
	if _CANOBJ.get("Freshless_bool"):
		IsBroken = _CANOBJ.Freshless_bool
	var _ItemTSCN = GameLogic.TSCNLoad.Extra_TSCN
	for _i in _CANOBJ.Num:
		var _Item = _ItemTSCN.instance()
		call_ItemInBox(_Item)
		_Item.call_init(ItemType)
	_CANOBJ.call_AddAll()
	_fressless_check()
func call_Drop():
	if IsBroken:
		IsBroken = false
	if IsPassDay:
		IsPassDay = false
	if HasContent:
		HasContent = false
	ItemType = ""
	if ItemArray.size():
		for _Item in ItemArray:
			if is_instance_valid(_Item):
				_Item.queue_free()
	ItemArray.clear()
	_fressless_check()
	call_NumShow()
func call_put_in_cup_puppet(_TYPE, _ButID, _PLAYERPATH, _OBJPATH):
	ItemType = _TYPE
	var _HoldObj = get_node(_OBJPATH)
	var _Player = get_node(_PLAYERPATH)
	var _FUNCTYPE = _HoldObj.FuncType
	match _HoldObj.FuncType:
		"Can", "WorkBoard":
			return call_PutInBox(_ButID, _HoldObj, _Player)

		"DrinkCup", "SuperCup":
			if ItemType in _EXTRA_LIST or ItemType in _FRUIT_LIST:
				if ItemArray.size():
					var _CheckExtra: int = 0
					if _HoldObj.get("Extra_1") == "":
						_CheckExtra = 1
					elif _HoldObj.get("Extra_2") == "" and _HoldObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M"]:
						_CheckExtra = 2
					elif _HoldObj.get("Extra_3") == "" and _HoldObj.TYPE in ["DrinkCup_L", "SuperCup_M"]:
						_CheckExtra = 3
					elif _HoldObj.get("Extra_4") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
						_CheckExtra = 4
					elif _HoldObj.get("Extra_5") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
						_CheckExtra = 5
					if _CheckExtra > 0:
						var _Node = ItemArray.pop_back()
						ItemNode.remove_child(_Node)
						_Node.queue_free()
						match _CheckExtra:
							1:
								_HoldObj.Extra_1 = ItemType
							2:
								_HoldObj.Extra_2 = ItemType
							3:
								_HoldObj.Extra_3 = ItemType
							4:
								_HoldObj.Extra_4 = ItemType
							5:
								_HoldObj.Extra_5 = ItemType
						_HoldObj.call_add_extra()
						call_put_in_cup( - 1, _Player, _HoldObj)

					Audio.play(0)
					call_NumShow()
					call_Item_Check()
					return 0
			elif ItemType in _CONDIMENT_LIST:
				if ItemArray.size() and not _HoldObj.get("Condiment_1"):
					var _Node = ItemArray.pop_back()
					ItemNode.remove_child(_Node)
					_Node.queue_free()
					_HoldObj.call_add_condiment(ItemType)
					call_put_in_cup( - 1, _Player, _HoldObj)
					if not ItemArray.size():
						ItemType = ""
						HasContent = false
					Audio.play(0)
					call_NumShow()
					return "加辅料"


func call_cup_puppet(_ITEMARRAYSIZE):
	if ItemArray.size() > _ITEMARRAYSIZE:
		var _Node = ItemArray.pop_back()
		ItemNode.remove_child(_Node)
		_Node.queue_free()
	call_Item_Check()
	Audio.play(0)
	call_NumShow()
func call_put_in_cup(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if IsBroken:

				return
			if get_parent().name in ["A", "B", "X", "Y"]:
				return
			if _HoldObj.FuncType in ["Box"]:
				return
			elif _HoldObj.Condiment_1:
				call_put_in_cup( - 2, _Player, _HoldObj)
			else:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
				But_Switch(true, _Player)
		0:
			if IsBroken:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			match _HoldObj.FuncType:
				"Can":
					var _Str = _HoldObj.TypeStr
					if not _HoldObj.CanUse and not _Str in ["bag_BlackCookie"]:
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
				"DrinkCup", "SuperCup", "SodaCan", "EggRollCup":
					if _HoldObj.Top != "":
						if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
							_Player.call_Say_NoUse()
						return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			var _FUNCTYPE = _HoldObj.FuncType
			match _FUNCTYPE:
				"Box":
					return call_PutInBox(_ButID, _HoldObj, _Player)
				"Can", "WorkBoard":
					return call_PutInBox(_ButID, _HoldObj, _Player)

				"EggRollCup":
					if ItemType in _EXTRA_LIST or ItemType in _FRUIT_LIST:
						if ItemArray.size():
							var _CheckExtra: int = 0
							match _HoldObj.Liquid_Count:
								2:
									if _HoldObj.Extra_1 == "":
										_CheckExtra = 1
								4:
									if _HoldObj.Extra_2 == "":
										_CheckExtra = 2
								6:
									if _HoldObj.Extra_3 == "":
										_CheckExtra = 3
							if _CheckExtra > 0:
								var _Node = ItemArray.pop_back()
								ItemNode.remove_child(_Node)
								_Node.queue_free()
								match _CheckExtra:
									1:
										_HoldObj.Extra_1 = ItemType
									2:
										_HoldObj.Extra_2 = ItemType
									3:
										_HoldObj.Extra_3 = ItemType
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									var _PLAYERPATH = _Player.get_path()
									var _OBJPATH = _HoldObj.get_path()
									SteamLogic.call_puppet_id_sync(_SELFID, "call_cup_puppet", [ItemArray.size()])
								if IsPassDay:
									_HoldObj.call_add_PassDay()
								_HoldObj.call_add_extra()
								call_put_in_cup( - 1, _Player, _HoldObj)
								call_Item_Check()
								Audio.play(0)
								call_NumShow()
					elif ItemType in _CONDIMENT_LIST:
						if ItemArray.size() and not _HoldObj.Condiment_1:
							var _Node = ItemArray.pop_back()
							ItemNode.remove_child(_Node)
							_Node.queue_free()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _PLAYERPATH = _Player.get_path()
								var _OBJPATH = _HoldObj.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_cup_puppet", [ItemArray.size()])
							_HoldObj.call_add_condiment(ItemType)
							call_put_in_cup( - 1, _Player, _HoldObj)
							call_Item_Check()
							Audio.play(0)
							call_NumShow()
							return "加辅料"
				"DrinkCup", "SuperCup", "SodaCan":
					if ItemType in _EXTRA_LIST or ItemType in _FRUIT_LIST:
						if ItemArray.size():
							var _CheckExtra: int = 0
							if _HoldObj.Extra_1 == "":
								_CheckExtra = 1
							elif _HoldObj.Extra_2 == "" and _HoldObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M", "BeerCup_M", "BeerCup_L"]:
								_CheckExtra = 2
							elif _HoldObj.Extra_3 == "" and _HoldObj.TYPE in ["DrinkCup_L", "SuperCup_M", "BeerCup_L"]:
								_CheckExtra = 3
							elif _HoldObj.get("Extra_4") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 4
							elif _HoldObj.get("Extra_5") == "" and _HoldObj.TYPE in ["SuperCup_M"]:
								_CheckExtra = 5
							if _CheckExtra > 0:
								var _Node = ItemArray.pop_back()
								ItemNode.remove_child(_Node)
								_Node.queue_free()
								match _CheckExtra:
									1:
										_HoldObj.Extra_1 = ItemType
									2:
										_HoldObj.Extra_2 = ItemType
									3:
										_HoldObj.Extra_3 = ItemType
									4:
										_HoldObj.Extra_4 = ItemType
									5:
										_HoldObj.Extra_5 = ItemType
								if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
									var _PLAYERPATH = _Player.get_path()
									var _OBJPATH = _HoldObj.get_path()
									SteamLogic.call_puppet_id_sync(_SELFID, "call_cup_puppet", [ItemArray.size()])
								if IsPassDay:
									_HoldObj.call_add_PassDay()
								_HoldObj.call_add_extra()
								call_put_in_cup( - 1, _Player, _HoldObj)
								call_Item_Check()
								Audio.play(0)
								call_NumShow()
								return "加小料"
							return false
					elif ItemType in _CONDIMENT_LIST:
						if ItemArray.size() and not _HoldObj.Condiment_1:
							var _Node = ItemArray.pop_back()
							ItemNode.remove_child(_Node)
							_Node.queue_free()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _PLAYERPATH = _Player.get_path()
								var _OBJPATH = _HoldObj.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_cup_puppet", [ItemArray.size()])
							_HoldObj.call_add_condiment(ItemType)
							call_put_in_cup( - 1, _Player, _HoldObj)
							call_Item_Check()
							Audio.play(0)
							call_NumShow()
							return "加辅料"

func call_Item_Check():
	if not ItemArray.size():
		ItemType = ""
		HasContent = false
		IsBroken = false
		IsPassDay = false
		_fressless_check()

func _on_body_entered(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
