extends Node

var spells = []
var spellsUses = {}
var schoolSaves = [0, 0, 0, 0, 0]

func getSavingThrow(school: int):
	return schoolSaves[school]

func getSpellRank(school: int):
	var skill = get_parent().skills.skills[schoolToSkill(school)]
	return int(ceil(skill/2.0))

func learnSpell(idx: int):
	spells.append(idx)
	var school = Data.spells[idx][Data.SP_SCHOOL]
	var rank = getSpellRank(school)
	spellsUses[idx] = Data.spells[idx][Data.SP_USES][rank]

func schoolToSkill(school: int):
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
	return null

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		var key = Ref.character.shortcuts.getKey(s, GLOBAL.SP_TYPE)
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], current[Data.SP_USES][0], key])
	return result
