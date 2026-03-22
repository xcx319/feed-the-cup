extends Control

var joyPressed_bool = false

export (float) var _speed = 1.0

var MainButShowTime = 0.5
var curUI = UI.MAINUI
enum UI{
	MAINUI
	CHARACTERSELECTUI
	OPTIONUI
	KEYSETTING
	CAST
	CHECKINFO
	UPDATEINFO
}

var cur_pressed: bool = false
onready var _init_time = 0

onready var ButAni = $ButtonAni
onready var PlayBut = $MainButList / Play

onready var CharacterSelectUI
onready var SceneUI

func grab_focus():


	if curUI in [UI.CHECKINFO]:
		if GameLogic.DEMO_bool and GameLogic.Save.IsNew:
			$NewInfo / AnimationPlayer.play("DEMO_New")
			return
		if GameLogic.Save._CHECKOLDDATA and GameLogic.Save._ISONLINE:

			$NewInfo / AnimationPlayer.play("DEMO_New")
			GameLogic.Save.call_CleanLogic()
			return
	elif curUI in [UI.UPDATEINFO]:
		$NewInfo / AnimationPlayer.play("UpdateInfo")
		return
	PlayBut.grab_focus()

	pass
func call_init():
	GameLogic.GameUI.get_node("HomeInfo").hide()
	GameLogic.GameUI.call_JoinInfo( - 1)
func call_LOGO():
	match GameLogic.GlobalData.cur_Language:
		"Language-zh":
			$Logo / AnimationPlayer.play("ch")
			$VBoxContainer / QQGROUP.show()
			$VBoxContainer / Discord.hide()
		_:
			$Logo / AnimationPlayer.play("en")
			$VBoxContainer / QQGROUP.hide()
			$VBoxContainer / Discord.show()
func _ready():

	call_LOGO()

	if GameLogic.Save._CHECKOLDDATA and GameLogic.Save._ISONLINE:
		curUI = UI.CHECKINFO
		CanPress = false
	if GameLogic.DEMO_bool:

		$MainButList / WishList.show()
	else:
		$MainButList / WishList.hide()

	if curUI != UI.CHECKINFO and not GameLogic.DEMO_bool:
		if GameLogic.FirstOpen:
			GameLogic.FirstOpen = false
			match GameLogic.GlobalData.cur_Language:
				"Language-zh":
					curUI = UI.UPDATEINFO
					CanPress = false


	GameLogic.GameUI.MainMenu.call_reset()
	set_process(false)
	PlayBut.grab_focus()
	GameLogic.GameUI.call_MainUI()
	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.connect("P2_Control", self, "_control_logic")
	GameLogic.LoadingUI.BGM_logic()
	if GameLogic.DEMO_bool:
		get_node("DEMOLABEL").text = "Feed the Cups DEMO v" + GameLogic.Save.VERSION + GameLogic.Save.LASTVER
		get_node("DEMOLABEL").show()
	else:
		get_node("DEMOLABEL").text = "Feed the Cups v" + GameLogic.Save.VERSION + GameLogic.Save.LASTVER

	if not GameLogic.Save.gameData.has("Bool_InLevel"):

		$MainButList / Tutorial.hide()
		GameLogic.call_NewGame()
	else:
		$MainButList / Tutorial.show()
	GameLogic.GameUI.call_DEMOINFO()

	var _text = GameLogic.CardTrans.get_message("Current Day")
	var _text1 = GameLogic.CardTrans.get_message("Tip Mult")

var CanPress: bool
func call_CheckINFO():
	if CanPress:
		GameLogic.Audio.But_Apply.play(0)
		$NewInfo / AnimationPlayer.play("init")
		curUI = UI.MAINUI
		grab_focus()
func call_CanPress():
	CanPress = true

func _control_logic(_but, _value, _type):

	if _value < 1 and _value > - 1:
		cur_pressed = false

	match curUI:
		UI.UPDATEINFO:
			if _but in ["B", "A", "START"] and _value == 1:
				call_CheckINFO()
			return
		UI.CHECKINFO:
			if _but in ["B", "A", "START"] and _value == 1:
				call_CheckINFO()
			return
		UI.CAST:

			if _but in ["B", "A", "START"] and _value == 1:
				curUI = UI.MAINUI
				call_Cast_Hide()
			return
		UI.KEYSETTING:
			return
	match _but:
		"B":
			if _value == 1:

				pass
		"A":
			var _input = InputEventAction.new()
			_input.action = "ui_accept"
			if _value == 1:
				_input.pressed = true
				Input.parse_input_event(_input)
				cur_pressed = true
			elif _value == 0:
				_input.pressed = false
				Input.parse_input_event(_input)
				cur_pressed = false
		"U":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"D":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"L":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_left"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"R":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_right"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"u":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_up"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"d":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_down"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"l":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_left"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
		"r":
			if (_value == 1 or _value == - 1):
				if not cur_pressed:
					var _input = InputEventAction.new()
					_input.action = "ui_right"
					_input.pressed = true
					cur_pressed = true
					Input.parse_input_event(_input)
	if _type == 0:
		cur_pressed = false
func _MainUI_Init():
	$Options.visible = false

	pass

func _on_Exit_pressed():
	if OS.get_name() != "OSX":
		if SteamLogic.STEAM_BOOL:
			Steam.steamShutdown()
	get_tree().quit()

func _on_Options_pressed():

	GameLogic.Con.call_vibration(1, 0, 0.8, 0.07)
	call_Options_Switch(true)
	call_MainUI_Switch(false)
	curUI = UI.OPTIONUI
func _on_Options_Back():

	GameLogic.Con.call_vibration(1, 0, 0.8, 0.07)
	call_Options_Switch(false)
	call_MainUI_Switch(true)
	curUI = UI.MAINUI
	call_LOGO()
func call_Options_Switch(switch):

	match switch:
		true:

			GameLogic.GameUI.OptionNode.call_Show(true)
			if not GameLogic.GameUI.OptionNode.BackBut.is_connected("pressed", self, "_on_Options_Back"):
				GameLogic.GameUI.OptionNode.BackBut.connect("pressed", self, "_on_Options_Back")
			GameLogic.Audio.But_Apply.play(0)
			GameLogic.GameUI.call_PanelAni(true)

		false:
			GameLogic.GameUI.OptionNode.call_Show(false)

			GameLogic.GameUI.OptionNode.release_focus()
			PlayBut.grab_focus()
			GameLogic.GameUI.call_PanelAni(false)

func call_MainUI_Switch(switch):
	match switch:
		true:
			ButAni.play("ShowUp")
		false:
			ButAni.play("MainHide")

func _on_NewGameButton_pressed():
	Dataselecthide(true)

func Dataselecthide(switch):
	match switch:
		true:
			curUI = UI.DATAUI
			pass
		false:
			$DataSelect.release_focus()

func NewGameUIhide(switch):
	$NewGameUI.visible = switch
	match switch:
		true:
			$NewGameUI / Panel / GameTypeVBox / DifficultyLab / Button.grab_focus()
			curUI = UI.NEWGAMEUI
		false:
			$NewGameUI.release_focus()
			$DataSelect / Panel / VScrollBar / VBoxContainer / NewGameBut.grab_focus()
			curUI = UI.MAINUI

func JoinGameUIhide(switch):
	$JoinGameUI.visible = switch
	match switch:
		true:
			curUI = UI.JOINGAMEUI
		false:
			curUI = UI.MAINUI
			$MainVBoxContainer / NewGameButton.grab_focus()

func queuefreeUI():
	queue_free()

func _on_Tutorial_pressed() -> void :

	$ButtonAni.play("Tutorial")
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.Audio.call_BGM_close()
	$Loop.play("init")

	yield(get_tree().create_timer(0.2), "timeout")
	var _OpenCG_TSCN = load("res://TscnAndGd/UI/Main/OpenCG.tscn")
	var _OpenCG = _OpenCG_TSCN.instance()
	self.add_child(_OpenCG)


	_OpenCG.call_play()



func _on_Play_pressed() -> void :
	GameLogic.GameUI.call_esc(0)

	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		GameLogic.Con.disconnect("P2_Control", self, "_control_logic")
	GameLogic.Audio.call_BGM_close()
	$Loop.play("init")

	if not GameLogic.Save.levelData.has("Level_bool"):
		GameLogic.Save.levelData["Level_bool"] = false

		GameLogic.call_NewGame()
		GameLogic.call_HomeLoad()
	else:
		if GameLogic.Save.levelData.Level_bool:
			GameLogic.call_load()

func _on_Cast_pressed():
	if has_node("Cast"):
		curUI = UI.CAST
		get_node("Cast").get_node("Ani").play("play")

func call_Cast_Hide():
	if has_node("Cast"):
		get_node("Cast").get_node("Ani").play("hide")
		curUI = UI.MAINUI

func _on_KeySettingBut_pressed():
	call_MainUI_Switch(false)
	if not GameLogic.GameUI.KeySettingNode.get_node("ButControl/BackBut").is_connected("pressed", self, "_on_KeySettingBut_Back"):
		GameLogic.GameUI.KeySettingNode.get_node("ButControl/BackBut").connect("pressed", self, "_on_KeySettingBut_Back")
	curUI = UI.KEYSETTING
	GameLogic.Audio.But_Apply.play(0)
	GameLogic.GameUI.KeySettingNode.call_Show(true)
	GameLogic.GameUI.PanelAni.play("show")
func _on_KeySettingBut_Back():
	if GameLogic.GameUI.KeySettingNode.SettingBool:
		return
	call_MainUI_Switch(true)
	GameLogic.Audio.But_Back.play(0)
	curUI = UI.MAINUI
	GameLogic.GameUI.MainMenu.call_reset()
	GameLogic.GameUI.KeySettingNode.call_Show(false)
	GameLogic.GameUI.PanelAni.play("hide")

func _on_WishList_pressed():
	if Steam.loggedOn():
		Steam.activateGameOverlayToStore(2336220)
	else:
		var _RETURN = OS.shell_open("https://store.steampowered.com/app/2336220/")
		print("Steam 未登录")

func _on_SaveFolder_pressed():
	var _DIR = ProjectSettings.globalize_path("user://")
	if OS.get_name() == "OSX":
		OS.execute("open", [_DIR])
	else:
		var _RETURN = OS.shell_open(_DIR)

func _on_QQGROUP_pressed():
	var _DIR = "https://pd.qq.com/s/eeirreyrf"
	var _RETURN = OS.shell_open(_DIR)

func _on_Discord_pressed():
	var _DIR = "https://discord.gg/UrbBakxCDN"
	var _RETURN = OS.shell_open(_DIR)

func _on_SteamGroup_pressed():
	match GameLogic.GlobalData.cur_Language:
		"Language-zh":
			var _DIR = "https://steamcommunity.com/chat/invite/b88JiK41"
			var _RETURN = OS.shell_open(_DIR)
		_:
			var _DIR = "https://steamcommunity.com/chat/invite/UHJDKy33"
			var _RETURN = OS.shell_open(_DIR)
