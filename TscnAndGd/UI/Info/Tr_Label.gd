extends Label

export var LabelTEXT: String
export var SYNC_Bool: bool = true
func _ready() -> void :
	if SYNC_Bool:
		if not GameLogic.is_connected("OPTIONSYNC", self, "_Tr_Set"):
			var _SYNC = GameLogic.connect("OPTIONSYNC", self, "_Tr_Set")
	call_deferred("_Tr_Set")

func _Tr_Set():
	if LabelTEXT:
		self.text = GameLogic.CardTrans.get_message(LabelTEXT)
	else:
		call_Tr()
func call_Tr():
	self.text = GameLogic.CardTrans.get_message(self.text)

func call_Tr_TEXT(_Text: String):
	LabelTEXT = _Text
	self.text = GameLogic.CardTrans.get_message(_Text)
