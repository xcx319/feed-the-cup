extends CanvasLayer

onready var Ani = $AnimationPlayer

var _ISJOIN: bool
var WaitMaster: bool

func _ready():
	call_init()
	if not GameLogic.is_connected("DayStart", self, "_Start"):
		var _CON = GameLogic.connect("DayStart", self, "_Start")

func call_SomeJoin_Info():
	Ani.play("正在加入不可选关卡")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_BuyError_Info():
	Ani.play("不可购买")
	var _AUDIO = GameLogic.Audio.return_Effect("错误1")
	_AUDIO.play(0)
func call_show(_NAME: String):
	$Control / NinePatchRect / Label.call_Tr_TEXT("网络-正在加入")
	$Control / NinePatchRect / Label.text = $Control / NinePatchRect / Label.text + " " + _NAME
	_ISJOIN = true

	get_tree().set_pause(true)
	Ani.play("中间文字")
	$Timer.wait_time = 30
	$Timer.start(0)
func call_Wait(_NAME: String):
	$Control / NinePatchRect / Label.call_Tr_TEXT("网络-正在加入")
	$Control / NinePatchRect / Label.text = $Control / NinePatchRect / Label.text + " " + _NAME
	_ISJOIN = true
	get_tree().set_pause(true)
	Ani.play("中间文字")
	$Timer.wait_time = 3
	$Timer.start(0)
func call_end():

	if _ISJOIN:
		_ISJOIN = false
		get_tree().set_pause(false)
	Ani.play("init")
	get_parent().emit_signal("LobbyUpdate")
func _Start():
	call_Master_Switch(false)

func call_Master_Switch(_Switch: bool):
	match _Switch:
		true:
			Ani.play("房主选择")
			WaitMaster = true
		false:
			_ISJOIN = false
			Ani.play("init")
			WaitMaster = false

	pass
func call_NoJoin():
	Ani.play("关卡中不可")
func call_VERSION_ANI(_VERSION):
	$Control / NinePatchRect / VERSION_Friend / Label.text = str(_VERSION)
	$Control / NinePatchRect / VERSION / Label.text = str(GameLogic.Save.VERSION)
	if _VERSION == "":
		Ani.play("未获取版本")
	else:
		Ani.play("版本不同")
	$Timer.stop()
func call_Waiting():

	$Control / NinePatchRect / Label.call_Tr_TEXT("信息-等待其他玩家")
	Ani.play("中间文字")

func _on_Timer_timeout():
	if not _ISJOIN:

		return
	if SteamLogic.TryJoinID != 0:

		SteamLogic.call_LeaveLobby(false, SteamLogic.TryJoinID)
		call_end()
	else:
		call_end()

func call_init():
	$Waiting / VBoxContainer / P1NAME.hide()
	$Waiting / VBoxContainer / P2NAME.hide()
	$Waiting / VBoxContainer / P3NAME.hide()
	$Waiting / VBoxContainer / P4NAME.hide()
	Ani.play("init")
func call_Member_Set():
	call_init()

	for _MEMBER in SteamLogic.LOBBY_MEMBERS:
		match _MEMBER.steam_id:
			SteamLogic.SLOT:
				$Waiting / VBoxContainer / P1NAME.text = _MEMBER.steam_name
				$Waiting / VBoxContainer / P1NAME / LatencyLabel.SteamID = _MEMBER.steam_id
				if _MEMBER.Check:
					$Waiting / VBoxContainer / P1NAME / Label / AnimationPlayer.play("finish")
				else:
					if _MEMBER.steam_id == SteamLogic.STEAM_ID:
						$Waiting / VBoxContainer / P1NAME / Label / AnimationPlayer.play("finish")
					else:
						$Waiting / VBoxContainer / P1NAME / Label / AnimationPlayer.play("init")
				$Waiting / VBoxContainer / P1NAME.show()
			SteamLogic.SLOT_2:
				$Waiting / VBoxContainer / P2NAME.text = _MEMBER.steam_name
				$Waiting / VBoxContainer / P2NAME / LatencyLabel.SteamID = _MEMBER.steam_id
				if _MEMBER.Check:
					$Waiting / VBoxContainer / P2NAME / Label / AnimationPlayer.play("finish")
				else:
					if _MEMBER.steam_id == SteamLogic.STEAM_ID:
						$Waiting / VBoxContainer / P2NAME / Label / AnimationPlayer.play("finish")
					else:
						$Waiting / VBoxContainer / P2NAME / Label / AnimationPlayer.play("init")
				$Waiting / VBoxContainer / P2NAME.show()
			SteamLogic.SLOT_3:
				$Waiting / VBoxContainer / P3NAME.text = _MEMBER.steam_name
				$Waiting / VBoxContainer / P3NAME / LatencyLabel.SteamID = _MEMBER.steam_id
				if _MEMBER.Check:
					$Waiting / VBoxContainer / P3NAME / Label / AnimationPlayer.play("finish")
				else:
					if _MEMBER.steam_id == SteamLogic.STEAM_ID:
						$Waiting / VBoxContainer / P3NAME / Label / AnimationPlayer.play("finish")
					else:
						$Waiting / VBoxContainer / P3NAME / Label / AnimationPlayer.play("init")
				$Waiting / VBoxContainer / P3NAME.show()
			SteamLogic.SLOT_4:
				$Waiting / VBoxContainer / P4NAME.text = _MEMBER.steam_name
				$Waiting / VBoxContainer / P4NAME / LatencyLabel.SteamID = _MEMBER.steam_id
				if _MEMBER.Check:
					$Waiting / VBoxContainer / P4NAME / Label / AnimationPlayer.play("finish")
				else:
					if _MEMBER.steam_id == SteamLogic.STEAM_ID:
						$Waiting / VBoxContainer / P4NAME / Label / AnimationPlayer.play("finish")
					else:
						$Waiting / VBoxContainer / P4NAME / Label / AnimationPlayer.play("init")
				$Waiting / VBoxContainer / P4NAME.show()

func call_WaitNetPlayer():

	call_Member_Set()
	if SteamLogic.LOBBY_IsMaster:
		$Waiting / ButList / Connect.show()
		$Waiting / ButList / Kick.show()
		$Waiting / ButList / Wait.hide()
	else:
		$Waiting / ButList / Connect.hide()
		$Waiting / ButList / Kick.hide()
		$Waiting / ButList / Wait.show()
	if not $AnimationPlayer.assigned_animation in ["房主选择"]:
		$AnimationPlayer.play("等待其他玩家")
	GameLogic.Can_ESC = false

func call_Master_WaitEnd():

	$AnimationPlayer.play("init")

var _TIME: int = 10
var CANCONTROL: bool
func call_1S_Timer():
	CANCONTROL = false
	$Waiting / Time / Timer.start(0)
	$Waiting / ButAni.play("init")
	pass

func _on_1STimer_timeout():
	if not $AnimationPlayer.assigned_animation in ["等待其他玩家"]:
		return
	_TIME -= 1
	if _TIME <= 0:
		$Waiting / ButAni.play("show")
		$Waiting / Time / AnimationPlayer.play("init")
		return
	$Waiting / Time.text = str(_TIME)
	$Waiting / Time / AnimationPlayer.play("show")

func call_grab_focus():
	CANCONTROL = true

func _on_Connect_pressed():
	if get_tree().get_root().get_node("Level")._NEWDAYBOOL:
		get_tree().get_root().get_node("Level").call_NewDay_Master()
	else:
		for _MEMBER in SteamLogic.LOBBY_MEMBERS:
			match _MEMBER.steam_id:
				SteamLogic.SLOT_2:
					if not _MEMBER.Check:
						SteamLogic.call_puppet_id_sync(_MEMBER.steam_id, "LoadingLevel", [{"cur_levelInfo": GameLogic.cur_levelInfo, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SteamLogic.SLOT, "SLOT_2": SteamLogic.SLOT_2, "SLOT_3": SteamLogic.SLOT_3, "SLOT_4": SteamLogic.SLOT_4}])
				SteamLogic.SLOT_3:
					if not _MEMBER.Check:
						SteamLogic.call_puppet_id_sync(_MEMBER.steam_id, "LoadingLevel", [{"cur_levelInfo": GameLogic.cur_levelInfo, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SteamLogic.SLOT, "SLOT_2": SteamLogic.SLOT_2, "SLOT_3": SteamLogic.SLOT_3, "SLOT_4": SteamLogic.SLOT_4}])
				SteamLogic.SLOT_4:
					if not _MEMBER.Check:
						SteamLogic.call_puppet_id_sync(_MEMBER.steam_id, "LoadingLevel", [{"cur_levelInfo": GameLogic.cur_levelInfo, "LOBBY_gameData": GameLogic.Save.gameData, "LOBBY_statisticsData": GameLogic.Save.statisticsData, "LOBBY_levelData": GameLogic.Save.levelData, "SLOT": SteamLogic.SLOT, "SLOT_2": SteamLogic.SLOT_2, "SLOT_3": SteamLogic.SLOT_3, "SLOT_4": SteamLogic.SLOT_4}])
	_TIME = 10
	call_1S_Timer()

func _on_Kick_pressed():

	for _MEMBER in SteamLogic.LOBBY_MEMBERS:
		match _MEMBER.steam_id:
			SteamLogic.SLOT_2:
				if not _MEMBER.Check:
					SteamLogic.call_kick_player(_MEMBER.steam_id)

			SteamLogic.SLOT_3:
				if not _MEMBER.Check:
					SteamLogic.call_kick_player(_MEMBER.steam_id)

			SteamLogic.SLOT_4:
				if not _MEMBER.Check:

					SteamLogic.call_kick_player(_MEMBER.steam_id)

	call_Member_Set()
	SteamLogic.emit_signal("MasterSYNC")
func _on_Exit_pressed():
	SteamLogic.call_LeaveLobby(true, SteamLogic.LOBBY_ID)

func _on_Wait_pressed():
	pass
