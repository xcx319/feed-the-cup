extends Head_Object
var SelfDev = "MopPool"

var HasMop: bool = true
onready var A_But = get_node("But/A")
onready var X_But = get_node("But/X")
onready var Audio_Take
var CLEANPLAYER = null

export var _TEST: bool = false

func _ready() -> void :


	call_init(SelfDev)
	CanPick = true
	call_deferred("_Mop_init")
	if GameLogic.LoadingUI.IsLevel:
		var _LEVELINFO = GameLogic.cur_levelInfo
		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			var _LEVEL = SteamLogic.LevelDic.Level
			var _DEVIL = SteamLogic.LevelDic.Devil
			var _DevilList = GameLogic.Config.SceneConfig[_LEVEL].DevilList
			var _GAMEPLAY: Array
			for _i in _DevilList.size():
				if (_i + 1) <= _DEVIL:
					_GAMEPLAY.append(_DevilList[_i])
			if not _GAMEPLAY.has("难度-污渍水渍") and not GameLogic.curLevelList.has("难度-污渍水渍"):
				if not _TEST:
					self.queue_free()
					return

		elif _LEVELINFO.has("GamePlay"):
			var _GAMEPLAY = _LEVELINFO.GamePlay
			if not _GAMEPLAY.has("难度-污渍水渍") and not GameLogic.curLevelList.has("难度-污渍水渍"):

				if not _TEST:
					self.queue_free()
					return

func call_queue_puppet():
	self.queue_free()
func call_init_puppet(_MOPINFO):
	for _NODE in $SavedNode.get_children():
		_NODE.queue_free()

	var _MopLoad = GameLogic.TSCNLoad.return_TSCN("Mop")
	var _Mop = _MopLoad.instance()
	$SavedNode.add_child(_Mop)
	OnTableObj = _Mop
	_Mop.call_load(_MOPINFO)
func call_load(_Info):
	$SavedNode / Mop_pool.queue_free()

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	HasMop = _Info.HasMop
	if HasMop:
		var _MopLoad = load("res://TscnAndGd/Objects/Devices/Mop_pool.tscn")
		var _Mop = _MopLoad.instance()
		$SavedNode.add_child(_Mop)
		OnTableObj = _Mop
		var _MOPINFO = {
			"TSCN": "Mop",
			"NAME": str(_Mop.get_instance_id()),
			"StainCount": 0,
			"TYPE": "Mop",

			"pos": Vector2.ZERO, }
		_Mop.call_load(_MOPINFO)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_init_puppet", [_MOPINFO])

func _Mop_init():

	Audio_Take = GameLogic.Audio.return_Effect("拿起")
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if not _Player.Con.IsHold:
		if HasMop:
			get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_Str)

			A_But.show()
			A_But.call_player_in(_Player.cur_Player)
			if is_instance_valid(OnTableObj):
				if OnTableObj.StainCount > 0:
					X_But.show()
				else:
					X_But.hide()
		else:
			A_But.hide()
	else:
		if not HasMop:
			A_But.show()
			get_node("But/A").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/A").Info_1)
			A_But.call_player_in(_Player.cur_Player)
			X_But.hide()
	.But_Switch(_bool, _Player)
func call_pick(_butID, _Player):

	match _butID:
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			But_Switch(true, _Player)
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			A_But.call_player_out(_Player.cur_Player)
			X_But.hide()

			But_Switch(false, _Player)
		0:
			if not _Player.Con.IsHold:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if HasMop:

					call_TakeMop(_Player)
					But_Switch(true, _Player)
			else:
				if GameLogic.Device.return_CanUse_bool(_Player):
					return
				if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
					return
				if not HasMop:
					var _Dev = instance_from_id(_Player.Con.HoldInsId)
					if _Dev.SelfDev == "Mop":
						call_PutMop(_Player)
						But_Switch(true, _Player)
		2:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if HasMop and CLEANPLAYER == null:
				if is_instance_valid(OnTableObj):
					if OnTableObj.StainCount > 0:

						_Clean_Logic(_Player)

func call_Clean_puppet(_PLAYERPATH, _TIME):
	var _PLAYER = get_node(_PLAYERPATH)
	CLEANPLAYER = _PLAYER
	_PLAYER.Con.call_WORK()
	CLEANPLAYER.call_control(1)
	$CleanTimer.wait_time = _TIME
	$CleanTimer.start(0)
	$AudioStreamPlayer2D.play(0)
func _Clean_Logic(_PLAYER):
	CLEANPLAYER = _PLAYER
	_PLAYER.Con.call_WORK()
	CLEANPLAYER.call_control(1)
	var _TIME: float = 0.2 * GameLogic.return_Multiplier_Division()
	$CleanTimer.wait_time = _TIME
	$CleanTimer.start(0)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _PLAYER.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_Clean_puppet", [_PLAYERPATH, _TIME])
	$AudioStreamPlayer2D.play(0)
func _on_CleanTimer_timeout():
	if is_instance_valid(CLEANPLAYER):
		if is_instance_valid(OnTableObj):
			OnTableObj.StainCount -= 10
			OnTableObj._Stain_Logic()
			if OnTableObj.StainCount <= 0:
				CLEANPLAYER.call_control(0)
				CLEANPLAYER.Con.call_reset_ArmState()
				CLEANPLAYER = null
			else:
				$CleanTimer.start(0)
		else:
			$CleanTimer.start(0)
			CLEANPLAYER.call_control(0)
			CLEANPLAYER.Con.call_reset_ArmState()
			CLEANPLAYER = null
func call_TakeMop_puppet(_PLAYERPATH):

	var _Player = get_node(_PLAYERPATH)
	SavedNode.remove_child(OnTableObj)
	HasMop = false
	GameLogic.Device.call_Player_Pick(_Player, OnTableObj)
	OnTableObj = null
func call_TakeMop(_Player):
	if not _Player.Con.IsHold:

		GameLogic.Device.call_Player_Pick(_Player, self)

func call_PutMop_puppet(_PLAYERPATH):

	var _Player = get_node(_PLAYERPATH)
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	_Player.WeaponNode.remove_child(_Dev)
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	_Audio.play(0)
	_Dev.position = Vector2.ZERO
	_Player.Stat.call_carry_off()
	SavedNode.add_child(_Dev)
	OnTableObj = _Dev
	HasMop = true
	if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		_Dev.call_X_Switch(false)
func call_PutMop(_Player):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_PutMop_puppet", [_PLAYERPATH])
	var _Dev = instance_from_id(_Player.Con.HoldInsId)
	_Player.WeaponNode.remove_child(_Dev)
	var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
	_Audio.play(0)
	_Dev.position = Vector2.ZERO
	_Player.Stat.call_carry_off()
	SavedNode.add_child(_Dev)
	OnTableObj = _Dev
	HasMop = true
	if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		_Dev.call_X_Switch(false)
