extends Sprite
class_name Aura

const BLUE = 0
const RED = 1
const GREEN = 2
const YELLOW = 3
const PURPLE = 4
const CYAN = 5

const POISON_CLOUD_I = 0
const POISON_CLOUD_II = 1
const FIRE_AURA = 10
const SPIRIT_GUARDIANS = 20

var pos = Vector2()
var relativeTo = null
var timer = 0
var type: int = 0
var isAllied = false
var tiedStatus: int = -1

func init(newPos: Vector2, auraType: int, lifetime: int, createdByAllied: bool, entity = null, source: int = -1):
	relativeTo = entity
	if relativeTo != null:
		position = 9 * (newPos + relativeTo.pos)
	else:
		position = 9 * newPos
	pos = newPos
	timer = lifetime - 1
	isAllied = createdByAllied
	tiedStatus = source
	type = auraType
	match auraType:
		POISON_CLOUD_I:
			frame = GREEN
		POISON_CLOUD_II:
			frame = GREEN
		FIRE_AURA:
			frame = RED
		SPIRIT_GUARDIANS:
			frame = YELLOW

func update():
	timer -= 1
	if timer < 0:
		queue_free()
	if tiedStatus != -1 and !GLOBAL.statuses.has(tiedStatus):
		queue_free()
	if relativeTo == null:
		return
	position = 9 * (pos + relativeTo.pos)

func trigger(entity):
	if entity == relativeTo:
		return
	if isAllied:
		if entity is Character:
			return
		#TODO check if allied
	else:
		#TODO check not allied
		pass
	match type:
		FIRE_AURA:
			var dmgDice = [GeneralEngine.dmgDice(0, 0, 1, Data.DMG_FIRE)]
			var dmg = GeneralEngine.computeDamages(null, dmgDice, entity.stats.resists)
			entity.takeHit(dmg)
		POISON_CLOUD_I:
			var dmgDice = [GeneralEngine.dmgDiceFromArray(Data.spellDamages[Data.SP_POISON_CLOUD][1])]
			var dmg = GeneralEngine.computeDamages(null, dmgDice, entity.stats.resists)
			entity.takeHit(dmg)
		POISON_CLOUD_II:
			var dmgDice = [GeneralEngine.dmgDiceFromArray(Data.spellDamages[Data.SP_POISON_CLOUD][2])]
			var dmg = GeneralEngine.computeDamages(null, dmgDice, entity.stats.resists)
			entity.takeHit(dmg)

func getPos() -> Vector2:
	if relativeTo == null:
		return pos
	return relativeTo.pos + pos

static func triggerAll():
	for a in Ref.currentLevel.auras.get_children():
		var cell = a.getPos()
		if GLOBAL.monstersByPosition.has(cell):
			a.trigger(GLOBAL.getMonsterByPos(cell))
		if Ref.character.pos == cell:
			a.trigger(Ref.character)

static func updateAll():
	for a in Ref.currentLevel.auras.get_children():
		a.update()
	triggerAll()

static func create(newPos: Array, auraType: int, lifetime: int, createdByAllied: bool, entity = null, source: int = -1):
	for p in newPos:
		var a = Ref.currentLevel.auraScene.instance()
		Ref.currentLevel.auras.add_child(a)
		a.init(p, auraType, lifetime, createdByAllied, entity, source)
