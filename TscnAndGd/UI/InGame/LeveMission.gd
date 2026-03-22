extends Control

export var ShowBool: bool
var cur_level: String
var Mission_Num: int
var Mission_1_Type: int
var Mission_1_Value: int
var Mission_2_Type: int
var Mission_2_Value: int

var Mission_1_Check: bool
var Mission_2_Check: bool

onready var M1Label = get_node("MissionInfo/VBoxContainer/1")
onready var M1ValueLabel = get_node("MissionInfo/VBoxContainer/1/value")
onready var M2Label = get_node("MissionInfo/VBoxContainer/2")
onready var M2ValueLabel = get_node("MissionInfo/VBoxContainer/2/value")
onready var M1Complete = get_node("MissionInfo/VBoxContainer/1/Complete")
onready var M1Fail = get_node("MissionInfo/VBoxContainer/1/Fail")
onready var M2Complete = get_node("MissionInfo/VBoxContainer/2/Complete")
onready var M2Fail = get_node("MissionInfo/VBoxContainer/2/Fail")

onready var Ani = get_node("Ani")

enum MISSIONTYPE{
	NONE
	Day
	CustomerNum
	SellMoneyTotal
	SellCupTotal
	StorePopular
	Profit
	OrderRat
	NoSellRat
	MaxCombo
	StoreValue
	Funds
	InDay
}

func call_check():
	GameLogic.MissionComplete_bool = false
	if GameLogic.cur_level:
		call_mission_init(GameLogic.cur_level)
	else:
		if not ShowBool:
			Ani.play("hide")

func call_mission_init(cur_Select):

	cur_level = cur_Select
	Mission_1_Check = false
	Mission_2_Check = false
	Mission_1_Type = int(GameLogic.cur_levelInfo.Mission_1)
	Mission_1_Value = int(GameLogic.cur_levelInfo.Mission_1_Value)
	Mission_2_Type = int(GameLogic.cur_levelInfo.Mission_2)
	Mission_2_Value = int(GameLogic.cur_levelInfo.Mission_2_Value)
	if Mission_2_Type == - 1:
		Mission_Num = 1
	else:
		Mission_Num = 2
	for i in 2:
		var _Type: int
		var _Value: int
		var _InfoLabel
		var _ValueLabel
		match i:
			0:
				_Type = Mission_1_Type
				_Value = Mission_1_Value
				_InfoLabel = M1Label
				_ValueLabel = M1ValueLabel
			1:
				_Type = Mission_2_Type
				_Value = Mission_2_Value
				_InfoLabel = M2Label
				_ValueLabel = M2ValueLabel
		if _Type > 0:
			_InfoLabel.show()
			match _Type:
				MISSIONTYPE.Day:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-完成天数")
					_ValueLabel.text = str(GameLogic.cur_Day - 1) + "/" + str(_Value)
					if (GameLogic.cur_Day - 1) >= _Value:
						call_complete(i)
				MISSIONTYPE.CustomerNum:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-顾客总数")
					_ValueLabel.text = str(GameLogic.level_CustomerTotal) + "/" + str(_Value)
					if GameLogic.level_CustomerTotal >= _Value:
						call_complete(i)
				MISSIONTYPE.SellMoneyTotal:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-营业额")
					_ValueLabel.text = str(GameLogic.level_MoneyTotal) + "/" + str(_Value)
					if GameLogic.level_MoneyTotal >= _Value:
						call_complete(i)
				MISSIONTYPE.SellCupTotal:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-销售总量")
					_ValueLabel.text = str(GameLogic.level_SellTotal) + "/" + str(_Value)
					if GameLogic.level_SellTotal >= _Value:
						call_complete(i)
				MISSIONTYPE.StorePopular:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-店铺人气")
					_ValueLabel.text = str(GameLogic.level_StorePopular) + "/" + str(_Value)
					if GameLogic.level_StorePopular >= _Value:
						call_complete(i)
				MISSIONTYPE.Profit:

					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-总利润")

					_ValueLabel.text = str(GameLogic.level_ProfitTotal) + "/" + str(_Value)
					if GameLogic.level_ProfitTotal >= _Value:
						call_complete(i)
				MISSIONTYPE.OrderRat:
					var TotalCustomer = GameLogic.cur_CustomerNum
					var TotalSell = GameLogic.cur_SellNum
					var OrderRat: int
					if TotalCustomer == 0:
						OrderRat = 0
					else:
						if TotalSell > 0:
							OrderRat = int(float(TotalSell) / float(TotalCustomer) * 100)
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-下单率")
					_ValueLabel.text = str(OrderRat) + "/" + str(_Value)
					if OrderRat >= _Value:
						call_complete(i)
				MISSIONTYPE.NoSellRat:
					var TotalNoOrder = GameLogic.cur_NoOrderNum
					var TotalLose = GameLogic.cur_NoSellNum
					var _TotalNoSell = TotalNoOrder + TotalLose
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-丢单数")
					_ValueLabel.text = str(_TotalNoSell) + "/" + str(_Value)
					if _TotalNoSell >= _Value:
						call_complete(i)
				MISSIONTYPE.MaxCombo:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-最大连击")
					_ValueLabel.text = str(GameLogic.cur_ComboMax) + "/" + str(_Value)
					if GameLogic.cur_ComboMax >= _Value:
						call_complete(i)
				MISSIONTYPE.StoreValue:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-店铺价值")
					_ValueLabel.text = str(GameLogic.cur_StoreValue) + "/" + str(_Value)
					if GameLogic.cur_StoreValue >= _Value:
						call_complete(i)
				MISSIONTYPE.Funds:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-总资金")
					_ValueLabel.text = str(GameLogic.cur_money) + "/" + str(_Value)
					if GameLogic.cur_money >= _Value:
						call_complete(i)
				MISSIONTYPE.InDay:
					_InfoLabel.text = GameLogic.CardTrans.get_message("任务-天数内")
					_ValueLabel.text = str(GameLogic.cur_Day - 1) + "/" + str(_Value)

		else:
			_InfoLabel.hide()
			call_complete(i)

func call_complete(_mission: int):
	if not Mission_1_Check:
		M1Complete.hide()
	if not Mission_2_Check:
		M2Complete.hide()

	match _mission:
		0:
			Mission_1_Check = true
			M1Complete.show()
			M1Fail.hide()

		1:
			Mission_2_Check = true
			M2Complete.show()
			M2Fail.hide()
	_MissionComplete_Check()
func _MissionComplete_Check():
	match Mission_Num:
		1:
			if Mission_1_Check:
				if not GameLogic.MissionComplete_bool:
					GameLogic.MissionComplete_bool = true
		2:
			if Mission_1_Check and Mission_2_Check:
				if not GameLogic.MissionComplete_bool:
					GameLogic.MissionComplete_bool = true
