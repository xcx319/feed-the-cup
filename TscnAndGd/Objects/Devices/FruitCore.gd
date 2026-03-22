extends Head_Object
var SelfDev = "FruitCore"

var FruitName: String = ""
var FruitNum: int = 0
var _FruitInList: Array = ["杨梅"]

onready var UseAni = $AniNode / UseAni
onready var TypeAni = $AniNode / TypeAni
onready var A_But = $But / A
onready var X_But = $But / X

var IsPassDay: bool
var IsBroken: bool
var _AUDIO: AudioStreamPlayer
func _ready() -> void :
	call_init(SelfDev)
	_AUDIO = GameLogic.Audio.return_Effect("气泡")

	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():
	if FruitName in ["杨梅块"]:

		IsBroken = true
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.FRUITCORE):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.FRUITCORE)
func call_Audio():
	_AUDIO.play(0)
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	A_But.show()
	X_But.hide()
	if not _Player.Con.IsHold:
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_2)
		if FruitName:
			if FruitName in _FruitInList:
				X_But.show()
	else:
		var _Fruit = _Player.Con.HoldObj.FuncTypePara
		var _test = _Player.Con.HoldObj.FuncType
		if _Player.Con.HoldObj.FuncType in ["Fruit"]:
			if _Fruit in _FruitInList:
				A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		elif _Player.Con.HoldObj.FuncType in ["MaterialBig", "MaterialBox", "MaterialBig", "DrinkCup"]:
			A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
			if FruitNum <= 0 or FruitName in _FruitInList:
				A_But.hide()
		else:
			A_But.hide()
	.But_Switch(_bool, _Player)
func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME

	if _Info.has("FruitName"):
		FruitName = _Info.FruitName
	if _Info.has("IsBroken"):
		IsBroken = _Info.IsBroken
	if _Info.has("FruitNum"):
		FruitNum = _Info.FruitNum
	CanMove = true
	.call_Ins_Save(_SELFID)
	call_Broken_Check()
	if TypeAni.has_animation(FruitName):
		TypeAni.play(FruitName)
		UseAni.play("Has")

func call_Broken_Check():
	if IsBroken:

		$Effect_flies / Ani.play("Flies")

	else:

		$Effect_flies / Ani.play("init")
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)

func call_Fruit_In(_ButID, _Player, _HoldObj):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			var _TYPE = _HoldObj.TypeStr
			if _TYPE in _FruitInList:
				But_Switch(true, _Player)
		0:
			if not FruitName:
				var _TYPE = _HoldObj.TypeStr
				if _TYPE in _FruitInList:
					FruitName = _TYPE
					FruitNum = 5

					TypeAni.play(FruitName)
					UseAni.play("PutIn")
					_Player.WeaponNode.remove_child(_HoldObj)
					_HoldObj.position = Vector2.ZERO
					_HoldObj.call_del()
					_Player.Stat.call_carry_off()
					But_Switch(true, _Player)

					return true
func call_Num_Logic():
	match FruitNum:
		5:
			$TexNode / Fruit / FruitBayberrySlice1.show()
			$TexNode / Fruit / FruitBayberrySlice2.show()
			$TexNode / Fruit / FruitBayberrySlice3.show()
			$TexNode / Fruit / FruitBayberrySlice4.show()
			$TexNode / Fruit / FruitBayberrySlice5.show()
		4:
			$TexNode / Fruit / FruitBayberrySlice1.show()
			$TexNode / Fruit / FruitBayberrySlice2.show()
			$TexNode / Fruit / FruitBayberrySlice3.show()
			$TexNode / Fruit / FruitBayberrySlice4.show()
			$TexNode / Fruit / FruitBayberrySlice5.hide()
		3:
			$TexNode / Fruit / FruitBayberrySlice1.show()
			$TexNode / Fruit / FruitBayberrySlice2.show()
			$TexNode / Fruit / FruitBayberrySlice3.show()
			$TexNode / Fruit / FruitBayberrySlice4.hide()
			$TexNode / Fruit / FruitBayberrySlice5.hide()
		2:
			$TexNode / Fruit / FruitBayberrySlice1.show()
			$TexNode / Fruit / FruitBayberrySlice2.show()
			$TexNode / Fruit / FruitBayberrySlice3.hide()
			$TexNode / Fruit / FruitBayberrySlice4.hide()
			$TexNode / Fruit / FruitBayberrySlice5.hide()
		1:
			$TexNode / Fruit / FruitBayberrySlice1.show()
			$TexNode / Fruit / FruitBayberrySlice2.hide()
			$TexNode / Fruit / FruitBayberrySlice3.hide()
			$TexNode / Fruit / FruitBayberrySlice4.hide()
			$TexNode / Fruit / FruitBayberrySlice5.hide()
		_:
			$TexNode / Fruit / FruitBayberrySlice1.hide()
			$TexNode / Fruit / FruitBayberrySlice2.hide()
			$TexNode / Fruit / FruitBayberrySlice3.hide()
			$TexNode / Fruit / FruitBayberrySlice4.hide()
			$TexNode / Fruit / FruitBayberrySlice5.hide()
func call_Use(_ButID, _Player):
	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
		2:
			if not FruitName in _FruitInList:
				return
			UseAni.play("Use")
			match FruitName:
				"杨梅":
					FruitName = "杨梅块"
			But_Switch(true, _Player)
			return true
func _Use_Logic():
	TypeAni.play(FruitName)


func call_Fruit_Out(_ButID, _HoldObj, _Player):
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

			var _return = _HoldObj.call_PutInBox(_ButID, self, _Player)
			call_Num_Logic()
			But_Switch(true, _Player)
			return _return
func call_Fruit_Out_Num(_NUM: int):
	FruitNum -= _NUM
	if FruitNum <= 0:
		FruitName = ""
		IsBroken = false
		IsPassDay = false
	call_Broken_Check()
	call_Num_Logic()
func call_Fruit_In_Cup(_ButID, _CupObj, _Player):
	if _ButID == - 1:
		But_Switch(true, _Player)
	if _ButID == 0 and FruitNum > 0:
		if FruitName in ["杨梅块"]:
			match _CupObj.TYPE:
				"DrinkCup_S":
					if _CupObj.Extra_1 != "":
						return
				"DrinkCup_M":
					if _CupObj.Extra_2 != "":
						return
				"DrinkCup_L":
					if _CupObj.Extra_3 != "":
						return
				"SuperCup_M":
					if _CupObj.Extra_5 != "":
						return
			var _CHECK: bool
			if _CupObj.Extra_1 == "":
				_CupObj.Extra_1 = FruitName
				_CupObj.call_add_extra()
				_CHECK = true
			elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 == "" and _CupObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "SuperCup_M"]:
				_CupObj.Extra_2 = FruitName
				_CupObj.call_add_extra()
				_CHECK = true
			elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 != "" and _CupObj.Extra_3 == "" and _CupObj.TYPE in ["DrinkCup_L", "SuperCup_M"]:
				_CupObj.Extra_3 = FruitName
				_CupObj.call_add_extra()
				_CHECK = true
			elif _CupObj.Extra_3 != "" and _CupObj.get("Extra_4") == "" and _CupObj.TYPE in ["SuperCup_M"]:
				_CupObj.Extra_4 = FruitName
				_CupObj.call_add_extra()
				_CHECK = true
			elif _CupObj.get("Extra_4") != "" and _CupObj.get("Extra_5") == "" and _CupObj.TYPE in ["SuperCup_M"]:
				_CupObj.Extra_5 = FruitName
				_CupObj.call_add_extra()
				_CHECK = true
			if _CHECK:
				call_Fruit_Out_Num(1)
				call_Audio()
				return "加水果"
	pass
func return_DropCount():
	call_Fruit_Out_Num(FruitNum)
	return 1
