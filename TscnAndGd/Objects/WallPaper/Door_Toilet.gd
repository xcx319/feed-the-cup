extends Area2D

onready var aniPlayer = $AniNode / AnimationPlayer
onready var LockAni = $AniNode / LockAni

onready var Audio_Open
onready var Audio_Close
onready var AUDIO = $Audio
onready var UseTime = $Timer
export var CANOPEN: bool = true
export var CANCLOSE: bool = true

var PLAYERLIST: Array

var Used: bool
var UserList: Array
var UsTime: int = 0
func _ready() -> void :
	Audio_Open = GameLogic.Audio.return_Effect("开门")
	Audio_Close = GameLogic.Audio.return_Effect("关门")

func call_open():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if aniPlayer.assigned_animation != "open":
		call_open_ani()
func call_close():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not PLAYERLIST.size() and UserList.size() <= 1:
		if aniPlayer.assigned_animation == "open":
			call_close_ani()
			_CHECK_LOGIC()
func call_open_ani():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_open_ani")
	aniPlayer.play("open")
	Audio_Open.play(0)
	if Audio_Close.is_playing():
		Audio_Close.stop()
func call_close_ani():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_close_ani")
	aniPlayer.play("close")
	Audio_Close.play(0)
	if Audio_Open.is_playing():
		Audio_Open.stop()
func call_Lock_puppet(_TYPE: int):
	match _TYPE:
		0:
			LockAni.play("init")
		1:
			LockAni.play("Lock")
func call_Lock_Ani():
	var _TYPE: int = 0
	if not UserList.size():
		LockAni.play("init")
	else:
		LockAni.play("Lock")
		_TYPE = 1
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Lock_puppet", [_TYPE])
func _on_player_entered(_body: Node) -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not PLAYERLIST.has(_body):
		PLAYERLIST.append(_body)
	if CANOPEN:
		if PLAYERLIST.size() == 1:
			call_open()
func _on_player_exited(_body: Node) -> void :
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if PLAYERLIST.has(_body):
		PLAYERLIST.erase(_body)
	call_close()

func _on_body_entered(_body):

	if not PLAYERLIST.size():
		if UserList.size():
			if _body == UserList[0]:
				call_open()

func call_Audio():

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Audio")
	AUDIO.play(0)

func _CHECK_LOGIC():
	if not Used and UserList.size() == 1 and aniPlayer.assigned_animation == "close":
		Used = true
		UseTime.start(0)
		CANOPEN = false
		call_Lock_Ani()

	elif not Used and UserList.size() == 1 and aniPlayer.assigned_animation != "close":
		call_close()
		Used = true
		UseTime.start(0)
		CANOPEN = false
		call_Lock_Ani()
	elif Used:
		if not UserList.size():
			Used = false
			UseTime.stop()
			UsTime = 0
			CANOPEN = true
			call_Lock_Ani()
			call_Audio()

		elif UserList.size() > 1:
			Used = false
			UseTime.stop()
			UsTime = 0
			CANOPEN = true
			call_open()

func _on_Toilet_body_entered(_body):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _body.has_method("_PlayerNode"):
		if not UserList.has(_body):
			UserList.append(_body)
		call_Door_Logic()
	print("厕所逻辑 in：", UserList, Used)
func _on_Toilet_body_exited(_body):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _body.has_method("_PlayerNode"):
		if UserList.has(_body):
			UserList.erase(_body)
		_CHECK_LOGIC()
		call_Door_Logic()
	print("厕所逻辑out：", UserList, Used)
func call_Door_Logic():
	if UserList.size() <= 1:
		CANCLOSE = true
	else:
		CANCLOSE = false
	_CHECK_LOGIC()

func _on_Timer_timeout():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not aniPlayer.assigned_animation in ["close", "init"]:
		return
	UsTime += 1
	if UserList.size() == 1:
		var _USER = UserList[0]
		if is_instance_valid(_USER):
			if _USER.has_method("call_ToiletNum_Change"):
				var _CLEANNUM: int = UsTime
				if _CLEANNUM >= 10:
					_CLEANNUM = 10
				_USER.call_ToiletNum_Change(_CLEANNUM)
