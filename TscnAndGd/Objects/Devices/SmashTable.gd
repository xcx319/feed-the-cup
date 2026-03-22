extends Head_Object
var SelfDev = "SmashTable"

onready var A_But = $But / A
onready var Y_But = $But / Y
onready var ActANI = $AniNode / ActAni
var _PLAYERLIST: Array

func _ready() -> void :
	call_init(SelfDev)
	if CanLayout:
		CanMove = true
func _CanMove_Check():
	if CanLayout:
		CanMove = false
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)

func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)

func call_Smash(_ButID, _HoldObj, _Player):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _HoldObj.Extra_1 == "":
				return
			if _HoldObj.Liquid_Count > 0:
				return
			But_Switch(true, _Player)
		0:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if _HoldObj.Liquid_Count > 0 or $WarningNode.NeedFix:
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_Player.call_Say_NoUse()
				return

			if _HoldObj.Extra_1 == "":

				return
			call_CanMove_Logic(false)
			$Timer.start(0)
			_Player.call_Smash_Start()
			if not _PLAYERLIST.has(_Player):
				_PLAYERLIST.append(_Player)

func But_Switch(_Bool, _Player):
	Y_But.hide()

	if _Player.Con.IsHold:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
		A_But.show()
	else:
		if CanMove:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			A_But.show()
		else:
			A_But.hide()
	if $WarningNode.NeedFix:
		if not _Player.Con.IsHold:
			Y_But.show()
			A_But.hide()
	.But_Switch(_Bool, _Player)
func call_MachineControl(_ButID, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return


			But_Switch(true, _Player)

		0:
			if not CanMove:
				if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
					_Player.call_Say_NoUse()
					return
		3:
			if GameLogic.Device.return_CanUse_bool(_Player):
				return
			if $WarningNode.NeedFix:
				if _Player.Con.IsHold:
					return
				call_Fix_Logic(_Player)

func call_Fix_Logic(_Player):
	if $WarningNode.return_Fixing(_Player):
		call_Fix_Ani(_Player)
		But_Switch(true, _Player)
	else:
		call_Fix_Ani(_Player)
func call_Fix_Ani(_Player):
	ActANI.play("Fix")
	GameLogic.Con.call_vibration_Type(_Player.cur_Player, 1)

func call_CanMove_Logic(_Switch: bool):
		CanMove = _Switch

func _on_Timer_timeout():
	for _PLAYER in _PLAYERLIST:
		if _PLAYER.Con.ArmState == GameLogic.NPC.STATE.SMASH:
			$Timer.start(0)
			return
		else:
				_PLAYERLIST.erase(_PLAYER)
	call_CanMove_Logic(true)
