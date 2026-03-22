extends Control

export var ZINDEX: int = 1
var playerList: Array
var cur_But: String
export var ButSetting: bool
export var ButPlayer: int
export var KeyBoard: bool
export var IsKeyBoard: bool
export var bool_Hold: bool
export var bool_Small: bool
export var bool_Static: bool
export var BUT: int
export var BUT_TYPE: int
export var RE: int

var _CONDIC = {
	"1PKEY": {"BUT": 0, "TYPE": 0, "RE": 0},
	"1PJOY": {"BUT": 0, "TYPE": 0, "RE": 0},
	"2PKEY": {"BUT": 0, "TYPE": 0, "RE": 0},
	"2PJOY": {"BUT": 0, "TYPE": 0, "RE": 0},
}

export var Info_Str: String
export var Info_1: String
export var Info_2: String
export var OnBut: bool = true
export var TopInfo: String
signal HoldFinish()

onready var ShowAni = get_node("ShowEnd")

onready var IdleAni = get_node("Idle")
onready var InfoLabel = get_node("Texture/InfoLabel")

onready var DisabledAni = get_node("DisabledAni")
onready var TopLabel = get_node("Texture/TopLabel")
func call_OutLine(_Switch: bool):

	match _Switch:
		true:
			if has_node("OutLineAni"):
				get_node("OutLineAni").play("show")
		false:
			if has_node("OutLineAni"):
				get_node("OutLineAni").play("init")

func _ready() -> void :
	if ButSetting:
		var _LoadTSCN = load("res://TscnAndGd/Buttons/WaitingLabel.tscn")
		var _TSCN = _LoadTSCN.instance()
		_TSCN._set_position(Vector2( - 128, - 40))
		_TSCN.set_pivot_offset(Vector2(128, 40))
		add_child(_TSCN)
		_LoadTSCN = null
	if not cur_But:
		cur_But = self.name
	if not GameLogic.is_connected("OPTIONSYNC", self, "_Tr_Set"):
		var _con = GameLogic.connect("OPTIONSYNC", self, "_Tr_Set")

	get_node("Texture").z_index = ZINDEX
	call_deferred("call_init")
func _Tr_Set():
	call_init()
	InfoLabel.text = GameLogic.CardTrans.get_message(Info_Str)
	call_waiting(false)
func _Conncet():
	if ButSetting:
		pass
	if not ButSetting:
		if not GameLogic.Con.is_connected("P1_Control", self, "_But_Show_1P"):
			GameLogic.Con.connect("P1_Control", self, "_But_Show_1P")
		if not GameLogic.Con.is_connected("P2_Control", self, "_But_Show_2P"):
			GameLogic.Con.connect("P2_Control", self, "_But_Show_2P")

func _But_Show_1P(_But, _value, _type):
	if not is_visible_in_tree():
		return

	if IsKeyBoard and GameLogic.Con.player1P_IsJoy:
		show_logic(1)
	elif not IsKeyBoard and not GameLogic.Con.player1P_IsJoy:
		show_logic(1)
func _But_Show_2P(_But, _value, _type):
	if not is_visible_in_tree():
		return

	if IsKeyBoard and GameLogic.Con.player2P_IsJoy:
		show_logic(2)
	elif not IsKeyBoard and not GameLogic.Con.player2P_IsJoy:
		show_logic(2)

func call_disabled(_bool):
	match _bool:
		true:
			DisabledAni.play("disabled")
			GameLogic.Audio.But_Hold.stop()
		false:
			DisabledAni.play("init")
			GameLogic.Audio.But_Hold.stop()

func call_init():
	call_ButShow_init()


	if bool_Hold:
		if bool_Static:
			ShowAni.play("Hold_Init")
	else:
		if bool_Static:
			ShowAni.play("Press_Init")
		else:
			ShowAni.play("init")
			GameLogic.Audio.But_Hold.stop()
	if OnBut:
		if not get_parent().visible:
			self.hide()
		else:
			self.show()
	if Info_Str:
		InfoLabel.text = GameLogic.CardTrans.get_message(Info_Str)
		InfoLabel.show()
	else:
		InfoLabel.hide()
	_Conncet()

func call_ButShow_init():
	if ButSetting:

		return


	var _NAME = cur_But
	match cur_But:
		"UP":
			_NAME = "up"
		"DOWN":
			_NAME = "down"
		"LEFT", "L":
			_NAME = "left"
		"RIGHT", "R":
			_NAME = "right"
		"START":
			_NAME = "Start"
	var _PONE = "P1_" + _NAME
	var _PTWO = "P2_" + _NAME
	_CONDIC["1PJOY"]["BUT"] = GameLogic.GlobalData.joyini[_PONE].BUT
	_CONDIC["1PJOY"]["TYPE"] = GameLogic.GlobalData.joyini[_PONE].TYPE
	_CONDIC["1PJOY"]["RE"] = GameLogic.GlobalData.joyini[_PONE].RE
	_CONDIC["2PJOY"]["BUT"] = GameLogic.GlobalData.joyini[_PTWO].BUT
	_CONDIC["2PJOY"]["TYPE"] = GameLogic.GlobalData.joyini[_PTWO].TYPE
	_CONDIC["2PJOY"]["RE"] = GameLogic.GlobalData.joyini[_PTWO].RE
	_CONDIC["1PKEY"]["BUT"] = GameLogic.GlobalData.keyboardini[_PONE].BUT
	_CONDIC["1PKEY"]["TYPE"] = GameLogic.GlobalData.keyboardini[_PONE].TYPE
	_CONDIC["1PKEY"]["RE"] = GameLogic.GlobalData.keyboardini[_PONE].RE
	_CONDIC["2PKEY"]["BUT"] = GameLogic.GlobalData.keyboardini[_PTWO].BUT
	_CONDIC["2PKEY"]["TYPE"] = GameLogic.GlobalData.keyboardini[_PTWO].TYPE
	_CONDIC["2PKEY"]["RE"] = GameLogic.GlobalData.keyboardini[_PTWO].RE
	_ButAni_init(1, _CONDIC["1PKEY"]["BUT"], _CONDIC["1PKEY"]["TYPE"], _CONDIC["1PKEY"]["RE"], false)
	_ButAni_init(1, _CONDIC["2PKEY"]["BUT"], _CONDIC["2PKEY"]["TYPE"], _CONDIC["2PKEY"]["RE"], true)

	_ButAni_init(2, _CONDIC["1PJOY"]["BUT"], _CONDIC["1PJOY"]["TYPE"], _CONDIC["1PJOY"]["RE"], false)
	_ButAni_init(2, _CONDIC["2PJOY"]["BUT"], _CONDIC["2PJOY"]["TYPE"], _CONDIC["2PJOY"]["RE"], true)

func call_ButShow(_P1Bool: bool, _JoyBool: bool):
	if _P1Bool:
		if _JoyBool:
			$Texture / Button.hide()
			$Texture / Joy.show()
			$Texture / SButton.hide()
			$Texture / SJoy.hide()
			$Texture / Key.hide()
		else:
			$Texture / Button.show()
			$Texture / Joy.hide()
			$Texture / SButton.hide()
			$Texture / SJoy.hide()
			$Texture / Key.show()
	else:
		if _JoyBool:
			$Texture / Button.hide()
			$Texture / Joy.hide()
			$Texture / SButton.hide()
			$Texture / SJoy.show()
			$Texture / Key.hide()
		else:
			$Texture / Button.hide()
			$Texture / Joy.hide()
			$Texture / SButton.show()
			$Texture / SJoy.hide()
			$Texture / Key.show()

func _ButAni_init(_TYPE, _BUT, _BUTTYPE, _RE, _2PBool: bool = false):

	match _TYPE:
		1:
			var ButTypeAni = $Texture / Button / ButtonType
			var Key_Label = $Texture / Key
			var P2TypeAni = $Texture / SButton / KeyType
			var P2Key = $Texture / SButton / Key
			match _BUT:
				KEY_ESCAPE:
					if _2PBool:
						P2TypeAni.play("Esc")
						P2Key.hide()
					else:
						ButTypeAni.play("Esc")
						Key_Label.hide()
				KEY_TAB:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Tab"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Tab"
						Key_Label.show()
				KEY_BACKTAB:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "B-T"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "B-T"
						Key_Label.show()
				KEY_BACKSPACE:
					if _2PBool:
						P2TypeAni.play("Backspace")
						P2Key.hide()
					else:
						ButTypeAni.play("Backspace")
						Key_Label.hide()
				KEY_ENTER:
					if _2PBool:
						P2TypeAni.play("Enter")
						P2Key.hide()
					else:
						ButTypeAni.play("Enter")
						Key_Label.hide()
				KEY_KP_ENTER:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "KP_En"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "KP_En"
						Key_Label.show()
				KEY_INSERT:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Ins"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Ins"
						Key_Label.show()
				KEY_DELETE:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Del"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Del"
						Key_Label.show()
				KEY_PAUSE:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Pause"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Pause"
						Key_Label.show()
				KEY_PRINT:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Pri"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Pri"
						Key_Label.show()
				KEY_SYSREQ:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Sys"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Sys"
						Key_Label.show()
				KEY_CLEAR:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Cle"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Cle"
						Key_Label.show()
				KEY_HOME:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Home"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Home"
						Key_Label.show()
				KEY_END:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "End"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "End"
						Key_Label.show()
				KEY_LEFT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "←"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "←"
						Key_Label.show()
				KEY_UP:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "↑"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "↑"
						Key_Label.show()
				KEY_RIGHT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "→"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "→"
						Key_Label.show()
				KEY_DOWN:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "↓"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "↓"
						Key_Label.show()
				KEY_PAGEUP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Pg Up"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Pg Up"
						Key_Label.show()
				KEY_PAGEDOWN:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Pg Dn"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Pg Dn"
						Key_Label.show()
				KEY_SHIFT:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Shift"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Shift"
						Key_Label.show()
				KEY_CONTROL:
					if _2PBool:
						P2TypeAni.play("Ctrl")
						P2Key.hide()
					else:
						ButTypeAni.play("Ctrl")
						Key_Label.hide()
				KEY_META:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Meta"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Meta"
						Key_Label.show()
				KEY_ALT:
					if _2PBool:
						P2TypeAni.play("Alt")
						P2Key.hide()
					else:
						ButTypeAni.play("Alt")
						Key_Label.hide()
				KEY_CAPSLOCK:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Caps"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Caps"
						Key_Label.show()
				KEY_NUMLOCK:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "NumL"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "NumL"
						Key_Label.show()
				KEY_SCROLLLOCK:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "ScrL"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "ScrL"
						Key_Label.show()
				KEY_F1:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F1"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F1"
						Key_Label.show()
				KEY_F2:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F2"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F2"
						Key_Label.show()
				KEY_F3:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F3"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F3"
						Key_Label.show()
				KEY_F4:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F4"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F4"
						Key_Label.show()
				KEY_F5:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F5"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F5"
						Key_Label.show()
				KEY_F6:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F6"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F6"
						Key_Label.show()
				KEY_F7:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F7"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F7"
						Key_Label.show()
				KEY_F8:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F8"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F8"
						Key_Label.show()
				KEY_F9:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F9"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F9"
						Key_Label.show()
				KEY_F10:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F10"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "F10"
						Key_Label.show()

				KEY_F11:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F11"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F11"
						Key_Label.show()
				KEY_F12:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F12"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F12"
						Key_Label.show()
				KEY_F13:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F13"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F13"
						Key_Label.show()
				KEY_F14:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F14"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "F14"
						Key_Label.show()
				KEY_F15:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F15"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "F15"
						Key_Label.show()
				KEY_F16:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F16"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "F16"
						Key_Label.show()
				KEY_KP_MULTIPLY:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_*"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_*"
						Key_Label.show()

				KEY_KP_DIVIDE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_/"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_/"
						Key_Label.show()

				KEY_KP_SUBTRACT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_-"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_-"
						Key_Label.show()

				KEY_KP_PERIOD:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_."
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_."
						Key_Label.show()

				KEY_KP_ADD:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_+"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_+"
						Key_Label.show()

				KEY_KP_0:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_0"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_0"
						Key_Label.show()

				KEY_KP_1:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_1"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_1"
						Key_Label.show()

				KEY_KP_2:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_2"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_2"
						Key_Label.show()

				KEY_KP_3:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_3"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_3"
						Key_Label.show()

				KEY_KP_4:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_4"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_4"
						Key_Label.show()

				KEY_KP_5:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_5"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_5"
						Key_Label.show()

				KEY_KP_6:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_6"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_6"
						Key_Label.show()

				KEY_KP_7:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_7"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_7"
						Key_Label.show()

				KEY_KP_8:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_8"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_8"
						Key_Label.show()

				KEY_KP_9:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "KP_9"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "KP_9"
						Key_Label.show()

				KEY_SUPER_L:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "SupL"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "SupL"
						Key_Label.show()
				KEY_SUPER_R:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "SupR"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "SupR"
						Key_Label.show()
				KEY_MENU:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Menu"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Menu"
						Key_Label.show()
				KEY_HYPER_L:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "HypL"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "HypL"
						Key_Label.show()
				KEY_HYPER_R:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "HypR"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "HypR"
						Key_Label.show()
				KEY_HELP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "help"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "help"
						Key_Label.show()
				KEY_DIRECTION_L:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "DirL"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "DirL"
						Key_Label.show()
				KEY_DIRECTION_R:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "DirR"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "DirR"
						Key_Label.show()
				KEY_BACK:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Back"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Back"
						Key_Label.show()
				KEY_FORWARD:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "ForW"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "ForW"
						Key_Label.show()
				KEY_STOP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Stop"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Stop"
						Key_Label.show()
				KEY_REFRESH:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Ref"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Ref"
						Key_Label.show()
				KEY_VOLUMEDOWN:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "VolD"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "VolD"
						Key_Label.show()
				KEY_VOLUMEMUTE:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "VolM"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "VolM"
						Key_Label.show()
				KEY_VOLUMEUP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "VolU"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "VolU"
						Key_Label.show()
				KEY_BASSBOOST:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Boost"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Boost"
						Key_Label.show()
				KEY_BASSUP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "BasU"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "BasU"
						Key_Label.show()
				KEY_BASSDOWN:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "BasD"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "BasD"
						Key_Label.show()
				KEY_TREBLEUP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "TreU"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "TreU"
						Key_Label.show()
				KEY_TREBLEDOWN:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "TreD"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "TreD"
						Key_Label.show()
				KEY_MEDIAPLAY:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "MedP"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "MedP"
						Key_Label.show()
				KEY_MEDIASTOP:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "MedS"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "MedS"
						Key_Label.show()
				KEY_MEDIAPREVIOUS:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "MedPr"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "MedPr"
						Key_Label.show()
				KEY_MEDIANEXT:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "MedN"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "MedN"
						Key_Label.show()
				KEY_MEDIARECORD:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "MedRe"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "MedRe"
						Key_Label.show()
				KEY_HOMEPAGE:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Ho Pa"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Ho Pa"
						Key_Label.show()
				KEY_FAVORITES:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Fav"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Fav"
						Key_Label.show()
				KEY_SEARCH:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Sear"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Sear"
						Key_Label.show()
				KEY_STANDBY:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "St By"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "St By"
						Key_Label.show()
				KEY_OPENURL:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "URL"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "URL"
						Key_Label.show()
				KEY_LAUNCHMAIL:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La Ma"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La Ma"
						Key_Label.show()
				KEY_LAUNCHMEDIA:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La Me"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La Me"
						Key_Label.show()
				KEY_LAUNCH0:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 0"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 0"
						Key_Label.show()
				KEY_LAUNCH1:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 1"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 1"
						Key_Label.show()
				KEY_LAUNCH2:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 2"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 2"
						Key_Label.show()
				KEY_LAUNCH3:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 3"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 3"
						Key_Label.show()
				KEY_LAUNCH4:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 4"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 4"
						Key_Label.show()
				KEY_LAUNCH5:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 0"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 5"
						Key_Label.show()
				KEY_LAUNCH6:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 0"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 6"
						Key_Label.show()
				KEY_LAUNCH7:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 7"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 7"
						Key_Label.show()
				KEY_LAUNCH8:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 8"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 8"
						Key_Label.show()
				KEY_LAUNCH9:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La 9"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La 9"
						Key_Label.show()
				KEY_LAUNCHA:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La A"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La A"
						Key_Label.show()
				KEY_LAUNCHB:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La B"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La B"
						Key_Label.show()
				KEY_LAUNCHC:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La C"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La C"
						Key_Label.show()
				KEY_LAUNCHD:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La D"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La D"
						Key_Label.show()
				KEY_LAUNCHE:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "La E"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La E"
						Key_Label.show()
				KEY_LAUNCHF:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "LaF"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "La F"
						Key_Label.show()
				KEY_UNKNOWN:
					if _2PBool:
						P2TypeAni.play("Key_L")
						P2Key.text = "Unknown"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Unknown"
						Key_Label.show()
				KEY_SPACE:
					if _2PBool:
						P2TypeAni.play("Space")

						P2Key.hide()
					else:
						ButTypeAni.play("Space")
						Key_Label.hide()
				KEY_EXCLAM:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "!"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "!"
						Key_Label.show()
				KEY_QUOTEDBL:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "”"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "”"
						Key_Label.show()
				KEY_NUMBERSIGN:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "#"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "#"
						Key_Label.show()
				KEY_DOLLAR:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "$"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "$"
						Key_Label.show()
				KEY_PERCENT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "%"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "%"
						Key_Label.show()
				KEY_AMPERSAND:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "&"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "&"
						Key_Label.show()
				KEY_APOSTROPHE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "'"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "'"
						Key_Label.show()
				KEY_PARENLEFT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "("
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "("
						Key_Label.show()
				KEY_PARENRIGHT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = ")"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = ")"
						Key_Label.show()
				KEY_ASTERISK:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "*"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "*"
						Key_Label.show()
				KEY_PLUS:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "+"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "+"
						Key_Label.show()
				KEY_COMMA:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = ","
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = ","
						Key_Label.show()
				KEY_MINUS:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "-"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "-"
						Key_Label.show()
				KEY_PERIOD:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "."
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "."
						Key_Label.show()
				KEY_SLASH:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "/"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "/"
						Key_Label.show()
				KEY_0:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "0"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "0"
						Key_Label.show()
				KEY_1:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "1"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "1"
						Key_Label.show()
				KEY_2:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "2"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "2"
						Key_Label.show()
				KEY_3:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "3"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "3"
						Key_Label.show()
				KEY_4:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "4"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "4"
						Key_Label.show()
				KEY_5:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "5"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "5"
						Key_Label.show()
				KEY_6:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "6"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "6"
						Key_Label.show()
				KEY_7:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "7"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "7"
						Key_Label.show()
				KEY_8:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "8"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "8"
						Key_Label.show()
				KEY_9:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "9"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "9"
						Key_Label.show()
				KEY_COLON:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = ":"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = ":"
						Key_Label.show()
				KEY_SEMICOLON:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = ";"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = ";"
						Key_Label.show()
				KEY_LESS:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "<"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "<"
						Key_Label.show()
				KEY_EQUAL:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "="
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "="
						Key_Label.show()
				KEY_GREATER:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = ">"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = ">"
						Key_Label.show()
				KEY_QUESTION:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "QUEST"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "QUEST"
						Key_Label.show()
				KEY_AT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "@"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "@"
						Key_Label.show()
				KEY_A:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "A"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "A"
						Key_Label.show()
				KEY_B:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "B"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "B"
						Key_Label.show()
				KEY_C:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "C"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "C"
						Key_Label.show()
				KEY_D:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "D"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "D"
						Key_Label.show()
				KEY_E:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "E"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "E"
						Key_Label.show()
				KEY_F:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "F"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "F"
						Key_Label.show()
				KEY_G:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "G"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "G"
						Key_Label.show()
				KEY_H:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "H"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "H"
						Key_Label.show()
				KEY_I:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "I"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "I"
						Key_Label.show()
				KEY_J:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "J"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "J"
						Key_Label.show()
				KEY_K:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "K"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "K"
						Key_Label.show()
				KEY_L:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "L"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "L"
						Key_Label.show()
				KEY_M:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "M"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "M"
						Key_Label.show()
				KEY_N:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "N"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "N"
						Key_Label.show()
				KEY_O:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "O"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "O"
						Key_Label.show()
				KEY_P:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "P"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "P"
						Key_Label.show()
				KEY_Q:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Q"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "Q"
						Key_Label.show()
				KEY_R:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "R"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "R"
						Key_Label.show()
				KEY_S:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "S"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "S"
						Key_Label.show()
				KEY_T:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "T"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "T"
						Key_Label.show()
				KEY_U:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "U"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "U"
						Key_Label.show()
				KEY_V:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "V"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "V"
						Key_Label.show()
				KEY_W:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "W"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "W"
						Key_Label.show()
				KEY_X:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "X"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "X"
						Key_Label.show()
				KEY_Y:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Y"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "Y"
						Key_Label.show()
				KEY_Z:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Z"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "Z"
						Key_Label.show()
				KEY_BRACKETLEFT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "["
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "["
						Key_Label.show()
				KEY_BACKSLASH:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "|"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "|"
						Key_Label.show()
				KEY_BRACKETRIGHT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "]"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "]"
						Key_Label.show()
				KEY_ASCIICIRCUM:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "^"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "^"
						Key_Label.show()
				KEY_UNDERSCORE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "_"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "_"
						Key_Label.show()
				KEY_QUOTELEFT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "`"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "`"
						Key_Label.show()
				KEY_BRACELEFT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "{"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "{"
						Key_Label.show()
				KEY_BAR:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "|"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "|"
						Key_Label.show()
				KEY_BRACERIGHT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "A"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "}"
						Key_Label.show()
				KEY_ASCIITILDE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "~"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "~"
						Key_Label.show()
				KEY_NOBREAKSPACE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "NBS"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "NBS"
						Key_Label.show()
				KEY_EXCLAMDOWN:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "?"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "?"
						Key_Label.show()
				KEY_CENT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "￠"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "￠"
						Key_Label.show()
				KEY_STERLING:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "￡"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "￡"
						Key_Label.show()
				KEY_CURRENCY:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "¤"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "¤"
						Key_Label.show()
				KEY_YEN:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "￥"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "￥"
						Key_Label.show()
				KEY_BROKENBAR:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "|"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "|"
						Key_Label.show()
				KEY_SECTION:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "§"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "§"
						Key_Label.show()
				KEY_DIAERESIS:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "¨"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "¨"
						Key_Label.show()
				KEY_COPYRIGHT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "?"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "?"
						Key_Label.show()
				KEY_ORDFEMININE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "a"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "a"
						Key_Label.show()
				KEY_GUILLEMOTLEFT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Guil"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Guil"
						Key_Label.show()
				KEY_NOTSIGN:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "NotS"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "NotS"
						Key_Label.show()
				KEY_HYPHEN:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Hyph"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Hyph"
						Key_Label.show()
				KEY_REGISTERED:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Regi"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Regi"
						Key_Label.show()
				KEY_MACRON:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "ˉ"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "ˉ"
						Key_Label.show()
				KEY_DEGREE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "°"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "°"
						Key_Label.show()
				KEY_PLUSMINUS:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "±"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "±"
						Key_Label.show()
				KEY_TWOSUPERIOR:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "2"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "2"
						Key_Label.show()
				KEY_THREESUPERIOR:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "3"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "3"
						Key_Label.show()
				KEY_ACUTE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "′"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "′"
						Key_Label.show()
				KEY_MU:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "μ"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "μ"
						Key_Label.show()
				KEY_PARAGRAPH:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "?"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "?"
						Key_Label.show()
				KEY_PERIODCENTERED:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "·"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "·"
						Key_Label.show()
				KEY_CEDILLA:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "Cedi"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "Cedi"
						Key_Label.show()
				KEY_ONESUPERIOR:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "1"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "1"
						Key_Label.show()
				KEY_MASCULINE:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "o"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "o"
						Key_Label.show()
				KEY_GUILLEMOTRIGHT:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "GUIR"
						P2Key.show()
					else:
						ButTypeAni.play("Key_L")
						Key_Label.text = "GUIR"
						Key_Label.show()
				KEY_ONEQUARTER:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = "GUIR"
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = "1Q"
						Key_Label.show()
				_:
					if _2PBool:
						P2TypeAni.play("Key")
						P2Key.text = str(_BUT)
						P2Key.show()
					else:
						ButTypeAni.play("Key")
						Key_Label.text = str(_BUT)
						Key_Label.show()
		2:
			match _BUTTYPE:
				GameLogic.Con.TYPE.AXIS:
					var ButTypeAni = $Texture / Joy / JoyType
					var Key_Label = $Texture / Joy / Key
					var P2TypeAni = $Texture / SJoy / JoyType
					var P2Key = $Texture / SJoy / Key
					P2Key.text = ""
					match _BUT:
						JOY_AXIS_0:
							if _2PBool:
								if _RE == - 1:
									P2TypeAni.play("Axis_L")
								elif _RE == 1:
									P2TypeAni.play("Axis_R")
							else:
								if _RE == - 1:
									ButTypeAni.play("Axis_L")
								elif _RE == 1:
									ButTypeAni.play("Axis_R")
						JOY_AXIS_1:
							if _2PBool:
								if _RE == - 1:
									P2TypeAni.play("Axis_U")
								elif _RE == 1:
									P2TypeAni.play("Axis_D")
							else:
								if _RE == - 1:
									ButTypeAni.play("Axis_U")
								elif _RE == 1:
									ButTypeAni.play("Axis_D")
						JOY_AXIS_2:
							if _2PBool:
								if _RE == - 1:
									P2TypeAni.play("Axis_L")
								elif _RE == 1:
									P2TypeAni.play("Axis_R")
							else:
								if _RE == - 1:
									ButTypeAni.play("Axis_L")
								elif _RE == 1:
									ButTypeAni.play("Axis_R")
						JOY_AXIS_3:
							if _2PBool:
								if _RE == - 1:
									P2TypeAni.play("Axis_U")
								elif _RE == 1:
									P2TypeAni.play("Axis_D")
							else:
								if _RE == - 1:
									ButTypeAni.play("Axis_U")
								elif _RE == 1:
									ButTypeAni.play("Axis_D")
						JOY_AXIS_4:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis 4"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis 4"
								Key_Label.show()
						JOY_AXIS_5:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis 5"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis 5"
								Key_Label.show()




						JOY_AXIS_6:

							if _2PBool:
								P2TypeAni.play("LT")
							else:
								ButTypeAni.play("LT")
						JOY_AXIS_7:
							if _2PBool:
								P2TypeAni.play("RT")
							else:
								ButTypeAni.play("RT")
						JOY_AXIS_8:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis 8"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis 8"
								Key_Label.show()
						JOY_AXIS_9:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis 9"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis 9"
								Key_Label.show()
						JOY_AXIS_MAX:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis Max"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis Max"
								Key_Label.show()
						JOY_ANALOG_LX:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis LX"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis LX"
								Key_Label.show()
						JOY_ANALOG_LY:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis LY"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis LY"
								Key_Label.show()
						JOY_ANALOG_RX:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis RX"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis RX"
								Key_Label.show()
						JOY_ANALOG_RY:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Axis RY"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Axis RY"
								Key_Label.show()
						JOY_ANALOG_L2:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "L2"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "L2"
								Key_Label.show()
						JOY_ANALOG_R2:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "R2"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "R2"
								Key_Label.show()


				GameLogic.Con.TYPE.BUTTON:
					var ButTypeAni = $Texture / Joy / JoyType
					var Key_Label = $Texture / Joy / Key
					var P2TypeAni = $Texture / SJoy / JoyType
					var P2Key = $Texture / SJoy / Key
					P2Key.text = ""

					match _BUT:
















						JOY_XBOX_B:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("B")
									1:
										P2TypeAni.play("圈")
									2:
										P2TypeAni.play("NS_B")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("B")
									1:
										ButTypeAni.play("圈")
									2:
										ButTypeAni.play("NS_B")
						JOY_XBOX_A:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("A")
									1:
										P2TypeAni.play("叉")
									2:
										P2TypeAni.play("NS_A")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("A")
									1:
										ButTypeAni.play("叉")
									2:
										ButTypeAni.play("NS_A")
						JOY_XBOX_X:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("X")
									1:
										P2TypeAni.play("方")
									2:
										P2TypeAni.play("NS_X")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("X")
									1:
										ButTypeAni.play("方")
									2:
										ButTypeAni.play("NS_X")
						JOY_XBOX_Y:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("Y")
									1:
										P2TypeAni.play("三角")
									2:
										P2TypeAni.play("NS_Y")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("Y")
									1:
										ButTypeAni.play("三角")
									2:
										ButTypeAni.play("NS_Y")

						JOY_VR_GRIP:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "GRIP"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "GRIP"
								Key_Label.show()

























						JOY_SELECT:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("Back")
									1:
										P2TypeAni.play("Share")
									2:
										P2TypeAni.play("NS_-")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("Back")
									1:
										ButTypeAni.play("Share")
									2:
										ButTypeAni.play("NS_-")
						JOY_START:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("Start")
									1:
										P2TypeAni.play("Option")
									2:
										P2TypeAni.play("NS_+")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("Start")
									1:
										ButTypeAni.play("Option")
									2:
										ButTypeAni.play("NS_+")

						JOY_DPAD_UP:
							if _2PBool:
								P2TypeAni.play("Dpad_Up")
							else:
								ButTypeAni.play("Dpad_Up")
						JOY_DPAD_DOWN:
							if _2PBool:
								P2TypeAni.play("Dpad_Down")
							else:
								ButTypeAni.play("Dpad_Down")
						JOY_DPAD_LEFT:

							if _2PBool:
								P2TypeAni.play("Dpad_Left")
							else:
								ButTypeAni.play("Dpad_Left")
						JOY_DPAD_RIGHT:
							if _2PBool:
								P2TypeAni.play("Dpad_Right")
							else:
								ButTypeAni.play("Dpad_Right")
						JOY_GUIDE:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Guide"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Guide"
								Key_Label.show()
						JOY_MISC1:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Misc1"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Misc1"
								Key_Label.show()
						JOY_PADDLE1:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Pad 1"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Pad 1"
								Key_Label.show()
						JOY_PADDLE2:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Pad 2"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Pad 2"
								Key_Label.show()
						JOY_PADDLE3:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Pad 3"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Pad 3"
								Key_Label.show()
						JOY_PADDLE4:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Pad 4"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Pad 4"
								Key_Label.show()
						JOY_TOUCHPAD:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = "Touch"
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = "Touch"
								Key_Label.show()
						JOY_L:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("LB")
									1:
										P2TypeAni.play("L1")
									2:
										P2TypeAni.play("NS_L")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("LB")
									1:
										ButTypeAni.play("L1")
									2:
										ButTypeAni.play("NS_L")

						JOY_L2:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("LT")
									1:
										P2TypeAni.play("L2")
									2:
										P2TypeAni.play("NS_ZL")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("LT")
									1:
										ButTypeAni.play("L2")
									2:
										ButTypeAni.play("NS_ZL")

						JOY_L3:
							if _2PBool:
								P2TypeAni.play("Axis_L3")
								P2Key.text = "L"
								P2Key.show()
							else:
								ButTypeAni.play("Axis_L3")
								Key_Label.text = "L"
								Key_Label.show()
						JOY_R:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("RB")
									1:
										P2TypeAni.play("R1")
									2:
										P2TypeAni.play("NS_R")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("RB")
									1:
										ButTypeAni.play("R1")
									2:
										ButTypeAni.play("NS_R")
						JOY_R2:
							if _2PBool:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										P2TypeAni.play("RT")
									1:
										P2TypeAni.play("R2")
									2:
										P2TypeAni.play("NS_ZR")
							else:
								match GameLogic.GlobalData.globalini.ButShow:
									0:
										ButTypeAni.play("RT")
									1:
										ButTypeAni.play("R2")
									2:
										ButTypeAni.play("NS_ZR")
						JOY_R3:
							if _2PBool:
								P2TypeAni.play("Axis_R3")
								P2Key.text = "L"
								P2Key.show()
							else:
								ButTypeAni.play("Axis_R3")
								Key_Label.text = "L"
								Key_Label.show()
						_:
							if _2PBool:
								P2TypeAni.play("But")
								P2Key.text = str(BUT)
								P2Key.show()
							else:
								ButTypeAni.play("But")
								Key_Label.text = str(BUT)
								Key_Label.show()















func call_clean():

	for i in playerList:

		call_player_out(i)
func call_player_in(_playerID):

	if not _playerID in [1, 2, SteamLogic.STEAM_ID]:
		return

	if not playerList.has(_playerID):
		playerList.append(_playerID)

	if _playerID in [1, SteamLogic.STEAM_ID]:
		show_logic(1)
	elif _playerID in [2]:
		show_logic(2)
	call_show()
func call_player_out(_playerID):

	if playerList.has(_playerID):
		playerList.erase(_playerID)
		call_hide()
		call_player_out(_playerID)
func call_player_hide(_playerID):

	if playerList.has(_playerID):
		playerList.erase(_playerID)
		_hide_init()
		call_player_hide(_playerID)
func call_show():

	call_Button_Show()
	if playerList.size() == 1:
		if bool_Hold:
			if not bool_Static:
				ShowAni.play("Hold_Show")
		else:
			if not bool_Static:
				ShowAni.play("Press_Show")
	if TopInfo:
		TopLabel.call_Tr_TEXT(TopInfo)
		TopLabel.show()
	else:
		TopLabel.hide()

func call_hide():

	if not playerList.size():
		if bool_Hold:
			if not bool_Static:
				ShowAni.play_backwards("Hold_Show")
				GameLogic.Audio.But_Hold.stop()
		else:
			if not bool_Static:
				ShowAni.play_backwards("Press_Show")
				GameLogic.Audio.But_Hold.stop()

func _hide_init():

	if not playerList.size():
		if bool_Hold:
			if not bool_Static:
				ShowAni.play("init")
				GameLogic.Audio.But_Hold.stop()
		else:
			if not bool_Static:
				ShowAni.play("init")
				GameLogic.Audio.But_Hold.stop()
func call_holding(_pressed):

	match _pressed:
		true:
			if ShowAni.assigned_animation != "Hold_holding" and ShowAni.assigned_animation != "Hold_end":
				ShowAni.play("Hold_holding")

		false:
			if ShowAni.assigned_animation in ["Hold_holding", "Hold_end"]:
				ShowAni.play("Hold_Init")

func call_holdfinished():
	ShowAni.play("Hold_end")

	emit_signal("HoldFinish")

func show_player(_PlayerID: int):

	playerList.clear()
	playerList.append(_PlayerID)
	show_logic(0)
func show_logic(_PlayerID: int):

	if ButSetting:

		return

	if ButPlayer:
		match ButPlayer:
			1, SteamLogic.STEAM_ID:
				if GameLogic.Con.player1P_Keyboard and not GameLogic.Con.player1P_IsJoy:
					IsKeyBoard = true
					call_ButShow(true, false)

				elif GameLogic.Con.player1P_Joy > - 1:

					IsKeyBoard = false
					call_ButShow(true, true)

			2:

				if KeyBoard:
					IsKeyBoard = true
					call_ButShow(false, false)

					return
				else:
					if GameLogic.Con.player2P_Keyboard and not GameLogic.Con.player2P_IsJoy:
						IsKeyBoard = true
						call_ButShow(false, false)

					elif GameLogic.Con.player2P_Joy > - 1:
						IsKeyBoard = false
						call_ButShow(false, true)

		return
	if playerList.size():

		var _ID = playerList.front()
		match _ID:
			1, SteamLogic.STEAM_ID:

				if GameLogic.Con.player1P_Keyboard and not GameLogic.Con.player1P_IsJoy:

					IsKeyBoard = true
					call_ButShow(true, false)

				elif GameLogic.Con.player1P_Joy > - 1:

					IsKeyBoard = false
					call_ButShow(true, true)

			2:

				if GameLogic.Con.player2P_Keyboard and not GameLogic.Con.player2P_IsJoy:
					IsKeyBoard = true
					call_ButShow(false, false)

				elif GameLogic.Con.player2P_Joy > - 1:
					IsKeyBoard = false
					call_ButShow(false, true)

	else:
		match _PlayerID:
			0, 1, SteamLogic.STEAM_ID:
				if GameLogic.Con.player1P_Keyboard and not GameLogic.Con.player1P_IsJoy:
					IsKeyBoard = true
					call_ButShow(true, false)

				elif GameLogic.Con.player1P_Joy > - 1:
					IsKeyBoard = false
					call_ButShow(true, true)

			2:
				if GameLogic.Con.player2P_Keyboard and not GameLogic.Con.player2P_IsJoy:
					IsKeyBoard = true
					call_ButShow(false, false)

				elif GameLogic.Con.player2P_Joy > - 1:
					IsKeyBoard = false
					call_ButShow(false, true)

func call_but_set(_Joy_bool, _ID):


	var ButTypeAni = get_node("Texture/Button/ButtonType")
	match cur_But:
		"A":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_A"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_A"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_A"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_A"].RE

			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_A"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_A"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_A"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_A"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_A"].RE
		"B":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_B"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_B"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_B"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_B"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_B"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_B"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_B"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_B"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_B"].RE
		"X":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_X"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_X"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_X"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_X"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_X"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_X"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_X"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_X"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_X"].RE

		"Y":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_Y"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_Y"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_Y"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_Y"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_Y"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_Y"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_Y"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_Y"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_Y"].RE
		"L1":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_L1"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_L1"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_L1"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_L1"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_L1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_L1"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_L1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_L1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_L1"].RE

		"R1":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_R1"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_R1"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_R1"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_R1"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_R1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_R1"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_R1"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_R1"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_R1"].RE

		"L2":
			if bool_Small:
				pass
			else:
				ButTypeAni.play("LT")
		"R2":
			if bool_Small:
				pass
			else:
				ButTypeAni.play("RT")
		"UP":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_up"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_up"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_up"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_up"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_up"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_up"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_up"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_up"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_up"].RE
		"DOWN":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_down"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_down"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_down"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_down"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_down"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_down"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_down"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_down"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_down"].RE
		"LEFT", "L":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_left"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_left"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_left"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_left"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_left"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_left"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_left"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_left"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_left"].RE
		"RIGHT", "R":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_right"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_right"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_right"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_right"].RE
			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_right"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_right"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_right"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_right"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_right"].RE
		"START":
			if _Joy_bool:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.joyini["P1_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P1_Start"].TYPE
						RE = GameLogic.GlobalData.joyini["P1_Start"].RE
					2:
						BUT = GameLogic.GlobalData.joyini["P2_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.joyini["P2_Start"].TYPE
						RE = GameLogic.GlobalData.joyini["P2_Start"].RE

			else:
				match _ID:
					1, SteamLogic.STEAM_ID:
						BUT = GameLogic.GlobalData.keyboardini["P1_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P1_Start"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P1_Start"].RE
					2:
						BUT = GameLogic.GlobalData.keyboardini["P2_Start"].BUT
						BUT_TYPE = GameLogic.GlobalData.keyboardini["P2_Start"].TYPE
						RE = GameLogic.GlobalData.keyboardini["P2_Start"].RE
func call_Button_Show(_CONTROLTYPE: int = 0):
	pass

func _on_focus_entered():

	call_OutLine(true)

func _on_focus_exited():
	call_OutLine(false)

func call_waiting(_Switch: bool):
	if has_node("WaitingLabel"):
		if not ButSetting:
			return
		match _Switch:
			true:
				get_node("Texture").hide()
				get_node("WaitingLabel/Ani").play("wait")

			false:
				get_node("Texture").show()

				get_node("WaitingLabel/Ani").play("init")
func call_waiting_wrong():
	if has_node("WaitingLabel"):
		if get_node("WaitingLabel/Ani").assigned_animation != "init":
			get_node("WaitingLabel/Ani").play("wrong")

func test():

	get_godot_controllers()

var godot_controllers: Array
func get_godot_controllers() -> void :

	godot_controllers = Input.get_connected_joypads()

	if godot_controllers.size() > 0:
		for this_controller in godot_controllers:
			var this_controller_name: String = Input.get_joy_name(this_controller)
