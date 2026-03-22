extends Button

var _click_Audio
export var EffectName: String
export var ButType: int
onready var Ani = get_node("Ani")
onready var NameLabel = get_node("BG/Control/NameLabel")
onready var CostLabel = get_node("BG/Control/CostLabel")
onready var LockAni = get_node("BG/Control/Lock/Ani")
var Type: int

var NameInfo: String
var CheckBool: bool = false
var Cost: int
var IsUnlock: bool

func _ready() -> void :

	call_deferred("_connect")

func _connect():
	var _connect

	if not self.is_connected("pressed", self, "on_pressed"):
		_connect = self.connect("pressed", self, "on_pressed")
	if rect_pivot_offset == Vector2.ZERO:
		rect_pivot_offset = rect_size / 2
	call_deferred("call_set")
	if Type == 0:
		if int(self.name) - 1 == GameLogic.Save.gameData.HomeUpdate:
			if GameLogic.DEMO_bool:
				if self.name == "2":
					Ani.play("disable")
					IsUnlock = true
					return
			if int(self.name) - 1 >= GameLogic.Achievement.CanUpdate:
				Ani.play("disable")
				IsUnlock = true
			elif not IsUnlock:
				Ani.play("UnLock")

func call_init(_Name):

	if GameLogic.Config.HomeConfig.has(_Name):
		NameInfo = _Name
		var INFO = GameLogic.Config.HomeConfig[_Name]
		Type = 0
		NameLabel.text = GameLogic.CardTrans.get_message(INFO.Name)
		CostLabel.text = INFO.Cost
		Cost = int(INFO.Cost)

		_check_logic()
	elif GameLogic.Config.HomeDevConfig.has(_Name):
		NameInfo = _Name
		var INFO = GameLogic.Config.HomeDevConfig[_Name]

		Type = 1
		NameLabel.text = GameLogic.CardTrans.get_message(INFO.Name)
		CostLabel.text = INFO.Cost
		Cost = int(INFO.Cost)

		_check_logic()
	call_CanBuy_Check()
func call_CanBuy_Check():

	if GameLogic.return_FullHMK() < Cost:
		$BG / Control / CostLabel / AnimationPlayer.play("red")
func _check_logic():

	match Type:
		0:
			if GameLogic.Save.gameData.has("HomeUpdate"):
				if GameLogic.Save.gameData.HomeUpdate >= int(self.name):
					if int(self.name) - 1 > GameLogic.Achievement.CanUpdate:
						Ani.play("disable")
						IsUnlock = true
						return
					Ani.play("Check")
					IsUnlock = true
					CheckBool = true
					return


				if int(self.name) - 1 == GameLogic.Save.gameData.HomeUpdate:
					if GameLogic.DEMO_bool:

						if self.name == "2":
							Ani.play("disable")
							IsUnlock = true
				else:
					Ani.play("disable")
					IsUnlock = true
			else:
				return

		1:

			if GameLogic.Save.gameData.has("HomeDevList"):
				if GameLogic.Save.gameData.HomeDevList.has(NameInfo):
					Ani.play("Check")
					CheckBool = true

			else:
				GameLogic.Save.gameData["HomeDevList"] = []

func call_set():
	_click_Audio = GameLogic.Audio.But_EasyClick

func on_pressed():

	if _click_Audio:
		_click_Audio.play(0)

func _on_Button_pressed():
	pass
