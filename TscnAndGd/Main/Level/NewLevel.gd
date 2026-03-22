extends Node2D

var LevelName: String
var OpenTime: int
var CloseTime: int
var _Type: int
var IndoorArea: int
var OutdoorArea: int
var Rent: int
var RentPayDay: int
var Cost: int
var CustomerList: Array
var CustomerRank: int
var Traffic_Array: Array
var ShopPopular
var BrandPopular
var _NPCArray: Array
var _NPCRatio: Array

onready var Player
var Path2D_node_point_array = []
var AStar_begin_end_back_array = []
var begin_id
var end_id
var astar = AStar2D.new()
var walk = 0
var target = Vector2.ZERO
var speed = 50
var velocity = Vector2.ZERO

onready var TMap_Floor = get_node("MapNode/Floor")
onready var TMap_Street = get_node("MapNode/Street")
onready var TMap_StreetMain = get_node("MapNode/StreetMain")
onready var TMap_NPCFloor = get_node("MapNode/NPCFloor")
onready var TMap_Delivery = get_node("MapNode/Delivery")

onready var Ysort_Items = get_node("YSort/Items")
onready var Ysort_Dev = get_node("YSort/Devices")
onready var Ysort_Update = get_node("YSort/Updates")
onready var Ysort_Players = get_node("YSort/Players")

onready var Camera_Limit_Left = get_node("CameraPos2D/LeftTop").position.x
onready var Camera_Limit_Top = get_node("CameraPos2D/LeftTop").position.y
onready var Camera_Limit_Right = get_node("CameraPos2D/RightBottom").position.x
onready var Camera_Limit_Bottom = get_node("CameraPos2D/RightBottom").position.y
onready var CameraMain = $CameraNode
onready var CameraNode = $CameraNode / Camera2D

var UILAYER
var MenuList: Array
var RewardList: Array

var _2PlayerCamera

func call_update_get():
	GameLogic.cur_Level_Update.clear()
	var _UpdateList = Ysort_Update.get_children()
	for i in _UpdateList.size():
		GameLogic.cur_Level_Update.append(_UpdateList[i])
func _name_set():
	for i in GameLogic.cur_Level_Update.size():
		var _Obj = GameLogic.cur_Level_Update[i]
		var _Name = _Obj.editor_description
		if not GameLogic.cur_Update_Name.has(_Name):
			GameLogic.cur_Update_Name.append(_Name)

func _CloseLight():
	if has_node("LightNode"):
		get_node("LightNode").visible = false
	if GameLogic.LoadingUI.IsLevel:
		GameLogic.GameUI.MainMenu.call_reset()

func _OpenLight():
	GameLogic.call_OpenLight()

func _LEVELSTAT_LOGIC(_Stat: int):


	match _Stat:
		0:

			GameLogic.GameUI.call_UI_init()
			SteamLogic.JOIN.call_Master_WaitEnd()
			if has_node("DayInfoCanvasLayer"):
				return

			get_tree().set_pause(true)
			_Level_Init()
			GameLogic.GameUI.call_DevilLogic(true)
			GameLogic.GameUI.Order_SellCount = 0
			if not GameLogic.SPECIALLEVEL_Int:
				GameLogic.call_SceneConfig_load()
			var _TSCN = load("res://TscnAndGd/UI/InGame/DayInfoUI.tscn")
			var _DayInfoUI = _TSCN.instance()
			UILAYER = CanvasLayer.new()
			UILAYER.name = "DayInfoCanvasLayer"
			self.add_child(UILAYER)
			UILAYER.add_child(_DayInfoUI)


		1:

			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "_LEVELSTAT_LOGIC", [1])

			GameLogic.call_DayStart()
			if has_node("DayInfoCanvasLayer"):
				get_node("DayInfoCanvasLayer").queue_free()
			get_tree().set_pause(false)
			set_process(true)

			GameLogic.Con.call_player1P_set()
			GameLogic.Con.call_player2P_set()

			GameLogic.CustomerCheck()

			GameLogic.call_ESCLOGIC(true)

			_Auto_Buy()

		2:

			GameLogic.Achievement.call_Achievement_Logic()
			get_tree().call_group("STAFF", "call_del")
			get_tree().call_group("NPC", "call_del")
			GameLogic.Buy.call_init()
			_Buy_Init()
			_Event_Init()
			_npc_passer()
			_Staff_Create()
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				pass
			elif SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var CHALLENGE_TSCN = load("res://TscnAndGd/UI/InGame/ChallengeUI.tscn")
				var _TSCN = CHALLENGE_TSCN.instance()
				var _NAME: String = str(_TSCN.get_instance_id())
				_TSCN.name = _NAME
				SteamLogic.call_puppet_node_sync(self, "call_puppet_Challenge", [_NAME])
				self.add_child(_TSCN)
			else:
				var CHALLENGE_TSCN = load("res://TscnAndGd/UI/InGame/ChallengeUI.tscn")
				var _TSCN = CHALLENGE_TSCN.instance()
				_TSCN.name = str(_TSCN.get_instance_id())
				self.add_child(_TSCN)
			if GameLogic.GameUI.Tutorial_UI.return_TutorialCheck():

				get_tree().set_pause(true)
				return
			_LEVELSTAT_LOGIC(1)
func call_puppet_Challenge(_NAME: String):
	var CHALLENGE_TSCN = load("res://TscnAndGd/UI/InGame/ChallengeUI.tscn")
	var _TSCN = CHALLENGE_TSCN.instance()
	_TSCN.name = _NAME
	self.add_child(_TSCN)
func _Event_Init():
	_Scroll_Init()
	if GameLogic.cur_Event != "":
		if GameLogic.Config.EventConfig.has(GameLogic.cur_Event):
			match GameLogic.Config.EventConfig[GameLogic.cur_Event].Type:
				"升级":

					pass
				"招聘":
					_NewStaff_Init()
				"资金":
					print("Event 资金")
				"减压":
					print("Event 减压")
				"简化":
					print("Event 简化")

func _Scroll_Init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.cur_levelInfo.GamePlay.has("新手引导1"):
		if GameLogic.cur_Day in [1, 2, 3]:
			return
	GameLogic.cur_BuyNum = 1
	var _BuyMax = 2
	match GameLogic.cur_Event:
		"随机升级":

			_BuyMax += 1
		"随机升级+":
			GameLogic.cur_BuyNum += 1
			_BuyMax += 1
		"随机升级++":
			GameLogic.cur_BuyNum += 2
			_BuyMax += 2
	if GameLogic.Achievement.cur_EquipList.has("升级增强") and not GameLogic.SPECIALLEVEL_Int:
		_BuyMax += 2
	if GameLogic.Achievement.cur_EquipList.has("更多装备") and not GameLogic.SPECIALLEVEL_Int:
		GameLogic.cur_BuyNum += 1
	var _PointArray = TMap_Delivery.get_used_cells()
	_PointArray.shuffle()
	if not GameLogic.cur_levelInfo.GamePlay.has("新手引导1") and not GameLogic.SPECIALLEVEL_Int:
		var DEVIL_TSCN = load("res://TscnAndGd/Main/NPC/Devil_Update.tscn")
		var _DEVIL = DEVIL_TSCN.instance()
		_DEVIL.name = str(_DEVIL.get_instance_id())
		var _DEVILPOS = (get_node("PlayerPos2D/1").position + get_node("PlayerPos2D/4").position) / 2
		_DEVIL.position = _DEVILPOS
		Ysort_Update.add_child(_DEVIL)
		_DEVIL.call_init()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "_Puppet_Create_Item", ["Devil", _DEVIL.name, _DEVILPOS, null])
	if not GameLogic.SPECIALLEVEL_Int:
		for _i in _BuyMax:
			var _RewardTSCN = load("res://TscnAndGd/Objects/Home/ChooseMenu.tscn")
			var _Reward = _RewardTSCN.instance()
			_Reward.name = str(_Reward.get_instance_id())
			var _pointV2 = _PointArray.pop_back() * 100 + Vector2(50, 50)
			_Reward.position = _pointV2
			Ysort_Update.add_child(_Reward)
			var _RAND = GameLogic.return_randi() % RewardList.size()
			_Reward.RewardID = RewardList.pop_at(_RAND)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "_Puppet_Create_Item", ["ChooseMenu", _Reward.name, _pointV2, _Reward.RewardID])
func _NewStaff_Init():
	match GameLogic.cur_Event:
		"招聘点单":
			GameLogic.Staff.call_interview(1, "点单", 1)
		"招聘点单+":
			GameLogic.Staff.call_interview(1, "点单", 2)
		"招聘点单++":
			GameLogic.Staff.call_interview(1, "点单", 3)
		"招聘保洁":
			GameLogic.Staff.call_interview(1, "保洁", 1)
		"招聘保洁+":
			GameLogic.Staff.call_interview(1, "保洁", 2)
		"招聘保洁++":
			GameLogic.Staff.call_interview(1, "保洁", 3)
		"招聘搬运":
			GameLogic.Staff.call_interview(1, "搬运", 1)
		"招聘搬运+":
			GameLogic.Staff.call_interview(1, "搬运", 2)
		"招聘搬运++":
			GameLogic.Staff.call_interview(1, "搬运", 3)
		"招聘清洁":
			GameLogic.Staff.call_interview(1, "清洁", 1)
		"招聘清洁+":
			GameLogic.Staff.call_interview(1, "清洁", 2)
		"招聘清洁++":
			GameLogic.Staff.call_interview(1, "清洁", 3)
		"随机招聘":
			GameLogic.Staff.call_interview(1, "", 1)
		"随机招聘+":
			GameLogic.Staff.call_interview(1, "", 2)
		"随机招聘++":
			GameLogic.Staff.call_interview(1, "", 3)

func _MoneyEvent_Init():

	pass
func _Buy_Init():
	RewardList.clear()
	GameLogic.Card.call_new_buy()
	for _Name in GameLogic.Card.Cards_CanUsed:
		RewardList.append(_Name)

func _Level_Init():
	if not GameLogic.is_connected("CloseLight", self, "_CloseLight"):
		var _check = GameLogic.connect("CloseLight", self, "_CloseLight")
	_LoadGame()


	LevelName = GameLogic.cur_level


	GameLogic.call_StoreStar_Logic()


	if not GameLogic.ComputerLevel_bool:
		GameLogic.GameUI.call_init()


		Logic_Init()

	if GameLogic.LoadingUI.Tutorial:
		GameLogic.Save.call_levelData_load()
		GameLogic.LoadingUI.Tutorial = false
	call_Meteorite_init()


func _PlayerSYNC(_SYNCType: String, _SteamID: int, _Data: Array):
	for _playerNode in Ysort_Players.get_children():
		if _playerNode.cur_Player == _SteamID:
			_playerNode.Con.call_PlayerSYNC(_SYNCType, _Data)
			break



func call_SteamCheck_reset():
	for _MEMBER in SteamLogic.LOBBY_MEMBERS:
		_MEMBER.Check = false
func _Steam_Check():
	if not GameLogic.GameUI.DayEnd:
		return

	if SteamLogic.IsMultiplay:
		if not _NEWDAYBOOL:
			for _MEMBER in SteamLogic.LOBBY_MEMBERS:
				if _MEMBER.steam_id == SteamLogic.STEAM_ID and not SteamLogic.LOBBY_IsMaster:

					_MEMBER.Check = true
					SteamLogic.call_master_sync("Check")
					SteamLogic.JOIN.call_WaitNetPlayer()
					get_tree().set_pause(true)
					break
		else:
			SteamLogic.JOIN.call_WaitNetPlayer()

		var _CheckFailList = _Check_Steam_AllPlayer_Loading()
		printerr("   _Steam_Check _CheckFailList:", _CheckFailList)
		if _CheckFailList:

			SteamLogic.JOIN.call_WaitNetPlayer()
			get_tree().set_pause(true)
		elif SteamLogic.CanStart:
			if SteamLogic.LOBBY_IsMaster:

				SteamLogic.CanStart = false
				SteamLogic.call_everybody_node_sync(self, "_LEVELSTAT_LOGIC", [0])
				SteamLogic.call_MemberCheck_init()
func _Check_Steam_AllPlayer_Loading():
	if not GameLogic.LoadingUI.IsLevel:
		return
	if SteamLogic.LOBBY_IsMaster:
		var _CheckFailList: Array
		for _MEMBER in SteamLogic.LOBBY_MEMBERS:
			if not _MEMBER.Check:
				if _MEMBER.steam_id != SteamLogic.MasterID:
					_CheckFailList.append(_MEMBER)
		if _CheckFailList:
			return _CheckFailList



		return _CheckFailList
	else:

		return false

var _NEWDAYBOOL: bool = false

func call_NewDay_Master():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_NewDay_puppet", [GameLogic.Save.levelData])

func call_NewDay_puppet(_DATA):

	SteamLogic.LOBBY_levelData = _DATA
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_master_sync("Check")
func call_NewDay():

	call_DelItem()
	_NEWDAYBOOL = true
	if SteamLogic.IsMultiplay:
		SteamLogic.call_MemberCheck_init()
	call_NewDay_Master()
	_ready()
func _ready() -> void :

	self.name = "Level"

	TMap_Floor.hide()
	TMap_NPCFloor.hide()

	if GameLogic.LoadingUI.IsLevel:
		call_camera_init()
		CameraNode.current = true

	elif GameLogic.ShowLevel_bool:
		call_update_get()
		_name_set()
		if has_node("DayLight"):
			get_node("DayLight").visible = false
		call_camera_init()
		_CloseLight()
		if has_node("CameraShow"):
			get_node("CameraShow").current = true
	set_process(false)
	if has_node("LightNode"):
		get_node("LightNode").visible = false

	if not GameLogic.cur_level:

		_newGame()


	TMap_AStarLogic()
	if GameLogic.LoadingUI.IsLevel:
		if is_instance_valid(GameLogic.player_1P):

			GameLogic.player_1P = null
			if is_instance_valid(GameLogic.player_2P):
				GameLogic.player_2P = null
			for _PLAYER in Ysort_Players.get_children():
				_PLAYER.queue_free()

	if GameLogic.ShowLevel_bool:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.CanStart = false
	else:
		SteamLogic.CanStart = true
	if SteamLogic.IsMultiplay:
		_PlayerCreate()
		_Steam_Check()
		if SteamLogic.LOBBY_IsMaster:

			if not SteamLogic.is_connected("MasterSYNC", self, "_Steam_Check"):
				var _SteamCon = SteamLogic.connect("MasterSYNC", self, "_Steam_Check")

		if not SteamLogic.is_connected("CreateNetPlayer", self, "call_NetWork_PlayerCreate"):
			var _Con = SteamLogic.connect("CreateNetPlayer", self, "call_NetWork_PlayerCreate")
		if not SteamLogic.is_connected("SentPlayerToMaster", self, "call_master_PlayerCreate"):
			var _Con = SteamLogic.connect("SentPlayerToMaster", self, "call_master_PlayerCreate")
	elif GameLogic.LoadingUI.IsLevel:

		_PlayerCreate()
		_LEVELSTAT_LOGIC(0)


	if not GameLogic.is_connected("NewDay", self, "call_NewDay"):
		var _con = GameLogic.connect("NewDay", self, "call_NewDay")
	if not SteamLogic.is_connected("PlayerSYNC", self, "_PlayerSYNC"):
		var _SteamCon = SteamLogic.connect("PlayerSYNC", self, "_PlayerSYNC")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

	GameLogic.cur_LevelDifficult.clear()
	if GameLogic.Config.SceneConfig.has(GameLogic.cur_level):
		var _Difficult = GameLogic.Config.SceneConfig[GameLogic.cur_level].Difficult
		for _DifName in _Difficult:
			GameLogic.cur_LevelDifficult.append(str(_DifName))






		return
func _BlackOut(_Switch: bool):
	if _Switch:
		var _LIST = get_node("LightNode").get_children()
		for _NODE in _LIST:
			_NODE.hide()
	else:
		var _LIST = get_node("LightNode").get_children()
		for _NODE in _LIST:
			_NODE.show()







func call_master_PlayerCreate():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if is_instance_valid(GameLogic.player_1P):
			var _PlayerPos = GameLogic.player_1P.global_position
			var _cur_face = GameLogic.player_1P.cur_face
			var _SkillList = GameLogic.player_1P.Stat.Skills
			var _ID = GameLogic.player_1P.cur_ID
			var _TSCN = GameLogic.Config.PlayerConfig[str(_ID)].TSCN


			var _ARRAY = [_TSCN, _ID, SteamLogic.STEAM_ID, _PlayerPos, _cur_face, _SkillList, {}]
			SteamLogic.call_master_node_sync(self, "call_NetWork_PlayerCreate", [_ARRAY])
func _PlayerCreate():

	if not is_instance_valid(GameLogic.player_1P):

		var _Player1P = GameLogic.TSCNLoad.return_player(1).instance()
		var _ID = int(GameLogic.player_1P_ID)
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			_ID = GameLogic.JoinPlayer

		_Player1P.cur_ID = _ID
		var _TSCNName = GameLogic.Config.PlayerConfig[str(_ID)].TSCN
		var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
		_Avatar.name = "Avatar"

		if SteamLogic.STEAM_ID:
			_Player1P.cur_Player = SteamLogic.STEAM_ID
		else:
			_Player1P.cur_Player = 1
		_Player1P.name = str(_Player1P.cur_Player)

		var _POS = get_node("PlayerPos2D/1").position
		if SteamLogic.IsMultiplay:
			if SteamLogic.SLOT_2 == SteamLogic.STEAM_ID:
				if has_node("PlayerPos2D/2"):
					_POS = get_node("PlayerPos2D/2").position
			if SteamLogic.SLOT_3 == SteamLogic.STEAM_ID:
				if has_node("PlayerPos2D/3"):
					_POS = get_node("PlayerPos2D/3").position
			if SteamLogic.SLOT_4 == SteamLogic.STEAM_ID:
				if has_node("PlayerPos2D/4"):
					_POS = get_node("PlayerPos2D/4").position
		_Player1P.position = _POS
		Ysort_Players.add_child(_Player1P)

		_Player1P.CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
		_Player1P.CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
		_Player1P.CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
		_Player1P.CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)


		if not GameLogic.AllStaff.has(_Player1P):
			GameLogic.AllStaff.append(_Player1P)
		_Player1P.AvatarNode.add_child(_Avatar)
		_Player1P.call_init()
		GameLogic.player_1P = _Player1P

		_Player1P.CameraNode.reset_smoothing()
		_Player1P.add_to_group("PLAYER")
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			var _PlayerPos = _Player1P.global_position
			var _cur_face = _Player1P.cur_face
			var _SkillList = _Player1P.Stat.Skills
			var _FashionDic: Dictionary = GameLogic.Save.gameData["EquipDic"][1][_ID]

			var _ARRAY = [_TSCNName, _ID, SteamLogic.STEAM_ID, _PlayerPos, _cur_face, _SkillList, _FashionDic]
			SteamLogic.call_master_node_sync(self, "call_NetWork_PlayerCreate", [_ARRAY])
			_Player1P._MultName_Logic()


	if GameLogic.Player2_bool:


		if not is_instance_valid(GameLogic.player_2P):
			var _Player2P = GameLogic.TSCNLoad.return_player(2).instance()
			var _TSCNName = GameLogic.Config.PlayerConfig[str(GameLogic.player_2P_ID)].TSCN
			_Player2P.cur_ID = int(GameLogic.player_2P_ID)
			var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
			_Avatar.name = "Avatar"

			_Player2P.position = get_node("PlayerPos2D/2").position
			_Player2P.cur_Player = 2
			_Player2P.name = str(_Player2P.cur_Player)
			Ysort_Players.add_child(_Player2P)

			_Player2P.CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
			_Player2P.CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
			_Player2P.CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
			_Player2P.CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)
			_Player2P.CameraNode.reset_smoothing()

			GameLogic.AllStaff.append(_Player2P)
			_Player2P.AvatarNode.add_child(_Avatar)
			_Player2P.call_init()
			GameLogic.player_2P = _Player2P



			CameraNode.current = true
			var _CameraZoom: Vector2 = Vector2(0.75, 0.75)
			if GameLogic.GlobalData.globalini.has("Camera"):
				var _ZoomNum: float = float(GameLogic.GlobalData.globalini.Camera) / 100
				_CameraZoom = Vector2(_ZoomNum, _ZoomNum)
			CameraNode.scale = _CameraZoom
			CameraNode.reset_smoothing()
			_Player2P.add_to_group("PLAYER")

func call_Player2_puppet():
	var _Player2P = GameLogic.TSCNLoad.return_player(2).instance()
	var _TSCNName = GameLogic.Config.PlayerConfig[str(GameLogic.player_2P_ID)].TSCN
	_Player2P.cur_ID = int(GameLogic.player_2P_ID)
	var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = "Avatar"

	_Player2P.position = get_node("PlayerPos2D/2").position
	_Player2P.cur_Player = 2
	_Player2P.name = str(_Player2P.cur_Player)
	Ysort_Players.add_child(_Player2P)



	GameLogic.AllStaff.append(_Player2P)
	_Player2P.AvatarNode.add_child(_Avatar)
	_Player2P.call_init()
	GameLogic.player_2P = _Player2P



	_Player2P.add_to_group("PLAYER")
func _Staff_Create():



	if GameLogic.SPECIALLEVEL_Int:
		var _Create_Array = GameLogic.NPC.Path2D_Array
		var _Crand = GameLogic.return_RANDOM() % _Create_Array.size()

	if GameLogic.curLevelList.has("难度-检查员"):
		GameLogic.NPC.call_Checker(GameLogic.HomeMoneyKey)
	if GameLogic.curLevelList.has("难度-督导"):
		GameLogic.NPC.call_Overseer(GameLogic.HomeMoneyKey)



	var StaffList = GameLogic.cur_Staff.keys()

	if StaffList:
		for _StaffID in StaffList:
			var _TSCN = load("res://TscnAndGd/Main/NPC/Staff.tscn")
			var _StaffNode = _TSCN.instance()
			var _NPC_Create_Array = GameLogic.NPC.Path2D_Array
			var _rand = GameLogic.return_RANDOM() % _NPC_Create_Array.size()
			_StaffNode.position = _NPC_Create_Array[_rand]
			Ysort_Players.add_child(_StaffNode)
			_StaffNode.IsStaff = true
			_StaffNode.HomePoint = _NPC_Create_Array[_rand]
			_StaffNode.Name = _StaffID
			_StaffNode.call_load(GameLogic.cur_Staff[_StaffID])



func call_NetWork_PlayerCreate(_DataArray: Array):
	print("创建网络其他玩家角色", _DataArray)
	var _TSCN = _DataArray[0]
	var _cur_ID = _DataArray[1]
	var _cur_Player_ID = _DataArray[2]
	var _Pos = _DataArray[3]

	var _AVATARDIC = _DataArray[6]
	if _cur_Player_ID == SteamLogic.STEAM_ID:
		return
	if GameLogic.LoadingUI.IsLevel:

		_AVATARDIC = SteamLogic._FASHIONDIC[int(_cur_Player_ID)]
	if Ysort_Players.has_node(str(_cur_Player_ID)):

		return
	var _NetPlayer = GameLogic.TSCNLoad.return_player(1).instance()
	var _TSCNName = _TSCN
	_NetPlayer.cur_ID = int(_cur_ID)
	var _Avatar = GameLogic.TSCNLoad.return_character(_TSCNName).instance()
	_Avatar.name = "Avatar"

	var _POS = get_node("PlayerPos2D/1").position
	if SteamLogic.IsMultiplay:
		if SteamLogic.SLOT_2 == _cur_Player_ID:
			if has_node("PlayerPos2D/2"):
				_POS = get_node("PlayerPos2D/2").position
		if SteamLogic.SLOT_3 == _cur_Player_ID:
			if has_node("PlayerPos2D/3"):
				_POS = get_node("PlayerPos2D/3").position
		if SteamLogic.SLOT_4 == _cur_Player_ID:
			if has_node("PlayerPos2D/4"):
				_POS = get_node("PlayerPos2D/4").position
	_NetPlayer.position = _POS
	_NetPlayer.cur_Player = _cur_Player_ID
	_NetPlayer.name = str(_cur_Player_ID)
	if _DataArray.size() >= 5:
		var _cur_face = _DataArray[4]
		_NetPlayer.cur_face = _cur_face
	Ysort_Players.add_child(_NetPlayer)




	if not GameLogic.AllStaff.has(_NetPlayer):
		GameLogic.AllStaff.append(_NetPlayer)
	_NetPlayer.AvatarNode.add_child(_Avatar)
	_NetPlayer.call_init()

	if _DataArray.size() >= 6:
		var _SKILLS = _DataArray[5]
		_NetPlayer.Stat.Skills = _SKILLS
		print("测试 联网角色1：", _SKILLS)
	print("测试 联网角色：", _NetPlayer.Stat.Skills)

	_NetPlayer._MultName_Logic()
	_NetPlayer.Stat.call_CollisionAni()

	_NetPlayer.call_Fashion_init(_AVATARDIC)

	_NetPlayer.add_to_group("PLAYER")
	if SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_PLAYER_SYNC()

func _dev_save():


	GameLogic.Save.levelData["Devices"] = []
	var _DevList = Ysort_Dev.get_children()
	for i in _DevList.size():
		var _Dev = _DevList[i]
		var _Data = GameLogic.Save.return_savedata(_Dev)
		GameLogic.Save.levelData["Devices"].insert(GameLogic.Save.levelData["Devices"].size(), _Data)

func _item_save():
	GameLogic.Save.levelData["Items"] = []
	var _ItemList = Ysort_Items.get_children()
	for i in _ItemList.size():
		var _ItemOBJ = _ItemList[i]
		var _ItemName = _ItemOBJ.TypeStr
		var _Data = GameLogic.Save.return_savedata(_ItemOBJ)
		GameLogic.Save.levelData["Items"].insert(GameLogic.Save.levelData["Items"].size(), _Data)

func call_level_save():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		_del_Item()
		return
	_dev_save()
	_item_save()

	_del_Item()
func call_DelItem():
	_del_Item()

func _Auto_Buy():



	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	if not GameLogic.Achievement.cur_EquipList.has("自动进货") and not GameLogic.SPECIALLEVEL_Int:
		if GameLogic.cur_Day > 1 and not GameLogic.SPECIALLEVEL_Int:
			print("大于第一天不可自动进货")
			return


	var _Delivery_Array: Array
	var _UsedArray = TMap_Delivery.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
		_Delivery_Array.append(_pointV2)
	_Delivery_Array.shuffle()

	var _TABLE_NUM: int = 0
	if GameLogic.Achievement.cur_EquipList.has("初始桌架") and GameLogic.cur_Day == 1:
		_TABLE_NUM = 1
	if GameLogic.SPECIALLEVEL_Int:
		if GameLogic.cur_Rewards.has("新增桌台"):
			_TABLE_NUM = 1
		elif GameLogic.cur_Rewards.has("新增桌台+"):
			_TABLE_NUM = 2
	for i in _TABLE_NUM:

		var _rand = GameLogic.return_randi() % _Delivery_Array.size()

		var _TSCN = load("res://TscnAndGd/Objects/Devices/Shelf_OnTable.tscn")
		var _Item = _TSCN.instance()
		var _Info: Dictionary = {
		"NAME": str(_Item.get_instance_id()),
		"pos": _Delivery_Array[_rand],
		"LayerA_Obj": null,
		"LayerB_Obj": null,
		"LayerX_Obj": null,
		"LayerY_Obj": null,
		}
		_Item.name = str(_Item.get_instance_id())
		_Item.position = _Delivery_Array[_rand]
		Ysort_Items.add_child(_Item)
		_Item.call_load(_Info)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

			SteamLogic.call_puppet_node_sync(self, "_Puppet_Create_Item", ["Shelf_OnTable", _Item.name, _Item.global_position, _Info])

	if GameLogic.Achievement.cur_EquipList.has("初始雪克杯") and GameLogic.cur_Day == 1 and not GameLogic.SPECIALLEVEL_Int:
		var _rand = GameLogic.return_randi() % _Delivery_Array.size()
		var _ItemName = "ShakeCup"
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
		var _Item = _TSCN.instance()
		_Item.name = str(_Item.get_instance_id())
		_Item.position = _Delivery_Array[_rand]
		Ysort_Items.add_child(_Item)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "_Puppet_Create_Item", ["ShakeCup", _Item.name, _Item.global_position, null])






	var _CostTotal: int = 0
	var _DelNum: int = 0
	var AutoList: Array = []
	var _AutoBool: bool = GameLogic.Save.gameData["SubStation_AutoShelf"]
	for i in GameLogic.Buy.Sell_2.size():
		var _itemName = GameLogic.Buy.Sell_2[i]
		if GameLogic.Config.ItemConfig.has(_itemName):
			var _NameInList = _itemName
			match _itemName:
				"DrinkCup_S":
					_NameInList = "DrinkCup_Group_S"
				"DrinkCup_M":
					_NameInList = "DrinkCup_Group_M"
				"DrinkCup_L":
					_NameInList = "DrinkCup_Group_L"
			if GameLogic.SPECIALLEVEL_Int and not _NameInList in ["SodaCan_S", "SodaCan_M", "SodaCan_L"] and _AutoBool:
				AutoList.append(_NameInList)
				continue

			if GameLogic.cur_Item_List.has(_NameInList):
				if GameLogic.cur_Item_List[_NameInList] > 0:
					continue

			_CostTotal += return_Box_Create(_itemName, _Delivery_Array[_DelNum])
			if _DelNum >= _Delivery_Array.size() - 1:
				_DelNum = 0
			else:
				_DelNum += 1

	for i in GameLogic.Buy.Sell_1.size():
		var _itemName = GameLogic.Buy.Sell_1[i]


		if GameLogic.SPECIALLEVEL_Int and _AutoBool:
			AutoList.append(_itemName)
			continue
		if GameLogic.cur_Item_List.has(_itemName):
			if GameLogic.cur_Item_List[_itemName] > 0:
				continue
		if GameLogic.Config.ItemConfig.has(_itemName):
			_CostTotal += return_Box_Create(_itemName, _Delivery_Array[_DelNum])
			if _DelNum >= _Delivery_Array.size() - 1:
				_DelNum = 0
			else:
				_DelNum += 1

	for i in GameLogic.Buy.Sell_3.size():
		var _itemName = GameLogic.Buy.Sell_3[i]
		if GameLogic.SPECIALLEVEL_Int and _AutoBool:
			AutoList.append(_itemName)
			continue
		if GameLogic.cur_Item_List.has(_itemName):
			if GameLogic.cur_Item_List[_itemName] > 0:
				continue

		if GameLogic.Config.ItemConfig.has(_itemName):


			_CostTotal += return_Box_Create(_itemName, _Delivery_Array[_DelNum])
			if _DelNum >= _Delivery_Array.size() - 1:
				_DelNum = 0
			else:
				_DelNum += 1



	if AutoList.size():
		var _SHELFNUM: int = 0
		var _SHELFLIST: Array
		var _SHELFNUMLIST: Array
		var _CUPSHELFLIST: Array
		var _CUPSHELFNUMLIST: Array
		var _FREEZERLIST: Array
		var _FREEZERNUMLIST: Array
		var _FROZENLIST: Array
		var _FROZENNUMLIST: Array
		var _FRUITLIST: Array
		var _FRUITNUMLIST: Array

		var _CUPSHELFBOOL: bool = false
		if GameLogic.NPC.SHELF.size():
			for _SHELF in GameLogic.NPC.SHELF:
				var _TYPE = _SHELF.get("AUTOTYPE")
				if _TYPE > 0:
					_CUPSHELFBOOL = true
					break
		for _NAME in AutoList:
			if GameLogic.Config.ItemConfig.has(_NAME):
				var _INFO = GameLogic.Config.ItemConfig[_NAME]
				var _NUM = int(_INFO.BuyNum)
				var _FRESH = int(_INFO.FreshType)
				_CostTotal += _NUM * int(_INFO.Sell)
				if _INFO.FuncType in ["Fruit"]:
					_FRUITLIST.append(_NAME)
					_FRUITNUMLIST.append(_NUM)
				else:
					match _FRESH:
						0:

							if _NAME in ["DrinkCup_Group_S", "DrinkCup_Group_M", "DrinkCup_Group_L"] and _CUPSHELFBOOL:
								_CUPSHELFLIST.append(_NAME)
								_CUPSHELFNUMLIST.append(_NUM)
							else:
								_SHELFLIST.append(_NAME)
								_SHELFNUMLIST.append(_NUM)

						2, 3:
							_FREEZERLIST.append(_NAME)
							_FREEZERNUMLIST.append(_NUM)
						5:
							_FROZENLIST.append(_NAME)
							_FROZENNUMLIST.append(_NUM)

		if GameLogic.NPC.SHELF.size():
			for _SHELF in GameLogic.NPC.SHELF:
				var _NAMELIST: Array
				var _NUMLIST: Array
				var _NUM: int = 4


				var _TYPE = _SHELF.get("AUTOTYPE")
				if _TYPE == 0:
					if _SHELFLIST.size() < 4:
						_NUM = _SHELFLIST.size()
					for i in _NUM:
						_NAMELIST.append(_SHELFLIST.pop_front())
						_NUMLIST.append(_SHELFNUMLIST.pop_front())
				elif _TYPE == 1:
					if _CUPSHELFLIST.size() < 4:
						_NUM = _CUPSHELFLIST.size()
					for i in _NUM:
						_NAMELIST.append(_CUPSHELFLIST.pop_front())
						_NUMLIST.append(_CUPSHELFNUMLIST.pop_front())
				_SHELF.call_auto(_NAMELIST, _NUMLIST)

		if _SHELFLIST.size():
			for _NAME in _SHELFLIST:
				return_Box_Create(_NAME, _Delivery_Array[_DelNum])
				if _DelNum >= _Delivery_Array.size() - 1:
					_DelNum = 0
				else:
					_DelNum += 1
		if _CUPSHELFLIST.size():
			for _NAME in _CUPSHELFLIST:
				return_Box_Create(_NAME, _Delivery_Array[_DelNum])
				if _DelNum >= _Delivery_Array.size() - 1:
					_DelNum = 0
				else:
					_DelNum += 1

		if _FRUITLIST.size() and GameLogic.NPC.FRUITSHELF.size():
			for _SHELF in GameLogic.NPC.FRUITSHELF:
				var _NAMELIST: Array
				var _NUMLIST: Array
				var _NUM: int = 4
				if _FRUITLIST.size() < 4:
					_NUM = _FRUITLIST.size()
				for i in _NUM:
					_NAMELIST.append(_FRUITLIST.pop_front())
					_NUMLIST.append(_FRUITNUMLIST.pop_front())
				_SHELF.call_auto(_NAMELIST, _NUMLIST)
				if not _FRUITLIST.size():
					break
		if _FRUITLIST.size():
			for _NAME in _FRUITLIST:
				return_Box_Create(_NAME, _Delivery_Array[_DelNum])
				if _DelNum >= _Delivery_Array.size() - 1:
					_DelNum = 0
				else:
					_DelNum += 1

		if _FREEZERLIST.size() and GameLogic.NPC.FREEZER.size():
			for _SHELF in GameLogic.NPC.FREEZER:
				var _NAMELIST: Array
				var _NUMLIST: Array
				var _NUM: int = 4
				if _FREEZERLIST.size() < 4:
					_NUM = _FREEZERLIST.size()
				for i in _NUM:
					_NAMELIST.append(_FREEZERLIST.pop_front())
					_NUMLIST.append(_FREEZERNUMLIST.pop_front())
				_SHELF.call_auto(_NAMELIST, _NUMLIST)
				if not _FREEZERLIST.size():
					break
		if _FREEZERLIST.size():
			for _NAME in _FREEZERLIST:
				return_Box_Create(_NAME, _Delivery_Array[_DelNum])
				if _DelNum >= _Delivery_Array.size() - 1:
					_DelNum = 0
				else:
					_DelNum += 1

		if _FROZENLIST.size() and GameLogic.NPC.FROZEN.size():
			for _SHELF in GameLogic.NPC.FROZEN:
				var _NAMELIST: Array
				var _NUMLIST: Array
				var _NUM: int = 4
				if _FROZENLIST.size() < 4:
					_NUM = _FROZENLIST.size()
				for i in _NUM:
					_NAMELIST.append(_FROZENLIST.pop_front())
					_NUMLIST.append(_FROZENNUMLIST.pop_front())
				_SHELF.call_auto(_NAMELIST, _NUMLIST)
				if not _FROZENLIST.size():
					break
		if _FROZENLIST.size():
			for _NAME in _FROZENLIST:
				return_Box_Create(_NAME, _Delivery_Array[_DelNum])
				if _DelNum >= _Delivery_Array.size() - 1:
					_DelNum = 0
				else:
					_DelNum += 1
		print(" autoload:", AutoList)


	if _CostTotal:
		if GameLogic.Achievement.cur_EquipList.has("自动进货") and not GameLogic.SPECIALLEVEL_Int:
			_CostTotal = int(float(_CostTotal) * 0.8)
		GameLogic.Cost_Items += _CostTotal
	GameLogic.GameUI.OrderNode.Order_SellCount = int(_CostTotal)
	GameLogic.GameUI.Order_SellCount = int(_CostTotal)
	GameLogic.GameUI.sellCount_ShowLogic()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_start_sell_puppet", [GameLogic.GameUI.OrderNode.Order_SellCount])

func call_start_sell_puppet(_TOTAL):
	GameLogic.GameUI.OrderNode.Order_SellCount = int(_TOTAL)
	GameLogic.GameUI.Order_SellCount = int(_TOTAL)
	GameLogic.GameUI.sellCount_ShowLogic()
func return_Box_Create(_ItemName, _pos):
	var _Num = GameLogic.Config.ItemConfig[_ItemName]["BuyNum"]
	if _ItemName in ["拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛"]:

		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemName)
		var _Item = _TSCN.instance()
		var _Info: Dictionary = {
			"TSCN": _ItemName,
			"NAME": str(_Item.get_instance_id()),
			"pos": _pos,
			"Liquid_Count": 40,
			"IsOpen": false,
		}
		_Item.name = str(_Item.get_instance_id())
		_Item.position = _pos
		Ysort_Items.add_child(_Item)
		_Item.call_load(_Info)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "_Puppet_Create_Item", [_ItemName, _Item.name, _Item.global_position, _Info])
	else:


		var _ItemData: Dictionary = {
			"TSCN": "Box_M_Paper",
			"IsOpen": false,
			"pos": _pos,
			"HasItem": true,
			"ItemName": _ItemName,
			"ItemNum": _Num,
			}
		var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemData.TSCN)
		var _Item = _TSCN.instance()
		_Item._SELFID = _Item.get_instance_id()
		_Item.name = str(_Item._SELFID)
		_ItemData["NAME"] = _Item.name
		_Item.position = _ItemData.pos
		Ysort_Items.add_child(_Item)

		_Item.call_load(_ItemData)
		_Item.call_create_num(_ItemData.ItemNum)
		_Item.call_deferred("call_new")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _CurItemNameDic: Dictionary = _Item._ItemNameDic
			var _CurNum = _CurItemNameDic.size()
			var _MaxNum = _Item.BuyNum

			SteamLogic.call_puppet_node_sync(GameLogic.Buy, "call_puppet_Box_Create", [_ItemName, _pos, _Item.name, _CurNum, _MaxNum, _CurItemNameDic])

	var _Cost = int(_Num) * int(GameLogic.Config.ItemConfig[_ItemName].Sell)

	var _Mult: float = 1
	if GameLogic.cur_Rewards.has("物料供应"):
		_Mult -= 0.25
	if GameLogic.cur_Rewards.has("物料供应+"):
		_Mult -= 0.5
	if GameLogic.cur_Challenge.has("物价上涨"):
		_Mult += 0.5
	if GameLogic.cur_Challenge.has("物价上涨+"):
		_Mult += 1
	if GameLogic.Achievement.cur_EquipList.has("进货降价") and not GameLogic.SPECIALLEVEL_Int:
		_Mult -= 0.2
	_Cost = int(float(_Cost) * _Mult)
	if _Cost < 0:
		_Cost = 0


	return _Cost
func _newGame():

	if not GameLogic.cur_level:
		GameLogic.Save.levelData["Devices"] = []
		GameLogic.Save.levelData["Items"] = []

		GameLogic.new_bool = false

		_dev_save()
		_item_save()

func _del_Dev():
	var _DevList = Ysort_Dev.get_children()
	for i in _DevList.size():
		var _Dev = _DevList[i]
		_Dev.queue_free()

	var _UpdateList = Ysort_Update.get_children()
	for i in _UpdateList.size():
		var _UpdateObj = _UpdateList[i]
		if GameLogic.ComputerLevel_bool:
			_UpdateObj.hide()
		else:
			_UpdateObj.queue_free()
func _del_Item():
	var _DevList = Ysort_Items.get_children()
	for i in _DevList.size():
		var _Dev = _DevList[i]
		_Dev.queue_free()
func _del_NPC():
	var _NPCList = get_node("YSort/NPCs").get_children()
	for i in _NPCList.size():
		var _NPC = _NPCList[i]
		_NPC.get_parent().remove_child(_NPC)
		_NPC.queue_free()
func _LoadGame():

	_del_Dev()
	_del_Item()
	var _ItemKeys = GameLogic.cur_Item_List.keys()
	for _i in _ItemKeys.size():
		GameLogic.cur_Item_List[_ItemKeys[_i]] = 0

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.LOBBY_levelData.has("Devices"):
			for i in SteamLogic.LOBBY_levelData["Devices"].size():
				var _DevInfo = SteamLogic.LOBBY_levelData["Devices"][i]
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_DevInfo.TSCN)
				if _TSCN != null:
					var _Dev = _TSCN.instance()

					_Dev.position = _DevInfo.pos
					Ysort_Dev.add_child(_Dev)
					_Dev.call_load(_DevInfo)
		if SteamLogic.LOBBY_levelData.has("Items"):
			for i in SteamLogic.LOBBY_levelData["Items"].size():
				var _ItemInfo = SteamLogic.LOBBY_levelData["Items"][i]
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemInfo.TSCN)
				if _TSCN != null:
					var _Item = _TSCN.instance()

					_Item.position = _ItemInfo.pos
					Ysort_Items.add_child(_Item)
					_Item.call_load(_ItemInfo)
	else:
		if GameLogic.Save.levelData.has("Devices"):
			for i in GameLogic.Save.levelData["Devices"].size():
				var _DevInfo = GameLogic.Save.levelData["Devices"][i]

				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_DevInfo.TSCN)
				if _TSCN != null:
					var _Dev = _TSCN.instance()

					_Dev.position = _DevInfo.pos
					Ysort_Dev.add_child(_Dev)
					_Dev.call_load(_DevInfo)
		if GameLogic.Save.levelData.has("Items"):
			for i in GameLogic.Save.levelData["Items"].size():
				var _ItemInfo = GameLogic.Save.levelData["Items"][i]
				var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemInfo.TSCN)
				if _TSCN != null:
					var _Item = _TSCN.instance()

					_Item.position = _ItemInfo.pos
					Ysort_Items.add_child(_Item)
					_Item.call_load(_ItemInfo)

func Logic_Init():

	_Extra_init()

	GameLogic.NPC.call_level_init()
	GameLogic.Staff.call_level_init()

	GameLogic.Audio.call_TileSet(get_node("MapNode/Audio"))

func _Extra_init():

	GameLogic.cur_Extra.clear()
	for _MenuName in GameLogic.cur_Menu:
		if GameLogic.Config.FormulaConfig.has(_MenuName):
			var _MenuTag = GameLogic.Config.FormulaConfig[_MenuName].Tag

			var _CHECK: bool = false
			for _TAG in ["其他配料", "万能配料", "奶茶配料", "自制配料"]:
				if _TAG in _MenuTag:

					if not GameLogic.cur_Extra.has(_MenuName):
						GameLogic.cur_Extra.append(_MenuName)

func _npc_passer():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _pos_array: Array
	var _UsedArray = TMap_StreetMain.get_used_cells()
	for _i in _UsedArray.size():
		var _pointV2 = _UsedArray[_i] * 100 + Vector2(50, 50)
		_pos_array.append(_pointV2)

	_pos_array.shuffle()

	var _Num: int = int(float(GameLogic.GameUI.cur_Traffic) / 12)


	for _i in _Num:
		var _POS = _pos_array.pop_back()
		GameLogic.NPC.call_passer_start(_POS)

	pass
func TMap_AStarLogic():
	if not GameLogic.LoadingUI.IsLevel:
		return
	_del_NPC()
	if GameLogic.Astar.cur_level != GameLogic.cur_level:
		GameLogic.Astar.call_Path2D_init()
	if GameLogic.Astar.AStar_Func.get_point_count() == 0:
		GameLogic.Astar.call_TMap_init(TMap_Floor)
		GameLogic.Astar.call_TMap_init_NPC(TMap_NPCFloor)
		GameLogic.Astar.call_TMap_Street_init(TMap_StreetMain, TMap_Street)


		if has_node("MapNode/Leave"):
			var _LeaveNode = get_node("MapNode/Leave")
			GameLogic.Astar.call_Leave_Init(_LeaveNode)

		GameLogic.Astar.connect_init()

func call_camera_init():
	CameraNode.zoom = Vector2.ONE
	CameraNode.set_limit(MARGIN_LEFT, Camera_Limit_Left)
	CameraNode.set_limit(MARGIN_TOP, Camera_Limit_Top)
	CameraNode.set_limit(MARGIN_RIGHT, Camera_Limit_Right)
	CameraNode.set_limit(MARGIN_BOTTOM, Camera_Limit_Bottom)
	CameraNode.smoothing_enabled = true

	var _CameraZoom: Vector2 = Vector2(0.75, 0.75)
	if GameLogic.GlobalData.globalini.has("Camera"):
		var _ZoomNum: float = float(GameLogic.GlobalData.globalini.Camera) / 100
		_CameraZoom = Vector2(_ZoomNum, _ZoomNum)

		CameraNode.zoom = _CameraZoom



	pass
func _process(_delta: float) -> void :


	if GameLogic.Player2_bool and GameLogic.player_2P:
		if is_instance_valid(GameLogic.player_1P) and is_instance_valid(GameLogic.player_2P):
			var _Y: int = - 100
			var _Pos = ((GameLogic.player_2P.position + Vector2(0, _Y)) + (GameLogic.player_1P.position + Vector2(0, _Y))) / 2

			CameraMain.position = ((GameLogic.player_2P.position + Vector2(0, _Y)) + (GameLogic.player_1P.position + Vector2(0, _Y))) / 2


			var _space_x: float = abs(GameLogic.player_1P.position.x - GameLogic.player_2P.position.x)
			var _space_y: float = abs(GameLogic.player_1P.position.y - GameLogic.player_2P.position.y)
			var _Mult: float = 1
			if GameLogic.GlobalData.globalini.has("Camera"):
				_Mult = float(GameLogic.GlobalData.globalini.Camera) / 100
			if _space_x > 1920 * _Mult or _space_y > 1060 * _Mult:
				var _zoom_x: float = 0.0
				var _zoom_y: float = 0.0
				var _zoom: float = 0.0
				_zoom_x = _space_x / 1920
				_zoom_y = _space_y / 1060
				if _zoom_x > _zoom_y:
					_zoom = _zoom_x
				else:
					_zoom = _zoom_y
				CameraNode.zoom = Vector2(_zoom + 0.1, _zoom + 0.1)
				if CameraNode.zoom > Vector2(2, 2):
					CameraNode.zoom = Vector2(2, 2)

			else:

				var _CameraZoom: Vector2 = Vector2(1.05, 1.05)
				if GameLogic.GlobalData.globalini.has("Camera"):
					var _ZoomNum: float = float(GameLogic.GlobalData.globalini.Camera) / 100
					_CameraZoom = Vector2(_ZoomNum + 0.1, _ZoomNum + 0.1)
				CameraNode.zoom = _CameraZoom


	else:
		var _check = is_instance_valid(GameLogic.player_1P)
		if not _check:
			return

		var _CameraZoom: Vector2 = Vector2(0.75, 0.75)
		if GameLogic.GlobalData.globalini.has("Camera"):
			var _ZoomNum: float = float(GameLogic.GlobalData.globalini.Camera) / 100
			_CameraZoom = Vector2(_ZoomNum, _ZoomNum)
		GameLogic.player_1P.CameraNode.zoom = _CameraZoom

		GameLogic.player_1P.CameraNode.current = true
		GameLogic.player_1P.CameraNode.reset_smoothing()
		GameLogic.player_1P.set_process(true)
		set_process(false)

func call_Camera_set():
	var _CameraZoom: Vector2 = Vector2(0.75, 0.75)
	if GameLogic.GlobalData.globalini.has("Camera"):
		var _ZoomNum: float = float(GameLogic.GlobalData.globalini.Camera) / 100
		_CameraZoom = Vector2(_ZoomNum, _ZoomNum)
		if GameLogic.Player2_bool and GameLogic.player_2P:
			CameraNode.zoom = _CameraZoom
		else:
			GameLogic.player_1P.CameraNode.zoom = _CameraZoom

func _Puppet_Create_Item(_ItemType: String, _Name: String, _Pos: Vector2, _ItemData):

	match _ItemType:
		"拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛":
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemType)
			var _Item = _TSCN.instance()
			_Item.name = _Name
			_Item.position = _Pos
			Ysort_Items.add_child(_Item)
			_Item.call_load(_ItemData)
		"Devil":
			var DEVIL_TSCN = load("res://TscnAndGd/Main/NPC/Devil_Update.tscn")
			var _DEVIL = DEVIL_TSCN.instance()
			_DEVIL.name = _Name
			_DEVIL.position = _Pos
			Ysort_Update.add_child(_DEVIL)

		"Shelf_OnTable":
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemType)
			var _Item = _TSCN.instance()
			_Item.name = _Name
			_Item.position = _Pos
			Ysort_Items.add_child(_Item)
			_Item.call_load(_ItemData)
		"ShakeCup":
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemType)
			var _Item = _TSCN.instance()
			_Item.name = _Name
			_Item.position = _Pos
			Ysort_Items.add_child(_Item)
		"ChooseMenu":
			var _RewardTSCN = load("res://TscnAndGd/Objects/Home/ChooseMenu.tscn")
			var _Reward = _RewardTSCN.instance()
			_Reward.name = _Name
			_Reward.position = _Pos
			Ysort_Update.add_child(_Reward)
			_Reward.RewardID = _ItemData
		_:
			var _TSCN = GameLogic.TSCNLoad.return_TSCN(_ItemType)
			var _Item = _TSCN.instance()
			_Item.name = _Name
			_Item.position = _Pos
			Ysort_Items.add_child(_Item)
			_Item.call_load(_ItemData)
			_Item.call_deferred("call_new")

onready var TopPos: Vector2
onready var BottomPos: Vector2
func call_Meteorite_init():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var BaseBallBool: bool
	var _CHECK = GameLogic.curLevelList
	if GameLogic.curLevelList.has("难度-陨石"):
		BaseBallBool = true

	if BaseBallBool:
		if not GameLogic.GameUI.is_connected("TimeChange", self, "_TimeChange_Logic"):
			var _check = GameLogic.GameUI.connect("TimeChange", self, "_TimeChange_Logic")
	TopPos = get_node("CameraPos2D/LeftTop").position
	BottomPos = get_node("CameraPos2D/RightBottom").position

func _TimeChange_Logic():
	var _NUM: int = 1
	for _i in _NUM:
		if GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
			var BaseBallTSCN = load("res://TscnAndGd/Objects/Gears/Meteorite.tscn")
			var _BaseBall = BaseBallTSCN.instance()
			var _STARTTYPE = GameLogic.return_RANDOM() % 4
			var _StartPos: Vector2
			var _EndPos: Vector2
			var _Vector: Vector2

			match _STARTTYPE:
				0:
					_StartPos.x = TopPos.x - GameLogic.return_RANDOM() % 200
					var _Y: int = int(BottomPos.y) - int(TopPos.y)
					_StartPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_EndPos.x = BottomPos.x
					_EndPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_Vector = (_EndPos - _StartPos).normalized()
				1:
					_StartPos.x = BottomPos.x + GameLogic.return_RANDOM() % 200
					var _Y: int = int(BottomPos.y) - int(TopPos.y)
					_StartPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_EndPos.x = TopPos.x - 50
					_EndPos.y = TopPos.y + GameLogic.return_RANDOM() % _Y
					_Vector = (_EndPos - _StartPos).normalized()
				2:
					_StartPos.y = TopPos.y - GameLogic.return_RANDOM() % 200
					var _X: int = int(BottomPos.x) - int(TopPos.x)
					_StartPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_EndPos.y = BottomPos.y + 50
					_EndPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_Vector = (_EndPos - _StartPos).normalized()
				3:
					_StartPos.y = BottomPos.y + GameLogic.return_RANDOM() % 200
					var _X: int = int(BottomPos.x) - int(TopPos.x)
					_StartPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_EndPos.y = TopPos.y - 50
					_EndPos.x = TopPos.x + GameLogic.return_RANDOM() % _X
					_Vector = (_EndPos - _StartPos).normalized()

			var _SPEED = GameLogic.return_RANDOM() % 400 + 200
			var _RANDNUM: int = int(float(_SPEED) / 3)
			var _RANDCHECK: int = GameLogic.return_RANDOM() % _RANDNUM

			var _NAME: String = str(_BaseBall.get_instance_id())
			var _Rotation = int(float(_SPEED) / 20)

			_BaseBall.name = _NAME
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_baseball_puppet", [_NAME, _StartPos, _Vector, _SPEED, _Rotation])
			_BaseBall.position = _StartPos
			_BaseBall.input_vector = _Vector

			_BaseBall.SPEED = _SPEED
			_BaseBall.Rotation = _Rotation
			Ysort_Update.add_child(_BaseBall)

func call_baseball_puppet(_NAME, _Pos, _Vec, _SPEED, _Rotation):
	var BaseBallTSCN = load("res://TscnAndGd/Objects/Gears/Meteorite.tscn")
	var _BaseBall = BaseBallTSCN.instance()
	_BaseBall.name = _NAME
	_BaseBall.position = _Pos
	_BaseBall.input_vector = _Vec
	_BaseBall.SPEED = _SPEED
	_BaseBall.Rotation = _Rotation
	Ysort_Update.add_child(_BaseBall)
