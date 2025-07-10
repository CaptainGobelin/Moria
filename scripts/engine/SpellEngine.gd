extends Node

onready var effectScene = preload("res://scenes/Effect.tscn")

onready var throwings = get_node("Throwings")

const TIME_FLOOR = 9000
const TIME_REST = 9001

const SANCT_ATTACK = 0
const SANCT_BUFF = 1
const SANCT_POTION = 2

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

func conjureCreature(caster, type: int):
	var cell = caster.getRandomCloseCell()
	if cell == null:
		return
	Ref.currentLevel.spawnMonster(type, cell, caster is Character)

func applySpellStatus(entity, type: int, rank: int, time: int):
	var status = createSpellStatus(type, rank, time)
	if time == TIME_FLOOR:
		status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_FLOOR
	elif time == TIME_REST:
		status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_REST
	var result = StatusEngine.addStatus(entity, status)
	entity.stats.computeStats()
	return result

func playEffect(pos: Vector2, type: int, length: int = 5, speed: float = 0.6):
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
	var roll = GeneralEngine.dice(1, 6, entity.stats.saveBonus[type]).roll(entity)
	var saved = roll >= savingCap
	if saved:
		Ref.ui.writeSavingThrowSuccess(entity.stats.entityName)
	return saved

func rollsavingThrow(caster, entity, malus: int = 0) -> bool:
	if saveType == Data.SAVE_NO:
		return false
	var roll = GeneralEngine.dice(1, 6, entity.stats.saveBonus[saveType] - malus).roll(entity)
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
		Data.SP_BURN_HANDS:
			burningHands(caster, rank, direction)
		Data.SP_LIGHT_BOLT:
			lightningBolt(caster, entity, rank)
		Data.SP_REPEL_EVIL:
			repelEvil(caster, rank)
		Data.SP_CURE_WOUNDS:
			cureWounds(entity, rank)
		Data.SP_FROST_NOVA:
			frostNova(caster, rank)
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
		Data.SP_NEGATE_ENER:
			negateEnergies(caster, rank)
		Data.SP_MIRROR_IMAGES:
			mirrorImages(caster, rank)
		Data.SP_HOLY_BLADE:
			holyBlade(caster, rank)
		Data.SP_CURSE:
			curse(caster, entity, rank)
		Data.SP_FIRE_BLADE:
			fireBlade(caster, rank)
		Data.SP_BLIND:
			blind(caster, entity, rank)
		Data.SP_MIND_SPIKE:
			mindSpike(caster, entity, rank)
		Data.SP_DETECT_EVIL:
			detectEvil(caster, entity, rank)
		Data.SP_REVEAL_TRAPS:
			revealTraps(caster, entity)
		Data.SP_LOCATE_OBJECTS:
			locateObjects(caster, entity)
		Data.SP_REVEAL_WEAK:
			revealWeakness(caster, rank)
		Data.SP_REVEAL_HIDDEN:
			revealHidden(caster)
		Data.SP_BLINK:
			blink(caster)
		Data.SP_TRUE_STRIKE:
			trueStrike(caster, rank)
		Data.SP_FUMBLE:
			fumble(caster, entity, rank)
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
		Data.SP_REPEL_MISS:
			repelMissiles(caster, rank)
		Data.SP_FLAMESKIN:
			flameskin(caster, rank)
		Data.SP_FREED_MOVE:
			freedomMovement(caster, rank)
		Data.SP_PROTECT_FIRE:
			fireProtection(caster, rank)
		Data.SP_PROTECT_POISON:
			poisonProtection(caster, rank)
		Data.SP_ACID_SPLASH:
			acidSplash(caster, entity, rank)
		Data.SP_CONJURE_ANIMAL:
			conjureAnimal(caster, rank)
		Data.SP_SPIRITUAL_HAMMER:
			spiritualHammer(caster, rank)
		Data.SP_LESSER_AQUIREMENT:
			lesserAcquirement(caster, entity, rank, savingCap)
		Data.SP_STONE_MUD:
			stoneToMud(caster, direction)
		Data.SP_POISON_CLOUD:
			poisonCloud(caster, entity, rank)
		Data.SP_ANIMATE_SKELETONS:
			animatedDead(caster, rank)
		Data.SP_GUADRIAN_SPIRITS:
			spiritGuardians(caster, rank)
		Data.SP_FIREBALL:
			fireball(caster, entity)
		Data.SP_TH_FIREBOMB:
			throwings.firebomb(entity)
		Data.SP_TH_POISON:
			throwings.poisonFlask(entity)
		Data.SP_TH_SLEEP:
			throwings.sleepFlask(entity)

func magicMissile(caster, entity, rank: int):
	playEffect(entity.pos, Effect.ARCANE, 5, 0.6)
	var dmgDice = getDmgDice(caster, Data.SP_MAGIC_MISSILE, rank)
	var dmg = GeneralEngine.computeDamages(caster, dmgDice, entity.stats.resists)
	if caster.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_IMP_MAGIC_MIS):
		dmg += 1
	if entity.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_ARCANE_SHIELD):
		dmg = 0
	entity.takeHit(dmg)

func electricGrasp(caster, entity, rank: int, direction: Vector2):
	var targetCell = entity.pos + direction
	playEffect(targetCell, Effect.SHOCK, 5, 1.1)
	var target = getValidTarget(targetCell)
	if target != null:
		var saved = rollsavingThrow(caster, target)
		var dmgDice = getDmgDice(caster, Data.SP_ELECTRIC_GRASP, rank)
		var dmg = GeneralEngine.computeDamages(caster, dmgDice, target.stats.resists)
		if saved:
			dmg = int(floor(dmg/2))
		elif rank > 0:
			applySpellStatus(entity, Data.STATUS_PARALYZED, 0, 2)
		target.takeHit(dmg)

func heal(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var healData = Data.spellDamages[Data.SP_HEAL][rank]
	var dice = GeneralEngine.diceFromArray(healData)
	entity.heal(dice.roll(caster))

func smite(caster, entity, rank: int, direction: Vector2):
	var targetCell = entity.pos + direction
	for _i in range(GLOBAL.VIEW_RANGE):
		if Ref.currentLevel.isCellFree(targetCell)[4]:
			return
		if Ref.currentLevel.fog.get_cellv(targetCell) == 1:
			return
		playEffect(targetCell, Effect.SMITE, 5, 0.8)
		var target = getValidTarget(targetCell)
		if target != null:
			var dmgDice = getDmgDice(caster, Data.SP_SMITE, rank)
			var dmg = GeneralEngine.computeDamages(caster, dmgDice, target.stats.resists)
			target.takeHit(dmg)
		targetCell += direction

func firebolt(caster, entity, rank: int):
	playEffect(entity.pos, Effect.FIRE)
	var dmgDice = getDmgDice(caster, Data.SP_FIREBOLT, rank)
	var dmg = GeneralEngine.computeDamages(caster, dmgDice, entity.stats.resists)
	if rollsavingThrow(caster, entity):
		dmg /= 2
	entity.takeHit(dmg)

func burningHands(caster, rank: int, direction: Vector2):
	var dmgDice = getDmgDice(caster, Data.SP_BURN_HANDS, rank)
	for cell in getCone(caster.pos, direction, 3):
		var pos = caster.pos + cell
		playEffect(pos, Effect.FIRE, 5, 0.6)
		var target = getValidTarget(pos)
		if target != null:
			var dmg = GeneralEngine.computeDamages(caster, dmgDice, target.stats.resists)
			if rollsavingThrow(caster, target):
				dmg /= 2
			target.takeHit(dmg)

func lightningBolt(caster, entity, rank: int):
	playEffect(entity.pos, Effect.SHOCK)
	var dmgDice = getDmgDice(caster, Data.SP_LIGHT_BOLT, rank)
	var dmg = GeneralEngine.computeDamages(caster, dmgDice, entity.stats.resists)
	if rollsavingThrow(caster, entity):
		dmg /= 2
	entity.takeHit(dmg)

func repelEvil(caster, rank: int):
	var dmgDice = getDmgDice(caster, Data.SP_REPEL_EVIL, rank)
	var turns = getTurns(Data.SP_REPEL_EVIL, rank)
	var targetedCells = getArea(caster.pos, Data.spells[Data.SP_REPEL_EVIL][Data.SP_AREA])
	for cell in targetedCells:
		var pos = caster.pos + cell
		var target = getValidTarget(pos)
		if Data.hasTag(target, Data.TAG_EVIL):
			playEffect(pos, Effect.SMITE)
			var dmg = GeneralEngine.computeDamages(caster, dmgDice, target.stats.resists)
			if rollsavingThrow(caster, target):
				dmg /= 2
			target.takeHit(dmg)
			if rank >= 2:
				applySpellStatus(target, Data.STATUS_TERROR, 0, turns)
		else:
			playEffect(pos, Effect.SPARK)

func cureWounds(entity, rank: int):
	playEffect(entity.pos, Effect.BUFF)
	if rank >= 2 and entity is Character:
		Ref.character.fatigue.refresh(100)

func frostNova(caster, rank: int):
	var dmgDice = getDmgDice(caster, Data.SP_FROST_NOVA, rank)
	var turns = getTurns(Data.SP_FROST_NOVA, rank)
	var spellRange = Data.spells[Data.SP_FROST_NOVA][Data.SP_AREA]
	if rank >= 2:
		spellRange += 1
	var targetedCells = getArea(caster.pos, spellRange)
	for cell in targetedCells:
		var pos = caster.pos + cell
		playEffect(pos, Effect.ICE)
		var target = getValidTarget(pos)
		if target == null:
			continue
		var dmg = GeneralEngine.computeDamages(caster, dmgDice, target.stats.resists)
		if rollsavingThrow(caster, target):
			dmg /= 2
		target.takeHit(dmg)
		applySpellStatus(target, Data.STATUS_IMMOBILE, 0, turns)

func sleep(caster, entity, rank: int):
	playEffect(entity.pos, Effect.GAS, 5, 0.6)
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
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_BLESS, rank)
	if rank >= 2:
		turns = TIME_REST
	applySpellStatus(entity, Data.STATUS_BLESSED, 0, turns)

func command(caster, entity, rank: int):
	playEffect(entity.pos, Effect.SMITE, 5, 0.6)
	var turns = getTurns(Data.SP_COMMAND, rank)
	if not rollsavingThrow(caster, entity):
		applySpellStatus(entity, Data.STATUS_TERROR, 0, turns)

func light(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_COMMAND, rank)
	if rank >= 2:
		turns = TIME_REST
	if rank == 0:
		applySpellStatus(entity, Data.STATUS_LIGHT, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_LIGHT, 1, turns)
	Ref.currentLevel.refresh_view()

func negateEnergies(caster, rank: int):
	var dmgDice = getDmgDice(caster, Data.SP_NEGATE_ENER, rank)
	var spellRange = Data.spells[Data.SP_NEGATE_ENER][Data.SP_AREA]
	if rank >= 2:
		spellRange += 2
	for m in Ref.currentLevel.monsters.get_children():
		if Utils.dist(caster.pos, m.pos) <= spellRange:
			if rollsavingThrow(caster, m):
				return
			if Data.hasTag(m, Data.TAG_SUMMONED):
				playEffect(m.pos, Effect.DESTROY)
				m.die()
				return
			if StatusEngine.removeRandomBuff(m):
				playEffect(m.pos, Effect.ARCANE)
				var dmg = GeneralEngine.computeDamages(caster, dmgDice, m.stats.resists)
				m.takeHit(dmg)

func mirrorImages(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF)
	var images = 3
	if rank >= 2:
		images = 5
	applySpellStatus(caster, Data.STATUS_MIRROR_IMAGES, images, TIME_REST)

func holyBlade(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF)
	var turns = getTurns(Data.SP_HOLY_BLADE, rank)
	applySpellStatus(caster, Data.STATUS_HOLY_BLADE, rank - 1, turns)

func curse(caster, entity, rank: int):
	var saveMalus = 1
	if rank >= 2:
		saveMalus = 2 
	var turns = getTurns(Data.SP_CURSE, rank)
	var targetedCells = getArea(entity.pos, Data.spells[Data.SP_CURSE][Data.SP_AREA])
	targetedCells.append(Vector2(0, 0))
	for cell in targetedCells:
		var pos = entity.pos + cell
		var target = getValidTarget(pos)
		if target != null:
			if not rollsavingThrow(caster, target, saveMalus):
				playEffect(pos, Effect.SKULL, 5, 0.45)
				applySpellStatus(target, Data.STATUS_CURSE, 0, turns)
		else:
			playEffect(pos, Effect.DARK)

func fireBlade(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF)
	var turns = getTurns(Data.SP_FIRE_BLADE, rank)
	applySpellStatus(caster, Data.STATUS_FIRE_BLADE, rank - 1, turns)

func blind(caster, entity, rank: int):
	playEffect(entity.pos, Effect.GAS, 5, 0.6)
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
	playEffect(entity.pos, Effect.ARCANE, 5, 0.6)
	if not rollsavingThrow(caster, entity):
		var dmgDice = getDmgDice(caster, Data.SP_MIND_SPIKE, rank)
		var dmg = GeneralEngine.computeDamages(caster, dmgDice, entity.stats.resists)
		entity.takeHit(dmg)

func detectEvil(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_DETECT_EVIL, rank)
	if rank == 0:
		applySpellStatus(entity, Data.STATUS_DETECT_EVIL, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_DETECT_EVIL, 1, turns)
	Ref.currentLevel.refresh_view()

func revealTraps(caster, entity):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_REVEAL_TRAPS, 0)
	applySpellStatus(entity, Data.STATUS_REVEAL_TRAPS, 0, turns)
	Ref.currentLevel.refresh_view()

func locateObjects(caster, entity):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	applySpellStatus(entity, Data.STATUS_LOCATE_OBJECTS, 0, TIME_FLOOR)
	Ref.currentLevel.refresh_view()

func revealWeakness(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF)
	var turns = getTurns(Data.SP_REVEAL_WEAK, rank)
	applySpellStatus(caster, Data.STATUS_REVEAL_WEAKNESS, 0, turns)

func blink(caster):
	var cell = Ref.currentLevel.getRandomFreeCell()
	caster.setPosition(cell)
	playEffect(caster.pos, Effect.DESTROY, 5, 0.8)

func revealHidden(caster):
	playEffect(caster.pos, Effect.BUFF)
	applySpellStatus(caster, Data.STATUS_REVEAL_HIDDEN, 0, TIME_FLOOR)
	Ref.currentLevel.refresh_view()

func trueStrike(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF)
	var turns = getTurns(Data.SP_TRUE_STRIKE, rank)
	applySpellStatus(caster, Data.STATUS_TRUE_STRIKE, 0, turns)

func fumble(caster, entity, rank: int):
	playEffect(entity.pos, Effect.SKULL, 5, 0.45)
	var turns = getTurns(Data.SP_FUMBLE, rank)
	if not rollsavingThrow(caster, entity):
		applySpellStatus(entity, Data.STATUS_FUMBLE, 0, turns)

func shield(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_SHIELD, rank)
	applySpellStatus(entity, Data.STATUS_SHIELD, 5 * (rank + 2) - 1, turns)

func mageArmor(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	applySpellStatus(entity, Data.STATUS_MAGE_ARMOR, rank, TIME_REST)

func armorFaith(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_ARMOR_OF_FAITH, rank)
	if rank >= 2:
		turns = TIME_REST
	if rank == 0:
		applySpellStatus(entity, Data.STATUS_ARMOR_OF_FAITH, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_ARMOR_OF_FAITH, 1, turns)

func protectEvil(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_PROTECTION_FROM_EVIL, rank)
	if rank <= 1:
		applySpellStatus(entity, Data.STATUS_PROTECT_EVIL, 0, turns)
	else:
		applySpellStatus(entity, Data.STATUS_PROTECT_EVIL, 1, turns)

func sanctuary(caster, entity, rank: int):
	playEffect(entity.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_SANCTUARY, rank)
	applySpellStatus(entity, Data.STATUS_SANCTUARY, rank, turns)

func breakSanctuary(entity, action: int):
	var rank = StatusEngine.getStatusRank(entity, Data.STATUS_SANCTUARY)
	if rank < 0:
		return
	if (action == SANCT_POTION) and (rank > 0):
		return
	if (action == SANCT_BUFF) and (rank > 1):
		return
	StatusEngine.removeStatusType(entity, Data.STATUS_SANCTUARY)
	if entity is Character:
		Ref.ui.writeSancturayBreak()

func repelMissiles(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF, 5, 0.6)
	applySpellStatus(caster, Data.STATUS_REPEL_MISSILES, rank-1, TIME_REST)

func flameskin(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_FLAMESKIN, rank)
	var auraSt = applySpellStatus(caster, Data.STATUS_FIRE_AURA, 0, turns)
	var targetedCells = getAuraCells(3)
	Aura.create(targetedCells, Aura.FIRE_AURA, turns+20, true, caster, auraSt)

func freedomMovement(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_FREED_MOVE, rank)
	applySpellStatus(caster, Data.STATUS_FREED_MOVE, rank-1, turns)
	StatusEngine.removeStatusType(caster, Data.STATUS_IMMOBILE)
	StatusEngine.removeStatusType(caster, Data.STATUS_PARALYZED)
	if rank > 1:
		StatusEngine.removeStatusType(caster, Data.STATUS_TERROR)

func fireProtection(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_PROTECT_FIRE, rank)
	applySpellStatus(caster, Data.STATUS_PROTECT_FIRE, rank, turns)

func poisonProtection(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_PROTECT_POISON, rank)
	applySpellStatus(caster, Data.STATUS_PROTECT_POISON, rank, turns)
	StatusEngine.removeStatusType(caster, Data.STATUS_POISON)

func acidSplash(caster, entity, rank: int):
	var dmgDice = getDmgDice(caster, Data.SP_ACID_SPLASH, rank)
	var dmg = GeneralEngine.computeDamages(caster, dmgDice, entity.stats.resists, true)
	if rollsavingThrow(caster, entity):
		dmg = int(floor(dmg/2))
	entity.takeHit(dmg, 9999)

func conjureAnimal(caster, rank: int):
	for _i in range(GeneralEngine.dice(1, 2, rank).roll(caster)):
		conjureCreature(caster, Data.MO_SUM_WOLF)

func spiritualHammer(caster, rank: int):
	conjureCreature(caster, Data.MO_SUM_HAMMER+rank)

func lesserAcquirement(caster, entity, rank: int, itemType: int):
	var items = Ref.game.itemGenerator.generateItem(rank * 2, itemType)
	for item in items:
		GLOBAL.dropItemOnFloor(item, entity.pos)
	Ref.ui.writeWishResult(items)

func stoneToMud(caster, direction: Vector2):
	var targetCell = caster.pos
	for _i in range(caster.stats.atkRange):
		targetCell += direction
		if targetCell.x < 1 or targetCell.x >= (GLOBAL.FLOOR_SIZE_X - 1):
			break
		if targetCell.y < 1 or targetCell.y >= (GLOBAL.FLOOR_SIZE_Y - 1):
			break
		if Ref.currentLevel.dungeon.get_cellv(targetCell) == GLOBAL.WALL_ID:
			Ref.currentLevel.dungeon.set_cellv(targetCell, GLOBAL.FLOOR_ID)
		if Ref.currentLevel.isCellFree(targetCell)[4]:
			break
		playEffect(targetCell, Effect.TRANSMUT, 5, 1.1)
	if caster is Character:
		Ref.currentLevel.refresh_view()

func poisonCloud(caster, entity, rank: int):
	var turns = getTurns(Data.SP_POISON_CLOUD, rank)
	var targetedCells = getArea(entity.pos, 4)
	targetedCells.append(Vector2(0, 0))
	var auraCells = []
	for cell in targetedCells:
		cell += entity.pos
		if not Ref.currentLevel.canTarget(entity.pos, cell).empty():
			playEffect(cell, 3, 5)
			auraCells.append(cell)
	if rank < 2:
		Aura.create(auraCells, Aura.POISON_CLOUD_I, turns, caster is Character)
	else:
		Aura.create(auraCells, Aura.POISON_CLOUD_II, turns, caster is Character)

func animatedDead(caster, rank: int):
	for _i in range(2):
		conjureCreature(caster, Data.MO_SUM_SKELETON)
	if rank == 2:
		conjureCreature(caster, Data.MO_SUM_ARCHER_SKELETON)

func spiritGuardians(caster, rank: int):
	playEffect(caster.pos, Effect.BUFF, 5, 0.6)
	var turns = getTurns(Data.SP_GUADRIAN_SPIRITS, rank)
	var auraSt = applySpellStatus(caster, Data.STATUS_SPIRIT_GUARD, 0, turns)
	var targetedCells = getAuraCells(2)
	Aura.create(targetedCells, Aura.SPIRIT_GUARDIANS, turns, true, caster, auraSt)

func fireball(caster, entity):
	var targetedCells = getArea(entity.pos, 4)
	targetedCells.append(Vector2(0, 0))
	for cell in targetedCells:
		var pos = entity.pos + cell
		playEffect(pos, Effect.FIRE, 5, 0.1)
		var target = getValidTarget(cell)
		if target != null:
			target.takeHit(GeneralEngine.dice(3, 6, 0).roll(caster))

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
		Vector2(-1, 0): [[2, Vector2(-1, -1)], [2, Vector2(-1, 1)], [2, Vector2(-2, 0)]],
		Vector2(1, 0): [[2, Vector2(1, -1)], [2, Vector2(1, 1)], [2, Vector2(2, 0)]],
		Vector2(0, -1): [[2, Vector2(-1, -1)], [2, Vector2(1, -1)], [2, Vector2(0, -2)]],
		Vector2(0, 1): [[2, Vector2(-1, 1)], [2, Vector2(1, 1)], [2, Vector2(0, 2)]],
		Vector2(-1, -1): [[3, Vector2(-2, -1)], [3, Vector2(-1, -2)]],
		Vector2(-1, 1): [[3, Vector2(-2, 1)], [3, Vector2(-1, 2)]],
		Vector2(1, -1): [[3, Vector2(2, -1)], [3, Vector2(1, -2)]],
		Vector2(1, 1): [[3, Vector2(2, 1)], [3, Vector2(1, 2)]],
		Vector2(-2, 0): [[3, Vector2(-3, 0)]],
		Vector2(2, 0): [[3, Vector2(3, 0)]],
		Vector2(0, -2): [[3, Vector2(0, -3)]],
		Vector2(0, 2): [[3, Vector2(0, 3)]],
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

func getCone(pos: Vector2, direction: Vector2, size: int) -> Array:
	var result = []
	var toCheck = [direction]
	var cells = {
		Vector2(-1, 0): {
			Vector2(-1, 0): [[2, Vector2(-2, -1)], [2, Vector2(-2, 1)], [2, Vector2(-2, 0)]],
			Vector2(-2, -1): [[3, Vector2(-3, -1)], [3, Vector2(-3, -2)]],
			Vector2(-2, 1): [[3, Vector2(-3, 1)], [3, Vector2(-3, 2)]],
			Vector2(-2, 0): [[3, Vector2(-3, 0)]]
		},
		Vector2(1, 0): {
			Vector2(1, 0): [[2, Vector2(2, -1)], [2, Vector2(2, 1)], [2, Vector2(2, 0)]],
			Vector2(2, -1): [[3, Vector2(3, -1)], [3, Vector2(3, -2)]],
			Vector2(2, 1): [[3, Vector2(3, 1)], [3, Vector2(3, 2)]],
			Vector2(2, 0): [[3, Vector2(3, 0)]]
		},
		Vector2(0, -1): {
			Vector2(0, -1): [[2, Vector2(-1, -2)], [2, Vector2(1, -2)], [2, Vector2(0, -2)]],
			Vector2(-1, -2): [[3, Vector2(-1, -3)], [3, Vector2(-2, -3)]],
			Vector2(1, -2): [[3, Vector2(1, -3)], [3, Vector2(2, -3)]],
			Vector2(0, -2): [[3, Vector2(0, -3)]]
		},
		Vector2(0, 1): {
			Vector2(0, 1): [[2, Vector2(-1, 2)], [2, Vector2(1, 2)], [2, Vector2(0, 2)]],
			Vector2(-1, 2): [[3, Vector2(-1, 3)], [3, Vector2(-2, 3)]],
			Vector2(1, 2): [[3, Vector2(1, 3)], [3, Vector2(2, 3)]],
			Vector2(0, 2): [[3, Vector2(0, 3)]]
		}
	}
	for c in toCheck:
		if Ref.currentLevel.isCellFree(c + pos)[4]:
			continue
		if !result.has(c):
			result.append(c)
		if !cells[direction].has(c):
			continue
		for cell in cells[direction][c]:
			if cell[0] > size:
				continue
			toCheck.append(cell[1])
	return result

func getAuraCells(size: int):
	var result = []
	if size > 0:
		result.append_array([Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)])
	if size > 1:
		result.append_array([Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1) , Vector2(-1, 1)])
	if size > 2:
		result.append_array([Vector2(-2, 0), Vector2(2, 0), Vector2(0, 2), Vector2(0, -2)])
	return result
