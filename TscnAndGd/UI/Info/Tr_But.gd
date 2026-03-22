extends Button

func _ready():
	self.text = GameLogic.CardTrans.get_message(self.text)
	if not GameLogic.is_connected("OPTIONSYNC", self, "_Tr_Set"):
		var _SYNC = GameLogic.connect("OPTIONSYNC", self, "_Tr_Set")

func _Tr_Set():
	self.text = GameLogic.CardTrans.get_message(self.text)
