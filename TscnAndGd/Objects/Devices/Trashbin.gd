extends Head_Object
var SelfDev = "Trashbin"

export var Trash_Max: int
var Trash_Count: int
var _Count: int = 0
onready var TrashAni = get_node("AniNode/TrashAni")
onready var TrashTypeAni = get_node("AniNode/CapacityAni")
onready var WarningAni
onready var ProAni
onready var ProColorAni

onready var Audio_In
onready var Audio_Full
onready var Audio_Wrong
onready var PickAudio
onready var _timer: int

func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")

func _ProColor_Check():
	if has_node("Ui/TextureProgress"):
		get_node("Ui/TextureProgress").max_value = Trash_Max
		get_node("Ui/TextureProgress").value = Trash_Count
		if Trash_Count < Trash_Max:
			if ProColorAni.assigned_animation != "init":
				ProColorAni.play("init")
		else:
			if ProColorAni.assigned_animation != "full":
				ProColorAni.play("full")
				TrashTypeAni.play("Full")
func _DayClosedCheck():


	if GameLogic.cur_Rewards.has("垃圾分解+"):
		if Trash_Count > 0:
			Trash_Count = 0
			call_TrashTypeAni_Set()

	if Trash_Count > 0:

		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.TRASHBIN):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.TRASHBIN)





	pass

func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.cur_RayObj != self:
		_bool = false
		call_OutLine(false)

	if _Player.Con.IsHold:
		var A_But = get_node("But/A")
		A_But.show()
		if has_node("But/X"):
			var X_But = get_node("But/X")
			X_But.hide()
	else:
		if Trash_Count > 0:
			var A_But = get_node("But/A")
			A_But.hide()
			if has_node("But/X"):
				var X_But = get_node("But/X")
				X_But.show()
	if not _bool:
		if has_node("AniNode/TrashOpen"):
			get_node("AniNode/TrashOpen").play("close")
	.But_Switch(_bool, _Player)
	if ProAni:
		match _bool:
			true:

				if ProAni.assigned_animation != "show":
					ProAni.play("show")
			false:
				if ProAni.assigned_animation == "show":
					ProAni.play("hide")
var _BUGCHECK: bool
var _BUGTSCN
func call_Bug_Creat():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if not GameLogic.cur_Item_List.has("Bug"):
		GameLogic.cur_Item_List["Bug"] = 1
	elif GameLogic.cur_Item_List["Bug"] >= SteamLogic.PlayerNum * 2:
		return
	else:
		GameLogic.cur_Item_List["Bug"] += 1

	var _BUG = _BUGTSCN.instance()

	_BUG.name = str(_BUG.get_instance_id())
	_BUG.position = self.position
	var _MULT = 1 + (GameLogic.return_RANDOM() % 11) * 0.05 - 0.25
	_BUG._BASEMULT = _MULT
	GameLogic.Staff.LevelNode.Ysort_Update.add_child(_BUG)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Bug_puppet", [self.position, _MULT, _BUG.name])
func call_Bug_puppet(_POS, _BASE, _NAME):
	if _BUGTSCN == null:
		_BUGTSCN = load("res://TscnAndGd/Objects/Special/CockRoach.tscn")

	var _BUG = _BUGTSCN.instance()
	_BUG.position = _POS
	_BUG._BASEMULT = _BASE
	_BUG.name = _NAME
	GameLogic.Staff.LevelNode.Ysort_Update.add_child(_BUG)
func _ready() -> void :
	call_init(SelfDev)
	if editor_description == "Dev":
		Trash_Max = 10
	else:
		Trash_Max = 10000
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		pass
	elif GameLogic.curLevelList.has("难度-虫虫") or GameLogic.curLevelList.has("难度-超级虫虫"):
		_BUGCHECK = true
	elif GameLogic.cur_levelInfo.has("GamePlay"):
		if GameLogic.cur_levelInfo.GamePlay.has("难度-虫虫"):
			_BUGCHECK = true
	if _BUGCHECK:
		_BUGTSCN = load("res://TscnAndGd/Objects/Special/CockRoach.tscn")
	call_deferred("_Connect")

	Audio_In = GameLogic.Audio.return_Effect("倒垃圾")
	Audio_Full = GameLogic.Audio.return_Effect("苍蝇循环")
	Audio_Wrong = GameLogic.Audio.return_Effect("错误1")
	PickAudio = GameLogic.Audio.return_Effect("拿起")
	if has_node("AniNode/ProAni"):
		ProAni = get_node("AniNode/ProAni")
	if has_node("AniNode/ProColorAni"):
		ProColorAni = get_node("AniNode/ProColorAni")
func _Connect():

	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	if has_node("AniNode/GuideAni"):
		if editor_description == "Dev":
			var _connect = GameLogic.Tutorial.connect("DropInTrashbin", self, "_Tutorial_Trashbag")
		else:
			var _connect = GameLogic.Tutorial.connect("DropTrashbag", self, "_Tutorial_Trashbag")
	if editor_description == "Dev":
		if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
			var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if has_node("AniNode/Warning"):
		WarningAni = get_node("AniNode/Warning")
	if not GameLogic.GameUI.is_connected("TimeChange", self, "call_timechange"):
		var _con = GameLogic.GameUI.connect("TimeChange", self, "call_timechange")

func _Tutorial_Trashbag(_Switch: bool):

	var GuideAni = get_node("AniNode/GuideAni")
	match _Switch:
		true:
			GuideAni.play("show")
		false:
			GuideAni.play("init")

func Update_Check():
	if GameLogic.cur_Rewards.has("垃圾回收") or GameLogic.cur_Rewards.has("垃圾回收+"):
		if has_node("AniNode/RecycleAni"):
			if get_node("AniNode/RecycleAni").assigned_animation != "recycle":
				get_node("AniNode/RecycleAni").play("recycle")
	if editor_description == "Dev":
		if GameLogic.cur_Rewards.has("垃圾分解"):
			if not GameLogic.GameUI.is_connected("TimeChange", self, "_DelectTrash"):
				GameLogic.GameUI.connect("TimeChange", self, "_DelectTrash")
		elif GameLogic.cur_Rewards.has("垃圾分解+"):
			if not GameLogic.GameUI.is_connected("TimeChange", self, "_DelectTrash"):
				GameLogic.GameUI.connect("TimeChange", self, "_DelectTrash")
		if GameLogic.cur_Rewards.has("垃圾桶升级"):
			if Trash_Max != 20:
				Trash_Max = 20
				if has_node("AniNode/Upgrade"):
					if get_node("AniNode/Upgrade").assigned_animation != "2":
						get_node("AniNode/Upgrade").play("2")
				_TrashType_Set()
		elif GameLogic.cur_Rewards.has("垃圾桶升级+"):
			if Trash_Max != 30:
				Trash_Max = 30
				if has_node("AniNode/Upgrade"):
					if get_node("AniNode/Upgrade").assigned_animation != "3":
						get_node("AniNode/Upgrade").play("3")
				_TrashType_Set()
		else:
			if has_node("AniNode/Upgrade"):
				get_node("AniNode/Upgrade").play("1")
				_TrashType_Set()
func _DelectTrash():
	_Count += 1
	if GameLogic.cur_Rewards.has("垃圾分解+"):
		_Count += 2
	if _Count > 10:
		_Count = 0
		if Trash_Count > 0:
			var _DELNUM = int(Trash_Max * 0.2)
			if _DELNUM > Trash_Count:
				_DELNUM = Trash_Count
			Trash_Count -= _DELNUM
			call_TrashTypeAni_Set()
			_ProColor_Check()

func call_load(_Info):
	Update_Check()

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	Trash_Count = int(_Info.Trash_Count)

	_ProColor_Check()
	call_TrashTypeAni_Set()


	if editor_description != "Dev":
		return
	if not has_node("AniNode/RecycleAni"):
		if not GameLogic.GameUI.is_connected("TimeChange", self, "call_timechange"):
			var _con = GameLogic.GameUI.connect("TimeChange", self, "call_timechange")

var _BUGTimer: int = 0

func call_timechange():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if editor_description != "Dev":
		if _BUGCHECK:

			var _TIMER = int(20 / GameLogic.return_Multiplier_Division())
			if _BUGTimer >= _TIMER:
				_BUGTimer = 0

				call_Bug_Creat()
			else:
				if not GameLogic.cur_Item_List.has("Trashbag"):
					GameLogic.cur_Item_List["Trashbag"] = 0
				_BUGTimer += int((1 + GameLogic.cur_Item_List["Trashbag"]) * GameLogic.return_Multiplier_Division())
		return

	if GameLogic.cur_Challenge.has("垃圾堆") or GameLogic.cur_Challenge.has("垃圾堆+"):
		_timer += 1
		if GameLogic.GameUI.Is_Open and GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
			if GameLogic.cur_Challenge.has("垃圾堆"):
				if _timer >= 6:
					_timer = 0
					GameLogic.call_Info(2, "垃圾堆")

					call_Trash_In_NoStatistics(1)
			if GameLogic.cur_Challenge.has("垃圾堆+"):
				if _timer >= 3:
					_timer = 0
					GameLogic.call_Info(2, "垃圾堆+")
					call_Trash_In_NoStatistics(1)
	if Trash_Count >= Trash_Max:
		var _Pre: int = 0
		if GameLogic.cur_Challenge.has("垃圾臭味"):
			GameLogic.call_Info(2, "垃圾臭味")
			_Pre += 1
		if GameLogic.cur_Challenge.has("垃圾臭味+"):
			GameLogic.call_Info(2, "垃圾臭味+")
			_Pre += 2
		if _Pre != 0:
			GameLogic.call_Pressure_Set(_Pre)
	if Trash_Count > 0 and _BUGCHECK:

		_BUGTimer += 1
		var _TIMER = 1 + int(float(Trash_Max + 1 - Trash_Count) * 2 / GameLogic.return_Multiplier())
		if _BUGTimer >= _TIMER:
			_BUGTimer = 0

			call_Bug_Creat()

func call_Trash_In_puppet(_NUM):
	Trash_Count = _NUM

	Audio_In.play(0)

	call_TrashTypeAni_Set()
func call_Trash_In_NoStatistics(_TrashNum):
	if editor_description == "Dev":
		if _TrashNum < 0:
			printerr("垃圾数量小于0")

		if _TrashNum > Trash_Max:
			return
		if Trash_Count >= Trash_Max:

			return
		else:
			Trash_Count += _TrashNum
			Audio_In.play(0)

	else:
		if GameLogic.cur_Rewards.has("垃圾回收"):
			var _MONEY = int(pow(_TrashNum, 1.7)) * GameLogic.return_Multiplayer()
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_MONEY = int(float(_MONEY) * 1.5)
			GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

			var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
			self.get_node("PayNode").add_child(_PayEffect)
			_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Trash_money_puppet", [_MONEY])
		if GameLogic.cur_Rewards.has("垃圾回收+"):
			var _MONEY = int(pow(_TrashNum, 2)) * GameLogic.return_Multiplayer()
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_MONEY = int(float(_MONEY) * 1.5)
			GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

			var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
			self.get_node("PayNode").add_child(_PayEffect)
			_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Trash_money_puppet", [_MONEY])
		Audio_In.play(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Trash_In_puppet", [Trash_Count])
	call_TrashTypeAni_Set()
func call_Trash_money_puppet(_MONEY):
	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	self.get_node("PayNode").add_child(_PayEffect)
	_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
	Audio_In.play(0)

	call_TrashTypeAni_Set()

func call_Trash_In(_TrashNum):

	if editor_description == "Dev":
		if _TrashNum < 0:
			printerr("垃圾数量小于0")

		if _TrashNum > Trash_Max:
			return
		if Trash_Count >= Trash_Max:

			return
		else:
			Trash_Count += _TrashNum
			GameLogic.call_StatisticsData_Set("Count_TrashBin", null, 1)

	else:

		if GameLogic.cur_Rewards.has("垃圾回收"):
			var _MONEY = int(pow(_TrashNum, 2) / 3 * GameLogic.cur_Day * GameLogic.return_Multiplayer())
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_MONEY = int(float(_MONEY) * 1.5)
			GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

			var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
			self.get_node("PayNode").add_child(_PayEffect)
			_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Trash_money_puppet", [_MONEY])
		if GameLogic.cur_Rewards.has("垃圾回收+"):
			var _MONEY = int(pow(_TrashNum, 2) * GameLogic.cur_Day * GameLogic.return_Multiplayer())
			if GameLogic.Achievement.cur_EquipList.has("特殊合约") and not GameLogic.SPECIALLEVEL_Int:
				_MONEY = int(float(_MONEY) * 1.5)
			GameLogic.call_MoneyOther_Change(_MONEY, GameLogic.HomeMoneyKey)

			var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
			self.get_node("PayNode").add_child(_PayEffect)
			_PayEffect.call_init(_MONEY, _MONEY, 0, false, false, false, false)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Trash_money_puppet", [_MONEY])

		GameLogic.call_StatisticsData_Set("Count_TrashBag", null, _TrashNum)

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Trash_In_puppet", [Trash_Count])
	Audio_In.play(0)
	call_TrashTypeAni_Set()

func _TrashType_Set():
	if Trash_Count == 0:
		TrashTypeAni.play("Empty")
	elif Trash_Count >= Trash_Max:
		TrashTypeAni.play("Full")
	elif Trash_Count > int(float(Trash_Max) / 2):
		TrashTypeAni.play("Many")
	elif Trash_Count > 0:
		TrashTypeAni.play("Few")
	_ProColor_Check()
func call_TrashAni_puppet(_TRASHCOUNT, _BUGBOOL):
	_BUGCHECK = _BUGBOOL
	Trash_Count = _TRASHCOUNT
	if Trash_Count == 0:
		TrashAni.play("out")
		TrashTypeAni.play("Empty")
	elif Trash_Count == Trash_Max:
		TrashAni.play("in")

		TrashTypeAni.play("Full")
	elif Trash_Count > int(float(Trash_Max) / 2):
		TrashAni.play("in")

		TrashTypeAni.play("Many")
	elif Trash_Count > 0:
		TrashAni.play("in")

		TrashTypeAni.play("Few")
	if _BUGCHECK:
		if Trash_Count:
			if has_node("TexNode/Coco/TexNode/Ani"):
				var _ANI = get_node("TexNode/Coco/TexNode/Ani")
				var _SPEED = (1 + 3 * float(Trash_Count) / float(Trash_Max))
				if _SPEED > 4:
					_SPEED = 4
				_ANI.playback_speed = _SPEED
				_ANI.play("play")
		else:
			if has_node("TexNode/Coco/TexNode/Ani"):
				get_node("TexNode/Coco/TexNode/Ani").play("init")
	_ProColor_Check()
func call_TrashTypeAni_Set():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_TrashAni_puppet", [Trash_Count, _BUGCHECK])
	if Trash_Count == 0:
		TrashAni.play("out")
		TrashTypeAni.play("Empty")
	elif Trash_Count == Trash_Max:
		TrashAni.play("in")
		TrashTypeAni.play("Full")

	elif Trash_Count > int(float(Trash_Max) / 2):
		TrashAni.play("in")

		TrashTypeAni.play("Many")
	elif Trash_Count > 0:
		TrashAni.play("in")

		TrashTypeAni.play("Few")
	if _BUGCHECK:
		if Trash_Count:
			if has_node("TexNode/Coco/TexNode/Ani"):
				var _ANI = get_node("TexNode/Coco/TexNode/Ani")
				var _SPEED = (1 + 3 * float(Trash_Count) / float(Trash_Max))
				if _SPEED > 4:
					_SPEED = 4
				_ANI.playback_speed = _SPEED
				_ANI.play("play")


		else:
			if has_node("TexNode/Coco/TexNode/Ani"):
				get_node("TexNode/Coco/TexNode/Ani").play("init")
	_ProColor_Check()

func call_Trashbin_puppet(_PLAYER, _NAME, _CarryWeight, _COUNT):
	var _Player = get_node(_PLAYER)
	var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
	Trashbag_TSCN.name = _NAME
	SteamLogic.OBJECT_DIC[int(_NAME)] = Trashbag_TSCN
	_Player.WeaponNode.add_child(Trashbag_TSCN)
	call_Trashbag_init(_Player, Trashbag_TSCN, _CarryWeight, _COUNT)
	if _Player.cur_Player == SteamLogic.STEAM_ID:
		GameLogic.Tutorial.call_DrapTrashbag(true)

	PickAudio.play(0)
func call_DevLogic_Trashbin(_ButID, _Player, _DevObj):

	match _ButID:

		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			var Trashbag_TSCN = GameLogic.TSCNLoad.Trashbag_TSCN.instance()
			var _NAME = str(Trashbag_TSCN.get_instance_id())
			Trashbag_TSCN.name = _NAME
			SteamLogic.OBJECT_DIC[int(_NAME)] = Trashbag_TSCN
			_Player.WeaponNode.add_child(Trashbag_TSCN)
			var _COUNT = Trash_Count
			if Trash_Count > Trash_Max:
				_COUNT = Trash_Max
			var _CarryWeight: float = 1.0 - (float(_COUNT) / 10 * 0.5)
			call_Trashbag_init(_Player, Trashbag_TSCN, _CarryWeight, Trash_Count)
			if SteamLogic.IsMultiplay:
				if _Player.cur_Player == SteamLogic.STEAM_ID:
					GameLogic.Tutorial.call_DrapTrashbag(true)
			else:
				GameLogic.Tutorial.call_DrapTrashbag(true)

			But_Switch(true, _Player)
			PickAudio.play(0)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PLAYER = _Player.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Trashbin_puppet", [_PLAYER, _NAME, _CarryWeight, _COUNT])
			return "取垃圾"
func call_Trashbag_init(_Player, Trashbag_TSCN, _CarryWeight, _COUNT):
	_Player.Con.HoldInsId = Trashbag_TSCN.get_instance_id()

	Trashbag_TSCN.call_load({"NAME": Trashbag_TSCN.name, "Weight": _CarryWeight})
	Trashbag_TSCN.call_Trashbag_init(_COUNT, false)
	if _CarryWeight < 0.5:
		_CarryWeight = 0.5
	Trashbag_TSCN.CarrySpeed = _CarryWeight

	_Player.Con.IsHold = true
	_Player.Con.HoldObj = Trashbag_TSCN
	_Player.Con.NeedPush = true
	_Player.Stat.call_carry_on(_CarryWeight)
	Trash_Count = 0
	call_TrashTypeAni_Set()

func call_WorkBoard_Trash_puppet(_HOLDPATH, _PLAYERPATH):
	var _HoldObj = get_node(_HOLDPATH)
	var _Player = get_node(_PLAYERPATH)
	var _TrashCount = 1
	_HoldObj.call_Trashbin_Logic()
	call_Trash_In(_TrashCount)

func call_BigPot_Trash(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.cur_ContentNum > 0 and _HoldObj.cur_TYPE in [4, 5, 6, 7]:
				But_Switch(true, _Player)
		0:
			if Trash_Count >= Trash_Max:
				if has_node("AniNode/Warning"):
					get_node("AniNode/Warning").play("idle")
					Audio_Wrong.play(0)
				return true
			printerr("倒掉内容物", _HoldObj.cur_TYPE)
			if _HoldObj.cur_ContentNum > 0 and _HoldObj.cur_TYPE in [4, 5, 6, 7]:
				call_Trash_In(_HoldObj.get("cur_ContentNum"))
				_HoldObj.call_clean()
				return true
func call_CreamMachine_Trash_puppet(_TrashCount):
	call_Trash_In(_TrashCount)
func call_CreamMachine_Trash(_ButID, _Player, _HoldObj):

	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.CreamBool or _HoldObj.CreamTYPE:
				But_Switch(true, _Player)
		0:
			if Trash_Count + 10 > Trash_Max:
				if has_node("AniNode/Warning"):
					get_node("AniNode/Warning").play("idle")
					Audio_Wrong.play(0)
				return
			if _HoldObj.CreamBool or _HoldObj.CreamTYPE:
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					But_Switch(false, _Player)
					return

				var _TrashCount = 10
				if not _HoldObj.CreamBool:
					_TrashCount = 1
				_HoldObj.call_Drop()
				call_Trash_In(_TrashCount)
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					SteamLogic.call_puppet_node_sync(self, "call_CreamMachine_Trash_puppet", [_TrashCount])
				return "入垃圾桶"

func call_WorkBoard_Trash(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			But_Switch(false, _Player)
		- 1:
			if _HoldObj.SaveNodeList.size():
				But_Switch(true, _Player)
		0:
			if Trash_Count >= Trash_Max:
				if has_node("AniNode/Warning"):
					get_node("AniNode/Warning").play("idle")
					Audio_Wrong.play(0)
				return
			if _HoldObj.SaveNodeList.size():
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					But_Switch(false, _Player)
					return
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _HOLDPATH = _HoldObj.get_path()
					var _PLAYERPATH = _Player.get_path()
					SteamLogic.call_puppet_node_sync(self, "call_WorkBoard_Trash_puppet", [_HOLDPATH, _PLAYERPATH])
				var _TrashCount = 1
				_HoldObj.call_Trashbin_Logic()
				call_Trash_In(_TrashCount)
				return "入垃圾桶"

func call_BobaMachine_DropTrash(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _HoldObj.cur_ContentNum == 0:
				return

			var A_But = get_node("But/A")
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _HoldObj.cur_ContentNum == 0:
				return
			if _HoldObj.cur_ContentNum + Trash_Count <= Trash_Max:
				if _HoldObj.Liquid_Count > 0:
					if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
						_Player.call_Say_DropWater()
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					GameLogic.Device.call_TouchDev_Logic( - 1, _Player, self)
					return
				if _HoldObj.has_method("call_Trash"):
					call_Trash_In(_HoldObj.cur_ContentNum)
					_HoldObj.call_Trash()

					But_Switch(false, _Player)
func call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj):

	if _HoldObj.IsItem:

		match _ButID:
			- 2:
				if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					return
				But_Switch(false, _Player)
			- 1:
				var _TYPE = _HoldObj.get("TypeStr")
				if _TYPE in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
					return
				if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					return
				var A_But = get_node("But/A")
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(str(A_But.Info_Str))
				But_Switch(true, _Player)
				if has_node("AniNode/TrashOpen"):
					get_node("AniNode/TrashOpen").play("open")
				_ProColor_Check()
			0:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				var _TYPE = _HoldObj.get("TypeStr")
				if _TYPE in ["BeerCup_S", "BeerCup_M", "BeerCup_L"]:
					return
				if _HoldObj.FuncType in ["Fruit"] or (_DevObj.Trash_Count < _DevObj.Trash_Max and _HoldObj.Weight <= _DevObj.Trash_Max):

					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						return

					var _TrashCount = _HoldObj.Weight
					if _HoldObj.has_method("return_DropCount"):
						_TrashCount = _HoldObj.return_DropCount()
					if _HoldObj.has_method("call_cleanID"):

						_HoldObj.call_cleanID()
					if _HoldObj.TypeStr == "Trashbag":
						call_Trash_In_NoStatistics(_TrashCount)
					else:
						call_Trash_In(_TrashCount)
					_Player.Stat.call_carry_off()
					if _HoldObj.has_method("call_del"):
						_HoldObj.call_del()
					GameLogic.Device.call_TouchDev_Logic( - 1, _Player, _DevObj)
					GameLogic.Order.emit_signal("NewOrder", 0)
					But_Switch(true, _Player)
					if has_node("AniNode/TrashOpen"):
						get_node("AniNode/TrashOpen").play("close")
					return "入垃圾桶"
				else:
					if _ButID == 0:
						if has_node("AniNode/Warning"):
							get_node("AniNode/Warning").play("idle")
							Audio_Wrong.play(0)

	else:

		if _DevObj.Trash_Count + _HoldObj.Weight <= _DevObj.Trash_Max:
			var _CanDrop: bool
			if _HoldObj.TypeStr == "ShakeCup":
				if _HoldObj.Liquid_Count:
					_CanDrop = true
			elif _HoldObj.TypeStr == "FruitCore":
				if _HoldObj.FruitNum > 0:
					_CanDrop = true
			else:
				if _HoldObj.HasContent:
					_CanDrop = true
				if _HoldObj.HasWater:
					_CanDrop = true
			if _CanDrop:
				match _ButID:
					- 2:
						if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
							return
						But_Switch(false, _Player)
					- 1:
						if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
							return

						var A_But = get_node("But/A")
						A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
						But_Switch(true, _Player)
					0:
						if GameLogic.Device.return_CanUse_bool(_Player):
							return
						var _Drop_Conut: int
						if _HoldObj.has_method("return_DropCount"):
							_Drop_Conut = _HoldObj.return_DropCount()
						if _HoldObj.has_method("call_Drop"):
							_HoldObj.call_Drop()
						if _DevObj.has_method("call_Trash_In"):
							_DevObj.call_Trash_In(_Drop_Conut)
							GameLogic.Device.call_TouchDev_Logic( - 1, _Player, _DevObj)

							But_Switch(false, _Player)
		else:
			if WarningAni:
				WarningAni.play("idle")


	pass

func call_BreakMachine_DropTrash(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _HoldObj.Liquid_Count == 0:
				return

			var A_But = get_node("But/A")
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _HoldObj.Liquid_Count > 0:
				if _HoldObj.Liquid_Count + Trash_Count <= Trash_Max:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						GameLogic.Device.call_TouchDev_Logic( - 1, _Player, self)
						return
					call_Trash_In(_HoldObj.Liquid_Count)
					_HoldObj.call_Drop()
					But_Switch(false, _Player)
					return true
				else:
					if _ButID == 0:
						if has_node("AniNode/Warning"):
							get_node("AniNode/Warning").play("idle")
							Audio_Wrong.play(0)
func call_Say_InWaterTank(_ButID, _Player, _HoldObj):
	match _ButID:
		0:
			if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
				_Player.call_Say_IntoSink()
				return

func call_IceCreamBox_DropTrash(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if not _HoldObj.MilkBool and not _HoldObj.CreamBool and not _HoldObj.FlavorType:
				return

			var A_But = get_node("But/A")
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return

			if _HoldObj.MilkBool or _HoldObj.CreamBool or _HoldObj.FlavorType:
				var _NUM = 0
				if _HoldObj.MilkBool:
					_NUM += 1
				if _HoldObj.CreamBool:
					_NUM += 1
				if _HoldObj.FlavorType:
					_NUM += 1
				if Trash_Count < Trash_Max:
					if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
						GameLogic.Device.call_TouchDev_Logic( - 1, _Player, self)
						return
					call_Trash_In(_NUM)
					_HoldObj.call_Empty()
					But_Switch(false, _Player)
					return true
				else:
					if _ButID == 0:
						if has_node("AniNode/Warning"):
							get_node("AniNode/Warning").play("idle")
							Audio_Wrong.play(0)
