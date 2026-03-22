extends Node

func _ready() -> void :

	pass
func _init() -> void :

	pass


func screenset():

	if OS.get_name() == "OSX":

		delay_screenset()
	else:
		screentypeset()
		screensizeset()

func delay_screenset():
	var tween: = Tween.new()
	add_child(tween)
	tween.interpolate_callback(self, 1, "screentypeset")
	var screentype = GameLogic.GlobalData.globalini.ScreenType
	match screentype:
		"window", "OPTION-窗口化", "borderless", "OPTION-无边窗":
			tween.interpolate_callback(self, 1.05, "screensizeset")
	tween.interpolate_callback(tween, 2, "queue_free")
	tween.start()

func is_2k_resolution(_size: Vector2) -> bool:
	var _SCREENSIZE = OS.get_screen_size()
	if _SCREENSIZE.x > 1920 and _SCREENSIZE.y > 1080:
		return true
	else:
		return false
func is_4k_resolution(_size: Vector2) -> bool:
	var _SCREENSIZE = OS.get_screen_size()
	if _SCREENSIZE.x > 2560 and _SCREENSIZE.y > 1440:
		return true
	else:
		return false
func screensizeset():
	var screensize = GameLogic.GlobalData.globalini.ScreenSize
	var _2K: bool
	var _4K: bool

	match screensize:
		"  3840 x 2160 (16:9)", "3840 x 2160 (16:9)":
			var _ScreenSiz_vec2: Vector2 = Vector2(3840, 2160)
			if is_2k_resolution(_ScreenSiz_vec2):
				_2K = true

			else:
				_2K = false

			if is_4k_resolution(_ScreenSiz_vec2):
				_4K = true
			else:
				_4K = false
			if _4K:
				OS.set_window_size(Vector2(3840, 2160))
				GameLogic.GlobalData.ScreenSizeName = "3840x2160"
			elif _2K:
				OS.set_window_size(Vector2(2560, 1440))
				GameLogic.GlobalData.ScreenSizeName = "2560x1440"
			else:
				OS.set_window_size(Vector2(1920, 1080))
				GameLogic.GlobalData.ScreenSizeName = "1920x1080"
		"  2560 x 1440 (16:9)", "2560 x 1440 (16:9)":
			var _ScreenSiz_vec2: Vector2 = Vector2(2560, 1440)
			if is_2k_resolution(_ScreenSiz_vec2):
				_2K = true

			else:
				_2K = false

			if _2K:
				OS.set_window_size(Vector2(2560, 1440))
				GameLogic.GlobalData.ScreenSizeName = "2560x1440"
			else:
				OS.set_window_size(Vector2(1920, 1080))
				GameLogic.GlobalData.ScreenSizeName = "1920x1080"

		"  1920 x 1080 (16:9)", "1920 x 1080 (16:9)":
			OS.set_window_size(Vector2(1920, 1080))
			GameLogic.GlobalData.ScreenSizeName = "1920x1080"
		"  1680 x 1050 (16:10)", "1680 x 1050 (16:10)":
			OS.set_window_size(Vector2(1680, 1050))
			GameLogic.GlobalData.ScreenSizeName = "1680x1050"
		"  1600 x 1024 (25:16)", "1600 x 1024 (25:16)":
			OS.set_window_size(Vector2(1600, 1024))
			GameLogic.GlobalData.ScreenSizeName = "1600x1024"
		"  1600 x 900  (16:9)", "1600 x 900  (16:9)":
			OS.set_window_size(Vector2(1600, 900))
			GameLogic.GlobalData.ScreenSizeName = "1600x900"

		"  1440 x 900  (16:10)", "1440 x 900  (16:10)":
			OS.set_window_size(Vector2(1440, 900))
			GameLogic.GlobalData.ScreenSizeName = "1440x900"
		"  1366 x 768  (~16:9)", "1366 x 768  (~16:9)":
			OS.set_window_size(Vector2(1366, 768))
			GameLogic.GlobalData.ScreenSizeName = "1366x768"
		"  1280 x 1024 (5:4)", "1280 x 1024 (5:4)":
			OS.set_window_size(Vector2(1280, 1024))
			GameLogic.GlobalData.ScreenSizeName = "1280x1024"
		"  1280 x 960  (4:3)", "1280 x 960  (4:3)":
			OS.set_window_size(Vector2(1280, 960))
			GameLogic.GlobalData.ScreenSizeName = "1280x960"
		"  1280 x 800  (16:10)", "1280 x 800  (16:10)":
			OS.set_window_size(Vector2(1280, 800))
			GameLogic.GlobalData.ScreenSizeName = "1280x800"
		"  1280 x 768  (5:3)", "1280 x 768  (5:3)":
			OS.set_window_size(Vector2(1280, 768))
			GameLogic.GlobalData.ScreenSizeName = "1280x768"
		"  1280 x 720  (16:9)", "1280 x 720  (16:9)":
			OS.set_window_size(Vector2(1280, 720))
			GameLogic.GlobalData.ScreenSizeName = "1280x720"
		"  1152 x 864  (4:3)", "1152 x 864  (4:3)":
			OS.set_window_size(Vector2(1152, 864))
			GameLogic.GlobalData.ScreenSizeName = "1152x864"
		"  1024 x 768  (4:3)", "1024 x 768  (4:3)":
			OS.set_window_size(Vector2(1024, 768))
			GameLogic.GlobalData.ScreenSizeName = "1024x768"
		"   800 x 600  (4:3)", "800 x 600  (4:3)":
			OS.set_window_size(Vector2(800, 600))
			GameLogic.GlobalData.ScreenSizeName = "800x600"
		"   720 x 576  (5:4)", "720 x 576  (5:4)":
			OS.set_window_size(Vector2(720, 576))
			GameLogic.GlobalData.ScreenSizeName = "720x576"
		"   720 x 480  (3:2)", "720 x 480  (3:2)":
			OS.set_window_size(Vector2(720, 480))
			GameLogic.GlobalData.ScreenSizeName = "720x480"
		"   640 x 480  (4:3)", "640 x 480  (4:3)":
			OS.set_window_size(Vector2(640, 480))
			GameLogic.GlobalData.ScreenSizeName = "640x480"

	var _ScreenNum = OS.get_screen_count()

	OS.center_window()
	if GameLogic.GlobalData.globalini.has("VSYNC"):
		OS.set_use_vsync(GameLogic.GlobalData.globalini.VSYNC)
	else:
		GameLogic.GlobalData.globalini.VSYNC = OS.is_vsync_enabled()

func screentypeset():
	var screentype = GameLogic.GlobalData.globalini.ScreenType

	match screentype:
		"window", "OPTION-窗口化":
			if OS.get_name() != "OSX":
				OS.set_keep_screen_on(false)
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(false)
			else:
				OS.set_window_fullscreen(false)
		"fullscreen", "OPTION-全屏":
			if OS.get_name() != "OSX":
				OS.set_borderless_window(false)
				OS.set_window_fullscreen(true)
				OS.set_keep_screen_on(true)
			else:
				OS.set_window_fullscreen(true)
		"borderless", "OPTION-无边窗":
			if OS.get_name() != "OSX":
				OS.set_keep_screen_on(false)
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(true)
			else:
				OS.set_window_fullscreen(false)
