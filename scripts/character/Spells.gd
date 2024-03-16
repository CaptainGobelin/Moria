extends Node

var spells = [0, 1, 2, 3]
var spellsUses = {
	0: 12, 1: 2, 2: 5, 3: 10
}

func getSpellsRows():
	var result = []
	for s in spells:
		var current = Data.spells[s]
		var key = Ref.character.shortcuts.getKey(s, GLOBAL.SP_TYPE)
		result.append([s, current[Data.SP_NAME], current[Data.SP_ICON], spellsUses[s], current[Data.SP_USES], key])
	return result
