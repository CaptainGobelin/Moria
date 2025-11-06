extends Node

var spells = []
var spellsUses = {}
var schoolSaves = [0, 0, 0, 0, 0]

func getSavingThrow(school: int):
	return schoolSaves[school]

func getSchoolSkillLevel(school: int):
	return Ref.character.skills.skills[schoolToSkill(school)]

func getSpellRank(school: int) -> int:
	var skill = get_parent().skills.skills[schoolToSkill(school)]
	if skill < 2:
		return 0
	if skill < 4:
		return 1
	return 2

func learnSpell(idx: int):
	spells.append(idx)
	var school = Data.spells[idx][Data.SP_SCHOOL]
	var rank = getSpellRank(school)
	spellsUses[idx] = Data.spells[idx][Data.SP_USES][rank]

func improveUses(school: int):
	var rank = getSpellRank(school)
	if rank == 0:
		return
	for s in spells:
		var spell = Data.spells[s]
		if spell[Data.SP_SCHOOL] == school:
			spellsUses[s] += (spell[Data.SP_USES][rank] - spell[Data.SP_USES][rank-1])

func schoolToSkill(school: int) -> int:
	match school:
		Data.SC_EVOCATION:
			return Data.SK_EVOC
		Data.SC_ENCHANTMENT:
			return Data.SK_ENCH
		Data.SC_ABJURATION:
			return Data.SK_ABJ
		Data.SC_DIVINATION:
			return Data.SK_DIV
		Data.SC_CONJURATION:
			return Data.SK_CONJ
	return -1

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		var key = Ref.character.shortcuts.getKey(s, GLOBAL.SP_TYPE)
		var maxUses = current[Data.SP_USES][getSpellRank(Data.spells[s][Data.SP_SCHOOL])]
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], maxUses, key])
	return result
