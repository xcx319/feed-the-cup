extends Node

var DeviceConfig
var ItemConfig
var LiquidConfig
var FormulaConfig
var NPCConfig
var PlayerConfig
var StaffConfig
var SceneConfig
var BrandConfig
var FormulaTypeConfig
var CardConfig
var ChallengeConfig
var HomeConfig
var HomeDevConfig
var NameConfig
var SkillConfig
var CardTranslation
var EventConfig
var ConfigPath = "res://TscnAndGd/Main/Config/"
var AchievementConfig
var StatueConfig
var DevilBonusConfig
var CostumeConfig
func _ready():
	_DeviceConfigLoad()
	_ItemConfigLoad()
	_LiquidConfigLoad()
	_FormulaConfigLoad()
	_NPCConfigLoad()
	_PlayerConfigLoad()
	_SceneConfig()
	_BrandConfig()
	_CardConfig()
	_HomeConfig()
	_FormulaTypeConfig()
	_Translation_Load()
	_SkillConfig()
	_NameConfig()
	_AchievementConfig()
	_CostumeConfig()
func _CostumeConfig():
	var _Path = ConfigPath + "CostumeConfig.json"
	CostumeConfig = return_LoadJson(_Path, "CostumeConfig")

func _AchievementConfig():
	var _Path = ConfigPath + "AchievementConfig.json"
	AchievementConfig = return_LoadJson(_Path, "AchievementConfig")
	var _StatuePath = ConfigPath + "StatueConfig.json"
	StatueConfig = return_LoadJson(_StatuePath, "StatueConfig")
	var _BonusPath = ConfigPath + "DevilBonusConfig.json"
	DevilBonusConfig = return_LoadJson(_BonusPath, "DevilBonusConfig")

	if GameLogic.DEMO_bool:
		var _KEYS = AchievementConfig.keys()
		for _i in _KEYS.size():
			var _ACH = _KEYS[_i]
			if _ACH in ["完美收拾1", "钞票1", "钞票2", "联机1"]:
				AchievementConfig.erase(_ACH)

func _NameConfig():
	var _Path = ConfigPath + "NameConfig.json"
	NameConfig = return_LoadJson(_Path, "NameConfig")
func _SkillConfig():
	var _Path = ConfigPath + "SkillConfig.json"
	SkillConfig = return_LoadJson(_Path, "SkillConfig")
func _HomeConfig():
	var _Path = ConfigPath + "HomeConfig.json"
	HomeConfig = return_LoadJson(_Path, "HomeConfig")

	var _DevPath = ConfigPath + "HomeDevConfig.json"
	HomeDevConfig = return_LoadJson(_DevPath, "HomeDevConfig")
func _Translation_Load():
	var _CardPath = ConfigPath + "CardTranslation.json"
	CardTranslation = return_LoadJson(_CardPath, "CardTranslation")

func return_LoadJson(_Path, _NAME: String = ""):
	call_turn(_NAME, _Path)
	var _File = File.new()
	if _File.file_exists(_Path):
		_File.open(_Path, File.READ)
		var _Json = parse_json(_File.get_as_text())
		return _Json
	else:
		var _CP = ConfigPath + _NAME + ".cfg"
		return return_cfgload(_CP)

func _FormulaTypeConfig():
	var _Path = ConfigPath + "FormulaTypeConfig.json"
	FormulaTypeConfig = return_LoadJson(_Path, "FormulaTypeConfig")
func _CardConfig():
	var _Path = ConfigPath + "CardConfig.json"
	CardConfig = return_LoadJson(_Path, "CardConfig")
	var _ChallengePath = ConfigPath + "ChallengeConfig.json"
	ChallengeConfig = return_LoadJson(_ChallengePath, "ChallengeConfig")
	var _EventPath = ConfigPath + "EventConfig.json"
	EventConfig = return_LoadJson(_EventPath, "EventConfig")

func _BrandConfig():
	var _Path = ConfigPath + "BrandConfig.json"
	BrandConfig = return_LoadJson(_Path, "BrandConfig")

func _SceneConfig():
	var _Path = ConfigPath + "SceneConfig.json"
	SceneConfig = return_LoadJson(_Path, "SceneConfig")
	if GameLogic.DEMO_bool:
		var _KEYS = SceneConfig.keys()
		for _i in _KEYS.size():
			var _LEVEL = _KEYS[_i]
			var _INFO = SceneConfig[_LEVEL]
			if int(_INFO.LevelType) > 1:
				SceneConfig.erase(_LEVEL)
			elif int(_INFO.LevelID) > 3:
				SceneConfig.erase(_LEVEL)
			else:
				if int(_INFO.DevilMax) > 0:
					if not _INFO.TSCN in ["1_1"]:
						_INFO.DevilMax = int(_INFO.DevilMax) - 1

func _PlayerConfigLoad():
	var _Path = ConfigPath + "PlayerConfig.json"
	PlayerConfig = return_LoadJson(_Path, "PlayerConfig")
	var _StaffPath = ConfigPath + "StaffConfig.json"
	StaffConfig = return_LoadJson(_StaffPath, "StaffConfig")

func _DeviceConfigLoad():
	var _Path = ConfigPath + "DeviceConfig.json"
	DeviceConfig = return_LoadJson(_Path, "DeviceConfig")

func _ItemConfigLoad():
	var _Path = ConfigPath + "ItemConfig.json"
	ItemConfig = return_LoadJson(_Path, "ItemConfig")



func _LiquidConfigLoad():
	var _Path = ConfigPath + "LiquidConfig.json"
	LiquidConfig = return_LoadJson(_Path, "LiquidConfig")

func _FormulaConfigLoad():
	var _Path = ConfigPath + "FormulaConfig.json"
	FormulaConfig = return_LoadJson(_Path, "FormulaConfig")

func _NPCConfigLoad():
	var _Path = ConfigPath + "NPCConfig.json"
	NPCConfig = return_LoadJson(_Path, "NPCConfig")

func call_turn(_NAME, _Path):
	var Config = ConfigFile.new()
	var json_file = File.new()
	if json_file.open(_Path, File.READ) == OK:
		var json_str = json_file.get_as_text()
		json_file.close()

		var json_data = JSON.parse(json_str).result
		if json_data is Dictionary:
			for section in json_data:
				for key in json_data[section]:
					Config.set_value(section, key, json_data[section][key])


			var _SavePath = ConfigPath + _NAME + ".cfg"
			var _check = Config.save_encrypted_pass(_SavePath, "Cups")

func return_cfgload(_path):
	var file = File.new()


	var Config = ConfigFile.new()
	if file.file_exists(_path):
		var _check = Config.load_encrypted_pass(_path, "Cups")

		if _check != OK:
			print("存档加载失败，错误：", _check)
			_check = Config.load(_path)
			if _check != OK:
				printerr("未加密存档加载失败，错误：", _check)
	file.close()

	var json_data = {}
	if Config.load_encrypted_pass(_path, "Cups") == OK:
		for section in Config.get_sections():
			json_data[section] = {}
			for key in Config.get_section_keys(section):
				json_data[section][key] = Config.get_value(section, key)

	return json_data
