extends Node

var BGM_Stream = null

onready var BGMAni = get_node("Music/BGMAni")
onready var BGMLogic = $Music / BGMLogic

var LevelBGM_Prefix: String = "res://Sounds/BGMs/"
var Mp3Label: String = ".mp3"

var MainBGM: String = "小心翼翼的试探"
var HomeBGM: String = "美好的一天遇见你"

onready var But_Apply = $Button / Apply
onready var But_Back = $Button / Back
onready var But_EasyClick = $Button / EasyClick
onready var But_Click = $Button / Click
onready var But_SwitchOn = $Button / SwitchOn
onready var But_SwitchOff = $Button / SwitchOff
onready var But_Hold = $Button / Hold
onready var SpecialList = get_node("Special").get_children()

onready var EffectList = get_node("Effect").get_children()
enum BUTTYPE{
	NONE,
	EASYCLICK,
	CLICK,
	APPLY,
	BACK,
	SWITCHON,
	SWITCHOFF,
}
var AudioTile
func _ready() -> void :
	set_process(false)

func return_Audio(_Name: String):

	var _EFFECTPATH: String = "res://Sounds/Effect/" + _Name + ".wav"
	var _AUDIO = $Effect.get_node("单一音效")
	if ResourceLoader.exists(_EFFECTPATH):
		var _LOAD = load(_EFFECTPATH)
		_AUDIO.set_stream(_LOAD)
	return _AUDIO
func return_Effect(_Name: String):
	for _Effect in EffectList:
		if _Effect.name == _Name:
			return _Effect
	return false
func Audio_Set(_bus_idx, _value):
	if _value == 0:
		AudioServer.set_bus_mute(_bus_idx, true)
	elif AudioServer.is_bus_mute(_bus_idx):
		AudioServer.set_bus_mute(_bus_idx, false)

	AudioServer.set_bus_volume_db(_bus_idx, linear2db(_value / 100))



var _ReadyBGM

var _ReadyBGMNAME: String

func call_BGM_play(_NAME: String):
	BGMLogic.play("play")
	if BGMAni.has_animation(_NAME):
		BGMAni.play(_NAME)
	else:
		printerr("BGM名字错误：", _NAME)



func call_BGM_close():
	BGMAni.play("init")

func call_speedup():
	BGMLogic.play("speedup")

func return_RandEffect(_Name):
	for _EffectNode in SpecialList:
		if _EffectNode.name == _Name:
			var _randi = GameLogic.return_RANDOM() % _EffectNode.get_child_count()
			return _EffectNode.get_child(_randi)

func call_TileSet(_Tile):
	AudioTile = _Tile
func return_FootSteps(_Pos: Vector2):
	if is_instance_valid(AudioTile):
		_Pos.x = int(_Pos.x / 100)
		_Pos.y = int(_Pos.y / 100)
		var _CheckType = AudioTile.get_cellv(_Pos)

		match _CheckType:
			0:
				return return_RandEffect("地板")
			1:
				return return_RandEffect("室外")
			2:
				return return_RandEffect("草地")
			3:
				return return_RandEffect("地毯")
			4:
				return return_RandEffect("柔和")
			5:
				return return_RandEffect("水坑")
