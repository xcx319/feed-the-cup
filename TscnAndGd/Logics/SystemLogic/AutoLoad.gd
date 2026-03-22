extends Node

onready var loader: ResourceInteractiveLoader

onready var PLAYER_TSCN = preload("res://TscnAndGd/Main/Player/NewPlayer.tscn")

onready var Bear = preload("res://TscnAndGd/Characters/Bear.tscn")
onready var Fox = preload("res://TscnAndGd/Characters/Fox.tscn")
onready var Wolf = preload("res://TscnAndGd/Characters/Wolf.tscn")
onready var Beaver = preload("res://TscnAndGd/Characters/Beaver.tscn")
onready var Ghost = preload("res://TscnAndGd/Characters/Ghost.tscn")
onready var Goblin = preload("res://TscnAndGd/Characters/Goblin.tscn")
onready var Slime = preload("res://TscnAndGd/Characters/Slime.tscn")
onready var Delivery = preload("res://TscnAndGd/Characters/Delivery.tscn")
onready var Devil = preload("res://TscnAndGd/Characters/Devil.tscn")
onready var Panda = preload("res://TscnAndGd/Characters/Panda.tscn")
onready var Crocodile = preload("res://TscnAndGd/Characters/Crocodile.tscn")

onready var WaterStain_TSCN = preload("res://TscnAndGd/Objects/Special/WaterStain.tscn")

onready var Bottle_TSCN = preload("res://TscnAndGd/Objects/Items/Bottle.tscn")
onready var Bag_TSCN = preload("res://TscnAndGd/Objects/Items/Bag.tscn")
onready var Extra_TSCN = preload("res://TscnAndGd/Objects/Items/Extra.tscn")
onready var Trashbag_TSCN = preload("res://TscnAndGd/Objects/Items/Trashbag.tscn")

onready var Fruit_TSCN = preload("res://TscnAndGd/Objects/Items/Fruit.tscn")

onready var PayEffect_TSCN = preload("res://TscnAndGd/Effects/PayEffect.tscn")
onready var PressureEffect_TSCN = preload("res://TscnAndGd/Effects/PressureEffect.tscn")
onready var LoadingEffect = preload("res://TscnAndGd/Effects/LoadingEffect.tscn")
onready var SmellEffect = preload("res://TscnAndGd/Effects/Effect_flies.tscn")
onready var WaterTypeEffect = preload("res://TscnAndGd/Effects/WaterTypeIcon.tscn")
onready var NumControl_TSCN = preload("res://TscnAndGd/UI/Info/NumControl.tscn")
onready var FootPrintEffect_TSCN = preload("res://TscnAndGd/Effects/Effect_FootPrint.tscn")
onready var SpeedEffect_TSCN = preload("res://TscnAndGd/Effects/Effect_SpeedUp.tscn")
onready var SmokeEffect_TSCN = preload("res://TscnAndGd/Effects/Effect_Smoke.tscn")
onready var ThrowObj_TSCN = preload("res://TscnAndGd/Objects/Special/ThrowObj.tscn")
onready var HitEffect_TSCN = preload("res://TscnAndGd/Effects/Effect_Hit.tscn")

onready var DeviceSmokeEffect_TSCN = preload("res://TscnAndGd/Effects/Effect_device.tscn")

onready var BuyButton_TSCN = preload("res://TscnAndGd/UI/InGame/Buy_Button.tscn")
onready var MenuBut = preload("res://TscnAndGd/UI/InGame/Menu_Button.tscn")

onready var DayClosedInfo_TSCN = preload("res://TscnAndGd/UI/Info/DayClosedInfo.tscn")
onready var StudyIcon_TSCN = preload("res://TscnAndGd/UI/Info/StudyIcon.tscn")
onready var StaffWorkBut_TSCN = preload("res://TscnAndGd/UI/Buttons/StaffWorkButton.tscn")
onready var DevilIcon_TSCN = preload("res://TscnAndGd/Buttons/Devil_Icon.tscn")

var UI_Path = "res://Resources/UI/GameUI/ui_pack.sprites/"

onready var ChooseChallenge_TSCN = preload("res://TscnAndGd/UI/Buttons/ChallengeButton.tscn")

func return_player(_Num):
	return PLAYER_TSCN

func return_character(_Name):
	match _Name:
		"Devil":
			return Devil
		"SlimeCleaner":
			return load("res://TscnAndGd/Characters/SlimeCleaner.tscn")
		"Bear":
			return Bear
		"Fox":
			return Fox
		"Wolf":
			return Wolf
		"Beaver":
			return Beaver
		"Goblin":
			return Goblin
		"Slime":
			return Slime
		"Ghost":
			return Ghost
		"Delivery":
			return Delivery
		"Devil":
			return Devil
		"Panda":
			return Panda
		"Crocodile":
			return Crocodile
func return_TSCN(_TSCN):
	match _TSCN:
		"HighStressToy":
			return load("res://TscnAndGd/Objects/Special/HighStressToy.tscn")
		"BeerMachine":
			return load("res://TscnAndGd/Objects/Devices/BeerMachine.tscn")
		"拉格", "艾尔", "小麦", "IPA", "皮尔森", "世涛":
			return load("res://TscnAndGd/Objects/Items/Barrel.tscn")
		"Shelf_Beer":
			return load("res://TscnAndGd/Objects/Devices/Shelf_Beer.tscn")
		"Shelf_GlassCup":
			return load("res://TscnAndGd/Objects/Devices/Shelf_S_Plastic.tscn")
		"CleanMachine":
			return load("res://TscnAndGd/Objects/Devices/CleanMachine.tscn")
		"Plate":
			return load("res://TscnAndGd/Objects/Devices/Shelf_Plate.tscn")
		"EggRoll_white", "EggRoll_black":
			return load("res://TscnAndGd/Objects/Items/EggRoll.tscn")
		"EggRollPot":
			return load("res://TscnAndGd/Objects/Devices/EggRollPot.tscn")
		"EggRollMachine":
			return load("res://TscnAndGd/Objects/Devices/EggRollMachine.tscn")
		"MixerMachine":
			return load("res://TscnAndGd/Objects/Devices/MixerMachine.tscn")
		"CreamMachine":
			return load("res://TscnAndGd/Objects/Devices/CreamMachine.tscn")
		"IceCreamBox":
			return load("res://TscnAndGd/Objects/Devices/IceCreamBox.tscn")
		"IceCreamMachine":
			return load("res://TscnAndGd/Objects/Devices/IceCreamMachine.tscn")
		"BreakMachine":
			return load("res://TscnAndGd/Objects/Devices/BreakMachine.tscn")
		"FruitShelf":
			return load("res://TscnAndGd/Objects/Devices/Shelf_M_Steel.tscn")
		"FreezerBig":
			return load("res://TscnAndGd/Objects/Devices/FreezerBox_Big.tscn")
		"FruitCore":
			return load("res://TscnAndGd/Objects/Devices/FruitCore.tscn")
		"SmashTable":
			return load("res://TscnAndGd/Objects/Devices/SmashTable.tscn")
		"ChopMachine":
			return load("res://TscnAndGd/Objects/Devices/ChopMachine.tscn")
		"TicketMachine":
			return load("res://TscnAndGd/Objects/Devices/TicketMachine.tscn")
		"SodaCan", "SodaCan_S", "SodaCan_M", "SodaCan_L":
			return load("res://TscnAndGd/Objects/Items/SodaCan.tscn")
		"SuperCup", "SuperCup_M":
			return load("res://TscnAndGd/Objects/Items/SuperCup.tscn")
		"SodaPack":
			return load("res://TscnAndGd/Objects/Devices/SodaPack.tscn")
		"PopWaterMachine":
			return load("res://TscnAndGd/Objects/Devices/PopWaterMachine.tscn")
		"Freezer":
			return load("res://TscnAndGd/Objects/Devices/Shelf_Frozen.tscn")

		"GasBox":
			return load("res://TscnAndGd/Objects/Devices/GasBox.tscn")
		"GasBottle":
			return load("res://TscnAndGd/Objects/Devices/GasBottle.tscn")
		"PopCap":
			return load("res://TscnAndGd/Objects/Devices/PopCap.tscn")
		"PopMachine":
			return load("res://TscnAndGd/Objects/Devices/PopMachine.tscn")
		"BobaMachine":
			return load("res://TscnAndGd/Objects/Devices/BobaMachine.tscn")
		"TeaBarrelShelf":
			return load("res://TscnAndGd/Objects/Devices/TeaBarrelShelf.tscn")
		"TeaBarrel":
			return load("res://TscnAndGd/Objects/Devices/TeaBarrel.tscn")
		"GramScale":
			return load("res://TscnAndGd/Objects/Devices/Gramscale.tscn")
		"MilkPot":
			return load("res://TscnAndGd/Objects/Devices/MilkPot.tscn")
		"BigPot":
			return load("res://TscnAndGd/Objects/Devices/BigPot.tscn")
		"MopPool":
			return load("res://TscnAndGd/Objects/Devices/DeviceMopPool.tscn")
		"Mop":
			return load("res://TscnAndGd/Objects/Devices/Mop_pool.tscn")
		"SnowShovel":
			return load("res://TscnAndGd/Objects/Devices/SnowShovel.tscn")
		"水果", "Fruit":
			return Fruit_TSCN
		"WorkBench":
			return load("res://TscnAndGd/Objects/Devices/WorkBench.tscn")
		"TeaPort":
			return load("res://TscnAndGd/Objects/Devices/TeaPort.tscn")
		"WaterPort":
			return load("res://TscnAndGd/Objects/Devices/WaterPort.tscn")
		"WaterTank":
			return load("res://TscnAndGd/Objects/Devices/WaterTank_S_Steel.tscn")
		"InductionCooker":
			return load("res://TscnAndGd/Objects/Devices/InductionCooker.tscn")
		"Trashbin":
			return load("res://TscnAndGd/Objects/Devices/Trashbin.tscn")
		"WorkBench_Immovable":
			return load("res://TscnAndGd/Objects/Devices/WorkBench_Immovable.tscn")
		"OrderTab":
			return load("res://TscnAndGd/Objects/Devices/OrderTab.tscn")
		"CupHolder":
			return load("res://TscnAndGd/Objects/Devices/CupHolder_L.tscn")
		"Shelf":
			return load("res://TscnAndGd/Objects/Devices/Shelf.tscn")
		"FreezeShelf":
			return load("res://TscnAndGd/Objects/Devices/Shelf_M_Freezer.tscn")
		"WorkBoard":
			return load("res://TscnAndGd/Objects/Devices/WorkBoard.tscn")
		"JuiceMachine":
			return load("res://TscnAndGd/Objects/Devices/JuiceMachine.tscn")
		"CoffeeMachine":
			return load("res://TscnAndGd/Objects/Devices/CoffeeMachine.tscn")
		"IceMachine":
			return load("res://TscnAndGd/Objects/Devices/IceMachine.tscn")
		"HotWaterMachine":
			return load("res://TscnAndGd/Objects/Devices/HotWaterMachine.tscn")
		"SugarMachine":
			return load("res://TscnAndGd/Objects/Devices/SugarMachine.tscn")
		"ShakeCup":
			return load("res://TscnAndGd/Objects/Devices/ShakeCup_L.tscn")
		"DrinkCup", "DrinkCup_S", "DrinkCup_M", "DrinkCup_L":
			return load("res://TscnAndGd/Objects/Items/DrinkCup.tscn")
		"BeerCup", "BeerCup_S", "BeerCup_M", "BeerCup_L":
			return load("res://TscnAndGd/Objects/Items/BeerCup.tscn")
		"Trashbag":
			return Trashbag_TSCN
		"Shelf_OnTable":
			return load("res://TscnAndGd/Objects/Devices/Shelf_OnTable.tscn")
		"FreezerOnTable":
			return load("res://TscnAndGd/Objects/Devices/FreezerOnTable.tscn")
		"FreezerBox":
			return load("res://TscnAndGd/Objects/Devices/FreezerBox.tscn")
		"MaterialBig":
			return load("res://TscnAndGd/Objects/Devices/MaterialBox_Big.tscn")
		"MaterialBox":
			return load("res://TscnAndGd/Objects/Devices/MaterialBox.tscn")
		_:
			if not GameLogic.Config.ItemConfig.has(_TSCN):

				return
			var _func = GameLogic.Config.ItemConfig[_TSCN].FuncType
			match _func:
				"Hang", "Top", "Bottle", "Pop":
					return Bottle_TSCN

				"EggRoll", "TeaLeaf", "Powder", "Sugar", "Choco", "FreeSugar", "Pot", "CoffeeBean", "Cooker", "TeaBag", "FruitTrash", "Cake":
					return Bag_TSCN
				"DrinkCup_Group":
					return load("res://TscnAndGd/Objects/Items/DrinkCup_Group.tscn")
				"DrinkCup":
					return load("res://TscnAndGd/Objects/Items/DrinkCup.tscn")
				"Can":
					return load("res://TscnAndGd/Objects/Items/Can.tscn")
				"Box":
					return load("res://TscnAndGd/Objects/Items/Box_M_Paper.tscn")
				"BoxWood":
					return load("res://TscnAndGd/Objects/Items/WoodBox.tscn")
				_:
					printerr(_TSCN, " 不存在于Item中")
func return_weight(_functype):
	match _functype:
		"Sugar", "FreeSugar", "Choco":
			return 2
		"Bottle":
			return 1
		"TeaLeaf":
			return 1
		"Powder":
			return 1
		"DrinkCup_Group":
			return 1
		"DrinkCup":
			return 1
		"Can":
			return 1
		_:
			return 1
