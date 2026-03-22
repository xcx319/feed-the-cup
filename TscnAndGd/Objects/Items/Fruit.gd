extends Head_Object

var Liquid_Count: int
var WaterType
var WaterCelcius: int = 25
var HasWater: bool
var IsPassDay: bool
var IsBroken: bool
var CanSQUEEZE: bool
var SQUEEZE_SPEED: float = 1

onready var TypeAni = get_node("AniNode/TypeAni")
onready var A_But = get_node("But/A")
onready var _Audio
var _PLAYER
var _CUP
var DropCount: int = 0
func return_DropCount():
	return DropCount
func But_Switch(_bool, _Player):
	if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
		return
	if _Player.Con.IsHold:
		if not CanSQUEEZE:
			A_But.hide()


		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_1)
		if TypeStr in ["桑葚", "草莓"]:
			A_But.show()
		if self.get_parent().name in ["Items"]:
			A_But.hide()
	else:

		A_But.InfoLabel.text = GameLogic.CardTrans.get_message(A_But.Info_Str)

	.But_Switch(_bool, _Player)
func call_OutLine(_Switch: bool):
	match _Switch:
		true:
			get_node("AniNode/OutLineAni").play("show")
		false:
			get_node("AniNode/OutLineAni").play("init")
func _ready() -> void :
	if get_parent().name == "Items":
		call_Collision_Switch(true)
	else:
		call_Collision_Switch(false)
	IsItem = true
	get_node("But").show()
	_Audio = GameLogic.Audio.return_Effect("手榨果汁")
func _rand_icon(_Name):
	match _Name:
		"鸡蛋":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			CanSQUEEZE = true
			WaterType = "鸡蛋液"
			DropCount = 1
			SQUEEZE_SPEED = 2
		"胡萝卜":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)

			WaterType = "胡萝卜汁"
			HasWater = true
			Liquid_Count = 3
			SQUEEZE_SPEED = 1
			DropCount = 1
		"黄瓜":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 40 + GameLogic.return_RANDOM() % 10
			WaterType = "黄瓜汁"
			HasWater = true
			Liquid_Count = 5
			SQUEEZE_SPEED = 1
			DropCount = 1
		"甘蔗":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode").rotation_degrees = 80 + GameLogic.return_RANDOM() % 20
			WaterType = "甘蔗汁"
			HasWater = true
			Liquid_Count = 10
			SQUEEZE_SPEED = 1
			DropCount = 2
		"西芹":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 40 + GameLogic.return_RANDOM() % 10
			WaterType = "西芹汁"
			HasWater = true
			Liquid_Count = 8
			SQUEEZE_SPEED = 1
			DropCount = 1
		"苹果":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation = GameLogic.return_RANDOM() % 360
			WaterType = "苹果汁"
			HasWater = true
			Liquid_Count = 4
			SQUEEZE_SPEED = 1

			DropCount = 1
		"生姜":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation = GameLogic.return_RANDOM() % 360
			WaterType = "生姜汁"
			HasWater = true
			Liquid_Count = 3
			SQUEEZE_SPEED = 1

			DropCount = 1
		"香蕉块", "西瓜块", "凤梨块", "芒果块", "牛油果块", "杨梅块", "葡萄块", "桃子块", "西柚块", "火龙果块":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			if TypeAni.has_animation(_AniName):
				TypeAni.play(_AniName)
			elif TypeAni.has_animation(_Name):
				TypeAni.play(_Name)
			get_node("TexNode/Tex").rotation_degrees = 0
			DropCount = 1
		"柠檬片", "芝士片", "青桔块", "薄荷叶":
			var _rand = GameLogic.return_RANDOM() % 5 + 1
			var _AniName = _Name + str(_rand)
			if TypeAni.has_animation(_AniName):
				TypeAni.play(_AniName)
			elif TypeAni.has_animation(_Name):
				TypeAni.play(_Name)
			get_node("TexNode/Tex").rotation_degrees = 0
			DropCount = 1
		"火龙果":

			var _AniName = _Name
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 0
			CanSQUEEZE = false
			DropCount = 2
		"香蕉":

			var _AniName = _Name
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 0
			CanSQUEEZE = false
			DropCount = 2
		"葡萄":

			var _AniName = _Name
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 0
			CanSQUEEZE = false
			DropCount = 3
		"凤梨":

			var _AniName = _Name
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 0
			CanSQUEEZE = false
			DropCount = 3
		"西瓜":

			var _AniName = _Name
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = 0
			CanSQUEEZE = false
			DropCount = 5
		"草莓", "芒果", "牛油果", "杨梅", "桃子", "牛油果", "桑葚":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			CanSQUEEZE = false
			DropCount = 1
		"西柚":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			CanSQUEEZE = false

			DropCount = 2
		"柠檬":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			WaterType = "柠檬汁"
			HasWater = true
			Liquid_Count = 1
			SQUEEZE_SPEED = 2
			CanSQUEEZE = true
			DropCount = 1
		"橙子":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			WaterType = "橙子汁"
			HasWater = true
			Liquid_Count = 2
			SQUEEZE_SPEED = 1
			CanSQUEEZE = true
			DropCount = 1
		"百香果":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			CanSQUEEZE = true
			WaterType = "百香果"
			DropCount = 1
		"芋头", "青桔":
			var _rand = GameLogic.return_RANDOM() % 4 + 1
			var _AniName = _Name + str(_rand)
			TypeAni.play(_AniName)
			get_node("TexNode/Tex").rotation_degrees = GameLogic.return_RANDOM() % 360
			CanSQUEEZE = false
			DropCount = 1
		"芋头块", "薄荷枝":
			TypeAni.play(_Name)
			get_node("TexNode/Tex").rotation_degrees = 0
			CanSQUEEZE = false
			DropCount = 1
func _load(_NAME):
	.call_init(_NAME)
func call_init(_TypeStr):
	.call_init(_TypeStr)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()
func call_load_TSCN(_TypeStr):
	call_init(_TypeStr)
	.call_Ins_Save(_SELFID)
	call_bag_tex_set()
func call_load(_Info):
	_SELFID = int(_Info.NAME)
	self.name = str(_SELFID)
	.call_Ins_Save(_SELFID)
	if not TypeStr:
		call_init(_Info.TypeStr)
	call_bag_tex_set()
	if _Info.has("IsBroken"):
		IsBroken = _Info.IsBroken
	_freshless_logic()
func call_bag_tex_set():

	IsItem = true
	if TypeAni:

		_rand_icon(TypeStr)

func call_WaterInDrinkCup(_ButID, _CupObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
			if _CupObj:
				if _CupObj.FuncType == "DrinkCup":
					if _CupObj.get_parent().name != "Weapon_note":
						_CupObj.call_CupInfo_Switch(false)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
			if _CupObj:
				if _CupObj.FuncType == "DrinkCup":
					if _CupObj.get_parent().name != "Weapon_note":
						if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
							_CupObj.call_CupInfo_Switch(true)
		0:

			if IsBroken:
				return
			if not TypeStr in ["桑葚", "百香果", "草莓", "柠檬", "橙子", "鸡蛋"]:
				return
			match TypeStr:
				"桑葚", "百香果", "草莓", "鸡蛋":
					var _Type = _CupObj.TYPE
					match _Type:
						"DrinkCup_S", "SodaCan_S", "BeerCup_S":
							if _CupObj.Extra_1 != "":

								return
						"DrinkCup_M", "SodaCan_M", "BeerCup_M":
							if _CupObj.Extra_2 != "":

								return
						"DrinkCup_L", "SodaCan_L", "BeerCup_L":
							if _CupObj.Extra_3 != "":

								return
						"SuperCup_M":
							if _CupObj.Extra_5 != "":

								return
						_:
							printerr(" 水果加入杯子错误，杯子类型错误：", _Type)
							return
				_:
					if _CupObj.Liquid_Count >= _CupObj.Liquid_Max:
						if _CupObj.LIQUID_DIR.has("啤酒泡"):
							if _CupObj.LIQUID_DIR["啤酒泡"] == 0:
								return
						else:
							return
			if not CanSQUEEZE and not TypeStr in ["桑葚", "草莓"]:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):

				return

			match get_parent().name:
				"layer1", "layer2", "layer3", "layer4":
					match TypeStr:
						"百香果", "柠檬", "橙子", "鸡蛋":
							var _R = return_ExtraInDrinkCup(_ButID, _CupObj, _Player)
							if _R:

								GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
								call_SQUEEZE(_CupObj, _Player)
							else:
								return
						"桑葚", "草莓":
							var _CHECK: bool
							if _CupObj.TYPE in ["SuperCup_M"]:
								if _CupObj.Extra_1 == "":
									_CupObj.Extra_1 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_2 == "":
									_CupObj.Extra_2 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_3 == "":
									_CupObj.Extra_3 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_4 == "":
									_CupObj.Extra_4 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_5 == "":
									_CupObj.Extra_5 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
							elif _CupObj.Extra_1 == "":
								_CupObj.Extra_1 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 == "" and _CupObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "BeerCup_M", "BeerCup_L"]:
								_CupObj.Extra_2 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 != "" and _CupObj.Extra_3 == "" and _CupObj.TYPE in ["DrinkCup_L", "BeerCup_L"]:
								_CupObj.Extra_3 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							if not _CHECK:
								return
							if IsPassDay:
								_CupObj.call_add_PassDay()
							if _Player.WeaponNode.has_node(self):
								_Player.WeaponNode.remove_child(self)

							self.call_del()
							var _AUDIO = GameLogic.Audio.return_Effect("气泡")
							_AUDIO.play(0)
					return true
				"Weapon_note":
					match TypeStr:
						"百香果", "柠檬", "橙子", "鸡蛋":
							var _R = return_ExtraInDrinkCup(_ButID, _CupObj, _Player)
							if _R:

								GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
								GameLogic.Device.call_Player_Pick(_Player, _CupObj)
								call_SQUEEZE(_CupObj, _Player)
								_CupObj.But_Hold(_Player)
								if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
									_CupObj.call_CupInfo_Switch(true)
							else:
								return
						"桑葚", "草莓":
							var _CHECK: bool
							if _CupObj.TYPE in ["SuperCup_M"]:
								if _CupObj.Extra_1 == "":
									_CupObj.Extra_1 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_2 == "":
									_CupObj.Extra_2 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_3 == "":
									_CupObj.Extra_3 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_4 == "":
									_CupObj.Extra_4 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_5 == "":
									_CupObj.Extra_5 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
							elif _CupObj.Extra_1 == "":
								_CupObj.Extra_1 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 == "" and _CupObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "BeerCup_M", "BeerCup_L"]:
								_CupObj.Extra_2 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 != "" and _CupObj.Extra_3 == "" and _CupObj.TYPE in ["DrinkCup_L", "BeerCup_L"]:
								_CupObj.Extra_3 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							if not _CHECK:
								return
							_Player.Stat.call_carry_off()
							self.call_del()
							var _AUDIO = GameLogic.Audio.return_Effect("气泡")
							_AUDIO.play(0)
							return "放入"
				"ItemNode":
					match TypeStr:
						"百香果", "柠檬", "橙子", "鸡蛋":
							var _R = return_ExtraInDrinkCup(_ButID, _CupObj, _Player)
							if _R:

								GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
								call_SQUEEZE(_CupObj, _Player)
							else:
								return
						"桑葚", "草莓":
							var _CHECK: bool
							if _CupObj.TYPE in ["SuperCup_M"]:
								if _CupObj.Extra_1 == "":
									_CupObj.Extra_1 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_2 == "":
									_CupObj.Extra_2 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_3 == "":
									_CupObj.Extra_3 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_4 == "":
									_CupObj.Extra_4 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_5 == "":
									_CupObj.Extra_5 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
							elif _CupObj.Extra_1 == "":
								_CupObj.Extra_1 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 == "" and _CupObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "BeerCup_M", "BeerCup_L"]:
								_CupObj.Extra_2 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 != "" and _CupObj.Extra_3 == "" and _CupObj.TYPE in ["DrinkCup_L", "BeerCup_L"]:
								_CupObj.Extra_3 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							if not _CHECK:
								return

							self.call_del()
							var _AUDIO = GameLogic.Audio.return_Effect("气泡")
							_AUDIO.play(0)
				"ObjNode":
					match TypeStr:
						"百香果", "柠檬", "橙子", "鸡蛋":
							var _R = return_ExtraInDrinkCup(_ButID, _CupObj, _Player)
							if _R:
								call_SQUEEZE(_CupObj, _Player)

								GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
							else:
								return
						"桑葚", "草莓":
							var _CHECK: bool
							if _CupObj.TYPE in ["SuperCup_M"]:
								if _CupObj.Extra_1 == "":
									_CupObj.Extra_1 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_2 == "":
									_CupObj.Extra_2 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_3 == "":
									_CupObj.Extra_3 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_4 == "":
									_CupObj.Extra_4 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
								elif _CupObj.Extra_5 == "":
									_CupObj.Extra_5 = TypeStr
									_CupObj.call_add_extra()
									_CHECK = true
							elif _CupObj.Extra_1 == "":
								_CupObj.Extra_1 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 == "" and _CupObj.TYPE in ["DrinkCup_M", "DrinkCup_L", "BeerCup_M", "BeerCup_L"]:
								_CupObj.Extra_2 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							elif _CupObj.Extra_1 != "" and _CupObj.Extra_2 != "" and _CupObj.Extra_3 == "" and _CupObj.TYPE in ["DrinkCup_L", "BeerCup_L"]:
								_CupObj.Extra_3 = TypeStr
								_CupObj.call_add_extra()
								_CHECK = true
							if not _CHECK:
								return

							self.call_del()
							var _AUDIO = GameLogic.Audio.return_Effect("气泡")
							_AUDIO.play(0)
					var _WorkBench = self.get_parent().get_parent()

					if _WorkBench.has_method("call_OnTable"):
						_WorkBench.OnTableObj = null
						_WorkBench.OnTable_InstanceId = 0
					return "放入"
func return_ExtraInDrinkCup(_ButID, _CupObj, _Player):

	match _ButID:
		- 2:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(false, _Player)
			if _CupObj:
				if _CupObj.FuncType == "DrinkCup":
					if _CupObj.get_parent().name != "Weapon_note":
						_CupObj.call_CupInfo_Switch(false)
		- 1:
			if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				return
			But_Switch(true, _Player)
			if _CupObj:
				if _CupObj.FuncType == "DrinkCup":
					if _CupObj.get_parent().name != "Weapon_note":
						if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
							_CupObj.call_CupInfo_Switch(true)
		0:

			if IsBroken:
				return
			if not CanSQUEEZE:
				return
			if GameLogic.Device.return_CanUse_bool(_Player):

				return
			var _EXTRANAME: String
			match FuncTypePara:
				"百香果":
					_EXTRANAME = "百香果肉"
					WaterType = "百香果"
					_Audio = GameLogic.Audio.return_Effect("手榨果汁")
				"鸡蛋":
					_EXTRANAME = "鸡蛋液"
					WaterType = "鸡蛋液"
					_Audio = GameLogic.Audio.return_Audio("特效鸡蛋")

				_:
					_Audio = GameLogic.Audio.return_Effect("手榨果汁")
			if _EXTRANAME != "":
				var _CHECK = _CupObj.return_add_Extra(_EXTRANAME)
				if not _CHECK:
					return
			if IsPassDay:
				_CupObj.call_add_PassDay()

			match get_parent().name:
				"Weapon_note":

					GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
					GameLogic.Device.call_Player_Pick(_Player, _CupObj)
					call_SQUEEZE(_CupObj, _Player)
					_CupObj.But_Hold(_Player)
					if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
						_CupObj.call_CupInfo_Switch(true)
				"ItemNode":

					GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
					call_SQUEEZE(_CupObj, _Player)
				"ObjNode":
					var _WorkBench = self.get_parent().get_parent()

					if _WorkBench.has_method("call_OnTable"):
						_WorkBench.OnTableObj = null
						_WorkBench.OnTable_InstanceId = 0
					call_SQUEEZE(_CupObj, _Player)

					GameLogic.Liquid.call_WaterStain(_Player.global_position, 4, WaterType, _Player)
			return true
func call_broken():
	IsBroken = true
	_freshless_logic()
func _freshless_logic():
	if has_node("Effect_files"):
		var _ANI = get_node("Effect_flies/Ani")
		if IsBroken:
			_ANI.play("Flies")
		elif IsPassDay:
			_ANI.play("OverDay")
func _on_body_entered(body: Node) -> void :
	if not IsPassDay and not IsBroken:
		var _BOOL = return_MoneyBool(body)
		if _BOOL:
			call_broken()
	GameLogic.Device.call_touch(body, self, true)
func _on_body_exited(body: Node) -> void :

	GameLogic.Device.call_touch(body, self, false)
func call_SQUEEZE_puppet(_PLAYERPATH, _SPEEDMILT, _WATERTYPE):
	var _Player = get_node(_PLAYERPATH)
	But_Switch(false, _Player)
	get_parent().remove_child(self)
	self.position = Vector2.ZERO
	_Player.RIGHTNode.add_child(self)
	_PLAYER = _Player

	_Player.Con.call_SQUEEZE(_SPEEDMILT)

	$MixNode / MixAni.playback_speed = _SPEEDMILT
	$MixNode / MixAni.play("Mixd")
	match _WATERTYPE:
		"鸡蛋液":
			_Audio = GameLogic.Audio.return_Audio("特效鸡蛋")
		_:
			_Audio = GameLogic.Audio.return_Effect("手榨果汁")
	_Audio.play(0)
func call_SQUEEZE(_CupObj, _Player):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Speed: float = 1
	var _Mult: float = 1
	_Speed = SQUEEZE_SPEED / GameLogic.return_Multiplier_Division()

	if _Player.Stat.Skills.has("技能-握力"):
		_Mult += 1
	if not _Player.Stat.Skills.has("技能-幽灵基础"):
		if GameLogic.cur_Rewards.has("尖爪手套"):
			_Mult += 1
		elif GameLogic.cur_Rewards.has("尖爪手套+"):
			_Mult += 3
		if GameLogic.cur_Challenge.has("手笨+"):
			_Mult = _Mult * 0.75
	if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
		_Mult += GameLogic.Skill.HandWorkMult
	if GameLogic.cur_Event == "手速":
		_Mult = 5

	var _SPEEDMILT = _Speed * _Mult

	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_id_sync(_SELFID, "call_SQUEEZE_puppet", [_PLAYERPATH, _SPEEDMILT, WaterType])
	But_Switch(false, _Player)
	get_parent().remove_child(self)
	self.position = Vector2.ZERO
	_Player.RIGHTNode.add_child(self)
	_PLAYER = _Player
	_CUP = _CupObj
	_Player.Con.call_SQUEEZE(_SPEEDMILT)
	$MixNode / MixAni.playback_speed = _SPEEDMILT
	$MixNode / MixAni.play("Mixd")
	_Audio.play(0)
func _Mix_Finished():
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if is_instance_valid(_PLAYER):
		_PLAYER.Con.call_reset_ArmState()
	if is_instance_valid(_CUP):
		_CUP.call_Water_In(0, self)
		match WaterType:

			"橙子汁":
				_CUP.call_Water_In(0, self)

	self.call_del()
