extends Control

export var TYPE: int = 0
var cur_Num: int = 0
var target_Num: int = 0
export var cur_Bit: int
onready var Negative: bool = false

var IsPlay: bool
var NeedNext: bool = true
onready var Ani = $Ani
onready var ShowAni = $ShowAni

signal decimal()
signal finish()

func _ready():
	match self.name:
		"1":
			cur_Bit = 0
		"10":
			cur_Bit = 1
		"100":
			cur_Bit = 2
		"1000":
			cur_Bit = 3
		"10000":
			cur_Bit = 4
		"100000":
			cur_Bit = 5
		"1000000":
			cur_Bit = 6
func call_init():
	Ani.play("init")
	ShowAni.play("init")

func call_BitSet(_Num: int, _TYPE: int):
	TYPE = _TYPE

	cur_Num = 10

func call_Combo(_num):
	NeedNext = false

	if ShowAni.assigned_animation != "combo":
		ShowAni.play("combo")
	if cur_Num != _num:
		cur_Num = _num

		Ani.play(str(cur_Num))
var _SPEED: float = 1
func call_target(_num):
	cur_Num = _num
	target_Num = _num
	NeedNext = false
	ShowAni.play("show")
	if _num < 0:
		pass
	if Ani.has_animation(str(_num)):
		Ani.play(str(_num))
	else:
		pass

	match cur_Bit:
		0:
			_SPEED = 3
			Ani.playback_speed = 3
		1:
			_SPEED = 2
			Ani.playback_speed = 2
		2:
			_SPEED = 1
			Ani.playback_speed = 1
		3:
			_SPEED = 0.75
			Ani.playback_speed = 0.75
		4:
			Ani.playback_speed = 0.5
		5:
			_SPEED = 0.25
			Ani.playback_speed = 0.25
		6:
			_SPEED = 0.25
			Ani.playback_speed = 0.25
func call_Speed_Switch(_bool: bool):
	match _bool:
		true:
			Ani.playback_speed = _SPEED * 10
		false:
			Ani.playback_speed = _SPEED

func call_next():
	if not NeedNext:
		return
	match TYPE:
		0:
			if ShowAni.assigned_animation != "combo":
				ShowAni.play("combo")
			if cur_Num != target_Num:
				if cur_Num >= 9:
					cur_Num = 0
				else:
					cur_Num += 1
				Ani.play(str(cur_Num))
			else:

				emit_signal("finish")
				var _NAME = str(cur_Num)
				if Ani.assigned_animation != _NAME:
					Ani.play(_NAME)
		1:

			if cur_Num == 9:
				cur_Num = 0
			else:
				cur_Num += 1
			var _NAME = str(cur_Num)
			if Ani.assigned_animation != _NAME:
				Ani.play(_NAME)

func call_Bit_Play(_num):
	target_Num = _num
	cur_Num = 0
	call_next()

func call_show_10(_NUM):
	target_Num = _NUM
	match cur_Bit:
		0:
			match TYPE:
				1:
					ShowAni.playback_speed = 6
				2:
					ShowAni.playback_speed = 3
		1:
			match TYPE:
				1:
					ShowAni.playback_speed = 5
				2:
					ShowAni.playback_speed = 2
		2:
			match TYPE:
				1:
					ShowAni.playback_speed = 4
				2:
					ShowAni.playback_speed = 1
		3:
			ShowAni.playback_speed = 3
		4:
			ShowAni.playback_speed = 2
		5:
			ShowAni.playback_speed = 2
		6:
			ShowAni.playback_speed = 2

func call_decimal():
	emit_signal("decimal")

func call_play():

	if IsPlay:
		return
	if not self.visible:
		self.visible = true
	IsPlay = true
	match cur_Bit:
		0:
			if target_Num > 0:
				var _NUM = target_Num
				target_Num = int(float(target_Num)) % 10
				if _NUM >= 10:
					ShowAni.play("show_10")
				else:
					call_EndUI()
			else:
				ShowAni.play("show")

		1:
			if target_Num >= 10:
				var _NUM = target_Num
				target_Num = int(float(target_Num) / 10) % 10
				if _NUM >= 100:
					ShowAni.play("show_10")
				else:
					call_EndUI()

			else:

				self.hide()
		2:
			if target_Num >= 100:
				var _NUM = target_Num
				target_Num = int(float(target_Num) / 100) % 10
				if _NUM >= 1000:
					ShowAni.play("show_10")
				else:
					call_EndUI()

			else:

				self.hide()
		3:
			if target_Num >= 1000:
				var _NUM = target_Num
				target_Num = int(float(target_Num) / 1000) % 10
				if _NUM >= 10000:
					ShowAni.play("show_10")
				else:
					call_EndUI()
			else:
				self.hide()
		4:
			if target_Num >= 10000:
				var _NUM = target_Num
				target_Num = int(float(target_Num) / 10000) % 10
				if _NUM >= 100000:
					ShowAni.play("show_10")
				else:
					call_EndUI()
			else:
				self.hide()

		5:
			if target_Num >= 100000:
				var _NUM = target_Num
				target_Num = int(float(target_Num) / 100000) % 10
				if _NUM >= 1000000:
					ShowAni.play("show_10")
				else:
					call_EndUI()
			else:
				self.hide()

		6:
			if target_Num >= 1000000:
				target_Num = int(float(target_Num) / 1000000) % 10
				call_EndUI()
			else:
				self.hide()
func call_EndUI():
	TYPE = 0
	ShowAni.play("show")
	match cur_Bit:
		0:
			Ani.playback_speed = 2
		1:
			Ani.playback_speed = 2
		2:
			Ani.playback_speed = 2
		3:
			Ani.playback_speed = 2
		4:
			Ani.playback_speed = 2
		5:
			Ani.playback_speed = 2
		6:
			Ani.playback_speed = 2

	call_next()

func call_cur(_Num: int):
	cur_Num = _Num
