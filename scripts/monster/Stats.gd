extends Node

onready var entityName = "Snail"
onready var type = -1
onready var ca = 6
onready var prot = 0
onready var hpMax = 10
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
onready var lastPoisonTick: int = 5

func init(monsterType: int):
	type = monsterType
	entityName = Data.monsters[type][Data.MO_NAME]
	ca = Data.monsters[type][Data.MO_CA]
	prot = Data.monsters[type][Data.MO_PROT]
	hpMax = Data.monsters[type][Data.MO_HP]
	currentHp = hpMax
	hitBonus = Data.monsters[type][Data.MO_HIT]
	hitDices = GeneralEngine.dice(1, 6, hitBonus)
	var dmg = Data.monsters[type][Data.MO_DMG]
	dmgDices = [GeneralEngine.dmgDice(dmg.x, dmg.y, dmg.z, Data.DMG_SLASH)]
	spellcasterLevel = Data.monsters[type][Data.MO_CASTER_LVL]
	saveBonus = [Data.monsters[type][Data.MO_WIL], Data.monsters[type][Data.MO_PHY]]
	xp = Data.monsters[type][Data.MO_XP]

func computeStats():
	computeState()
	StatusEngine.applyEffect(get_parent())
	applyMageArmor()
	applyBlind()

func applyMageArmor():
	if hasStatus(Data.STATUS_MAGE_ARMOR):
		var rank = getStatusRank(Data.STATUS_MAGE_ARMOR)
		if ca <= (4 + rank):
			ca = 4 + rank

func applyBlind():
	if hasStatus(Data.STATUS_BLIND):
		atkRange = 3

func applyPoison():
	if hasStatus(Data.STATUS_POISON):
		if lastPoisonTick <= 0:
			var rank = getStatusRank(Data.STATUS_POISON)
			var dice = GeneralEngine.dmgDice(0, 0, rank + 1, Data.DMG_POISON)
			var dmg = GeneralEngine.computeDamages(null, dice, resists)
			get_parent().takeHit(dmg)
			lastPoisonTick = 5
		else:
			lastPoisonTick -= 1
	else:
		lastPoisonTick = 5

func computeState():
	state = ""
	if hasStatus(Data.STATUS_IMMOBILE):
		state = "immobile"
	if hasStatus(Data.STATUS_SLEEP):
		state = "disabled"
	elif hasStatus(Data.STATUS_PARALYZED):
		state = "disabled"
	elif hasStatus(Data.STATUS_TERROR):
		state = "disabled"

func hpPercent() -> float:
	return float(currentHp)/float(hpMax) * 100

func hasStatus(status: int) -> bool:
	return get_parent().statuses.has(status)

func getStatusRank(status: int) -> int:
	return StatusEngine.getStatusRank(get_parent(), status)
