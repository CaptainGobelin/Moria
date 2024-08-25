extends Node

onready var entityName = "Snail"
onready var type = -1
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

func init(monsterType: int):
	type = monsterType
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
	saveBonus = [Data.monsters[type][Data.MO_WIL], Data.monsters[type][Data.MO_PHY]]
	xp = Data.monsters[type][Data.MO_XP]
	computeStats()

func computeStats():
	computeState()
	computeHit()
	computeRange()

func computeHit():
	var hitBonus = Data.monsters[type][Data.MO_HIT]
	if hasStatus(Data.STATUS_BLIND):
		hitBonus -= 1
	hitDices = GeneralEngine.dice(1, 6, hitBonus)

func computeRange():
	atkRange = 6
	if hasStatus(Data.STATUS_BLIND):
		atkRange = 3

func computeAC():
	ca = Data.monsters[type][Data.MO_CA]
	if hasStatus(Data.STATUS_ARMOR_FAITH):
		ca += 1
	if hasStatus(Data.STATUS_MAGE_ARMOR):
		ca = max(ca, getStatusRank(Data.STATUS_MAGE_ARMOR) + 4)

func computeProt():
	prot = Data.monsters[type][Data.MO_PROT]
	if getStatusRank(Data.STATUS_ARMOR_FAITH) > 0:
		prot += 1

func computeSaves():
	saveBonus = [Data.monsters[type][Data.MO_WIL], Data.monsters[type][Data.MO_PHY]]
	if hasStatus(Data.STATUS_BLESSED):
		var rank = getStatusRank(Data.SP_BLESS)
		saveBonus[0] += (rank + 1)
		saveBonus[1] += (rank + 1)

func computeState():
	state = ""
	if hasStatus(Data.STATUS_SLEEP):
		state = "disabled"
	elif hasStatus(Data.STATUS_PARALYZED):
		state = "disabled"
	elif hasStatus(Data.STATUS_TERROR):
		state = "disabled"

func hpPercent() -> float:
	return float(currentHp)/float(maxHp) * 100

func hasStatus(status: int) -> bool:
	return get_parent().statuses.has(status)

func getStatusRank(status: int) -> int:
	return StatusEngine.getStatusRank(get_parent(), status)
