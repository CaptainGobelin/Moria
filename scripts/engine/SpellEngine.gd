extends Node

onready var effectScene = preload("res://scenes/Effect.tscn")

onready var throwings = get_node("Throwings")

var saveType = Data.SAVE_NO
var saveCap = 99
var fromChar = false

func createSpellStatus(type: int, rank: int, time: int):
	var status = Data.statusPrefabs[type]
	if rank > 1:
		status[GLOBAL.ST_NAME] += " " + Utils.toRoman(rank)
	status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_TIMER
	status[GLOBAL.ST_TURNS] = time
	status[GLOBAL.ST_RANK] = rank
	return status

func applySpellStatus(entity, type: int, rank: int, time: int):
	var status = createSpellStatus(type, rank, time)
	StatusEngine.addStatus(entity, status)
	entity.stats.computeStats()

func playEffect(pos: Vector2, type: int, length: int, speed: float):
	var effect = effectScene.instance()
	Ref.currentLevel.effects.add_child(effect)
	effect.play(pos, type, length, speed)

func getValidTarget(cell: Vector2):
	if fromChar:
		if GLOBAL.monstersByPosition.has(cell):
			return instance_from_id(GLOBAL.monstersByPosition[cell])
	else:
		if Ref.character.pos == cell:
			return Ref.character
	return null

func rollsavingThrow(entity) -> bool:
	var saved = GeneralEngine.dice(1, 6, entity.stats.saveBonus[saveType]).roll() >= saveCap
	if saved:
		Ref.ui.writeSavingThrowSuccess(entity.stats.entityName)
	return saved

func applyEffect(entity, spellId: int, fromCharacter: bool, rank: int, savingCap: int, direction: Vector2 = Vector2(0, 0)):
	var spell = Data.spells[spellId]
	saveCap = savingCap
	saveType = spell[Data.SP_SAVE]
	fromChar = fromCharacter
	match spellId:
		Data.SP_MAGIC_MISSILE:
			magicMissile(entity)
		Data.SP_ELECTRIC_GRASP:
			electricGrasp(entity, rank, direction)
		Data.SP_HEAL:
			heal(entity)
		Data.SP_SMITE:
			smite(entity, direction)
		Data.SP_FIREBOLT:
			firebolt(entity)
		Data.SP_SLEEP:
			sleep(entity, rank)
		Data.SP_UNLOCK:
			unlock(entity, direction)
		Data.SP_BLESS:
			bless(entity, rank)
		Data.SP_COMMAND:
			command(entity)
		Data.SP_LIGHT:
			light(entity)
		Data.SP_CONJURE_ANIMAL:
			conjureAnimal(entity)
		Data.SP_FIREBALL:
			fireball(entity)
		Data.SP_TH_FIREBOMB:
			throwings.firebomb(entity)
		Data.SP_TH_POISON:
			throwings.poisonFlask(entity)
		Data.SP_TH_SLEEP:
			throwings.sleepFlask(entity)

func magicMissile(entity):
	entity.takeHit(GeneralEngine.dice(2, 1, 1).roll())

func electricGrasp(entity, rank: int, direction: Vector2):
	var targetCell = entity.pos + direction
	playEffect(targetCell, 5, 5, 1.1)
	var target = getValidTarget(targetCell)
	if target != null:
		var saved = rollsavingThrow(target)
		var dmgDice = [GeneralEngine.dmgDice(1, 12, 0, Data.DMG_LIGHTNING)]
		var dmg = GeneralEngine.computeDamages(dmgDice, target.stats.resists)
		if saved:
			dmg = int(dmg) / int(2)
		target.takeHit(dmg)

func heal(entity):
	playEffect(entity.pos, 7, 5, 0.6)
	var result:float = entity.stats.hpMax * 0.5
	entity.stats.hp += ceil(result)

func smite(entity, direction):
	var targetCell = entity.pos + direction
	for _i in range(GLOBAL.VIEW_RANGE) :
		if Ref.currentLevel.isCellFree(targetCell)[4]:
			return
		if Ref.currentLevel.fog.get_cellv(targetCell) == 1:
			return
		playEffect(targetCell, 6, 5, 0.8)
		var target = getValidTarget(targetCell)
		if target != null:
			var dmgDice = [GeneralEngine.dmgDice(1, 8, 0, Data.DMG_RADIANT)]
			var dmg = GeneralEngine.computeDamages(dmgDice, target.stats.resists)
			target.takeHit(dmg)
		targetCell += direction

func firebolt(entity):
	var dmgDice = [GeneralEngine.dmgDice(1, 10, 0, Data.DMG_FIRE)]
	var dmg = GeneralEngine.computeDamages(dmgDice, entity.stats.resists)
	entity.takeHit(dmg)

func sleep(entity, rank: int):
	playEffect(entity.pos, 4, 5, 0.6)
	if not rollsavingThrow(entity):
		applySpellStatus(entity, Data.STATUS_SLEEP, rank, 20)

func unlock(entity, direction: Vector2):
	var cell = entity.pos + direction
	if GLOBAL.lockedDoors.has(cell) and (not GLOBAL.hiddenDoors.has(cell)):
		GLOBAL.lockedDoors.erase(cell)
		Ref.ui.writeDoorUnlocked()
		return
	var chest = GLOBAL.getChestByPos(cell)
	if chest != null and chest[GLOBAL.CH_LOCKED] > 0:
		chest[GLOBAL.CH_LOCKED] = 0
		Ref.ui.writeChestUnlocked()

func bless(entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	applySpellStatus(entity, Data.STATUS_BLESSED, rank, 20)

func command(entity):
	playEffect(entity.pos, 6, 5, 0.6)
	if not rollsavingThrow(entity):
		applySpellStatus(entity, Data.STATUS_TERROR, 1, 5)

func light(entity):
	playEffect(entity.pos, 7, 5, 0.6)
	applySpellStatus(entity, Data.STATUS_LIGHT, 1, 40)

func conjureAnimal(entity):
	if entity is Character:
		var cell = entity.getRandomCloseCell()
		if cell == null:
			return
		Ref.currentLevel.spawnMonster(900, cell, true)

func fireball(entity):
	var targetedCells = getArea(entity.pos, 4)
	targetedCells.append(Vector2(0, 0))
	for cell in targetedCells:
		var pos = entity.pos + cell
		playEffect(pos, 0, 5, 0.1)
		var target = getValidTarget(cell)
		if target != null:
			target.takeHit(GeneralEngine.dice(3, 6, 0).roll())

func getArea(pos: Vector2, size: int):
	var result = []
	var toCheck = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	var cells = {
		Vector2(-1, 0): [[2, Vector2(-1, -1)], [2, Vector2(-1, 1)], [3, Vector2(-2, 0)]],
		Vector2(1, 0): [[2, Vector2(1, -1)], [2, Vector2(1, 1)], [3, Vector2(2, 0)]],
		Vector2(0, -1): [[2, Vector2(-1, -1)], [2, Vector2(1, -1)], [3, Vector2(0, -2)]],
		Vector2(0, 1): [[2, Vector2(-1, 1)], [2, Vector2(1, 1)], [3, Vector2(0, 2)]],
		Vector2(-1, -1): [[4, Vector2(-2, -1)], [4, Vector2(-1, -2)]],
		Vector2(-1, 1): [[4, Vector2(-2, 1)], [4, Vector2(-1, 2)]],
		Vector2(1, -1): [[4, Vector2(2, -1)], [4, Vector2(1, -2)]],
		Vector2(1, 1): [[4, Vector2(2, 1)], [4, Vector2(1, 2)]]
	}
	for c in toCheck:
		if Ref.currentLevel.isCellFree(c + pos)[4]:
			continue
		if !result.has(c):
			result.append(c)
		if !cells.has(c):
			continue
		for cell in cells[c]:
			if cell[0] > size:
				continue
			toCheck.append(cell[1])
	return result
