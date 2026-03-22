extends Node2D

export var ID: int
export var TYPE: int

onready var ANI = $LightAni
var RunBool: bool

func _ready():

	var _LEVELINFO = GameLogic.cur_levelInfo
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.curLevelList.has("难度-跑圈"):
		RunBool = true
	elif _LEVELINFO.has("GamePlay"):
		if _LEVELINFO.GamePlay.has("难度-跑圈"):
			RunBool = true
	if RunBool:
		if not GameLogic.is_connected("DayStart", self, "call_init"):
			var _con = GameLogic.connect("DayStart", self, "call_init")

func call_init():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_init")
	if not GameLogic.is_connected("Run", self, "_Run_Logic"):
		var _CON = GameLogic.connect("Run", self, "_Run_Logic")
	if not RunBool:
		self.hide()
	ANI.play("init")
	$TypeAni.play(str(TYPE))
func _Run_Logic(_CALLID, _TYPE):

	match _CALLID:
		- 2:
			if ID == 0:
				ANI.play("show")
		- 1:
			ANI.play("init")
		_:
			if _CALLID == ID:
				ANI.play("1")

func _on_RunPoint_body_entered(_body):
	if _body.has_node("Player/SpecialNode/PlayerSpecialEffect"):
		if not _body.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			return
		var _RUNNODE = _body.get_node("Player/SpecialNode/PlayerSpecialEffect")
		if _RUNNODE.IsRunning:
			if _RUNNODE.RunCheckNum == ID:
				if SteamLogic.IsMultiplay:
					SteamLogic.call_puppet_node_sync(_RUNNODE, "call_CheckPoint", [TYPE])
				_RUNNODE.call_CheckPoint(TYPE)
				ANI.play("2")
				var _AUDIO = GameLogic.Audio.return_Effect("检查点")
				_AUDIO.play(0)
			elif _RUNNODE.RunCheckNum == - 1 and ID == 0:
				printerr("抢跑")
