extends Area2D

var ToiletDoor

var Used: bool
var UserList: Array

onready var UseTime = $Timer
onready var AUDIO = $Audio
func _ready():
	pass

func call_init():
	if get_parent().has_node("Door_Toilet"):
		ToiletDoor = get_parent().get_node("Door_Toilet")

		var _CON = ToiletDoor.connect("CLOSE", self, "_CHECK_LOGIC")

func _CHECK_LOGIC():
	if not Used and UserList.size() == 1 and ToiletDoor.aniPlayer.assigned_animation == "close":
		Used = true
		UseTime.start(0)
		ToiletDoor.CANOPEN = false
		ToiletDoor.call_Lock_Ani()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Used_puppet", [Used])
	elif Used:
		if not UserList.size():
			Used = false
			UseTime.stop()
			UsTime = 0
			ToiletDoor.CANOPEN = true
			ToiletDoor.call_Lock_Ani()
			if not AUDIO.is_playing():
				AUDIO.play(0)
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Used_puppet", [Used])

func _on_Toilet_body_entered(_body):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _body.has_method("_PlayerNode"):
		if not UserList.has(_body):
			UserList.append(_body)
		call_Door_Logic()

func _on_Toilet_body_exited(_body):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _body.has_method("_PlayerNode"):
		if UserList.has(_body):
			UserList.erase(_body)
		_CHECK_LOGIC()
		call_Door_Logic()
func call_Door_Logic():
	if UserList.size() <= 1:
		ToiletDoor.CANCLOSE = true
	else:
		ToiletDoor.CANCLOSE = false
	pass
func call_Used_puppet(_USED):
	Used = _USED
	match _USED:
		true:
			UseTime.start(0)
			ToiletDoor.CANOPEN = false
		false:
			UseTime.stop()
			ToiletDoor.CANOPEN = true
			if not AUDIO.is_playing():
				AUDIO.play(0)
	ToiletDoor.call_Lock_Ani()
var UsTime: int = 0
func _on_Timer_timeout():
	if GameLogic.curLevelList.has("难度-厕所") or GameLogic.cur_levelInfo.GamePlay.has("难度-厕所"):
		if is_instance_valid(ToiletDoor):
			if not ToiletDoor.aniPlayer.assigned_animation in ["close", "init"]:
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
	else:
		UseTime.stop()
