extends Node

const FLOOR_SIZE_X = 37
const FLOOR_SIZE_Y = 19
const FULLNESS_THRESHOLD = 0.46
const DOOR_REDUCTION_RATIO = 2

const WALL_ID = 1
const DOOR_ID = 2
const PILLAR_ID = 3
const FLOOR_ID = 4
const GRID_ID = 5
const PASS_ID = 6

const VIEW_RANGE = 8

const INV_WEAPONS = 0
const INV_ARMORS = 1
const INV_POTIONS = 3

const CHAR_SKILLS = 0
const CHAR_FEATS = 1
const CHAR_STATUSES = 2

const WP_TYPE = 0
const AR_TYPE = 1
const PO_TYPE = 2

const IT_TYPE = 0
const IT_NAME = 1
const IT_ICON = 2
const IT_DMG = 3
const IT_HIT = 4
const IT_2H = 5
const IT_CA = 6
const IT_PROT = 7
# Special is enchants, talisman effect, scroll spell or potion effect
const IT_SPEC = 8
const IT_STACK = 9
var items = {}

var itemsOnFloor = {}
