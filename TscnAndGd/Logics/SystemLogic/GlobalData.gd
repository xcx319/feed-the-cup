extends Node

const SAVE_DIR = "user://"

var save_path = SAVE_DIR + "default/global.dat"
var override_Save_path = SAVE_DIR + "default/override.cfg"
var globalini: Dictionary = {}
var joyini: Dictionary = {}
var keyboardini: Dictionary = {}
var NewGame = false
var SelfID = 0
var loadingUI = "MainUI"
var isJoyControl = false

var bool_TalkEdit = false
var ScreenSizeName
var ScreenSize: Vector2

var LoadingType: int = 0
var cur_Language = "Language-zh"
var cur_WindowMode = "OPTION-全屏"
enum WATERTYPE{
	WATER
	TEALEAF_RED
	TEALEAF_GREEN
	POWDER_INSTANT_COFFEE
	POWDER_INSTANT_MILK
	POWDER_INSTANT_MILKTEA
	POWDER_INSTANT_SOYBEANMILK
	POWDER_COCO
	POWDER_COFFEE
	POWDER_MOCHA
	POWDER_VEGFAT
	MIX_RED_VEGFAT
	MIX_RED_INSTANTILK

}
enum TEATYPE{
	WASTE
	TEALEAF_RED
	TEALEAF_GREEN
	POWDER_VEGFAT
	POWDER_COCO
	POWDER_COFFEE
	POWDER_MOCHA
	POWDER_INSTANT_COFFEE
	POWDER_INSTANT_MILK
	POWDER_INSTANT_MILKTEA
	POWDER_INSTANT_SOYBEANMILK
}

var LANGUAGE = [
	"Language-zh",
	"Language-en",


	"Language-fr",
	"Language-ja",

]

func _ready():

	call_deferred("golbaldataload")

	pass
func call_override_save():

	ProjectSettings.set_setting("display/window/size/test_width", ScreenSize.x)
	ProjectSettings.set_setting("display/window/size/test_height", ScreenSize.y)

	if globalini.ScreenType == "OPTION-全屏":
		ProjectSettings.set_setting("display/window/size/fullscreen", 1)
		ProjectSettings.set_setting("display/window/size/borderless", 0)
	else:
		ProjectSettings.set_setting("display/window/size/fullscreen", 0)
	if globalini.ScreenType == "OPTION-无边窗":
		ProjectSettings.set_setting("display/window/size/borderless", 1)
		ProjectSettings.set_setting("display/window/size/fullscreen", 0)
	else:
		ProjectSettings.set_setting("display/window/size/borderless", 0)
	if globalini.ScreenType == "OPTION-窗口化":
		ProjectSettings.set_setting("display/window/size/fullscreen", 0)
		ProjectSettings.set_setting("display/window/size/borderless", 0)

	var _path = SAVE_DIR + "override.cfg"
	var _Error = ProjectSettings.save_custom(_path)
	if _Error != OK:
		printerr("Options设置保存错误：", _Error)

func globalinisave():
	globalini.joyini = joyini
	globalini.keyboardini = keyboardini

	if SteamLogic.STEAM_ID != 0:
		save_path = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/"
	else:
		save_path = SAVE_DIR + "default/"
	var dir = Directory.new()
	if dir.open(save_path) != OK:

		dir.make_dir(save_path)

	var _path = save_path + "global.dat"
	var file = File.new()
	var error = file.open(_path, File.WRITE)
	if error == OK:
		file.store_var(globalini)

		file.close()


	else:
		printerr("Error:" + str(error))
		file.close()
	pass

func golbaldataload():
	var file = File.new()
	if SteamLogic.STEAM_ID != 0:
		save_path = SAVE_DIR + str(SteamLogic.STEAM_ID) + "/global.dat"

	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		if error == OK:
			globalini = file.get_var()
			file.close()

			cur_WindowMode = globalini.ScreenType

			joyini = globalini.joyini
			keyboardini = globalini.keyboardini
			if not globalini.has("NightSwitch"):
				globalini.NightSwitch = true
			if not globalini.has("Camera"):
				globalini.Camera = 100
			if not globalini.has("Touch"):
				globalini.Touch = 0
			if not globalini.has("Interaction"):
				globalini.Interaction = 0
			if not globalini.has("FPS"):
				var _FPS = OS.get_screen_refresh_rate()
				globalini.FPS = _FPS

			if globalini.FPS > 240:
				var _SCFPS = OS.get_screen_refresh_rate()
				Engine.set_target_fps(_SCFPS)
			else:
				Engine.set_target_fps(globalini.FPS)
			if not globalini.has("ButShow"):
				globalini.ButShow = 0

		else:
			printerr("OpenGlobalFileError:" + error)
	else:
		call_globalini_init()
		globalinisave()
	GameLogic.ScreenSet.screenset()
	if not globalini.has("Vibration"):
		globalini.Vibration = true
func call_read_Steam_Language():


	if SteamLogic.STEAM_BOOL:
		if Steam.loggedOn():
			match Steam.getCurrentGameLanguage():
				"frence", "fr":
					TranslationServer.set_locale("fr")
					GameLogic.GlobalData.call_Translation_Set("fr")
					GameLogic.GlobalData.globalini.Language = "Language-fr"
					GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.globalini.Language
					return
				"japanese", "ja":
					TranslationServer.set_locale("ja")
					GameLogic.GlobalData.call_Translation_Set("ja")
					GameLogic.GlobalData.globalini.Language = "Language-ja"
					GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.globalini.Language
					return
				"schinese", "tchinese":
					TranslationServer.set_locale("zh")
					GameLogic.GlobalData.call_Translation_Set("zh")
					GameLogic.GlobalData.globalini.Language = "Language-zh"
					GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.globalini.Language
					return
				_:
					TranslationServer.set_locale("en")
					GameLogic.GlobalData.call_Translation_Set("en")
					GameLogic.GlobalData.globalini.Language = "Language-en"
					GameLogic.GlobalData.cur_Language = GameLogic.GlobalData.globalini.Language
					return

	GameLogic.GlobalData.languageset()

func languageset():

	cur_Language = globalini.Language

	match cur_Language:
		"Language-en", "en":
			TranslationServer.set_locale("en")
			call_Translation_Set("en")

		"Language-zh", "zh":

			TranslationServer.set_locale("zh")
			call_Translation_Set("zh")

		"Language-de", "de":

			TranslationServer.set_locale("de")
			call_Translation_Set("de")
		"Language-es", "es":

			TranslationServer.set_locale("es")
			call_Translation_Set("es")
		"Language-fr", "fr":

			TranslationServer.set_locale("fr")
			call_Translation_Set("fr")
		"Language-ja", "ja":

			TranslationServer.set_locale("ja")
			call_Translation_Set("ja")
		"Language-pt", "pt":

			TranslationServer.set_locale("pt")
			call_Translation_Set("pt")
		"Language-ru", "ru":

			TranslationServer.set_locale("ru")
			call_Translation_Set("ru")
		"Language-ko", "ko":
			TranslationServer.set_locale("ko")
			call_Translation_Set("ko")

func call_globalini_init():




	var _SystemLanguage = OS.get_locale_language()

	match _SystemLanguage:
		"zh":
			cur_Language = "Language-zh"
		_:
			cur_Language = "Language-zh"
	globalini = {
		"ScreenSize": "1920 x 1080 (16:9)",
		"ScreenType": "OPTION-全屏",
		"Language": cur_Language,
		"Audio": 100,
		"Music": 80,
		"Effect": 100,
		"Camera": 100,
		"FootStep": 80,
		"CurScreen": 0,
		"LoadingType": 0,
		"NightSwitch": true,
		"VSYNC": OS.is_vsync_enabled(),
		"Vibration": true,
		"Touch": 0,
		"Interaction": 0,
		"ButShow": 0,

	}

func call_Translation_Set(_Locales: String):

	GameLogic.CardTrans.set_locale(_Locales)
	var _Language = GameLogic.CardTrans.get_locale()

	_del_Translation()
	if not GameLogic.Config.CardTranslation:
		return
	var _CardKeys = GameLogic.Config.CardTranslation.keys()

	for i in _CardKeys.size():

		GameLogic.CardTrans.add_message(_CardKeys[i], GameLogic.Config.CardTranslation[_CardKeys[i]][_Locales])

	GameLogic.Info.call_init()

	GameLogic.call_OPTIONSYNC()
func _del_Translation():
	var _List = GameLogic.CardTrans.get_message_list()
	for _Message in _List:
		GameLogic.CardTrans.erase_message(_Message)
