extends Node

onready var classStats: Array
onready var charName: String = "Fridolin"
onready var entityName: String = "Mendiant"
onready var level: int = 1 setget updateLevel
onready var xp: int = 0 setget updateXp
onready var atkRange: int = GLOBAL.VIEW_RANGE
onready var hpMax: int = 10 setget updateHpMax
onready var hp: int = 10 setget updateHp
onready var ca: int = 3 setget updateCA
onready var prot: int = 0 setget updateProt
onready var dmgDices: Array = [GeneralEngine.dmgDice(1, 1, 0, Data.DMG_BLUNT)] setget updateDmg
onready var hitDices = GeneralEngine.dice(1, 6, 0) setget updateHit
onready var perception = GeneralEngine.dice(1, 6, 0)
onready var resists: Array = [0, 0, 0, 0, 0, 0, 0, 0]
onready var maxResists: Array = [1, 1, 1, 1, 1, 1, 1, 1]
onready var saveBonus: Array = [0, 0]
onready var lastPoisonTick: int = 5

func init(charClass: int):
	if charClass == -1:
		charClass = 0
	classStats = Data.classes[charClass]
	entityName = classStats[Data.CL_NAME]
	Ref.ui.updateStat(Data.CHAR_NAME, [charName, entityName])
	updateLevel(1)
	updateXp(0)
	updateHpMax(classStats[Data.CL_HP])
	updateHp(classStats[Data.CL_HP])
	updateCA(0)
	updateProt(0)
	updateDmg([GeneralEngine.dmgDice(1, 1, 0, Data.DMG_BLUNT)])
	updateHit(GeneralEngine.dice(1, 6, 0))

func setName(newName: String):
	charName = newName
	Ref.ui.updateStat(Data.CHAR_NAME, [charName, entityName])

func computeStats():
	computeRange()
	computeHpMax()
	computeCA()
	computeProt()
	computeDmg()
	computeHit()
	computeSaves()
	computeResists()
	StatusEngine.applyEffect(get_parent())
	applyMageArmor()
	applyBlind()
#	Utils.printDict(get_parent().enchants)
#	Utils.printDict(get_parent().statuses)

func computeRange():
	atkRange = GLOBAL.VIEW_RANGE

func computeHpMax():
	var value = classStats[Data.CL_HP]
	value += (level-1) * classStats[Data.CL_HPLVL] 
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
			value += GLOBAL.items[i][GLOBAL.IT_CA]
	updateCA(value)

func updateCA(newValue: int):
	ca = newValue
	Ref.ui.updateStat(Data.CHAR_CA, newValue)

func applyMageArmor():
	if hasStatus(Data.STATUS_MAGE_ARMOR):
		var rank = getStatusRank(Data.STATUS_MAGE_ARMOR)
		if ca <= (4 + rank):
			ca = 4 + rank
			updateCA(ca)

func applyBlind():
	if hasStatus(Data.STATUS_BLIND):
		atkRange = 3

func applyPoison():
	if hasStatus(Data.STATUS_POISON):
		lastPoisonTick -= 1
		if lastPoisonTick <= 0:
			var rank = getStatusRank(Data.STATUS_POISON)
			var dice = GeneralEngine.dmgDice(0, 0, rank + 1, Data.DMG_POISON)
			var dmg = GeneralEngine.computeDamages([dice], resists)
			get_parent().takeHit(dmg)
			lastPoisonTick = 5
	else:
		lastPoisonTick = 5

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
			value += GLOBAL.items[i][GLOBAL.IT_PROT]
	updateProt(value)

func updateProt(newValue: int):
	prot = newValue
	Ref.ui.updateStat(Data.CHAR_PROT, newValue)

func computeDmg():
	var value = []
	var weapon = Ref.character.inventory.getWeapon()
	if weapon != -1:
		value = [GLOBAL.items[weapon][GLOBAL.IT_DMG].duplicate()]
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
	var value = GeneralEngine.dice(1, 6, 0)
	var weapon = Ref.character.inventory.getWeapon()
	if weapon != -1:
		value.b += GLOBAL.items[weapon][GLOBAL.IT_HIT]
	updateHit(value)

func updateHit(newValue):
	hitDices = newValue
	Ref.ui.updateStat(Data.CHAR_HIT, newValue)

func computePerception():
	perception = GeneralEngine.dice(1, 6, 0)

func computeResists():
	for i in range(8):
		resists[i] = 0
	updateResists()

func updateResists():
	Ref.ui.updateStat(Data.CHAR_R_FIRE, [resists[Data.DMG_FIRE], maxResists[Data.DMG_FIRE]])
	Ref.ui.updateStat(Data.CHAR_R_POISON, [resists[Data.DMG_POISON], maxResists[Data.DMG_POISON]])

func computeSaves():
	saveBonus = [0, 0]

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
		Ref.character.skills.skp += Data.skpGains[level]
		Ref.character.skills.ftp += Data.ftpGains[level]
		Ref.ui.writeLevelUp(level, classStats[Data.CL_HPLVL], Data.skpGains[level], Data.ftpGains[level])
		Ref.ui.updateStat(Data.CHAR_XP, xp)
	else:
		xp = newValue
		Ref.ui.updateStat(Data.CHAR_XP, newValue)

func hasStatus(status: int) -> bool:
	return get_parent().statuses.has(status)

func getStatusRank(status: int) -> int:
	return StatusEngine.getStatusRank(get_parent(), status)

func hpPercent() -> float:
	var current = hp as float
	var maxHp = hpMax as float
	return current / maxHp
