extends Head_Object
var SelfDev = "WorkBoard"

onready var ItemType: String = ""
var PlayerList: Array

var _Pressed: bool
var SaveNodeList: Array
var IsBroken: bool
var IsPassDay: bool
onready var MixAni = get_node("MixNode/MixAni")
onready var FreshAni = $Effect_flies / Ani
onready var A_But = get_node("But/A")
onready var X_But = get_node("But/X")
onready var Y_But = get_node("But/Y")

var PickBool: bool
var CanPutList = ["柠檬", "芝士", "芋头", "青桔", "香蕉", "西瓜", "凤梨", "火龙果", "bag_BrownieCake", "布朗尼蛋糕", "薄荷枝"]
var PassDayList = ["薄荷叶", "柠檬片", "芝士", "芝士片", "芋头块", "青桔块", "香蕉块", "西瓜块", "凤梨块", "火龙果块", "bag_BrownieCake", "布朗尼蛋糕", "布朗尼块"]

var _InCupList: Array = ["薄荷叶", "柠檬片", "芝士片", "青桔块", "西瓜块", "香蕉块", "凤梨块", "火龙果块", "布朗尼块"]
onready var AUDIO_PUT
onready var AUDIO_PICK
func _ready() -> void :
	call_init("WorkBoard")
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	AUDIO_PUT = GameLogic.Audio.return_Effect("放下")
	AUDIO_PICK = GameLogic.Audio.return_Effect("气泡")


func _CanMove_Check():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if CanLayout:
		if ItemType in ["", "薄荷叶", "柠檬片", "芝士片", "芋头块", "青桔块", "西瓜块", "香蕉块", "凤梨块", "火龙果块", "布朗尼块"]:
			CanMove = true

		else:
			CanMove = false

	else:
		CanMove = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CanMove_Check_puppet", [CanMove])
func call_Audio_Cut():
	var _AUDIO_CUT = GameLogic.Audio.return_RandEffect("切脆")
	_AUDIO_CUT.play(0)
func _DayClosedCheck():
	if not is_instance_valid(self):
		return


	if ItemType in PassDayList:
		if SaveNodeList.size():
			IsBroken = true

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return

	if IsPassDay or IsBroken:
		Y_But.show()
		X_But.hide()
		A_But.hide()
	else:
		Y_But.hide()
		A_But.show()
	if ItemType in CanPutList:
		if ItemType != "芝士":

			X_But.show()
			PickBool = true
		else:
			X_But.show()
			PickBool = false
	else:
		X_But.hide()
		PickBool = false

	if CanMove and not _Player.Con.IsHold:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
	elif PickBool:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	else:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	A_But.show()

	if not ItemType in CanPutList:
		if not _Player.Con.IsHold:
			if ItemType == "垃圾":
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			elif not CanMove:
				A_But.hide()
	if ItemType == "芝士":
		A_But.hide()

	.But_Switch(_bool, _Player)
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay
	if _Info.has("IsBroken"):
		IsBroken = _Info.IsBroken
	_DayClosedCheck()
	_freshless_logic()

	if _Info.has("Type"):
		if _Info.Type:
			ItemType = _Info.Type


			call_ItemLoad(_Info.Number)
	_CanMove_Check()
func _freshless_logic():
	if IsBroken:
		FreshAni.play("Flies")
	elif IsPassDay:
		FreshAni.play("OverDay")
	else:
		FreshAni.play("init")

func call_put_puppet(_TYPE, _PLAYERPATH, _DEVPATH, _NAME, _ITEMTYPE):
	match _TYPE:
		0:
			var _Player = get_node(_PLAYERPATH)
			var _Dev = get_node(_DEVPATH)
			if _Dev.get("Freshless_bool"):
				IsBroken = true
			if _Dev.get("IsPassDay"):
				IsPassDay = true
			var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
			var _ExtraObj = _EXTRATSCN.instance()
			_ExtraObj.name = _NAME
			ItemType = _ITEMTYPE
			SavedNode.add_child(_ExtraObj)
			SaveNodeList.append(_ExtraObj)
			_ExtraObj.call_init(ItemType)
			_Dev.call_used()
			call_pick( - 2, _Player)
			_CanMove_Check()
			AUDIO_PUT.play(0)
		1:
			var _Player = get_node(_PLAYERPATH)
			var _Dev = get_node(_DEVPATH)
			if not is_instance_valid(_Player):
				return
			if not is_instance_valid(_Dev):
				return
			_Player.WeaponNode.remove_child(_Dev)
			_Dev.position = Vector2.ZERO

			_Player.Stat.call_carry_off()
			SavedNode.add_child(_Dev)
			ItemType = _Dev.TypeStr
			SaveNodeList.append(_Dev)
			call_pick( - 1, _Player)
			_CanMove_Check()
			AUDIO_PUT.play(0)

func call_canStir(_ButID, _HoldObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _HoldObj.get("Used"):
				return
			But_Switch(true, _Player)
		0:
			if not SaveNodeList.size():
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				var _Dev = instance_from_id(_Player.Con.HoldInsId)

				if not _Dev.get("TypeStr") in CanPutList:
					return
				if _Dev.get("Used"):
					return
				if _Dev.get("TypeStr") == "bag_BrownieCake":
					if _Dev.get("Freshless_bool"):
						IsBroken = true
					if _Dev.get("IsPassDay"):
						IsPassDay = true
					_freshless_logic()
					var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
					var _ExtraObj = _EXTRATSCN.instance()
					var _NAME = str(_ExtraObj.get_instance_id())
					_ExtraObj.name = _NAME
					ItemType = "布朗尼蛋糕"
					SavedNode.add_child(_ExtraObj)
					SaveNodeList.append(_ExtraObj)
					_ExtraObj.call_init(ItemType)
					_Dev.call_used()
					call_pick( - 2, _Player)
					_CanMove_Check()
					AUDIO_PUT.play(0)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _PLAYERPATH = _Player.get_path()
						var _DEVPATH = _Dev.get_path()
						SteamLogic.call_puppet_id_sync(_SELFID, "call_put_puppet", [0, _PLAYERPATH, _DEVPATH, _NAME, ItemType])
					return "放菜板"
				if _Dev.get("TypeStr") == "芝士":
					if _Dev.get("Freshless_bool"):
						IsBroken = true
					if _Dev.get("IsPassDay"):
						IsPassDay = true
					_freshless_logic()
					var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
					var _ExtraObj = _EXTRATSCN.instance()
					var _NAME = str(_ExtraObj.get_instance_id())
					_ExtraObj.name = _NAME
					ItemType = _Dev.TypeStr

					SavedNode.add_child(_ExtraObj)
					SaveNodeList.append(_ExtraObj)
					_ExtraObj.call_init(ItemType)
					_Dev.call_used()
					call_pick( - 2, _Player)
					_CanMove_Check()
					AUDIO_PUT.play(0)
					if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
						var _PLAYERPATH = _Player.get_path()
						var _DEVPATH = _Dev.get_path()
						SteamLogic.call_puppet_id_sync(_SELFID, "call_put_puppet", [0, _PLAYERPATH, _DEVPATH, _NAME, ItemType])
					return "放菜板"
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAYERPATH = _Player.get_path()
					var _DEVPATH = _Dev.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_put_puppet", [1, _PLAYERPATH, _DEVPATH, null, ItemType])
				_Player.WeaponNode.remove_child(_Dev)
				_Dev.position = Vector2.ZERO

				if _Dev.get("TypeStr") == "薄荷枝":
					_Dev.rotation_degrees = 90
				_Player.Stat.call_carry_off()
				SavedNode.add_child(_Dev)
				_Pressed = false

				ItemType = _Dev.TypeStr
				SaveNodeList.append(_Dev)

				call_pick( - 1, _Player)
				_CanMove_Check()
				AUDIO_PUT.play(0)

				return "放菜板"

func call_put_in_cup_puppet(_NODE, _HOLDOBJ, _TYPE):
	var _Node = get_node(_NODE)
	var _HoldObj = get_node(_HOLDOBJ)
	SavedNode.remove_child(_Node)
	_Node.queue_free()
	match _TYPE:
		"柠檬片", "芝士片", "青桔块", "薄荷叶":
			_HoldObj.call_add_condiment(_TYPE)
	if not SaveNodeList.size():
		ItemType = ""
	AUDIO_PUT.play(0)
func call_put_in_cup(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if ItemType == "" or IsBroken:
				return
			But_Switch(true, _Player)
		0:
			if IsBroken:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return

			match ItemType:
				"柠檬片", "芝士片", "青桔块", "薄荷叶":
					if SaveNodeList.size() and not _HoldObj.Condiment_1:
						var _Node = SaveNodeList.pop_back()
						if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
							var _NODE = _Node.get_path()
							var _HOLDOBJ = _HoldObj.get_path()
							SteamLogic.call_puppet_id_sync(_SELFID, "call_put_in_cup_puppet", [_NODE, _HOLDOBJ, ItemType])
						SavedNode.remove_child(_Node)
						_Node.queue_free()
						_HoldObj.call_add_condiment(ItemType)
						if not SaveNodeList.size():
							ItemType = ""
						AUDIO_PUT.play(0)
						_CanMove_Check()
						return "加辅料"
				"香蕉块", "西瓜块", "凤梨块", "火龙果块", "布朗尼块":
					if SaveNodeList.size():
						var _CHECK = _HoldObj.return_add_Extra(ItemType)
						if _CHECK:
							var _Node = SaveNodeList.pop_back()
							if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
								var _NODE = _Node.get_path()
								var _HOLDOBJ = _HoldObj.get_path()
								SteamLogic.call_puppet_id_sync(_SELFID, "call_put_in_cup_puppet", [_NODE, _HOLDOBJ, ItemType])
							SavedNode.remove_child(_Node)
							_Node.queue_free()
							if not SaveNodeList.size():
								ItemType = ""
							AUDIO_PUT.play(0)
							_CanMove_Check()
							return "加辅料"
func call_pick_puppet(_DEVPATH, _PLAYERPATH):
	var _Dev = get_node(_DEVPATH)
	var _Player = get_node(_PLAYERPATH)

	GameLogic.Device.call_Player_Pick(_Player, _Dev)
	if not SaveNodeList.size():
		ItemType = ""
	But_Switch(true, _Player)
func _pick(_Player):
	if not _Player.Con.IsHold:
		var _Dev = SaveNodeList.pop_back()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _DEVPATH = _Dev.get_path()
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_pick_puppet", [_DEVPATH, _PLAYERPATH])

		GameLogic.Device.call_Player_Pick(_Player, _Dev)
		if not SaveNodeList.size():
			ItemType = ""
		_CanMove_Check()
		But_Switch(true, _Player)
		return "拿"
func call_pick(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if SaveNodeList.size():
				But_Switch(true, _Player)
		0:

			if SaveNodeList.size():
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if ItemType in CanPutList:
					if ItemType in ["芝士", "布朗尼蛋糕"]:
						return
					return _pick(_Player)
				elif ItemType == "垃圾":
					return _pick(_Player)
		3:
			if IsBroken or IsPassDay:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				call_trash()
				IsBroken = false
				IsPassDay = false
				FreshAni.play("init")
				But_Switch(true, _Player)
func call_trash_puppet(_NAME):
	call_SaveClear()
	var Trashbag_TSCN = GameLogic.TSCNLoad.return_TSCN("Trashbag")
	var _TrashObj = Trashbag_TSCN.instance()
	_TrashObj.name = _NAME
	SteamLogic.OBJECT_DIC[int(_NAME)] = _TrashObj
	SavedNode.add_child(_TrashObj)
	_TrashObj.call_load({"NAME": _NAME, "Weight": 1})
	_TrashObj.call_Trashbag_init(1, true)
	SaveNodeList.append(_TrashObj)
	ItemType = "垃圾"
	IsBroken = false
	IsPassDay = false
	FreshAni.play("init")
func call_Trashbin_Logic():
	MixAni.play("init")
	call_SaveClear()
	ItemType = ""
	FreshAni.play("init")
	IsBroken = false
	IsPassDay = false
func call_trash():
	var _weight = 1
	call_SaveClear()
	var Trashbag_TSCN = GameLogic.TSCNLoad.return_TSCN("Trashbag")
	var _TrashObj = Trashbag_TSCN.instance()
	var _NAME = str(_TrashObj.get_instance_id())
	_TrashObj.name = _NAME
	SteamLogic.OBJECT_DIC[int(_NAME)] = _TrashObj
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_trash_puppet", [_NAME])
	SavedNode.add_child(_TrashObj)
	_TrashObj.call_load({"NAME": _NAME, "Weight": 1})
	_TrashObj.call_Trashbag_init(_weight, true)
	SaveNodeList.append(_TrashObj)
	ItemType = "垃圾"
	_CanMove_Check()
func call_clear_puppet():
	call_SaveClear_puppet()
	var _weight = 1
	ItemType = ""
	_CanMove_Check()
	IsBroken = false
	IsPassDay = false
	_freshless_logic()
func call_clear():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_clear_puppet")
	var _weight = 1
	call_SaveClear()
	ItemType = ""
	_CanMove_Check()
	IsBroken = false
	IsPassDay = false
	_freshless_logic()
func return_SQUEEZE_SPEED():
	var _SPEED: float = 1 / GameLogic.return_Multiplier_Division()

	var _Mult: float = 0
	for _Player in PlayerList:
		_Mult += 1
		if _Player.Stat.Skills.has("技能-利爪"):
			_Mult += 1

		if _Player.Stat.Skills.has("技能-麻利"):
			_Mult += 0.5
		if _Player.BuffList.has("技能-手速"):
			_Mult += 0.5

		if not _Player.Stat.Skills.has("技能-幽灵基础"):
			if GameLogic.cur_Rewards.has("尖爪手套"):
				_Mult += 1
			if GameLogic.cur_Rewards.has("尖爪手套+"):
				_Mult += 3
			if GameLogic.cur_Challenge.has("手笨+"):
				_Mult = _Mult * 0.75
		if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
			_Mult += GameLogic.Skill.HandWorkMult





		if GameLogic.cur_Event == "手速":
			_Mult = 20

	if _Mult <= 0:
		_Mult = 1
	_SPEED = _SPEED * _Mult
	return _SPEED
func call_puppet_WORK_start(_PLAYERPATH, _SPEED):
	var _Player = get_node(_PLAYERPATH)
	if not PlayerList.size():
		PlayerList.append(_Player)
	_Player.Con.ArmState = GameLogic.NPC.STATE.WORK
	MixAni.playback_speed = return_SQUEEZE_SPEED()
	MixAni.play("Mixd")
	CanMove = false
func return_WORK_start(_Player, _Speed):
	if get_parent().name == "Weapon_note":
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if PlayerList.has(_Player):
			return true

		return

	if ItemType in CanPutList:
		if not PlayerList.size():

			_Pressed = true
			if not PlayerList.has(_Player):
				PlayerList.append(_Player)
			MixAni.playback_speed = return_SQUEEZE_SPEED()
			MixAni.play("Mixd")
			CanMove = false
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYERPATH = _Player.get_path()
				SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_WORK_start", [_PLAYERPATH, MixAni.playback_speed])
			return true
		if PlayerList.has(_Player):
			return true
	return false
func call_player_leave(_Player):

	if PlayerList.has(_Player):
		call_STIR_end(_Player)
func call_STIR_end_puppet(_CHECK: bool):
	if GameLogic.cur_Challenge.has("手笨") and _CHECK:
		if not MixAni.get_assigned_animation() in ["hide", "init"]:
			MixAni.play("hide")
			return
	else:
		if MixAni.assigned_animation == "Mixd":
			MixAni.stop(false)
			CanMove = true
			return
func call_STIR_end(_Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	_Pressed = false
	if PlayerList.has(_Player):
		PlayerList.erase(_Player)
		_Player.call_reset_stat()

	if not PlayerList.size():
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _CHECK: bool = false
			SteamLogic.call_puppet_id_sync(_SELFID, "call_STIR_end_puppet", [_CHECK])

		if GameLogic.cur_Challenge.has("手笨"):
			if not MixAni.get_assigned_animation() in ["hide", "init"]:
				MixAni.play("hide")
				CanMove = true
				return
		else:
			if MixAni.assigned_animation == "Mixd":
				MixAni.stop(false)
				CanMove = true
				return
func call_Mix_Finished_puppet():

	PlayerList.clear()

	MixAni.play("hide")
	CanMove = true

func _Mix_Finished() -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		for i in PlayerList.size():
			var _Player = PlayerList[i]

			if _Player.has_method("call_reset_stat"):


				But_Switch(true, _Player)
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Mix_Finished_puppet")
	call_Cut_Finished()

	var _CHECKBOOL: bool = false
	for i in PlayerList.size():
		var _Player = PlayerList[i]

		if _Player.has_method("call_reset_stat"):
			_Player.call_reset_stat()
			GameLogic.Device.call_teach(2, _Player, self, "切片")
			But_Switch(true, _Player)
			if not _CHECKBOOL:
				call_FruitTrash_Create(_Player, ItemType)
	PlayerList.clear()
	if MixAni.get_assigned_animation() != "hide":
		MixAni.play("hide")
	CanMove = true

func call_ItemLoad_puppet(_NUM, _NAMELIST, _POSLIST, _ITEMTYPE):
	call_SaveClear_puppet()
	ItemType = _ITEMTYPE
	for i in _NUM:
		if ItemType in ["布朗尼块"]:
			var _Obj = GameLogic.TSCNLoad.Extra_TSCN.instance()
			_Obj.position.x = _POSLIST[i]
			_Obj._SELFID = _NAMELIST[i]
			_Obj.name = str(_NAMELIST[i])
			SavedNode.add_child(_Obj)
			_Obj.call_init(ItemType)
			_Obj.call_bag_tex_set()
			SaveNodeList.append(_Obj)
		else:
			var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
			_FruitObj._SELFID = _NAMELIST[i]
			_FruitObj.name = str(_NAMELIST[i])
			_FruitObj.position.x = _POSLIST[i]
			SavedNode.add_child(_FruitObj)
			_FruitObj.call_load_TSCN(ItemType)
			SaveNodeList.append(_FruitObj)
func call_SaveClear_puppet():
	if SaveNodeList.size():
		for i in SaveNodeList.size():
			var _Node = SaveNodeList[i]

			if is_instance_valid(_Node):
				if _Node.get_parent().name in ["SavedNode"]:
					_Node.queue_free()
	SaveNodeList.clear()
func call_SaveClear():
	var _CLEARLIST: Array
	if SaveNodeList.size():
		for i in SaveNodeList.size():
			var _Node = SaveNodeList[i]

			if is_instance_valid(_Node):
				if _Node.get_parent().name in ["SavedNode"]:
					if _Node.has_method("call_del"):
						_Node.call_del()
					else:
						_Node.queue_free()
				else:
					_CLEARLIST.append(_Node)
			else:
				_CLEARLIST.append(_Node)
		if _CLEARLIST.size():
			for _NODE in _CLEARLIST:
				if SaveNodeList.has(_NODE):
					SaveNodeList.erase(_NODE)
	SaveNodeList.clear()
func call_Extra_puppet(_ID):
	call_SaveClear()
	var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
	var _ExtraObj = _EXTRATSCN.instance()
	_ExtraObj._SELFID = _ID
	_ExtraObj.name = str(_ID)
	SavedNode.add_child(_ExtraObj)
	SaveNodeList.append(_ExtraObj)
	_ExtraObj.call_init(ItemType)
func call_ItemLoad(_Num):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	call_SaveClear()
	match ItemType:
		"布朗尼蛋糕":
			var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
			var _ExtraObj = _EXTRATSCN.instance()
			_ExtraObj._SELFID = _ExtraObj.get_instance_id()
			var _NAME = str(_ExtraObj._SELFID)

			_ExtraObj.name = _NAME
			SavedNode.add_child(_ExtraObj)
			SaveNodeList.append(_ExtraObj)
			_ExtraObj.call_init(ItemType)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Extra_puppet", [_ExtraObj._SELFID])
		"布朗尼块":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:

				var _FruitObj = GameLogic.TSCNLoad.Extra_TSCN.instance()
				_FruitObj.position.x += (i - 2) * 2
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)

				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)
				_FruitObj.call_init(ItemType)
				_FruitObj.call_bag_tex_set()
				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
		"芝士":
			var _EXTRATSCN = GameLogic.TSCNLoad.Extra_TSCN
			var _ExtraObj = _EXTRATSCN.instance()
			_ExtraObj._SELFID = _ExtraObj.get_instance_id()
			var _NAME = str(_ExtraObj._SELFID)

			_ExtraObj.name = _NAME
			SavedNode.add_child(_ExtraObj)
			SaveNodeList.append(_ExtraObj)
			_ExtraObj.call_init(ItemType)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_Extra_puppet", [_ExtraObj._SELFID])
		"芋头块":
			var _NAMELIST: Array
			var _POSLIST: Array
			var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
			_FruitObj.position = Vector2.ZERO
			_FruitObj._SELFID = _FruitObj.get_instance_id()
			var _NAME = str(_FruitObj._SELFID)

			_FruitObj.name = _NAME
			_NAMELIST.append(_FruitObj._SELFID)
			_POSLIST.append(_FruitObj.position.x)
			SavedNode.add_child(_FruitObj)
			_FruitObj.call_init(ItemType)
			_FruitObj.call_bag_tex_set()
			SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
		"芝士片":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:

				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				_FruitObj.position.x += (i - 2) * 5
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)

				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)
				_FruitObj.call_init(ItemType)
				_FruitObj.call_bag_tex_set()
				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
		"垃圾":
			var _NAMELIST: Array
			var _POSLIST: Array
			var Trashbag_TSCN = GameLogic.TSCNLoad.return_TSCN("Trashbag")
			var _TrashObj = Trashbag_TSCN.instance()
			_TrashObj._SELFID = _TrashObj.get_instance_id()
			var _NAME = str(_TrashObj._SELFID)

			_TrashObj.name = _NAME
			_NAMELIST.append(_TrashObj._SELFID)
			_POSLIST.append(0)
			SavedNode.add_child(_TrashObj)
			_TrashObj.call_Trashbag_init(1, true)
			SaveNodeList.append(_TrashObj)

			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [1, _NAMELIST, _POSLIST, ItemType])
		"柠檬", "橙子", "芋头", "青桔", "香蕉", "西瓜", "凤梨", "火龙果":
			var _NAMELIST: Array
			var _POSLIST: Array
			var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
			_FruitObj._SELFID = _FruitObj.get_instance_id()
			var _NAME = str(_FruitObj._SELFID)
			_FruitObj.name = _NAME
			_NAMELIST.append(_FruitObj._SELFID)
			_POSLIST.append(0)
			SavedNode.add_child(_FruitObj)

			_FruitObj.call_load_TSCN(ItemType)

			SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [1, _NAMELIST, _POSLIST, ItemType])
		"凤梨块":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:
				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				if i < 5:
					_FruitObj.position.x += (i - 2) * 5
					_FruitObj.position.y += - 5
				else:
					_FruitObj.position.x += ((i - 5) - 2) * 5
					_FruitObj.position.y += 5
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)
				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)

				_FruitObj.call_load_TSCN(ItemType)

				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
		"香蕉块":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:
				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				_FruitObj.position.x += (i - 2) * 6
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)
				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)

				_FruitObj.call_load_TSCN(ItemType)

				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
		"火龙果块":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:
				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				_FruitObj.position.x += (i - 2) * 6
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)
				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)

				_FruitObj.call_load_TSCN(ItemType)

				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
			for i in PlayerList.size():
				var _Player = PlayerList[i]
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 5, "火龙果汁", _Player, 1)
		"西瓜块":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:
				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				if i < 5:
					_FruitObj.position.x += (i - 2) * 5
					_FruitObj.position.y += - 6
				elif i < 10:
					_FruitObj.position.x += ((i - 5) - 2) * 5
					_FruitObj.position.y += - 3
				elif i < 15:
					_FruitObj.position.x += ((i - 10) - 2) * 5
					_FruitObj.position.y += 3
				else:
					_FruitObj.position.x += ((i - 15) - 2) * 5
					_FruitObj.position.y += 6
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)
				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)

				_FruitObj.call_load_TSCN(ItemType)

				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
			for i in PlayerList.size():
				var _Player = PlayerList[i]
				GameLogic.Liquid.call_WaterStain(_Player.global_position, 10, "西瓜汁", _Player, 1)

		"柠檬片", "青桔块", "薄荷叶":
			var _NAMELIST: Array
			var _POSLIST: Array
			for i in _Num:
				var _FruitObj = GameLogic.TSCNLoad.Fruit_TSCN.instance()
				_FruitObj.position.x += (i - 2) * 5
				_FruitObj._SELFID = _FruitObj.get_instance_id()
				var _NAME = str(_FruitObj._SELFID)
				_FruitObj.name = _NAME
				_NAMELIST.append(_FruitObj._SELFID)
				_POSLIST.append(_FruitObj.position.x)

				SavedNode.add_child(_FruitObj)

				_FruitObj.call_load_TSCN(ItemType)

				SaveNodeList.append(_FruitObj)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_id_sync(_SELFID, "call_ItemLoad_puppet", [_Num, _NAMELIST, _POSLIST, ItemType])
func call_CanMove_Check_puppet(_CANMOVE):
	CanMove = _CANMOVE
func call_Cut_Finished():
	match ItemType:
		"薄荷枝":
			ItemType = "薄荷叶"
			call_ItemLoad(5)
		"布朗尼蛋糕":
			ItemType = "布朗尼块"
			call_ItemLoad(10)
		"火龙果":
			ItemType = "火龙果块"
			call_ItemLoad(6)
		"香蕉":
			ItemType = "香蕉块"
			call_ItemLoad(6)
		"西瓜":
			ItemType = "西瓜块"
			call_ItemLoad(12)
		"凤梨":
			ItemType = "凤梨块"
			call_ItemLoad(8)
		"青桔":
			ItemType = "青桔块"
			call_ItemLoad(5)
		"芋头":
			ItemType = "芋头块"
			call_ItemLoad(1)
		"芝士":
			ItemType = "芝士片"
			call_ItemLoad(5)
		"柠檬":
			ItemType = "柠檬片"
			call_ItemLoad(5)
	_CanMove_Check()
func call_MoveInBox_puppet(_Num):
	for _i in _Num:
		if SaveNodeList.size():
			var _Obj = SaveNodeList.pop_back()
			SavedNode.remove_child(_Obj)

		else:
			break
	if not SaveNodeList.size():
		ItemType = ""
func return_MoveInBoxList(_Num: int):

	if SaveNodeList.size():
		var _returnList: Array
		var _CurNum: int

		for _i in _Num:
			if SaveNodeList.size():
				var _Obj = SaveNodeList.pop_back()
				if is_instance_valid(_Obj):
					if SavedNode.has_node(_Obj.get_path()):
						SavedNode.remove_child(_Obj)
						_returnList.append(_Obj)
			else:
				break
		if not SaveNodeList.size():
			ItemType = ""
			IsPassDay = false
			IsBroken = false
			_freshless_logic()
		_CanMove_Check()
		return _returnList
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)

func call_FruitTrash_Create(_Player, _ItemType):
	var _CHECK: bool = false
	var _ItemName: String
	match _ItemType:
		"火龙果块":
			_ItemName = "火龙果皮"
			_CHECK = true
		"西瓜块":
			_ItemName = "西瓜皮"
			_CHECK = true
		"凤梨块":
			_ItemName = "凤梨皮"
			_CHECK = true
		"香蕉块":
			_ItemName = "香蕉皮"
			_CHECK = true
	if _CHECK:
		var _Obj = GameLogic.TSCNLoad.Bag_TSCN.instance()
		_Obj._SELFID = _Obj.get_instance_id()
		_Obj.name = str(_Obj._SELFID)
		_Obj.call_load_TSCN(_ItemName)
		GameLogic.Device._Pick_Logic(_Player, _Obj)
		_Obj.call_bag_tex_set()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_FtuitTrash_puppet", [_ItemName, _Obj._SELFID, _PLAYERPATH])

func call_FtuitTrash_puppet(_ItemName, _ID, _PLAYERPATH):
	var _Obj = GameLogic.TSCNLoad.Bag_TSCN.instance()
	_Obj._SELFID = _ID
	_Obj.name = str(_Obj._SELFID)
	_Obj.call_load_TSCN(_ItemName)
	var _Player = get_node(_PLAYERPATH)
	GameLogic.Device._Pick_Logic(_Player, _Obj)
	_Obj.call_bag_tex_set()
