extends RichTextLabel
export var LabelTEXT: String
export var Center_Bool: bool
export var Shake_Bool: bool
export var InCenter: bool

func _ready() -> void :
	if not GameLogic.is_connected("OPTIONSYNC", self, "_Tr_Set"):
		var _SYNC = GameLogic.connect("OPTIONSYNC", self, "_Tr_Set")

	call_deferred("_Tr_Set")

func call_init():
	if LabelTEXT:

		var _INFO_Base = GameLogic.CardTrans.get_message(LabelTEXT)

		var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)
		var _Info = _Info_1.format(GameLogic.Info.Info_Name)

		if Center_Bool:
			if InCenter:
				self.bbcode_text = "[center][center]" + _Info + "[/center][/center]"
			else:
				self.bbcode_text = "[center]" + _Info + "[/center]"
		else:
			self.bbcode_text = _Info

	else:
		call_Tr()

func _Tr_Set():
	if LabelTEXT:

		var _INFO_Base = GameLogic.CardTrans.get_message(LabelTEXT)
		var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)

		var _Info = _Info_1.format(GameLogic.Info.Info_Name)

		if Shake_Bool:
			call_shake_TEXT(LabelTEXT)
		elif Center_Bool:
			if InCenter:
				self.bbcode_text = "[center][center]" + _Info + "[/center][/center]"
			else:
				self.bbcode_text = "[center]" + _Info + "[/center]"
		else:
			self.bbcode_text = _Info

func call_Tr():
	var _INFO = GameLogic.CardTrans.get_message(self.text)
	if _INFO != "":
		if Center_Bool:
			if InCenter:
				self.bbcode_text = "[center][center]" + _INFO + "[/center][/center]"
			else:
				self.bbcode_text = "[center]" + _INFO + "[/center]"
		else:
			self.bbcode_text = _INFO

func call_Tr_TEXT(_Text: String):
	LabelTEXT = _Text

	var _INFO_Base = GameLogic.CardTrans.get_message(_Text)

	var _Info_1 = GameLogic.Info.return_ColorInfo(_INFO_Base)
	var _Info = _Info_1.format(GameLogic.Info.Info_Name)

	if Center_Bool:
		if InCenter:
			self.bbcode_text = "[center][center]" + _Info + "[/center][/center]"
		else:
			self.bbcode_text = "[center]" + _Info + "[/center]"
	else:
		self.bbcode_text = _Info

func call_center_TEXT(_Text: String):
	var _Info_1 = GameLogic.CardTrans.get_message(_Text)
	var _Info = _Info_1.format(GameLogic.Info.Info_Name)
	self.bbcode_text = "[center]" + _Info + "[/center]"

func call_shake_TEXT(_TEXT: String):
	var _Info_1 = GameLogic.CardTrans.get_message(_TEXT)
	var _Info = _Info_1.format(GameLogic.Info.Info_Name)
	self.bbcode_text = "[shake rate=4.5 level=10][center]" + _Info + "[/center][/shake]"
