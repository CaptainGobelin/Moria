extends Node2D
class_name Monster

onready var type = -1
onready var stats = get_node("Stats")
onready var bodySprite = get_node("BodySprite")
onready var status = "sleep"

var statuses: Dictionary = {}
var pos = Vector2(0, 0)
var skipNextTurn = false

func spawn(monsterType: int, cell: Vector2):
	type = monsterType
	bodySprite.frame = Data.monsters[monsterType][Data.MO_SPRITE]
	setPosition(cell)
	stats.init(type)

func takeTurn():
	if skipNextTurn:
		skipNextTurn = false
		return
	match status:
		"sleep":
			return
		"awake":
			if Ref.game.pathfinder.checkRange(pos, Ref.character.pos) <= stats.atkRange:
				hit(Ref.character)
			else:
				if Data.monsters[type][Data.MO_MOVE]:
					moveTo(Ref.character)
			return
		"help": # Allies behavior
			if Utils.dist(Ref.character.pos, pos) > 9:
				moveTo(Ref.character)
				return
			var target = getClosestTarget(GLOBAL.targets.keys())
			if target != null and Utils.dist(pos, target.pos) < 7:
				if Ref.game.pathfinder.checkRange(pos, target.pos) <= stats.atkRange:
					hit(target)
					return
				if moveTo(target):
					return
			if Utils.dist(Ref.character.pos, pos) > (1 + randi() % 3):
				moveTo(Ref.character)
				return
			wander()
			return

func hit(entity):
	if entity == null:
		return
	if entity.is_in_group("Character") or status == "help":
		var result = stats.hitDices.roll()
		var targetName = entity.stats.entityName
		if entity is Character:
			targetName = "you"
		if result >= entity.stats.ca:
			var rolledDmg = GeneralEngine.computeDamages(stats.dmgDices, entity.stats.resists)
			Ref.ui.writeMonsterStrike(stats.entityName, targetName, result, entity.stats.ca)
			entity.takeHit(rolledDmg)
		else:
			Ref.ui.writeMonsterMiss(stats.entityName, targetName, result, entity.stats.ca)

func moveTo(entity) -> bool:
	var path = Ref.game.pathfinder.a_star(pos, entity.pos, 1000)
	if path == null:
		return false
	setPosition(path[1])
	return true

func setPosition(newPos: Vector2):
	if GLOBAL.monstersByPosition.has(pos):
		GLOBAL.monstersByPosition.erase(pos)
	pos = newPos
	GLOBAL.monstersByPosition[pos] = get_instance_id()
	refreshMapPosition()

func refreshMapPosition():
	position = 9 * pos

func takeHit(dmg):
	var realDmg = (dmg - stats.prot)
	stats.currentHp -= realDmg
	Ref.ui.writeMonsterTakeHit(stats.entityName, realDmg)
	if stats.currentHp <= 0:
		die()

func die():
	status = "dead"
	Ref.ui.writeMonsterDie(stats.entityName)
	Ref.character.stats.xp += stats.xp
	if GLOBAL.monstersByPosition.has(pos):
		GLOBAL.monstersByPosition.erase(pos)
	GLOBAL.targets.erase(get_instance_id())
	queue_free()

func awake():
	if status == "sleep":
		status = "awake"

func wander():
	if randf() < 0.5:
		return
	var cells = Utils.directons.duplicate()
	cells.shuffle()
	for c in cells:
		if Ref.currentLevel.isCellFree(c)[0]:
			moveTo(c)

func getClosestTarget(targets: Array):
	if targets.empty():
		return null
	var result = null
	var dist = 99
	for t in targets:
		var target = instance_from_id(t)
		var newDist = Utils.dist(pos, target.pos)
		if newDist < dist:
			dist = newDist
			result = target
	return result
