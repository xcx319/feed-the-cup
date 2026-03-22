extends Panel

func _ready():
	var _con
	_con = GameLogic.connect("InfoPop", self, "_InfoPop")
	pass

func _InfoPop(_type):

	var _text
	match _type:
		0:
			pass
		1:
			_text = "INFO-随机种子需要为整数。"
		"ExitCurGame":
			_text = "INFO-确定退出当前游戏。"

	_text = "[center]" + _text + "[/center]"
	get_node("InfoPop/RichTextLabel").bbcode_text = _text
	self.visible = true
	get_node("InfoPop").visible = true

func _on_Button_pressed():
	get_node("InfoPop").visible = false
	self.visible = false
	pass
