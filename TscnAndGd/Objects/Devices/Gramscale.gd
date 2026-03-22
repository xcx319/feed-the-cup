extends Head_Object
var SelfDev = "GramsSale"

var _ADDPLAYER
var CanADD: bool = true
var ADDOBJ
var CurGram: int
var CurType: String
var _LastType: String
var CurTeaBagList: Array
onready var ADDANI = $AniNode / AddAni
onready var TeaANI = $AniNode / TeaAni
onready var TeaTypeANI = $AniNode / TeaType

onready var BUT_X = $But / X
onready var BUT_Y = $But / Y
onready var BUT_A = $But / A
func _ready() -> void :
	call_init("GramScale")
	if get_parent().name in ["Items", "Devices"]:
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
	if not GameLogic.is_connected("OpenStore", self, "_CanMove_Check"):
		var _con = GameLogic.connect("OpenStore", self, "_CanMove_Check")
	call_deferred("call_Num_init")
func _CanMove_Check():
	if CanLayout:
		if CurTeaBagList.size() == 0:
			CanMove = true
		else:
			CanMove = false
	else:
		CanMove = false
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_CanMove_Check_puppet", [CanMove])
func call_CanMove_Check_puppet(_CANMOVE):
	CanMove = _CANMOVE
func call_Num_init():
	get_node("TexNode/HBox/0").call_init(3, 1, 1)
	get_node("TexNode/HBox/1").call_init(3, 1, 1)
	get_node("TexNode/HBox/2").call_init(3, 1, 1)
	if CurGram > 0:
		call_Gram_Show()



func call_Audio_Cut():
	var _AUDIO_CUT = GameLogic.Audio.return_RandEffect("切脆")
	_AUDIO_CUT.play(0)
func _DayClosedCheck():
	if not is_instance_valid(self):
		return


func call_ButShow():
	if CurGram < 50:
		BUT_Y.hide()
	else:
		BUT_Y.show()
	if CurGram < 200:
		BUT_X.show()
	else:
		BUT_X.hide()
func But_Switch(_bool, _Player):

	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return


	if not _Player.Con.IsHold:
		BUT_A.InfoLabel.text = GameLogic.CardTrans.get_message(BUT_A.Info_1)
		BUT_A.show()
		call_ButShow()
		BUT_X.hide()

	else:
		BUT_A.hide()
		call_ButShow()
		if _Player.Con.IsHold:
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			if _HoldObj.get("FuncType") == "TeaBag":
				BUT_A.InfoLabel.text = GameLogic.CardTrans.get_message(BUT_A.Info_Str)
				BUT_A.show()
				BUT_X.hide()




	.But_Switch(_bool, _Player)

func call_load(_Info):

	_SELFID = int(_Info.NAME)
	self.name = _Info.NAME
	.call_Ins_Save(_SELFID)
	_DayClosedCheck()
	CurGram = _Info.CurGram

	_Type_Logic(_Info.CurType)
	self.position = _Info.pos
	if _Info.has("TeaBagList"):
		if _Info.TeaBagList.size():
			for _EXTRAINFO in _Info.TeaBagList:
				var _ExtraObj = GameLogic.TSCNLoad.Bag_TSCN.instance()
				_ExtraObj._SELFID = int(_EXTRAINFO.NAME)
				var _NAME = _EXTRAINFO.NAME
				_ExtraObj.name = _NAME
				match CurTeaBagList.size():
					0:
						get_node("TexNode/ItemNode/1").add_child(_ExtraObj)
						CurTeaBagList.append(_ExtraObj)
					1:
						get_node("TexNode/ItemNode/2").add_child(_ExtraObj)
						CurTeaBagList.append(_ExtraObj)
					2:
						get_node("TexNode/ItemNode/3").add_child(_ExtraObj)
						CurTeaBagList.append(_ExtraObj)
					3:
						get_node("TexNode/ItemNode/4").add_child(_ExtraObj)
						CurTeaBagList.append(_ExtraObj)
				_ExtraObj.call_load_TSCN(_EXTRAINFO.TypeStr)
	call_Gram_Show()

	_CanMove_Check()

func _CanAdd_Logic(_SWITCH: bool):
	match _SWITCH:
		false:
			CanADD = _SWITCH
		true:
			if CurGram < 50:
				CanADD = true
func call_AddLeaf(_ButID, _HoldObj, _Player):

	match _ButID:
		- 2:
			call_SHAKE_end(_Player)
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return

			_CanAdd_Logic(false)
			if _HoldObj.FuncType in ["TeaLeaf"]:
				_HoldObj.GRAMOBJ = null
			But_Switch(false, _Player)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			if _HoldObj.FuncType in ["TeaLeaf"]:
				_CanAdd_Logic(true)
				if _HoldObj.CurGram > 0:
					if CurType != "" and CurType != _HoldObj.FuncTypePara and CurGram < 50:
						BUT_X.InfoLabel.text = GameLogic.CardTrans.get_message(BUT_X.Info_1)
					else:
						BUT_X.InfoLabel.text = GameLogic.CardTrans.get_message(BUT_X.Info_Str)
			But_Switch(true, _Player)
		2:

			if _HoldObj.FuncType in ["TeaLeaf"]:
				if _HoldObj.CurGram > 0:
					if CurType == "" or CurType == _HoldObj.FuncTypePara:

						_Type_Logic(_HoldObj.FuncTypePara)

						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							var _CHECK = return_SHAKE(_Player)
							if _CHECK:
								_Player.Con.call_SHAKE()
								_ADD_Logic(_HoldObj)

							return


						var _CHECK = return_SHAKE(_Player)
						if _CHECK:
							_Player.Con.call_SHAKE()
							_ADD_Logic(_HoldObj)
					elif CurGram < 50:
						if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
							return
						call_clean()
		3:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			return return_Make_TeaBag(3, _Player)

func call_clean():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_clean")
	CurType = ""
	CurGram = 0
	_TeaAni()
	call_ButShow()
	_CanMove_Check()
	call_Num_init()
func call_Pick_puppet(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	var _OBJ = CurTeaBagList.pop_front()
	_OBJ.get_parent().remove_child(_OBJ)
	GameLogic.Device.call_Player_Pick(_Player, _OBJ)
	for _i in CurTeaBagList.size():
		var _TEAOBJ = CurTeaBagList[_i]
		var _Name = "TexNode/ItemNode/" + str(_i + 1)
		if has_node(_Name):
			_TEAOBJ.get_parent().remove_child(_TEAOBJ)
			get_node(_Name).add_child(_TEAOBJ)
	_CanMove_Check()


func call_PickEnd_Logic(_Player):
	for _i in CurTeaBagList.size():
		var _TEAOBJ = CurTeaBagList[_i]
		var _Name = "TexNode/ItemNode/" + str(_i + 1)
		if has_node(_Name):
			_TEAOBJ.get_parent().remove_child(_TEAOBJ)
			get_node(_Name).add_child(_TEAOBJ)
	_CanMove_Check()
	But_Switch(true, _Player)

func call_Pick(_Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if CurTeaBagList.size() > 0:
		var _OBJ = CurTeaBagList.front()

		GameLogic.Device.call_Player_Pick(_Player, _OBJ)

		return true
func call_Put_puppet(_PLAYERPATH, _OBJPATH, _NUM):
	var _Player = get_node(_PLAYERPATH)
	var _OBJ = get_node(_OBJPATH)
	_OBJ.get_parent().remove_child(_OBJ)
	_Player.Stat.call_carry_off()
	match _NUM:
		0:
			get_node("TexNode/ItemNode/1").add_child(_OBJ)
			CurTeaBagList.append(_OBJ)
		1:
			get_node("TexNode/ItemNode/2").add_child(_OBJ)
			CurTeaBagList.append(_OBJ)
		2:
			get_node("TexNode/ItemNode/3").add_child(_OBJ)
			CurTeaBagList.append(_OBJ)
		3:
			get_node("TexNode/ItemNode/4").add_child(_OBJ)
			CurTeaBagList.append(_OBJ)
	_CanMove_Check()
func call_Put(_But, _OBJ, _Player):
	match _But:
		- 1:
			But_Switch(true, _Player)
		0:
			if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
				return
			if CurTeaBagList.size() < 4:
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _PLAYERPATH = _Player.get_path()
					var _OBJPATH = _OBJ.get_path()
					SteamLogic.call_puppet_id_sync(_SELFID, "call_Put_puppet", [_PLAYERPATH, _OBJPATH, CurTeaBagList.size()])
				_OBJ.get_parent().remove_child(_OBJ)
				_Player.Stat.call_carry_off()
				match CurTeaBagList.size():
					0:
						get_node("TexNode/ItemNode/1").add_child(_OBJ)
						CurTeaBagList.append(_OBJ)
					1:
						get_node("TexNode/ItemNode/2").add_child(_OBJ)
						CurTeaBagList.append(_OBJ)
					2:
						get_node("TexNode/ItemNode/3").add_child(_OBJ)
						CurTeaBagList.append(_OBJ)
					3:
						get_node("TexNode/ItemNode/4").add_child(_OBJ)
						CurTeaBagList.append(_OBJ)
				_CanMove_Check()
				But_Switch(true, _Player)
				return true

func return_Make_TeaBag(_But, _Player):
	match _But:
		- 1:
			But_Switch(true, _Player)
		0:
			return call_Pick(_Player)
		3:
			if CurGram >= 50 and CurTeaBagList.size() < 4:
				_Make_TeaBag()
				return "打包"
			else:
				call_SHAKE_end(_Player)
func call_Make_TeaBag_puppet(_NAME, _NUM, _TYPE):
	var _ExtraObj = GameLogic.TSCNLoad.Bag_TSCN.instance()
	_ExtraObj._SELFID = int(_NAME)
	_ExtraObj.name = _NAME
	match _NUM:
		0:
			get_node("TexNode/ItemNode/1").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
		1:
			get_node("TexNode/ItemNode/2").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
		2:
			get_node("TexNode/ItemNode/3").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
		3:
			get_node("TexNode/ItemNode/4").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
	if _TYPE != "":
		_ExtraObj.call_load_TSCN(_TYPE)
	CurGram = 0
	CurType = ""
	_TeaAni()
	_CanMove_Check()
	call_Num_init()
func _Make_TeaBag():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _TYPE: String
	match CurType:
		"wolfberry":
			_TYPE = "枸杞茶包"
		"flower":
			_TYPE = "花茶包"
		"oolong":
			_TYPE = "乌龙茶包"
		"green":
			_TYPE = "绿茶包"
		"red":
			_TYPE = "红茶包"
		"white":
			_TYPE = "白茶包"
	var _ExtraObj = GameLogic.TSCNLoad.Bag_TSCN.instance()
	_ExtraObj._SELFID = _ExtraObj.get_instance_id()
	var _NAME = str(_ExtraObj._SELFID)

	_ExtraObj.name = _NAME
	var _NUM = CurTeaBagList.size()
	match _NUM:
		0:
			get_node("TexNode/ItemNode/1").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
		1:
			get_node("TexNode/ItemNode/2").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
		2:
			get_node("TexNode/ItemNode/3").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
		3:
			get_node("TexNode/ItemNode/4").add_child(_ExtraObj)
			CurTeaBagList.append(_ExtraObj)
	if _TYPE != "":
		_ExtraObj.call_load_TSCN(_TYPE)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_Make_TeaBag_puppet", [_NAME, _NUM, _TYPE])
	CurGram = 0
	CurType = ""
	_TeaAni()
	call_ButShow()
	_CanMove_Check()
	call_Num_init()
	var _AUDIO_CUT = GameLogic.Audio.return_Effect("放下包")
	_AUDIO_CUT.play(0)

func _Type_Logic(_TYPE):

	CurType = _TYPE
	if TeaTypeANI.has_animation(_TYPE):
		TeaTypeANI.play(_TYPE)
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "_Type_Logic", [_TYPE])

func _ADD_Logic(_OBJ):
	CurType = _OBJ.FuncTypePara
	_LastType = CurType
	_OBJ.GRAMOBJ = self
	ADDOBJ = _OBJ
	ADDANI.play("add")
func _Add_Gram():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if CurType == "":
		CurType = _LastType
	_Type_Logic(CurType)
	if ADDOBJ.CurGram > 0:
		ADDOBJ.AddGram()
		CurGram += 1
		call_Gram_Show()
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_AddGram_puppet", [CurGram, CurType])
func call_AddGram_puppet(_GRAMNUM, _TYPE):
	CurType = _TYPE
	CurGram = _GRAMNUM
	call_Gram_Show()
func call_Gram_Show():
	get_node("TexNode/HBox/2").call_init(3, CurGram % 10 + 2, 1)
	if CurGram >= 10:
		if CurGram < 20:
			get_node("TexNode/HBox/1").call_init(3, 3, 1)
		else:
			get_node("TexNode/HBox/1").call_init(3, int(float(CurGram) / 10) % 10 + 2, 1)
	else:
		get_node("TexNode/HBox/1").call_init(3, 0, 1)
	if CurGram >= 100:
		if CurGram < 200:
			get_node("TexNode/HBox/0").call_init(3, 3, 1)
		else:
			get_node("TexNode/HBox/0").call_init(3, int(float(CurGram) / 100) % 10 + 2, 1)
	else:
		get_node("TexNode/HBox/0").call_init(3, 0, 1)
	if is_instance_valid(ADDOBJ):
		var _x = ADDOBJ.CurGram
		if ADDOBJ.CurGram == 0:
			ADDOBJ.call_used()
			ADDANI.play("init")

	_TeaAni()
	call_ButShow()
func _TeaAni():
	if CurGram == 0:
		TeaANI.play("0")
	elif CurGram > 0 and CurGram < 50:
		TeaANI.play("1")
	elif CurGram >= 50 and CurGram <= 150:
		TeaANI.play("2")
	else:
		TeaANI.play("3")
func return_SHAKE(_Player):
	if CanADD:
		if is_instance_valid(_ADDPLAYER):
			if _ADDPLAYER != _Player:
				return
		_ADDPLAYER = _Player
		ADDANI.play("init")
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_SHAKE_start", [_PLAYERPATH])
		return true
	return false
func call_puppet_SHAKE_start(_PLAYERPATH):
	var _Player = get_node(_PLAYERPATH)
	_ADDPLAYER = _Player

	_Player.Con.call_SHAKE()
func call_SHAKE_end(_Player):

	if _ADDPLAYER == _Player:
		_ADDPLAYER = null
		_Player.call_reset_stat()
		ADDANI.stop(true)

		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _PATH = _Player.get_path()
			SteamLogic.call_puppet_id_sync(_SELFID, "call_puppet_STIR_end", [_PATH])
func call_puppet_STIR_end(_PATH):
	var _Player = get_node(_PATH)
	_Player.call_reset_stat()
	ADDANI.stop(true)
func _on_body_entered(body):
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body):
	GameLogic.Device.call_touch(body, self, false)
