extends Node2D

onready var PayAni = $Ani
onready var PayHBox = $PayNode / HBox
onready var TipHBox = $TipsNode / HBox
onready var CriIcon = $PayNode / CriIcon
onready var QuickAni = $QuickAni
onready var SlowAni = $SlowAni
onready var JumpAni = $JumpAni
var Base: int
var Pay: int
var Tips: int
var IsCri: bool
var TYPE: int
var COLOR: int = 1
var IsQuick: bool
var IsSlow: bool
var IsJump: bool

var IsPay: bool
var HasREP: bool
func call_Pay(_Num):
	var _TexPath = "res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_CO2.tres"
	var _Tex = load(_TexPath)
	$PayNode / Control / Icon.set_texture(_Tex)
	Base = _Num
	Pay = _Num * - 1
	IsPay = true
	_TYPE_Set()
	_COLOR_Set()
	NumSet()
	call_show()
func call_REP(_Num):
	HasREP = true
	if not HasREP:
		$REPNode.hide()
	else:
		$REPNode.show()
		$TipsNode.hide()
		$PayNode.hide()
	$REPNode / Label.text = str(_Num)
	call_show()
func call_init(_BasePay: int, _Pay: int, _Tip: int, _IsCri: bool, _IsQuick: bool, _IsSlow: bool, _IsJump: bool, _REP: int = 0):
	Base = _BasePay
	Pay = _Pay
	Tips = _Tip
	IsCri = _IsCri
	IsQuick = _IsQuick
	IsSlow = _IsSlow
	IsJump = _IsJump

	if not _REP:
		$REPNode.hide()
	else:
		$REPNode.show()
		$TipsNode.hide()
	_TYPE_Set()
	_COLOR_Set()
	NumSet()
	call_show()
func _TYPE_Set():
	if float(Pay) >= float(Base) * 1.3:
		TYPE = 2
	else:
		TYPE = 1
func _COLOR_Set():
	if Pay < 0:
		COLOR = - 1
	elif Pay < Base:
		COLOR = 0
	elif Base == 0:
		COLOR = 1
	elif float(Pay) >= float(Base) * 1.1 and Pay != 0:
		COLOR = int(float(Pay) / float(Base) * 10)
	else:
		COLOR = 1
func call_show():

	if Tips > 0:
		if IsCri:
			var _Audio = GameLogic.Audio.return_Effect("硬币一个清脆")
			_Audio.play(0)
		else:
			var _Audio = GameLogic.Audio.return_Effect("硬币一个快速")
			_Audio.play(0)

	else:
		var _Audio = GameLogic.Audio.return_Effect("硬币一个低音")
		_Audio.play(0)

	if IsCri:
		CriIcon.show()
	else:
		CriIcon.hide()
	if IsQuick:
		QuickAni.play("quick")
	if IsSlow:
		SlowAni.play("Slow")
	if IsJump:
		JumpAni.play("jump")
	PayAni.play("show")

func NumSet():

	if Pay >= 0:
		var _SIGN = GameLogic.TSCNLoad.NumControl_TSCN.instance()
		PayHBox.add_child(_SIGN)
		_SIGN.call_init(TYPE, 0, COLOR)
	else:
		var _SIGN = GameLogic.TSCNLoad.NumControl_TSCN.instance()
		PayHBox.add_child(_SIGN)
		_SIGN.call_init(TYPE, 1, COLOR)
	var str_num = str(abs(Pay))
	var length = len(str_num)
	var _Color = COLOR
	if IsCri:
		_Color = 2

	for _i in length:
		var _Num = GameLogic.TSCNLoad.NumControl_TSCN.instance()
		var _PayNum = int(str_num.substr(_i, 1)) + 2
		PayHBox.add_child(_Num)
		_Num.call_init(TYPE, _PayNum, _Color)
	if Tips > 0:
		str_num = str(Tips)
		length = len(str_num)
		for _i in length:
			var _Num = GameLogic.TSCNLoad.NumControl_TSCN.instance()
			var _TipNum = int(str_num.substr(_i, 1)) + 2

			TipHBox.add_child(_Num)
			_Num.call_init(0, _TipNum, 3)
	else:
		get_node("TipsNode").hide()
func call_del():
	self.queue_free()
