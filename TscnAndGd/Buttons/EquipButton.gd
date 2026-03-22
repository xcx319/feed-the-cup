extends Button
export var AVATARID: int
export var PLAYERID: int
export var ID: int
export var IsBase: bool
export var ISEQUIP: bool = false
var IsRecycle: bool = false
onready var EquipLabel = $Label
onready var ITEMNODE = $Item
onready var RareANI = $ANI
onready var NumLabel = $NumLabel
onready var FOCUSANI = $Focus / ANI
export var NUM: int = 0

export var EQUIPPART: String
export var DISABLEBOOL: bool = true

var EQUIPINFO: Dictionary
func _ready():
	call_EquipShow()
	if not GameLogic.is_connected("EQUIPCHANGE", self, "_ShowLogic"):
		var _con = GameLogic.connect("EQUIPCHANGE", self, "_ShowLogic")
func call_EquipShow():
	match ISEQUIP:
		true:
			EquipLabel.show()
		false:
			EquipLabel.hide()

	if IsBase:
		NumLabel.hide()
		match self.name:
			"1":
				ITEMNODE.call_PartAni("Head")
			"2":
				ITEMNODE.call_PartAni("Face")
			"3":
				ITEMNODE.call_PartAni("Body")
			"4":
				ITEMNODE.call_PartAni("Hand")
			"5":
				ITEMNODE.call_PartAni("Foot")
			"6":
				ITEMNODE.call_PartAni("Accessory")
	elif NUM > 1:
		NumLabel.text = str(NUM)
		NumLabel.show()
	else:
		NumLabel.hide()

func call_ButShow(_ID, _PARTNAME):
	if _ID:
		if GameLogic.Config.CostumeConfig.has(str(_ID)):
			var _INFO = GameLogic.Config.CostumeConfig[str(_ID)]
			var _RARITY = _INFO.rarity
			if RareANI.has_animation(_RARITY):
				RareANI.play(_RARITY)
			if _PARTNAME == "":
				_PARTNAME = _INFO.part
	else:
		RareANI.play("Common")


	ITEMNODE.call_Part_init(_ID, _PARTNAME)
func call_RecycleShow(_ID):
	if GameLogic.Config.CostumeConfig.has(str(_ID)):
		var _INFO = GameLogic.Config.CostumeConfig[str(_ID)]
		var _RARITY = _INFO.rarity
		if RareANI.has_animation(_RARITY):
			RareANI.play(_RARITY)
		var _PARTNAME = _INFO.part
		ITEMNODE.call_Part_init(_ID, _PARTNAME)

		if SteamLogic._EQUIPDIC.has(_ID):
			var _EquipNum = SteamLogic._EQUIPDIC[_ID].Num
			NUM = _EquipNum
			NumLabel.text = str(NUM)
			NumLabel.show()
	else:
		ITEMNODE.call_Part_init(_ID, "")
		RareANI.play("Common")
		NumLabel.hide()
	IsRecycle = true

func call_ID_Logic():
	if ID:
		if GameLogic.Config.CostumeConfig.has(str(ID)):
			EQUIPINFO = GameLogic.Config.CostumeConfig[str(ID)]
		if SteamLogic._EQUIPDIC.has(ID):
			var _EquipNum = SteamLogic._EQUIPDIC[ID].Num
			NUM = _EquipNum
		ITEMNODE.ID = ID

		if IsRecycle:
			if GameLogic.Config.CostumeConfig.has(str(ID)):
				var _INFO = GameLogic.Config.CostumeConfig[str(ID)]
				var _RARITY = _INFO.rarity
				if RareANI.has_animation(_RARITY):
					RareANI.play(_RARITY)
			ISEQUIP = false
			for _i in 8:
				if GameLogic.Save.gameData["EquipDic"].has(PLAYERID):
					var _EQUIPKEYS = GameLogic.Save.gameData["EquipDic"][PLAYERID][_i].keys()

					for _KEY in _EQUIPKEYS:
						var _EQUIPID = int(GameLogic.Save.gameData["EquipDic"][PLAYERID][_i][_KEY])
						if _EQUIPID == ID:
							ISEQUIP = true
							break
			call_Disable_Check()
			call_EquipShow()
			return
		match PLAYERID:

			0:

				if ID:
					if GameLogic.Config.CostumeConfig.has(str(ID)):
						var _INFO = GameLogic.Config.CostumeConfig[str(ID)]
						var _RARITY = _INFO.rarity
						if RareANI.has_animation(_RARITY):
							RareANI.play(_RARITY)
				return
		var _EQUIPKEYS = GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID].keys()
		ISEQUIP = false
		for _KEY in _EQUIPKEYS:
			var _EQUIPID = int(GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID][_KEY])
			if _EQUIPID == ID:
				ISEQUIP = true
				break
		call_Disable_Check()
		call_EquipShow()
func call_Disable_Check():
	if not DISABLEBOOL:
		return
	var _RARITY = EQUIPINFO.rarity
	if RareANI.has_animation(_RARITY):
		RareANI.play(_RARITY)
	var _ROLE = EQUIPINFO.role
	var _AVATARIDCHECK: int
	match _ROLE:
		"Bear":
			_AVATARIDCHECK = 0
		"Wolf":
			_AVATARIDCHECK = 1
		"Fox":
			_AVATARIDCHECK = 2
		"Beaver":
			_AVATARIDCHECK = 3
		"Ghost":
			_AVATARIDCHECK = 4
		"Slime":
			_AVATARIDCHECK = 5
		"Panda":
			_AVATARIDCHECK = 6
		"Crocodile":
			_AVATARIDCHECK = 7

	if AVATARID == _AVATARIDCHECK:
		self.disabled = false
		var _PART = EQUIPINFO.part
		match _PART:
			"Head":
				if not GameLogic.Save.gameData.HomeDevList.has("帽架"):
					self.disabled = true
			"Face":
				if not GameLogic.Save.gameData.HomeDevList.has("帽架"):
					self.disabled = true
			"Body":
				if not GameLogic.Save.gameData.HomeDevList.has("衣橱"):
					self.disabled = true
			"Hand":
				if not GameLogic.Save.gameData.HomeDevList.has("鞋柜"):
					self.disabled = true
			"Foot":
				if not GameLogic.Save.gameData.HomeDevList.has("鞋柜"):
					self.disabled = true
			"Accessory":
				if not GameLogic.Save.gameData.HomeDevList.has("衣橱"):
					self.disabled = true

	else:
		self.disabled = true

func _on_Button_pressed():
	if IsBase:
		return
	if IsRecycle:
		GameLogic.call_Recycle(ID)
		return
	if ISEQUIP:
		if GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID].has(EQUIPPART):
			var _IDCheck = GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID][EQUIPPART]
			if _IDCheck == ID:

				GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID][EQUIPPART] = 0
				GameLogic.call_EquipChange()

				return

	if GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID].has(EQUIPPART):
		GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID][EQUIPPART] = ID
		GameLogic.call_EquipChange()

func _ShowLogic():
	if GameLogic.Save.gameData["EquipDic"].has(PLAYERID):
		if GameLogic.Save.gameData["EquipDic"][PLAYERID].has(AVATARID):
			if GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID].has(EQUIPPART):
				if GameLogic.Save.gameData["EquipDic"][PLAYERID][AVATARID][EQUIPPART] == ID:
					ISEQUIP = true
				else:
					ISEQUIP = false
				call_EquipShow()
func _on_Button_focus_entered():
	if not IsBase:
		FOCUSANI.play("show")
		GameLogic.Audio.But_EasyClick.play()
func _on_Button_focus_exited():
	if not IsBase:
		FOCUSANI.play("init")
func call_Select(_SWITCH: bool):
	match _SWITCH:
		true:
			FOCUSANI.play("show")
		false:
			FOCUSANI.play("init")
