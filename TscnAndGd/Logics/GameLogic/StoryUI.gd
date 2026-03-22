extends CanvasLayer

onready var StoryAni = $AniNode / StoryAni

var StoryList = [0]

func call_story(_id):
	if StoryList.has(int(_id)):
		print("play story")
		StoryAni.play(str(_id))
