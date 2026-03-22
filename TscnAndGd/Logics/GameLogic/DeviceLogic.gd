extends Node

onready var PickAudio

signal FuncCheckLogic(_ButID, _Player, _DevObj, _Action)

func _ready() -> void :
	call_deferred("Audio_init")
func Audio_init():
	PickAudio = GameLogic.Audio.return_Effect("拿起")

func call_teach(_ButID, _Player, _DevObj, _Action):

	emit_signal("FuncCheckLogic", _ButID, _Player, _DevObj, _Action)
func call_touch(body, _Obj, _switch: bool) -> void :
	if body.has_method("call_ThrowObj"):
		return
	if body.has_method("_PlayerNode"):
		pass
	elif body.IsCourier:
		pass

	match _switch:
		true:

			body.cur_Touch_Count += 1
			body.Stat.call_across_in()
			if not body.cur_Touch_List.has(_Obj):
				body.cur_Touch_List.append(_Obj)
				if body.has_method("call_AcrossItem"):
					body.call_AcrossItem(_Obj)

			if not body.has_method("call_control"):
				return
			body.call_touch()
		false:
			body.cur_Touch_Count -= 1

			body.Stat.call_across_end()
			if body.cur_Touch_List.has(_Obj):
				body.cur_Touch_List.erase(_Obj)
			if not body.has_method("call_control"):
				return
			yield(get_tree().create_timer(0.01), "timeout")
			if is_instance_valid(body):
				body.call_touch()

func call_TouchDev_Logic(_TouchOrBut, _Player, _DevTouch):

	if not _DevTouch.has_method("_ready"):

		return
	if _DevTouch.has_method("call_Study_Finish"):
		return
	if _TouchOrBut == - 2:

		if _DevTouch.get("HasTable"):
			if is_instance_valid(_DevTouch.OnTableObj):
				var _Dev = _DevTouch.OnTableObj
				if not is_instance_valid(_Dev):
					return
				if _Dev.has_method("call_SHAKE_end"):
					_Dev.call_SHAKE_end(_Player)
		if _DevTouch.has_method("_CleanLogic"):
			_DevTouch._CleanLogic(false, _Player)
		if not _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
			return

		if _DevTouch.has_method("But_Switch"):
			_DevTouch.But_Switch(false, _Player)

		if _DevTouch.has_method("call_put_in_cup"):
			_DevTouch.call_put_in_cup(_TouchOrBut, _Player, null)
		if _DevTouch.get("HasTable"):
			if is_instance_valid(_DevTouch.OnTableObj):
				var _Dev = _DevTouch.OnTableObj
				if _Dev.get("SelfDev") == "InductionCooker":
					var _OBJ = _Dev.OnTableObj
					if is_instance_valid(_OBJ):
						if _OBJ.has_method("call_Pot_In"):
							_OBJ.call_Pot_In(_TouchOrBut, null, _Player)
						if _OBJ.has_method("But_Switch"):
							_OBJ.But_Switch(false, _Player)
				if _Dev.has_method("But_Switch"):
					_Dev.But_Switch(false, _Player)
				if _Dev.has_method("call_CupInfo_Switch"):
					_Dev.call_CupInfo_Switch(false)
				if _Dev.has_method("call_ChangeID"):
					_Dev.call_ChangeID(_TouchOrBut, null, _Player)

		if _DevTouch.has_method("call_OutLine"):
				_DevTouch.call_OutLine(false)
		if _DevTouch.has_method("call_Box_OnTable"):
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			_DevTouch.call_Box_OnTable(_TouchOrBut, _HoldObj, _Player)
		if _Player.Con.IsHold:
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			if not is_instance_valid(_HoldObj):
				return
			_HoldObj.But_Switch(false, _Player)
		if _DevTouch.get("FuncType") == "Box":
			var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
			if _DevTouch.has_method("call_PickFruitInCup"):
				_DevTouch.call_PickFruitInCup(_TouchOrBut, _HoldObj, _Player)
	if _TouchOrBut == - 1:
		if _DevTouch.has_method("call_OutLine"):
			if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
				_DevTouch.call_OutLine(true)

		if _DevTouch.get("HasTable"):
			if is_instance_valid(_DevTouch.OnTableObj):
				var _Dev = _DevTouch.OnTableObj

				if _DevTouch.has_method("But_Switch"):
					_DevTouch.But_Switch(false, _Player)
				if not _Player.Con.IsHold:
					if not is_instance_valid(_Dev):
						return
					if _Dev.CanMove:
						if _Dev.has_method("But_Switch"):
							if _TouchOrBut == - 1:
								_Dev.But_Switch(true, _Player)
						if _Dev.has_method("call_CupInfo_Switch"):
							if _Player.name in ["1", "2", str(SteamLogic.STEAM_ID)]:
								_Dev.call_CupInfo_Switch(true)
					elif _Dev.CanPick:

						if _Dev.has_method("But_Switch"):
							if _TouchOrBut == - 1:
								_Dev.But_Switch(true, _Player)
					else:

						var _return = _call_FuncCheckLogic(_TouchOrBut, _Player, _Dev)

				else:
					return _call_FuncCheckLogic(_TouchOrBut, _Player, _Dev)

			else:
				if _Player.Con.IsHold:

					if _DevTouch.has_method("But_Switch"):

						if _TouchOrBut == - 1:
							var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
							if not is_instance_valid(_HoldObj):
								return
							if _HoldObj.has_method("_CanMove_Check"):
								var _Func = _HoldObj.FuncType
								if _Func in ["Plate"]:
									_DevTouch.But_Switch(true, _Player)
								elif _DevTouch.SelfDev == "WorkBench_Immovable":
									if _DevTouch.CanPutDev:
										_DevTouch.But_Switch(true, _Player)
								else:
									_DevTouch.But_Switch(true, _Player)
							else:
								_DevTouch.But_Switch(true, _Player)
				else:
					if _DevTouch.has_method("But_Switch"):
						if _TouchOrBut == - 1:
							_DevTouch.But_Switch(false, _Player)
		else:

			return _call_FuncCheckLogic(_TouchOrBut, _Player, _DevTouch)
	else:

		if is_instance_valid(_DevTouch.get("OnTableObj")):
			var _Dev = _DevTouch.OnTableObj
			if not is_instance_valid(_Dev):
				return

			if _Dev.has_method("But_Switch"):

				if _TouchOrBut < - 1:
					_Dev.But_Switch(false, _Player)


		else:

			if _DevTouch.has_method("But_Switch"):
				if _TouchOrBut < - 1:
					_DevTouch.But_Switch(false, _Player)

			if _Player.Con.IsHold:


				pass

func Call_CheckLogic(_buttonID, _Player, _DevTouchNode):

	if not _DevTouchNode.has_method("_ready"):
		return 0


	if _Player.Con.IsHold:

		if _DevTouchNode.get("HasTable"):
			if not is_instance_valid(_DevTouchNode.OnTableObj):
				if _buttonID == 0:
					var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
					if _HoldObj.has_method("_CanMove_Check"):
						if _DevTouchNode.SelfDev == "WorkBench_Immovable":
							var _Func = _HoldObj.FuncType
							if _Func in ["Plate"]:
								DevLogic_Put(_buttonID, _Player, _DevTouchNode)
								return "放桌上"
							if _DevTouchNode.CanPutDev:
								DevLogic_Put(_buttonID, _Player, _DevTouchNode)
								return "放桌上"
							else:

								_DevTouchNode.call_NoPut()
								return
						else:
							DevLogic_Put(_buttonID, _Player, _DevTouchNode)
							return "放桌上"
					else:
						DevLogic_Put(_buttonID, _Player, _DevTouchNode)
						return "放桌上"
				else:
					return
			else:

				var _DevObj = _DevTouchNode.OnTableObj
				return _call_FuncCheckLogic(_buttonID, _Player, _DevObj)
		else:
			return _call_FuncCheckLogic(_buttonID, _Player, _DevTouchNode)
	else:

		if _DevTouchNode.has_method("call_Study_Finish"):
			return

		if _DevTouchNode.get("HasTable"):
			if _DevTouchNode.FuncType == "PickUp":
				var _check = _DevTouchNode.call_pickup_logic(_buttonID, _Player)

				if _check == "出杯":
					GameLogic.Device.call_teach(_buttonID, _Player, _DevTouchNode, "出杯")
					return
			if is_instance_valid(_DevTouchNode.OnTableObj):
				var _DevObj = _DevTouchNode.OnTableObj


				if _buttonID == 0:

					if _DevObj.IsItem:
						return DevLogic_Pick(_buttonID, _Player, _DevTouchNode)

					elif _DevObj.CanMove:
						return DevLogic_Pick(_buttonID, _Player, _DevTouchNode)

					else:
						return _call_FuncCheckLogic(_buttonID, _Player, _DevObj)

				else:

					return _call_FuncCheckLogic(_buttonID, _Player, _DevObj)

			else:
				return _call_FuncCheckLogic(_buttonID, _Player, _DevTouchNode)

				pass
		else:
			return _call_FuncCheckLogic(_buttonID, _Player, _DevTouchNode)

	pass

func _call_FuncCheckLogic(_ButID, _Player, _DevObj):


	if not is_instance_valid(_DevObj):
		return
	if _Player.Con.IsHold:
		var _HoldObj = instance_from_id(_Player.Con.HoldInsId)
		if not is_instance_valid(_HoldObj):
			_Player.Con.HoldInsId = 0
			return
		var _HoldObjType = _HoldObj.FuncType
		var _DevType = _DevObj.get("FuncType")

		match _HoldObjType:
			"Beer":
				match _DevType:
					"BeerMachine":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Shelf_Beer":
						return _DevObj.call_PutOn(_ButID, _Player)
			"CreamMachine":

				match _DevType:
					"Con_Liquid":
						return _HoldObj.call_Out(_ButID, _DevObj, _Player)
					"Trashbin", "Water_Normal":
						return _DevObj.call_CreamMachine_Trash(_ButID, _Player, _HoldObj)
					"Con_Liquid":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
			"Cooker", "Cake":
				match _DevType:
					"WorkBoard":
						var _Str = _HoldObj.get("TypeStr")
						if _Str in ["bag_BrownieCake"]:
							return _DevObj.call_canStir(_ButID, _HoldObj, _Player)
					"CreamMachine":
						return _DevObj.call_In(_ButID, _HoldObj, _Player)
					"LiquidCon_Heat":
						if is_instance_valid(_DevObj.OnTableObj):
							if _DevObj.OnTableObj.SelfDev in ["MilkPot"]:
								return _DevObj.OnTableObj.call_Pot_In(_ButID, _HoldObj, _Player)
					"MilkPot":
						return _DevObj.call_Sugar_In(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"BobaMachine":
						return _DevObj.call_Cooker_In(_ButID, _HoldObj, _Player)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)

			"BobaMachine":
				match _DevType:
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_BobaMachine_DropTrash(_ButID, _Player, _HoldObj)
					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_PutInBox(_ButID, _HoldObj, _Player)

			"TeaBarrel":
				match _DevType:
					"TeaBarrel":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"Con_Liquid":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"IceMachine":
						return _DevObj.call_Barrel_AddIce(_ButID, _HoldObj, _Player)
					"Water_Normal":
						return _DevObj.call_WaterDrop(_ButID, _HoldObj, _Player)

					"TeaBarrelShelf":
						return _DevObj.call_PutOn(_ButID, _Player)
			"TeaBag":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"BigPot":
						return _DevObj.call_Pot_In(_ButID, _HoldObj, _Player)

					"GramScale":
						return _DevObj.call_Put(_ButID, _HoldObj, _Player)
					"LiquidCon_Heat":
						if is_instance_valid(_DevObj.OnTableObj):
							if _DevObj.OnTableObj.SelfDev in ["BigPot", "MilkPot"]:
								return _DevObj.OnTableObj.call_Pot_In(_ButID, _HoldObj, _Player)
			"MilkPot":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Trashbin":
						if _HoldObj.HasContent or _HoldObj.HasMilk:
							if _ButID == 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
								_Player.call_Say_IntoSink()
								return
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Con_Liquid":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"Water_Normal":

						return _HoldObj.call_Water_In(_ButID, _DevObj, _Player)
					"Bottle":
						return _HoldObj.call_Milk_In(_ButID, _DevObj, _Player)
					"Pot":
						return _HoldObj.call_Pot_In(_ButID, _DevObj, _Player)
					"LiquidCon_Heat":
						return _DevObj.call_DevLogic_PutLiquidCon_On_Cooker(_ButID, _Player)
			"BigPot":
				match _DevType:
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Con_Liquid":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"TeaBag":
						return _HoldObj.call_Pot_In(_ButID, _DevObj, _Player)
					"TeaBarrel":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_PutInBox(_ButID, _HoldObj, _Player)
					"Trashbin":
						return _DevObj.call_BigPot_Trash(_ButID, _Player, _HoldObj)
					"LiquidCon_Heat":

						return _DevObj.call_DevLogic_PutLiquidCon_On_Cooker(_ButID, _Player)
					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)

			"Pot":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"WorkBoard":
						return _DevObj.call_canStir(_ButID, _HoldObj, _Player)
					"MilkPot":
						return _DevObj.call_Pot_In(_ButID, _HoldObj, _Player)

					"LiquidCon_Heat":
						if is_instance_valid(_DevObj.OnTableObj):
							if _DevObj.OnTableObj.SelfDev in ["BigPot", "MilkPot"]:
								return _DevObj.OnTableObj.call_Pot_In(_ButID, _HoldObj, _Player)

					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)

					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"SnowShovel":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
			"Mop":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"MopPool":
						return _DevObj.call_pick(_ButID, _Player)
			"FruitTrash":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
			"Top", "Hang":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"DrinkCup", "EggRollCup", "BeerCup":
						return _HoldObj.call_WaterInDrinkCup(_ButID, _DevObj, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true

					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
			"WorkBoard":
				match _DevType:
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"LiquidCon_Heat":
						if is_instance_valid(_DevObj.OnTableObj):
							if _DevObj.OnTableObj.SelfDev in ["BigPot", "MilkPot"]:
								return _DevObj.OnTableObj.call_Pot_In(_ButID, _HoldObj, _Player)
					"MaterialBox", "MaterialBig":
						if not _HoldObj.IsPassDay:
							return _DevObj.call_PutInBox(_ButID, _HoldObj, _Player)
						else:
							return
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Trashbin":
						return _DevObj.call_WorkBoard_Trash(_ButID, _Player, _HoldObj)
			"Box":
				match _DevType:
					"FruitShelf":
						return _DevObj.call_Fruit_PutOn(_ButID, _Player, _HoldObj)
					"MaterialBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					"Trashbin":
						if _HoldObj.IsTrash:
							return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
			"IceCreamBox":
				match _DevType:
					"Water_Normal":
						return _DevObj.call_WaterDrop(_ButID, _HoldObj, _Player)
					"Trashbin":
						return _DevObj.call_Say_InWaterTank(_ButID, _Player, _HoldObj)
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"IceCreamMachine":
						return _DevObj.call_put(_ButID, _HoldObj, _Player)
			"MaterialBox", "MaterialBig":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_PutInBox(_ButID, _HoldObj, _Player)
					"FruitCore":
						return _DevObj.call_Fruit_Out(_ButID, _HoldObj, _Player)
					"ChopMachine":
						return _DevObj.call_put(_ButID, _HoldObj, _Player)
					"DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup":
						return _HoldObj.call_put_in_cup(_ButID, _Player, _DevObj)
					"Can":
						return _HoldObj.call_PutInBox(_ButID, _DevObj, _Player)
					"BigPot", "BobaMachine":
						return _HoldObj.call_PutInBox(_ButID, _DevObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put(_ButID, _HoldObj, _Player)
					"WorkBoard":

						return _HoldObj.call_PutInBox(_ButID, _DevObj, _Player)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"FruitCore":
				match _DevType:
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_PutInBox(_ButID, _HoldObj, _Player)
			"Fruit":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Shelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"FruitShelf":
						return _DevObj.call_Fruit_PutOn(_ButID, _Player, _HoldObj)
					"BigPot":
						return _DevObj.call_Fruit_In(_ButID, _Player, _HoldObj)
					"ChopMachine":
						return _DevObj.call_Fruit_In(_ButID, _Player, _HoldObj)
					"FruitCore":
						return _DevObj.call_Fruit_In(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"JuiceMachine":
						return _DevObj.call_Fruit_In(_ButID, _HoldObj, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"WorkBoard":
						return _DevObj.call_canStir(_ButID, _HoldObj, _Player)
					"DrinkCup", "SodaCan", "SuperCup", "BeerCup":
						return _HoldObj.call_WaterInDrinkCup(_ButID, _DevObj, _Player)
					"ShakeCup":
						return _HoldObj.call_WaterInDrinkCup(_ButID, _DevObj, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
			"CoffeeBean":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)

					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return
					"CoffeeMachine":
						return _DevObj.call_addCoffeeBean(_ButID, _HoldObj, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
			"GasBottle":
				match _DevType:
					"BeerMachine":
						return _DevObj.call_PutOn(_ButID, _Player)
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)

					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)

					"GasBox":
						return _DevObj.call_PutOn(_ButID, _Player)
					"PopMachine", "PopWaterMachine":
						return _DevObj.call_PutOn(_ButID, _Player)
			"PopCap":
				match _DevType:
					"PopMachine":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
			"Pop":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"BigPot":
						return _DevObj.call_Defrost(_ButID, _HoldObj, _Player)
					"PopCap":
						return _DevObj.call_Liquid_In(_ButID, _HoldObj, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					_:
						return
			"EggRollCup":
				match _DevType:
					"EggRollMachine":
						return _DevObj.call_EggRollCup(_ButID, _HoldObj, _Player)
					"IceCreamMachine":
						return _DevObj.call_DrinkCup(_ButID, _HoldObj, _Player)
					"EggRollCup":
						return _DevObj.call_ChangeID(_ButID, _HoldObj, _Player)
					"TicketMachine":
						return _DevObj.call_Ticket(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Shelf_OnTable", "TeaBarrelShelf":
						return _DevObj.call_DrinkCup_Logic(_ButID, _Player)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Can":
						return _DevObj.call_add_extra(_ButID, _Player, _HoldObj)
					"SugarMachine":
						if not _HoldObj.SugarType:
							return _DevObj.call_sugar_in_cup(_ButID, _HoldObj, _Player)
					"WorkBoard":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
			"EggRoll":
				match _DevType:
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"EggRollPot":
						return _DevObj.call_Content_In(_ButID, _HoldObj, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Can":
						return _DevObj.call_add_extra(_ButID, _Player, _HoldObj)
					"SugarMachine":
						if not _HoldObj.SugarType:
							return _DevObj.call_sugar_in_cup(_ButID, _HoldObj, _Player)
			"EggRollPot":
				match _DevType:
					"EggRollMachine":
						return _DevObj.call_EggRoll_In(_ButID, _HoldObj, _Player)
					"Water_Normal":
						return _HoldObj.call_Water_In(_ButID, _DevObj, _Player)
			"Bottle":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"CreamMachine":
						return _DevObj.call_In(_ButID, _HoldObj, _Player)
					"IceCreamBox":
						return _DevObj.call_InBox(_ButID, _HoldObj, _Player)
					"BigPot":
						return _DevObj.call_Defrost(_ButID, _HoldObj, _Player)

					"MilkPot":
						return _DevObj.call_Milk_In(_ButID, _HoldObj, _Player)
					"LiquidCon_Heat":
						if is_instance_valid(_DevObj.OnTableObj):
							if _DevObj.OnTableObj.SelfDev in ["MilkPot"]:
								return _DevObj.OnTableObj.call_Milk_In(_ButID, _HoldObj, _Player)
					"CoffeeMachine":
						return _DevObj.call_Milk_Put(_ButID, _HoldObj, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"DrinkCup", "SodaCan", "SuperCup", "BeerCup":
						return _HoldObj.call_WaterInDrinkCup(_ButID, _DevObj, _Player)
					"ShakeCup":
						return _HoldObj.call_WaterInDrinkCup(_ButID, _DevObj, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)

					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)

					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"Can":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_PutInBox(_ButID, _HoldObj, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup":
						if _ButID == - 1:
							_DevObj.But_Switch(true, _Player)
						return _HoldObj.call_add_extra(_ButID, _Player, _DevObj)

					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)

					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)

					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return

			"Sugar", "Choco", "FreeSugar":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"SugarMachine":

						return _DevObj.call_addsugar(_ButID, _HoldObj, _Player)
					"Shelf", "Freezer":

						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":

						return _DevObj.call_PutOn(_ButID, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"DrinkCup_Group":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Box":

						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"CupHolder":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"SuperCup":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Shelf":
						return _DevObj.call_PutOn(_ButID, _Player)
					"TicketMachine":
						return _DevObj.call_Ticket(_ButID, _HoldObj, _Player)
					"FruitShelf":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"FruitCore":
						return _DevObj.call_Fruit_In_Cup(_ButID, _HoldObj, _Player)
					"ChopMachine":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"SmashTable":
						return _DevObj.call_Smash(_ButID, _HoldObj, _Player)

					"PopMachine", "PopWaterMachine":
						return _DevObj.call_In_Cup(_ButID, _HoldObj, _Player)
					"JuiceMachine":
						return _DevObj.return_Juice_In_Cup(_ButID, _HoldObj, _Player)
					"CoffeeMachine":
						return _DevObj.call_drinkcup_logic(_ButID, _HoldObj, _Player)
					"DrinkCup", "SuperCup", "SodaCan", "BeerCup":
						return _DevObj.call_ChangeID(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Box":
						return _DevObj.call_PickFruitInCup(_ButID, _HoldObj, _Player)
					"Fruit":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)
					"Shelf_OnTable", "TeaBarrelShelf":
						return _DevObj.call_DrinkCup_Logic(_ButID, _Player)
					"ShakeCup":
						return _HoldObj.call_ShakeCup_In_DrinkCup(_ButID, _Player, _DevObj)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Can":
						return _DevObj.call_add_extra(_ButID, _Player, _HoldObj)
					"Bottle", "Top", "Hang":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)
					"IceMachine":
						return _DevObj.call_AddIce(_ButID, _HoldObj, _Player)

					"HotWaterMachine":
						return _DevObj.call_AddHotWater(_ButID, _HoldObj, _Player)

					"SugarMachine":
						if not _HoldObj.SugarType:
							return _DevObj.call_sugar_in_cup(_ButID, _HoldObj, _Player)
					"WorkBoard":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
					"Con_Liquid", "TeaBarrel":

						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)

						pass
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"SodaCan":
				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"IceMachine":
						return _DevObj.call_AddIce(_ButID, _HoldObj, _Player)
					"Shelf":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"TicketMachine":
						return _DevObj.call_Ticket(_ButID, _HoldObj, _Player)
					"SodaPack":
						return _DevObj.call_SodaCan_Pack(_ButID, _HoldObj, _Player)
					"PopMachine", "PopWaterMachine":
						return _DevObj.call_In_Cup(_ButID, _HoldObj, _Player)
					"JuiceMachine":
						return _DevObj.return_Juice_In_Cup(_ButID, _HoldObj, _Player)
					"CoffeeMachine":
						return _DevObj.call_drinkcup_logic(_ButID, _HoldObj, _Player)
					"SodaCan", "SuperCup":
						return _DevObj.call_ChangeID(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Box":
						return _DevObj.call_PickFruitInCup(_ButID, _HoldObj, _Player)
					"Fruit":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)
					"Shelf_OnTable", "TeaBarrelShelf":
						return _DevObj.call_DrinkCup_Logic(_ButID, _Player)
					"ShakeCup":
						return _HoldObj.call_ShakeCup_In_DrinkCup(_ButID, _Player, _DevObj)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Can":
						return _DevObj.call_add_extra(_ButID, _Player, _HoldObj)
					"Bottle":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)

					"SugarMachine":
						if not _HoldObj.SugarType:
							return _DevObj.call_sugar_in_cup(_ButID, _HoldObj, _Player)
					"WorkBoard":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
					"Con_Liquid", "TeaBarrel":

						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"BreakMachine":
				match _DevType:
					"Trashbin":
						return _DevObj.call_BreakMachine_DropTrash(_ButID, _Player, _HoldObj)
					"Water_Normal":
						if _HoldObj.WaterType:
							return _DevObj.call_WaterDrop(_ButID, _HoldObj, _Player)
			"Plate":
				match _DevType:
					"Order":
						if _ButID == 0:
							if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
								_Player.call_Say_NeedEmptyHand()
						return
					"DrinkCup":
						return _HoldObj.call_Cup_Touch(_ButID, _DevObj, _Player)
					"Shelf_GlassCup":
						return _DevObj.call_PlatePutOn(_ButID, _Player)
					"CleanMachine":
						return _DevObj.call_Plate(_ButID, _Player)
			"DrinkCup", "BeerCup":

				match _DevType:
					"BeerMachine":
						return _DevObj.call_DrinkCup_Logic(_ButID, _Player)
					"Beer":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)
					"Plate":
						return _DevObj.call_PutOn(_ButID, _Player)
					"CleanMachine":
						return _DevObj.call_DrinkCup_Logic(_ButID, _Player)
					"Shelf_GlassCup":
						return _DevObj.call_PutOn(_ButID, _Player)
					"MixerMachine":
						return _DevObj.call_DrinkCup(_ButID, _HoldObj, _Player)
					"IceCreamMachine":
						return _DevObj.call_DrinkCup(_ButID, _HoldObj, _Player)
					"BreakMachine":
						return _DevObj.call_DrinkCup(_ButID, _Player, _HoldObj)
					"FruitShelf":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"FruitCore":
						return _DevObj.call_Fruit_In_Cup(_ButID, _HoldObj, _Player)
					"ChopMachine":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"SmashTable":
						return _DevObj.call_Smash(_ButID, _HoldObj, _Player)
					"PopMachine", "PopWaterMachine":
						return _DevObj.call_In_Cup(_ButID, _HoldObj, _Player)
					"JuiceMachine":
						return _DevObj.return_Juice_In_Cup(_ButID, _HoldObj, _Player)
					"CoffeeMachine":
						return _DevObj.call_drinkcup_logic(_ButID, _HoldObj, _Player)
					"DrinkCup", "BeerCup":
						return _DevObj.call_ChangeID(_ButID, _HoldObj, _Player)
					"TicketMachine":
						return _DevObj.call_Ticket(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Shelf_OnTable", "TeaBarrelShelf":
						return _DevObj.call_DrinkCup_Logic(_ButID, _Player)
					"FreezerBox", "FreezerBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"MaterialBox", "MaterialBig":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Can":
						return _DevObj.call_add_extra(_ButID, _Player, _HoldObj)
					"SugarMachine":
						if not _HoldObj.SugarType:
							return _DevObj.call_sugar_in_cup(_ButID, _HoldObj, _Player)
					"WorkBoard":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Box":
						return _DevObj.call_PickFruitInCup(_ButID, _HoldObj, _Player)
					"Fruit":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)
					"ShakeCup":
						return _HoldObj.call_ShakeCup_In_DrinkCup(_ButID, _Player, _DevObj)
					"Bottle", "Top", "Hang":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)
					"IceMachine":
						return _DevObj.call_AddIce(_ButID, _HoldObj, _Player)

					"HotWaterMachine":
						return _DevObj.call_AddHotWater(_ButID, _HoldObj, _Player)


					"Water_Normal":
						return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
					"Con_Liquid", "TeaBarrel":

						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)

					"CupHolder":


						return _DevObj.call_CupIn(_ButID, _HoldObj, _Player)

						pass
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return

			"TeaLeaf":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"GramScale":
						return _DevObj.call_AddLeaf(_ButID, _HoldObj, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)



					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"Powder":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"IceCreamBox":
						return _DevObj.call_InBox(_ButID, _HoldObj, _Player)
					"Box":
						return _DevObj.call_Fruit_PutIn(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Shelf", "Freezer":
						return _DevObj.call_PutOn(_ButID, _Player)
					"FruitShelf":
						if _ButID >= 0 and _Player.cur_Player in [SteamLogic.STEAM_ID, 1, 2]:
							_Player.call_Say_NoUse()
							return true
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Con_TeaPort":

						return _DevObj.call_TeaInTeaPort(_ButID, _HoldObj, _Player)
					"LiquidCon_Heat":

						var _SavedObj = _DevObj.OnTableObj
						if is_instance_valid(_SavedObj):
							if _SavedObj.FuncType == "Con_TeaPort":

								return _SavedObj.call_TeaInTeaPort(_ButID, _HoldObj, _Player)
						else:
							return
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)

					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"Trashbag":
				match _DevType:
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"Con_TeaPort":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"WorkBoard":
						return _DevObj.call_canStir(_ButID, _HoldObj, _Player)
					"Powder":
						return _HoldObj.call_TeaInTeaPort(_ButID, _DevObj, _Player)
					"TeaLeaf":
						return _HoldObj.call_TeaInTeaPort(_ButID, _DevObj, _Player)
					"LiquidCon_Heat":
						return _DevObj.call_DevLogic_PutLiquidCon_On_Cooker(_ButID, _Player)
					"Water_Normal":

						if not _HoldObj.HasWater:
							if _HoldObj.TeaType != "tealeaf_waste":

								return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
						if _HoldObj.HasWater:

							return _DevObj.call_WaterDrop(_ButID, _HoldObj, _Player)
						if _ButID == 3:
							return 0
					"Con_TeaPort":

						if _ButID == 3:

							return
						if not _HoldObj.HasWater:
							if _HoldObj.TeaType != "tealeaf_waste":
								if _DevObj.CanWaterOut:
									if _DevObj.WaterType == "water":
										return _HoldObj.call_WaterInTeaPort(_ButID, _DevObj, _Player)
						elif _HoldObj.CanWaterOut:
							if _HoldObj.WaterType == "water":
								if not _DevObj.HasWater:
									return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"Con_Liquid":

						if _ButID == 3:
							return
						if _HoldObj.HasWater and _HoldObj.CanWaterOut:

							var _return = _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
							_HoldObj.But_Switch(false, _Player)
							return _return
					"Trashbin":
						var _CanDrop: bool
						if _HoldObj.HasContent:
							_CanDrop = true
						if _HoldObj.HasWater:
							_CanDrop = false
						if _CanDrop and _ButID <= 0:

							_DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
						if _ButID == 3:
							return 0
					"IceMachine", "HotWaterMachine":
						if _DevObj.has_method("But_Switch"):
							match _ButID:
								- 1:
									_DevObj.But_Switch(true, _Player)
								- 2:
									_DevObj.But_Switch(false, _Player)
								3:
									_DevObj.call_MachineControl(_ButID, _Player)
						return 0
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					_:
						return
			"ShakeCup":
				match _DevType:

					"Box":
						return _DevObj.call_PickFruitInCup(_ButID, _HoldObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					"DrinkCup", "SodaCan", "SuperCup", "BeerCup":

						return _DevObj.call_ShakeCup_In_DrinkCup(_ButID, _Player, _HoldObj)
					"FreezerBox":

						return
					"MaterialBox":

						return

					"Bottle":
						return _DevObj.call_WaterInDrinkCup(_ButID, _HoldObj, _Player)

					"IceMachine":
						return _DevObj.call_AddIce(_ButID, _HoldObj, _Player)
					"HotWaterMachine":
						return _DevObj.call_AddHotWater(_ButID, _HoldObj, _Player)
					"SugarMachine":
						if not _HoldObj.SugarType:
							return _DevObj.call_sugar_in_cup(_ButID, _HoldObj, _Player)
					"WorkBoard":
						return _DevObj.call_put_in_cup(_ButID, _Player, _HoldObj)

					"Trashbin":
						return _DevObj.call_DevLogic_DropTrash(_ButID, _Player, _HoldObj, _DevObj)
					"Shelf_OnTable":
						return _DevObj.call_ShakeCup_Logic(_ButID, _Player)

					"Water_Normal":

						if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
							return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)

						if _HoldObj.Liquid_Count > 0:
							return _DevObj.call_WaterDrop(_ButID, _HoldObj, _Player)
					"Con_Liquid":
						if _DevObj.HasWater:
							if _HoldObj.Liquid_Count > 0:
								_HoldObj.call_out_switch(true)
							if _HoldObj.Liquid_Count < _HoldObj.Liquid_Max:
								_HoldObj.call_Water_In(_ButID, _DevObj)

								if _DevObj.has_method("But_Switch"):
									_DevObj.But_Switch(true, _Player)
								if _HoldObj.Liquid_Count == _HoldObj.Liquid_Max:

									if _DevObj.has_method("But_Switch"):
										_DevObj.But_Switch(true, _Player)
										return 0
			"Con_Liquid":

				match _DevType:
					"BreakMachine":
						return _DevObj.call_Turn(_ButID, _Player, _HoldObj)
					"CreamMachine":
						return _DevObj.call_Out(_ButID, _HoldObj, _Player)

					"TeaBarrel":
						return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
					"LiquidCon_Heat":
						if is_instance_valid(_DevObj.OnTableObj):
							if _DevObj.OnTableObj.SelfDev in ["MilkPot"]:
								return _HoldObj.call_WaterInTeaPort(_ButID, _DevObj.OnTableObj, _Player)

					"JuiceMachine":
						return _DevObj.return_JuiceInPot(_ButID, _HoldObj, _Player)
					"MilkPot":
						return _HoldObj.call_WaterInTeaPort(_ButID, _DevObj, _Player)
					"Order":
						return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)
					"IceMachine", "HotWaterMachine":
						return _DevObj.call_MachineControl(_ButID, _Player)
					"Table", "PickUp":
						return DevLogic_Put(_ButID, _Player, _DevObj)
					"Shelf_OnTable":
						return _DevObj.call_PutOn(_ButID, _Player)
					"ShakeCup":

						if _HoldObj.HasWater:
							_DevObj.call_CupInfo_Switch(_ButID)
							return _DevObj.call_Water_In(_ButID, _HoldObj)
					"DrinkCup", "SodaCan", "SuperCup", "BeerCup":

						if _HoldObj.HasWater:
							_DevObj.call_CupInfo_Switch(_ButID)
							return _HoldObj.call_WaterInDrinkCup(_ButID, _DevObj, _Player)
					"Water_Normal":

						if not _HoldObj.Liquid_Count:
							return _DevObj.call_WaterInPort(_ButID, _HoldObj, _Player)
						else:
							return _DevObj.call_WaterDrop(_ButID, _HoldObj, _Player)
					"Con_TeaPort":
						if _DevObj.HasWater and _DevObj.CanWaterOut:

							var _return = _HoldObj.call_WaterInTeaPort(_ButID, _DevObj, _Player)
							_DevObj.But_Switch(false, _Player)
							return _return

					"Con_Liquid":
						if _HoldObj.HasWater:
							if not _DevObj.HasWater:
								return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
							elif _DevObj.HasWater:

								return _DevObj.call_WaterInTeaPort(_ButID, _HoldObj, _Player)
						elif _DevObj.HasWater:

							return _HoldObj.call_WaterInTeaPort(_ButID, _DevObj, _Player)
					_:
						return
			_:
				return
	else:
		if not _DevObj.get("FuncType"):
			return
		var _DevType = _DevObj.FuncType

		if _DevObj.CanMove:
			match _ButID:
				- 2:

					if _DevObj.has_method("But_Switch"):
						_DevObj.But_Switch(false, _Player)
				- 1:

					if _DevObj.has_method("But_Switch"):
						_DevObj.But_Switch(true, _Player)
				0:

					_DevObj.call_pickup_by(_Player, _DevObj)

					return "捡"
				1:

					match _DevType:
						"CoffeeMachine":
							return _DevObj.call_MachineControl(_ButID, _Player)
				2:

					match _DevType:
						"Beer":
							return _DevObj.call_Use(_ButID, _Player)
						"Plate":
							return _DevObj.call_pick(_ButID, _Player)
						"BreakMachine", "CreamMachine":
							return _DevObj.call_MachineControl(_ButID, _Player)
						"FruitCore":
							return _DevObj.call_Use(_ButID, _Player)
						"TicketMachine":
							return _DevObj.call_DevLogic(_ButID, _Player, _DevObj)
						"BigPot":
							return _DevObj.call_Defrost(_ButID, _DevObj, _Player)
						"JuiceMachine":
							return _DevObj.call_DevLogic_Trashbin(_ButID, _Player, _DevObj)
						"CoffeeMachine":
							return _DevObj.call_MachineControl(_ButID, _Player)
						"CupHolder":
							return _DevObj.call_DevLogic(_ButID, _Player, _DevObj)
						"Box":

							if not _DevObj.IsOpen:
								return _DevObj.call_OpenBox()
							else:
								return _DevObj.call_PickItem(_Player)
						"BoxWood":

							return _DevObj.call_But_Logic(_ButID, _Player)
				3:
					match _DevType:
						"CreamMachine", "BreakMachine", "MixerMachine", "EggRollMachine":
							return _DevObj.call_MachineControl(_ButID, _Player)
						"TicketMachine":
							return _DevObj.call_DevLogic(_ButID, _Player, _DevObj)
						"GramScale":
							return _DevObj.return_Make_TeaBag(_ButID, _Player)
						"WorkBoard":
							return _DevObj.call_pick(_ButID, _Player)
						"IceMachine", "HotWaterMachine", "CoffeeMachine", "SugarMachine", "BobaMachine", "PopWaterMachine", "PopMachine", "JuiceMachine", "ChopMachine":
							return _DevObj.call_MachineControl(_ButID, _Player)

						"BoxWood":

							return _DevObj.call_But_Logic(_ButID, _Player)
		else:

			match _DevType:
				"BreakMachine", "EggRollMachine":
					return _DevObj.call_MachineControl(_ButID, _Player)
				"CreamMachine":
					return _DevObj.call_MachineControl(_ButID, _Player)
				"ChopMachine":
					if is_instance_valid(_DevObj._BOX):
						return _DevObj.call_pick(_ButID, _Player)
					else:
						return _DevObj.call_MachineControl(_ButID, _Player)
				"FruitCore":
					return _DevObj.call_Use(_ButID, _Player)
				"SodaPack", "Shelf_Beer":
					return _DevObj.call_pick(_ButID, _Player)
				"GramScale":
					return _DevObj.return_Make_TeaBag(_ButID, _Player)
				"MopPool":
					return _DevObj.call_pick(_ButID, _Player)
				"FreezerBox", "FreezerBig", "IceCreamMachine":
					return _DevObj.call_take(_ButID, _Player)

				"IceMachine", "HotWaterMachine", "CoffeeMachine", "Water_Normal", "SmashTable", "JuiceMachine":
					return _DevObj.call_MachineControl(_ButID, _Player)

				"Shelf", "Freezer", "FruitShelf", "Shelf_GlassCup", "CleanMachine", "BeerMachine":
					return _DevObj.call_pick(_ButID, _Player)

				"Shelf_OnTable", "TeaBarrelShelf", "PopMachine", "GasBox", "PopWaterMachine":
					return _DevObj.call_pick(_ButID, _Player)

				"WorkBoard":
					return _DevObj.call_pick(_ButID, _Player)

				"Order":

					return _DevObj.call_DevLogic_OrderTab(_ButID, _Player)

				"Trashbin", "JuiceMachine":

					if _DevObj.Trash_Count > 0:
						_DevObj.But_Switch(true, _Player)
						return _DevObj.call_DevLogic_Trashbin(_ButID, _Player, _DevObj)
					else:
						_DevObj.But_Switch(false, _Player)
				"Table", "PickUp":

					if _DevObj.OnTableObj:
						var _Obj = _DevObj.OnTableObj

						if is_instance_valid(_Obj):
							if _Obj.CanMove:
								return DevLogic_Pick(_ButID, _Player, _DevObj)
					else:
						return
				"LiquidCon_Heat":
					return _DevObj.call_DevLogic_Pick(_ButID, _Player)

				"CupHolder":
					return _DevObj.call_DevLogic(_ButID, _Player, _DevObj)

func call_Player_Pick_puppet(_PLAYERPATH, _NODEID: int):
	if not SteamLogic.OBJECT_DIC.has(_NODEID):
		printerr(" DeviceLogic OBJECT_DIC 无：", _NODEID)
		return
	var _Player = get_node(_PLAYERPATH)
	var _Dev = SteamLogic.OBJECT_DIC[_NODEID]
	call_Pick_Logic(_Player, _Dev)
func call_Player_Pick(_Player, _DevTouchNode):
	printerr(" 拾取1：", _DevTouchNode.TypeStr)
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	var _Dev = null
	if _DevTouchNode.get("TypeStr"):
		if not _DevTouchNode.TypeStr in ["WorkBench_Immovable", "WorkBench"]:
			_Dev = _DevTouchNode
		if _DevTouchNode.TypeStr in ["MopPool"]:
			_Dev = _DevTouchNode.OnTableObj
			_DevTouchNode.HasMop = false
	if _DevTouchNode.has_method("call_ThrowObj"):
		return
	var _DevObj = _DevTouchNode.OnTableObj
	if is_instance_valid(_DevObj) and not is_instance_valid(_Dev):

		if _DevObj.CanMove:
			_Dev = _DevObj
			_DevTouchNode.OnTableObj = null
		else:
			if _DevObj.get("SelfDev") in ["InductionCooker"]:
				if is_instance_valid(_DevObj.OnTableObj):
					_Dev = _DevObj.OnTableObj


				pass
		pass
	elif not is_instance_valid(_Dev):
		_Dev = _DevTouchNode


		pass
	if not is_instance_valid(_Dev):
		return
	elif _Dev.TypeStr in ["WorkBench_Immovable", "WorkBench"]:
		return
	else:
		if _Dev.TypeStr == "MilkPot":
			if _Dev.IsMixing:
				return

		var _Parent = _Dev.get_parent()
		if not is_instance_valid(_Parent):
			return
		if _Parent.name in ["A", "B", "X", "Y"]:
			if _Parent.get_parent().name in ["BoxNode"]:
				var _OBJ = _Parent.get_parent().get_parent().get_parent()
				match _Parent.name:
					"A":
						_OBJ.A_Box = null
					"B":
						_OBJ.B_Box = null
					"X":
						_OBJ.X_Box = null
					"Y":
						_OBJ.Y_Box = null
				_Dev.call_InFreezerBox(false)
				_OBJ._But_Show(_Player)
				_OBJ.UseAni.play("Use")
				_OBJ.call_turn_check()
		elif _Parent.name in ["ObjNode"]:
			if _Parent.get_parent().get("TypeStr"):
				if _Parent.get_parent().TypeStr in ["WorkBench_Immovable", "WorkBench"]:
					_Parent.get_parent().OnTableObj = null
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_Player_Pick_puppet", [_PLAYERPATH, int(_Dev.name)])

	call_Pick_Logic(_Player, _Dev)
	return "捡"
func _PickLogic(_Player, _Dev):
	var _PARENT = _Dev.get_parent()
	if not is_instance_valid(_PARENT):
		return
	if _PARENT.name in ["ObjNode"]:
		var _BENCH = _PARENT.get_parent()
		if _BENCH.has_method("call_del"):
			_BENCH.OnTableObj = null
	elif _PARENT.name in ["SavedNode"]:
		var _OBJ = _PARENT.get_parent()
		if _OBJ.get("SelfDev") in ["InductionCooker"]:
			if _Dev.WaterCelcius >= 100:
				_Dev.WaterCelcius = 99
				_OBJ.Audio_100.stop()
				_Dev.call_WaterCelcius_change()
			_OBJ.OnTableObj = null
			_OBJ._CanMove_Check()
			if _Dev.has_method("call_ColdTimer"):
				_Dev.call_ColdTimer()
			_OBJ.CookerAni.play("close")
			_OBJ.But_Switch(true, _Player)
			_OBJ.set_process(false)
	elif _PARENT.name in ["MilkNode"]:
		var _MACHINE = _PARENT.get_parent().get_parent()
		_MACHINE.MilkOBJ = null
		_MACHINE.HasMilk = false
	elif _PARENT.name in ["DrinkCupNode"]:
		var _MACHINE = _PARENT.get_parent().get_parent()
		_MACHINE.CupOBJ = null
		_MACHINE.HasCup = false
		_MACHINE.call_CHOOSE_RESET()
	elif _PARENT.name in ["1", "2", "3", "4"]:
		if _PARENT.get_parent().name in ["ItemNode"]:
			if _PARENT.get_parent().name in ["ItemNode"]:
				var _OBJ = _PARENT.get_parent().get_parent().get_parent()
				if _OBJ.has_method("call_PickEnd_Logic"):
					if _OBJ.CurTeaBagList.has(_Dev):
						_OBJ.CurTeaBagList.erase(_Dev)
					_OBJ.call_PickEnd_Logic(_Player)

func call_Pick_Logic(_Player, _Dev):
	_PickLogic(_Player, _Dev)
	printerr(" 拾取：", _Dev.TypeStr)

	if _Dev.is_inside_tree():
		_Dev.get_parent().remove_child(_Dev)
	if _Dev.has_method("_TrashItem"):
		_Dev._TrashItem()

	_Pick_Logic(_Player, _Dev)
func _Pick_Logic(_Player, _Dev):
	print("PickLogic")
	PickAudio.play(0)
	_Dev.position = Vector2.ZERO
	_Player.WeaponNode.add_child(_Dev)
	_Player.Con.IsHold = true
	_Player.Con.HoldInsId = _Dev.get_instance_id()
	_Player.Con.HoldObj = _Dev
	_Dev.Holding = true
	_Dev.Holder = _Player
	_Player.Stat.call_carry_on(_Dev.CarrySpeed)
	var _Type = _Dev.TypeStr

	match _Type:

		"SnowShovel":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Dev.call_X_Switch(true)

		"Mop":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Dev.call_X_Switch(true)
		"CoffeeMachine":
			_Dev._PLAYERLIST.clear()
		"MaterialBox", "MaterialBig":
			if _Player.cur_Player == SteamLogic.STEAM_ID:
				if is_instance_valid(_Player.cur_RayObj):
					if _Player.cur_RayObj.get("SelfDev") in ["FreezerBox", "FreezerBig"]:
						_Player.cur_RayObj.call_put( - 1, _Dev, _Player)
		"can_coco":
			_Dev.But_Switch(true, _Player)
		"DrinkCup_S", "DrinkCup_M", "DrinkCup_L":
			_Dev.call_touch(_Player)

		"柠檬", "橙子", "芋头":
			_Dev.position = Vector2(0, - 20)
		_:
			_Dev.position = Vector2.ZERO

	if _Dev.FuncType in ["DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup"]:

		if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
			GameLogic.Order.call_pickup_cup_logic(_Dev.cur_ID, _Player.cur_Player)
			_Dev.call_CupInfo_Switch(true)

		GameLogic.Order.call_OutLine(_Dev.cur_ID, _Player.cur_Player)
		_Dev.call_PlayerOutLine(_Player.cur_Player)
	if _Dev.NeedPush:
		_Player.Con.NeedPush = true
	else:
		_Player.Con.NeedPush = false
	if _Dev.get("WaterCelcius"):
		if _Dev.WaterCelcius >= 100:
			_Dev.WaterCelcius = 99

	var _FUNCTYPE = _Dev.FuncType

	match _Dev.FuncType:
		"Con_TeaPort", "Con_Liquid", "DrinkCup_Group":
			_Dev.call_Info_Switch(true)
		"BobaMachine":
			_Dev.call_Wait()

		"Box":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if _Dev.IsTrash:
					GameLogic.Tutorial.call_DropInTrashbin(true)
		"Bottle", "Hang", "Top", "Pop":
			_Dev.call_Info_Switch(true)
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if _Dev.Freshless_bool or _Dev.Liquid_Count == 0:
					GameLogic.Tutorial.call_DropInTrashbin(true)
		"DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup":

			if _Dev.has_method("call_reset_pickup"):
				_Dev.call_reset_pickup()
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if _Dev.IsPassDay:
					GameLogic.Tutorial.call_DropInTrashbin(true)
		"Can":
			_Dev.call_Info_Switch(true)
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if not _Dev.Num:
					GameLogic.Tutorial.call_DropInTrashbin(true)
		"Box":

			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if not _Dev.has_method("call_create"):
					if _Dev.Used:
						GameLogic.Tutorial.call_DropInTrashbin(true)
		"Sugar", "Choco":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				if _Dev.Used:
					GameLogic.Tutorial.call_DropInTrashbin(true)
		"Trashbag":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				GameLogic.Tutorial.call_DrapTrashbag(true)



	if _Dev.get("CanPick") == true:
		_Dev.CanPick = false
	if _Dev.has_method("call_Picked"):
		_Dev.call_Picked()
	if _Dev.has_method("call_OutLine"):
		_Dev.call_OutLine(false)
	_Player.call_StatChange()
	return "拿"

func call_Player_Pick_Old(_Player, _ObjNode: Node2D, _Dev, _DevTouchNode, _Array: Array = []):
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		SteamLogic.call_puppet_node_sync(self, "call_Player_Pick")
	for _NODE in _Array:
		_NODE = null
	_ObjNode.remove_child(_Dev)
	PickAudio.play(0)
	_Dev.position = Vector2.ZERO
	_Player.WeaponNode.add_child(_Dev)
	_Player.Con.IsHold = true
	_Player.Con.HoldInsId = _Dev.get_instance_id()
	_Dev.Holding = true
	_Dev.Holder = _Player
	_Player.Stat.call_carry_on(_Dev.CarrySpeed)
	var _Type = _Dev.TypeStr

	match _Type:
		"can_coco":
			_Dev.But_Switch(true, _Player)
		"DrinkCup_S", "DrinkCup_M", "DrinkCup_L":
			_Dev.call_touch(_Player)

		"柠檬", "橙子", "芋头":
			_Dev.position = Vector2(0, - 20)
		_:
			_Dev.position = Vector2.ZERO

	if _Dev.FuncType in ["DrinkCup", "SodaCan", "SuperCup", "BeerCup"]:

		if SteamLogic.IsMultiplay and _Player.cur_Player == SteamLogic.STEAM_ID:
			GameLogic.Order.call_pickup_cup_logic(_Dev.cur_ID, _Player.cur_Player)
		elif not SteamLogic.IsMultiplay:
			GameLogic.Order.call_pickup_cup_logic(_Dev.cur_ID, _Player.cur_Player)
		GameLogic.Order.call_OutLine(_Dev.cur_ID, _Player.cur_Player)
		_Dev.call_PlayerOutLine(_Player.cur_Player)

	if _Dev.NeedPush:
		_Player.Con.NeedPush = true
	else:
		_Player.Con.NeedPush = false
	if _Dev.get("WaterCelcius") >= 100:
		_Dev.WaterCelcius = 99



	if SteamLogic.IsMultiplay:
		if _Player.cur_Player != SteamLogic.STEAM_ID:
			return

	match _Dev.FuncType:
		"BobaMachine":
			_Dev.call_Wait()

		"Box":
			if _Dev.IsTrash:
				GameLogic.Tutorial.call_DropInTrashbin(true)
		"Bottle":

			if _Dev.Freshless_bool or _Dev.Liquid_Count == 0:
				GameLogic.Tutorial.call_DropInTrashbin(true)
		"DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup":
			if _DevTouchNode.has_method("call_reset_pickup"):
				_DevTouchNode.call_reset_pickup()
			if _Dev.IsPassDay:
				GameLogic.Tutorial.call_DropInTrashbin(true)
		"Can":
			if not _Dev.Num:
				GameLogic.Tutorial.call_DropInTrashbin(true)
		"Box":
			if not _Dev.has_method("call_create"):
				if _Dev.Used:
					GameLogic.Tutorial.call_DropInTrashbin(true)
		"Sugar", "Choco":
			if _Dev.Used:
				GameLogic.Tutorial.call_DropInTrashbin(true)
		"Trashbag":
			GameLogic.Tutorial.call_DrapTrashbag(true)
	if _Dev.has_method("But_Switch"):
		_Dev.But_Switch(false, _Player)
	if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
		call_TouchDev_Logic( - 1, _Player, _DevTouchNode)
	if _Dev.get("CanPick") == true:
		_Dev = false
	if _Dev.has_method("call_Picked"):
		_Dev.call_Picked()

func call_Pick_ObjNode(_DEVNODEPATH, _DEVPATH, _PLAYERPATH):

	var _DevTouchNode = get_node(_DEVNODEPATH)
	var _Dev = get_node(_DEVPATH)
	var _Player = get_node(_PLAYERPATH)
	if not is_instance_valid(_Dev):
		return
	var _OBJNODE = _DevTouchNode.get_node("ObjNode")
	call_Player_Pick(_Player, _DevTouchNode)

	_DevTouchNode.OnTableObj = null

	if _Dev.has_method("But_Switch"):
		_Dev.But_Switch(false, _Player)


	call_TouchDev_Logic( - 1, _Player, _DevTouchNode)

func DevLogic_Pick(_button, _Player, _DevTouchNode):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if _button == 0:
		return call_Player_Pick(_Player, _DevTouchNode)
	return

func DevLogic_Pick_Old(_button, _Player, _DevTouchNode):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	if _DevTouchNode.OnTableObj:
		if _Player.Con.IsHold:
			return
		var _Dev = _DevTouchNode.OnTableObj
		if _Dev.CanMove:
			if _button == 0:
				match _Dev.FuncType:
					"BobaMachine":
						_Dev.call_Wait()
					"DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup":
						if _DevTouchNode.has_method("call_reset_pickup"):
							_DevTouchNode.call_reset_pickup()
				_Player.Con.IsHold = true
				if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
					var _DEVNODEPATH = _DevTouchNode.get_path()
					var _PLAYERPATH = _Player.get_path()
					var _DEVPATH = _Dev.get_path()
					SteamLogic.call_puppet_node_sync(self, "call_Pick_ObjNode", [_DEVNODEPATH, _DEVPATH, _PLAYERPATH])

				_DevTouchNode.get_node("ObjNode").remove_child(_Dev)
				call_Player_Pick(_Player, _Dev)

				_DevTouchNode.OnTableObj = null
				if _Dev.has_method("But_Switch"):
					_Dev.But_Switch(false, _Player)
				call_TouchDev_Logic( - 1, _Player, _DevTouchNode)
				return "捡"
		elif _Dev.CanPick:
			_Player.Con.IsHold = true
			if _Dev.has_method("But_Switch"):
				_Dev.But_Switch(false, _Player)
			var _SavedObj = _Dev.SavedObj
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _DEVNODEPATH = _DevTouchNode.get_path()
				var _DEVPATH = _Dev.get_path()
				var _PLAYERPATH = _Player.get_path()
				var _SAVEOBJ = _SavedObj.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Pick_puppet", [_DEVNODEPATH, _DEVPATH, _SAVEOBJ, _PLAYERPATH])
			_Dev.SavedNode.remove_child(_SavedObj)
			_Dev.SavedObj = null
			_Dev.CanPick = false
			call_Player_Pick(_Player, _Dev)
			if _SavedObj.WaterCelcius >= 100:
				_SavedObj.WaterCelcius = 99
			_Dev.call_Picked()
			call_TouchDev_Logic( - 1, _Player, _DevTouchNode)
			return "？"
		else:
			return

func call_Put_puppet(_PlAYERPATH, _DEVPATH, _TOUCHPATH, _AUDIO):
	if not has_node(_DEVPATH):
		return
	if not has_node(_PlAYERPATH):
		return
	if not has_node(_TOUCHPATH):
		return
	var _Player = get_node(_PlAYERPATH)
	var _Dev = get_node(_DEVPATH)
	var _DevTouchNode = get_node(_TOUCHPATH)
	if not is_instance_valid(_Dev):
		return
	_Player.WeaponNode.remove_child(_Dev)
	var _Audio = GameLogic.Audio.return_Effect(_AUDIO)
	_Audio.play(0)

	_Dev.position = Vector2.ZERO
	_Player.Stat.call_carry_off()
	_DevTouchNode.get_node("ObjNode").add_child(_Dev)
	_DevTouchNode.OnTableObj = _Dev
	if _Dev.FuncType in ["DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup"]:
		GameLogic.Order.call_del_cup_logic(_Dev.cur_ID)
		GameLogic.Order.call_OutLine(_Dev.cur_ID, 0)
		_Dev.call_PlayerOutLine(0)
	match _Dev.FuncType:
		"Mop", "SnowShovel":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_Dev.call_X_Switch(false)

	_Dev.Holding = false
	_Dev.Holder = null
	_Player.Con.IsHold = false
	call_TouchDev_Logic( - 1, _Player, _DevTouchNode)
func DevLogic_Put(_button, _Player, _DevTouchNode):

	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _button != 0:
		return
	if not is_instance_valid(_DevTouchNode.OnTableObj):
		if GameLogic.Device.return_CanUse_bool(_Player):
			return
		var _Dev = instance_from_id(_Player.Con.HoldInsId)
		if not _Dev:
			if _Player.WeaponNode.get_child_count() > 0:
				var _NodeList = _Player.WeaponNode.get_children()
				_Dev = _NodeList[0]
				_Player.Con.HoldInsId = _Dev.get_instance_id()
			else:
				return
		if _DevTouchNode.has_node("ObjNode"):
			if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
				var _PlAYERPATH = _Player.get_path()
				var _DEVPATH = _Dev.get_path()
				var _TOUCHPATH = _DevTouchNode.get_path()
				SteamLogic.call_puppet_node_sync(self, "call_Put_puppet", [_PlAYERPATH, _DEVPATH, _TOUCHPATH, _Dev.AudioPut])
			_Player.WeaponNode.remove_child(_Dev)
			var _Audio = GameLogic.Audio.return_Effect(_Dev.AudioPut)
			_Audio.play(0)

			_Dev.position = Vector2.ZERO
			_Player.Stat.call_carry_off()
			_DevTouchNode.get_node("ObjNode").add_child(_Dev)
			_DevTouchNode.OnTableObj = _Dev
			match _Dev.FuncType:

				"Mop", "SnowShovel":
					if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
						_Dev.call_X_Switch(false)
				"BobaMachine":
					_Dev.call_Logic()
				"DrinkCup", "SodaCan", "SuperCup", "EggRollCup", "BeerCup":
					GameLogic.Order.call_OutLine(_Dev.cur_ID, 0)
					_Dev.call_PlayerOutLine(0)
					if SteamLogic.IsMultiplay and _Player.cur_Player == SteamLogic.STEAM_ID:
						GameLogic.Order.call_del_cup_logic(_Dev.cur_ID)
					elif not SteamLogic.IsMultiplay:
						GameLogic.Order.call_del_cup_logic(_Dev.cur_ID)

		else:
			print("DevLogic_Put havn't ObjNode")

		_Player.Stat.call_carry_off()
		_Dev.Holding = false
		_Dev.Holder = null
		call_TouchDev_Logic( - 1, _Player, _DevTouchNode)

func call_PutOnGround_puppet(_OBJPATH, _PLAYERPATH, _POS):
	var _ItemObj = get_node(_OBJPATH)
	if not is_instance_valid(_ItemObj):
		return
	var _Player = get_node(_PLAYERPATH)
	if not is_instance_valid(_Player):
		return
	_ItemObj.call_deferred("call_Collision_Switch", true)
	var ItemYSort = get_tree().get_root().get_node("Level/YSort/Items")
	_Player.WeaponNode.remove_child(_ItemObj)
	var _Audio = GameLogic.Audio.return_Effect(_ItemObj.AudioPut)
	_Audio.play(0)
	_ItemObj.position = _POS
	ItemYSort.call_deferred("add_child", _ItemObj)



	_Player.Stat.call_carry_off()
	_ItemObj.Holding = false
	_ItemObj.Holder = null
	if _ItemObj.has_method("But_Hold"):
		_ItemObj.But_Hold(_Player)
	match _ItemObj.FuncType:
		"Mop", "SnowShovel":
			if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
				_ItemObj.call_X_Switch(false)

func ItemLogic_PutOnGround(_button, _Player, _ItemObj):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if _ItemObj.CanGround:
		if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
			var _OBJPATH = _ItemObj.get_path()
			var _PLAYERPATH = _Player.get_path()
			SteamLogic.call_puppet_node_sync(self, "call_PutOnGround_puppet", [_OBJPATH, _PLAYERPATH, _Player.position])

		var ItemYSort = get_tree().get_root().get_node("Level/YSort/Items")
		_Player.WeaponNode.remove_child(_ItemObj)
		var _Audio = GameLogic.Audio.return_Effect(_ItemObj.AudioPut)
		_Audio.play(0)
		_ItemObj.position = _Player.position
		ItemYSort.add_child(_ItemObj)
		_ItemObj.call_Collision_Switch(true)

		_Player.Stat.call_carry_off()
		_ItemObj.Holding = false
		_ItemObj.Holder = null
		if _ItemObj.has_method("But_Hold"):
			_ItemObj.But_Hold(_Player)
		var _CHECK = _ItemObj.FuncType
		match _ItemObj.FuncType:
			"SodaCan", "SuperCup":
				_ItemObj.call_CupInfo_Switch(false)
			"Mop", "SnowShovel":
				if _Player.cur_Player in [1, 2, SteamLogic.STEAM_ID]:
					_ItemObj.call_X_Switch(false)

		return "放地上"

func Box_OnGround_puppet(_BOXPATH, _POS):
	var _BOXOBJ = get_node(_BOXPATH)
	_BOXOBJ.position = _POS
	get_tree().get_root().get_node("Level").Ysort_Items.call_deferred("add_child", _BOXOBJ)
	_BOXOBJ.call_deferred("call_Collision_set")
func Box_OnGround(_BOXOBJ, _POS):

	_BOXOBJ.get_parent().remove_child(_BOXOBJ)
	_BOXOBJ.position = _POS
	get_tree().get_root().get_node("Level").Ysort_Items.call_deferred("add_child", _BOXOBJ)
	_BOXOBJ.call_deferred("call_Collision_set")

func call_PutOnGround(_button, _Player, _ItemObj):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _OBJPATH = _ItemObj.get_path()
		var _PLAYERPATH = _Player.get_path()
		SteamLogic.call_puppet_node_sync(self, "call_PutOnGround_puppet", [_OBJPATH, _PLAYERPATH, _Player.position])
	_ItemObj.call_deferred("call_Collision_Switch", true)
	var ItemYSort = get_tree().get_root().get_node("Level/YSort/Items")
	_Player.WeaponNode.remove_child(_ItemObj)
	var _Audio = GameLogic.Audio.return_Effect(_ItemObj.AudioPut)
	_Audio.play(0)
	_ItemObj.position = _Player.position
	ItemYSort.call_deferred("add_child", _ItemObj)

	_Player.Stat.call_carry_off()
	_ItemObj.Holding = false
	_ItemObj.Holder = null

	return "放地上"

func _DevLogic_TeaInTeaPort(_ButReturnBool, _TeaObj, _PortObj):

	if not _PortObj.HasContent:
		if _ButReturnBool == - 1:
			return 0
		else:
			var _player = _TeaObj.Holder
			if _player == null:
				_player = _PortObj.Holder
				var _DevTouch = _TeaObj.get_parent().get_parent()
				_DevTouch.OnTableObj = null
			else:
				_player.Stat.call_carry_off()
			_TeaObj.queue_free()
			_PortObj.call_Content_In(_TeaObj.TypeStr, _TeaObj.FuncType)

func call_ObjTurnTrashbag_puppet(_OBJPATH, _TRASHNAME, _weight):
	var _Obj = get_node(_OBJPATH)
	var _Trashbag_TSCN = GameLogic.AutoLoad.Trashbag_TSCN.instance()
	_Trashbag_TSCN.name = _TRASHNAME
	var _parentNode = _Obj.get_parent()
	_parentNode.remove_child(_Obj)
	_Trashbag_TSCN.position = _Obj.position
	_parentNode.add_child(_Trashbag_TSCN)
	_Trashbag_TSCN.call_Trashbag_init(_weight, true)
	_Obj.queue_free()
func call_ObjTurnTrashbag(_Obj, _weight):
	if SteamLogic.IsMultiplay and not SteamLogic.LOBBY_IsMaster:
		return

	var _Trashbag_TSCN = GameLogic.AutoLoad.Trashbag_TSCN.instance()
	_Trashbag_TSCN.name = str(_Trashbag_TSCN.get_instance_id())
	if SteamLogic.IsMultiplay and SteamLogic.LOBBY_IsMaster:
		var _OBJPATH = _Obj.get_path()
		var _TRASHNAME = _Trashbag_TSCN.name
		SteamLogic.call_puppet_node_sync(self, "call_ObjTurnTrashbag_puppet", [_OBJPATH, _TRASHNAME, _weight])
	var _parentNode = _Obj.get_parent()
	_parentNode.remove_child(_Obj)
	_Trashbag_TSCN.position = _Obj.position
	_parentNode.add_child(_Trashbag_TSCN)
	_Trashbag_TSCN.call_Trashbag_init(_weight, true)
	_Obj.queue_free()

func return_CanUse_bool(_Player):
	if not _Player.has_method("_PlayerNode"):
		return false
	if _Player.Con.ArmState in [GameLogic.NPC.STATE.WORK,
	GameLogic.NPC.STATE.STIR,
	GameLogic.NPC.STATE.SHAKE,
	GameLogic.NPC.STATE.ORDER,
	GameLogic.NPC.STATE.SQUEEZE]:

		_Player.call_Say_Busy()
		return true
	else:
		return false
