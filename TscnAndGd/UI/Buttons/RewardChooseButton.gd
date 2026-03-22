extends Button
onready var NameLabel = get_node("NameLabel")
onready var InfoLabel = get_node("InfoLabel")
onready var CostLabel = get_node("CostLabel")
onready var TYPEAni = get_node("TYPEAni")
onready var CostAni = get_node("CostLabel/Ani")
onready var BuyLabel = get_node("CostLabel/BuyLabel")
var ID: String setget _IDSet
var Name: String setget _NameSet
var Info: String setget _InfoSet
var TYPE: int setget _TYPE_Set
var Cost: int
var Rank: int
var IsShow: bool = false
export var REWARDBOOL: bool = false
func _ready() -> void :
	var _con = GameLogic.connect("MoneyChange", self, "_ShowLogic")
	var _SYCN = GameLogic.connect("OPTIONSYNC", self, "_Set")
	if get_parent().name == "InfoControl":
		BuyLabel.show()
	else:
		BuyLabel.hide()
func _ShowLogic(_value):
	if GameLogic.cur_money < Cost:
		CostAni.play("false")
	else:
		CostAni.play("init")

func _Set():
	_NameSet(Name)
	_InfoSet(Info)

var CanINFO: bool
func _IDSet(_ID: String):

	ID = _ID
	if GameLogic.Config.CardConfig.has(ID):
		var INFO = GameLogic.Config.CardConfig[ID]

		_NameSet(INFO.ShowNameID)
		_InfoSet(INFO.ShowInfoID, INFO.InfoType1, INFO.InfoType2)
		_CostSet(INFO.Cost)
		_RankSet(0, INFO.Rank, INFO.SpecialAni)
		_IconSet(INFO.Icon)
		if INFO.UnlockType == "升级":

			get_node("Plus").play("+")
		else:
			get_node("Plus").play("init")
		if IsShow:
			if not GameLogic.Save.statisticsData.CardList.has(ID):

				_TYPE_Set(5)
			else:
				var _LIST = GameLogic.Save.statisticsData.CardList[ID]

				$UsedControl / Used / Number.text = str(_LIST[0])
				$UsedControl / Finished / Number.text = str(_LIST[1])
				$UsedControl / HighScore / Number.text = str(_LIST[2])
				CanINFO = true
				_TYPE_Set(3)
		elif REWARDBOOL:
			if not GameLogic.Save.statisticsData.CardList.has(ID):
				$NewLabel.show()
			else:
				$NewLabel.hide()

	elif GameLogic.Config.ChallengeConfig.has(ID):
		var INFO = GameLogic.Config.ChallengeConfig[ID]
		_NameSet(INFO.ShowNameID)
		_InfoSet(INFO.ShowInfoID)

		_RankSet(1, INFO.Rank, "0")
		_IconSet(INFO.Icon)

func _IconSet(_Icon):
	var _TexPath = "res://Resources/UI/Scrolls/ui_scroll_pack.sprites/" + _Icon + ".tres"
	var _Tex = load(_TexPath)
	get_node("IconControl/Icon").set_texture(_Tex)

func _RankSet(_Type, _Rank, _SpecialAni):
	Rank = int(_Rank)
	var _AniName: String
	match _Type:
		0:
			_AniName = "Reward_" + str(_Rank)
		1:
			_AniName = "Challenge_" + str(_Rank)
	get_node("RankAni").play(_AniName)
	get_node("SpecialAni").play(_SpecialAni)
func _CostSet(_Cost: String):
	if GameLogic.Achievement.cur_EquipList.has("设备减价") and not GameLogic.SPECIALLEVEL_Int:
		Cost = int(float(_Cost) * 0.75)
	else:
		Cost = int(_Cost)
	CostLabel.text = str(Cost)
	_ShowLogic( - 1)
func _NameSet(_Name: String):
	Name = _Name
	var _ChallName = GameLogic.CardTrans.get_message(Name)
	var _TEXT = "[center]" + _ChallName + "[/center]"
	NameLabel.bbcode_text = _TEXT
func _InfoSet(_Info: String, _Type1: Array = [], _Type2: Array = []):
	if _Info == "":
		return
	Info = _Info
	var _ChallengeInfo = GameLogic.CardTrans.get_message(Info)

	var _TEXT_1 = GameLogic.Info.return_ColorInfo(_ChallengeInfo, _Type1, _Type2)

	var _TEXT = "[center]" + _TEXT_1.format(GameLogic.Info.Info_Name) + "[/center]"
	InfoLabel.bbcode_text = _TEXT

func _TYPE_Set(_Type: int):
	TYPE = _Type
	match TYPE:
		1:
			TYPEAni.play("BUY")
		2:
			TYPEAni.play("Select")
		3:
			TYPEAni.play("Check")
		4:
			TYPEAni.play("Choose")
		5:
			TYPEAni.play("Hide")
func _on_mouse_entered() -> void :
	self.grab_focus()

func _on_focus_entered():
	if IsShow:
		return
	$SelectShow / AnimationPlayer.play("show")

func _on_focus_exited():
	$SelectShow / AnimationPlayer.play("init")

func call_INFO_Switch(_SWITCH: bool):
	if CanINFO:
		match _SWITCH:
			true:
				$INFOTYPE.play("show")
			false:
				$INFOTYPE.play("init")

onready var NetChooseTSCN = preload("res://TscnAndGd/Effects/NetChoose.tscn")

func call_NetChoose(_PLAYER: int):
	var _ChooseTSCN = NetChooseTSCN.instance()
	var _randx = GameLogic.return_RANDOM() % 260 - 130
	var _randy = GameLogic.return_RANDOM() % 40 - 20
	var _POS: Vector2 = Vector2(_randx, _randy)
	var _NUM = $Net.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	_ChooseTSCN.position = _POS
	$Net.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)

	if SteamLogic.IsMultiplay:
		SteamLogic.call_puppet_node_sync(self, "call_NetChoose_puppet", [_PLAYER, _POS])

func call_NetChoose_puppet(_PLAYER, _POS):
	var _ChooseTSCN = NetChooseTSCN.instance()
	_ChooseTSCN.position = _POS
	var _NUM = $Net.get_child_count()
	_ChooseTSCN.name = str(_NUM)
	$Net.add_child(_ChooseTSCN)
	_ChooseTSCN.call_Player(_PLAYER)
