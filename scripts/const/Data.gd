extends Node

# Damage types
const DMG_SLASH = 0
const DMG_BLUNT = 1
const DMG_FIRE = 2
const DMG_POISON = 3
const DMG_RADIANT = 4
const DMG_MAGIC = 5
const DMG_ICE = 6
const DMG_LIGHTNING = 7
const DMG_COLORS = [
	Colors.white,
	Colors.white,
	Colors.red,
	Colors.green,
	Colors.yellow,
	Colors.purple,
	Colors.cyan,
	Colors.yellow
]
const DMG_NAMES = [
	"slashing", "bludgeoning", "fire", "poison",
	"radiant", "magic", "cold", "shock"
]

# Saving throw
const SAVING_BASE = 4

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
const PROJ_GREEN_M = [Colors.green, 6]
const PROJ_GREEN_R = [Colors.green, 9]

# Feats
const FEAT_FIGHTER = 0
const FEAT_THIEF = 1
const FEAT_MAGE = 2
const FEAT_CLERIC = 3
const FEAT_PALADIN = 4
const FEAT_BARD = 5
const FEAT_DRUID = 6
const FEAT_RANGER = 7
const FEAT_ABJURER = 8
const FEAT_CONJURER = 9
const FEAT_DIVINER = 10
const FEAT_ENCHANTER = 11
const FEAT_SPHERE_WAR = 12
const FEAT_SPHERE_ASTRAL = 13
const FEAT_SPHERE_LAW = 14
const FEAT_ENDURANT = 100
const FEAT_TRAP_SPECIALIST = 101
const FEAT_PYROMANCER = 102
const FEAT_ARCANE_INITIATE = 104
const FEAT_DIVINE_SERVANT = 105
const FEAT_GREAT_MEMORY = 106
const FEAT_INVOKER = 107
const FEAT_TOUGH = 108
const FEAT_SHIELD_MASTER = 109
const FEAT_SAVAGE_ATTACKER = 110
const FEAT_THROWER = 111
const FEAT_SCROLL_EXPERT = 112
const FEAT_FIERCE = 113
const FEAT_RIPOSTE = 114
const FEAT_SKILLED = 200
const FEAT_SKILLED_COMBAT = 201
const FEAT_SKILLED_ARMOR = 202
const FEAT_SKILLED_EVOCATION = 203
const FEAT_SKILLED_ENCHANTMENT = 204
const FEAT_SKILLED_DIVINATION = 205
const FEAT_SKILLED_ABJURATION = 206
const FEAT_SKILLED_CONJURATION = 207
const FEAT_SKILLED_PHYSICS = 208
const FEAT_SKILLED_WILLPOWER = 209
const FEAT_SKILLED_PERCEPTION = 210
const FEAT_SKILLED_THIEVERY = 211

# Spells
const SP_MAGIC_MISSILE = 0
const SP_ELECTRIC_GRASP = 1
const SP_HEAL = 2
const SP_SMITE = 3
const SP_FIREBOLT = 4
const SP_FIREBALL = 10

const SP_SLEEP = 15
const SP_UNLOCK = 16
const SP_BLESS = 17
const SP_COMMAND = 18
const SP_LIGHT = 19

const SP_BLIND = 30
const SP_MIND_SPIKE = 31
const SP_DETECT_EVIL = 32
const SP_REVEAL_TRAPS = 33

const SP_SHIELD = 45
const SP_MAGE_ARMOR = 46
const SP_ARMOR_OF_FAITH = 47
const SP_PROTECTION_FROM_EVIL = 48
const SP_SANCTUARY = 49

const SP_ACID_SPLASH = 60
const SP_CONJURE_ANIMAL = 61
const SP_SPIRITUAL_HAMMER = 62
const SP_LESSER_AQUIREMENT = 63

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
const lvlCaps = [0, 30, 50, 75, 110, 150, 200, 275]
const skpGains = [0, 0, 2, 1, 2, 1, 2, 1, 2]
const ftpGains = [0, 0, 0, 1, 0, 1, 0, 1, 0]

# Classes
const CL_FIGHTER = 0
const CL_THIEF = 1
const CL_MAGE = 2
const CL_CLERIC = 3
const CL_PALADIN = 4
const CL_BARD = 5
const CL_DRUID = 6
const CL_RANGER = 7

const CL_NAME = 0
const CL_HP = 1
const CL_HPLVL = 2
const CL_SK = 3
const CL_SKMAS = 4
const CL_LIST = 5

# Spell lists
const SP_LIST_ARCANE = 0
const SP_LIST_DIVINE = 1
const SP_LIST_NATURE = 2

const classes = {
	#								C  A  E  E  D  A  C  P  W  P  T    C  A  E  E  D  A  C  P  W  P  T
	CL_FIGHTER: ["Fighter", 10, 5, [1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0], [2, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1], SP_LIST_ARCANE],
	CL_THIEF: 	["Thief", 	 8, 4, [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1], [2, 1, 0, 0, 0, 0, 0, 1, 1, 2, 2], SP_LIST_ARCANE],
	CL_MAGE: 	["Mage", 	 6, 3, [0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0], [0, 0, 2,-1,-1,-1,-1, 0, 2, 1, 0], SP_LIST_ARCANE],
	CL_CLERIC: 	["Cleric", 	 8, 4, [0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0], [0, 1, 2,-1,-1,-1,-1, 1, 2, 0, 0], SP_LIST_DIVINE],
	CL_PALADIN: ["Paladin", 10, 5, [1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0], [2, 2, 1, 0, 0, 1, 0, 1, 2, 0, 0], SP_LIST_DIVINE],
	CL_BARD:	["Bard", 	 8, 4, [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2], [1, 1, 0, 2, 9, 1, 0, 0, 2, 0, 2], SP_LIST_ARCANE],
	CL_DRUID:	["Druid", 	 8, 4, [0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0], [0, 1, 1, 0, 1, 2, 2, 1, 0, 2, 0], SP_LIST_NATURE],
	CL_RANGER: 	["Ranger", 	10, 5, [1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0], [2, 1, 0, 0, 1, 0, 0, 2, 0, 2, 1], SP_LIST_NATURE],
}

func classesReader():
	var classesCsv = Utils.csvToDict("CLASSES.csv")
	for idx in classesCsv.keys():
		if classes.has(idx):
			classes[idx][CL_HP] = classesCsv[idx]["HP"]
			classes[idx][CL_HPLVL] = int(classesCsv[idx]["HP"]/2)
			classes[idx][CL_SKMAS][SK_COMBAT] = classesCsv[idx]["Combat"]
			classes[idx][CL_SKMAS][SK_ARMOR] = classesCsv[idx]["Armor"]
			classes[idx][CL_SKMAS][SK_PHY] = classesCsv[idx]["Physics"]
			classes[idx][CL_SKMAS][SK_WIL] = classesCsv[idx]["Willpower"]
			classes[idx][CL_SKMAS][SK_PER] = classesCsv[idx]["Perception"]
			classes[idx][CL_SKMAS][SK_THI] = classesCsv[idx]["Thievery"]
			classes[idx][CL_SKMAS][SK_ENCH] = classesCsv[idx]["Enchantment"]
			classes[idx][CL_SKMAS][SK_EVOC] = classesCsv[idx]["Evocation"]
			classes[idx][CL_SKMAS][SK_ABJ] = classesCsv[idx]["Abjuration"]
			classes[idx][CL_SKMAS][SK_DIV] = classesCsv[idx]["Divination"]
			classes[idx][CL_SKMAS][SK_CONJ] = classesCsv[idx]["Conjuration"]

# Monsters
const MO_SKELETON = 0
const MO_GIANT_BAT = 1
const MO_GIANT_SNAKE = 2
const MO_GIANT_LEECH = 3
const MO_LESSER_SKELETON = 4
const MO_GOBLIN = 5
const MO_SPIDER = 6
const MO_SHAMAN_GOBLIN = 7
const MO_ZOMBIE = 8
const MO_SUM_WOLF = 900
const MO_SUM_HAMMER = 901 #902 903 reserved also
const MO_DUMMY = 1000

const MO_NAME = 0
const MO_HP = 1
const MO_HIT = 2
const MO_DMG = 3
const MO_CA = 4
const MO_PROT = 5
const MO_SPRITE = 6
const MO_XP = 7
const MO_MOVE = 8
const MO_CASTER_LVL = 9
const MO_WIL = 10
const MO_PHY = 11
const MO_CR = 12
const MO_ACTIONS = 13
const ACT_THROW = 0
const ACT_SPELL = 1
const ACT_BUFF = 2
const ACT_DEBUFF = 3
const ACT_HEAL = 4
const ACT_ID = 0
const ACT_TYPE = 1
const ACT_SUBTYPE = 2
const ACT_COUNT = 3
const ACT_SUBTYPE_POTION = 0
const ACT_SUBTYPE_SPELL = 1
const monsters = {
	MO_SKELETON: [
		#Name HP Hit Dmg
		"Skeleton", 6, 0, Vector3(1, 4, 0),
		#AC Prot Sprite XP MOVE
		3, 1, 2, 4, true,
		#CasterLvl WIL PHY CR
		1, 0, 0, 1,
		[
			[0, ACT_THROW, null, 2],
			[SP_BLESS, ACT_BUFF, ACT_SUBTYPE_SPELL, 1],
			[SP_FIREBOLT, ACT_SPELL, ACT_SUBTYPE_SPELL, 5],
		]
	],
	MO_GIANT_BAT: [
		"Giant bat", 4, -1, Vector3(1, 1, 0),
		3, 0, 8, 4, true,
		1, 0, 0, 1,
		[]
	],
	MO_GIANT_SNAKE: [
		"Giant snake", 4, -1, Vector3(1, 1, 0),
		3, 0, 29, 4, true,
		1, 0, 0, 1,
		[]
	],
	MO_GIANT_LEECH: [
		"Giant leech", 4, -1, Vector3(1, 1, 0),
		3, 0, 25, 4, true,
		1, 0, 0, 2,
		[]
	],
	MO_LESSER_SKELETON: [
		"Lesser skeleton", 4, -1, Vector3(1, 1, 0),
		3, 0, 30, 4, true,
		1, 0, 0, 2,
		[]
	],
	MO_GOBLIN: [
		"Goblin", 4, -1, Vector3(1, 1, 0),
		3, 0, 1, 4, true,
		1, 0, 0, 3,
		[]
	],
	MO_SPIDER: [
		"Spider", 4, -1, Vector3(1, 1, 0),
		3, 0, 3, 4, true,
		1, 0, 0, 4,
		[]
	],
	MO_SHAMAN_GOBLIN: [
		"Shaman goblin", 4, -1, Vector3(1, 1, 0),
		3, 0, 5, 4, true,
		1, 0, 0, 5,
		[]
	],
	MO_ZOMBIE: [
		"Zombie", 4, -1, Vector3(1, 1, 0),
		3, 0, 22, 4, true,
		1, 0, 0, 5,
		[]
	],
	MO_SUM_WOLF: [
		"Conjured wolf", 10, 0, Vector3(1, 6, 0),
		2, 0, 24, 0, true,
		1, 0, 0, 1,
		[]
	],
	MO_SUM_HAMMER: [
		"Spiritual hammer", 4, 1, Vector3(1, 4, 0),
		4, 2, 28, 0, true,
		1, 0, 0, 1,
		[]
	],
	MO_SUM_HAMMER+1: [
		"Spiritual hammer II", 4, 1, Vector3(1, 4, 0),
		4, 2, 28, 0, true,
		1, 0, 0, 1,
		[]
	],
	MO_SUM_HAMMER+2: [
		"Spiritual hammer III", 4, 1, Vector3(1, 4, 0),
		4, 2, 28, 0, true,
		1, 0, 0, 1,
		[]
	],
	MO_DUMMY: [
		"Dummy target", 100, 0, Vector3(1, 1, 0),
		2, 1, 1, 10, false,
		1, 0, 0, 1,
		[]
	],
}

const monsterTags = {
	MO_SKELETON: ["evil", "undead"],
	MO_SUM_WOLF: ["animal", "summoned"],
	MO_SUM_HAMMER: ["animated", "summoned"]
}

func monstersReader():
	var statsCsv = Utils.csvToDict("MONSTER_STATS.csv")
	var monstersCsv = Utils.csvToDict("MONSTERS.csv")
	for idx in monstersCsv.keys():
		if monsters.has(idx):
			monsters[idx][MO_NAME] = monstersCsv[idx]["Name"]
			monsters[idx][MO_CR] = monstersCsv[idx]["CR"]
			monsters[idx][MO_HP] = statsCsv[monsters[idx][MO_CR]]["HP-" + monstersCsv[idx]["Hp"]]
			monsters[idx][MO_HIT] = statsCsv[monsters[idx][MO_CR]]["Hit-" + monstersCsv[idx]["Hit"]]
			monsters[idx][MO_DMG].x = Utils.diceToVector(monstersCsv[idx]["Damages"])
			#Damage type
			#monsters[idx][MO_HP] = statsCsv[monsters[idx][MO_CR]]["HP-" + monstersCsv[idx]["Hp"]]
			monsters[idx][MO_CA] = statsCsv[monsters[idx][MO_CR]]["AC-" + monstersCsv[idx]["AC"]]
			monsters[idx][MO_PROT] = statsCsv[monsters[idx][MO_CR]]["Prot-" + monstersCsv[idx]["Prot"]]
			monsters[idx][MO_CASTER_LVL] = statsCsv[monsters[idx][MO_CR]]["Save-" + monstersCsv[idx]["Save"]]
			monsters[idx][MO_PHY] = statsCsv[monsters[idx][MO_CR]]["PHY-" + monstersCsv[idx]["PHY"]]
			monsters[idx][MO_WIL] = statsCsv[monsters[idx][MO_CR]]["PHY-" + monstersCsv[idx]["WIL"]]

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
const CHAR_R_SLASH = 11
const CHAR_R_BLUNT = 12
const CHAR_R_FIRE = 13
const CHAR_R_POISON = 14
const CHAR_R_RADIANT = 15
const CHAR_R_MAGIC = 16
const CHAR_R_ICE = 17
const CHAR_R_LIGHTNING = 18

# Weapons
const W_CLUB = 0
const W_DAGGER = 1
const W_HATCHET = 2
const W_MACE = 3
const W_SHORTSWORD = 4
const W_AXE = 5
const W_STAFF = 100
const W_GREATCLUB = 101
const W_FELLING_AXE = 102
const W_MAUL = 103
const W_BROADSWORD = 104

const W_NAME = 0
const W_HIT = 1 #Not used
const W_DMG = 2
const W_TYPE = 3
const W_RAR = 4
const W_2H = 5
const W_ICON = 6

const weapons = {
	W_CLUB: 		["club",		null, Vector2(1,  4), "B", 0, false,  0],
	W_DAGGER:		["dagger",		null, Vector2(1,  4), "S", 1, false,  1],
	W_HATCHET: 		["hatchet",		null, Vector2(1,  6), "S", 1, false,  2],
	W_MACE: 		["mace",		null, Vector2(1,  8), "B", 2, false,  3],
	W_SHORTSWORD: 	["shortsword",	null, Vector2(2,  4), "S", 3, false,  4],
	W_AXE: 			["hand axe",	null, Vector2(1, 10), "S", 4, false,  5],
	6: 				["longsword",	null, Vector2(2, 10), "S", 5, false,  6],
	7: 				["morning star",null, Vector2(3,  6), "S", 6, false,  7],
	
	W_STAFF: 		["staff",		null, Vector2(1,  6), "B", 0, true,  8],
	W_GREATCLUB: 	["greatclub",	null, Vector2(1,  8), "B", 1, true,  9],
	W_FELLING_AXE:	["felling axe",	null, Vector2(1, 12), "S", 2, true, 10],
	W_MAUL: 		["maul",		null, Vector2(2,  6), "B", 3, true, 11],
	W_BROADSWORD: 	["broadsword",	null, Vector2(3,  4), "S", 4, true, 12],
	13:				["halberd",		null, Vector2(3, 10), "S", 5, true, 13],
	14:				["greataxe",	null, Vector2(3, 12), "S", 6, true, 14],
	15:				["zweihander",	null, Vector2(4,  8), "S", 6, true, 15],
}

const weaponDescriptions = {
	-1: "A rusty weapon.",
	W_CLUB: "A stick made of wood with a large knob on the end.",
	W_DAGGER: "A short double-edged knife with a sharp point.",
	W_HATCHET: "A small and light axe, it's a tool more than a weapon.",
	W_MACE: "A metal club with a heavy head on the end.",
	W_SHORTSWORD: "A slashing weapon with a short sharp blade.",
	W_AXE: "A strong crescent-shaped battle axe.",
	
	W_STAFF: "A shaft made of hardwood, sometimes infused with magic.",
	W_GREATCLUB: "A club but large enough to be used two-handed.",
	W_FELLING_AXE: "An axe with a strong blade designed to chop wood.",
	W_MAUL: "A long-handled hammer with a heavy head.",
	W_BROADSWORD: "A heavy blade designed to be used two-handed.",
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

const SH_BUCKLER = 0
const SH_TARGE = 1
const SH_SHIELD = 2

const shields = {
	SH_BUCKLER: 	["Buckler",       1, 1, 1, 0, 1.0, 33],
	SH_TARGE: 		["Round shield",  1, 2, 2, 2, 1.0, 34],
	SH_SHIELD: 		["Heater shield", 1, 3, 4, 4, 1.0, 35]
}

const shieldDescriptions = {
	-1: "A rusty shield.",
	SH_BUCKLER: "Small round shield made of wood and leather.",
	SH_TARGE: "A round wooden shield covered by a thin layer of bronze.",
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
const A_HELM = 6

const A_ROBE = 0
const A_PADDED = 1
const A_LEATHER = 2
const A_BRIGANDINE = 3
const A_CAP = 10
const A_HELMET = 11

const armors = {
	A_ROBE: 		["Robe",				2, 0, 0, 18, 1.0, false],
	A_PADDED: 		["Padded armour",	3, 0, 0, 19, 1.0, false],
	A_LEATHER: 		["Leather armour",	4, 1, 1, 20, 1.0, false],
	A_BRIGANDINE: 	["Brigandine",		4, 1, 2, 21, 1.0, false],
	4: ["Scalemail",		5, 2, 3, 22, 1.0, false],
	5: ["Full plate",		5, 3, 4, 23, 1.0, false],
	
	A_CAP: 			["Leather cap",		0, 1, 0, 16, 1.0, true],
	A_HELMET: 		["Horned helm",		1, 1, 4, 17, 1.0, true],
}

const armorDescriptions = {
	-1: "A rusty armor.",
	A_ROBE: "A simple clothing made of fabric.",
	A_PADDED: "A jacket made of whool, stuffed to offer minor protection.",
	A_LEATHER: "A light armor covered with thin layers of animal hide.",
	A_BRIGANDINE: "A sturdy armor made of cloth with riveted steel plates.",
	
	A_CAP: "A simple helmet made of hardened leather and fur.",
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
	PO_HEALING: ["Potion of healing", 0, 0, 24, 0],
}

const potionDescriptions = {
	PO_HEALING: "Restores 50% of your total HP (rounds down)."
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
const SC_RANK = 2
const SC_RAR = 3
const SC_STACK = 4
const SC_ICON_ALL = 57

const SC_MAGIC_MISSILE = 0

const scrolls = {
	SC_MAGIC_MISSILE: ["Scroll of magic missile", SP_MAGIC_MISSILE, 2, 0, 100],
}

const scrollDescriptions = {
	SC_MAGIC_MISSILE: "Fires arcane projectiles to random targets, each dealing %%DMG_1 damages. No saving throw."
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
	0: [["Belt"], [42, 43], 0.125],
	1: [["Cloak", "Cape", "Mantle"], [44, 45], 0.25],
	2: [["Amulet", "Necklace", "Medallion"], [46, 47, 52, 53], 0.50],
	3: [["Ring"], [48, 49, 50, 51], 0.80],
	4: [["Boots", "Greaves"], [54, 55], 0.925],
	5: [["Bracers"], [56], 1.0]
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

# Starting kits
const KIT_WP = 0
const KIT_SH = 1
const KIT_AR = 2
const KIT_PO = 3
const KIT_SC = 4
const KIT_TH = 5
const KIT_GO = 6
const KIT_LO = 7

const KIT_UNDEF = [-1, -1, -1, [], [], [], 0, 0]
const KIT_FIGHTER = [3, 0, 1, [0, 0], [], [0, 0, 0], 30, 2]
const KIT_THIEF =	[1,-1, 1, [0, 0], [], [0, 0, 0], 45, 3]
const KIT_MAGE = 	[8,-1, 0, [0, 0], [0], [], 30, 2]
const KIT_CLERIC = 	[0, 0, 1, [0, 0], [], [], 30, 2]
const KIT_PALADIN = [9,-1, 1, [0, 0], [], [], 30, 2]

const CLASS_KITS = {
	-1: KIT_UNDEF,
	CL_FIGHTER: KIT_FIGHTER,
	CL_THIEF: KIT_THIEF,
	CL_BARD: KIT_THIEF,
	CL_MAGE: KIT_MAGE,
	CL_DRUID: KIT_MAGE,
	CL_CLERIC: KIT_CLERIC,
	CL_RANGER: KIT_PALADIN,
	CL_PALADIN: KIT_PALADIN,
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
const ENCH_PRECISE_WP = 54
const ENCH_FIRE_RES = 100
const ENCH_POISON_RES = 101
const ENCH_PHY_SAVE = 200
const ENCH_WIL_SAVE = 201
# Armor enchants
const ENCH_1_AR = 1000
const ENCH_2_AR = 1001
const ENCH_3_AR = 1002
const ENCH_FIRE_RESIST = 1003
const ENCH_POISON_RESIST = 1004
# Talisman enchants

const WP_EN_PRE = 0
const WP_EN_SUF = 1
const WP_EN_RAR = 2
const WP_EN_ID = 3
const wpEnchants = {
	ENCH_1_WP: [null, "+1", 3, 0],
#	ENCH_2_WP: [null, "+2", 1],
#	ENCH_3_WP: [null, "+3", 2],
	
	ENCH_FIRE_DMG: 	["flaming", "of fire", 1, 3],
	ENCH_SHOCK_DMG: ["shocking", "of shock", 1, 5],
	ENCH_HOLY_WP: 	["blessed", "of holy wrath", 2, 6],
#	103: ["antimagic", "of dispel", 2, 7],
	ENCH_POISON_DMG:["venomous", "of poison", 1, 8],
#	105: ["sharp", "of slaying", 0, 9],
	ENCH_FROST_DMG: ["freezing", "of frost", 1, 4],
	
#	200: ["acidic", "of acid", 1, 52],
#	201: ["vampiric", "of draining", 4, 53],
	ENCH_PRECISE_WP:["balanced", "of precision", 3, 54],
#	203: [null, "of speed", 50],
	ENCH_VORP_WP: 	["vorpal", null, 4, 51],
}

# Armor enchants
const AR_EN_SUF = 0
const AR_EN_RAR = 1
const AR_EN_ID = 2
const arEnchants = {
	ENCH_1_AR: ["+1", 3, 1001],
#	ENCH_2_AR: ["+2", 1, 1002],
#	ENCH_3_AR: ["+3", 2, 1003],
	
	ENCH_FIRE_RES: 	["of fire resistance", 1, 1004],
	ENCH_POISON_RES:["of poison resistance", 0, 1005],
	ENCH_PHY_SAVE:	["of endurance", 2, 1005],
	ENCH_WIL_SAVE: 	["of willpower", 3, 1005],
}

# Talisman enchants
const TA_EN_SUF = 0
const TA_EN_RAR = 1
const TA_EN_ID = 2
const taEnchants = {
	0: ["of protection", 1, 2000],
}

# Gold
const GOLD_NAME = "Gold coins"
const GOLD_ICON = 59

# Lockpick
const LOCKPICK_NAME = "Lockpick"
const LOCKPICK_ICON = 58

# Spell schools
const SC_ENCHANTMENT = 0
const SC_EVOCATION = 1
const SC_DIVINATION = 2
const SC_ABJURATION = 3
const SC_CONJURATION = 4

const SP_NAME = 0
const SP_LVL = 1
const SP_SCHOOL = 2
const SP_LISTS = 3
const SP_PROJ = 4
const SP_ICON = 5
const SP_USES = 6
const SP_TARGET = 7
const SP_TARGET_SELF = 0
const SP_TARGET_TARGET = 1
const SP_TARGET_DIRECT = 2
const SP_TARGET_ITEM_CHOICE = 3
const SP_TARGET_RANDOM = 4
const SP_AREA = 8
const SP_SAVE = 9
const SAVE_WIL = 0
const SAVE_PHY = 1
const SAVE_NO = 2

const spells = {
	# Evocation
	SP_MAGIC_MISSILE: 	["Magic missile", 1, SC_EVOCATION, [true, false, false], PROJ_PURPLE_S, 0, [20, 20, 20], SP_TARGET_RANDOM, 0, SAVE_NO],
	SP_ELECTRIC_GRASP: 	["Shocking grasp", 1, SC_EVOCATION, [true, false, true], null, 1, [10, 10, 10], SP_TARGET_DIRECT, 1, SAVE_PHY],
	SP_HEAL: 			["Heal", 1, SC_EVOCATION, [false, true, true], null, 2, [5, 5, 5], SP_TARGET_SELF, 0, SAVE_NO],
	SP_SMITE: 			["Sunscorch", 1, SC_EVOCATION, [false, true, false], null, 3, [10, 10, 10], SP_TARGET_DIRECT, 1, SAVE_PHY],
	SP_FIREBOLT: 		["Fire bolt", 1, SC_EVOCATION, [true, false, false], PROJ_RED_L, 4, [15, 15, 15], SP_TARGET_TARGET, 0, SAVE_PHY],
	SP_FIREBALL: 		["Fireball", 3, SC_EVOCATION, [true, false, false], PROJ_RED_R, 10, [10, 10, 10], SP_TARGET_TARGET, 3, SAVE_PHY],
	# Enchantment
	SP_SLEEP:	 		["Sleep", 1, SC_ENCHANTMENT, [true, false, true], null, 15, [8, 8, 8], SP_TARGET_TARGET, 0, SAVE_WIL],
	SP_UNLOCK:	 		["Unlock", 1, SC_ENCHANTMENT, [true, false, false], null, 16, [5, 10, 15], SP_TARGET_DIRECT, 1, SAVE_NO],
	SP_BLESS: 			["Bless", 1, SC_ENCHANTMENT, [false, true, true], null, 17, [15, 15, 15], SP_TARGET_SELF, 0, SAVE_NO],
	SP_COMMAND:	 		["Command", 1, SC_ENCHANTMENT, [false, true, false], null, 18, [5, 5, 5], SP_TARGET_TARGET, 0, SAVE_WIL],
	SP_LIGHT:	 		["Light", 1, SC_ENCHANTMENT, [true, true, true], null, 19, [20, 20, 20], SP_TARGET_SELF, 0, SAVE_NO],
	# Divination
	SP_BLIND: 			["Blind", 1, SC_DIVINATION, [true, false, true], null, 30, [15, 15, 15], SP_TARGET_TARGET, 0, SAVE_PHY],
	SP_MIND_SPIKE: 		["Mind spike", 1, SC_DIVINATION, [false, true, false], null, 31, [10, 10, 10], SP_TARGET_TARGET, 0, SAVE_WIL],
	SP_DETECT_EVIL:		["Detect evil", 1, SC_DIVINATION, [false, true, true], null, 32, [10, 10, 10], SP_TARGET_SELF, 0, SAVE_NO],
	SP_REVEAL_TRAPS:	["Find traps", 1, SC_DIVINATION, [true, true, true], null, 33, [5, 10, 15], SP_TARGET_SELF, 0, SAVE_NO],
	# Abjuration
	SP_SHIELD:			["Shield", 1, SC_ABJURATION, [true, false, false], null, 45, [5, 5, 5], SP_TARGET_SELF, 0, SAVE_NO],
	SP_MAGE_ARMOR:		["Mage armor", 1, SC_ABJURATION, [true, false, false], null, 46, [15, 15, 15], SP_TARGET_SELF, 0, SAVE_NO],
	SP_ARMOR_OF_FAITH:	["Armor of faith", 1, SC_ABJURATION, [false, true, false], null, 47, [10, 10, 10], SP_TARGET_SELF, 0, SAVE_NO],
	SP_PROTECTION_FROM_EVIL:["Protection from evil", 1, SC_ABJURATION, [false, true, true], null, 49, [10, 10, 10], SP_TARGET_SELF, 0, SAVE_NO],
	SP_SANCTUARY:		["Sanctuary", 1, SC_ABJURATION, [false, true, true], null, 48, [5, 5, 5], SP_TARGET_SELF, 0, SAVE_NO],
	# Conjuration
	SP_ACID_SPLASH: 	["Acid arrow", 1, SC_CONJURATION, [true, false, true], PROJ_GREEN_M, 60, [15, 15, 15], SP_TARGET_TARGET, 0, SAVE_PHY],
	SP_CONJURE_ANIMAL:	["Conjure animals", 1, SC_CONJURATION, [true, false, true], null, 61, [5, 5, 5], SP_TARGET_SELF, 0, SAVE_NO],
	SP_SPIRITUAL_HAMMER:["Spiritual hammer", 1, SC_CONJURATION, [false, true, false], null, 62, [5, 5, 5], SP_TARGET_SELF, 0, SAVE_NO],
	SP_LESSER_AQUIREMENT:["Lesser acquirement", 1, SC_CONJURATION, [true, true, false], null, 63, [5, 5, 5], SP_TARGET_ITEM_CHOICE, 0, SAVE_NO],
}

const spellDamages = {
	SP_MAGIC_MISSILE: [[1, 4, 1, DMG_MAGIC], [1, 4, 1, DMG_MAGIC], [1, 4, 1, DMG_MAGIC]],
	SP_ELECTRIC_GRASP: [[1, 12, 0, DMG_LIGHTNING], [1, 12, 0, DMG_LIGHTNING], [2, 12, 0, DMG_LIGHTNING]],
	SP_HEAL: [[1, 6, 0, DMG_MAGIC], [1, 8, 0, DMG_MAGIC], [1, 10, 0, DMG_MAGIC]],
	SP_SMITE: [[1, 8, 1, DMG_RADIANT], [1, 10, 2, DMG_RADIANT], [1, 12, 3, DMG_RADIANT]],
	SP_FIREBOLT: [[1, 10, 0, DMG_FIRE], [1, 10, 2, DMG_FIRE], [1, 10, 4, DMG_FIRE]],
	SP_FIREBALL: [[], [], [3, 6, 0, DMG_FIRE]],
	SP_MIND_SPIKE: [[1, 8, 0, DMG_MAGIC], [1, 8, 2, DMG_MAGIC], [1, 8, 4, DMG_MAGIC]],
	SP_ACID_SPLASH: [[2, 4, 0, DMG_SLASH], [3, 4, 0, DMG_SLASH], [4, 4, 0, DMG_SLASH]],
}

const spellTurns = {
	SP_SLEEP: [15, 15, 15],
	SP_BLESS: [15, 15, 15],
	SP_COMMAND: [5, 5, 5],
	SP_LIGHT: [40, 40, 40],
	SP_BLIND: [15, 15, 15],
	SP_DETECT_EVIL: [40, 40, 40],
	SP_REVEAL_TRAPS: [40, 40, 40],
	SP_SHIELD: [25, 25, 25],
	SP_ARMOR_OF_FAITH: [100, 100, 100],
	SP_PROTECTION_FROM_EVIL: [25, 25, 25],
	SP_SANCTUARY: [15, 15, 15],
	SP_SPIRITUAL_HAMMER: [40, 40, 40],
}

var spellDescriptions = {
	SP_MAGIC_MISSILE: [
		"Fires arcane projectiles to random targets, each dealing %%DMG_1 damages. No saving throw.",
		"Fires two projectiles.",
		"Fires three projectiles.",
		"Fires four projectiles."
	],
	SP_ELECTRIC_GRASP: [
		"Gives a powerful electrical jolt to %%CONTACT.",
		"%%D_DMG_1",
		"Also inflicts [PARALYZED] the target for two turns.",
		"%%INC_DMG_3"
	],
	SP_HEAL: [
		"Conjures healing energies to cure your wounds.",
		"Heals you for %%DMGN_1 damages.",
		"Increases healing to %%DMGN_2.",
		"Increases healing to %%DMGN_3."
	],
	SP_SMITE: [
		"Conjures a beam of sunlight to damage %%LINE.",
		"%%D_DMG_1",
		"%%INC_DMG_2",
		"%%INC_DMG_3"
	],
	SP_FIREBOLT: [
		"Fires a bolt of flame to %%TARGET.",
		"%%D_DMG_1",
		"%%INC_DMG_2",
		"%%INC_DMG_3"
	],
	SP_SLEEP: [
		"Forces a creature to fall asleep. Any damage will break the spell.",
		"Inflicts [SLEEP] for %%TURNS_1 to a creature at range.",
		"Also targets all creatures at range 1.",
		"Also targets all creatures at range 3."
	],
	SP_UNLOCK: [
		"Magically opens a locked door or chest.",
		"%%USES_1.",
		"%%USES_2.",
		"%%USES_3."
	],
	SP_BLESS: [
		"Bless you with divine energy to improve all your save rolls.",
		"Gives [BLESS] (+1 to all save rolls) for %%TURNS_1.",
		"Lasts for %%TURNS_2.",
		"Lasts for %%TURNS_3.",
	],
	SP_COMMAND: [
		"Enables you to command another creature with a single word. Applies [TERROR].",
		"Lasts %%TURNS_1.",
		"Lasts %%TURNS_2.",
		"Lasts %%TURNS_3.",
	],
	SP_LIGHT: [
		"Surrounds you with a floating light that follows you for %%TURNS_1.",
		"Gives you [LIGHT] (+1 range).",
		"Gives you [LIGHT II] (+1 perception rolls).",
		"Lasts until rest.",
	],
	SP_BLIND: [
		"Causes the target to become blind for %%TURNS_1.",
		"Inflicts [BLIND] (-1 to hit rolls -3 to range) to %%TARGET.",
		"Also targets all creatures at range 1.",
		"Also targets all creatures at range 3.",
	],
	SP_MIND_SPIKE: [
		"Reaches another creature's mind to damage it.",
		"%%D_DMG_1",
		"%%INC_DMG_2",
		"%%INC_DMG_3"
	],
	SP_DETECT_EVIL: [
		"Detects all evil creatures (undeads and demons) on the current floor. No saving throw.",
		"Gives [DETECT EVIL] for %%TURNS_1.",
		"Inflicts [VULNERABLE] (ignore prot) to revealed creatures.",
		"%%USES_3."
	],
	SP_REVEAL_TRAPS: [
		"Reveals all traps on the current floor. Lasts %%TURNS_1.",
		"%%USES_1.",
		"%%USES_2.",
		"%%USES_3."
	],
	SP_SHIELD: [
		"Protects you with an invisible barrier that absorbs incoming damages.",
		"Gives you [SHIELD] (absorb 10 damages) for %%TURNS_1.",
		"Absorbs 15 damages.",
		"Absorbs 20 damages."
	],
	SP_MAGE_ARMOR: [
		"Creates a magical field of force that replaces your armor. Lasts until rest.",
		"Gives you [MAGE ARMOR] (set your AC to 4).",
		"Set your AC to 5.",
		"Set your AC to 6."
	],
	SP_ARMOR_OF_FAITH: [
		"Invokes divine forces to protect you during %%TURNS_1.",
		"Gives you [PROTECTION] (+1 CA).",
		"Gives you [PROTECTION II] (+1 CA +1 protection).",
		"Lasts until rest."
	],
	SP_PROTECTION_FROM_EVIL: [
		"Protects you from spells casted by evil creatures (undeads and demons). Lasts %%TURNS_1.",
		"Gives you [PROTECTION FROM EVIL] (+1 to all saves).",
		"Lasts %%TURNS_2.",
		"Increases bonus to +2."
	],
	SP_SANCTUARY: [
		"Prevent any creatures to harm you until you attack, drink a potion or cast a spell.",
		"Gives you [SANCTUARY] for %%TURNS_1.",
		"You can drink potions.",
		"You can cast spells on yourself."
	],
	SP_ACID_SPLASH: [
		"Creates a magic arrow that inflicts acid damages to %%TARGET. It bypass protection and resistances.",
		"%%D_DMG_1",
		"%%INC_DMG_2",
		"%%INC_DMG_3"
	],
	SP_CONJURE_ANIMAL: [
		"Conjures a wolf to fight by your side.",
		"Conures 1d2 wolves.",
		"Conures 1d2+1 wolves.",
		"Conures 1d2+2 wolves.",
	],
	SP_SPIRITUAL_HAMMER: [
		"Conjures an animated hammer that will fight your enemies.",
		"Convokes a hamer for %%TURNS_1.",
		"Improves the hammer.",
		"Improves the hammer."
	],
	SP_LESSER_AQUIREMENT: [
		"Creates a small object from nothing.",
		"Creates a weapon, an armor, a scroll, a potion or golds.",
		"Improves object quality.",
		"Improves object quality."
	]
}

const spellsPerSchool: Dictionary = {}

func spellsReader():
	for idx in spells.keys():
		var school = spells[idx][SP_SCHOOL]
		var rank = spells[idx][SP_LVL]
		var list = spells[idx][SP_LISTS]
		for l in range(3):
			if not list[l]:
				continue
			if !spellsPerSchool.has(l):
				spellsPerSchool[l] = {}
			if !spellsPerSchool[l].has(school):
				spellsPerSchool[l][school] = {}
			if !spellsPerSchool[l][school].has(rank):
				spellsPerSchool[l][school][rank] = []
			spellsPerSchool[l][school][rank].append(idx)

# Statuses
const STATUS_SLEEP = 0
const STATUS_TERROR = 1
const STATUS_BLIND = 2
const STATUS_PARALYZED = 3
const STATUS_VULNERABLE = 4

const STATUS_LIGHT = 100
const STATUS_DETECT_EVIL = 101
const STATUS_REVEAL_TRAPS = 102
const STATUS_BLESSED = 103
const STATUS_SHIELD = 104
const STATUS_MAGE_ARMOR = 105
const STATUS_ARMOR_FAITH = 106
const STATUS_PROTECT_EVIL = 107
const STATUS_SANCTUARY = 108

const STATUS_FIRE_WEAPON = 1000 + ENCH_FIRE_DMG
const STATUS_FROST_WEAPON = 1000 + ENCH_FROST_DMG
const STATUS_POISON_WEAPON = 1000 + ENCH_POISON_DMG
const STATUS_SHOCK_WEAPON = 1000 + ENCH_SHOCK_DMG
const STATUS_HOLY_WEAPON = 1000 + ENCH_HOLY_WP
const STATUS_PRECISE_WEAPON = 1000 + ENCH_PRECISE_WP
const STATUS_VORPAL_WEAPON = 1000 + ENCH_VORP_WP
const STATUS_SLASH_RESIST = 10000 + DMG_SLASH
const STATUS_BLUNT_RESIST = 10000 + DMG_BLUNT
const STATUS_FIRE_RESIST = 10000 + DMG_FIRE
const STATUS_POISON_RESIST = 10000 + DMG_POISON
const STATUS_RADIANT_RESIST = 10000 + DMG_RADIANT
const STATUS_MAGIC_RESIST = 10000 + DMG_MAGIC
const STATUS_ICE_RESIST = 10000 + DMG_ICE
const STATUS_LIGHTNING_RESIST = 10000 + DMG_LIGHTNING
#const STATUS_FEAT_FIGHTER = 20000 + FEAT_FIGHTER
#const STATUS_FEAT_THIEF = 20000 + FEAT_THIEF
#const STATUS_FEAT_PALADIN = 20000 + FEAT_PALADIN
#const STATUS_FEAT_BARD = 20000 + FEAT_BARD
#const STATUS_FEAT_DRUID = 20000 + FEAT_DRUID
#const STATUS_FEAT_RANGER = 20000 + FEAT_RANGER

const statusesDescriptions = {
	STATUS_SLEEP: [
		"You fell into a magical slumber. You cannot act but any damage will wake you up."
	],
	STATUS_TERROR: [
		"A deep fear and distress prevent you to move. You cannot act."
	],
	STATUS_BLIND: [
		"Your vision is dimished drastically. You have a -1 penalty to your HIT dice rolls and your range is reduced to 3."
	],
	STATUS_PARALYZED: [
		"Your muscles don't respond to your commands. You cannot act."
	],
	STATUS_VULNERABLE: [
		"Your defences are breached. Any attack will bypass your PROT."
	],
	
	STATUS_LIGHT: [
		"A floating glow follows you, enlighting your surroundings. It grants you +1 range.",
		"A floating glow follows you, enlighting your surroundings. It grants you +1 range and +1 to perception rolls.",
	],
	STATUS_DETECT_EVIL: [
		"You detect the negative aura of evil enemies (undeads and demons). They appear on you map.",
		"You detect the negative aura of evil enemies (undeads and demons). They appear on you ma and they are vulnerables to your attacks.",
	],
	STATUS_REVEAL_TRAPS: [
		"All traps appear on your map, and you reveal them when they are in sight."
	],
	STATUS_BLESSED: [
		"A sacred blessing stands upoon your, protecting yourself against spells. It grants you +1 to all save rolls."
	],
	STATUS_SHIELD: [
		"A magical shield protects you against attacks. I will absorb as much incoming damages as its rank."
	],
	STATUS_MAGE_ARMOR: [
		"A protective force surrounds you and replace your armor. Set your AC to 4 if it's lower.",
		"A protective force surrounds you and replace your armor. Set your AC to 5 if it's lower.",
		"A protective force surrounds you and replace your armor. Set your AC to 6 if it's lower.",
	],
	STATUS_ARMOR_FAITH: [
		"A shimmering field srurrounds you and protect you. It grants +1 AC.",
		"A shimmering field srurrounds you and protect you. It grants +1 AC and +1 PROT.",
	],
	STATUS_PROTECT_EVIL: [
		"You are  protected aginst spells casted evil creatures (undeads and demons). You gains +1 to save rolls against such spells.",
		"You are  protected aginst spells casted evil creatures (undeads and demons). You gains +2 to save rolls against such spells.",
	],
	STATUS_SANCTUARY: [
		"You are protected by a divine barrier preventing any attack against you. The shield disappears if you attack, drink a potion or cast a spell.",
		"You are protected by a divine barrier preventing any attack against you. The shield disappears if you attack or cast a spell.",
		"You are protected by a divine barrier preventing any attack against you. The shield disappears if you attack or cast a spell on omebody else.",
	],
}

const statusPrefabs = {
	STATUS_SLEEP: ["Sleep", 7, null, null, STATUS_SLEEP, null, null, false],
	STATUS_TERROR: ["Terror", 2, null, null, STATUS_TERROR, null, null, false],
	STATUS_BLIND: ["Blind", 3, null, null, STATUS_BLIND, null, null, false],
	STATUS_PARALYZED: ["Paralyzed", 14, null, null, STATUS_PARALYZED, null, null, false],
	
	STATUS_LIGHT: ["Light", 23, null, null, STATUS_LIGHT, null, null, false],
	STATUS_DETECT_EVIL: ["Detect evil", 9, null, null, STATUS_DETECT_EVIL, null, null, false],
	STATUS_REVEAL_TRAPS: ["Find traps", 15, null, null, STATUS_REVEAL_TRAPS, null, null, false],
	STATUS_BLESSED: ["Blessed", 11, null, null, STATUS_BLESSED, null, null, false],
	STATUS_SHIELD: ["Shield", 39, null, null, STATUS_SHIELD, null, null, false],
	STATUS_MAGE_ARMOR: ["Mage armor", 27, null, null, STATUS_MAGE_ARMOR, null, null, false],
	STATUS_ARMOR_FAITH: ["Armor of faith", 5, null, null, STATUS_ARMOR_FAITH, null, null, false],
	STATUS_PROTECT_EVIL: ["Protection from evil", 41, null, null, STATUS_PROTECT_EVIL, null, null, false],
	STATUS_SANCTUARY: ["Sanctuary", 33, null, null, STATUS_SANCTUARY, null, null, false],
}

const FE_NAME = 0
const FE_CHOOSE = 1
const FE_SUBS = 2

const feats = {
	FEAT_FIGHTER: ["Trained soldier", false, []],
	FEAT_THIEF: ["Nimble fingers", false, []],
	FEAT_MAGE: ["Specialization", false, [FEAT_ABJURER, FEAT_CONJURER, FEAT_DIVINER, FEAT_ENCHANTER]],
	FEAT_CLERIC: ["Sphere", false, [FEAT_SPHERE_WAR, FEAT_SPHERE_ASTRAL, FEAT_SPHERE_LAW]],
	FEAT_PALADIN: ["Holy warrior", false, []],
	FEAT_BARD: ["Ancient knowledge", false, []],
	FEAT_DRUID: ["Force of nature", false, []],
	FEAT_RANGER: ["Woodman", false, []],
	
	FEAT_ABJURER: ["Abjurer", false, []],
	FEAT_ENCHANTER: ["Enchanter", false, []],
	FEAT_CONJURER: ["Conjurer", false, []],
	FEAT_DIVINER: ["Diviner", false, []],
	
	FEAT_SPHERE_WAR: ["War sphere", false, []],
	FEAT_SPHERE_ASTRAL: ["Astral sphere", false, []],
	FEAT_SPHERE_LAW: ["Law sphere", false, []],
	
	FEAT_ENDURANT: ["Endurant", true, []],
	FEAT_TRAP_SPECIALIST: ["Trap specialist", true, []],
	FEAT_PYROMANCER: ["Pyromancer", true, []],
	FEAT_ARCANE_INITIATE: ["Arcane initiate", true, []],
	FEAT_DIVINE_SERVANT: ["Divine servant", true, []],
	FEAT_GREAT_MEMORY: ["Great memory", true, []],
	FEAT_INVOKER: ["Invoker", true, []],
	FEAT_TOUGH: ["Tough", true, []],
	FEAT_SHIELD_MASTER: ["Shield master", true, []],
	FEAT_SAVAGE_ATTACKER: ["Savge attacker", true, []],
	FEAT_THROWER: ["Thrower", true, []],
	FEAT_SCROLL_EXPERT: ["Scroll expert", true, []],
	FEAT_FIERCE: ["Fierce", true, []],
	FEAT_RIPOSTE: ["Riposte", true, []],
	
	FEAT_SKILLED: ["Skilled", true, [
		FEAT_SKILLED_COMBAT, FEAT_SKILLED_ARMOR, FEAT_SKILLED_EVOCATION,
		FEAT_SKILLED_ENCHANTMENT, FEAT_SKILLED_DIVINATION, FEAT_SKILLED_ABJURATION,
		FEAT_SKILLED_CONJURATION, FEAT_SKILLED_PHYSICS, FEAT_SKILLED_WILLPOWER,
		FEAT_SKILLED_PERCEPTION, FEAT_SKILLED_THIEVERY]],
	FEAT_SKILLED_COMBAT: ["Skilled: Combat", false, []],
	FEAT_SKILLED_ARMOR: ["Skilled: Armor", false, []],
	FEAT_SKILLED_EVOCATION: ["Skilled: Evocation", false, []],
	FEAT_SKILLED_ENCHANTMENT: ["Skilled: Enchantment", false, []],
	FEAT_SKILLED_DIVINATION: ["Skilled: Divination", false, []],
	FEAT_SKILLED_ABJURATION: ["Skilled: Abjuration", false, []],
	FEAT_SKILLED_CONJURATION: ["Skilled: Conjuration", false, []],
	FEAT_SKILLED_PHYSICS: ["Skilled: Physics", false, []],
	FEAT_SKILLED_WILLPOWER: ["Skilled: Willpower", false, []],
	FEAT_SKILLED_PERCEPTION: ["Skilled: Perception", false, []],
	FEAT_SKILLED_THIEVERY: ["Skilled: Thievery", false, []],
}

const featDescriptions = {
	FEAT_FIGHTER: "Reduces combat fatigue cost from 5 per turn to 4. +2 to PHY saves against injuries.",
	FEAT_THIEF: "Each skill point spent in Thievery or Perception awards 2 * instead of 1.",
	FEAT_MAGE: "Choose a specialist school (and a forbidden one), choosen school have 20% more uses.",
	FEAT_CLERIC: "Choose a sphere to increase your masteries and skills in magic shools.",
	FEAT_PALADIN: "+1 to CA when wearing 2H wepon, +1 damage per dice rolled when wearing 1H weapon.",
	FEAT_BARD: "Scrolls have a 20% chance not to disaperear when readed.",
	FEAT_DRUID: "+1 to all save rolls against spells.",
	FEAT_RANGER: "You have no malus to rolls when under 100 fatigue.",
	
	FEAT_ABJURER: 	"Grants:\n- Abjuration  *....\n- Divination  ...\n- Conjuration  ...\n\nAbjuration spells have 30% more uses but Enchantment spells have 30% less.",
	FEAT_ENCHANTER: "Grants:\n- Enchantment *....\n- Conjuration ...\n- Abjuration  ...\n\nEnchantment spells have 30% more uses but Divination spells have 30% less.",
	FEAT_CONJURER: 	"Grants:\n- Conjuration *....\n- Enchantment ...\n- Divination  ...\n\nConjuration spells have 30% more uses but Abjuration spells have 30% less.",
	FEAT_DIVINER: 	"Grants:\n- Divination  *....\n- Abjuration  ...\n- Enchantment ...\n\nEnchantment spells have 30% more uses but Conjuration spells have 30% less.",
	
	FEAT_SPHERE_WAR: 	"Grants:\n- Abjuration   *....\n- Enchantment  ...",
	FEAT_SPHERE_ASTRAL: 	"Grants:\n- Divination   *....\n- Conjuration  ...",
	FEAT_SPHERE_LAW: 	"Grants:\n- Enchantment  *....\n- Divination   ...",
	
	FEAT_ENDURANT: "Increases maximum fatigue by 250.",
	FEAT_TRAP_SPECIALIST: "Grants:\n- +3 to search rolls to detect traps\n- +2 to saves for trap effects.",
	FEAT_PYROMANCER: "You ignore fire resistance and fire immunity when dealing damages with spells.",
	FEAT_ARCANE_INITIATE: "You learn a single spell form the arcane spell list (restricted by school level).",
	FEAT_DIVINE_SERVANT: "You learn a single spell form the divine spell list (restricted by school level).",
	FEAT_GREAT_MEMORY: "All you spells have 20% more uses (rounded down).",
	FEAT_INVOKER: "Conjured creatures attract much more enemies attention.",
	FEAT_TOUGH: "Grants:\n- 2 HP per level (retroactive)\n- +3 for PHY save rolls against injuries",
	FEAT_SHIELD_MASTER: "If you succeed a PHY save roll while using a shield you negate the effect instead of halving damages.",
	FEAT_SAVAGE_ATTACKER: "You have -1 AC but add 1 dice to your weapon damage dices.",
	FEAT_THROWER: "Throwing weapon always deal maximum damages.",
	FEAT_SCROLL_EXPERT: "Reading a scroll does not consume your turn anymore.",
	FEAT_FIERCE: "Reroll 1s on weapon damage dices when attacking.",
	FEAT_RIPOSTE: "When a melee attack miss by at least 3, make a free automatic attack with your weapon against the attacker.",
	
	FEAT_SKILLED: "Choose a skill, you gain one level of mastery and one skill level for that skill.",
	FEAT_SKILLED_COMBAT: "You gain one level of mastery and one skill level in Combat.",
	FEAT_SKILLED_ARMOR: "You gain one level of mastery and one skill level in Armor.",
	FEAT_SKILLED_EVOCATION: "You gain one level of mastery and one skill level in Evocation.",
	FEAT_SKILLED_ENCHANTMENT:"You gain one level of mastery and one skill level in Enchantment.",
	FEAT_SKILLED_DIVINATION: "You gain one level of mastery and one skill level in Divination.",
	FEAT_SKILLED_ABJURATION: "You gain one level of mastery and one skill level in Abjuration.",
	FEAT_SKILLED_CONJURATION: "You gain one level of mastery and one skill level in Conjuration.",
	FEAT_SKILLED_PHYSICS: "You gain one level of mastery and one skill level in PHY saves.",
	FEAT_SKILLED_WILLPOWER: "You gain one level of mastery and one skill level in WIL saves.",
	FEAT_SKILLED_PERCEPTION: "You gain one level of mastery and one skill level in Perception.",
	FEAT_SKILLED_THIEVERY: "You gain one level of mastery and one skill level in Thievery.",
}

# Traps
const TR_DART = 0

const TR_NAME = 0
const TR_TYPE = 1
const TR_ICON = 2
const traps = {
	0: ["Dart trap", TR_DART, 6],
}

const BIOME_DUNGEON = 0
const BIOME_CAVERN = 1
const BIOME_MINE = 2
const BIOME_CRYPT = 3
const BIOME_VOLCANO = 4
const BIOME_ABYSS = 5

const BI_CR = 0
const BI_FLOORS = 1
const BI_CONNECT = 2
const biomes = {
	BIOME_DUNGEON: [3, 5, [BIOME_CAVERN]],
	BIOME_CAVERN: 	[6, 5, []],
}

const ENC_MONSTERS = 0
const ENC_PROB = 1
const ENC_DIFF = 2
const encounters = {
	BIOME_DUNGEON: [
		[[MO_SKELETON], 1, 0],
		[[MO_SKELETON, MO_SKELETON], 1, 1],
	]
}

var encountersCumultaiveProb: Dictionary = {}

func encountersReader():
	for biome in encounters.keys():
		if !encountersCumultaiveProb.has(biome):
			encountersCumultaiveProb[biome] = 0
		for encounter in encounters[biome]:
			encountersCumultaiveProb[biome] += encounter[ENC_PROB]

func _ready():
	classesReader()
	monstersReader()
	weaponsReader()
	shieldsReader()
	armorsReader()
	potionsReader()
	scrollsReader()
	spellsReader()
	encountersReader()
