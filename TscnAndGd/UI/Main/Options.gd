extends Control

onready var OptionAni = get_node("OptionAni")
onready var MainUI = get_parent()
onready var OptionListNode
onready var WindowSizeLable = $GraphicsVBox / Resolution / WindowSize
onready var WindowSize_L_But = $GraphicsVBox / Resolution / L
onready var WindowSize_R_But = $GraphicsVBox / Resolution / R

onready var CurScreenLabel = $GraphicsVBox / CurScreen / CurScreenLabel
onready var CurScreen_L_But = $GraphicsVBox / CurScreen / L
onready var CurScreen_R_But = $GraphicsVBox / CurScreen / R

onready var windowModeLable = $GraphicsVBox / ScreenMode / WindowMode
onready var WindowMode_L_But = $GraphicsVBox / ScreenMode / L
onready var WindowMode_R_But = $GraphicsVBox / ScreenMode / R

onready var AudioBut = $AudioVBox / Audio
onready var AudioSlider = $AudioVBox / Audio / HSlider
onready var Audio_L_But = $AudioVBox / Audio / L
onready var Audio_R_But = $AudioVBox / Audio / R

onready var MusicSlider = $AudioVBox / Music / HSlider
onready var Music_L_But = $AudioVBox / Music / L
onready var Music_R_But = $AudioVBox / Music / R

onready var EffectSlider = $AudioVBox / Effect / HSlider
onready var Effect_L_But = $AudioVBox / Effect / L
onready var Effect_R_But = $AudioVBox / Effect / R

onready var TouchLabel = $GameVBox / Touch / Label
onready var Touch_L_But = $GameVBox / Touch / L
onready var Touch_R_But = $GameVBox / Touch / R
var TouchNum: int
var InteractionNum: int = 1
onready var InteractionLabel = $GameVBox / Interaction / Label
onready var Interaction_L_But = $GameVBox / Interaction / L
onready var Interaction_R_But = $GameVBox / Interaction / R

onready var FootStepSlider = $AudioVBox / FootStep / HSlider
onready var FootStep_L_But = $AudioVBox / FootStep / L
onready var FootStep_R_But = $AudioVBox / FootStep / R

onready var CameraSlider = $GraphicsVBox / Camera / HSlider
onready var Camera_L_But = $GraphicsVBox / Camera / L
onready var Camera_R_But = $GraphicsVBox / Camera / R

onready var StressLabel = $GameVBox / StressShow / CurLabel
onready var Stress_L_But = $GameVBox / StressShow / L
onready var Stress_R_But = $GameVBox / StressShow / R

onready var MultNameLabel = $GameVBox / MultNameShow / MultNameLabel
onready var MultName_L_But = $GameVBox / MultNameShow / L
onready var MultName_R_But = $GameVBox / MultNameShow / R

onready var VSYNCLabel = $GraphicsVBox / VSYNC / VSYNCLabel
onready var VSYNC_L_But = $GraphicsVBox / VSYNC / L
onready var VSYNC_R_But = $GraphicsVBox / VSYNC / R

onready var LanguageLable = $GameVBox / Language / LanguageLable
onready var Language_L_But = $GameVBox / Language / L
onready var Language_R_But = $GameVBox / Language / R
onready var BackBut = get_node("ButControl/BackBut")

onready var NightSwitchLabel = $GraphicsVBox / NightSwitch / SwitchLabel
onready var NightSwitch_L_But = $GraphicsVBox / NightSwitch / L
onready var NightSwitch_R_But = $GraphicsVBox / NightSwitch / R

onready var ButShowSwitch_L_But = $GraphicsVBox / ButShow / L
onready var ButShowSwitch_R_But = $GraphicsVBox / ButShow / R

onready var TypeAni = $TypeAni

var SCREENMODE = [
	"OPTION-全屏",
	"OPTION-窗口化",
	"OPTION-无边窗"
]
var Cur_SCREEN: String
var NightSwitch: bool
var SCREENSIZE = [
	"3840 x 2160 (16:9)",
	"2560 x 1440 (16:9)",
	"1920 x 1080 (16:9)",
	"1680 x 1050 (16:10)",
	"1600 x 1024 (25:16)",
	"1600 x 900  (16:9)",
	"1440 x 900  (16:10)",
	"1366 x 768  (~16:9)",
	"1280 x 1024 (5:4)",
	"1280 x 960  (4:3)",
	"1280 x 800  (16:10)",
	"1280 x 768  (5:3)",
	"1280 x 720  (16:9)",
	"1152 x 864  (4:3)",
	"1024 x 768  (4:3)",
	"800 x 600  (4:3)",
	"720 x 576  (5:4)",
	"720 x 480  (3:2)",
	"640 x 480  (4:3)",
]
var _FPS: int = 60

var cur_pressed: bool
func _ready() -> void :
	call_deferred("_Option_Init")
	if not GameLogic.is_connected("NewNetInfo", self, "_Join_Check"):
		var _RETURN = GameLogic.connect("NewNetInfo", self, "_Join_Check")

	pass
func _Join_Check(_Type, _Info, _SteamID):

	if _Type == 3 and _Info == "网络-正在进入房间":

		if OptionAni.assigned_animation == "show":
			BackBut.emit_signal("pressed")
			_on_Back_pressed()

			call_Show(false)
			GameLogic.GameUI.PanelAni.play("hide")

func call_Show(_Switch: bool):

	match _Switch:
		true:
			$HBoxContainer / Game.pressed = true
			call_Type("Game")
			OptionAni.play("show")

		false:
			OptionAni.play("hide")
func call_Type(_TYPE):
	var _TYPEANI = $TypeAni
	if _TYPEANI.has_animation(_TYPE):
		_TYPEANI.play(_TYPE)
	else:
		printerr(" 错误 无动画：", _TYPE)
func call_Game_Grab():
	$GameVBox / Language.grab_focus()
func call_Graphics_Grab():
	$GraphicsVBox / Camera.grab_focus()
func call_Audio_Grab():
	$AudioVBox / Audio.grab_focus()

func call_Type_Change(_LR: String):
	var _GAMEBUT = $HBoxContainer / Game
	var _GRAPHICSBUT = $HBoxContainer / Graphics
	var _AUDIOBUT = $HBoxContainer / Audio
	var _BUT = _GAMEBUT.group.get_pressed_button()
	if is_instance_valid(_BUT):
		match _BUT.name:
			"Game":
				match _LR:
					"R":
						_GRAPHICSBUT.pressed = true
						_on_Graphics_pressed()
			"Graphics":
				match _LR:
					"L":
						_GAMEBUT.pressed = true
						_on_Game_pressed()
					"R":
						_AUDIOBUT.pressed = true
						_on_Audio_pressed()
			"Audio":
				match _LR:
					"L":
						_GRAPHICSBUT.pressed = true
						_on_Graphics_pressed()

func _control_logic(_but, _value, _type):

	if _value != 1 and _value != - 1 and cur_pressed:
		cur_pressed = false
	match _but:
		"L1":
			if _value in [1, - 1]:
				call_Type_Change("L")
		"R1":
			if _value in [1, - 1]:
				call_Type_Change("R")
		"Y":
			if _value == 1 or _value == - 1:
				get_node("ButControl/DefaultBut").call_pressed()
				_on_Defaults_pressed()
		"X":
			if _value == 1 or _value == - 1:
				get_node("ButControl/ApplyBut").call_pressed()
				_on_Apply_pressed()
		"B", "START":
			if _value == 1 or _value == - 1:
				BackBut.call_pressed()
				BackBut.emit_signal("pressed")
		"L", "l":
			if _value == 1 or _value == - 1:

				if not cur_pressed:
					cur_pressed = true
					var _BUT = get_focus_owner()
					if is_instance_valid(_BUT):
						match _BUT.name:
							"Audio":
								_on_Audio_L_pressed()
							"Music":
								_on_Music_L_pressed()
							"Effect":
								_on_Effect_L_pressed()
							"FootStep":
								_on_FootStep_L_pressed()
							"Camera":
								_on_Camera_L_pressed()
							"CurScreen":
								_on_CurScreen_L_pressed()
							"Resolution":
								_on_Resolution_L_pressed()
							"ScreenMode":
								_on_ScreenMode_L_pressed()
							"Language":
								_on_Language_L_pressed()
							"NightSwitch":
								_on_NightSwitch_L_pressed()
							"FPS":
								_on_FPS_L_pressed()
							"ButShow":
								_on_ButShow_L_pressed()
							"StressShow":
								_on_Stress_L_pressed()
							"MultNameShow":
								_on_MultName_L_pressed()
							"VSYNC":
								_on_VSYNC_L_pressed()
							"Vibration":
								_on_Vibration_L_pressed()
							"Touch":
								_on_Touch_L_pressed()
							"Interaction":
								_on_Interaction_L_pressed()

		"R", "r":
			if _value == 1 or _value == - 1:
				if not cur_pressed:
					cur_pressed = true
					var _BUT = get_focus_owner()
					if is_instance_valid(_BUT):
						match _BUT.name:
							"Audio":
								_on_Audio_R_pressed()
							"Music":
								_on_Music_R_pressed()
							"Effect":
								_on_Effect_R_pressed()
							"FootStep":
								_on_FootStep_R_pressed()
							"Camera":
								_on_Camera_R_pressed()
							"CurScreen":
								_on_CurScreen_R_pressed()
							"Resolution":
								_on_Resolution_R_pressed()
							"ScreenMode":
								_on_ScreenMode_R_pressed()
							"Language":
								_on_Language_R_pressed()
							"NightSwitch":
								_on_NightSwitch_R_pressed()
							"FPS":
								_on_FPS_R_pressed()
							"ButShow":
								_on_ButShow_R_pressed()
							"StressShow":
								_on_Stress_R_pressed()
							"MultNameShow":
								_on_MultName_R_pressed()
							"VSYNC":
								_on_VSYNC_R_pressed()
							"Vibration":
								_on_Vibration_R_pressed()
							"Touch":
								_on_Touch_R_pressed()
							"Interaction":
								_on_Interaction_R_pressed()

	if _type == 0:
		cur_pressed = false

var VSYNC: bool = true
var StressShowType: int
var NameShowType: int
func _Option_Init():

	if not GameLogic.GlobalData.globalini.has("ButShow"):
		GameLogic.GlobalData.globalini["ButShow"] = 0
	_BUTSHOWINT = GameLogic.GlobalData.globalini.ButShow
	_ButShow_Set()
	if GameLogic.GlobalData.globalini.has("FPS"):
		_FPS = GameLogic.GlobalData.globalini.FPS
	_FPSLabel()
	if GameLogic.GlobalData.globalini.has("Touch"):
		TouchNum = GameLogic.GlobalData.globalini.Touch
	if GameLogic.GlobalData.globalini.has("Interaction"):
		InteractionNum = GameLogic.GlobalData.globalini.Interaction
	_InteractionLabel()
	_TouchLabel()
	if not GameLogic.GlobalData.globalini.has("StressShowType"):
		StressShowType = 0
	else:
		StressShowType = GameLogic.GlobalData.globalini.StressShowType
	_StressLabel()
	if not GameLogic.GlobalData.globalini.has("NameShowType"):
		NameShowType = 0
	else:
		NameShowType = GameLogic.GlobalData.globalini.NameShowType
	_NameLabel()
	_VibrationLabel()
	Cur_SCREEN = GameLogic.GlobalData.globalini.ScreenType
	WindowSizeLable.text = GameLogic.GlobalData.globalini.ScreenSize
	windowModeLable.text = GameLogic.CardTrans.get_message(Cur_SCREEN)
	AudioSlider.value = int(GameLogic.GlobalData.globalini.Audio)
	MusicSlider.value = int(GameLogic.GlobalData.globalini.Music)
	EffectSlider.value = int(GameLogic.GlobalData.globalini.Effect)
	if not GameLogic.GlobalData.globalini.has("FootStep"):
		GameLogic.GlobalData.globalini.FootStep = 70
	FootStepSlider.value = int(GameLogic.GlobalData.globalini.FootStep)
	if not GameLogic.GlobalData.globalini.has("VSYNC"):
		if OS.is_vsync_enabled():
			VSYNC = true
		else:
			VSYNC = false
	else:
		VSYNC = GameLogic.GlobalData.globalini.VSYNC
	if GameLogic.GlobalData.globalini.has("Camera"):
		CameraSlider.value = int(GameLogic.GlobalData.globalini.Camera)
	else:
		CameraSlider.value = 75
		GameLogic.GlobalData.globalini["Camera"] = 75
	LanguageLable.text = GameLogic.CardTrans.get_message(GameLogic.GlobalData.globalini.Language)

	if GameLogic.GlobalData.globalini.has("NightSwitch"):
		match bool(GameLogic.GlobalData.globalini.NightSwitch):
			true:
				NightSwitch = true

			false:
				NightSwitch = false

	else:
		GameLogic.GlobalData.globalini.NightSwitch = true
		NightSwitch = true

	call_NightSwitch_Label()


	CurScreenLabel.text = str(OS.get_current_screen())


	var _TURN: String = "设置-开"
	if not OS.is_vsync_enabled():
		VSYNC = false
	else:
		VSYNC = true

	_SYNCLabel()

	if get_tree().get_root().has_node("Level/LightNode"):
		if GameLogic.GlobalData.globalini.NightSwitch:
			get_tree().get_root().get_node("Level/LightNode").show()
		else:
			get_tree().get_root().get_node("Level/LightNode").hide()

	_But_Set()
	if SteamLogic.STEAM_BOOL:
		$GameVBox / Language / SteamLabel.show()
	else:
		$GameVBox / Language / SteamLabel.hide()
	GameLogic.Audio.Audio_Set(0, AudioSlider.value)
	GameLogic.Audio.Audio_Set(1, MusicSlider.value)
	GameLogic.Audio.Audio_Set(2, EffectSlider.value)
	GameLogic.Audio.Audio_Set(3, FootStepSlider.value)

var _BUTSHOWINT: int = 0
func _ButShow_Set():
	match _BUTSHOWINT:
		0:
			$GraphicsVBox / ButShow / Show / XBOX.show()
			$GraphicsVBox / ButShow / Show / PS.hide()
			$GraphicsVBox / ButShow / Show / NS.hide()
		1:
			$GraphicsVBox / ButShow / Show / XBOX.hide()
			$GraphicsVBox / ButShow / Show / PS.show()
			$GraphicsVBox / ButShow / Show / NS.hide()
		2:
			$GraphicsVBox / ButShow / Show / NS.show()
			$GraphicsVBox / ButShow / Show / XBOX.hide()
			$GraphicsVBox / ButShow / Show / PS.hide()
func _But_Set():



	var _ScreenNum = OS.get_screen_count()
	if _ScreenNum == 1:
		CurScreenLabel.text = str(OS.get_current_screen())
		CurScreen_L_But.set_disabled(true)
		CurScreen_R_But.set_disabled(true)
	else:
		if int(CurScreenLabel.text) == 0:
			CurScreen_L_But.set_disabled(true)
			CurScreen_R_But.set_disabled(false)
		elif int(CurScreenLabel.text) == int(_ScreenNum - 1):
			CurScreen_L_But.set_disabled(false)
			CurScreen_R_But.set_disabled(true)
		else:
			CurScreen_L_But.set_disabled(false)
			CurScreen_R_But.set_disabled(false)



	var _LanguageNum = GameLogic.GlobalData.LANGUAGE.find(LanguageLable.text)
	if _LanguageNum == 0:
		Language_L_But.set_disabled(true)
	else:
		Language_L_But.set_disabled(false)
	if _LanguageNum == GameLogic.GlobalData.LANGUAGE.size() - 1:
		Language_R_But.set_disabled(true)
	else:
		Language_R_But.set_disabled(false)
	var _ScreenSizeNum = SCREENSIZE.find(WindowSizeLable.text)
	var _ScreenModeNum = SCREENMODE.find(Cur_SCREEN)
	if _ScreenSizeNum == 0:
		WindowSize_L_But.set_disabled(true)
	else:
		WindowSize_L_But.set_disabled(false)
	if _ScreenSizeNum == SCREENSIZE.size() - 1:
		WindowSize_R_But.set_disabled(true)
	else:
		WindowSize_R_But.set_disabled(false)
	if _ScreenModeNum == 0:
		WindowMode_L_But.set_disabled(true)
	else:
		WindowMode_L_But.set_disabled(false)
	if _ScreenModeNum == SCREENMODE.size() - 1:
		WindowMode_R_But.set_disabled(true)
	else:
		WindowMode_R_But.set_disabled(false)
	if AudioSlider.value <= AudioSlider.min_value:
		Audio_L_But.set_disabled(true)
		yield(get_tree().create_timer(0.1), "timeout")
		Audio_L_But.call_up()
	else:
		Audio_L_But.set_disabled(false)
	if AudioSlider.value >= AudioSlider.max_value:
		Audio_R_But.set_disabled(true)
		yield(get_tree().create_timer(0.1), "timeout")
		Audio_R_But.call_up()
	else:
		Audio_R_But.set_disabled(false)
	if MusicSlider.value <= MusicSlider.min_value:
		Music_L_But.set_disabled(true)
	else:
		Music_L_But.set_disabled(false)
	if MusicSlider.value >= MusicSlider.max_value:
		Music_R_But.set_disabled(true)
	else:
		Music_R_But.set_disabled(false)
	if EffectSlider.value <= EffectSlider.min_value:
		Effect_L_But.set_disabled(true)
	else:
		Effect_L_But.set_disabled(false)
	if EffectSlider.value >= EffectSlider.max_value:
		Effect_R_But.set_disabled(true)
	else:
		Effect_R_But.set_disabled(false)
	if FootStepSlider.value <= FootStepSlider.min_value:
		FootStep_L_But.set_disabled(true)
	else:
		FootStep_L_But.set_disabled(false)
	if FootStepSlider.value >= FootStepSlider.max_value:
		FootStep_R_But.set_disabled(true)
	else:
		FootStep_R_But.set_disabled(false)

	if CameraSlider.value <= CameraSlider.min_value:
		Camera_L_But.set_disabled(true)
	else:
		Camera_L_But.set_disabled(false)
	if CameraSlider.value >= CameraSlider.max_value:
		Camera_R_But.set_disabled(true)
	else:
		Camera_R_But.set_disabled(false)
	match StressShowType:
		0:
			Stress_L_But.set_disabled(true)
			Stress_R_But.set_disabled(false)
		1:
			Stress_L_But.set_disabled(false)
			Stress_R_But.set_disabled(true)
	match NameShowType:
		0:
			MultName_L_But.set_disabled(true)
			MultName_R_But.set_disabled(false)
		1:
			MultName_L_But.set_disabled(false)
			MultName_R_But.set_disabled(true)
	_FPSLabel()
	_SYNCLabel()
	if _FPS <= 0:
		$GraphicsVBox / FPS / L.set_disabled(true)
	else:
		$GraphicsVBox / FPS / L.set_disabled(false)
	if _FPS >= 360:
		$GraphicsVBox / FPS / R.set_disabled(true)
	else:
		$GraphicsVBox / FPS / R.set_disabled(false)



func screensizeset():
	var _screensize = WindowSizeLable.text
	match _screensize:
		"3840 x 2160 (16:9)":
			GameLogic.GlobalData.ScreenSize = Vector2(3840, 2160)
		"2560 x 1440 (16:9)":
			GameLogic.GlobalData.ScreenSize = Vector2(2560, 1440)
		"1920 x 1080 (16:9)":
			GameLogic.GlobalData.ScreenSize = Vector2(1920, 1080)
		"1680 x 1050 (16:10)":
			GameLogic.GlobalData.ScreenSize = Vector2(1680, 1050)
		"1600 x 1024 (25:16)":
			GameLogic.GlobalData.ScreenSize = Vector2(1600, 1024)
		"1600 x 900  (16:9)":
			GameLogic.GlobalData.ScreenSize = Vector2(1600, 900)
		"1440 x 900  (16:10)":
			GameLogic.GlobalData.ScreenSize = Vector2(1440, 900)
		"1366 x 768  (~16:9)":
			GameLogic.GlobalData.ScreenSize = Vector2(1366, 768)
		"1280 x 1024 (5:4)":
			GameLogic.GlobalData.ScreenSize = Vector2(1280, 1024)
		"1280 x 960  (4:3)":
			GameLogic.GlobalData.ScreenSize = Vector2(1280, 960)
		"1280 x 800  (16:10)":
			GameLogic.GlobalData.ScreenSize = Vector2(1280, 800)
		"1280 x 768  (5:3)":
			GameLogic.GlobalData.ScreenSize = Vector2(1280, 768)
		"1280 x 720  (16:9)":
			GameLogic.GlobalData.ScreenSize = Vector2(1280, 720)
		"1152 x 864  (4:3)":
			GameLogic.GlobalData.ScreenSize = Vector2(1152, 864)
		"1024 x 768  (4:3)":
			GameLogic.GlobalData.ScreenSize = Vector2(1024, 768)
		"800 x 600  (4:3)":
			GameLogic.GlobalData.ScreenSize = Vector2(800, 600)
		"720 x 576  (5:4)":
			GameLogic.GlobalData.ScreenSize = Vector2(720, 576)
		"720 x 480  (3:2)":
			GameLogic.GlobalData.ScreenSize = Vector2(720, 480)
		"640 x 480  (4:3)":
			GameLogic.GlobalData.ScreenSize = Vector2(640, 480)

func screentypeset():
	var screentype = GameLogic.GlobalData.cur_WindowMode
	match screentype:
		"OPTION-窗口化":
			if OS.get_name() != "OSX":
				OS.set_keep_screen_on(false)
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(false)
			else:
				OS.set_window_fullscreen(false)
		"OPTION-全屏":
			if OS.get_name() != "OSX":
				OS.set_borderless_window(false)
				OS.set_window_fullscreen(true)
				OS.set_keep_screen_on(true)
			else:
				OS.set_window_fullscreen(true)
		"OPTION-无边窗":
			if OS.get_name() != "OSX":
				OS.set_keep_screen_on(false)
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(true)
			else:
				OS.set_window_fullscreen(false)

func _InteractionLabel():
	match InteractionNum:
		0:
			$GameVBox / Interaction / Label.call_Tr_TEXT("OPTION-地面")
		_:
			$GameVBox / Interaction / Label.call_Tr_TEXT("OPTION-物体")
func _on_Interaction_L_pressed():

	if InteractionNum:
		InteractionNum = 0
	else:
		InteractionNum = 1
	_InteractionLabel()

func _on_Interaction_R_pressed():
	if InteractionNum:
		InteractionNum = 0
	else:
		InteractionNum = 1
	_InteractionLabel()

func _FPSLabel():
	if _FPS <= 0:
		$GraphicsVBox / FPS / FPSLabel.call_Tr_TEXT("信息-无限制")
	elif _FPS >= 360:
		$GraphicsVBox / FPS / FPSLabel.call_Tr_TEXT("信息-显示器刷新率")
		var _SCFPS = OS.get_screen_refresh_rate()
		$GraphicsVBox / FPS / FPSLabel.text = str(_SCFPS) + " " + $GraphicsVBox / FPS / FPSLabel.text
	else:
		$GraphicsVBox / FPS / FPSLabel.call_Tr_TEXT("")
		$GraphicsVBox / FPS / FPSLabel.text = str(_FPS)
func _TouchLabel():
	match TouchNum:
		0:
			$GameVBox / Touch / Label.call_Tr_TEXT("OPTION-地面")
		_:
			$GameVBox / Touch / Label.call_Tr_TEXT("OPTION-物体")
func _on_Touch_L_pressed():

	if TouchNum:
		TouchNum = 0
	else:
		TouchNum = 1
	_TouchLabel()

func _on_Touch_R_pressed():
	if TouchNum:
		TouchNum = 0
	else:
		TouchNum = 1
	_TouchLabel()

func _on_Vibration_L_pressed():
	if GameLogic.GlobalData.globalini.Vibration:
		GameLogic.GlobalData.globalini.Vibration = false
	else:
		GameLogic.GlobalData.globalini.Vibration = true
	_VibrationLabel()
	_But_Set()
func _on_Vibration_R_pressed():
	if GameLogic.GlobalData.globalini.Vibration:
		GameLogic.GlobalData.globalini.Vibration = false
	else:
		GameLogic.GlobalData.globalini.Vibration = true
	_VibrationLabel()
	_But_Set()
func _VibrationLabel():
	match GameLogic.GlobalData.globalini.Vibration:
		true:
			$GameVBox / Vibration / VibrationLabel.call_Tr_TEXT("设置-开")

		false:
			$GameVBox / Vibration / VibrationLabel.call_Tr_TEXT("设置-关")
func _on_MultName_L_pressed():
	if NameShowType == 1:
		NameShowType = 0

	_NameLabel()
	_But_Set()
func _on_MultName_R_pressed():
	if NameShowType == 0:
		NameShowType = 1

	_NameLabel()
	_But_Set()

func _on_VSYNC_L_pressed():
	if VSYNC:
		VSYNC = false
	else:
		VSYNC = true
	_SYNCLabel()
	_But_Set()

func _on_VSYNC_R_pressed():
	if VSYNC:
		VSYNC = false
	else:
		VSYNC = true
	_SYNCLabel()
	_But_Set()

func _on_CurScreen_L_pressed() -> void :
	if int(CurScreenLabel.text) > 0:
		CurScreenLabel.text = str(int(CurScreenLabel.text) - 1)
	_But_Set()
func _on_CurScreen_R_pressed() -> void :
	if int(CurScreenLabel.text) < (OS.get_screen_count() - 1):
		CurScreenLabel.text = str(int(CurScreenLabel.text) + 1)
	_But_Set()

func _on_Resolution_L_pressed() -> void :

	_Resolution_Logic()
	var _WindowSizeText = WindowSizeLable.text
	var _ScreenSizeNum = SCREENSIZE.find(_WindowSizeText)
	if _ScreenSizeNum > 0:
		WindowSizeLable.text = SCREENSIZE[_ScreenSizeNum - 1]
	_But_Set()

func _on_Resolution_R_pressed() -> void :
	_Resolution_Logic()
	var _WindowSizeText = WindowSizeLable.text
	var _ScreenSizeNum = SCREENSIZE.find(_WindowSizeText)
	if _ScreenSizeNum < SCREENSIZE.size() - 1:
		WindowSizeLable.text = SCREENSIZE[_ScreenSizeNum + 1]
	_But_Set()
func _Resolution_Logic():

	var main_screen_size = OS.get_screen_size(0)
	var _2K: bool = true
	var _4K: bool
	if is_2k_resolution(main_screen_size):
		_2K = true
		print("主屏幕支持2K分辨率")
	else:
		_2K = false
		print("主屏幕不支持2K分辨率1")

	if is_4k_resolution(main_screen_size):
		_4K = true
		print("主屏幕支持4K分辨率")
	else:
		_4K = false
		print("主屏幕不支持4K分辨率")
	if _2K:
		if not SCREENSIZE.has("2560 x 1440 (16:9)"):
			SCREENSIZE.insert(0, "2560 x 1440 (16:9)")
	else:
		if SCREENSIZE.has("2560 x 1440 (16:9)"):
			SCREENSIZE.erase("2560 x 1440 (16:9)")
	if _4K:
		if not SCREENSIZE.has("3840 x 2160 (16:9)"):
			SCREENSIZE.insert(0, "3840 x 2160 (16:9)")
	else:
		if SCREENSIZE.has("3840 x 2160 (16:9)"):
			SCREENSIZE.erase("3840 x 2160 (16:9)")

func is_2k_resolution(_size: Vector2) -> bool:
	if _size.x > 1920 and _size.y > 1080:
		return true
	else:
		return false
func is_4k_resolution(_size: Vector2) -> bool:
	if _size.x > 2560 and _size.y > 1440:
		return true
	else:
		return false

func _on_ScreenMode_R_pressed() -> void :
	var _WindowModeText = Cur_SCREEN
	if not SCREENMODE.has(_WindowModeText):
		Cur_SCREEN = SCREENMODE[0]
	var _WindowModeNum = SCREENMODE.find(_WindowModeText)

	if _WindowModeNum < SCREENMODE.size() - 1:
		Cur_SCREEN = SCREENMODE[_WindowModeNum + 1]
		windowModeLable.text = GameLogic.CardTrans.get_message(Cur_SCREEN)

	_But_Set()

func _on_ScreenMode_L_pressed() -> void :
	var _WindowModeText = Cur_SCREEN
	if not SCREENMODE.has(_WindowModeText):
		Cur_SCREEN = SCREENMODE[0]
	var _WindowModeNum = SCREENMODE.find(_WindowModeText)
	if _WindowModeNum > 0:
		Cur_SCREEN = SCREENMODE[_WindowModeNum - 1]
		windowModeLable.text = GameLogic.CardTrans.get_message(Cur_SCREEN)

	_But_Set()

func _on_HSlider_value_changed(_value: float) -> void :
	_But_Set()
func _on_Audio_L_pressed() -> void :
	if AudioSlider.value > AudioSlider.min_value:
		AudioSlider.value -= AudioSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(0, AudioSlider.value)
	$MasterAudio.play(0)
func _on_Audio_R_pressed() -> void :
	if AudioSlider.value < AudioSlider.max_value:
		AudioSlider.value += AudioSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(0, AudioSlider.value)
	$MasterAudio.play(0)
func _on_Music_L_pressed() -> void :
	if MusicSlider.value > MusicSlider.min_value:
		MusicSlider.value -= MusicSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(1, MusicSlider.value)
	$MusicAudio.play(0)
func _on_Music_R_pressed() -> void :
	if MusicSlider.value < MusicSlider.max_value:
		MusicSlider.value += MusicSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(1, MusicSlider.value)
	$MusicAudio.play(0)
func _on_Effect_L_pressed() -> void :
	if EffectSlider.value > EffectSlider.min_value:
		EffectSlider.value -= EffectSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(2, EffectSlider.value)
	$EffectAudio.play(0)
func _on_Effect_R_pressed() -> void :
	if EffectSlider.value < EffectSlider.max_value:
		EffectSlider.value += EffectSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(2, EffectSlider.value)
	$EffectAudio.play(0)
func _on_FootStep_L_pressed() -> void :
	if FootStepSlider.value > FootStepSlider.min_value:
		FootStepSlider.value -= FootStepSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(3, FootStepSlider.value)
	$FootStepAudio.play(0)
func _on_FootStep_R_pressed() -> void :
	if FootStepSlider.value < FootStepSlider.max_value:
		FootStepSlider.value += FootStepSlider.step
	_But_Set()
	GameLogic.Audio.Audio_Set(3, FootStepSlider.value)
	$FootStepAudio.play(0)
func _on_Camera_L_pressed() -> void :
	if CameraSlider.value > CameraSlider.min_value:
		CameraSlider.value -= CameraSlider.step

	_But_Set()
func _on_Camera_R_pressed() -> void :
	if CameraSlider.value < CameraSlider.max_value:
		CameraSlider.value += CameraSlider.step
	_But_Set()
func _SYNCLabel():
	match VSYNC:
		true:
			VSYNCLabel.call_Tr_TEXT("设置-开")

		false:
			VSYNCLabel.call_Tr_TEXT("设置-关")

func _NameLabel():
	match NameShowType:
		0:
			MultNameLabel.text = GameLogic.CardTrans.get_message("设置-名字默认显示")
		1:
			MultNameLabel.text = GameLogic.CardTrans.get_message("设置-持续显示")
func _StressLabel():
	match StressShowType:
		0:
			StressLabel.text = GameLogic.CardTrans.get_message("设置-压力默认显示")
		1:
			StressLabel.text = GameLogic.CardTrans.get_message("设置-持续显示")
func _on_Stress_L_pressed() -> void :
	if StressShowType == 1:
		StressShowType = 0
	_StressLabel()

	_But_Set()
func _on_Stress_R_pressed() -> void :
	if StressShowType == 0:
		StressShowType = 1
	_StressLabel()
	_But_Set()
func _on_Language_L_pressed() -> void :
	var _LanguageText = GameLogic.GlobalData.cur_Language
	var _LanguageNum = GameLogic.GlobalData.LANGUAGE.find(_LanguageText)
	if _LanguageNum > 0:
		GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.LANGUAGE[_LanguageNum - 1]
		LanguageLable.text = GameLogic.CardTrans.get_message(GameLogic.GlobalData.cur_Language)
	else:
		GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.LANGUAGE[GameLogic.GlobalData.LANGUAGE.size() - 1]
		LanguageLable.text = GameLogic.CardTrans.get_message(GameLogic.GlobalData.cur_Language)

	_But_Set()
func _on_Language_R_pressed() -> void :
	var _LanguageText = GameLogic.GlobalData.cur_Language
	var _LanguageNum = GameLogic.GlobalData.LANGUAGE.find(_LanguageText)
	if _LanguageNum < GameLogic.GlobalData.LANGUAGE.size() - 1:
		GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.LANGUAGE[_LanguageNum + 1]
		LanguageLable.text = GameLogic.CardTrans.get_message(GameLogic.GlobalData.cur_Language)
	else:
		GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.LANGUAGE[0]
		LanguageLable.text = GameLogic.CardTrans.get_message(GameLogic.GlobalData.cur_Language)

	_But_Set()

func call_NightSwitch_Label():
	match NightSwitch:
		true:
			NightSwitchLabel.call_Tr_TEXT("设置-灯光开")
		false:
			NightSwitchLabel.call_Tr_TEXT("设置-灯光关")
func _on_FPS_L_pressed():

	if _FPS <= 0:
		pass
	if _FPS <= 30:
		_FPS = 0
	elif _FPS <= 60:
		_FPS = 30
	elif _FPS <= 120:
		_FPS = 60
	elif _FPS <= 144:
		_FPS = 120
	elif _FPS <= 165:
		_FPS = 144
	elif _FPS <= 240:
		_FPS = 165
	elif _FPS <= 360:
		_FPS = 240

	_But_Set()
func _on_FPS_R_pressed():
	if _FPS <= 0:
		_FPS = 30
	elif _FPS <= 30:
		_FPS = 60
	elif _FPS <= 60:
		_FPS = 120
	elif _FPS <= 120:
		_FPS = 144
	elif _FPS <= 144:
		_FPS = 165
	elif _FPS <= 165:
		_FPS = 240
	elif _FPS <= 240:
		_FPS = 360
	elif _FPS <= 360:

		pass

	_But_Set()
func _on_ButShow_L_pressed():
	if _BUTSHOWINT <= 0:
		_BUTSHOWINT = 2
	else:
		_BUTSHOWINT -= 1
	_ButShow_Set()
func _on_ButShow_R_pressed():
	if _BUTSHOWINT >= 2:
		_BUTSHOWINT = 0
	else:
		_BUTSHOWINT += 1
	_ButShow_Set()
func _on_NightSwitch_L_pressed():
	if NightSwitch:
		NightSwitch = false

	else:
		NightSwitch = true

	call_NightSwitch_Label()

func _on_NightSwitch_R_pressed():
	if NightSwitch:
		NightSwitch = false

	else:
		NightSwitch = true

	call_NightSwitch_Label()

func _on_Defaults_pressed() -> void :
	AudioSlider.value = AudioSlider.max_value
	MusicSlider.value = 80
	EffectSlider.value = EffectSlider.max_value
	FootStepSlider.value = 80
	WindowSizeLable.text = "1920 x 1080 (16:9)"
	Cur_SCREEN = "OPTION-全屏"
	GameLogic.GlobalData.cur_WindowMode = "OPTION-全屏"
	windowModeLable.text = GameLogic.CardTrans.get_message(GameLogic.GlobalData.cur_WindowMode)

	NightSwitch = true
	VSYNC = true
	_FPS = 60

	call_NightSwitch_Label()
	_But_Set()

func _on_Apply_pressed() -> void :

	var _ScreenNum = OS.get_screen_count()
	if OS.get_current_screen() != int(CurScreenLabel.text):
		OS.set_current_screen(int(CurScreenLabel.text))



	elif _FPS > 240 or _FPS == 0:
		var _SCFPS = OS.get_screen_refresh_rate()
		Engine.set_target_fps(_SCFPS)
	else:
		Engine.set_target_fps(_FPS)
	GameLogic.GlobalData.globalini.ButShow = _BUTSHOWINT
	GameLogic.GlobalData.globalini.FPS = _FPS
	GameLogic.GlobalData.globalini.Interaction = InteractionNum
	GameLogic.GlobalData.globalini.Touch = TouchNum
	GameLogic.GlobalData.globalini.Audio = AudioSlider.value

	GameLogic.GlobalData.globalini.Music = MusicSlider.value
	GameLogic.GlobalData.globalini.Effect = EffectSlider.value
	GameLogic.GlobalData.globalini.FootStep = FootStepSlider.value
	GameLogic.GlobalData.globalini.Camera = CameraSlider.value
	GameLogic.GlobalData.globalini.ScreenSize = WindowSizeLable.text
	GameLogic.GlobalData.cur_WindowMode = Cur_SCREEN
	GameLogic.GlobalData.globalini.ScreenType = Cur_SCREEN
	GameLogic.GlobalData.globalini.Language = str(GameLogic.GlobalData.cur_Language)
	GameLogic.GlobalData.globalini.CurScreen = CurScreenLabel.text
	GameLogic.GlobalData.globalini.NightSwitch = NightSwitch
	GameLogic.GlobalData.globalini.VSYNC = VSYNC
	GameLogic.GlobalData.globalini.StressShowType = StressShowType
	GameLogic.GlobalData.globalini.NameShowType = NameShowType
	screensizeset()
	screentypeset()
	OS.set_window_size(GameLogic.GlobalData.ScreenSize)
	OS.center_window()
	GameLogic.GlobalData.globalinisave()
	GameLogic.GlobalData.languageset()

	windowModeLable.text = GameLogic.CardTrans.get_message(Cur_SCREEN)


	GameLogic.GlobalData.call_override_save()

	match VSYNC:
		true:
			OS.set_use_vsync(true)
		false:
			OS.set_use_vsync(false)

	if GameLogic.LoadingUI.IsLevel:
		if is_instance_valid(GameLogic.Staff.LevelNode):
			GameLogic.Staff.LevelNode.call_Camera_set()
	_NameLabel()
	_StressLabel()
	_SYNCLabel()

	GameLogic.Audio.Audio_Set(0, AudioSlider.value)
	GameLogic.Audio.Audio_Set(1, MusicSlider.value)
	GameLogic.Audio.Audio_Set(2, EffectSlider.value)
	GameLogic.Audio.Audio_Set(3, FootStepSlider.value)
	GameLogic.call_OPTIONSYNC()

func _on_Back_pressed() -> void :
	_Option_Init()

	pass
func call_grabfocus():

	if not GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _check1 = GameLogic.Con.connect("P1_Control", self, "_control_logic")
	if not GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _check2 = GameLogic.Con.connect("P2_Control", self, "_control_logic")
	_Option_Init()

func call_releasefocus():
	if GameLogic.Con.is_connected("P1_Control", self, "_control_logic"):
		var _check1 = GameLogic.Con.disconnect("P1_Control", self, "_control_logic")
	if GameLogic.Con.is_connected("P2_Control", self, "_control_logic"):
		var _check2 = GameLogic.Con.disconnect("P2_Control", self, "_control_logic")

func _on_Game_pressed():
	TypeAni.play("Game")
func _on_Graphics_pressed():
	TypeAni.play("Graphics")
func _on_Audio_pressed():
	TypeAni.play("Audio")
