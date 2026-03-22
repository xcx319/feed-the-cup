extends Control

var cur_InfoType = GameLogic.WRONGTYPE.NONE

onready var SpriteNode = get_node("Sprite")
onready var InfoLabel = self

func call_set(_type):
	cur_InfoType = _type

	match cur_InfoType:
		GameLogic.WRONGTYPE.BARREL:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-BARREL")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.FRUITCORE:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-FRUITCORE")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.JUICEMACHINE:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-JUICEMACHINE")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.MILKPOT:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-MILKPOT")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.MATERIALBOX:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-MATERIALBOX")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info

		GameLogic.WRONGTYPE.TRASHITEM:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-TRASHITEM")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.NONE:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-NONE")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
			SpriteNode.hide()
		GameLogic.WRONGTYPE.BOBAMACHINE:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-BOBAMACHINE")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
			SpriteNode.hide()
		GameLogic.WRONGTYPE.BIGPOT:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-BIGPOT")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
			SpriteNode.hide()
		GameLogic.WRONGTYPE.STAIN:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-STAIN")

			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.STEAMMACHINE:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-HOTWATER")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
			SpriteNode.hide()
		GameLogic.WRONGTYPE.ICEMACHINE:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-ICEMACHINE")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
			SpriteNode.hide()
		GameLogic.WRONGTYPE.TRASHBIN:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-TRASHBIN")
			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.TRASHBAG:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-TRASHBAG")

			var _Info_2 = GameLogic.Info.return_ColorInfo(_Info_1)
			var _Info = _Info_2.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.INDUCTIONCOOKER:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-INDUCTIONCOOKER")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.BOX:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-BOX")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.ITEM:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-ITEM")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.TEAPORT:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-TEAPORT")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.WATERPORT:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-WATERPORT")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		GameLogic.WRONGTYPE.DRINKCUP:
			var _Info_1 = GameLogic.CardTrans.get_message("INFO-DRINKCUP")
			var _Info = _Info_1.format(GameLogic.Info.Info_Name)
			InfoLabel.bbcode_text = _Info
		_:
			print("未添加说明：", cur_InfoType)
