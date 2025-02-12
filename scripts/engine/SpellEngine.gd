extends Node

onready var effectScene = preload("res://scenes/Effect.tscn")

onready var throwings = get_node("Throwings")

var saveType = Data.SAVE_NO
var saveCap = 99
var fromChar = false

func createSpellStatus(type: int, rank: int, time: int):
	var status = Data.statusPrefabs[type].duplicate(true)
	if rank > 1:
		status[GLOBAL.ST_NAME] += " " + Utils.toRoman(rank+1)
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

func getDmgDice(caster, spellId: int, rank: int) -> Array:
	var base = GeneralEngine.dmgDiceFromArray(Data.spellDamages[spellId][rank])
#	if caster.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_DESTRUCTION):
#		base.n += 1
	return [base]

func getTurns(spellId: int, rank: int) -> int:
	return Data.spellTurns[spellId][rank]

func standardSavingThrow(entity, savingCap: int, type: int) -> bool:
	if type == Data.SAVE_NO:
		return false
	var roll = GeneralEngine.dice(1, 6, entity.stats.saveBonus[type]).roll()
	var saved = roll >= savingCap
	if saved:
		Ref.ui.writeSavingThrowSuccess(entity.stats.entityName)
	return saved

func rollsavingThrow(caster, entity) -> bool:
	if saveType == Data.SAVE_NO:
		return false
	var roll = GeneralEngine.dice(1, 6, entity.stats.saveBonus[saveType]).roll()
	if Data.hasTag(caster, Data.TAG_EVIL):
		if entity.statuses.has(Data.STATUS_PROTECT_EVIL):
			roll += 1
	var saved = roll >= saveCap
	if saved:
		Ref.ui.writeSavingThrowSuccess(entity.stats.entityName)
	return saved

func applyEffect(caster, entity, spellId: int, fromCharacter: bool, rank: int, savingCap: int, direction: Vector2 = Vector2(0, 0)):
	if spellId < 100:
		var spell = Data.spells[spellId]
		saveCap = savingCap
		if spell[Data.SP_SAVE] != Data.SAVE_NO:
			saveType = spell[Data.SP_SAVE]
	else:
		saveType = Data.SAVE_NO
	if caster.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_EMP_ENCH):
		if Data.spells[spellId][Data.SP_SCHOOL] == Data.SC_ENCHANTMENT:
			savingCap += 1
	fromChar = fromCharacter
	match spellId:
		Data.SP_MAGIC_MISSILE:
			magicMissile(caster, entity, rank)
		Data.SP_ELECTRIC_GRASP:
			electricGrasp(caster, entity, rank, direction)
		Data.SP_HEAL:
			heal(caster, entity, rank)
		Data.SP_SMITE:
			smite(caster, entity, rank, direction)
		Data.SP_FIREBOLT:
			firebolt(caster, entity, rank)
		Data.SP_SLEEP:
			sleep(caster, entity, rank)
		Data.SP_UNLOCK:
			unlock(caster, entity, direction)
		Data.SP_BLESS:
			bless(caster, entity, rank)
		Data.SP_COMMAND:
			command(caster, entity, rank)
		Data.SP_LIGHT:
			light(caster, entity, rank)
		Data.SP_BLIND:
			blind(caster, entity, rank)
		Data.SP_MIND_SPIKE:
			mindSpike(caster, entity, rank)
		Data.SP_DETECT_EVIL:
			detectEvil(caster, entity, rank)
		Data.SP_REVEAL_TRAPS:
			revealTraps(caster, entity)
		Data.SP_SHIELD:
			shield(caster, entity, rank)
		Data.SP_MAGE_ARMOR:
			mageArmor(caster, entity, rank)
		Data.SP_ARMOR_OF_FAITH:
			armorFaith(caster, entity, rank)
		Data.SP_PROTECTION_FROM_EVIL:
			protectEvil(caster, entity, rank)
		Data.SP_SANCTUARY:
			sanctuary(caster, entity, rank)
		Data.SP_ACID_SPLASH:
			acidSplash(caster, entity, rank)
		Data.SP_CONJURE_ANIMAL:
			conjureAnimal(caster, entity, rank)
		Data.SP_SPIRITUAL_HAMMER:
			spiritualHammer(caster, entity, rank)
		Data.SP_LESSER_AQUIREMENT:
			lesserAcquirement(caster, entity, rank, savingCap)
		Data.SP_FIREBALL:
			fireball(caster, entity)
		Data.SP_TH_FIREBOMB:
			throwings.firebomb(entity)
		Data.SP_TH_POISON:
			throwings.poisonFlask(entity)
		Data.SP_TH_SLEEP:
			throwings.sleepFlask(entity)

func magicMissile(caster, entity, rank: int):
	playEffect(entity.pos, 8, 5, 0.6)
	var dmgDice = getDmgDice(caster, Data.SP_MAGIC_MISSILE, rank)
	var dmg = GeneralEngine.computeDamages(dmgDice, entity.stats.resists)
	if caster.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_IMP_MAGIC_MIS):
		dmg += 1
	if entity.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_ARCANE_SHIELD):
		dmg = 0
	entity.takeHit(dmg)

func electricGrasp(caster, entity, rank: int, direction: Vector2):
	var targetCell = entity.pos + direction
	playEffect(targetCell, 5, 5, 1.1)
	var target = getValidTarget(targetCell)
	if target != null:
		var saved = rollsavingThrow(caster, target)
		var dmgDice = getDmgDice(caster, Data.SP_ELECTRIC_GRASP, rank)
		var dmg = GeneralEngine.computeDamages(dmgDice, target.stats.resists)
		if saved:
			dmg = int(floor(dmg/2))
		elif rank > 0:
			applySpellStatus(entity, Data.STATUS_PARALYZED, 0, 2)
		target.takeHit(dmg)

func heal(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var healData = Data.spellDamages[Data.SP_HEAL][rank]
	healData.pop_back()
	var dice = GeneralEngine.diceFromArray(healData)
	entity.stats.hp += dice.roll()

func smite(caster, entity, rank: int, direction: Vector2):
	var targetCell = entity.pos + direction
	for _i in range(GLOBAL.VIEW_RANGE) :
		if Ref.currentLevel.isCellFree(targetCell)[4]:
			return
		if Ref.currentLevel.fog.get_cellv(targetCell) == 1:
			return
		playEffect(targetCell, 6, 5, 0.8)
		var target = getValidTarget(targetCell)
		if target != null:
			var dmgDice = getDmgDice(caster, Data.DMG_RADIANT, rank)
			var dmg = GeneralEngine.computeDamages(dmgDice, target.stats.resists)
			target.takeHit(dmg)
		targetCell += direction

func firebolt(caster, entity, rank: int):
	var dmgDice = getDmgDice(caster, Data.DMG_FIRE, rank)
	var dmg = GeneralEngine.computeDamages(dmgDice, entity.stats.resists)
	if rollsavingThrow(caster, entity):
		dmg /= 2
	entity.takeHit(dmg)

func sleep(caster, entity, rank: int):
	playEffect(entity.pos, 4, 5, 0.6)
	var turns = getTurns(Data.SP_SLEEP, rank)
	if rank == 0 or entity is Character:
		if not rollsavingThrow(caster, entity):
			applySpellStatus(entity, Data.STATUS_SLEEP, 0, turns)
	else:
		for m in Ref.currentLevel.monsters.get_children():
			if Utils.dist(entity.pos, m.pos) <= (rank+1):
				if not rollsavingThrow(caster, entity):
					applySpellStatus(entity, Data.STATUS_SLEEP, 0, turns)

func unlock(caster, entity, direction: Vector2):
	var cell = entity.pos + direction
	if GLOBAL.lockedDoors.has(cell) and (not GLOBAL.hiddenDoors.has(cell)):
		GLOBAL.lockedDoors.erase(cell)
		Ref.ui.writeDoorUnlocked()
		return
	var chest = GLOBAL.getChestByPos(cell)
	if chest != null and chest[GLOBAL.CH_LOCKED] > 0:
		chest[GLOBAL.CH_LOCKED] = 0
		Ref.ui.writeChestUnlocked()

func bless(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	for i in range(100, 109):
		applySpellStatus(entity, i, 0, 10)
	var turns = getTurns(Data.SP_BLESS, rank)
	applySpellStatus(entity, Data.STATUS_BLESSED, 0, turns)

func command(caster, entity, rank: int):
	playEffect(entity.pos, 6, 5, 0.6)
	var turns = getTurns(Data.SP_COMMAND, rank)
	if not rollsavingThrow(caster, entity):
		applySpellStatus(entity, Data.STATUS_TERROR, 0, turns)

func light(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_COMMAND, rank)
	if rank == 0:
		applySpellStatus(entity, Data.STATUS_LIGHT, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_LIGHT, 1, turns)
	Ref.currentLevel.refresh_view()

func blind(caster, entity, rank: int):
	playEffect(entity.pos, 4, 5, 0.6)
	var turns = getTurns(Data.SP_BLIND, rank)
	if rank == 0 or entity is Character:
		if not rollsavingThrow(caster, entity):
			applySpellStatus(entity, Data.STATUS_BLIND, 0, turns)
	else:
		for m in Ref.currentLevel.monsters.get_children():
			if Utils.dist(entity.pos, m.pos) <= (rank+1):
				if not rollsavingThrow(caster, entity):
					applySpellStatus(m, Data.STATUS_SLEEP, 0, turns)

func mindSpike(caster, entity, rank: int):
	playEffect(entity.pos, 8, 5, 0.6)
	if not rollsavingThrow(caster, entity):
		var dmgDice = getDmgDice(caster, Data.SP_MIND_SPIKE, rank)
		var dmg = GeneralEngine.computeDamages(dmgDice, entity.stats.resists)
		entity.takeHit(dmg)

func detectEvil(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_DETECT_EVIL, rank)
	if rank == 0:
		applySpellStatus(entity, Data.STATUS_DETECT_EVIL, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_DETECT_EVIL, 1, turns)
	Ref.currentLevel.refresh_view()

func revealTraps(caster, entity):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_REVEAL_TRAPS, 0)
	applySpellStatus(entity, Data.STATUS_REVEAL_TRAPS, 0, turns)
	Ref.currentLevel.refresh_view()

func shield(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_SHIELD, rank)
	applySpellStatus(entity, Data.STATUS_SHIELD, 5 * (rank + 2) - 1, turns)

func mageArmor(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var status = createSpellStatus(Data.STATUS_MAGE_ARMOR, rank, 99)
	status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_REST
	StatusEngine.addStatus(entity, status)
	entity.stats.computeStats()

func armorFaith(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_ARMOR_OF_FAITH, rank)
	if rank == 0:
		applySpellStatus(entity, Data.STATUS_PROTECTION, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_PROTECTION, 1, turns)

func protectEvil(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_PROTECTION_FROM_EVIL, rank)
	if rank <= 1:
		applySpellStatus(entity, Data.STATUS_PROTECT_EVIL, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_PROTECT_EVIL, 1, turns)

func sanctuary(caster, entity, rank: int):
	playEffect(entity.pos, 7, 5, 0.6)
	var turns = getTurns(Data.SP_SANCTUARY, rank)
	applySpellStatus(entity, Data.STATUS_SANCTUARY, rank, turns)

func acidSplash(caster, entity, rank: int):
	var dmgDice = getDmgDice(caster, Data.SP_ACID_SPLASH, rank)
	var dmg = GeneralEngine.computeDamages(dmgDice, entity.stats.resists, true)
	if rollsavingThrow(caster, entity):
		dmg = int(floor(dmg/2))
	entity.takeHit(dmg, 9999)

func conjureAnimal(caster, entity, rank: int):
	if entity is Character:
		for _i in range(GeneralEngine.dice(1, 2, rank).roll()):
			var cell = entity.getRandomCloseCell()
			if cell == null:
				return
			Ref.currentLevel.spawnMonster(Data.MO_SUM_WOLF, cell, true)

func spiritualHammer(caster, entity, rank: int):
	if entity is Character:
		var cell = entity.getRandomCloseCell()
		if cell == null:
			return
		Ref.currentLevel.spawnMonster(Data.MO_SUM_HAMMER+rank, cell, true)

func lesserAcquirement(caster, entity, rank: int, itemType: int):
	var items = Ref.game.itemGenerator.generateItem(rank * 2, itemType)
	for item in items:
		GLOBAL.dropItemOnFloor(item, entity.pos)
	Ref.ui.writeWishResult(items)

func fireball(caster, entity):
	var targetedCells = getArea(entity.pos, 4)
	targetedCells.append(Vector2(0, 0))
	for cell in targetedCells:
		var pos = entity.pos + cell
		playEffect(pos, 0, 5, 0.1)
		var target = getValidTarget(cell)
		if target != null:
			target.takeHit(GeneralEngine.dice(3, 6, 0).roll())

# ===== ENCHANTMENTS SPELLS/EFFECTS ===== #

func applyPoison(target, rank: int, savingCap: int):
	saveCap = savingCap
	if standardSavingThrow(target, savingCap, Data.SAV_PHY):
		return
	applySpellStatus(target, Data.STATUS_POISON, rank, 20)

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
