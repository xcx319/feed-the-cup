extends Node2D

var RunBool: bool
var ToiletBool: bool
var ToiletNum: int = 0
var ToiletCheckList: Array = [20, 22, 25, 30]
var IsRunning: bool
var RunCheckNum: int = 0
var RunTime: float
var RunTime_S: int
var RunTime_m: int
var CountNum: int = 0
onready var ANI = $SpecialAni
onready var InfoLabel = $Label
onready var PlayerNode = get_parent().get_parent().get_parent()

func _ready():
	set_process(false)
	set_physics_process(false)
	call_deferred("call_Run_init")

func call_Run_init():
	RunBool = false
	ToiletBool = false
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if GameLogic.LoadingUI.IsLevel:

		if GameLogic.curLevelList.has("难度-跑圈") or GameLogic.cur_levelInfo.GamePlay.has("难度-跑圈"):
			RunBool = true
			var _NUM: float = float(GameLogic.cur_CloseTime - GameLogic.cur_OpenTime) * 10
			var _RAND: float = float(GameLogic.return_randi() % int(_NUM))
			RunTime = GameLogic.cur_OpenTime + _RAND / 10
			if not GameLogic.GameUI.is_connected("TimeChange", self, "_TimeChange_Logic"):
				var _check = GameLogic.GameUI.connect("TimeChange", self, "_TimeChange_Logic")

		if GameLogic.curLevelList.has("难度-厕所") or GameLogic.cur_levelInfo.GamePlay.has("难度-厕所"):
			ToiletBool = true
			if not GameLogic.GameUI.is_connected("TimeChange", self, "_ToiletCharge"):
				var _check = GameLogic.GameUI.connect("TimeChange", self, "_ToiletCharge")

func call_ToiletNum_Change(_NUM: int):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if not ToiletBool:
		return
	if ToiletNum > 5 and _NUM > 0:
		$Texture / DownEffect / Effect / AnimationPlayer.play("init")
		$Texture / DownEffect / Effect / AnimationPlayer.play("show")
	elif ToiletNum <= 5 and _NUM > 0:
		AudioAni.play("FinishToilet")
	ToiletNum -= _NUM
	if ToiletNum < 0:
		ToiletNum = 0
	call_ToiletShow()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_ToiletNum_puppet", [ToiletNum, _NUM])

func call_ToiletNum_puppet(_TOILETNUMSET, _NUM: int = 0):

	ToiletNum = _TOILETNUMSET
	if ToiletNum > 5 and _NUM > 0:
		$Texture / DownEffect / Effect / AnimationPlayer.play("init")
		$Texture / DownEffect / Effect / AnimationPlayer.play("show")
	elif ToiletNum <= 5 and _NUM > 0:
		AudioAni.play("FinishToilet")
	call_ToiletShow()
func _ToiletCharge():

	if ToiletBool:
		if ToiletNum < ToiletCheckList.back():
			if PlayerNode.cur_Pressure >= PlayerNode.cur_PressureMax:
				pass
			else:
				ToiletNum += 1
	else:
		if GameLogic.GameUI.is_connected("TimeChange", self, "_ToiletCharge"):
			var _check = GameLogic.GameUI.disconnect("TimeChange", self, "_ToiletCharge")
	if ToiletNum >= ToiletCheckList[1] and ToiletNum < ToiletCheckList[2]:
		pass
	elif ToiletNum >= ToiletCheckList[2] and ToiletNum < ToiletCheckList[3]:
		pass

	call_ToiletShow()
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_ToiletNum_puppet", [ToiletNum])

var IsMax: bool
onready var AudioAni = $AudioStreamPlayer / AnimationPlayer
func call_ToiletShow():
	if ToiletNum < ToiletCheckList[0]:
		ANI.play("init")
		call_SpeedChange(0)
		set_process(false)
	elif ToiletNum < ToiletCheckList[1]:
		ANI.play("1")
		call_SpeedChange(0)
		set_process(false)
	elif ToiletNum < ToiletCheckList[2]:
		ANI.play("2")
		call_SpeedChange(1)
		set_process(false)
	elif ToiletNum < ToiletCheckList[3]:
		ANI.play("3")
		call_SpeedChange(2)
		set_process(false)
		IsMax = false
	else:
		set_process(true)
		call_SpeedChange(2)
		ANI.play("4")
		if not IsMax:
			IsMax = true
			AudioAni.play("Toilet")
	printerr(" 厕所值：", ToiletNum)
func call_SpeedChange(_TYPE: int):
	match _TYPE:
		0:
			if PlayerNode.Stat.Ins_Skill_2_Mult > 1:
				PlayerNode.Stat.Ins_Skill_2_Mult = 1
				PlayerNode.Stat._data_instance()
		1:
			PlayerNode.Stat.Ins_Skill_2_Mult = 1.25
			PlayerNode.Stat._speed_change_logic()
		2:
			PlayerNode.Stat.Ins_Skill_2_Mult = 1.5
			PlayerNode.Stat._speed_change_logic()
func _TimeChange_Logic():
	if RunBool:
		call_Run_Check()
func call_Run_Check():
	var _CHECKTIME = GameLogic.GameUI.CurTime
	if RunTime <= _CHECKTIME and not IsRunning:
		call_Run_Logic()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_node_sync(self, "call_Run_Logic")
func call_Run_Logic():
	RunCheckNum = - 1
	IsRunning = true
	ANI.play("ReadyToRun")
	AudioAni.play("ReadyToRun")
	RunBool = false
	if PlayerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.call_Run( - 2, 0)
	PlayerNode.AVATAR.call_Run_Start()
func call_CheckPoint(_TYPE):
	RunCheckNum += 1
	if PlayerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.call_Run(RunCheckNum)
	if _TYPE == 2:
		IsRunning = false
		set_process(false)

		if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_master_node_sync(self, "call_master_RunEnd")
			SteamLogic.call_puppet_node_sync(self, "call_RunEnd_everybody", [InfoLabel.text])
		else:
			call_master_RunEnd()

func call_RunEnd_everybody(_TEXT):
	InfoLabel.text = _TEXT

func call_master_RunEnd():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_master_RunEnd")
	AudioAni.play("RunEnd")
	PlayerNode.AVATAR.call_Run_End()
	get_tree().call_group("Customers", "call_Bonus", 1)

func call_Run_Start():
	RunCheckNum = 0
	RunTime_m = 0
	RunTime_S = 0
	ANI.play("Running")
	AudioAni.play("Run")
	if PlayerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		GameLogic.call_Run(RunCheckNum, 0)
	set_process(true)

func _process(_delta):
	if ToiletBool:
		RunTime_m += int(_delta * 1000)
		if RunTime_m >= 1000:
			RunTime_S += 1
			RunTime_m -= 1000
			call_Pressure_Logic()
		return
	if IsRunning:
		RunTime_m += int(_delta * 1000)
		if RunTime_m >= 1000:
			RunTime_S += 1
			RunTime_m -= 1000
			call_Pressure_Logic()
		var _S: String
		if RunTime_S >= 10:
			_S = str(RunTime_S)
		else:
			_S = "0" + str(RunTime_S)
		var _m: String
		var _SHOWTIME: int = int(float(RunTime_m) / 10)
		if _SHOWTIME >= 10:
			_m = str(_SHOWTIME)
		else:
			_m = "0" + str(_SHOWTIME)
		InfoLabel.text = _S + "''" + _m
	else:
		set_process(false)
func _physics_process(_delta):
	if ToiletBool:
		RunTime_m += int(_delta * 60)
		if RunTime_m >= 60:
			RunTime_S += 1
			RunTime_m -= 60
			call_Pressure_Logic()
		return
	if IsRunning:
		RunTime_m += int(_delta * 60)
		if RunTime_m >= 60:
			RunTime_S += 1
			RunTime_m -= 60
			call_Pressure_Logic()
		var _S: String
		if RunTime_S >= 10:
			_S = str(RunTime_S)
		else:
			_S = "0" + str(RunTime_S)
		var _m: String
		if RunTime_m >= 10:
			_m = str(RunTime_m)
		else:
			_m = "0" + str(RunTime_m)
		InfoLabel.text = _S + "''" + _m
	else:
		set_process(false)
func call_RunEnd():
	if IsRunning:
		IsRunning = false
		InfoLabel.text = "--"

		if PlayerNode.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			GameLogic.call_Run(RunCheckNum, - 1)
func call_Pressure_Logic():
	if PlayerNode.cur_Pressure >= PlayerNode.cur_PressureMax:
		if ToiletNum > 0:
			ToiletNum = 0
		if IsRunning:
			if SteamLogic.multiplayer and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_RunEnd")
			call_RunEnd()

		return
	if RunTime_S >= 10:
		PlayerNode.call_pressure_set(1)
	if ToiletNum >= ToiletCheckList.back():
		PlayerNode.call_pressure_set(1)

func call_BaseBall_Hit():
	CountNum += 1
	InfoLabel.text = str(CountNum)
	InfoLabel.show()
	if SteamLogic.IsMultiplay and PlayerNode.cur_Player == SteamLogic.STEAM_ID:
		SteamLogic.call_puppet_node_sync(self, "call_BaseBall_Hit_puppet", [CountNum])

func call_BaseBall_Hit_puppet(_HITNUM):
	CountNum = _HITNUM
	InfoLabel.text = str(CountNum)
	InfoLabel.show()
