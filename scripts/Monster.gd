extends Node2D
class_name Monster

onready var type = -1
onready var stats = get_node("Stats")
onready var actions = get_node("Actions")
onready var bodySprite = get_node("BodySprite")
onready var mask = get_node("Mask")
onready var status = "sleep"

var tags: Array = []
var statuses: Dictionary = {}
var pos = Vector2(0, 0)
var skipNextTurn = false
var allies: Array = []
var buffCD = 0

func spawn(monsterType: int, cell: Vector2):
	type = monsterType
	bodySprite.frame = Data.monsters[monsterType][Data.MO_SPRITE]
	setPosition(cell)
	stats.init(type)
	actions.init(type)
	if Data.monsterTags.has(monsterType):
		tags = Data.monsterTags[monsterType]

func takeTurn():
	buffCD -= 1
	if skipNextTurn:
		skipNextTurn = false
		return
	var currentStatus = stats.state
	if currentStatus == "":
		currentStatus = status
	match currentStatus:
		"dead":
			return
		"disabled":
			return
		"sleep":
			wander()
			return
		"awake":
			if randf() < 0.25:
				if heal():
					return
			if buffCD <= 0 and randf() < 0.25:
				if buff():
					buffCD = 10
					return
			#var rangeToChar = Utils.dist(pos, Ref.character.pos)
			var losToChar = Ref.currentLevel.canTarget(pos, Ref.character.pos)
			attack(Ref.character, losToChar)
		"help": # Allies behavior
			if Utils.dist(Ref.character.pos, pos) > 9:
				moveTo(Ref.character)
				return
			var target = getClosestTarget(GLOBAL.targets.keys())
			if target[0] != null and target[1].size() < (stats.atkRange + 4):
					attack(target[0], target[1])
					return
			if Utils.dist(Ref.character.pos, pos) > (1 + randi() % 3):
				moveTo(Ref.character)
				return
			wander()
			return

func heal():
	var heal = actions.getAction(actions.heals, "heal")
	if heal != null:
		var ally = getTargetableAlly(true)
		if ally != null:
			Ref.game.spellHandler.castSpellMonster(heal[0], self, ally[0], ally[1])
			actions.consumeAction(heal[0], heal[1])
			return true
	if stats.hpPercent() > 40:
		return false
	heal = actions.getSelfHeal()
	if heal != null:
		if heal[1] == "heal":
			Ref.game.spellHandler.castSpellMonster(heal[0], self, self, [])
			actions.consumeAction(heal[0], heal[1])
		else:
			quaffPotion(heal[0], heal[1])
		return true
	return false

func buff():
	var buff = actions.getAction(actions.buffs, "buff")
	if buff != null:
		var ally = getTargetableAlly()
		if ally != null:
			Ref.game.spellHandler.castSpellMonster(buff[0], self, ally[0], ally[1])
			actions.consumeAction(buff[0], buff[1])
			return true
	buff = actions.getSelfBuff()
	if buff != null:
		if buff[1] == "buff":
			Ref.game.spellHandler.castSpellMonster(buff[0], self, self, [])
			actions.consumeAction(buff[0], buff[1])
		else:
			quaffPotion(buff[0], buff[1])
		return true
	return false

func attack(entity, los: Array):
	if !los.empty() and randf() < 0.5:
		var action = actions.getAction(actions.spells, "spell")
		if action != null:
			Ref.game.spellHandler.castSpellMonster(action[0], self, entity, los)
			actions.consumeAction(action[0], action[1])
			return
	if Utils.dist(pos, entity.pos) == 1:
		hit(entity)
		return
	if !los.empty():
		var action = actions.getAction(actions.throwings, "throwing")
		if action != null:
			Ref.game.throwHandler.castThrowMonster(action[0], self, entity, los)
			actions.consumeAction(action[0], action[1])
			return
	moveTo(entity)

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
	var path = Ref.game.pathfinder.a_star(pos, entity.pos, 20)
	if path == null:
		return false
	setPosition(path[1])
	return true

func moveStep(d: Vector2) -> bool:
	if Ref.character.pos == pos + d:
		return false
	if Ref.currentLevel.isCellFree(pos+d)[0]:
		setPosition(pos+d)
		return true
	return false

func setPosition(newPos: Vector2):
	if GLOBAL.monstersByPosition.has(pos):
		GLOBAL.monstersByPosition.erase(pos)
	pos = newPos
	GLOBAL.monstersByPosition[pos] = get_instance_id()
	refreshMapPosition()

func refreshMapPosition():
	position = 9 * pos

func takeHit(dmg: int, bypassProt: bool = false):
	if status == "dead":
		return
	var realDmg = (dmg - stats.prot)
	if bypassProt:
		realDmg = dmg
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
		if moveStep(c):
			return

func quaffPotion(idx: int, actionType: String):
	var potion = GLOBAL.items[idx]
	PotionEngine.applyEffect(self, potion[GLOBAL.IT_SPEC])
	Ref.ui.writeMonsterQuaffedPotion(stats.entityName, potion[GLOBAL.IT_NAME])
	actions.consumeAction(idx, actionType)

func getClosestTarget(targets):
	var result = null
	var currentLos = []
	var dist = 99
	for t in targets:
		var target = instance_from_id(t)
		var los = Ref.currentLevel.canTarget(pos, target.pos)
		if los.empty() or los.size() > dist:
			continue
		dist = los.size()
		result = target
		currentLos = los.duplicate()
	return [result, currentLos]

func getTargetableAlly(toHeal: bool = false):
	var result = {}
	for a in allies:
		if a.status == "dead":
			continue
		if toHeal and a.stats.hpPercent() > 40:
			continue
		var los = Ref.currentLevel.canTarget(pos, a.pos)
		if los.empty():
			continue
		result[a.get_instance_id()] = los
	if result.empty():
		return null
	var resultId = Utils.chooseRandom(result.keys())
	return [resultId, result[resultId]]
