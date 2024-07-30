extends Node

var spells = [Data.SP_BLESS, Data.SP_ELECTRIC_GRASP, Data.SP_SMITE]
var spellsUses = {
	Data.SP_BLESS: 5,
	Data.SP_ELECTRIC_GRASP: 10,
	Data.SP_SMITE: 8
}
var schoolRanks = [0, 0, 0, 0, 0]
var schoolSaves = [0, 0, 0, 0, 0]

func getSavingThrow(school: int):
	return schoolSaves[school]

func getSpellRank(school: int):
	return 1 + (int(schoolRanks[school]) / int(2))

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		var key = Ref.character.shortcuts.getKey(s, GLOBAL.SP_TYPE)
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], current[Data.SP_USES][0], key])
	return result
