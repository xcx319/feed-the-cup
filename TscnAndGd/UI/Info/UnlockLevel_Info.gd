extends Control

var _PLAYERID: int

var _SHOWBOOL: bool
export var SLOT: int

func _ready():
	self.hide()
	call_deferred("call_SLOT_init")
	var _Latency = SteamLogic.connect("Latency", self, "_CheckLogic")
	var _CHECK = SteamLogic.connect("MasterSYNC", self, "call_Check")
func call_init():

	$UnLockAni.play("init")
func call_SLOT_init():
	if SLOT == 2:
		$PlayerAni.play("2")
	elif SLOT == 3:
		$PlayerAni.play("3")
	elif SLOT == 4:
		$PlayerAni.play("4")

func call_NAME_Set(_STEAMID, _UNLOCK: int):

	self.show()
	var _NAME = Steam.getFriendPersonaName(_STEAMID)
	$Name.text = _NAME
	match _UNLOCK:
		0:
			$UnLockAni.play("Unlocked")
		1:
			$UnLockAni.play("Unlockable")
		2:
			$UnLockAni.play("Ununlockable")
		3:
			$UnLockAni.play("中途加入不可解锁")
func _CheckLogic(_STEAMID, _INFO: Array):

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:

		if GameLogic.cur_level:
			GameLogic.GameUI.call_JoinInfo(0)
		else:
			GameLogic.GameUI.call_JoinInfo( - 1)
	match SLOT:
		2:
			if SteamLogic.SLOT_2 == 0:
				self.hide()
				return
			if _STEAMID == SteamLogic.SLOT_2:
				call_NAME_Set(_STEAMID, _INFO[1])
			elif SteamLogic.STEAM_ID == SteamLogic.SLOT_2:

				call_NAME_Set(SteamLogic.STEAM_ID, GameLogic.GameUI._LEVELCHECKINT)



		3:
			if SteamLogic.SLOT_3 == 0:
				self.hide()
				return
			if _STEAMID == SteamLogic.SLOT_3:
				call_NAME_Set(_STEAMID, _INFO[1])
			elif SteamLogic.STEAM_ID == SteamLogic.SLOT_3:

				call_NAME_Set(SteamLogic.STEAM_ID, GameLogic.GameUI._LEVELCHECKINT)

		4:
			if SteamLogic.SLOT_4 == 0:
				self.hide()
				return
			if _STEAMID == SteamLogic.SLOT_4:
				call_NAME_Set(_STEAMID, _INFO[1])
			elif SteamLogic.STEAM_ID == SteamLogic.SLOT_4:

				call_NAME_Set(SteamLogic.STEAM_ID, GameLogic.GameUI._LEVELCHECKINT)

func call_Check():
	match SLOT:
		2:
			if SteamLogic.SLOT_2 == 0:
				self.hide()
		3:
			if SteamLogic.SLOT_3 == 0:
				self.hide()
		4:
			if SteamLogic.SLOT_4 == 0:
				self.hide()
func call_PlayerSet(_ID):
	_PLAYERID = _ID
	if _PLAYERID == SteamLogic.SLOT_2:
		self.show()
	elif _PLAYERID == SteamLogic.SLOT_3:
		self.show()
	elif _PLAYERID == SteamLogic.SLOT_4:
		self.show()
	else:
		self.hide()
