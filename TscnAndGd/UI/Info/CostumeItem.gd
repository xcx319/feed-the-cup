extends Node2D

onready var ANI = $Ani

export var ID: int setget _ID_Set

onready var PartANI = $Part / PartAni
onready var RoleANI = $Role / RoleAni

func return_ID_Five(_ID: int):
	var _STRID = str(_ID)
	if _STRID.length() == 7:
		var _ID_Five = _STRID.right(2)
		return _ID_Five
	return _ID
func call_Part_init(_ID: int, _PARTNAME):
	if GameLogic.Config.CostumeConfig.has(str(_ID)):
		_ID_Set(_ID)
	else:
		call_Ani("init")
		call_PartAni(_PARTNAME)
		call_RoleAni("init")
func _ID_Set(_ID: int):
	if GameLogic.Config.CostumeConfig.has(str(_ID)):
		ID = _ID
		var _INFO = GameLogic.Config.CostumeConfig[str(_ID)]
		var _PART = _INFO.part
		var _ROLE = _INFO.role
		var _ANI = _INFO.ANI

		call_Ani(_ANI)
		call_PartAni(_PART)
		call_RoleAni(_ROLE)

func call_Ani(_ANINAME: String):
	if ANI.has_animation(_ANINAME):
		ANI.play(_ANINAME)

func call_PartAni(_ANINAME):
	if PartANI.has_animation(_ANINAME):
		PartANI.play(_ANINAME)
	else:
		PartANI.play("init")
func call_RoleAni(_ANINAME):
	if RoleANI.has_animation(_ANINAME):
		RoleANI.play(_ANINAME)

func call_Only_ID(_ID: int):
	if GameLogic.Config.CostumeConfig.has(str(_ID)):
		ID = _ID
		var _INFO = GameLogic.Config.CostumeConfig[str(_ID)]
		var _PART = _INFO.part
		var _ROLE = _INFO.role
		var _ANI = _INFO.ANI

		call_Ani(_ANI)
		call_PartAni(_PART)
		call_RoleAni(_ROLE)
	else:
		call_Ani("init")
		call_RoleAni("init")
		call_PartAni("init")
