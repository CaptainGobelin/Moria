extends Node

var spells = [
	Data.SP_SHIELD,
	Data.SP_MAGE_ARMOR,
	Data.SP_ARMOR_OF_FAITH,
	Data.SP_PROTECTION_FROM_EVIL,
	Data.SP_SANCTUARY
]
var spellsUses = {
	Data.SP_SHIELD: 15,
	Data.SP_MAGE_ARMOR: 10,
	Data.SP_ARMOR_OF_FAITH: 8,
	Data.SP_PROTECTION_FROM_EVIL: 10,
	Data.SP_SANCTUARY: 10
}
var schoolRanks = [0, 0, 0, 0, 0]
var schoolSaves = [0, 0, 0, 0, 0]

func getSavingThrow(school: int):
	return schoolSaves[school]

func getSpellRank(school: int):
	return 1 + (int(schoolRanks[school]) / int(2))

func getSchoolRank(school: int):
	return (int(schoolRanks[school]) / int(2))

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		var key = Ref.character.shortcuts.getKey(s, GLOBAL.SP_TYPE)
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], current[Data.SP_USES][0], key])
	return result
