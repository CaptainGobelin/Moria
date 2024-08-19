extends Node

onready var entityName = "Snail"
onready var ca = 6
onready var prot = 0
onready var maxHp = 10
onready var currentHp = 1
onready var atkRange = 6
onready var hitBonus = 0
onready var hitDices = GeneralEngine.dice(1, 6, 0)
onready var dmgDices = [GeneralEngine.dmgDice(1, 1, 0, Data.DMG_BLUNT)]
onready var resists: Array = [0, 0, 0, 0, 0, 0, 0, 0]
onready var maxResists: Array = [1, 1, 1, 1, 1, 1, 1, 1]
onready var saveBonus: Array = [0, 0]
onready var spellcasterLevel: int = 0
onready var xp = 0
onready var state: String = ""

func init(type: int):
	entityName = Data.monsters[type][Data.MO_NAME]
	ca = Data.monsters[type][Data.MO_CA]
	prot = Data.monsters[type][Data.MO_PROT]
	maxHp = Data.monsters[type][Data.MO_HP]
	currentHp = maxHp
	hitBonus = Data.monsters[type][Data.MO_HIT]
	hitDices = GeneralEngine.dice(1, 6, hitBonus)
	var dmg = Data.monsters[type][Data.MO_DMG]
	dmgDices = [GeneralEngine.dmgDice(dmg.x, dmg.y, dmg.z, Data.DMG_SLASH)]
	spellcasterLevel = Data.monsters[type][Data.MO_CASTER_LVL]
	xp = Data.monsters[type][Data.MO_XP]
	computeStats()

func computeStats():
	computeState()

func computeState():
	state = ""
	if get_parent().statuses.has(Data.STATUS_SLEEP):
		state = "disabled"

func hpPercent() -> float:
	return float(currentHp)/float(maxHp) * 100