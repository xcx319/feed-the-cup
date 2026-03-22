extends Node2D

onready var Audio_Wrong

export var CanBlackOut: bool
export var CanNeedFix: bool
export var FixBase: int
var NeedFix: bool
var FixPoint: int
var FixMax: int = 5
func _ready():
	Audio_Wrong = GameLogic.Audio.return_Effect("错误1")
	if not GameLogic.is_connected("BlackOut", self, "_BlackOut"):
		var _con = GameLogic.connect("BlackOut", self, "_BlackOut")

	if not GameLogic.is_connected("Reward", self, "call_dayStart"):
		var _CON = GameLogic.connect("Reward", self, "call_dayStart")
func call_dayStart():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _LEVELINFO = GameLogic.cur_levelInfo

	if GameLogic.curLevelList.has("难度-设备故障") or _LEVELINFO.GamePlay.has("难度-设备故障"):
		if CanNeedFix:
			var _MULT: float = 1

			FixPoint = GameLogic.return_randi() % int(float(FixBase) * _MULT)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_set_sync(self, "FixPoint", FixPoint)
			call_Check()

	elif GameLogic.cur_Challenge.has("设备抽风") or GameLogic.cur_Challenge.has("设备抽风+"):
		if CanNeedFix:
			var _MULT: float = 1

			FixPoint = GameLogic.return_randi() % int(float(FixBase) * _MULT)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_set_sync(self, "FixPoint", FixPoint)
			call_Check()
	else:

		$ToolAni.play("init")
func call_Fixing_puppet(_FixPoint, _FIXTIME):
	FixPoint = _FixPoint

	$ToolAni.play("init")
	$ToolAni.play("Fixing")
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.max_value = _FIXTIME
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.value = FixPoint
	var _AUDIO = GameLogic.Audio.return_Effect("放下杯子")
	_AUDIO.play(0)
	if FixPoint >= _FIXTIME:

		call_Fixed()

func call_Fix_ElecBox(_Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:

		return
	$ToolAni.play("init")
	$ToolAni.play("Fixing")
	var _AUDIO = GameLogic.Audio.return_Effect("放下杯子")
	_AUDIO.play(0)
	FixPoint += 1
	var _FIXTIME: int = 3
	_FIXTIME = int(_FIXTIME * GameLogic.return_Multiplier())
	if _Player.Stat.Skills.has("技能-修理"):
		FixPoint = _FIXTIME
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Fix_Elec_puppet", [FixPoint, _FIXTIME])
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.max_value = _FIXTIME
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.value = FixPoint
	if FixPoint >= _FIXTIME:
		GameLogic.call_BlackOut_Over()
		call_Fixed()

		return true
func call_Fix_Elec_puppet(_FixPoint, _FIXTIME):
	FixPoint = _FixPoint
	$ToolAni.play("init")
	$ToolAni.play("Fixing")
	var _AUDIO = GameLogic.Audio.return_Effect("放下杯子")
	_AUDIO.play(0)
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.max_value = _FIXTIME
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.value = FixPoint
	if FixPoint >= _FIXTIME:
		GameLogic.call_BlackOut_Over()
		call_Fixed()
func return_Fixing(_Player):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _LEVELINFO = GameLogic.cur_levelInfo

	if GameLogic.curLevelList.has("难度-设备故障") or _LEVELINFO.GamePlay.has("难度-设备故障") or GameLogic.cur_Challenge.has("设备抽风") or GameLogic.cur_Challenge.has("设备抽风+"):

		$ToolAni.play("init")
		$ToolAni.play("Fixing")
		var _AUDIO = GameLogic.Audio.return_Effect("放下杯子")
		_AUDIO.play(0)
		FixPoint += 1

		var _FIXTIME: int = 0
		if GameLogic.curLevelList.has("难度-设备故障") or _LEVELINFO.GamePlay.has("难度-设备故障"):
			_FIXTIME += 3
		if GameLogic.cur_Challenge.has("设备抽风"):
			_FIXTIME += 3
		if GameLogic.cur_Challenge.has("设备抽风+"):
			_FIXTIME += 6
		_FIXTIME = int(_FIXTIME * GameLogic.return_Multiplier())
		if _Player.Stat.Skills.has("技能-修理"):
			FixPoint = _FIXTIME
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Fixing_puppet", [FixPoint, _FIXTIME])
		$Tool / Texture / UiPoptipWarning1 / TextureProgress.max_value = _FIXTIME
		$Tool / Texture / UiPoptipWarning1 / TextureProgress.value = FixPoint
		if FixPoint >= _FIXTIME:
			call_Fixed()

			return true
	return false
func call_NeedFix_End():
	NeedFix = false
	FixPoint = 0
	$ToolAni.play("init")
func return_Fix():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.curLevelList.has("难度-设备故障") or GameLogic.cur_levelInfo.GamePlay.has("难度-设备故障") or GameLogic.cur_Challenge.has("设备抽风") or GameLogic.cur_Challenge.has("设备抽风+"):
		if CanNeedFix and not NeedFix:
			FixPoint -= 1

			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_set_sync(self, "FixPoint", FixPoint)

			call_Check()
			if NeedFix:
				return true
		if CanNeedFix and NeedFix:
			return true
	return false
func call_Fixed_puppet(_FixPoint):
	NeedFix = false
	call_Check()
	$ToolAni.play("FixEnd")
	FixPoint = _FixPoint
func call_Fixed():
	NeedFix = false
	FixPoint = GameLogic.return_randi() % FixBase + FixBase
	call_Check()
	$ToolAni.play("FixEnd")

func call_Check():

	if CanNeedFix:
		if FixPoint <= 0:
			call_NeedFix()

func _BlackOut(_Switch):
	if CanBlackOut:
		if _Switch:
			$PowerAni.play("elec")
		else:
			$PowerAni.play("init")

func call_Audio():
	Audio_Wrong.play(0)

func call_Empty():
	call_Audio()
	get_node("WarningAni").play("Empty")

func call_Full():
	call_Audio()
	get_node("WarningAni").play("Full")

func call_NeedFix():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_NeedFix")
	if GameLogic.cur_Challenge.has("设备抽风"):
		GameLogic.call_Info(2, "设备抽风")
	if GameLogic.cur_Challenge.has("设备抽风+"):
		GameLogic.call_Info(2, "设备抽风+")
	NeedFix = true
	FixPoint = 0
	$ToolAni.play("NeedFix")

func call_Fix():
	$ToolAni.play("Fixing")
func return_ElecBox():

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	$ToolAni.play("init")
	$ToolAni.play("Fixing")
	var _AUDIO = GameLogic.Audio.return_Effect("放下杯子")
	_AUDIO.play(0)
	FixPoint += 1

	var _FIXTIME: int = 10
	_FIXTIME = int(_FIXTIME * GameLogic.return_Multiplier())
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Fixing_puppet", [FixPoint, _FIXTIME])
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.max_value = _FIXTIME
	$Tool / Texture / UiPoptipWarning1 / TextureProgress.value = FixPoint
	if FixPoint >= _FIXTIME:
		call_Fixed()

		return true
	return false
