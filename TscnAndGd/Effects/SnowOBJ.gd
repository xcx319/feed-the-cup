extends Node2D

export var FlipH: bool = false
export var Type: int = 1
onready var TypeAni = $TypeAni

var NUM: int = 1
var CanP: bool = false
var CanPass: bool = true

onready var CanPassAni = $Label / Ani
func _ready():
	var _SCALENUM: int = NUM

	call_Scale(_SCALENUM)
func call_Scale(_SCALENUM):
	var _X = 1
	if FlipH:
		_X = - 1
	_SCALENUM = NUM * 2
	if _SCALENUM >= 10:
		_SCALENUM = 10

	self.scale = Vector2(float(_SCALENUM) / 10 * _X, float(_SCALENUM) / 10)
	self.modulate.a = float(_SCALENUM) / 10
	var _x = self.modulate.a
	if NUM < 10:
		self.z_index = - 1
		TypeAni.play(str(Type))
	else:
		self.z_index = 0
		TypeAni.play("D" + str(Type))

func call_Snow_Add():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	NUM += 1
	if NUM >= 10:
		NUM = 10
		if not CanP and CanPass:
			CanP = true
			CanPassAni.play("New")
	call_Scale(NUM)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Num", [NUM])
func call_Num(_NUM):
	NUM = _NUM
	if NUM == 10:
		if not CanP and CanPass:
			CanP = true
			CanPassAni.play("New")
	call_Scale(NUM)
func _Num_Change(_NUM):

	NUM += _NUM
	if NUM >= 10:
		NUM = 10
		if not CanP and CanPass:
			CanP = true
			CanPassAni.play("New")
	call_Scale(NUM)
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Num", [NUM])
func _Num_Change_H(_NUM):
	call_Num_H(_NUM)

func call_Num_H(_NUM):
	NUM += _NUM
	if NUM > 10 and NUM < 30:
		NUM = 20
	elif NUM > 30:
		NUM = 30
	if NUM == 20:
		if TypeAni.assigned_animation != "Snow1":
			TypeAni.play("Snow1")
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Num_H_puppet", [NUM])
	elif NUM == 30:
		if TypeAni.assigned_animation != "Snow2":
			TypeAni.play("Snow2")
			call_Finish()
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				SteamLogic.call_puppet_node_sync(self, "call_Num_H_puppet", [NUM])
func call_Num_H_puppet(_NUM):
	NUM = _NUM
	if NUM == 20:
		TypeAni.play("Snow1")
	elif NUM == 30:
		if TypeAni.assigned_animation != "Snow2":
			TypeAni.play("Snow2")
			call_Finish()
func call_Finish():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		$Label / Ani.play("Finished")
		return
	var _VALUE: int = 60
	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = self.global_position
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	var _R = GameLogic.return_Popular(_VALUE, GameLogic.HomeMoneyKey)
	_PayEffect.call_REP(_R)
	$Label / Ani.play("Finished")
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Pay_puppet", [_R])
func call_Pay_puppet(_VALUE):
	var _PayEffect = GameLogic.TSCNLoad.PayEffect_TSCN.instance()
	_PayEffect.position = self.global_position
	GameLogic.Staff.LevelNode.add_child(_PayEffect)
	_PayEffect.call_REP(_VALUE)
func _on_Snow_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	pass

func call_del():
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_del")
	if is_in_group("WaterStain"):
		remove_from_group("WaterStain")
	if CanPassAni.is_playing():
		CanPassAni.stop()
	self.queue_free()
func _on_Area2D_area_entered(_Area):
	if _Area == self:
		return
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _PAR = _Area.get_parent()
	if _PAR.has_method("call_Snow_Add"):

		if NUM == _PAR.NUM and NUM < 10:
			var _selfID = self.get_instance_id()
			var _AreaID = _PAR.get_instance_id()

			if _selfID < _AreaID:
				_Num_Change(_PAR.NUM)

				_PAR.call_del()
				pass
		elif NUM == 10 and _PAR.NUM == 10:
			var _selfID = self.get_instance_id()
			var _AreaID = _PAR.get_instance_id()
			if _selfID < _AreaID:
				_Num_Change_H(_PAR.NUM)
				_PAR.call_del()
		elif NUM == 20 and _PAR.NUM == 20:
			var _selfID = self.get_instance_id()
			var _AreaID = _PAR.get_instance_id()
			if _selfID < _AreaID:
				_Num_Change_H(_PAR.NUM)
				_PAR.call_del()

		elif NUM > _PAR.NUM and NUM < 10:

			_Num_Change(_PAR.NUM)
			_PAR.call_del()


func _on_WaterStain_body_entered(_body):

	if _body.has_method("call_ThrowObj"):
		return

	if NUM < 10:
		if _body.Stat.has_method("call_slip_in"):
			if _body.has_method("_PlayerNode"):
				pass
			_body.Stat.call_slip_in(NUM * 2, true)
			_body.Stat.call_stick_in(float(NUM) / 2, true)
	else:
		if _body.Stat.has_method("call_stick_end"):
			_body.Stat.call_stick_in(float(NUM) * 1.3, true)

func _on_WaterStain_body_exited(_body):
	if _body.has_method("call_ThrowObj"):
		return
	if NUM < 10:
		if _body.Stat.has_method("call_slip_end"):
			_body.Stat.call_slip_end(true)
			_body.Stat.call_stick_end(true)
	else:
		if _body.Stat.has_method("call_stick_end"):
			_body.Stat.call_stick_end(true)
			if _body.has_method("call_AcrossItem") and not CanPass:
				_body.call_AcrossItem(self)

var velocity: Vector2
func _physics_process(_delta):

	if not get_tree().paused:
		self.position = self.position.move_toward(self.position + velocity, 350 * _delta)
func call_move(_Switch, _FACE):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	match _Switch:
		true:
			match _FACE:
				0:
					velocity = Vector2(0, - 100)
				1:
					velocity = Vector2(0, 100)
				2:
					velocity = Vector2( - 100, 0)
				3:
					velocity = Vector2(100, 0)
		false:
			velocity = Vector2.ZERO
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_move_puppet", [_Switch, _FACE, self.position])
func call_move_puppet(_Switch, _FACE, _POS):
	match _Switch:
		true:
			match _FACE:
				0:
					velocity = Vector2(0, - 100)
				1:
					velocity = Vector2(0, 100)
				2:
					velocity = Vector2( - 100, 0)
				3:
					velocity = Vector2(100, 0)
		false:
			velocity = Vector2.ZERO
	self.position = _POS

func call_CanPassEnd():

	CanPass = false
