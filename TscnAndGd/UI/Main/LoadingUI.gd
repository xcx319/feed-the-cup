extends CanvasLayer

var Tutorial: bool
var item_count
var now_count
var _Level_Path = "res://TscnAndGd/Main/Level/"

onready var ANI = $Control / Car / Ani

var Is_Loading: bool
var IsMain: bool
var IsLevel: bool
var IsHome: bool
var Main_init: bool
var MainLoader
var HomeLoader

func _ready():
	set_process(false)
	ANI.play("init")
	Is_Loading = false
func call_Audio_reset():
	var _HeartAudio = GameLogic.Audio.return_Effect("心跳")
	_HeartAudio.stop()
func mainUILoad():
	GameLogic.GameUI.call_DayEndLogic()
	if Is_Loading:
		return
	GameLogic.Audio.call_BGM_close()
	ANI.play("play")
	GameLogic.GameUI.call_DevilLogic(false)
	GameLogic.GameUI.Combo.call_init()
	HomeLoader = null
	GameLogic.cur_ExtraNum = 0
	BGM_logic()
	get_tree().set_pause(false)


	Is_Loading = true
	IsLevel = false
	IsHome = false
	IsMain = true
	Main_init = false
	GameLogic.AwaitMasterLoad = false

	GameLogic.cur_Challenge.clear()

	var _path = "res://TscnAndGd/UI/Main/MainUI.tscn"
	var _check = ResourceLoader.exists(_path)
	if not _check:
		print("LoadingUI 错误，MainUILoad 地址不存在。")
		return
	GameLogic.GameUI.call_DayEndLogic()
	if ResourceLoader.has_cached(_path):
		if MainLoader.get_resource():
			var _check_change = get_tree().change_scene_to(MainLoader.get_resource())
			ANI.play("init")
			Is_Loading = false
			BGM_logic()
		return
	MainLoader = ResourceLoader.load_interactive(_path)
	item_count = MainLoader.get_stage_count()
	$Control / ProgressBar.show()
	$Control / ProgressBar.max_value = item_count - 1
	set_process(true)


func TutorialLoad():
	if Is_Loading:
		return
	ANI.play("play")
	GameLogic.GameUI.call_DevilLogic(false)
	HomeLoader = null

	GameLogic.cur_ExtraNum = 0
	GameLogic.Audio.call_BGM_close()
	get_tree().set_pause(false)


	Is_Loading = true
	IsLevel = false
	IsHome = false
	IsMain = true
	Main_init = false
	GameLogic.AwaitMasterLoad = false

	GameLogic.cur_Challenge.clear()

	var _path = "res://TscnAndGd/Main/Level/1_4.tscn"
	var _check = ResourceLoader.exists(_path)
	if not _check:
		print("LoadingUI 错误，MainUILoad 地址不存在。")
		return
	GameLogic.GameUI.call_DayEndLogic()
	if ResourceLoader.has_cached(_path):
		if MainLoader.get_resource():
			var _check_change = get_tree().change_scene_to(MainLoader.get_resource())
			ANI.play("init")
			Is_Loading = false
			BGM_logic()
		return
	MainLoader = ResourceLoader.load_interactive(_path)
	item_count = MainLoader.get_stage_count()
	$Control / ProgressBar.show()
	$Control / ProgressBar.max_value = item_count - 1
	set_process(true)


func call_HomeLoad():

	GameLogic.Audio.call_BGM_close()
	GameLogic.GameUI.call_DayEndLogic()
	GameLogic.Save.levelData["PlayerNum"] = 1
	if Is_Loading:
		return

	GameLogic.call_load_puppet()
	ANI.play("play")
	GameLogic.Astar.call_clear()
	GameLogic.Order.call_init()
	MainLoader = null
	GameLogic.GameUI.call_JoinInfo( - 1)
	GameLogic.GameUI.Combo.call_init()
	GameLogic.ShowLevel_bool = true

	Is_Loading = true
	IsLevel = false
	IsHome = true
	IsMain = false
	GameLogic.InHome_Bool = true
	GameLogic.AllStaff.clear()
	GameLogic.NPC.call_reset()

	var _path = "res://TscnAndGd/Main/Homes/map_home_0.tscn"

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		if SteamLogic.LOBBY_gameData.has("HomeUpdate"):
			var _Num = str(SteamLogic.LOBBY_gameData["HomeUpdate"])
			_path = "res://TscnAndGd/Main/Homes/map_home_" + _Num + ".tscn"
	elif GameLogic.Save.gameData.has("HomeUpdate"):
		var _Num = str(GameLogic.Save.gameData["HomeUpdate"])
		_path = "res://TscnAndGd/Main/Homes/map_home_" + _Num + ".tscn"


	var _check = ResourceLoader.exists(_path)
	if not _check:
		print("LoadingUI 错误，MainUILoad 地址不存在。")
		return

	if HomeLoader:
		if ResourceLoader.has_cached(_path):
			if HomeLoader.get_resource():
				var _check_change = get_tree().change_scene_to(HomeLoader.get_resource())
				ANI.play("init")

				Is_Loading = false
				SteamLogic.call_InHome()
				call_load_free()
			return
	HomeLoader = ResourceLoader.load_interactive(_path)
	item_count = HomeLoader.get_stage_count()
	$Control / ProgressBar.show()
	$Control / ProgressBar.max_value = item_count - 1
	set_process(true)





func call_LevelLoad(_levelID, _TypeID: int = 0):

	SteamLogic.OBJECT_DIC.clear()
	GameLogic.Audio.call_BGM_close()
	if Is_Loading:
		return

	if not SteamLogic.IsMultiplay:
		if not GameLogic.cur_level:
			return

	GameLogic.GameUI.call_JoinInfo( - 1)
	GameLogic.Tutorial.CheckList.clear()
	GameLogic.GameUI.DayEnd = true
	GameLogic.InHome_Bool = false
	GameLogic.ShowLevel_bool = false
	GameLogic.ComputerLevel_bool = false
	GameLogic.call_ESCLOGIC(false)

	ANI.play("play")

	Is_Loading = true
	IsLevel = true
	IsHome = false
	IsMain = false
	GameLogic.AwaitMasterLoad = true

	SteamLogic.call_InLevel()

	var _SceneName = GameLogic.Config.SceneConfig[_levelID].TSCN
	match _TypeID:
		0:
			pass
		_:
			_SceneName = _SceneName + "_" + str(_TypeID - 1)

	GameLogic.Config._Translation_Load()
	var _path = _Level_Path + _SceneName + ".tscn"
	var _check = ResourceLoader.exists(_path)
	if not _check:
		print("LoadingUI 错误，MainUILoad 地址不存在。")
		return
	if ResourceLoader.has_cached(_path):
		if GameLogic.TSCNLoad.loader != null:
			if GameLogic.TSCNLoad.loader.get_resource():
				var _check_change = get_tree().change_scene_to(GameLogic.TSCNLoad.loader.get_resource())
				ANI.play("init")

				Is_Loading = false
				BGM_logic()
				call_load_free()
			pass
		else:
			GameLogic.TSCNLoad.loader = ResourceLoader.load_interactive(_path)
			if GameLogic.TSCNLoad.loader != null:
				item_count = GameLogic.TSCNLoad.loader.get_stage_count()
				$Control / ProgressBar.show()
				$Control / ProgressBar.max_value = item_count - 1
				set_process(true)

	else:
		GameLogic.TSCNLoad.loader = ResourceLoader.load_interactive(_path)
		if GameLogic.TSCNLoad.loader != null:
			item_count = GameLogic.TSCNLoad.loader.get_stage_count()
			$Control / ProgressBar.show()
			$Control / ProgressBar.max_value = item_count - 1
			set_process(true)

func _process(_delta):

	var loader
	if IsLevel:
		loader = GameLogic.TSCNLoad.loader
	if IsHome:
		loader = HomeLoader
	if IsMain:
		loader = MainLoader
		Main_init = true
	now_count = loader.get_stage()
	$Control / ProgressBar.value = now_count % item_count
	var _check = loader.poll()

	if _check == ERR_FILE_EOF:
		if loader.get_resource():
			var tree: SceneTree = get_tree()
			var _Node = tree.get_current_scene()

			var _check_change = tree.change_scene_to(loader.get_resource())


			ANI.play("init")

			Is_Loading = false
			SteamLogic.call_SetRich()

			set_process(false)


			call_load_free()


	elif _check != OK:

		set_process(false)

func BGM_logic():

	if IsMain:
		GameLogic.Audio.call_BGM_play("Main")
	elif IsHome:
		GameLogic.Audio.call_BGM_play("Home")
	elif IsLevel:
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			if SteamLogic.LevelDic.Level != "":

				GameLogic.Audio.call_BGM_play(SteamLogic.LevelDic.Level)
				return

		if GameLogic.cur_level:

			GameLogic.Audio.call_BGM_play(GameLogic.cur_level)
			return

func call_load_free():


	HomeLoader = null
	MainLoader = null
