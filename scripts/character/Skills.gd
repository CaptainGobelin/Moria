extends Node
class_name Skills

var feats: Array = []
var ftp: int = 2
var skills: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var masteries: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var skp: int = 5

func init(charClass: int):
	if charClass != -1:
		masteries = Data.classes[charClass][Data.CL_SKMAS].duplicate()

func improve(idx: int, isFree: bool = false):
	skills[idx] += 1
	if !isFree:
		skp -= 1
	var school = skillToSchool(idx)
	Ref.character.stats.computeStats()
	if school == null:
		return null
	var spLevel = 0
	if skills[idx] == 1:
		spLevel = 1
	if skills[idx] == 3:
		spLevel = 2
	if skills[idx] == 5:
		spLevel = 3
	if skills[idx] == 2 or skills[idx] == 4:
		Ref.character.spells.improveUses(school)
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

func addFeat(feat: int):
	Ref.character.skills.feats.append(feat)
	match feat:
		Data.FEAT_ABJURER:
			masteries[Data.SK_ABJ] = 2
			masteries[Data.SK_DIV] = 1
			masteries[Data.SK_CONJ] = 1
			masteries[Data.SK_ENCH] = 0
			return improve(Data.SK_ABJ)
		Data.FEAT_CONJURER:
			masteries[Data.SK_ABJ] = 0
			masteries[Data.SK_DIV] = 1
			masteries[Data.SK_CONJ] = 2
			masteries[Data.SK_ENCH] = 1
			return improve(Data.SK_CONJ)
		Data.FEAT_DIVINER:
			masteries[Data.SK_ABJ] = 1
			masteries[Data.SK_DIV] = 2
			masteries[Data.SK_CONJ] = 0
			masteries[Data.SK_ENCH] = 1
			return improve(Data.SK_DIV)
		Data.FEAT_ENCHANTER:
			masteries[Data.SK_ABJ] = 1
			masteries[Data.SK_DIV] = 0
			masteries[Data.SK_CONJ] = 1
			masteries[Data.SK_ENCH] = 2
			return improve(Data.SK_ENCH)
		Data.FEAT_SPHERE_WAR:
			masteries[Data.SK_ABJ] = 2
			masteries[Data.SK_DIV] = 0
			masteries[Data.SK_CONJ] = 0
			masteries[Data.SK_ENCH] = 1
			return improve(Data.SK_ABJ)
		Data.FEAT_SPHERE_ASTRAL:
			masteries[Data.SK_ABJ] = 0
			masteries[Data.SK_DIV] = 2
			masteries[Data.SK_CONJ] = 1
			masteries[Data.SK_ENCH] = 0
			return improve(Data.SK_DIV)
		Data.FEAT_SPHERE_LAW:
			masteries[Data.SK_ABJ] = 0
			masteries[Data.SK_DIV] = 1
			masteries[Data.SK_CONJ] = 0
			masteries[Data.SK_ENCH] = 2
			return improve(Data.SK_ENCH)
		Data.FEAT_SKILLED_COMBAT:
			masteries[Data.SK_COMBAT] += 1
			return improve(Data.SK_COMBAT)
		Data.FEAT_SKILLED_ARMOR:
			masteries[Data.SK_ARMOR] += 1
			return improve(Data.SK_ARMOR)
		Data.FEAT_SKILLED_EVOCATION:
			masteries[Data.SK_EVOC] += 1
			return improve(Data.SK_EVOC)
		Data.FEAT_SKILLED_ENCHANTMENT:
			masteries[Data.SK_ENCH] += 1
			return improve(Data.SK_ENCH)
		Data.FEAT_SKILLED_ABJURATION:
			masteries[Data.SK_ABJ] += 1
			return improve(Data.SK_ABJ)
		Data.FEAT_SKILLED_DIVINATION:
			masteries[Data.SK_DIV] += 1
			return improve(Data.SK_DIV)
		Data.FEAT_SKILLED_CONJURATION:
			masteries[Data.SK_CONJ] += 1
			return improve(Data.SK_CONJ)
		Data.FEAT_SKILLED_PHYSICS:
			masteries[Data.SK_PHY] += 1
			return improve(Data.SK_PHY)
		Data.FEAT_SKILLED_WILLPOWER:
			masteries[Data.SK_WIL] += 1
			return improve(Data.SK_WIL)
		Data.FEAT_SKILLED_PERCEPTION:
			masteries[Data.SK_PER] += 1
			return improve(Data.SK_PER)
		Data.FEAT_SKILLED_THIEVERY:
			masteries[Data.SK_THI] += 1
			return improve(Data.SK_THI)
	return null

static func removeForbiddenFeats(featList: Array) -> Array:
	if featList.has(Data.FEAT_SKILLED_COMBAT):
		if Ref.character.skills.masteries[Data.SK_COMBAT] == 2:
			featList.erase(Data.FEAT_SKILLED_COMBAT)
	if featList.has(Data.FEAT_SKILLED_ARMOR):
		if Ref.character.skills.masteries[Data.SK_ARMOR] == 2:
			featList.erase(Data.FEAT_SKILLED_ARMOR)
	if featList.has(Data.FEAT_SKILLED_EVOCATION):
		if Ref.character.skills.masteries[Data.SK_EVOC] == 2:
			featList.erase(Data.FEAT_SKILLED_EVOCATION)
	if featList.has(Data.FEAT_SKILLED_ENCHANTMENT):
		if Ref.character.skills.masteries[Data.SK_ENCH] == 2:
			featList.erase(Data.FEAT_SKILLED_ENCHANTMENT)
	if featList.has(Data.FEAT_SKILLED_ABJURATION):
		if Ref.character.skills.masteries[Data.SK_ABJ] == 2:
			featList.erase(Data.FEAT_SKILLED_ABJURATION)
	if featList.has(Data.FEAT_SKILLED_DIVINATION):
		if Ref.character.skills.masteries[Data.SK_DIV] == 2:
			featList.erase(Data.FEAT_SKILLED_DIVINATION)
	if featList.has(Data.FEAT_SKILLED_CONJURATION):
		if Ref.character.skills.masteries[Data.SK_CONJ] == 2:
			featList.erase(Data.FEAT_SKILLED_CONJURATION)
	if featList.has(Data.FEAT_SKILLED_PHYSICS):
		if Ref.character.skills.masteries[Data.SK_PHY] == 2:
			featList.erase(Data.FEAT_SKILLED_PHYSICS)
	if featList.has(Data.FEAT_SKILLED_WILLPOWER):
		if Ref.character.skills.masteries[Data.SK_WIL] == 2:
			featList.erase(Data.FEAT_SKILLED_WILLPOWER)
	if featList.has(Data.FEAT_SKILLED_PERCEPTION):
		if Ref.character.skills.masteries[Data.SK_PER] == 2:
			featList.erase(Data.FEAT_SKILLED_PERCEPTION)
	if featList.has(Data.FEAT_SKILLED_THIEVERY):
		if Ref.character.skills.masteries[Data.SK_THI] == 2:
			featList.erase(Data.FEAT_SKILLED_THIEVERY)
	return featList

static func canEquipWeapon(idx: int) -> bool:
	return Ref.character.skills.skills[Data.SK_COMBAT] >= Data.weapons[idx][Data.W_SKILL] 

static func getHitBonus() -> int:
	if Ref.character.skills.skills[Data.SK_COMBAT] == 5:
		return 3
	if Ref.character.skills.skills[Data.SK_COMBAT] >= 3:
		return 2
	if Ref.character.skills.skills[Data.SK_COMBAT] >= 1:
		return 1
	return 0

static func getPerceptionBonus() -> int:
	if Ref.character.skills.skills[Data.SK_PER] == 5:
		return 3
	if Ref.character.skills.skills[Data.SK_PER] >= 3:
		return 2
	if Ref.character.skills.skills[Data.SK_PER] >= 1:
		return 1
	return 0

static func getLootRarityBonus() -> int:
	var rand = randf()
	if Ref.character.skills.skills[Data.SK_PER] >= 4 and rand < 0.3:
		return 1
	if Ref.character.skills.skills[Data.SK_PER] >= 2 and rand < 0.15:
		return 1
	return 0

static func getAmorMalusReduction() -> int:
	return 5 - Ref.character.skills.skills[Data.SK_ARMOR]

static func getLockpickBonus() -> int:
	return Ref.character.skills.skills[Data.SK_THI]

static func getMerchantDiscount() -> float:
	if Ref.character.skills.skills[Data.SK_THI] == 5:
		return 0.55
	if Ref.character.skills.skills[Data.SK_THI] >= 3:
		return 0.7
	if Ref.character.skills.skills[Data.SK_THI] >= 1:
		return 0.85
	return 1.0

static func getPhySavesBonus() -> int:
	if Ref.character.skills.skills[Data.SK_PHY] == 5:
		return 3
	if Ref.character.skills.skills[Data.SK_PHY] >= 3:
		return 2
	if Ref.character.skills.skills[Data.SK_PHY] >= 1:
		return 1
	return 0

static func hasImproveHp() -> bool:
	return Ref.character.skills.skills[Data.SK_PHY] >= 2

static func hasImprovedPotions() -> bool:
	return Ref.character.skills.skills[Data.SK_PHY] >= 4

static func hasPoisonResistance() -> bool:
	return Ref.character.skills.skills[Data.SK_PHY] >= 2

static func hasFireResistance() -> bool:
	return Ref.character.skills.skills[Data.SK_PHY] >= 4

static func getWilSavesBonus() -> int:
	if Ref.character.skills.skills[Data.SK_WIL] == 5:
		return 3
	if Ref.character.skills.skills[Data.SK_WIL] >= 3:
		return 2
	if Ref.character.skills.skills[Data.SK_WIL] >= 1:
		return 1
	return 0

static func isImmuneToSleep() -> bool:
	return Ref.character.skills.skills[Data.SK_WIL] >= 2

static func isImmuneToTerror() -> bool:
	return Ref.character.skills.skills[Data.SK_WIL] >= 4
