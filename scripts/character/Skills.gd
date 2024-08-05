extends Node

onready var skills = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var masteries = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var skp: int = 5

func init(charClass: int):
	skills = Data.classes[charClass][Data.CL_SK].duplicate()
	masteries = Data.classes[charClass][Data.CL_SKMAS].duplicate()

func improve(idx: int):
	skills[idx] += 1
	skp -= 1
	var spLevel = 0
	if skills[idx] == 1:
		spLevel = 1
	if skills[idx] == 3:
		spLevel = 2
	if skills[idx] == 5:
		spLevel = 3
	match idx:
		Data.SK_EVOC:
			return ["chooseSpell", Data.SC_EVOCATION, spLevel]
		Data.SK_ENCH:
			return ["chooseSpell", Data.SC_ENCHANTMENT, spLevel]
		Data.SK_ABJ:
			return ["chooseSpell", Data.SC_ABJURATION, spLevel]
		Data.SK_DIV:
			return ["chooseSpell", Data.SC_DIVINATION, spLevel]
		Data.SK_CONJ:
			return ["chooseSpell", Data.SC_CONJURATION, spLevel]
	return null
