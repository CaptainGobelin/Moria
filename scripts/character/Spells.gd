extends Node

var spells = [
	Data.SP_UNLOCK,
	Data.SP_MAGE_ARMOR,
	Data.SP_MAGIC_MISSILE,
	Data.SP_CONJURE_ANIMAL,
	Data.SP_DETECT_EVIL
]
var spellsUses = {
	Data.SP_UNLOCK: 15,
	Data.SP_MAGE_ARMOR: 10,
	Data.SP_MAGIC_MISSILE: 8,
	Data.SP_CONJURE_ANIMAL: 10,
	Data.SP_DETECT_EVIL: 10
}
var schoolRanks = [0, 0, 0, 0, 0]
var schoolSaves = [0, 0, 0, 0, 0]

func getSavingThrow(school: int):
	return schoolSaves[school]

func getSpellRank(school: int):
	return 1 + (int(schoolRanks[school]) / int(2))

func getSchoolRank(school: int):
	return (int(schoolRanks[school]) / int(2))

func learnSpell(idx: int):
	spells.append(idx)
	var school = Data.spells[idx][Data.SP_SCHOOL]
	var rank = getSpellRank(school)
	spellsUses[idx] = Data.spells[idx][Data.SP_USES][rank]

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		var key = Ref.character.shortcuts.getKey(s, GLOBAL.SP_TYPE)
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], current[Data.SP_USES][0], key])
	return result
