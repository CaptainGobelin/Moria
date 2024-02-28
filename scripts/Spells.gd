extends Node

var spells = [0, 1]
var spellsUses = {
	0: 12, 1: 2
}

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], current[Data.SP_USES]])
	return result
