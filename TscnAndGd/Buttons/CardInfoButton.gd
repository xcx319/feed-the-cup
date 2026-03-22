extends Button

var cur_Card
var cur_focus: bool

onready var InfoNode = get_node("InfoBG/InfoLabel")
onready var Card_RankNode = get_node("HBox")
onready var Ani = get_node("Ani")

func call_set(_cardName):
	if GameLogic.Config.CardConfig.has(_cardName):
		cur_Card = _cardName
		var _Info = GameLogic.Config.CardConfig[cur_Card]
		self.text = _Info.ShowNameID
		InfoNode.text = _Info.ShowInfoID
		var CardRank = int(_Info.Rank)
		if CardRank >= 1:
			Card_RankNode.get_node("1/TextureProgress").value = 1
		if CardRank >= 2:
			Card_RankNode.get_node("2/TextureProgress").value = 1
		if CardRank >= 3:
			Card_RankNode.get_node("3/TextureProgress").value = 1
		if CardRank >= 4:
			Card_RankNode.get_node("4/TextureProgress").value = 1
		if CardRank >= 5:
			Card_RankNode.get_node("5/TextureProgress").value = 1
