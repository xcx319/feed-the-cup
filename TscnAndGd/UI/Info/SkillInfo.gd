extends Control

onready var IconAni = $BG / Control / NinePatchRect / Icon / AnimationPlayer
func _ready():
	pass

func call_Label_set(_SKILLNAME):

	$TypeAni.play("Unlock")
	$Label.call_Tr_TEXT(_SKILLNAME)

	match _SKILLNAME:

		"技能-木讷":
			IconAni.play("木讷")
		"技能-修理":
			IconAni.play("修理")
		"技能-强卖":
			IconAni.play("强卖")
		"技能-出杯":
			IconAni.play("销售")
		"技能-拖地减压":
			IconAni.play("拖地减压")
		"技能-补充":
			IconAni.play("补充")
		"技能-握力":
			IconAni.play("握力")
		"技能-抗压":
			IconAni.play("抗压")
		"技能-爆发力":
			IconAni.play("爆发力")
		"技能-利爪":
			IconAni.play("利爪")
		"技能-熟练":
			IconAni.play("熟练")
		"技能-小心":
			IconAni.play("小心")
		"技能-自动欢迎":
			IconAni.play("迎宾")
		"技能-污渍不粘":
			IconAni.play("不粘")
		"技能-穿越":
			IconAni.play("穿越")
		"技能-发呆":
			IconAni.play("发呆")
		_:
			IconAni.play("无")
func call_Lock(_Type: int):
	$TypeAni.play("Lock")
	IconAni.play("无")
	match _Type:
		1:

			$Label.call_Tr_TEXT("信息-正式店员解锁")
		2:

			$Label.call_Tr_TEXT("信息-资深店员解锁")
func call_init():
	$TypeAni.play("Lock")
