extends KinematicBody2D

var IsStaff: bool
var IsWork: bool

var FollowPlayer = null
var cur_Touch_Count: int
var cur_Touch_List: Array
var _Time: float
var _TimeLogic: float
var _Max = 100
var Work_Order: int

var Name: String

var WorkRate = 1

var EXP_Order = 0

var behavior_ready = null
var behavior = BEHAVIOR.IDLE

var per_diem: int

var cur_Pressure: int = 0
var cur_PressureMax: int

enum LV{
	NONE
	LOW
	NORMAL
	HIGH
	MASTER
}
enum BEHAVIOR{
	IDLE
	MOVE
	STUDY
	REST
	EAT
	DRINK
	ORDER
	CARRY
	BREW
	MAKE
	PICK
	CLEAN
	WORK
	WORK_ON
	WORK_OFF_READY
	WORK_OFF
	CALL
	SAMPLE
	INTERVIEW
	IDLE_MOVE
	READY
	WC
	WASH

	FOLLOW
}

enum SKILL{
	ORDER
	CARRY
	CLEAN
	BREW
	MAKE



}

var ActionNum: int = 1
var ActionMax: int = 9
var DayActionDic: Dictionary
var NightActionDic: Dictionary
var DailyWage: int
var AvatarID: String = "0"
var AvatarType: String = "2"
var SkillList: Array
var Fatigue: int
var EXP_LV: int
var HomePoint: Vector2

var cur_Skill_List: Array
var Lv_Order = LV.LOW

var INFO: Dictionary
var ReactionTime: float = 0.5

onready var AVATAR

var TargetPOS: Vector2
var target: Vector2
var WayPoint_array: Array
onready var Con = get_node("LogicNode/Control")
onready var Stat = get_node("LogicNode/Stat")
onready var WeaponNode
onready var BehaviorAni = get_node("LogicNode/BehaviorAni")
onready var ActionNode = get_node("Action/HBox")

onready var ReactionTimer = get_node("LogicNode/ReactionTimer")
onready var OrderTimer = get_node("LogicNode/OrderTimer")
onready var NameLabel = get_node("NameLabel")
var _Path_IsFinish: bool
var Temp_Study: Array
var cur_Work_Array: Array
var cur_Work_Num: int = 0
var cur_Work_OBJ = null

var _HoldOBJ = null
var _ExtraWork: Array

var IsCourier: bool
func _ready() -> void :

	behavior = BEHAVIOR.IDLE
	_Path_IsFinish = true

	target = self.position

	if get_parent().get_parent().name != "YSort":
		set_process(false)
		set_physics_process(false)

	var _check = GameLogic.connect("Pressure_Set", self, "call_pressure_set")
	var _CloseCheck = GameLogic.connect("CloseLight", self, "_DayEnd_Logic")
	var _HoldCheck = get_node("But/X").connect("HoldFinish", self, "_Hire")
	var _FireCheck = get_node("But/B").connect("HoldFinish", self, "call_Fire")
	ActionNode.hide()
func _P2_control_logic(_but, _value, _type):
	call_Hold(_but, _value, _type)
func _P1_control_logic(_but, _value, _type):
	call_Hold(_but, _value, _type)
func call_Hold(_but, _value, _type):

	if _value == 1 or _value == - 1:
		match _but:
			"B":

				if IsStaff and behavior_ready == BEHAVIOR.FOLLOW:
					get_node("But/B").call_holding(true)
			"X":
				if not IsStaff and GameLogic.Staff.Staff_Max > GameLogic.cur_Staff.size():
					get_node("But/X").call_holding(true)
	if _value == 0:
		match _but:
			"B":
				if IsStaff and behavior_ready == BEHAVIOR.FOLLOW:
					get_node("But/B").call_holding(false)
			"X":
				if not IsStaff:
					get_node("But/X").call_holding(false)

func _Hire():
	IsStaff = true
	call_Staff_Save()
	behavior_ready = BEHAVIOR.WORK_ON
	OrderTimer.wait_time = (4 - Lv_Order) + 0.1
	ReactionTimer.start(0)
	call_StaffInfo_Switch(false)

func call_Fire():
	behavior_ready = BEHAVIOR.WORK_OFF
	ReactionTimer.start(0)
	IsStaff = false
	if GameLogic.cur_Staff.has(Name):
		var _return = GameLogic.cur_Staff.erase(Name)
	if Con.IsHold:
		var _PutDown = {"ACT": "放地上"}
		call_HoldWork(_PutDown)
		return
func call_pressure_set(_value):
	if not IsStaff:
		return
	call_Pressure_init()
	if _value == 0:
		return
	var _Skill: Array

	cur_Pressure += _value
	if cur_Pressure < 0:
		cur_Pressure = 0

	var _Effect = GameLogic.TSCNLoad.PressureEffect_TSCN.instance()
	_Effect.Num = _value
	if _Skill:
		_Effect.Skill = _Skill
	get_node("EffectNode").add_child(_Effect)
	_Effect._Skill_logic()


	if has_node("Avatar"):
		get_node("Avatar").PressureNode.call_set(cur_Pressure, cur_PressureMax)

	if SkillList.has("技能-无精打采"):
		if cur_Pressure >= int((float(cur_PressureMax) * 0.6)):
			Stat.Ins_Skill_2_Mult = 0.7
		else:
			Stat.Ins_Skill_2_Mult = 1

	var _ReactionMult: float = 1
	if SkillList.has("技能-脑壳痛"):
		if cur_Pressure >= int((float(cur_PressureMax) * 0.6)):
			_ReactionMult += 0.5
	match GameLogic.cur_Event:
		"动员":
			_ReactionMult -= 0.25
		"动员+":
			_ReactionMult -= 0.5
	if _ReactionMult < 0.1:
		_ReactionMult = 0.1
	if INFO.has("ReactionTime"):
		ReactionTimer.wait_time = float(INFO.ReactionTime) * _ReactionMult

	if cur_Pressure >= cur_PressureMax:
		if not GameLogic.is_connected("Pressure_Set", self, "call_pressure_set"):
			GameLogic.disconnect("Pressure_Set", self, "call_pressure_set")
		BehaviorAni.play("心情_生气")
		behavior_ready = BEHAVIOR.WORK_OFF
		ReactionTimer.start(0)
		IsStaff = false
		if not SkillList.has("技能-忠诚"):
			if GameLogic.cur_Staff.has(Name):
				var _return = GameLogic.cur_Staff.erase(Name)

		if Con.IsHold:
			var _PutDown = {"ACT": "放地上"}
			call_HoldWork(_PutDown)
			return



	if GameLogic.cur_Challenge.has("身体不适"):
		if cur_Pressure >= int(float(cur_PressureMax) * 0.5):
			Stat.Ins_ChallengeMult -= 0.2
		else:
			Stat.Ins_ChallengeMult = 1
		Stat._speed_change_logic()
	if GameLogic.cur_Challenge.has("身体不适+"):
		if cur_Pressure >= int(float(cur_PressureMax) * 0.5):
			Stat.Ins_ChallengeMult -= 0.4
		else:
			Stat.Ins_ChallengeMult = 1
		Stat._speed_change_logic()
func call_Pressure_init():

	cur_PressureMax = int(GameLogic.Config.PlayerConfig[str(AvatarID)].Pressure)



	if GameLogic.Save.gameData.HomeDevList.has("猫猫照片"):
		cur_PressureMax += 5
	if GameLogic.Save.gameData.HomeDevList.has("狐狸照片"):
		cur_PressureMax += 5
	if GameLogic.Save.gameData.HomeDevList.has("灰狼照片"):
		cur_PressureMax += 5
	if GameLogic.Save.gameData.HomeDevList.has("熊熊照片"):
		cur_PressureMax += 5


	var _Mult: float = 1
	if GameLogic.cur_Challenge.has("抗压力差"):
		_Mult -= 0.1

	if GameLogic.cur_Challenge.has("抗压力差+"):
		_Mult -= 0.2

	if _Mult != 1:
		cur_PressureMax = int(float(cur_PressureMax) * _Mult)


func _StaffInfo_WorkSet():
	var _NODE = get_node("StaffInfo/WORKNUM/HBox")
	var _Array = _NODE.get_children()
	for _Node in _Array:
		_NODE.remove_child(_Node)
		_Node.queue_free()
	var _TSCN = load("res://TscnAndGd/UI/Info/StudyIcon.tscn")
	for _i in ActionMax:
		var _Node = _TSCN.instance()
		_NODE.add_child(_Node)
	ActionNode.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
func call_load(_INFO: Dictionary):

	INFO = _INFO
	if INFO.has("NAME"):
		Name = INFO.NAME
	NameLabel.text = GameLogic.CardTrans.get_message(Name)
	cur_Pressure = int(INFO.cur_Pressure)

	AvatarID = str(INFO.AvatarID)
	AvatarType = str(INFO.AvatarType)
	SkillList = INFO.SkillList

	DayActionDic = INFO.DayActionDic

	ActionMax = int(INFO.ActionMax)
	HomePoint = Vector2(INFO.HomePoint)

	var StaffINFO = GameLogic.Config.StaffConfig[AvatarID]
	var _PressureMaxMult: float = 1

	cur_PressureMax = int(float(StaffINFO.Pressure) * _PressureMaxMult)
	var _ReactionMult: float = 1
	if SkillList.has("技能-聪慧"):
		_ReactionMult = 0.5
	INFO["ReactionTime"] = float(StaffINFO.ReactionTime) * _ReactionMult
	ReactionTime = float(INFO["ReactionTime"])
	DailyWage = int(StaffINFO.DailyBase)
	var _SpeedMult: float = 1
	if SkillList.has("技能-迅捷"):
		_SpeedMult += 0.25
	INFO["MoveSpeed"] = float(StaffINFO.MoveSpeed) * _SpeedMult
	Stat.MoveSpeed = 10 + INFO["MoveSpeed"] * 5
	Stat._data_instance()
	_call_init()
	Stat.Skills = SkillList
	if has_node("Avatar"):
		get_node("Avatar").PressureNode.call_init(cur_Pressure, cur_PressureMax)
	if SkillList.has("技能-忠诚"):
		if cur_Pressure >= cur_PressureMax:
			cur_Pressure = int(float(cur_PressureMax) * 0.9)
	_StaffInfo_WorkSet()
	if not IsStaff:
		_on_ReactionTimer_timeout()

func call_HoldWork(_Work):

	var _Hold = instance_from_id(Con.HoldInsId)
	if not _Hold:
		return
	match _Work.ACT:
		"放地上":
			if Con.IsHold:

				var _Obj = instance_from_id(Con.HoldInsId)
				var _check = GameLogic.Device.call_PutOnGround(3, self, _Obj)
				return
		"摇匀":
			if _Hold.TypeStr == _Work.HOLDVALUE:
				if _Hold.has_method("return_CanMix"):
					var _Mix_bool = _Hold.return_CanMix(self)
					if _Mix_bool:
						if _Hold.TypeStr == "ShakeCup":
							Con.ArmState = GameLogic.NPC.STATE.SHAKE
						else:
							Con.ArmState = GameLogic.NPC.STATE.STIR
						var _Mult: float = 1
						if GameLogic.Player2_bool:
							_Mult = GameLogic.Player2_Mult
						var _time: float = 2 * _Mult
						if GameLogic.Achievement.cur_EquipList.has("手工增强") and not GameLogic.SPECIALLEVEL_Int:
							_time = _time * GameLogic.Skill.HandWorkMult
						if GameLogic.cur_Rewards.has("一次性手套"):
							_time = _time * 0.5
						if not GameLogic.cur_Rewards.has("一次性手套+"):
							_time = _time * 0.25
						if GameLogic.cur_Event == "手速":
							_time = 0.1

						yield(get_tree().create_timer(_time), "timeout")
						Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
						if _Hold.has_method("call_CanMix_Finish"):
							var _check = _Hold.call_CanMix_Finish()
						ReactionTimer.start(0)
						return
		"开盖":

			if _Hold.TypeStr == _Work.HOLDVALUE:
				if not _Hold.IsOpen:
					Con.call_OpenLogic(_Hold)
					yield(_Hold, "OPENED")
					Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY
					ReactionTimer.start(0)
					return

func return_HoldCheck(_Work):


	match _Work.ACT:
		"摇匀":
			return "Act"
		"开盖":


			return "Act"
func return_WorkCheck(_Work, _OBJ):

	match _Work.ACT:
		"捡":

			if not Con.IsHold:
				if _Work.ISITEM:
					return "Act"
				elif _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
					if _OBJ.OnTableObj.DeviceID != null:
						if _OBJ.OnTableObj.DeviceID == _Work.DEV:
							return "Act"
					elif _OBJ.OnTableObj.TypeStr == _Work.HOLDVALUE:
						return "Act"
		"开制冰机":
			if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
				if _OBJ.OnTableObj.TypeStr == "IceMachine":
					if not _OBJ.OnTableObj._TurnOn:
						return "Act"
					else:
						return "Pass"
		"关制冰机":
			if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
				if _OBJ.OnTableObj.TypeStr == "IceMachine":
					if _OBJ.OnTableObj._TurnOn:
						return "Act"
					else:
						return "Pass"
		"出杯":
			if _Work.OBJNAME == "WorkBench_Immovable":
				if _OBJ.OnTableObj:
					if _OBJ.OnTableObj.FuncType == "DrinkCup":
						var _FinishCheck = GameLogic.Order.return_readycheck(_OBJ.OnTableObj.cur_ID)

						if not _FinishCheck:
							if _OBJ.OnTableObj.Liquid_Count == _OBJ.OnTableObj.Liquid_Max:
								if GameLogic.Order.cur_OrderList.has(_OBJ.OnTableObj.cur_ID):
									var _INFO = GameLogic.Order.cur_OrderList[_OBJ.OnTableObj.cur_ID]
									var _ExtraDic: Dictionary
									if _OBJ.OnTableObj.Celcius != _INFO.Celcius:


										printerr("温度不对:", _OBJ.OnTableObj.Celcius, " ", _INFO.Celcius)
									if not _OBJ.OnTableObj.SugarType and _INFO.Sugar == 2:
										printerr("未加糖 且 甜度不对")
									if _INFO.ExtraArray.size():
										printerr("未加小料")

									return "Act"



		"取出饮品杯":

			if _Work.OBJNAME == "WorkBench_Immovable" and _OBJ.DeviceID == _Work.DEV:

				if _OBJ.OnTableObj:
					if _OBJ.OnTableObj.TypeStr == "CupHolder":
						var _CupHolder = _OBJ.OnTableObj
						if _CupHolder.CanTake_bool:
							if GameLogic.Order.cur_OrderList.has(_CupHolder._Take_ID):
								var _Value = GameLogic.Order.cur_OrderList[_CupHolder._Take_ID].Name
								if _Value == _Work.MENU:
									_HoldOBJ = _CupHolder.Take_DEV
									return "Act"
		"瓶子倒入杯子":

			if _Work.HOLDVALUE in ["ShakeCup", "DrinkCup_S", "DrinkCup_M", "DrinkCup_L"]:

				var _LiquidName = null
				match typeof(_Work.VALUE):
					TYPE_ARRAY:
						_LiquidName = _Work.VALUE.back()
					TYPE_STRING:
						_LiquidName = _Work.VALUE
					TYPE_NIL:
						pass

				if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
					if _OBJ.OnTableObj:

						if _OBJ.OnTableObj.TypeStr == _LiquidName:
							if _OBJ.OnTableObj.IsOpen and _OBJ.OnTableObj.Liquid_Count > 0:
								return "Act"

						if _OBJ.OnTableObj.TypeStr == "Shelf_OnTable":
							var _TableObj
							match _Work.BUT:
								0:
									if _OBJ.OnTableObj.LayerA_Obj:
										_TableObj = _OBJ.OnTableObj.LayerA_Obj
								1:
									if _OBJ.OnTableObj.LayerB_Obj:
										_TableObj = _OBJ.OnTableObj.LayerB_Obj
								2:
									if _OBJ.OnTableObj.LayerX_Obj:
										_TableObj = _OBJ.OnTableObj.LayerX_Obj
								3:
									if _OBJ.OnTableObj.LayerY_Obj:
										_TableObj = _OBJ.OnTableObj.LayerY_Obj
							if _TableObj:

								if _TableObj.TypeStr == _LiquidName:
									if _TableObj.IsOpen and _TableObj.Liquid_Count > 0:
										return "Act"
				if _OBJ.TypeStr == _LiquidName:
					if _OBJ.OnTableObj.IsOpen and _OBJ.OnTableObj.Liquid_Count > 0:
						return "Act"

	match _Work.OBJNAME:
		"Trashbin":

			if _OBJ.TypeStr != _Work.OBJNAME:
				return
			if _OBJ.DeviceID == _Work.DEV:
				match _Work.ACT:
					"取垃圾":
						if _OBJ.Trash_Count:

							return "Act"
					"入垃圾桶":

						if _OBJ.Trash_Count < _OBJ.Trash_Max:
							return "Act"
			else:
				match _Work.ACT:
					"入垃圾桶":
						if _Work.DEV > 1 and _OBJ.DeviceID > 1:
							return "Act"
		"WorkBench_Immovable":
			if _OBJ.TypeStr != _Work.OBJNAME:
				return


			match _Work.ACT:
				"捡":
					if not Con.IsHold:
						if _OBJ.OnTableObj:
							_HoldOBJ = _OBJ.OnTableObj
							return "Act"
				"拆箱":
					if _OBJ.OnTableObj and not Con.IsHold:
						if _OBJ.OnTableObj.TypeStr == "Box_M_Paper":
							if not _OBJ.OnTableObj.HasItem:
								return "Act"
					return "Pass"
				"放桌上":

					if _HoldOBJ == _OBJ.OnTableObj:
						_HoldOBJ = null
						return "Act"
					if not _OBJ.OnTableObj:
						_HoldOBJ = null
						return "Act"

				"开箱":
					var _Box = _OBJ.OnTableObj
					if _Box:
						if _Box.TypeStr == "Box_M_Paper":
							if not _Box.IsOpen:
								return "Act"
							else:
								return "Pass"
				"箱中取":
					var _Box = _OBJ.OnTableObj

					if _Box:

						if _Box.TypeStr == "Box_M_Paper":
							var _ItemName: String = _Box.ItemName
							if _Box.ItemName == "DrinkCup_S":
								_ItemName = "DrinkCup_Group_S"
							elif _Box.ItemName == "DrinkCup_M":
								_ItemName = "DrinkCup_Group_M"
							elif _Box.ItemName == "DrinkCup_L":
								_ItemName = "DrinkCup_Group_L"
							if _ItemName == _Work.HOLDVALUE:
								if _Box.HasItem:
									_HoldOBJ = _Box.ItemOBJ_Array.back()

									return "Act"
				"放入杯组":
					var _CupHolder = _OBJ.OnTableObj
					if _CupHolder:

						if _CupHolder.TypeStr == "CupHolder":

							if _HoldOBJ:

								match _HoldOBJ.TypeStr:
									"DrinkCup_Group_S":
										if _CupHolder.S_Num + 10 <= _CupHolder.Cup_Max:
											return "Act"
									"DrinkCup_Group_M":
										if _CupHolder.M_Num + 10 <= _CupHolder.Cup_Max:
											return "Act"
									"DrinkCup_Group_L":
										if _CupHolder.L_Num + 10 <= _CupHolder.Cup_Max:
											return "Act"
		"WorkBench":
			if _OBJ.TypeStr != _Work.OBJNAME:
				return

			if _OBJ.DeviceID == _Work.DEV:
				match _Work.ACT:
					"捡":

						if not Con.IsHold:
							if _OBJ.OnTableObj:
								_HoldOBJ = _OBJ.OnTableObj
								return "Act"
					"拆箱":
						if _OBJ.OnTableObj and not Con.IsHold:
							if _OBJ.OnTableObj.TypeStr == "Box_M_Paper":
								if not _OBJ.OnTableObj.HasItem:
									return "Act"
						return "Pass"
					"加水":
						var _WaterTank = _OBJ.OnTableObj
						if _WaterTank.TypeStr == "WaterTank":
							if _HoldOBJ:

								if _HoldOBJ.FuncType in ["DrinkCup", "ShakeCup"]:
									if _HoldOBJ.Liquid_Count < _HoldOBJ.Liquid_Max:
										return "Act"
					"瓶子倒入杯子":
						var _Bottle = _OBJ.OnTableObj
						if _Bottle:

							if _Bottle.FuncType == "Bottle":
								if _Bottle.Liquid_Count > 0:
									if _HoldOBJ:
										if _HoldOBJ.FuncType in ["DrinkCup", "ShakeCup"]:
											if _HoldOBJ.Liquid_Count < _HoldOBJ.Liquid_Max:

												return "Act"
					"台架放入":
						var _Shelf = _OBJ.OnTableObj
						if _Shelf.TypeStr == "Shelf_OnTable":
							match _Work.BUT:
								0:
									if not _Shelf.LayerA_Obj or _Shelf.LayerA_Obj == _HoldOBJ:
										_HoldOBJ = null
										return "Act"
								1:
									if not _Shelf.LayerB_Obj or _Shelf.LayerB_Obj == _HoldOBJ:
										_HoldOBJ = null
										return "Act"
								2:
									if not _Shelf.LayerX_Obj or _Shelf.LayerX_Obj == _HoldOBJ:
										_HoldOBJ = null
										return "Act"
								3:
									if not _Shelf.LayerY_Obj or _Shelf.LayerY_Obj == _HoldOBJ:
										_HoldOBJ = null
										return "Act"
					"台架取出":
						var _Shelf = _OBJ.OnTableObj
						if _Shelf.TypeStr == "Shelf_OnTable":
							var _Obj = null
							match _Work.BUT:
								0:
									if _Shelf.LayerA_Obj:
										_Obj = _Shelf.LayerA_Obj
								1:
									if _Shelf.LayerB_Obj:
										_Obj = _Shelf.LayerB_Obj
								2:
									if _Shelf.LayerX_Obj:
										_Obj = _Shelf.LayerX_Obj
								3:
									if _Shelf.LayerY_Obj:
										_Obj = _Shelf.LayerY_Obj
							if _Obj:
								if _Obj.TypeStr == _Work.HOLDVALUE:

									match _Work.HOLDVALUE:
										"ShakeCup":

											pass
					"放桌上":

						if not _HoldOBJ:
							return "Act"
						if not _OBJ.OnTableObj:
							_HoldOBJ = null
							return "Act"
					"开箱":
						var _Box = _OBJ.OnTableObj
						if _Box:
							if _Box.TypeStr == "Box_M_Paper":
								if not _Box.IsOpen:
									return "Act"
								else:
									return "Pass"
					"箱中取":
						var _Box = _OBJ.OnTableObj

						if _Box:

							if _Box.TypeStr == "Box_M_Paper":
								var _ItemName: String = _Box.ItemName
								if _Box.ItemName == "DrinkCup_S":
									_ItemName = "DrinkCup_Group_S"
								elif _Box.ItemName == "DrinkCup_M":
									_ItemName = "DrinkCup_Group_M"
								elif _Box.ItemName == "DrinkCup_L":
									_ItemName = "DrinkCup_Group_L"
								if _ItemName == _Work.HOLDVALUE:
									if _Box.HasItem:
										_HoldOBJ = _Box.ItemOBJ_Array.back()
										return "Act"
					"加冰":
						if _OBJ.OnTableObj:
							if _OBJ.OnTableObj.TypeStr == "IceMachine":
								if _OBJ.OnTableObj.cur_Ice > 0:
									return "Act"
					"加糖":
						if _OBJ.OnTableObj:
							if _OBJ.OnTableObj.TypeStr == "SugarMachine":
								if _OBJ.OnTableObj.cur_sugar > 0:
									return "Act"
					"补糖":
						if _OBJ.OnTableObj:

							if _OBJ.OnTableObj.TypeStr == "SugarMachine":
								if _OBJ.OnTableObj.cur_sugar + 10 <= _OBJ.OnTableObj.sugar_max:

									_HoldOBJ = null
									return "Act"
								else:
									return
		"Trashbag":

			if _OBJ.TypeStr != _Work.OBJNAME:
				return
			if _OBJ.DeviceID == _Work.DEV and not Con.IsHold:
				match _Work.ACT:
					"捡":
						return "Act"
		"Box_M_Paper":

			if _OBJ.TypeStr != _Work.OBJNAME:
				return
			if not Con.IsHold:
				if _Work.ACT == "拆箱":
					if not _OBJ.HasItem:
						return "Act"
				if str(_OBJ.DeviceID) == str(_Work.DEV) or _OBJ.ItemName == str(_Work.DEV):
					printerr(_Work.ACT, " 工作判断：")
					match _Work.ACT:
						"捡":
							_HoldOBJ = _OBJ
							return "Act"
						"拆箱":
							if not _OBJ.HasItem:
								return "Act"
							else:
								return "Pass"
						"开箱":
							if not _OBJ.IsOpen:
								return "Act"
							else:
								return "Pass"
						"箱中取":
							if _OBJ.HasItem:
								_HoldOBJ = _OBJ

								return "Act"
							else:
								return
		"Shelf":
			if _OBJ.TypeStr != _Work.OBJNAME:
				return

			if _OBJ.DeviceID == int(_Work.DEV):
				match _Work.ACT:
					"拿":
						match _Work.BUT:
							0:
								if _OBJ.Layer1_Item == _Work.HOLDVALUE:
									_HoldOBJ = _OBJ.layer1_Array.back()
									return "Act"
							1:
								if _OBJ.Layer2_Item == _Work.HOLDVALUE:
									_HoldOBJ = _OBJ.layer2_Array.back()
									return "Act"
							2:
								if _OBJ.Layer3_Item == _Work.HOLDVALUE:
									_HoldOBJ = _OBJ.layer3_Array.back()
									return "Act"
							3:
								if _OBJ.Layer4_Item == _Work.HOLDVALUE:
									_HoldOBJ = _OBJ.layer4_Array.back()
									return "Act"
					"放":
						if not Con.IsHold:
							return "Pass"
						var _Hold = instance_from_id(Con.HoldInsId)
						match _Work.BUT:
							0:
								if _OBJ.Layer1_Weight + _Hold.Weight <= 8:
									_HoldOBJ = null
									return "Act"
								else:
									return "Pass"
							1:
								if _OBJ.Layer2_Weight + _Hold.Weight <= 8:
									_HoldOBJ = null
									return "Act"
								else:
									return "Pass"
							2:
								if _OBJ.Layer3_Weight + _Hold.Weight <= 8:
									_HoldOBJ = null
									return "Act"
								else:
									return "Pass"
							3:
								if _OBJ.Layer4_Weight + _Hold.Weight <= 8:
									_HoldOBJ = null
									return "Act"
								else:
									return "Pass"
		_:
			print("工作判断 暂未添加 物体：", _Work.OBJNAME, " 行为:", _Work.ACT, " 按键：", _Work.BUT, " 参数：", _Work.DEV)
	return null
func return_ready_WORK_Logic(_WorkList: Array):


	if not GameLogic.Staff.LevelNode:
		return
	if not is_instance_valid(GameLogic.Staff.LevelNode):
		print("LevelNode 不存在")
		return
	var _CheckList: Array
	var _CheckNum: int = 0
	for _Work in _WorkList:
		_CheckList.append(false)

		var _LevelYSortNode

		var _HoldCheck = return_HoldCheck(_Work)
		if _Work.HOLD and _HoldCheck:
			_CheckList[_CheckNum] = _HoldCheck
		else:
			if _Work.ISITEM:
				_LevelYSortNode = "YSort/Items"
			else:
				_LevelYSortNode = "YSort/Devices"
			if GameLogic.Staff.LevelNode.has_node(_LevelYSortNode):
				var _ItemYSort = GameLogic.Staff.LevelNode.get_node(_LevelYSortNode)

				for _Node in _ItemYSort.get_children():
					if _Node.TypeStr == _Work.OBJNAME:
						var _check = return_WorkCheck(_Work, _Node)
						if _check != null:
							_CheckList[_CheckNum] = _check
							break

				match _Work.OBJNAME:
					"Trashbag":
						var _Num: int = 0
						for _OldWork in _WorkList:
							_Num += 1
							print("检查逻辑：", _Num, _CheckNum)
							if _Num > _CheckNum:
								break

							if _OldWork.ACT in ["拆箱"]:
								_CheckList[_CheckNum] = "Pass"
			if GameLogic.Staff.LevelNode.has_node("YSort/Outdoor"):
				for _Node in GameLogic.Staff.LevelNode.get_node("YSort/Outdoor").get_children():
					if _Node.has_method("_ready"):
						if _Node.TypeStr == _Work.OBJNAME:
							var _check = return_WorkCheck(_Work, _Node)
							if _check != null:
								_CheckList[_CheckNum] = _check
								break
			else:
				printerr("工作判断错误：", _Work)
		_CheckNum += 1

	_HoldOBJ = null
	if not false in _CheckList:
		return BEHAVIOR.WORK
	else:
		return null
func call_Work_Logic():

	if cur_Work_Num < 0:
		cur_Work_Num = 0
	if cur_Work_Array.size() > cur_Work_Num:

		if SkillList.has("技能-笨手笨脚"):
			if Con.IsHold:
				var _rand = GameLogic.return_randi() % 10
				if not _rand:
					var _PutDown = {"ACT": "放地上"}
					call_HoldWork(_PutDown)
					cur_Work_Array.clear()
					ReactionTimer.start(0)
					return

		var _Work = cur_Work_Array[cur_Work_Num]

		var _LevelYSortNode
		if _Work.HOLD:
			var _Logic = return_HoldCheck(_Work)

			match _Logic:
				"Act":
					call_HoldWork(_Work)
					cur_Work_Num += 1

					return
				"Pass":
					cur_Work_Num += 1
					call_Work_Logic()

					return
		if _Work.ISITEM:
			_LevelYSortNode = "YSort/Items"
		else:
			_LevelYSortNode = "YSort/Devices"
		if cur_Work_OBJ == null:
			if GameLogic.Staff.LevelNode.has_node(_LevelYSortNode):
				var _ItemYSort = GameLogic.Staff.LevelNode.get_node(_LevelYSortNode)
				for _Node in _ItemYSort.get_children():
					if _Node.TypeStr == str(_Work.OBJNAME):
						var _Logic = return_WorkCheck(_Work, _Node)

						match _Logic:
							"Act":
								cur_Work_OBJ = _Node
								TargetPOS = cur_Work_OBJ.global_position
								_move_to_OBJ_AllWays(TargetPOS)

								return
							"Pass":
								cur_Work_Num += 1
								call_Work_Logic()

								return
			if GameLogic.Staff.LevelNode.has_node("YSort/Outdoor"):
				for _Node in GameLogic.Staff.LevelNode.get_node("YSort/Outdoor").get_children():
					if _Node.has_method("_ready"):
						if _Node.TypeStr == _Work.OBJNAME:
							var _Logic = return_WorkCheck(_Work, _Node)

							match _Logic:
								"Act":
									cur_Work_OBJ = _Node
									TargetPOS = cur_Work_OBJ.global_position
									_move_to_OBJ_AllWays(TargetPOS)

									return
								"Pass":
									cur_Work_Num += 1
									call_Work_Logic()

									return


				call_BackToIDLE()
				return
		else:

			if is_instance_valid(cur_Work_OBJ):

				var _direction = (cur_Work_OBJ.global_position - self.position).normalized()
				Con.input_vector = _direction

				var _return
				match _Work.ACT:
					"出杯":
						if cur_Work_OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
							if cur_Work_OBJ.OnTableObj:
								if cur_Work_OBJ.OnTableObj.FuncType == "DrinkCup":
									var _FinishCheck = GameLogic.Order.return_readycheck(cur_Work_OBJ.OnTableObj.cur_ID)

									if not _FinishCheck:
										_return = cur_Work_OBJ.call_pickup_logic(_Work.BUT)
					"捡":
						if not Con.IsHold:
							if cur_Work_OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
								if cur_Work_OBJ.OnTableObj:
									if cur_Work_OBJ.OnTableObj.TypeStr == str(_Work.HOLDVALUE):
										_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ)
							else:
								if cur_Work_OBJ.TypeStr == _Work.OBJNAME:
									if cur_Work_OBJ.get_parent().name == "Items":
										var _WayCheckList = GameLogic.Astar.return_WayPoint_Array(self.position, cur_Work_OBJ.global_position)
										if _WayCheckList.size() == 0:
											_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ)
					"放桌上":
						if Con.IsHold:
							if cur_Work_OBJ.TypeStr == _Work.OBJNAME:
								_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ)
					"放":
						if Con.IsHold:
							if cur_Work_OBJ.TypeStr == _Work.OBJNAME:
								if cur_Work_OBJ.TypeStr == "Shelf":
									var _BUT: int = - 1
									var _ShelfYSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
									var _ShelfNode
									var _ShelfList: Array
									var _Hold = instance_from_id(Con.HoldInsId)
									var _OBJNAME: String = _Hold.TypeStr
									if _OBJNAME == "DrinkCup_S":
										_OBJNAME = "DrinkCup_Group_S"
									elif _OBJNAME == "DrinkCup_M":
										_OBJNAME = "DrinkCup_Group_M"
									elif _OBJNAME == "DrinkCup_L":
										_OBJNAME = "DrinkCup_Group_L"
									for _Shelf in _ShelfYSort.get_children():
										if _Shelf.TypeStr == "Shelf":
											_ShelfList.append(_Shelf)
											if _Shelf.Layer1_Item == _OBJNAME:
												if _Shelf.Layer1_Weight + _Hold.Weight <= 8:
													_BUT = 0
													_ShelfNode = _Shelf
											if _Shelf.Layer2_Item == _OBJNAME and _BUT == - 1:
												if _Shelf.Layer2_Weight + _Hold.Weight <= 8:
													_BUT = 1
													_ShelfNode = _Shelf
											if _Shelf.Layer3_Item == _OBJNAME and _BUT == - 1:
												if _Shelf.Layer3_Weight + _Hold.Weight <= 8:
													_BUT = 2
													_ShelfNode = _Shelf
											if _Shelf.Layer4_Item == _OBJNAME and _BUT == - 1:
												if _Shelf.Layer4_Weight + _Hold.Weight <= 8:
													_BUT = 3
													_ShelfNode = _Shelf
									if _BUT == - 1:
										for _Shelf in _ShelfList:
											if not _Shelf.Layer1_Item:
												_BUT = 0
												_ShelfNode = _Shelf
												break
											if not _Shelf.Layer2_Item:
												_BUT = 1
												_ShelfNode = _Shelf
												break
											if not _Shelf.Layer3_Item:
												_BUT = 2
												_ShelfNode = _Shelf
												break
											if not _Shelf.Layer4_Item:
												_BUT = 3
												_ShelfNode = _Shelf
												break
									if _ShelfNode and _BUT != - 1:
										_return = GameLogic.Device._call_FuncCheckLogic(_BUT, self, _ShelfNode)
								else:
									_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ)
					_:
						if cur_Work_OBJ.TypeStr == _Work.OBJNAME:
							if cur_Work_OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
								if cur_Work_OBJ.OnTableObj:
									_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ.OnTableObj)

								else:
									_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ)
							else:
								_return = GameLogic.Device._call_FuncCheckLogic(_Work.BUT, self, cur_Work_OBJ)

				cur_Work_OBJ = null
				cur_Work_Num += 1

				if _return:
					ReactionTimer.start(0)
				else:
					_on_ReactionTimer_timeout()
			else:
				call_BackToIDLE()

	else:


		if Con.IsHold:

			if SkillList.has("技能-丢垃圾"):
				cur_Work_Array = [{"ACT": "入垃圾桶",
				"BUT": 0,
				"DEV": 1,
				"HOLD": false,
				"HOLDITEM": false,
				"HOLDVALUE": null,
				"ISITEM": false,
				"MENU": null,
				"OBJNAME": "Trashbin",
				"VALUE": null}]
				cur_Work_Num = 0
				ReactionTimer.start(0)
				return
			else:

				var _PutDown = {"ACT": "放地上"}
				call_HoldWork(_PutDown)
				ReactionTimer.start(0)
				return

		call_BackToIDLE()
func call_BackToIDLE():
	if cur_Work_OBJ != null:

		ReactionTimer.start(0)
		return
	cur_Work_OBJ = null
	cur_Work_Num = 0
	_HoldOBJ = null
	behavior = BEHAVIOR.IDLE
	behavior_ready = null

	ReactionTimer.start(0)

func _call_InStore_RandomMove():
	var _FinalTarget = GameLogic.NPC.return_inStorePoint()
	_Path_IsFinish = false
	behavior = BEHAVIOR.MOVE
	target = self.position
	WayPoint_array = GameLogic.Astar.return_NPC_WayPoint_Array(self.position, _FinalTarget)

func _on_ReactionTimer_timeout() -> void :

	if not IsStaff:

		if not behavior_ready and GameLogic.LoadingUI.IsLevel and not GameLogic.LoadingUI.Is_Loading:
			behavior_ready = BEHAVIOR.INTERVIEW
			_call_InStore_RandomMove()

			yield(get_tree().create_timer(1.0), "timeout")
			ReactionTimer.start(0)

			return
	if IsStaff:

		if cur_Pressure >= cur_PressureMax:
			behavior_ready = BEHAVIOR.WORK_OFF
			if FollowPlayer != null:
					call_Study_Finish()
			if BehaviorAni.assigned_animation != "心情_生气":
				BehaviorAni.play("心情_生气")
		if Con.ArmState in [GameLogic.NPC.STATE.SHAKE, GameLogic.NPC.STATE.STIR, GameLogic.NPC.STATE.WORK]:

			ReactionTimer.start(0)
			return

		if SkillList.has("技能-肠胃不适"):
			if _Path_IsFinish:
				var _rand = GameLogic.return_randi() % 20
				if not _rand:
					if Con.IsHold:
						var _PutDown = {"ACT": "放地上"}
						call_HoldWork(_PutDown)
					behavior_ready = BEHAVIOR.WC
		if SkillList.has("技能-怕孤独"):
			if _BodyList.size():
				var _rand = GameLogic.return_randi() % 10
				if not _rand:
					call_pressure_set(1)
		if SkillList.has("技能-开心果"):
			if _BodyList.size():
				var _rand = GameLogic.return_randi() % 10
				if not _rand:
					for _BODY in _BodyList:
						if _BODY.has_method("call_pressure_set"):
							_BODY.call_pressure_set(1)

	if _Path_IsFinish:

		if not WayPoint_array.size():
			if not behavior_ready in [BEHAVIOR.FOLLOW, BEHAVIOR.STUDY]:
				if behavior_ready in [BEHAVIOR.WORK_ON, BEHAVIOR.WORK_OFF_READY]:
					if Con.IsHold:
						var _PutDown = {"ACT": "放地上"}
						call_HoldWork(_PutDown)
					if abs(GameLogic.Staff.StaffLocker_OBJ.global_position.x - self.position.x) >= 150 or abs(GameLogic.Staff.StaffLocker_OBJ.global_position.y - self.position.y) >= 150:

						_move_to_StaffLocker()
						if WayPoint_array:
							_on_ReactionTimer_timeout()
							return
				elif cur_Work_OBJ:

					if abs(TargetPOS.x) - abs(self.position.x) >= 150 or abs(TargetPOS.y) - abs(self.position.y) >= 150:
						_move_to_OBJ_AllWays(TargetPOS)
						if WayPoint_array:
							_on_ReactionTimer_timeout()
							return

		match behavior_ready:
			BEHAVIOR.INTERVIEW:
				var _rand = 30 + GameLogic.return_randi() % 30
				OrderTimer.wait_time = _rand

				OrderTimer.start(0)

			BEHAVIOR.WC:
				if abs(self.position.x) - abs(HomePoint.x) < 100 and abs(self.position.y) - abs(HomePoint.y) < 100:
					behavior_ready = null
					_call_StaffStore_RandomMove()
					ReactionTimer.start(0)
					return
				else:
					Stat.Ins_Skill_3_Mult = 1.75
					_move_to_OBJ_AllWays(HomePoint)
					_on_ReactionTimer_timeout()
			BEHAVIOR.WORK_OFF_READY:

				behavior_ready = BEHAVIOR.WORK_OFF
				ReactionTimer.start(0)
				return
			BEHAVIOR.WORK_OFF:
				_move_to_OBJ_AllWays(HomePoint)
			BEHAVIOR.ORDER:
				call_ORDER_Logic()
				return

			BEHAVIOR.FOLLOW:
				behavior = BEHAVIOR.FOLLOW
				_Path_IsFinish = false
			BEHAVIOR.STUDY:
				behavior = BEHAVIOR.STUDY
				_Path_IsFinish = false
			BEHAVIOR.WORK:
				call_Work_Logic()
			BEHAVIOR.WORK_ON:
				behavior_ready = null

				behavior = BEHAVIOR.IDLE
				IsWork = true
				ReactionTimer.start(0)
				return

	match behavior:
		BEHAVIOR.FOLLOW:
			behavior_ready = BEHAVIOR.FOLLOW
			_move_to_Follow()
		BEHAVIOR.STUDY:

			behavior_ready = BEHAVIOR.STUDY
			_move_to_Follow()
		BEHAVIOR.MOVE:
			match behavior_ready:
				BEHAVIOR.ORDER:

					call_ORDER_Logic()
				BEHAVIOR.STUDY:
					_move_to_Follow()

		BEHAVIOR.IDLE:

			return_IDLE_Logic()
		BEHAVIOR.ORDER:

			if GameLogic.Order.cur_LineUpArray.size():

				Con.input_vector = GameLogic.Staff.OrderTab_direction
				Con.ArmState = GameLogic.NPC.STATE.ORDER

				if OrderTimer.is_stopped():
					OrderTimer.start(0)
			else:
				behavior = BEHAVIOR.IDLE
				Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY

				ReactionTimer.start(0)
	_Behavior_Show()
func _Behavior_Show():

	match behavior_ready:
		BEHAVIOR.FOLLOW:
			if BehaviorAni.assigned_animation != "FOLLOW":
				BehaviorAni.play("FOLLOW")
		BEHAVIOR.STUDY:
			if BehaviorAni.assigned_animation != "学习":
				BehaviorAni.play("学习")
		BEHAVIOR.ORDER:
			if BehaviorAni.assigned_animation != "点单":
				BehaviorAni.play("点单")
		BEHAVIOR.WORK:
			if BehaviorAni.assigned_animation != "WORK":
				BehaviorAni.play("WORK")
		BEHAVIOR.WORK_ON:
			if BehaviorAni.assigned_animation != "上班":
				BehaviorAni.play("上班")
		BEHAVIOR.WORK_OFF, BEHAVIOR.WORK_OFF_READY:
			if BehaviorAni.assigned_animation != "下班":
				BehaviorAni.play("下班")
		null:
			match behavior:
				BEHAVIOR.IDLE:
					BehaviorAni.play("IDLE")
				BEHAVIOR.MOVE:

					if Con.velocity == Vector2.ZERO:
						BehaviorAni.play("MOVE")
					else:
						BehaviorAni.play("IDLE")
func _on_OrderTimer_timeout() -> void :

	if not IsStaff:
		if behavior_ready == BEHAVIOR.INTERVIEW:
			behavior_ready = BEHAVIOR.WORK_OFF
			_on_ReactionTimer_timeout()
	else:
		if GameLogic.Order.cur_LineUpArray.size():
			GameLogic.Order.call_order()
		Con.ArmState = GameLogic.NPC.STATE.IDLE_EMPTY

		ReactionTimer.start(0)
func _call_init():
	_Avatar_Set()
	OrderTimer.wait_time = (4 - Lv_Order) + 0.1
	ReactionTimer.wait_time = float(ReactionTime)
	_DayAction_Init()
	_ActionIcon_init()
	self.add_to_group("STAFF")
func call_del():

	self.queue_free()
func _DayAction_Init():
	if SkillList.has("技能-自动点单"):
		if not DayActionDic.has("点单"):
			DayActionDic["点单"] = [{
				"ACT": "点单",
				"BUT": 0,
				"DEV": 1,
				"HOLD": false,
				"HOLDITEM": false,
				"HOLDVALUE": null,
				"ISITEM": false,
				"MENU": null,
				"OBJNAME": "WorkBench_Immovable",
				"VALUE": null
				}]
	if SkillList.has("技能-自动出杯"):
		if not DayActionDic.has("出杯"):
			DayActionDic["出杯"] = [{
				"ACT": "出杯",
				"BUT": 3,
				"DEV": null,
				"HOLD": false,
				"HOLDITEM": false,
				"HOLDVALUE": null,
				"ISITEM": false,
				"MENU": null,
				"OBJNAME": "WorkBench_Immovable",
				"VALUE": null
				}]
func _ActionIcon_init():
	var _Array = ActionNode.get_children()
	for _Node in _Array:
		ActionNode.remove_child(_Node)
		_Node.queue_free()
	var _TSCN = load("res://TscnAndGd/UI/Info/StudyIcon.tscn")
	for _i in ActionMax:
		var _Node = _TSCN.instance()
		ActionNode.add_child(_Node)
	ActionNode.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
func _ActionIcon_Show():

	if ActionNode.get_child_count() >= Temp_Study.size():
		var _Node = ActionNode.get_child(Temp_Study.size() - 1)
		_Node.get_node("1/Ani").play("Act")
func _ActionIcon_reset():
	for _Node in ActionNode.get_children():
		_Node.get_node("1/Ani").play("init")
func _Avatar_Set():
	if GameLogic.LoadingUI.IsLevel:
		if not GameLogic.Config.StaffConfig.has(AvatarID):
			print("错误，无法读取员工AvatarID:", AvatarID, GameLogic.Config.StaffConfig)
			return
		var _AvatarTSCN = GameLogic.Config.StaffConfig[AvatarID].TSCN
		var _TSCN = GameLogic.TSCNLoad.return_character(_AvatarTSCN)
		var _Avatar = _TSCN.instance()
		_Avatar.name = "Avatar"
		self.add_child(_Avatar)

		AVATAR = _Avatar
		_Avatar.call_HeadType(AvatarType)
		_Avatar.get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Body/HeadPose/Head/Texturenode").call_set(cur_Pressure, cur_PressureMax)
		WeaponNode = _Avatar.get_node("SpriteTex/Top_note/All_note/Body_note/BodyPose/Arm_Hold/Pose_Hold/Weapon_note")
func return_REST_Logic():


	pass
func _call_StaffStore_RandomMove():
	var _FinalTarget = GameLogic.Staff.return_StaffStorePoint()
	if _FinalTarget != null and _FinalTarget != self.position:
		_Path_IsFinish = false
		if GameLogic.Staff.Staff_Order == self:
			GameLogic.Staff.Staff_Order = null
		behavior = BEHAVIOR.MOVE
		target = self.position
		WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _FinalTarget)

func return_IDLE_Logic():

	if IsStaff:

		if not behavior_ready and SkillList.has("技能-倒垃圾临时工"):
				if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime - 0.5:
					print("垃圾工行动时间")
					IsWork = true
					if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
						var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
						for _TRASH in _YSort.get_children():
							if _TRASH.TypeStr == "Trashbin":
								if _TRASH.Trash_Count > 0:
									cur_Work_Array = [{
										"ACT": "取垃圾",
										"BUT": 2,
										"DEV": 1,
										"HOLD": true,
										"HOLDITEM": true,
										"HOLDVALUE": "Trashbag",
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null},
										{"ACT": "入垃圾桶",
										"BUT": 0,
										"DEV": 2,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null
										}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return
		if behavior_ready == null:
			if not behavior_ready and SkillList.has("技能-偶尔早退"):
				if GameLogic.GameUI.CurTime >= (GameLogic.cur_CloseTime - 1) and IsWork:
					var _Rand = GameLogic.return_randi() % 20
					if _Rand == 0:
						IsWork = false
						behavior_ready = BEHAVIOR.WORK_OFF_READY

						_on_ReactionTimer_timeout()
						return
			if not behavior_ready and SkillList.has("技能-夜间关机器"):
				if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime and IsWork:

					if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
						var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
						for _WORKBENCH in _YSort.get_children():
							if _WORKBENCH.TypeStr == "WorkBench" and _WORKBENCH.OnTableObj:
								if _WORKBENCH.OnTableObj.TypeStr == "IceMachine":
									if _WORKBENCH.OnTableObj._TurnOn:
										cur_Work_Array = [{
											"ACT": "关制冰机",
											"BUT": 2,
											"DEV": _WORKBENCH.DeviceID,
											"HOLD": false,
											"HOLDITEM": false,
											"HOLDVALUE": null,
											"ISITEM": false,
											"MENU": null,
											"OBJNAME": "WorkBench",
											"VALUE": null,
											}]
										behavior_ready = BEHAVIOR.WORK

										_on_ReactionTimer_timeout()
										return
			if not behavior_ready and SkillList.has("技能-夜间倒垃圾"):
				if GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime and IsWork:
					if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
						var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
						for _TRASH in _YSort.get_children():
							if _TRASH.TypeStr == "Trashbin":
								if _TRASH.Trash_Count > 0:
									cur_Work_Array = [{
										"ACT": "取垃圾",
										"BUT": 2,
										"DEV": 1,
										"HOLD": true,
										"HOLDITEM": true,
										"HOLDVALUE": "Trashbag",
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null},
										{"ACT": "入垃圾桶",
										"BUT": 0,
										"DEV": 2,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null
										}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return

			if not behavior_ready and GameLogic.GameUI.CurTime >= GameLogic.cur_CloseTime and IsWork:

				if not has_node("Tutorial_Devil"):
					IsWork = false

		if IsWork:

			if behavior_ready == null:
				for _Dic in DayActionDic:
					var _Front = DayActionDic[_Dic].front()
					match _Front.ACT:
						"点单":
							behavior_ready = return_ready_ORDER_Logic()
							if behavior_ready != null:

								ReactionTimer.start(0)
								return
					behavior_ready = return_ready_WORK_Logic(DayActionDic[_Dic])
					if behavior_ready != null:
						cur_Work_Array = DayActionDic[_Dic]

						ReactionTimer.start(0)
						return

			if not behavior_ready and SkillList.has("技能-发脾气"):
				var _rand = GameLogic.return_randi() % 10
				if not _rand:
					BehaviorAni.play("心情_吵架")
					for _BODY in _BodyList:
						_BODY.call_pressure_set(1)
			if not behavior_ready and SkillList.has("技能-洁癖"):
				var _rand = GameLogic.return_randi() % 5
				if not _rand:
					behavior_ready = BEHAVIOR.WASH
					ReactionTimer.start(0)
			if not behavior_ready and SkillList.has("技能-补货"):
				if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
					for _OBJ in _YSort.get_children():
						if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
							if _OBJ.OnTableObj.TypeStr == "SugarMachine":
								if (int(_OBJ.OnTableObj.sugar_max) - int(_OBJ.OnTableObj.cur_sugar)) >= 10:
									var _return = return_Take_Shelf(_OBJ, "Sugar")

									if _return:

										_on_ReactionTimer_timeout()
										return
							if _OBJ.OnTableObj.TypeStr == "CupHolder":

								if (int(_OBJ.OnTableObj.Cup_Max) - int(_OBJ.OnTableObj.S_Num)) >= 10:
									var _return = return_Take_Shelf(_OBJ, "DrinkCup_Group_S")
									if _return:
										_on_ReactionTimer_timeout()
										return
								if (int(_OBJ.OnTableObj.Cup_Max) - int(_OBJ.OnTableObj.M_Num)) >= 10:
									var _return = return_Take_Shelf(_OBJ, "DrinkCup_Group_M")
									if _return:
										_on_ReactionTimer_timeout()
										return
								if (int(_OBJ.OnTableObj.Cup_Max) - int(_OBJ.OnTableObj.L_Num)) >= 10:
									var _return = return_Take_Shelf(_OBJ, "DrinkCup_Group_L")
									if _return:
										_on_ReactionTimer_timeout()
										return
			if not behavior_ready and SkillList.has("技能-早班"):
				if GameLogic.GameUI.CurTime >= GameLogic.cur_OpenTime:
					pass
				elif GameLogic.Staff.LevelNode.has_node("YSort/Devices"):

					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
					for _OBJ in _YSort.get_children():
						if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
							if _OBJ.OnTableObj.TypeStr == "IceMachine":
								if not _OBJ.OnTableObj._TurnOn:
									cur_Work_Array = [{
										"ACT": "开制冰机",
										"BUT": 2,
										"DEV": _OBJ.DeviceID,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": _OBJ.TypeStr,
										"VALUE": null,
										}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return
			if not behavior_ready and SkillList.has("技能-丢垃圾"):
				if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
					for _OBJ in _YSort.get_children():
						if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
							if _OBJ.OnTableObj.TypeStr == "Box_M_Paper":
								if not _OBJ.OnTableObj.ItemOBJ_Array:
									cur_Work_Array = [{
										"ACT": "拆箱",
										"BUT": 2,
										"DEV": _OBJ.DeviceID,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": _OBJ.TypeStr,
										"VALUE": null,
										}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return
							if _OBJ.OnTableObj.FuncType == "Bottle":
								if _OBJ.OnTableObj.Liquid_Count == 0:
									cur_Work_Array = [{
										"ACT": "捡",
										"BUT": 0,
										"DEV": _OBJ.DeviceID,
										"HOLD": false,
										"HOLDITEM": true,
										"HOLDVALUE": _OBJ.OnTableObj.TypeStr,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": _OBJ.TypeStr,
										"VALUE": null},
										{"ACT": "入垃圾桶",
										"BUT": 0,
										"DEV": 1,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return
							if _OBJ.OnTableObj.FuncType == "Can":
								if _OBJ.OnTableObj.Num == 0:
									cur_Work_Array = [{
										"ACT": "捡",
										"BUT": 0,
										"DEV": _OBJ.DeviceID,
										"HOLD": false,
										"HOLDITEM": true,
										"HOLDVALUE": _OBJ.OnTableObj.TypeStr,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": _OBJ.TypeStr,
										"VALUE": null},
										{"ACT": "入垃圾桶",
										"BUT": 0,
										"DEV": 1,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return
							if _OBJ.OnTableObj.FuncType == "Trashbag":
								cur_Work_Array = [{
									"ACT": "捡",
									"BUT": 0,
									"DEV": _OBJ.DeviceID,
									"HOLD": false,
									"HOLDITEM": true,
									"HOLDVALUE": _OBJ.OnTableObj.TypeStr,
									"ISITEM": false,
									"MENU": null,
									"OBJNAME": _OBJ.TypeStr,
									"VALUE": null},
									{"ACT": "入垃圾桶",
									"BUT": 0,
									"DEV": 1,
									"HOLD": false,
									"HOLDITEM": false,
									"HOLDVALUE": null,
									"ISITEM": false,
									"MENU": null,
									"OBJNAME": "Trashbin",
									"VALUE": null}]
								behavior_ready = BEHAVIOR.WORK

								_on_ReactionTimer_timeout()
								return
							if _OBJ.OnTableObj.FuncType == "Sugar":
								if _OBJ.OnTableObj.Used:
									cur_Work_Array = [{
										"ACT": "捡",
										"BUT": 0,
										"DEV": _OBJ.DeviceID,
										"HOLD": false,
										"HOLDITEM": true,
										"HOLDVALUE": _OBJ.OnTableObj.TypeStr,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": _OBJ.TypeStr,
										"VALUE": null},
										{"ACT": "入垃圾桶",
										"BUT": 0,
										"DEV": 1,
										"HOLD": false,
										"HOLDITEM": false,
										"HOLDVALUE": null,
										"ISITEM": false,
										"MENU": null,
										"OBJNAME": "Trashbin",
										"VALUE": null}]
									behavior_ready = BEHAVIOR.WORK

									_on_ReactionTimer_timeout()
									return
				if GameLogic.Staff.LevelNode.has_node("YSort/Items"):
					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Items")
					for _OBJ in _YSort.get_children():
						if _OBJ.TypeStr == "Box_M_Paper":
							if not _OBJ.ItemOBJ_Array:
								cur_Work_Array = [{
									"ACT": "拆箱",
									"BUT": 2,
									"DEV": _OBJ.DeviceID,
									"HOLD": false,
									"HOLDITEM": false,
									"HOLDVALUE": null,
									"ISITEM": true,
									"MENU": null,
									"OBJNAME": _OBJ.TypeStr,
									"VALUE": null,
									}]
								behavior_ready = BEHAVIOR.WORK

								_on_ReactionTimer_timeout()

								return
						if _OBJ.FuncType == "Bottle":
							if _OBJ.Liquid_Count == 0:
								cur_Work_Array = [{
									"ACT": "捡",
									"BUT": 0,
									"DEV": _OBJ.DeviceID,
									"HOLD": false,
									"HOLDITEM": true,
									"HOLDVALUE": _OBJ.TypeStr,
									"ISITEM": true,
									"MENU": null,
									"OBJNAME": _OBJ.TypeStr,
									"VALUE": null},
									{"ACT": "入垃圾桶",
									"BUT": 0,
									"DEV": 1,
									"HOLD": false,
									"HOLDITEM": false,
									"HOLDVALUE": null,
									"ISITEM": false,
									"MENU": null,
									"OBJNAME": "Trashbin",
									"VALUE": null}]
								behavior_ready = BEHAVIOR.WORK

								_on_ReactionTimer_timeout()
								return
						if _OBJ.FuncType == "Can":
							if _OBJ.Num == 0:
								cur_Work_Array = [{
									"ACT": "捡",
									"BUT": 0,
									"DEV": _OBJ.DeviceID,
									"HOLD": false,
									"HOLDITEM": true,
									"HOLDVALUE": _OBJ.TypeStr,
									"ISITEM": true,
									"MENU": null,
									"OBJNAME": _OBJ.TypeStr,
									"VALUE": null},
									{"ACT": "入垃圾桶",
									"BUT": 0,
									"DEV": 1,
									"HOLD": false,
									"HOLDITEM": false,
									"HOLDVALUE": null,
									"ISITEM": false,
									"MENU": null,
									"OBJNAME": "Trashbin",
									"VALUE": null}]
								behavior_ready = BEHAVIOR.WORK

								_on_ReactionTimer_timeout()
								return
						if _OBJ.FuncType == "Trashbag":
								cur_Work_Array = [{
								"ACT": "捡",
								"BUT": 0,
								"DEV": _OBJ.DeviceID,
								"HOLD": false,
								"HOLDITEM": true,
								"HOLDVALUE": _OBJ.TypeStr,
								"ISITEM": true,
								"MENU": null,
								"OBJNAME": _OBJ.TypeStr,
								"VALUE": null},
								{"ACT": "入垃圾桶",
								"BUT": 0,
								"DEV": 1,
								"HOLD": false,
								"HOLDITEM": false,
								"HOLDVALUE": null,
								"ISITEM": false,
								"MENU": null,
								"OBJNAME": "Trashbin",
								"VALUE": null}]
								behavior_ready = BEHAVIOR.WORK

								_on_ReactionTimer_timeout()
								return
						if _OBJ.FuncType == "Sugar":
							if _OBJ.Used:
								cur_Work_Array = [{
								"ACT": "捡",
								"BUT": 0,
								"DEV": _OBJ.DeviceID,
								"HOLD": false,
								"HOLDITEM": true,
								"HOLDVALUE": _OBJ.TypeStr,
								"ISITEM": true,
								"MENU": null,
								"OBJNAME": _OBJ.TypeStr,
								"VALUE": null},
								{"ACT": "入垃圾桶",
								"BUT": 0,
								"DEV": 1,
								"HOLD": false,
								"HOLDITEM": false,
								"HOLDVALUE": null,
								"ISITEM": false,
								"MENU": null,
								"OBJNAME": "Trashbin",
								"VALUE": null}]
								behavior_ready = BEHAVIOR.WORK

								_on_ReactionTimer_timeout()
								return
			if not behavior_ready and SkillList.has("技能-进货整理"):
				if GameLogic.Staff.LevelNode.has_node("YSort/Devices"):
					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
					for _OBJ in _YSort.get_children():
						if _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"] and _OBJ.OnTableObj:
							if _OBJ.OnTableObj.TypeStr == "Box_M_Paper":
								print("整理 箱子Type：", _OBJ.OnTableObj.Type)
								if _OBJ.OnTableObj.Type != "Fruit":
									if _OBJ.OnTableObj.ItemOBJ_Array:
										_PutOn_Shelf(_OBJ)
										return
				if GameLogic.Staff.LevelNode.has_node("YSort/Items"):
					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Items")
					for _OBJ in _YSort.get_children():
						if _OBJ.TypeStr == "Box_M_Paper":
							if _OBJ.Type != "Fruit":
								if _OBJ.ItemOBJ_Array:
									_PutOn_Shelf(_OBJ)
									return
			if not behavior_ready and SkillList.has("技能-地面整理"):
				if GameLogic.Staff.LevelNode.has_node("YSort/Items"):
					var _YSort = GameLogic.Staff.LevelNode.get_node("YSort/Items")
					for _OBJ in _YSort.get_children():
						if _OBJ.FuncType == "Bottle":
							if _OBJ.Liquid_Count > 0:
								_PutOn_Shelf(_OBJ)
								return
						elif _OBJ.FuncType == "Can":
							if _OBJ.Num > 0:
								_PutOn_Shelf(_OBJ)
								return
						elif _OBJ.FuncType in ["Sugar", "TeaLeaf"]:
							if not _OBJ.Used:
								_PutOn_Shelf(_OBJ)
								return


			if behavior_ready == null:
				if Con.IsHold:
					var _PutDown = {"ACT": "放地上"}
					call_HoldWork(_PutDown)
					ReactionTimer.start(0)
					return

				if abs(self.position.x - GameLogic.Staff.StaffLocker_StaffPos.x) <= 50 and abs(self.position.y - GameLogic.Staff.StaffLocker_StaffPos.y) <= 50:

					call_IDLEMOVE_Logic()
				else:
					var _rand = GameLogic.return_randi() % 10
					if _rand == 0:
						call_IDLEMOVE_Logic()

				ReactionTimer.start(0)

		else:
			if GameLogic.GameUI.CurTime < GameLogic.cur_CloseTime:
				if SkillList.has("技能-倒垃圾临时工"):

					ReactionTimer.start(0)
					return
				var _RandMax: int = 10
				if not behavior_ready and SkillList.has("技能-早班"):
					_RandMax = 0
				if not behavior_ready and SkillList.has("技能-早到"):
					_RandMax = 0
				if not behavior_ready and SkillList.has("技能-爱迟到"):
					_RandMax += 30
				var _Rand: int = 0
				if _RandMax > 0:
					_Rand = GameLogic.return_randi() % _RandMax
				if _Rand > 0:
					behavior_ready = BEHAVIOR.READY

				behavior_ready = BEHAVIOR.WORK_ON

				_move_to_StaffLocker()
				IsWork = true

				ReactionTimer.start(0)
			else:
				if SkillList.has("技能-倒垃圾临时工"):
					if not behavior_ready:
						behavior_ready = BEHAVIOR.WORK_OFF
					ReactionTimer.start(0)
					return
				if not SkillList.has("技能-加班狂"):
					if not behavior_ready:
						behavior_ready = BEHAVIOR.WORK_OFF_READY
				ReactionTimer.start(0)
				pass

func return_Take_Shelf(_OBJ, _NAME: String):
	var _BUT: int = - 1
	var _ShelfYSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
	var _ShelfNode
	for _Shelf in _ShelfYSort.get_children():
		if _Shelf.TypeStr == "Shelf":

			if _Shelf.Layer1_Item == _NAME:
				_BUT = 0
				_ShelfNode = _Shelf

				break
			elif _Shelf.Layer2_Item == _NAME:
				_BUT = 1
				_ShelfNode = _Shelf

				break
			elif _Shelf.Layer3_Item == _NAME:
				_BUT = 2
				_ShelfNode = _Shelf

				break
			elif _Shelf.Layer4_Item == _NAME:
				_BUT = 3
				_ShelfNode = _Shelf

				break

	if not _ShelfNode or _BUT == - 1:

		return false
	if _NAME == "Sugar":
		cur_Work_Array = [
		{"ACT": "拿",
		"BUT": _BUT,
		"DEV": _ShelfNode.DeviceID,
		"HOLD": true,
		"HOLDITEM": true,
		"HOLDVALUE": _NAME,
		"ISITEM": false,
		"MENU": null,
		"OBJNAME": _ShelfNode.TypeStr,
		"VALUE": null,
		},
		{"ACT": "补糖",
		"BUT": 0,
		"DEV": _OBJ.DeviceID,
		"HOLD": false,
		"HOLDITEM": true,
		"HOLDVALUE": _NAME,
		"ISITEM": false,
		"MENU": null,
		"OBJNAME": _OBJ.TypeStr,
		"VALUE": null,
		}]
	elif _NAME in ["DrinkCup_Group_S", "DrinkCup_Group_M", "DrinkCup_Group_L"]:
		cur_Work_Array = [
		{"ACT": "拿",
		"BUT": _BUT,
		"DEV": _ShelfNode.DeviceID,
		"HOLD": true,
		"HOLDITEM": true,
		"HOLDVALUE": _NAME,
		"ISITEM": false,
		"MENU": null,
		"OBJNAME": _ShelfNode.TypeStr,
		"VALUE": null,
		},
		{"ACT": "放入杯组",
		"BUT": 0,
		"DEV": _OBJ.DeviceID,
		"HOLD": false,
		"HOLDITEM": false,
		"HOLDVALUE": null,
		"ISITEM": false,
		"MENU": null,
		"OBJNAME": _OBJ.TypeStr,
		"VALUE": null,
		}]
	behavior_ready = BEHAVIOR.WORK

	return true
func _PutOn_Shelf(_OBJ):
	var _BUT: int = - 1
	var _ShelfYSort = GameLogic.Staff.LevelNode.get_node("YSort/Devices")
	var _ShelfNode
	var _ShelfList: Array
	var _OBJNAME: String
	var IsItem: bool = true
	var _NeedOpen: bool
	if _OBJ.TypeStr == "Box_M_Paper":
		_OBJNAME = _OBJ.ItemName
		_NeedOpen = true
	elif _OBJ.TypeStr in ["WorkBench", "WorkBench_Immovable"]:
		if _OBJ.OnTableObj:
			if _OBJ.OnTableObj.TypeStr == "Box_M_Paper":
				_OBJNAME = _OBJ.OnTableObj.ItemName
				IsItem = false
				_NeedOpen = true
	else:
		_OBJNAME = _OBJ.TypeStr
		_NeedOpen = false
	if _OBJNAME == "DrinkCup_S":
		_OBJNAME = "DrinkCup_Group_S"
	elif _OBJNAME == "DrinkCup_M":
		_OBJNAME = "DrinkCup_Group_M"
	elif _OBJNAME == "DrinkCup_L":
		_OBJNAME = "DrinkCup_Group_L"
	for _Shelf in _ShelfYSort.get_children():
		if _Shelf.TypeStr == "Shelf":
			_ShelfList.append(_Shelf)

			if _Shelf.Layer1_Item == _OBJNAME and _Shelf.Layer1_Weight + _OBJ.Weight <= 8:
				_BUT = 0
				_ShelfNode = _Shelf

			elif _Shelf.Layer2_Item == _OBJNAME and _Shelf.Layer2_Weight + _OBJ.Weight <= 8:
				_BUT = 1
				_ShelfNode = _Shelf

			elif _Shelf.Layer3_Item == _OBJNAME and _Shelf.Layer3_Weight + _OBJ.Weight <= 8:
				_BUT = 2
				_ShelfNode = _Shelf

			elif _Shelf.Layer4_Item == _OBJNAME and _Shelf.Layer4_Weight + _OBJ.Weight <= 8:
				_BUT = 3
				_ShelfNode = _Shelf

	if _BUT == - 1:

		for _Shelf in _ShelfList:

			if not _Shelf.Layer1_Item:
				_BUT = 0
				_ShelfNode = _Shelf
				break
			if not _Shelf.Layer2_Item:
				_BUT = 1
				_ShelfNode = _Shelf
				break
			if not _Shelf.Layer3_Item:
				_BUT = 2
				_ShelfNode = _Shelf
				break
			if not _Shelf.Layer4_Item:
				_BUT = 3
				_ShelfNode = _Shelf
				break
	if not _ShelfNode or _BUT == - 1:

		ReactionTimer.start(0)
		return

	cur_Work_Array.clear()
	if _NeedOpen:
		cur_Work_Array.append({"ACT": "开箱",
			"BUT": 2,
			"DEV": _OBJ.DeviceID,
			"HOLD": false,
			"HOLDITEM": false,
			"HOLDVALUE": null,
			"ISITEM": IsItem,
			"MENU": null,
			"OBJNAME": _OBJ.TypeStr,
			"VALUE": null,
			})
		cur_Work_Array.append({"ACT": "箱中取",
			"BUT": 2,
			"DEV": _OBJ.DeviceID,
			"HOLD": false,
			"HOLDITEM": true,
			"HOLDVALUE": _OBJNAME,
			"ISITEM": IsItem,
			"MENU": null,
			"OBJNAME": _OBJ.TypeStr,
			"VALUE": null})
	else:
		cur_Work_Array.append({"ACT": "捡",
			"BUT": 0,
			"DEV": _OBJ.DeviceID,
			"HOLD": false,
			"HOLDITEM": true,
			"HOLDVALUE": _OBJNAME,
			"ISITEM": true,
			"MENU": null,
			"OBJNAME": _OBJ.TypeStr,
			"VALUE": null})
	cur_Work_Array.append({"ACT": "放",
		"BUT": _BUT,
		"DEV": _ShelfNode.DeviceID,
		"HOLD": false,
		"HOLDITEM": false,
		"HOLDVALUE": null,
		"ISITEM": false,
		"MENU": null,
		"OBJNAME": "Shelf",
		"VALUE": null})
	behavior_ready = BEHAVIOR.WORK

	_on_ReactionTimer_timeout()

func return_on_workpoint(_workpos):
	var _selfpos = self.global_position
	print("判断是否在点单位置：", _selfpos, _workpos)
	var _x = abs(_workpos.x - _selfpos.x)
	var _y = abs(_workpos.y - _selfpos.y)
	if _x <= 50 and _y <= 50:
		return true
	else:
		return false
func call_IDLEMOVE_Logic():
	_call_StaffStore_RandomMove()
	pass

func _OrderLogic():
	print("是否靠近点单台：", return_on_workpoint(GameLogic.Staff.OrderTab_StaffPos))
	if return_on_workpoint(GameLogic.Staff.OrderTab_StaffPos):

		GameLogic.Staff.Staff_Order = self

		behavior_ready = null
		behavior = BEHAVIOR.ORDER
		_on_ReactionTimer_timeout()
	else:
		pass
func call_ORDER_Logic():

	if GameLogic.Staff.Staff_Order == self and GameLogic.Staff.Need_Order:
		_OrderLogic()
	if not GameLogic.Staff.Staff_Order and GameLogic.Staff.Need_Order:
		_OrderLogic()
	else:
		behavior = BEHAVIOR.IDLE
		behavior_ready = null
		_Path_IsFinish = true
		_on_ReactionTimer_timeout()
func return_ready_ORDER_Logic():


	if GameLogic.Staff.Staff_Order == self and GameLogic.Staff.Need_Order:
		_move_to_Order()
		return BEHAVIOR.ORDER
	if not GameLogic.Staff.Staff_Order and GameLogic.Staff.Need_Order:

		_move_to_Order()
		return BEHAVIOR.ORDER
	else:
		_Path_IsFinish = true
		return null

func _move_to_OBJ_AllWays(_OBJPos: Vector2):
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, _OBJPos)
	print("移动逻辑判断：", behavior, " ready:", behavior_ready)

	if WayPoint_array.size() > 0:

		_Path_IsFinish = false
		next_point()
	else:
		match behavior_ready:
			BEHAVIOR.WC:
				var _Rand = 2 + GameLogic.return_randi() % 20
				yield(get_tree().create_timer(_Rand), "timeout")
				Stat.Ins_Skill_3_Mult = 1
				behavior_ready = BEHAVIOR.WORK_ON
				_call_StaffStore_RandomMove()
				_on_ReactionTimer_timeout()
			BEHAVIOR.WORK_OFF:
				behavior_ready = null
				self.queue_free()
			_:
				_Path_IsFinish = true
				ReactionTimer.start(0)
func _move_to_OBJ(_OBJPos: Vector2):
	WayPoint_array = GameLogic.Astar.return_Staff_WayPoint_Array(self.position, _OBJPos)

	if WayPoint_array.size() > 0:

		_Path_IsFinish = false
		next_point()
	else:
		_Path_IsFinish = true
		_on_ReactionTimer_timeout()
func _move_to_Follow():

	if FollowPlayer == null:

		if cur_Work_Array:
			_Path_IsFinish = true

			behavior_ready = BEHAVIOR.WORK
		else:
			_Path_IsFinish = true

			behavior_ready = BEHAVIOR.IDLE
			behavior = BEHAVIOR.IDLE
		ReactionTimer.start(0)
		return

	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, FollowPlayer.global_position)
	if WayPoint_array.size() > 1:
		var _Del = WayPoint_array.pop_back()
		_Path_IsFinish = false
		next_point()
	else:
		_Path_IsFinish = true

	ReactionTimer.start(0)
func _move_to_Order():

	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, GameLogic.Staff.OrderTab_StaffPos)
	if WayPoint_array:
		_Path_IsFinish = false
		next_point()

func _move_to_StaffLocker():
	WayPoint_array = GameLogic.Astar.return_WayPoint_Array(self.position, GameLogic.Staff.StaffLocker_StaffPos)
	_Path_IsFinish = false
	print("移动到Locker:", WayPoint_array, GameLogic.Staff.StaffLocker_StaffPos)
	next_point()

func _physics_process(_delta: float) -> void :
	if behavior == BEHAVIOR.MOVE:
		Con.velocity = position.direction_to(target) * Stat.Ins_MAXSPEED
		Con.velocity = Con.velocity * float(Stat.Ins_SpeedMult)
		if not _Path_IsFinish:
			Con.input_vector = Con.velocity.normalized()
			if not WayPoint_array.size():
				if self.position.distance_to(target) < 10:
					self.position = target
					next_point()
			elif self.position.distance_to(target) < 20:
				next_point()
			move(_delta)

		else:
			behavior = BEHAVIOR.IDLE
	_ani_logic()
func next_point():

	if WayPoint_array.size():
		target = WayPoint_array.pop_front()
		var _PosCheck = GameLogic.Astar.AStar_Func.get_point_position(GameLogic.Astar.AStar_Func.get_closest_point(target))

		if TargetPOS.x == _PosCheck.x and abs(TargetPOS.y - _PosCheck.y) < 150:
			WayPoint_array.clear()

		elif TargetPOS.y == _PosCheck.y and abs(TargetPOS.x - _PosCheck.x) < 150:
			WayPoint_array.clear()

		behavior = BEHAVIOR.MOVE
	else:

		target = self.position
		_Path_IsFinish = true
		if behavior in [BEHAVIOR.MOVE]:
			behavior = BEHAVIOR.IDLE
		if not behavior_ready in [BEHAVIOR.FOLLOW, BEHAVIOR.STUDY]:
			if behavior_ready in [BEHAVIOR.WORK_ON, BEHAVIOR.WORK_OFF_READY]:
				var _direction = (GameLogic.Staff.StaffLocker_OBJ.global_position - self.position).normalized()
				Con.input_vector = _direction
			elif cur_Work_OBJ:
				var _direction = (cur_Work_OBJ.global_position - self.position).normalized()
				Con.input_vector = _direction

		_on_ReactionTimer_timeout()
func _ani_logic():
	if Con.state != GameLogic.NPC.STATE.WORK:
		var _aniSpeed = _return_ani_speed()

		if _aniSpeed > 0:
			if Con.state != GameLogic.NPC.STATE.MOVE:
				Con.state = GameLogic.NPC.STATE.MOVE
		else:
			if Con.state != GameLogic.NPC.STATE.IDLE_EMPTY:
				Con.state = GameLogic.NPC.STATE.IDLE_EMPTY

func _return_ani_speed():


	if _Path_IsFinish:
		return 0
	var _speedscale: float
	var velocity = Con.velocity
	var _x = abs(velocity.x / Stat.Ins_MAXSPEED)
	var _y = abs(velocity.y / Stat.Ins_MAXSPEED)
	if _x >= _y:
		_speedscale = float(int(_x * 100)) / 100
	else:
		_speedscale = float(int(_y * 100)) / 100

	return _speedscale

func move(_delta):

	Con.velocity = move_and_slide(Con.velocity)
	var _aniSpeed = _return_ani_speed()
	if not _Path_IsFinish:
		if _aniSpeed == 0 and Con.velocity != Vector2.ZERO:
			var _Transform2D = Transform2D(0, self.position)
			if not test_move(_Transform2D, Con.velocity):
				_call_Beside_RandomMove()

func _call_Beside_RandomMove():
	var _pointID = GameLogic.Astar.AStar_Func.get_closest_point(self.position)
	var _point = GameLogic.Astar.AStar_Func.get_point_position(_pointID)
	var _check = GameLogic.Staff.return_besidePoint(_point)
	if not _check:
		print("_call_Beside_RandomMove 未找到可以动的位置。")
		return
	if not WayPoint_array.size():
		WayPoint_array.append(target)
	target = _check

func But_Switch(_bool, _Player):

	if IsStaff:

		if FollowPlayer:
			get_node("But/Y").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/Y").Info_Str)
			get_node("But/X").bool_Hold = false
			if behavior_ready != BEHAVIOR.STUDY:
				get_node("But/X").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/X").Info_1)
				get_node("But/Y").show()
				get_node("But/B").show()
			else:
				get_node("But/X").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/X").Info_2)
				get_node("But/Y").hide()
				get_node("But/B").hide()
			get_node("But/X").show()
		else:
			get_node("But/Y").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/Y").Info_1)
			get_node("But/X").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/Y").Info_Str)
			get_node("But/B").hide()
			get_node("But/X").hide()

			get_node("But/Y").show()

		var _playerID: int = _Player.cur_Player
		if has_node("But"):
			var ButList = get_node("But").get_children()
			var _Name = get_parent().name
			if _Name == "Weapon_note":

				for i in ButList.size():
					var _But = ButList[i]
					_But.call_clean()
			for i in ButList.size():
				var _But = ButList[i]
				match _bool:
					true:
						_But.call_player_in(_playerID)
						match _Player.cur_Player:
							1:
								if not GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
									GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
							2:
								if not GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
									GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")

					false:
						_But.call_player_out(_playerID)
						match _Player.cur_Player:
							1:
								if GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
									GameLogic.Con.disconnect("P1_Control", self, "_P1_control_logic")
							2:
								if GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
									GameLogic.Con.disconnect("P2_Control", self, "_P2_control_logic")

	else:
		get_node("But/Y").hide()
		if GameLogic.Staff.Staff_Max > GameLogic.cur_Staff.size():
			get_node("But/X").bool_Hold = true
			get_node("But/X").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/X").Info_Str)
			get_node("But/X").show()
		get_node("But/B").hide()
		if _bool:
			match _Player.cur_Player:
				1:
					if not GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
						GameLogic.Con.connect("P1_Control", self, "_P1_control_logic")
				2:
					if not GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
						GameLogic.Con.connect("P2_Control", self, "_P2_control_logic")

			call_StaffInfo_Switch(true)
		else:
			match _Player.cur_Player:
				1:
					if GameLogic.Con.is_connected("P1_Control", self, "_P1_control_logic"):
						GameLogic.Con.disconnect("P1_Control", self, "_P1_control_logic")
				2:
					if GameLogic.Con.is_connected("P2_Control", self, "_P2_control_logic"):
						GameLogic.Con.disconnect("P2_Control", self, "_P2_control_logic")

			call_StaffInfo_Switch(false)
func call_StaffInfo_Switch(_switch: bool):
	match _switch:
		true:
			get_node("StaffInfo").call_show()

			if IsStaff:
				get_node("But/B").show()
			else:
				if GameLogic.Staff.Staff_Max > GameLogic.cur_Staff.size():
					get_node("But/X").bool_Hold = true
					get_node("But/X").InfoLabel.text = GameLogic.CardTrans.get_message(get_node("But/X").Info_Str)
					get_node("But/X").show()
		false:
			get_node("StaffInfo").call_hide()

			get_node("But/B").hide()
			get_node("But/X").hide()
func call_FollowPlayer(_Player):
	if FollowPlayer == null:
		FollowPlayer = _Player
		behavior_ready = BEHAVIOR.FOLLOW
		behavior = BEHAVIOR.FOLLOW
		_on_ReactionTimer_timeout()

func call_follow(_Player):
	if not IsStaff or behavior_ready in [BEHAVIOR.STUDY]:
		return
	if FollowPlayer == null:
		FollowPlayer = _Player
		behavior_ready = BEHAVIOR.FOLLOW

		behavior = BEHAVIOR.FOLLOW

		_on_ReactionTimer_timeout()

		call_StaffInfo_Switch(true)
		But_Switch(true, _Player)

	elif FollowPlayer == _Player:
		FollowPlayer = null
		if cur_Work_Array:
			_Path_IsFinish = true

			behavior_ready = BEHAVIOR.WORK
		else:
			_Path_IsFinish = true

			behavior_ready = BEHAVIOR.IDLE

		ReactionTimer.start(0)
		call_StaffInfo_Switch(false)
		But_Switch(true, _Player)

func _StudyLogic(_ButID, _Player, _DevObj, _Action):
	if _ButID < 0:
		return
	if _Player != FollowPlayer:
		return
	var _OBJNAME = null
	var _Type
	var _ISITEM
	var _Value = null
	var _Array: Array
	if _DevObj:
		if _DevObj.has_method("_ready"):
			_OBJNAME = _DevObj.TypeStr
			_ISITEM = _DevObj.IsItem


			match _OBJNAME:
				"Box_M_Paper":
					_Type = _DevObj.ItemName
				_:
					_Type = _DevObj.DeviceID
					if _Type == 0:
						printerr("当前物体的ID为0.请检查原因。", _DevObj.DeviceID)
	var _Hold: bool = _Player.Con.IsHold
	var _HoldObj = null
	var _HoldItem = false
	var _HoldValue = null
	var _Menu = null
	if _Hold:
		_HoldObj = instance_from_id(_Player.Con.HoldInsId)
		_HoldItem = _HoldObj.IsItem
		_HoldValue = _HoldObj.TypeStr

		match _HoldObj.FuncType:
			"ShakeCup":

				pass
			"DrinkCup":

				pass

	var _Logic: Dictionary = {
		"BUT": _ButID,
		"ACT": _Action,
		"ISITEM": _ISITEM,
		"OBJNAME": _OBJNAME,
		"DEV": _Type,
		"HOLD": _Player.Con.IsHold,
		"HOLDITEM": _HoldItem,
		"HOLDVALUE": _HoldValue,
		"VALUE": _Value,
		"MENU": _Menu,
		}
	if _Array.size():
		_Logic.VALUE = _Array

	Temp_Study.append(_Logic)
	if ActionNode.get_child_count() < Temp_Study.size():
		Temp_Study.clear()
		call_Study_Finish()
	else:
		_ActionIcon_Show()
		if _Action in ["放桌上", "出杯", "入垃圾桶", "放入杯组", "台架放入", "补糖", "放"]:
			call_Study_Finish()

func _DayEnd_Logic():
	if Con.IsHold:
		var _PutDown = {"ACT": "放地上"}
		call_HoldWork(_PutDown)

	behavior_ready = null
	behavior = BEHAVIOR.IDLE
	return

func call_Study_Finish():

	if not IsStaff:
		return
	if FollowPlayer == null:
		return

	var _StudyInfo: Array
	for _Study in Temp_Study:
		_StudyInfo.append(_Study)
	Temp_Study.clear()
	if _StudyInfo.size():
		DayActionDic[0] = _StudyInfo
		BehaviorAni.play("学会了")
	else:
		BehaviorAni.play("学不会")
	_Path_IsFinish = true
	FollowPlayer = null

	behavior_ready = null
	behavior = BEHAVIOR.IDLE
	WayPoint_array.clear()
	if GameLogic.Device.is_connected("FuncCheckLogic", self, "_StudyLogic"):
		GameLogic.Device.disconnect("FuncCheckLogic", self, "_StudyLogic")

	ReactionTimer.start(0)
	call_StaffInfo_Switch(false)
	ActionNode.hide()
var _BodyList: Array
func _on_body_entered(body: Node) -> void :
	if body == self:
		return
	if not _BodyList.has(body):
		_BodyList.append(body)
	if _BodyList.size():

		if SkillList.has("技能-偷懒"):

			if ReactionTimer.wait_time != ReactionTime:
				ReactionTimer.wait_time = ReactionTime

func _on_body_exited(body: Node) -> void :
	if _BodyList.has(body):
		_BodyList.erase(body)

	if not _BodyList.size():
		if SkillList.has("技能-偷懒"):
			print("离开偷懒判断：", ReactionTimer.wait_time, " ", int(INFO.ReactionTime) + ReactionTime)
			if ReactionTimer.wait_time != int(INFO.ReactionTime) + ReactionTime:
				ReactionTimer.wait_time = int(INFO.ReactionTime) + ReactionTime
				print("偷懒解除：", ReactionTimer.wait_time)
		if SkillList.has("技能-游手好闲"):
			Stat.Ins_Skill_1_Mult = 1
			print("游手好闲解除：", Stat.Ins_Skill_1_Mult)
func call_Staff_Save():
	var _STAFFINFO = {
		"NAME": Name,
		"cur_Pressure": cur_Pressure,
		"AvatarID": AvatarID,
		"AvatarType": AvatarType,
		"SkillList": SkillList,
		"DayActionDic": DayActionDic,
		"DailyWage": DailyWage,
		"ActionMax": ActionMax,
		"HomePoint": HomePoint,
		}
	GameLogic.cur_Staff[Name] = _STAFFINFO
