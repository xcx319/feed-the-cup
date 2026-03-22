extends Node

var White_B = "[b][color=white][font=res://Language/Fonts/Base_special_B.tres]"
var Yellow_B = "[b][color=yellow][font=res://Language/Fonts/Base_special_B.tres]"
var Red_B = "[b][color=red][font=res://Language/Fonts/Base_special_B.tres]"
var Cyan_B = "[b][color=#00ffe7][font=res://Language/Fonts/Base_special_B.tres]"
var Lime_B = "[b][color=lime][font=res://Language/Fonts/Base_special_B.tres]"
var Orange_B = "[b][color=#ff8300][font=res://Language/Fonts/Base_special_B.tres]"
var Green_B = "[b][color=green][font=res://Language/Fonts/Base_special_B.tres]"
var OutLine = "[font=res://Language/Fonts/Base_special_B.tres]"
var WhiteLine = "[font=res://Language/Fonts/Base_special_W.tres]"
var Color_end = "[/font][/color][/b]"

var Info_Name: Dictionary

var _GREENREG
var _REDREG
var _YELLOWREG
var _ORANGEREG

var _NUMREG

func _ready():
	_GREENREG = RegEx.new()
	_GREENREG.compile("\\{green[^}]*\\}")
	_REDREG = RegEx.new()
	_REDREG.compile("\\{red[^}]*\\}")
	_YELLOWREG = RegEx.new()
	_YELLOWREG.compile("\\{yellow[^}]*\\}")
	_ORANGEREG = RegEx.new()
	_ORANGEREG.compile("\\{orange[^}]*\\}")
	_NUMREG = RegEx.new()
	_NUMREG.compile("\\{\\d+\\.?\\d*\\%?\\!?\\}")
func return_ColorInfo(_INFO: String, _Type1: Array = [0], _Type2: Array = [0]):


	var _NUMList = _NUMREG.search_all(_INFO)
	if _NUMList:
		var _DAYBOOL: bool
		var _PERSONBOOL: bool

		for _i in _NUMList.size():
			var _GINFO: String = _NUMList[_i].get_string()
			var _PERCENT: bool
			var _INTBOOL: bool

			if _GINFO.find("!") != - 1:
				_INTBOOL = true



			var _TYPENUM = int(_GINFO.substr(1, _GINFO.length() - 2))
			var _Num: float = _TYPENUM
			if _Type1.size() >= (_TYPENUM + 1):
				var _TYPE1NUM = _Type1[_TYPENUM]
				if str(_TYPE1NUM).find("%") != - 1:
					_PERCENT = true
				_Num = float(_TYPE1NUM)

			if _Type2.size() >= (_TYPENUM + 1):
				var _TYPE = int(_Type2[_TYPENUM])
				match _TYPE:
					0:
						pass
					3:
						var _Day = GameLogic.cur_Day
						if _Day < 0:
							_Day = 1
						if GameLogic.LoadingUI.IsHome:
							_Day = 1
						_Num = _Num * _Day
						_DAYBOOL = true
					2:
						_Num = _Num * int(4 / float(SteamLogic.PlayerNum))
						_PERSONBOOL = true
					1:
						_Num = _Num * GameLogic.return_Multiplayer()
						_PERSONBOOL = true
					4:
						var _Day = GameLogic.cur_Day

						if _Day < 0:
							_Day = 1
						if GameLogic.LoadingUI.IsHome:
							_Day = 1
						_Num = _Num * GameLogic.return_Multiplayer() * _Day
						_PERSONBOOL = true
						_DAYBOOL = true
					5:
						var _NumBase = 1
						if SteamLogic.IsMultiplay:
							match SteamLogic.PlayerNum:
								0, 1:
									_NumBase = 4
								2:
									_NumBase = 3
								3:
									_NumBase = 2
								4:
									_NumBase = 1
						else:
							if GameLogic.Player2_bool:
								_NumBase = 3
							else:
								_NumBase = 4

						var _Day = GameLogic.cur_Day

						if _Day < 0:
							_Day = 1
						if GameLogic.LoadingUI.IsHome:
							_Day = 1
						_Num = _Num * _NumBase * _Day
						_DAYBOOL = true
						_PERSONBOOL = true

			var _NUMSTR = str(_Num)
			if _PERCENT:
				_NUMSTR = _NUMSTR + "%"

			_INFO = _INFO.replace(_GINFO, _NUMSTR)
		if _PERSONBOOL or _DAYBOOL:
			var _PERSTR: String = ""
			var _DAYSTR: String = ""
			if _PERSONBOOL:
				if SteamLogic.IsMultiplay:
					_PERSTR = "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_multy.tres[/img]" + "×" + str(SteamLogic.PlayerNum)
				elif GameLogic.Player2_bool:
					_PERSTR = "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_multy.tres[/img]" + "×" + "2"
				else:
					_PERSTR = "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_multy.tres[/img]" + "×" + "1"
			if _DAYBOOL:
				var _Day = GameLogic.cur_Day
				if _Day < 0:
					_Day = 1
				if GameLogic.LoadingUI.IsHome:
					_Day = 1
				if _PERSONBOOL:
					_DAYSTR = ", DAY " + str(_Day)
				else:
					_DAYSTR = "DAY " + str(_Day)
			_INFO = _INFO + "\n( " + _PERSTR + _DAYSTR + " )"

	var _ReInfo = _INFO

	var _GreenList = _GREENREG.search_all(_INFO)
	var _GreenReList: Array
	if _GreenList:
		for _i in _GreenList.size():
			var _GINFO: String = _GreenList[_i].get_string()

			var _t1 = _GINFO.replacen("{green", GameLogic.Info.Lime_B)
			var _t2 = _t1.replacen("}", GameLogic.Info.Color_end)
			_GreenReList.append(_t2)

		for _i in _GreenList.size():
			_ReInfo = _ReInfo.replace(_GreenList[_i].get_string(), _GreenReList[_i])

	var _RedList = _REDREG.search_all(_INFO)
	var _RedReList: Array
	if _RedList:
		for _i in _RedList.size():
			var _GINFO: String = _RedList[_i].get_string()

			var _t1 = _GINFO.replacen("{red", GameLogic.Info.Red_B)
			var _t2 = _t1.replacen("}", GameLogic.Info.Color_end)
			_RedReList.append(_t2)

		for _i in _RedList.size():
			_ReInfo = _ReInfo.replace(_RedList[_i].get_string(), _RedReList[_i])

	var _YellowList = _YELLOWREG.search_all(_INFO)
	var _YeReList: Array

	if _YellowList:
		for _i in _YellowList.size():
			var _GINFO: String = _YellowList[_i].get_string()

			var _t1 = _GINFO.replacen("{yellow", GameLogic.Info.Yellow_B)
			var _t2 = _t1.replacen("}", GameLogic.Info.Color_end)
			_YeReList.append(_t2)

		for _i in _YellowList.size():
			_ReInfo = _ReInfo.replace(_YellowList[_i].get_string(), _YeReList[_i])

	var _OrangeList = _ORANGEREG.search_all(_INFO)
	var _OrReList: Array
	if _OrangeList:
		for _i in _OrangeList.size():
			var _GINFO: String = _OrangeList[_i].get_string()

			var _t1 = _GINFO.replacen("{orange", GameLogic.Info.Orange_B)
			var _t2 = _t1.replacen("}", GameLogic.Info.Color_end)
			_OrReList.append(_t2)

		for _i in _OrangeList.size():
			_ReInfo = _ReInfo.replace(_OrangeList[_i].get_string(), _OrReList[_i])



	return _ReInfo

func call_init():

	Info_Name = {
	"术语_租金": Yellow_B + GameLogic.CardTrans.get_message("术语_租金") + Color_end,
	"术语_水费": Yellow_B + GameLogic.CardTrans.get_message("术语_水费") + Color_end,
	"术语_电费": Yellow_B + GameLogic.CardTrans.get_message("术语_电费") + Color_end,
	"术语_饮品": Yellow_B + GameLogic.CardTrans.get_message("术语_饮品") + Color_end,
	"术语_小料": Yellow_B + GameLogic.CardTrans.get_message("术语_小料") + Color_end,
	"术语_杯子": Yellow_B + GameLogic.CardTrans.get_message("术语_杯子") + Color_end,
	"术语_装饰": Yellow_B + GameLogic.CardTrans.get_message("术语_装饰") + Color_end,
	"术语_挂壁": Yellow_B + GameLogic.CardTrans.get_message("术语_挂壁") + Color_end,
	"术语_淋酱": Yellow_B + GameLogic.CardTrans.get_message("术语_淋酱") + Color_end,
	"术语_雪克杯": Yellow_B + GameLogic.CardTrans.get_message("术语_雪克杯") + Color_end,
	"术语_搅拌": Yellow_B + GameLogic.CardTrans.get_message("术语_搅拌") + Color_end,
	"术语_开盖": Yellow_B + GameLogic.CardTrans.get_message("术语_开盖") + Color_end,
	"术语_切": Yellow_B + GameLogic.CardTrans.get_message("术语_切") + Color_end,
	"术语_手工": Yellow_B + GameLogic.CardTrans.get_message("术语_手工") + Color_end,
	"出杯员": White_B + GameLogic.CardTrans.get_message("出杯员") + Color_end,
	"点单员": White_B + GameLogic.CardTrans.get_message("点单员") + Color_end,
	"有店员": White_B + GameLogic.CardTrans.get_message("有店员") + Color_end,
	"全体店员": White_B + GameLogic.CardTrans.get_message("全体店员") + Color_end,
	"欢迎光临": White_B + GameLogic.CardTrans.get_message("欢迎光临") + Color_end,
	"术语_COMBO": Yellow_B + GameLogic.CardTrans.get_message("术语_COMBO") + Color_end,
	"术语_原价": "[b][color=white]" + OutLine + GameLogic.CardTrans.get_message("术语_原价") + Color_end,
	"术语_总售价": Yellow_B + GameLogic.CardTrans.get_message("术语_总售价") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_营业额": Yellow_B + GameLogic.CardTrans.get_message("术语_营业额") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_单价": Yellow_B + GameLogic.CardTrans.get_message("术语_单价") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_小费": Yellow_B + GameLogic.CardTrans.get_message("术语_小费") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_基础小费": Yellow_B + GameLogic.CardTrans.get_message("术语_基础小费") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_额外小费": Yellow_B + GameLogic.CardTrans.get_message("术语_额外小费") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_单价倍率": Yellow_B + GameLogic.CardTrans.get_message("术语_单价倍率") + Color_end,
	"术语_总价倍率": Yellow_B + GameLogic.CardTrans.get_message("术语_总价倍率") + Color_end,
	"术语_小费倍率": Yellow_B + GameLogic.CardTrans.get_message("术语_小费倍率") + Color_end,
	"术语_额外收入": Yellow_B + GameLogic.CardTrans.get_message("术语_额外收入") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_资金": Yellow_B + GameLogic.CardTrans.get_message("术语_资金") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"术语_绿票": Lime_B + GameLogic.CardTrans.get_message("术语_绿票") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_money.tres[/img]",
	"术语_契约": Red_B + GameLogic.CardTrans.get_message("术语_契约") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_evil.tres[/img]",
	"术语_契约币": Lime_B + GameLogic.CardTrans.get_message("术语_契约币") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_reroll.tres[/img]",
	"术语_恶魔能力": Lime_B + GameLogic.CardTrans.get_message("术语_恶魔能力") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_gift.tres[/img]",
	"术语_恶魔币": Lime_B + GameLogic.CardTrans.get_message("术语_恶魔币") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_regift.tres[/img]",
	"术语_声望值": Orange_B + GameLogic.CardTrans.get_message("术语_声望值") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_rep.tres[/img]",
	"术语_经验": Orange_B + GameLogic.CardTrans.get_message("术语_经验") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_exp.tres[/img]",
	"术语_暴击": Cyan_B + GameLogic.CardTrans.get_message("术语_暴击") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_34.tres[/img]",
	"术语_暴击率": Cyan_B + GameLogic.CardTrans.get_message("术语_暴击率") + Color_end,
	"术语_暴击收益": Cyan_B + GameLogic.CardTrans.get_message("术语_暴击收益") + Color_end,
	"术语_压力": Red_B + GameLogic.CardTrans.get_message("术语_压力") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_presure.tres[/img]",
	"术语_无压力": Cyan_B + GameLogic.CardTrans.get_message("术语_无压力") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_presurefree.tres[/img]",
	"术语_高压": "[b][color=#de78ff]" + OutLine + GameLogic.CardTrans.get_message("术语_高压") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_presurehigh.tres[/img]",
	"术语_代价": Red_B + GameLogic.CardTrans.get_message("术语_代价") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_debuff.tres[/img]",
	"术语_点单": Yellow_B + GameLogic.CardTrans.get_message("术语_点单") + Color_end,
	"术语_未点单": "[b][color=#969696]" + OutLine + GameLogic.CardTrans.get_message("术语_未点单") + Color_end,
	"术语_未下单": "[b][color=#969696]" + OutLine + GameLogic.CardTrans.get_message("术语_未下单") + Color_end,
	"术语_丢单": Red_B + GameLogic.CardTrans.get_message("术语_丢单") + Color_end,
	"术语_出杯": Yellow_B + GameLogic.CardTrans.get_message("术语_出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_21.tres[/img]",

	"术语_跳单出杯": "[b][color=#f999ff]" + OutLine + GameLogic.CardTrans.get_message("术语_跳单出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_33.tres[/img]",
	"术语_快速出杯": Lime_B + GameLogic.CardTrans.get_message("术语_快速出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_31.tres[/img]",
	"术语_极限出杯": Orange_B + GameLogic.CardTrans.get_message("术语_极限出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_32.tres[/img]",
	"术语_完美出杯": "[b][color=#f972ff]" + OutLine + GameLogic.CardTrans.get_message("术语_完美出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_mood1.tres[/img]",
	"术语_跳单数": "[b][color=#f999ff]" + OutLine + GameLogic.CardTrans.get_message("术语_跳单数") + Color_end,
	"术语_快速数": Lime_B + GameLogic.CardTrans.get_message("术语_快速数") + Color_end,
	"术语_极限数": Orange_B + GameLogic.CardTrans.get_message("术语_极限数") + Color_end,
	"术语_完美数": "[b][color=#f972ff]" + OutLine + GameLogic.CardTrans.get_message("术语_完美数") + Color_end,
	"术语_COMBO数": Yellow_B + GameLogic.CardTrans.get_message("术语_COMBO数") + Color_end,
	"术语_暴击数": Cyan_B + GameLogic.CardTrans.get_message("术语_暴击数") + Color_end,
	"术语_压力值": Red_B + GameLogic.CardTrans.get_message("术语_压力值") + Color_end,
	"术语_非完美出杯": "[b][color=#ffc053]" + OutLine + GameLogic.CardTrans.get_message("术语_非完美出杯") + Color_end,
	"术语_稍差出杯": "[b][color=#ffc053]" + OutLine + GameLogic.CardTrans.get_message("术语_稍差出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_mood2.tres[/img]",
	"术语_勉强出杯": "[b][color=#6e84f7]" + OutLine + GameLogic.CardTrans.get_message("术语_勉强出杯") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_mood3.tres[/img]",
	"术语_收银机": Yellow_B + GameLogic.CardTrans.get_message("术语_收银机") + Color_end,
	"术语_制冰机": Yellow_B + GameLogic.CardTrans.get_message("术语_制冰机") + Color_end,
	"术语_蒸汽机": Yellow_B + GameLogic.CardTrans.get_message("术语_蒸汽机") + Color_end,
	"术语_果糖机": Yellow_B + GameLogic.CardTrans.get_message("术语_果糖机") + Color_end,
	"术语_咖啡机": Yellow_B + GameLogic.CardTrans.get_message("术语_咖啡机") + Color_end,
	"术语_榨汁机": Yellow_B + GameLogic.CardTrans.get_message("术语_榨汁机") + Color_end,
	"术语_电磁炉": Yellow_B + GameLogic.CardTrans.get_message("术语_电磁炉") + Color_end,
	"术语_珍珠锅": Yellow_B + GameLogic.CardTrans.get_message("术语_珍珠锅") + Color_end,
	"术语_茶壶": Yellow_B + GameLogic.CardTrans.get_message("术语_茶壶") + Color_end,
	"术语_量杯": Yellow_B + GameLogic.CardTrans.get_message("术语_量杯") + Color_end,
	"术语_垃圾桶": Yellow_B + GameLogic.CardTrans.get_message("术语_垃圾桶") + Color_end,
	"术语_杯架": Yellow_B + GameLogic.CardTrans.get_message("术语_杯架") + Color_end,
	"术语_桌台": Yellow_B + GameLogic.CardTrans.get_message("术语_桌台") + Color_end,
	"术语_菜板": Yellow_B + GameLogic.CardTrans.get_message("术语_菜板") + Color_end,
	"术语_新鲜": Yellow_B + GameLogic.CardTrans.get_message("术语_新鲜") + Color_end,
	"术语_陈旧": Orange_B + GameLogic.CardTrans.get_message("术语_陈旧") + Color_end,
	"术语_腐坏": Red_B + GameLogic.CardTrans.get_message("术语_腐坏") + Color_end,
	"术语_顾客": Yellow_B + GameLogic.CardTrans.get_message("术语_顾客") + Color_end,
	"术语_排队": Yellow_B + GameLogic.CardTrans.get_message("术语_排队") + Color_end,
	"术语_排队时间": Yellow_B + GameLogic.CardTrans.get_message("术语_排队时间") + Color_end,
	"术语_等待时间": Yellow_B + GameLogic.CardTrans.get_message("术语_等待时间") + Color_end,
	"术语_点单思考": Yellow_B + GameLogic.CardTrans.get_message("术语_点单思考") + Color_end,
	"术语_提前营业": Yellow_B + GameLogic.CardTrans.get_message("术语_提前营业") + Color_end,
	"术语_完美收拾": Yellow_B + GameLogic.CardTrans.get_message("术语_完美收拾") + Color_end,
	"术语_营业结束": Yellow_B + GameLogic.CardTrans.get_message("术语_营业结束") + Color_end,
	"术语_小混混": White_B + GameLogic.CardTrans.get_message("术语_小混混") + Color_end,
	"术语_小偷": White_B + GameLogic.CardTrans.get_message("术语_小偷") + Color_end,
	"术语_探店客": White_B + GameLogic.CardTrans.get_message("术语_探店客") + Color_end,
	"术语_批评家": White_B + GameLogic.CardTrans.get_message("术语_批评家") + Color_end,
	"术语_检查员": White_B + GameLogic.CardTrans.get_message("术语_检查员") + Color_end,
	"术语_学咖族": White_B + GameLogic.CardTrans.get_message("术语_学咖族") + Color_end,
	"术语_小杯子": White_B + GameLogic.CardTrans.get_message("术语_小杯子") + Color_end,
	"术语_马克杯": White_B + GameLogic.CardTrans.get_message("术语_马克杯") + Color_end,
	"术语_大纸杯": White_B + GameLogic.CardTrans.get_message("术语_大纸杯") + Color_end,
	"术语_英式茶杯": White_B + GameLogic.CardTrans.get_message("术语_英式茶杯") + Color_end,
	"术语_日式茶杯": White_B + GameLogic.CardTrans.get_message("术语_日式茶杯") + Color_end,
	"术语_双耳茶杯": White_B + GameLogic.CardTrans.get_message("术语_双耳茶杯") + Color_end,
	"术语_大瓶子": White_B + GameLogic.CardTrans.get_message("术语_大瓶子") + Color_end,
	"术语_玻璃瓶": White_B + GameLogic.CardTrans.get_message("术语_玻璃瓶") + Color_end,
	"术语_常温": "[b][color=#00a2ff]" + OutLine + GameLogic.CardTrans.get_message("术语_常温") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_state_cold.tres[/img]",
	"术语_冰": Cyan_B + GameLogic.CardTrans.get_message("术语_冰") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_state_ice.tres[/img]",
	"术语_热": Orange_B + GameLogic.CardTrans.get_message("术语_热") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_state_hot.tres[/img]",
	"术语_沸腾": Red_B + GameLogic.CardTrans.get_message("术语_沸腾") + Color_end,




	"Rent": Yellow_B + GameLogic.CardTrans.get_message("Rent") + Color_end,
	"Water Bill": Yellow_B + GameLogic.CardTrans.get_message("Water Bill") + Color_end,
	"Electricity Bill": Yellow_B + GameLogic.CardTrans.get_message("Electricity Bill") + Color_end,
	"Drink": Yellow_B + GameLogic.CardTrans.get_message("Drink") + Color_end,
	"Topping": Yellow_B + GameLogic.CardTrans.get_message("Topping") + Color_end,
	"Cup": Yellow_B + GameLogic.CardTrans.get_message("Cup") + Color_end,
	"Garnish": Yellow_B + GameLogic.CardTrans.get_message("Garnish") + Color_end,
	"Cup Wall Art": Yellow_B + GameLogic.CardTrans.get_message("Cup Wall Art") + Color_end,
	"Drizzle": Yellow_B + GameLogic.CardTrans.get_message("Drizzle") + Color_end,
	"Shaker": Yellow_B + GameLogic.CardTrans.get_message("Shaker") + Color_end,
	"Stir": Yellow_B + GameLogic.CardTrans.get_message("Stir") + Color_end,
	"Open Lid": Yellow_B + GameLogic.CardTrans.get_message("Open Lid") + Color_end,
	"Chopping": Yellow_B + GameLogic.CardTrans.get_message("Chopping") + Color_end,
	"Hand Work": Yellow_B + GameLogic.CardTrans.get_message("Hand Work") + Color_end,
	"Server": White_B + GameLogic.CardTrans.get_message("Server") + Color_end,
	"Order Taker": White_B + GameLogic.CardTrans.get_message("Order Taker") + Color_end,
	"Any Staff": White_B + GameLogic.CardTrans.get_message("Any Staff") + Color_end,
	"All Staff": White_B + GameLogic.CardTrans.get_message("All Staff") + Color_end,
	"Welcome": White_B + GameLogic.CardTrans.get_message("Welcome") + Color_end,
	"COMBO": Yellow_B + GameLogic.CardTrans.get_message("COMBO") + Color_end,
	"Base Price": "[b][color=white]" + OutLine + GameLogic.CardTrans.get_message("Base Price") + Color_end,
	"Total Price": Yellow_B + GameLogic.CardTrans.get_message("Total Price") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Revenue": Yellow_B + GameLogic.CardTrans.get_message("Revenue") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Unit Price": Yellow_B + GameLogic.CardTrans.get_message("Unit Price") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Tip": Yellow_B + GameLogic.CardTrans.get_message("Tip") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Base Tip": Yellow_B + GameLogic.CardTrans.get_message("Base Tip") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Extra Tip": Yellow_B + GameLogic.CardTrans.get_message("Extra Tip") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Price Mult": Yellow_B + GameLogic.CardTrans.get_message("Price Mult") + Color_end,
	"Total Mult": Yellow_B + GameLogic.CardTrans.get_message("Total Mult") + Color_end,
	"Tip Mult": Yellow_B + GameLogic.CardTrans.get_message("Tip Mult") + Color_end,
	"Extra Revenue": Yellow_B + GameLogic.CardTrans.get_message("Extra Revenue") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"Cup Coin": Yellow_B + GameLogic.CardTrans.get_message("Cup Coin") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_coin.tres[/img]",
	"LUX": Lime_B + GameLogic.CardTrans.get_message("LUX") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_money.tres[/img]",
	"Demonic Contract": Red_B + GameLogic.CardTrans.get_message("Demonic Contract") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_evil.tres[/img]",
	"Contract Re-draw": Lime_B + GameLogic.CardTrans.get_message("Contract Re-draw") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_reroll.tres[/img]",
	"Demonic Ability": Lime_B + GameLogic.CardTrans.get_message("Demonic Ability") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_gift.tres[/img]",
	"Gift Re-draw": Lime_B + GameLogic.CardTrans.get_message("Gift Re-draw") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_regift.tres[/img]",
	"REP": Orange_B + GameLogic.CardTrans.get_message("REP") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_rep.tres[/img]",
	"EXP": Orange_B + GameLogic.CardTrans.get_message("EXP") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_exp.tres[/img]",
	"Crit": Cyan_B + GameLogic.CardTrans.get_message("Crit") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_34.tres[/img]",
	"Crit Rate": Cyan_B + GameLogic.CardTrans.get_message("Crit Rate") + Color_end,
	"Crit Earnings": Cyan_B + GameLogic.CardTrans.get_message("Crit Earnings") + Color_end,
	"Stress": Red_B + GameLogic.CardTrans.get_message("Stress") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_presure.tres[/img]",
	"No Stress": Cyan_B + GameLogic.CardTrans.get_message("No Stress") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_presurefree.tres[/img]",
	"High Stress": "[b][color=#de78ff]" + OutLine + GameLogic.CardTrans.get_message("High Stress") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_presurehigh.tres[/img]",
	"Cost": Red_B + GameLogic.CardTrans.get_message("Cost") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_debuff.tres[/img]",
	"Order": Yellow_B + GameLogic.CardTrans.get_message("Order") + Color_end,
	"Ignore Order": "[b][color=#969696]" + OutLine + GameLogic.CardTrans.get_message("Ignore Order") + Color_end,
	"Drop Order": "[b][color=#969696]" + OutLine + GameLogic.CardTrans.get_message("Drop Order") + Color_end,
	"Abandon Order": Red_B + GameLogic.CardTrans.get_message("Abandon Order") + Color_end,
	"Sale": Yellow_B + GameLogic.CardTrans.get_message("Sale") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_21.tres[/img]",
	"Impatient": Red_B + GameLogic.CardTrans.get_message("Impatient") + Color_end,
	"Prioritize Sale": "[b][color=#f999ff]" + OutLine + GameLogic.CardTrans.get_message("Prioritize Sale") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_33.tres[/img]",
	"Quick Sale": Lime_B + GameLogic.CardTrans.get_message("Quick Sale") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_31.tres[/img]",
	"Just-in-time Sale": Orange_B + GameLogic.CardTrans.get_message("Just-in-time Sale") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_poptip_idea_32.tres[/img]",
	"Good Review": "[b][color=#f972ff]" + OutLine + GameLogic.CardTrans.get_message("Good Review") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_mood1.tres[/img]",
	"Prioritize Number": "[b][color=#f999ff]" + OutLine + GameLogic.CardTrans.get_message("Prioritize Number") + Color_end,
	"Quick Number": Lime_B + GameLogic.CardTrans.get_message("Quick Number") + Color_end,
	"Just-in-time Number": Orange_B + GameLogic.CardTrans.get_message("Just-in-time Number") + Color_end,
	"Good Review Number": "[b][color=#f972ff]" + OutLine + GameLogic.CardTrans.get_message("Good Review Number") + Color_end,
	"COMBO Number": Yellow_B + GameLogic.CardTrans.get_message("COMBO Number") + Color_end,
	"Crit Number": Cyan_B + GameLogic.CardTrans.get_message("Crit Number") + Color_end,
	"Stress Value": Red_B + GameLogic.CardTrans.get_message("Stress Value") + Color_end,
	"Neutral-to-Bad Review": "[b][color=#ffc053]" + OutLine + GameLogic.CardTrans.get_message("Neutral-to-Bad Review") + Color_end,
	"Neutral Review": "[b][color=#ffc053]" + OutLine + GameLogic.CardTrans.get_message("Neutral Review") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_mood2.tres[/img]",
	"Bad Review": "[b][color=#6e84f7]" + OutLine + GameLogic.CardTrans.get_message("Bad Review") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/icon_text_mood3.tres[/img]",
	"Cash Register": Yellow_B + GameLogic.CardTrans.get_message("Cash Register") + Color_end,
	"Ice Machine": Yellow_B + GameLogic.CardTrans.get_message("Ice Machine") + Color_end,
	"Steamer": Yellow_B + GameLogic.CardTrans.get_message("Steamer") + Color_end,
	"Fructose Machine": Yellow_B + GameLogic.CardTrans.get_message("Fructose Machine") + Color_end,
	"Coffee Machine": Yellow_B + GameLogic.CardTrans.get_message("Coffee Machine") + Color_end,
	"Juicer": Yellow_B + GameLogic.CardTrans.get_message("Juicer") + Color_end,
	"Induction Cooker": Yellow_B + GameLogic.CardTrans.get_message("Induction Cooker") + Color_end,
	"Boba Machine": Yellow_B + GameLogic.CardTrans.get_message("Boba Machine") + Color_end,
	"Teapot": Yellow_B + GameLogic.CardTrans.get_message("Teapot") + Color_end,
	"Measuring Cup": Yellow_B + GameLogic.CardTrans.get_message("Measuring Cup") + Color_end,
	"Trash Can": Yellow_B + GameLogic.CardTrans.get_message("Trash Can") + Color_end,
	"Cup Dispenser": Yellow_B + GameLogic.CardTrans.get_message("Cup Dispenser") + Color_end,
	"Rack Stand": Yellow_B + GameLogic.CardTrans.get_message("Rack Stand") + Color_end,
	"Chopping Board": Yellow_B + GameLogic.CardTrans.get_message("Chopping Board") + Color_end,
	"Soda Water Machine": Yellow_B + GameLogic.CardTrans.get_message("Soda Water Machine") + Color_end,
	"Soft Drink Blender": Yellow_B + GameLogic.CardTrans.get_message("Soft Drink Blender") + Color_end,
	"Gas Bottle": Yellow_B + GameLogic.CardTrans.get_message("Gas Bottle") + Color_end,
	"Water Tank": Yellow_B + GameLogic.CardTrans.get_message("Water Tank") + Color_end,
	"Fresh": Yellow_B + GameLogic.CardTrans.get_message("Fresh") + Color_end,
	"Stale": Orange_B + GameLogic.CardTrans.get_message("Stale") + Color_end,
	"Spoiled": Red_B + GameLogic.CardTrans.get_message("Spoiled") + Color_end,
	"Customer": Yellow_B + GameLogic.CardTrans.get_message("Customer") + Color_end,
	"Line": Yellow_B + GameLogic.CardTrans.get_message("Line") + Color_end,
	"Line Wait Time": Yellow_B + GameLogic.CardTrans.get_message("Line Wait Time") + Color_end,
	"Order Wait Time": Yellow_B + GameLogic.CardTrans.get_message("Order Wait Time") + Color_end,
	"Thinking About Order": Yellow_B + GameLogic.CardTrans.get_message("Thinking About Order") + Color_end,
	"Open Early": Yellow_B + GameLogic.CardTrans.get_message("Open Early") + Color_end,
	"Perfect Shift": Yellow_B + GameLogic.CardTrans.get_message("Perfect Shift") + Color_end,
	"Closing Time": Yellow_B + GameLogic.CardTrans.get_message("Closing Time") + Color_end,
	"Thug": White_B + GameLogic.CardTrans.get_message("Thug") + Color_end,
	"Thief": White_B + GameLogic.CardTrans.get_message("Thief") + Color_end,
	"Shopper": White_B + GameLogic.CardTrans.get_message("Shopper") + Color_end,
	"Critic": White_B + GameLogic.CardTrans.get_message("Critic") + Color_end,
	"Inspector": White_B + GameLogic.CardTrans.get_message("Inspector") + Color_end,
	"Student": White_B + GameLogic.CardTrans.get_message("Student") + Color_end,
	"Small Cup": White_B + GameLogic.CardTrans.get_message("Small Cup") + Color_end,
	"Mug": White_B + GameLogic.CardTrans.get_message("Mug") + Color_end,
	"Large Paper Cup": White_B + GameLogic.CardTrans.get_message("Large Paper Cup") + Color_end,
	"British Teacup": White_B + GameLogic.CardTrans.get_message("British Teacup") + Color_end,
	"Japanese Teacup": White_B + GameLogic.CardTrans.get_message("Japanese Teacup") + Color_end,
	"Two-handled Cup": White_B + GameLogic.CardTrans.get_message("Two-handled Cup") + Color_end,
	"Big Bottle": White_B + GameLogic.CardTrans.get_message("Big Bottle") + Color_end,
	"Glass Bottle": White_B + GameLogic.CardTrans.get_message("Glass Bottle") + Color_end,
	"Room Temperature": "[b][color=#00a2ff]" + OutLine + GameLogic.CardTrans.get_message("Room Temperature") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_state_cold.tres[/img]",
	"Iced": Cyan_B + GameLogic.CardTrans.get_message("Iced") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_state_ice.tres[/img]",
	"Hot": Orange_B + GameLogic.CardTrans.get_message("Hot") + Color_end + "[img]res://Resources/UI/GameUI/ui_pack.sprites/Ui_icon_state_hot.tres[/img]",
	"Boiling": Red_B + GameLogic.CardTrans.get_message("Boiling") + Color_end,
	"Soda Pack": Yellow_B + GameLogic.CardTrans.get_message("Soda Pack") + Color_end,
	"Pop Cap": Yellow_B + GameLogic.CardTrans.get_message("Pop Cap") + Color_end,
	"Squeeze": Yellow_B + GameLogic.CardTrans.get_message("Squeeze") + Color_end,
	"Beat": Yellow_B + GameLogic.CardTrans.get_message("Beat") + Color_end,
	"Super Cup": Yellow_B + GameLogic.CardTrans.get_message("Super Cup") + Color_end,
	"Current Day": Yellow_B + GameLogic.CardTrans.get_message("Current Day") + Color_end,
	"Sell": Yellow_B + GameLogic.CardTrans.get_message("Sell") + Color_end,
	"Sell Count": Yellow_B + GameLogic.CardTrans.get_message("Sell Count") + Color_end,
	"Count": Yellow_B + GameLogic.CardTrans.get_message("Count") + Color_end,
	"Drink Star": Yellow_B + GameLogic.CardTrans.get_message("Drink Star") + Color_end,
	"Order Number": Yellow_B + GameLogic.CardTrans.get_message("Order Number") + Color_end,
	}
