extends Node

var spells = [Data.SP_LESSER_AQUIREMENT, Data.SP_SPIRITUAL_HAMMER, Data.SP_ACID_SPLASH]
var spellsUses = {
	Data.SP_LESSER_AQUIREMENT: 15,
	Data.SP_SPIRITUAL_HAMMER: 10,
	Data.SP_ACID_SPLASH: 8
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
