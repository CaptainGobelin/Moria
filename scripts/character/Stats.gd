extends Node

onready var currentClass = 0
onready var entityName = "Mendiant"
onready var hpMax = 10 setget updateHpMax
onready var hp = 10 setget updateHp
onready var ca = 3 setget updateCA
onready var prot = 0 setget updateProt
onready var dmgDices = Vector2(1, 1) setget updateDmg
onready var hitDices = Vector2(1, 1) setget updateHit
onready var skills = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var masteries = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
onready var skp = 2

func init():
	entityName = Data.classes[currentClass][Data.CL_NAME]
	updateHpMax(Data.classes[currentClass][Data.CL_HP])
	updateHp(Data.classes[currentClass][Data.CL_HP])
	updateCA(4)
	updateProt(0)
	updateDmg(Vector2(1, 4))
	updateHit(Vector2(1, 12))
	skills = Data.classes[currentClass][Data.CL_SK]
	masteries = Data.classes[currentClass][Data.CL_SKMAS]

func updateHpMax(newValue):
	hpMax = newValue
	Ref.ui.updateStat(Data.ST_HPMAX, newValue)

func updateHp(newValue):
	newValue = min(newValue, hpMax)
	hp = newValue
	Ref.ui.updateStat(Data.ST_HP, newValue)

func updateCA(newValue):
	ca = newValue
	Ref.ui.updateStat(Data.ST_CA, newValue)

func updateProt(newValue):
	prot = newValue
	Ref.ui.updateStat(Data.ST_PROT, newValue)

func updateDmg(newValue):
	dmgDices = newValue
	Ref.ui.updateStat(Data.ST_DMG, newValue)

func updateHit(newValue):
	hitDices = newValue
	Ref.ui.updateStat(Data.ST_HIT, newValue)
