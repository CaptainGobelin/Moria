extends Node

onready var currentClass: Array = Data.classes[0]
onready var entityName: String = "Mendiant"
onready var level: int = 1 setget updateLevel
onready var xp: int = 0 setget updateXp
onready var hpMax: int = 10 setget updateHpMax
onready var hp: int = 10 setget updateHp
onready var ca: int = 3 setget updateCA
onready var prot: int = 0 setget updateProt
onready var dmgDices: Array = [GeneralEngine.dmgDice(1, 1, 0, Data.DMG_BLUNT)] setget updateDmg
onready var hitDices = GeneralEngine.dice(1, 6, 0) setget updateHit
onready var resists: Array = [0, 0, 0, 0, 0, 0, 0, 0]
onready var maxResists: Array = [1, 1, 1, 1, 1, 1, 1, 1]
onready var skills = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var masteries = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var skp: int = 0

func init():
	entityName = currentClass[Data.CL_NAME]
	Ref.ui.updateStat(Data.CHAR_NAME, ["Fridolin", entityName])
	updateLevel(1)
	updateXp(0)
	updateHpMax(currentClass[Data.CL_HP])
	updateHp(currentClass[Data.CL_HP])
	updateCA(0)
	updateProt(0)
	updateDmg([GeneralEngine.dmgDice(1, 1, 0, Data.DMG_BLUNT)])
	updateHit(GeneralEngine.dice(1, 6, 0))
	skills = currentClass[Data.CL_SK]
	masteries = currentClass[Data.CL_SKMAS]

func computeStats():
	computeHpMax()
	computeCA()
	computeProt()
	computeDmg()
	computeHit()
	StatusEngine.applyEffect(get_parent())
	Utils.printDict(get_parent().enchants)
	Utils.printDict(get_parent().statuses)

func computeHpMax():
	var value = currentClass[Data.CL_HP]
	value += (level-1) * currentClass[Data.CL_HPLVL] 
	updateHpMax(value)

func updateHpMax(newValue: int):
	hpMax = newValue
	Ref.ui.updateStat(Data.CHAR_HPMAX, newValue)

func updateHp(newValue: int):
	newValue = min(newValue, hpMax)
	hp = newValue
	Ref.ui.updateStat(Data.CHAR_HP, newValue)

func computeCA():
	var items = [
		Ref.character.inventory.getArmor(),
		Ref.character.inventory.getHelmet()
	]
	var weapon = Ref.character.inventory.getWeapon()
	if weapon == -1 or not GLOBAL.items[weapon][GLOBAL.IT_2H]:
		items.append(Ref.character.inventory.getShield())
	var value = 0
	for i in items:
		if i != -1:
			var diceBonus = 0
			if GLOBAL.items[i][GLOBAL.IT_SPEC].has(Data.ENCH_1_AR):
				diceBonus = 1
			elif GLOBAL.items[i][GLOBAL.IT_SPEC].has(Data.ENCH_2_AR):
				diceBonus = 1
			elif GLOBAL.items[i][GLOBAL.IT_SPEC].has(Data.ENCH_3_AR):
				diceBonus = 1
			value += GLOBAL.items[i][GLOBAL.IT_CA] + diceBonus
	updateCA(value)

func updateCA(newValue: int):
	ca = newValue
	Ref.ui.updateStat(Data.CHAR_CA, newValue)

func computeProt():
	var items = [
		Ref.character.inventory.getArmor(),
		Ref.character.inventory.getHelmet()
	]
	var weapon = Ref.character.inventory.getWeapon()
	if weapon == -1 or not GLOBAL.items[weapon][GLOBAL.IT_2H]:
		items.append(Ref.character.inventory.getShield())
	var value = 0
	for i in items:
		if i != -1:
			var diceBonus = 0
			if GLOBAL.items[i][GLOBAL.IT_SPEC].has(Data.ENCH_1_AR):
				diceBonus = 1
			elif GLOBAL.items[i][GLOBAL.IT_SPEC].has(Data.ENCH_2_AR):
				diceBonus = 1
			elif GLOBAL.items[i][GLOBAL.IT_SPEC].has(Data.ENCH_3_AR):
				diceBonus = 1
			value += GLOBAL.items[i][GLOBAL.IT_PROT] + diceBonus
	updateProt(value)

func updateProt(newValue: int):
	prot = newValue
	Ref.ui.updateStat(Data.CHAR_PROT, newValue)

func computeDmg():
	var value = []
	var weapon = Ref.character.inventory.getWeapon()
	if weapon != -1:
		var diceBonus = 0
		if GLOBAL.items[weapon][GLOBAL.IT_SPEC].has(Data.ENCH_1_WP):
			diceBonus = 1
		elif GLOBAL.items[weapon][GLOBAL.IT_SPEC].has(Data.ENCH_2_WP):
			diceBonus = 1
		elif GLOBAL.items[weapon][GLOBAL.IT_SPEC].has(Data.ENCH_3_WP):
			diceBonus = 1
		value = [GLOBAL.items[weapon][GLOBAL.IT_DMG]]
		value[0].dice.b = diceBonus
	else:
		value = [GeneralEngine.dmgDice(1, 1, 0, Data.DMG_BLUNT)]
	updateDmg(value)

func updateDmg(newValue: Array):
	dmgDices = newValue
	Ref.ui.updateStat(Data.CHAR_DMG, newValue)

func addDmg(newValue):
	dmgDices.append(newValue)
	updateDmg(dmgDices)

func computeHit():
	var value = []
	var weapon = Ref.character.inventory.getWeapon()
	if weapon != -1:
		var diceBonus = 0
		if GLOBAL.items[weapon][GLOBAL.IT_SPEC].has(Data.ENCH_1_WP):
			diceBonus = 1
		elif GLOBAL.items[weapon][GLOBAL.IT_SPEC].has(Data.ENCH_2_WP):
			diceBonus = 1
		elif GLOBAL.items[weapon][GLOBAL.IT_SPEC].has(Data.ENCH_3_WP):
			diceBonus = 1
		value = GLOBAL.items[weapon][GLOBAL.IT_HIT]
		value.b = diceBonus
	else:
		value = GeneralEngine.dice(1, 6, 0)
	updateHit(value)

func updateHit(newValue):
	hitDices = newValue
	Ref.ui.updateStat(Data.CHAR_HIT, newValue)

func updateReissts(newValue):
	pass

func updateLevel(newValue):
	level = newValue
	Ref.ui.updateStat(Data.CHAR_LVL, newValue)
	Ref.ui.updateStat(Data.CHAR_XPMAX, Data.lvlCaps[level])

func updateXp(newValue):
	if (newValue - xp) > 0:
		Ref.ui.writeXpGain(newValue - xp)
	if newValue >= Data.lvlCaps[level]:
		xp = (newValue % Data.lvlCaps[level])
		updateLevel(level + 1)
		skp += Data.skpGains[level]
		Ref.ui.writeLevelUp(level, currentClass[Data.CL_HPLVL], Data.skpGains[level], 0)
		Ref.ui.updateStat(Data.CHAR_XP, xp)
	else:
		xp = newValue
		Ref.ui.updateStat(Data.CHAR_XP, newValue)
