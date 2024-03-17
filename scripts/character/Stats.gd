extends Node

onready var currentClass = Data.classes[0]
onready var entityName = "Mendiant"
onready var level = 1 setget updateLevel
onready var xp = 0 setget updateXp
onready var hpMax = 10 setget updateHpMax
onready var hp = 10 setget updateHp
onready var ca = 3 setget updateCA
onready var prot = 0 setget updateProt
onready var dmgDices = Vector2(1, 1) setget updateDmg
onready var hitDices = Vector2(1, 1) setget updateHit
onready var skills = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var masteries = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var skp = 0

func init():
	entityName = currentClass[Data.CL_NAME]
	Ref.ui.updateStat(Data.CHAR_NAME, ["Fridolin", entityName])
	updateLevel(1)
	updateXp(0)
	updateHpMax(currentClass[Data.CL_HP])
	updateHp(currentClass[Data.CL_HP])
	updateCA(4)
	updateProt(0)
	updateDmg(Vector2(10, 4))
	updateHit(Vector2(10, 12))
	skills = currentClass[Data.CL_SK]
	masteries = currentClass[Data.CL_SKMAS]

func updateHpMax(newValue):
	hpMax = newValue
	Ref.ui.updateStat(Data.CHAR_HPMAX, newValue)

func updateHp(newValue):
	newValue = min(newValue, hpMax)
	hp = newValue
	Ref.ui.updateStat(Data.CHAR_HP, newValue)

func updateCA(newValue):
	ca = newValue
	Ref.ui.updateStat(Data.CHAR_CA, newValue)

func updateProt(newValue):
	prot = newValue
	Ref.ui.updateStat(Data.CHAR_PROT, newValue)

func updateDmg(newValue):
	dmgDices = newValue
	Ref.ui.updateStat(Data.CHAR_DMG, newValue)

func updateHit(newValue):
	hitDices = newValue
	Ref.ui.updateStat(Data.CHAR_HIT, newValue)

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
