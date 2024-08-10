extends Node

var feats: Array = []
var ftp: int = 3
var skills: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var masteries: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var skp: int = 5

func init(charClass: int):
	skills = Data.classes[charClass][Data.CL_SK].duplicate()
	masteries = Data.classes[charClass][Data.CL_SKMAS].duplicate()

func improve(idx: int):
	skills[idx] += 1
	skp -= 1
	var school = skillToSchool(idx)
	if school == null:
		return null
	var spLevel = 0
	if skills[idx] == 1:
		spLevel = 1
	if skills[idx] == 3:
		spLevel = 2
	if skills[idx] == 5:
		spLevel = 3
	return ["chooseSpell", school, spLevel]

func skillToSchool(skill: int):
	match skill:
		Data.SK_EVOC:
			return Data.SC_EVOCATION
		Data.SK_ENCH:
			return Data.SC_ENCHANTMENT
		Data.SK_ABJ:
			return Data.SC_ABJURATION
		Data.SK_DIV:
			return Data.SC_DIVINATION
		Data.SK_CONJ:
			return Data.SC_CONJURATION
	return null
