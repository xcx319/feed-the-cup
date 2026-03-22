extends Control

onready var FirstCharacter_But = get_node("ScrollContainer/VBoxContainer/0/0")
onready var Ani = $Ani
onready var MainUI = get_parent()
onready var Char_VBox = get_node("ScrollContainer/VBoxContainer")
var Player_Unlock
var Old_Select = - 1
var Cur_Select = 0

onready var Label_Name = get_node("Card/Name")
onready var Label_Info = get_node("Card/Info")
onready var Label_Money = get_node("Card/money")
onready var Label_MoveSpeed = get_node("Card/movespeed")
onready var Label_Skills = get_node("Card/Skills")
func call_init():
	if not GameLogic.Save.gameData.has("Player_Unlock"):
		GameLogic.Save.gameData.Player_Unlock = [0, 1, 5]
	Player_Unlock = GameLogic.Save.gameData.Player_Unlock
	for i in Player_Unlock.size():
		var _id = Player_Unlock[i]
		Character_set(_id)

func Character_set(_id):
	var _Main = str(int(_id / 3))
	Char_VBox.get_node(_Main).get_node(str(_id)).call_set(_id)

func call_UI_show_logic():
	FirstCharacter_But.grab_focus()
	Ani.play("show")

func _on_Back_pressed() -> void :
	call_CharacterSelectUI_Switch(false)
func call_CharacterSelectUI_Switch(_switch):
	if MainUI.name != "MainUI":
		return
	match _switch:
		true:
			call_init()
			MainUI.call_MainUI_Switch(false)
			MainUI.curUI = MainUI.UI.CHARACTERSELECTUI
			call_UI_show_logic()
		false:
			MainUI.call_MainUI_Switch(true)
			MainUI.curUI = MainUI.UI.MAINUI
			Ani.play("hide")

func hide_end():
	MainUI.PlayBut.grab_focus()

func call_player_info():

	for i in Label_Skills.get_child_count():
		var _label = Label_Skills.get_child(i)
		_label.text = ""
	if GameLogic.Config.PlayerConfig.has(str(Cur_Select)):
		var _info = GameLogic.Config.PlayerConfig[str(Cur_Select)]
		Label_MoveSpeed.text = _info.MoveSpeed
		Label_Money.text = _info.Money
		Label_Info.text = _info.PlayerInfo
		var _SkillList = _info.Skills
		var _label
		for i in _SkillList.size():

			_label = "SKILLINFO-" + str(_SkillList[i])
			Label_Skills.get_node(str(i)).text = _label
		pass

func _on_focus_entered() -> void :
	FirstCharacter_But.group.get_pressed_button()
	pass

func _on_character_pressed() -> void :

	GameLogic.NewGame_Bool = true

	GameLogic.cur_money = GameLogic.Config.PlayerConfig[str(Cur_Select)].Money
	var _level = GameLogic.Config.PlayerConfig[str(Cur_Select)].Level

	MainUI.SceneUI.call_init()
	self.hide()
