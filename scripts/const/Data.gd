extends Node

# Projectiles
const PROJ_COLOR = 0
const PROJ_TYPE = 1
const PROJ_PURPLE_S = [Colors.purple, 0]
const PROJ_PURPLE_R = [Colors.purple, 9]
const PROJ_RED_L = [Colors.red, 12]
const PROJ_RED_R = [Colors.red, 9]
const PROJ_WHITE_S = [Colors.white, 0]
const PROJ_WHITE_M = [Colors.white, 6]
const PROJ_WHITE_LONG = [Colors.white, 3]
const PROJ_WHITE_R = [Colors.white, 9]
const PROJ_GREEN_R = [Colors.green, 9]

# Spells
const SP_MAGIC_MISSILE = 0
const SP_HEAL = 1
const SP_BLESS = 2
const SP_FIREBALL = 3
const SP_TH_FIREBOMB = 100
const SP_TH_POISON = 101
const SP_TH_SLEEP = 102

# Skills
const SK_COMBAT = 0
const SK_ARMOR = 1
const SK_EVOC = 2
const SK_ENCH = 3
const SK_DIV = 4
const SK_ABJ = 5
const SK_CONJ = 6
const SK_PHY = 7
const SK_WIL = 8
const SK_PER = 9
const SK_THI = 10

# Level caps
const lvlCaps = [0, 6, 50, 75, 110, 150, 200, 275]
const skpGains = [0, 0, 2, 1, 2, 1, 2, 1, 2]

# Classes
const CL_FIGHTER = 0

const CL_NAME = 0
const CL_HP = 1
const CL_HPLVL = 2
const CL_SK = 3
const CL_SKMAS = 4
const classes = {
	0: ["Fighter", 10, 5, [1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0], [2, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1]],
}

# Monsters
const MO_NAME = 0
const MO_HP = 1
const MO_HIT = 2
const MO_DMG = 3
const MO_CA = 4
const MO_PROT = 5
const MO_SPRITE = 6
const MO_XP = 7
const monsters = {
	0: ["Skeleton", 6, Vector2(1, 6), Vector2(1, 4), 5, 1, 0, 4],
}

# Stats
const CHAR_NAME = -1
const CHAR_CA = 0
const CHAR_PROT = 1
const CHAR_DMG = 2
const CHAR_HIT = 3
const CHAR_HPMAX = 4
const CHAR_HP = 5
const CHAR_LOCK = 6
const CHAR_GOLD = 7
const CHAR_LVL = 8
const CHAR_XP = 9
const CHAR_XPMAX = 10

# Weapons
const W_NAME = 0
const W_HIT = 1
const W_DMG = 2
const W_TYPE = 3
const W_RAR = 4
const W_ENCH = 5
const W_2H = 6
const W_ICON = 7
const W_IS_SHIELD = 8
const weapons = {
	0: ["club",			Vector2(1, 12), Vector2(1,  6), "B", 0, 0.4, false,  0],
	1: ["dagger",		Vector2(1, 12), Vector2(1,  4), "S", 1, 1.5, false,  1],
	2: ["hatchet",		Vector2(1,  8), Vector2(1,  8), "S", 1, 0.8, false,  2],
	3: ["mace",			Vector2(1,  8), Vector2(2, 10), "B", 2, 1.0, false,  3],
	4: ["shortsword",	Vector2(1,  8), Vector2(2,  6), "S", 3, 1.2, false,  4],
	5: ["hand axe",		Vector2(1,  4), Vector2(2,  8), "S", 4, 1.6, false,  5],
	6: ["longsword",	Vector2(1,  4), Vector2(2, 10), "S", 5, 2.0, false,  6],
	7: ["morning star",	Vector2(1,  4), Vector2(3,  6), "-", 6, 2.0, false,  7],
	
	8: ["staff",		Vector2(1, 12), Vector2(1,  8), "B", 0, 2.0, true,  8],
	9: ["greatclub",	Vector2(1, 12), Vector2(1, 10), "B", 1, 0.4, true,  9],
	10:["felling axe",	Vector2(1,  8), Vector2(2,  6), "S", 2, 0.8, true, 10],
	11:["maul",			Vector2(1,  8), Vector2(3,  6), "B", 3, 1.2, true, 11],
	12:["broadsword",	Vector2(1,  8), Vector2(2, 12), "S", 4, 1.2, true, 12],
	13:["halberd",		Vector2(1,  4), Vector2(3, 10), "S", 5, 1.5, true, 13],
	14:["greataxe",		Vector2(1,  4), Vector2(3, 12), "S", 6, 1.8, true, 14],
	15:["zweihander",	Vector2(1,  4), Vector2(4,  8), "S", 6, 2.0, true, 15],
}

var weaponsByRarity = {}

func weaponsReader():
	for idx in weapons.keys():
		var rarity = weapons[idx][W_RAR]
		if !weaponsByRarity.has(rarity):
			weaponsByRarity[rarity] = []
		weaponsByRarity[rarity].append(idx)

const SH_NAME = 0
const SH_AC = 1
const SH_PROT = 2
const SH_MALUS = 3
const SH_RAR = 4
const SH_ENCH = 5
const SH_ICON = 6
const shields = {
	0: ["buckler",       1, 0, 1, 0, 1.0, 33],
	1: ["shield",        1, 1, 2, 2, 1.0, 34],
	2: ["heater shield", 2, 1, 4, 4, 1.0, 35]
}

var shieldsByRarity = {}

func shieldsReader():
	for idx in shields.keys():
		var rarity = shields[idx][SH_RAR]
		if !shieldsByRarity.has(rarity):
			shieldsByRarity[rarity] = []
		shieldsByRarity[rarity].append(idx)

# Armors
const A_NAME = 0
const A_CA = 1
const A_PROT = 2
const A_RAR = 3
const A_ICON = 4
const A_ENCH = 5
const armors = {
	0: ["robe",				5, 0, 0, 18, 1.0],
	1: ["leather armour",	6, 0, 1, 19, 1.0],
	2: ["brigandine",		7, 1, 2, 20, 1.0],
	3: ["scalemail",		8, 1, 3, 21, 1.0],
	4: ["full plate",		9, 2, 4, 22, 1.0],
}

var armorsByRarity = {}

func armorsReader():
	for idx in armors.keys():
		var rarity = armors[idx][A_RAR]
		if !armorsByRarity.has(rarity):
			armorsByRarity[rarity] = []
		armorsByRarity[rarity].append(idx)

# Potions
const PO_HEALING = 0

const PO_NAME = 0
const PO_EF = 1
const PO_RAR = 2
const PO_ICON = 3
const PO_STACK = 4
const potions = {
	0: ["Potion of healing", 0, 0, 24, 0],
}
 
var potionsByRarity = {}

func potionsReader():
	for idx in potions.keys():
		var rarity = potions[idx][PO_RAR]
		if !potionsByRarity.has(rarity):
			potionsByRarity[rarity] = []
		potionsByRarity[rarity].append(idx)

# Scrolls

const SC_NAME = 0
const SC_SP = 1
const SC_RAR = 2
const SC_STACK = 3
const SC_ICON_ALL = 57
const scrolls = {
	0: ["Scroll of magic missile", SP_MAGIC_MISSILE, 0, 100],
}
 
var scrollsByRarity = {}

func scrollsReader():
	for idx in scrolls.keys():
		var rarity = scrolls[idx][SC_RAR]
		if !scrollsByRarity.has(rarity):
			scrollsByRarity[rarity] = []
		scrollsByRarity[rarity].append(idx)

# Taslimans
const TA_NAMES = 0
const TA_ICONS = 1
const TA_PROB = 2
const talismans = {
	0: [["belt"], [42, 43], 0.125],
	1: [["cloak", "cape", "mantle"], [44, 45], 0.25],
	2: [["amulet", "necklace", "medallion"], [46, 47, 52, 53], 0.50],
	3: [["ring"], [48, 49, 50, 51], 0.80],
	4: [["boots", "greaves"], [54, 55], 0.925],
	5: [["bracers"], [56], 1.0]
}

# Throwings
const TH_NAME = 0
const TH_ICON = 1
const TH_DMG = 2
const TH_SKILL = 3
const TH_EFFECT = 4
const TH_PROJ = 5
const TH_STACK = 6
const throwings = {
	0: ["Throwing knife", 	36, Vector2(1,  6), 0, null,           PROJ_WHITE_S,    200],
	1: ["Throwing axe", 	37, Vector2(1, 10), 1, null,           PROJ_WHITE_M,    201],
	2: ["Javelin", 			38, Vector2(2,  8), 2, null,           PROJ_WHITE_LONG, 202],
	3: ["Roped firebomb", 	39, null,           0, SP_TH_FIREBOMB, PROJ_WHITE_R,    203],
	4: ["Toxic flask", 		40, null,           0, SP_TH_POISON,   PROJ_WHITE_R,    204],
	5: ["Sleep flask", 		41, null,           0, SP_TH_SLEEP,    PROJ_WHITE_R,    205],
}

# Weapon enchants
const ENCH_1_WP = 0
const ENCH_2_WP = 1
const ENCH_3_WP = 2
const ENCH_FIRE_DMG = 3
const ENCH_FROST_DMG = 4
const ENCH_SHOCK_DMG = 5
const ENCH_HOLY_WP = 6
const ENCH_ANTIMAGIC_WP = 7
const ENCH_POISON_DMG = 8
const ENCH_SLAY_WP = 9
const ENCH_SPEED_WP = 50
const ENCH_VORP_WP = 51
const ENCH_ACID_DMG = 52
const ENCH_VAMPIRIC_WP = 53
const ENCH_PRECISED_WP = 54
const ENCH_FIRE_RES = 100
const ENCH_POISON_RES = 101
const ENCH_PROTECT = 200

const WP_EN_PRE = 0
const WP_EN_SUF = 1
const WP_EN_ID = 2
const wpEnchants = {
	0: [null, "+1", 0],
	1: [null, "+2", 1],
	
	100: ["flaming", "of fire", 3],
	101: ["shocking", "of shock", 5],
	102: ["blessed", "of holy wrath", 6],
	103: ["antimagic", "of dispel", 7],
	104: ["venomous", "of poison", 8],
	105: ["sharp", "of slaying", 9],
	106: ["freezing", "of frost", 4],
	
	200: ["acidic", "of acid", 52],
	201: ["vampiric", "of draining", 53],
	202: ["balanced", "of precision", 54],
	203: [null, "of speed", 50],
	204: ["vorpal", null, 51],
}

# Armor enchants
const AR_EN_SUF = 0
const AR_EN_RAR = 1
const AR_EN_ALLOWED = 2
const AR_EN_ID = 3
const arEnchants = {
	0: ["of fire resistance", 1, [0], 100],
	1: ["of poison resistance", 0, [0], 101],
}

# Talisman enchants
const TA_EN_SUF = 0
const TA_EN_RAR = 1
const TA_EN_ID = 2
const taEnchants = {
	0: ["of protection", 1, 200],
}

# Gold
const GOLD_NAME = "Gold coins"
const GOLD_ICON = 59

# Lockpick
const LOCKPICK_NAME = "Lockpick"
const LOCKPICK_ICON = 58

# Spell schools
const SC_ENCHANTEMENT = 0
const SC_EVOCATION = 1
const SC_DIVINATION = 2
const SC_ABJURATION = 3
const SC_CONJURATION = 4

# Spell lists
const SP_LIST_ARCANE = 0
const SP_LIST_DIVINE = 1
const SP_LIST_NATURE = 2

const SP_TARGET_SELF = 0
const SP_TARGET_TARGET = 1

const SP_NAME = 0
const SP_LVL = 1
const SP_SCHOOL = 2
const SP_LISTS = 3
const SP_PROJ = 4
const SP_ICON = 5
const SP_USES = 6
const SP_TARGET = 7
const SP_AREA = 8

const spells = {
	0: ["Magic Missile", 1, SC_EVOCATION, [true, false, false], PROJ_PURPLE_S, 0, 15, SP_TARGET_TARGET, 0],
	1: ["Heal", 1, SC_EVOCATION, [false, true, true], null, 2, 5, SP_TARGET_SELF, 0],
	2: ["Bless", 1, SC_ENCHANTEMENT, [false, true, true], null, 17, 10, SP_TARGET_SELF, 0],
	3: ["Fireball", 3, SC_EVOCATION, [true, false, false], PROJ_RED_L, 10, 10, SP_TARGET_TARGET, 3],
}

# Statuses
const STATUS_BLESSED = 6

const ST_NAME = 0
const ST_ICON = 1
const ST_TURNS = 2

const statuses = {
	3: ["Blinded", 3, 5],
	4: ["Might", 4, 10],
	6: ["Blessed", 6, 10],
}

# Traps
const TR_DART = 0

const TR_NAME = 0
const TR_TYPE = 1
const TR_ICON = 2
const traps = {
	0: ["Dart trap", TR_DART, 6],
}

func _ready():
	weaponsReader()
	shieldsReader()
	armorsReader()
	potionsReader()
	scrollsReader()
