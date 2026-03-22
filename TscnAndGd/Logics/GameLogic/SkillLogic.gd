extends Node

var Skill_Base: Dictionary
var Skill_Plus: Dictionary
var Skill_Minus: Dictionary

var HandWorkMult: float = 0.25

func _ready() -> void :
	call_deferred("call_init")

func call_init():
	if not GameLogic.Config.SkillConfig:
		return
	var _SkillKeys = GameLogic.Config.SkillConfig.keys()
	for _Name in _SkillKeys:
		if int(GameLogic.Config.SkillConfig[_Name].Type) == 0:
			Skill_Base[_Name] = GameLogic.Config.SkillConfig[_Name]
			Skill_Plus[_Name] = GameLogic.Config.SkillConfig[_Name]
		if int(GameLogic.Config.SkillConfig[_Name].Type) == 1:
			Skill_Plus[_Name] = GameLogic.Config.SkillConfig[_Name]
		elif int(GameLogic.Config.SkillConfig[_Name].Type) == 2:
			Skill_Minus[_Name] = GameLogic.Config.SkillConfig[_Name]

func return_skills(_BaseSkills: Array, _Type: String, _Rank: int):
	var _SkillList: Array
	for _SKILL in _BaseSkills:
		if str(_SKILL) != "0":
			_SkillList.append(_SKILL)
	var BaseNum = _SkillList.size()
	var _PlusRand: int = 1 + GameLogic.return_RANDOM() % (3 - BaseNum)

	var _Skill_Base_Keys = Skill_Base.keys()
	var _Skill_Plus_Keys = Skill_Plus.keys()
	var _Skill_Minus_Keys = Skill_Minus.keys()
	for _i in _Rank:
		if _i == 0:
			match _Type:
				"点单":
					if not _SkillList.has("技能-自动点单"):
						_SkillList.append("技能-自动点单")
						if _Skill_Base_Keys.has("技能-自动点单"):
							_Skill_Base_Keys.erase("技能-自动点单")
				"保洁":
					if not _SkillList.has("技能-丢垃圾"):
						_SkillList.append("技能-丢垃圾")
						if _Skill_Base_Keys.has("技能-丢垃圾"):
							_Skill_Base_Keys.erase("技能-丢垃圾")
				"搬运":
					if not _SkillList.has("技能-进货整理"):
						_SkillList.append("技能-进货整理")
						if _Skill_Base_Keys.has("技能-进货整理"):
							_Skill_Base_Keys.erase("技能-进货整理")
				"清洁":
					pass
				_:
					var _rand = GameLogic.return_RANDOM() % _Skill_Base_Keys.size()
					if not _SkillList.has(_Skill_Base_Keys[_rand]):
						_SkillList.append(_Skill_Base_Keys.pop_at(_rand))

		else:
			var _rand = GameLogic.return_RANDOM() % _Skill_Base_Keys.size()
			if not _SkillList.has(_Skill_Base_Keys[_rand]):
				_SkillList.append(_Skill_Base_Keys.pop_at(_rand))

	for _i in _PlusRand:
		var _rand = GameLogic.return_RANDOM() % Skill_Plus.size()
		if not _SkillList.has(_Skill_Plus_Keys[_rand]):
			_SkillList.append(_Skill_Plus_Keys[_rand])

	return _SkillList
