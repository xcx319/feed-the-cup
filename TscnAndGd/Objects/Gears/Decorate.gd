extends Node2D

export var TYPE: String

func _ready():
	if not GameLogic.is_connected("Reward", self, "Update_Check"):
		var _con = GameLogic.connect("Reward", self, "Update_Check")
	call_deferred("call_init")
func call_init():
	if not GameLogic.LoadingUI.IsLevel:
		if has_node("Ani"):
			if get_node("Ani").has_animation("Show"):
				get_node("Ani").play("Show")
			if get_node("Ani").has_animation("show"):
				get_node("Ani").play("show")
		return
	Update_Check()
func Update_Check():
	match TYPE:
		"Immortal":
			if GameLogic.cur_Rewards.has("永生花") or GameLogic.cur_Rewards.has("永生花+"):
				get_node("Ani").play("Show")
		"Ticket":
			if GameLogic.cur_Rewards.has("饥饿营销new") or GameLogic.cur_Rewards.has("饿营销new+"):
				get_node("Ani").play("Show")
		"Order":
			if GameLogic.cur_Rewards.has("取票器") or GameLogic.cur_Rewards.has("取票器+"):
				get_node("Ani").play("Show")
		"Pig":
			if GameLogic.cur_Rewards.has("猪猪罐") or GameLogic.cur_Rewards.has("猪猪罐+"):
				get_node("Ani").play("Show")
		"Sand":
			if GameLogic.cur_Rewards.has("时间沙漏") or GameLogic.cur_Rewards.has("时间沙漏+"):
				get_node("Ani").play("Show")
		"Time":
			if GameLogic.cur_Rewards.has("绝对极限new") or GameLogic.cur_Rewards.has("绝对极限new+"):
				get_node("Ani").play("Show")

		"Cake":
			if GameLogic.cur_Rewards.has("安抚蛋糕") or GameLogic.cur_Rewards.has("安抚蛋糕+"):
				get_node("Ani").play("Show")
		"Show_1":
			if GameLogic.cur_Rewards.has("畅饮爽") or GameLogic.cur_Rewards.has("畅饮爽+"):
				get_node("Ani").play("Show")
		"Show_2":
			if GameLogic.cur_Rewards.has("管吃饱") or GameLogic.cur_Rewards.has("管吃饱+"):
				get_node("Ani").play("Show")
		"Show_3":
			if GameLogic.cur_Rewards.has("透心凉") or GameLogic.cur_Rewards.has("透心凉+"):
				get_node("Ani").play("Show")
		"Show_4":
			if GameLogic.cur_Rewards.has("七分糖") or GameLogic.cur_Rewards.has("七分糖+"):
				get_node("Ani").play("Show")
		"Show_5":
			if GameLogic.cur_Rewards.has("来者不拒new") or GameLogic.cur_Rewards.has("来者不拒new+"):
				get_node("Ani").play("Show")
		"Serve_1":
			if GameLogic.cur_Rewards.has("负压雨伞") or GameLogic.cur_Rewards.has("负压雨伞+"):
				get_node("Ani").play("Show")
		"Serve_2":
			if GameLogic.cur_Rewards.has("杂物篮") or GameLogic.cur_Rewards.has("杂物篮+"):
				get_node("Ani").play("Show")
		"Serve_3":
			if GameLogic.cur_Rewards.has("擦汗毛巾") or GameLogic.cur_Rewards.has("擦汗毛巾+"):
				get_node("Ani").play("Show")
		"Serve_4":
			if GameLogic.cur_Rewards.has("小费纸巾") or GameLogic.cur_Rewards.has("小费纸巾+"):
				get_node("Ani").play("Show")
		"Serve_5":
			if GameLogic.cur_Rewards.has("免洗消毒") or GameLogic.cur_Rewards.has("免洗消毒+"):
				get_node("Ani").play("Show")
		"Clean_1":
			if GameLogic.cur_Rewards.has("洗脑钢刷") or GameLogic.cur_Rewards.has("洗脑钢刷+"):
				get_node("Ani").play("Show")
		"Clean_2":
			if GameLogic.cur_Rewards.has("提速杯刷") or GameLogic.cur_Rewards.has("提速杯刷+"):
				get_node("Ani").play("Show")
		"Clean_3":
			if GameLogic.cur_Rewards.has("延时抹布") or GameLogic.cur_Rewards.has("延时抹布+"):
				get_node("Ani").play("Show")

		"Photo":
			if GameLogic.cur_Rewards.has("照片墙") or GameLogic.cur_Rewards.has("照片墙+"):
				get_node("Ani").play("Show")

		"Balloon":
			if GameLogic.cur_Rewards.has("气球") or GameLogic.cur_Rewards.has("气球+"):
				get_node("Ani").play("Show")

		"Air":
			if GameLogic.cur_Rewards.has("排队付费") or GameLogic.cur_Rewards.has("排队付费+"):
				get_node("Ani").play("Show")
		"Flower":
			if GameLogic.cur_Rewards.has("慷慨花环") or GameLogic.cur_Rewards.has("慷慨花环+"):
				get_node("Ani").play("Show")
		"Join":
			if GameLogic.cur_Rewards.has("营业执照") or GameLogic.cur_Rewards.has("营业执照+"):
				get_node("Ani").play("Show")
		"Lantern":
			if GameLogic.cur_Rewards.has("爆炸灯笼") or GameLogic.cur_Rewards.has("爆炸灯笼+"):
				get_node("Ani").play("Show")
		"Jade":
			if GameLogic.cur_Rewards.has("完美碧玉") or GameLogic.cur_Rewards.has("完美碧玉+"):
				get_node("Ani").play("Show")
		"Fan":
			if GameLogic.cur_Rewards.has("纸扇") or GameLogic.cur_Rewards.has("纸扇+"):
				get_node("Ani").play("Show")
		"Fish":
			if GameLogic.cur_Rewards.has("好运锦鲤"):
				get_node("Ani").play("Show")
		"Fireworks":
			if GameLogic.cur_Rewards.has("发财鞭炮") or GameLogic.cur_Rewards.has("发财鞭炮+"):
				get_node("Ani").play("Show")
		"BronzeCup":
			if GameLogic.cur_Rewards.has("连串铜币") or GameLogic.cur_Rewards.has("连串铜币+"):
				get_node("Ani").play("Show")
		"Tie":
			if GameLogic.cur_Rewards.has("幸运结"):
				get_node("Ani").play("Show")
		"Fu":
			if GameLogic.cur_Rewards.has("福气到") or GameLogic.cur_Rewards.has("福气到+"):
				get_node("Ani").play("Show")
		"Camera":
			if GameLogic.cur_Rewards.has("闭路电视") or GameLogic.cur_Rewards.has("闭路电视+"):
				get_node("Ani").play("Show")
		"Voice":
			if GameLogic.cur_Rewards.has("外放音响") or GameLogic.cur_Rewards.has("外放音响+"):
				get_node("Ani").play("Show")
		"Ultraviolet":
			if GameLogic.cur_Rewards.has("灭蚊灯") or GameLogic.cur_Rewards.has("灭蚊灯+"):
				get_node("Ani").play("Show")
		"Notice":
			if GameLogic.cur_Rewards.has("排班表") or GameLogic.cur_Rewards.has("排班表+"):
				get_node("Ani").play("Show")
		"Caimao":
			if GameLogic.cur_Rewards.has("招财猫") or GameLogic.cur_Rewards.has("招财猫+"):
				get_node("Ani").play("Show")
		"CatToy":
			if GameLogic.cur_Rewards.has("陪伴玩偶") or GameLogic.cur_Rewards.has("陪伴玩偶+"):
				get_node("Ani").play("Show")
		"CatJar":
			if GameLogic.cur_Rewards.has("流浪捐助箱") or GameLogic.cur_Rewards.has("流浪捐助箱+"):
				get_node("Ani").play("Show")
		"CatMat":
			if GameLogic.cur_Rewards.has("超负荷小窝") or GameLogic.cur_Rewards.has("超负荷小窝+"):
				get_node("Ani").play("Show")
		"CatBowl":
			if GameLogic.cur_Rewards.has("内卷饭碗") or GameLogic.cur_Rewards.has("内卷饭碗+"):
				get_node("Ani").play("Show")
