extends Head_Object

var Used: bool
var _ReadyStr: String
onready var typeAni = get_node("AniNode/typeAni")
onready var HoldBut = get_node("Hold")
onready var HoldY_But = HoldBut.get_node("Y")
onready var FreshAni = $Effect_flies / Ani
var Freshless_bool: bool
var IsPassDay: bool
var Is_Storage: bool
var IsOpen: bool = false
var CurGram: int
var GRAMOBJ

func call_AddGram_puppet(_GRAMNUM):
	CurGram = _GRAMNUM
	if not IsOpen:
		IsOpen = true
	call_Gram_Show()
func AddGram():
	if CurGram > 0:
		CurGram -= 1
		if not IsOpen:
			IsOpen = true
		if SteamLogic.IsMultiplay:
			SteamLogic.call_puppet_id_sync(_SELFID, "call_AddGram_puppet", [CurGram])
	call_Gram_Show()
func call_Gram_Show():
	if IsOpen:
		if CurGram <= 0:
			$Label.hide()
			return
		$Label.show()
		$Label.text = str(CurGram) + "g"
	else:
		$Label.hide()
func call_SHAKE_end(_Player):

	if is_instance_valid(GRAMOBJ):
		GRAMOBJ.call_SHAKE_end(_Player)
func call_Freezer_Switch(_Switch):
	Is_Storage = _Switch
func But_Hold(_Player):

	if not is_instance_valid(get_parent()):
		return
	if get_parent().name == "Weapon_note":
		HoldY_But.show_player(_Player.cur_Player)
		HoldBut.show()
	else:
		HoldBut.hide()
		HoldY_But.call_clean()
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			if has_node("AniNode/OutLineAni"):
				get_node("AniNode/OutLineAni").play("show")

		false:
			if has_node("AniNode/OutLineAni"):
				get_node("AniNode/OutLineAni").play("init")
	pass
func call_Broken():
	var _FreshBool: bool

	match FreshType:
		1:

			_FreshBool = true
		2, 3:
			if not Is_Storage:
				_FreshBool = true
		4:
			Freshless_bool = true

	if _FreshBool:
		if IsPassDay and not Freshless_bool:
			Freshless_bool = true
		elif not IsPassDay:
			IsPassDay = true
	_freshless_logic()
func call_used_puppet():
	Used = true
	CarrySpeed = 1
	call_bag_tex_set()
	if FuncType in ["Sugar", "Choco", "FreeSugar", "Pot"]:

		GameLogic.Tutorial.call_DropInTrashbin(true)
	_freshless_logic()
func call_used():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_id_sync(_SELFID, "call_used_puppet")

	Used = true
	CarrySpeed = 1
	call_bag_tex_set()
	if FuncType in ["Sugar", "Choco", "FreeSugar", "Pot"]:

		GameLogic.Tutorial.call_DropInTrashbin(true)
	_freshless_logic()
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.Con.IsHold:

		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
	else:
		var A_But = get_node("But/A")
		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)
	.But_Switch(_bool, _Player)

func _ready() -> void :
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	IsItem = true
	if not GameLogic.is_connected("CloseLight", self, "_DayClosedCheck"):
		var _con = GameLogic.connect("CloseLight", self, "_DayClosedCheck")
func _DayClosedCheck():
	if not self.is_inside_tree():
		return
	if get_parent().name == "Items":
		if not GameLogic.WrongInfo.has(GameLogic.WRONGTYPE.ITEM):
			GameLogic.WrongInfo.append(GameLogic.WRONGTYPE.ITEM)

	call_Broken()
func _typeAni_set():

	if has_node("AniNode/typeAni"):
		typeAni = get_node("AniNode/typeAni")


func call_load_TSCN(_TSCN):
	call_init(_TSCN)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()
func _freshless_logic():
	if Used:
		FreshAni.play("init")
	else:
		if Freshless_bool:
			FreshAni.play("Flies")
		elif IsPassDay:
			FreshAni.play("OverDay")
		else:
			FreshAni.play("init")
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	if not TypeStr:
		call_init(_Info.TSCN)

	if _Info.has("IsOpen"):
		IsOpen = _Info.IsOpen

	if _Info.has("Used"):
		Used = _Info.Used
		if Used:
			CarrySpeed = 1
	if _Info.has("CurGram"):
		CurGram = _Info.CurGram
		if CurGram <= 0:
			Used = true
	if _Info.has("Is_Storage"):
		Is_Storage = _Info.Is_Storage
	if _Info.has("Freshless_bool"):
		Freshless_bool = _Info.Freshless_bool
	if _Info.has("IsPassDay"):
		IsPassDay = _Info.IsPassDay
	_freshless_logic()

	call_bag_tex_set()

func call_bag_tex_set():

	IsItem = true

	if typeAni:
		if Used:
			var _UsedAni = FuncType + "_empty"

			if typeAni.has_animation(_UsedAni):

				typeAni.play(_UsedAni)
			else:
				print("TypeStr Used = ", TypeStr)
				_UsedAni = TypeStr + "_empty"
				if typeAni.has_animation(_UsedAni):
					typeAni.play(_UsedAni)
				else:
					match TypeStr:
						"芝士":
							_UsedAni = "bag_cheeze_empty"
						"黑糖水":
							_UsedAni = "黑糖_empty"
						"白糖水":
							_UsedAni = "白糖_empty"
					if typeAni.has_animation(_UsedAni):
						typeAni.play(_UsedAni)
					elif typeAni.has_animation(TypeStr):
						typeAni.play(TypeStr)
		elif typeAni.has_animation(TypeStr):
			typeAni.play(TypeStr)

		else:
			print("TypeStr = ", TypeStr)
	if FuncType == "Box":
		Weight = 5
	else:
		Weight = 1
	if not IsOpen:
		CurGram = 200
	call_Gram_Show()

func call_broken():
	Freshless_bool = true
	Used = true
	call_bag_tex_set()
	_freshless_logic()
func _on_body_entered(body: Node) -> void :
	if not IsOpen and not Used and not Freshless_bool:
		var _BOOL = return_MoneyBool(body)
		if _BOOL:
			call_broken()
	GameLogic.Device.call_touch(body, self, true)

func _on_body_exited(body: Node) -> void :
	GameLogic.Device.call_touch(body, self, false)
