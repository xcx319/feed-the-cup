extends Node2D

var _BufName: String
var _TIMELOGIC: bool
func call_init(_BUFNAME, _TYPE, _TIME):

	_BufName = _BUFNAME
	match _BufName:
		"技能-手速":
			match _TYPE:
				1:
					$AnimationPlayer.play("HandUp")
		"技能-提速":
			match _TYPE:
				1:
					$AnimationPlayer.play("SpeedUp")
				0:
					$AnimationPlayer.play("Down")
		"补充":
			$AnimationPlayer.play("HandUp")
	if _TIME > 0:
		_TIMELOGIC = true
		$Timer.wait_time = _TIME
		$Timer.start(0)
	else:
		$Timer.wait_time = 1
		$Timer.start(0)
func _on_Timer_timeout():
	$AnimationPlayer.play("5s")
func call_del():
	if _TIMELOGIC:
		if get_parent().get_parent().BuffList.has(_BufName):
			get_parent().get_parent().BuffList.erase(_BufName)
		get_parent().get_parent().Stat.Update_Check()
		self.queue_free()
	else:
		if not get_parent().get_parent().BuffList.has(_BufName):
			get_parent().get_parent().Stat.Update_Check()
			self.queue_free()
