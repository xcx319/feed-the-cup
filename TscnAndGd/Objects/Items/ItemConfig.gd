extends Head_Object

onready var typeAni

func _ready() -> void :
	call_Collision_Switch(false)
	IsItem = true

	_typeAni_set()

func _typeAni_set():

	if has_node("AniNode/typeAni"):
		typeAni = get_node("AniNode/typeAni")

func call_bag_tex_set():
	IsItem = true
	if typeAni:
		if typeAni.has_animation(TypeStr):
			typeAni.play(TypeStr)
	match TypeStr:
		"tealeaf_red":

			Weight = 1
		"tealeaf_green":
			Weight = 1
		"power_vegfat":

			Weight = 1
		"powder_coco":
			Weight = 1
		"powder_coffeebean":
			Weight = 1
		"powder_mocha":
			Weight = 1
		"powder_instant_coffee":
			Weight = 1
		"powder_instant_milk":
			Weight = 1
		"powder_instant_milktea":
			Weight = 1

func _on_body_entered(body: Node) -> void :

	body.cur_Touch_Count += 1
	body.Stat.call_speed_set(0.5)

	if not body.cur_TouchObj:
		body.cur_TouchObj = self
	else:
		DeviceLogic.call_TouchDev_Logic( - 2, body, body.cur_TouchObj)
		body.cur_TouchObj = self
	DeviceLogic.call_TouchDev_Logic( - 1, body, body.cur_TouchObj)

func _on_body_exited(body: Node) -> void :
	body.cur_Touch_Count -= 1
	if body.cur_Touch_Count <= 0:
		body.Stat.call_speed_reset()
	if body.cur_TouchObj == self:
		body.cur_TouchObj = null
		DeviceLogic.call_TouchDev_Logic( - 2, body, self)
