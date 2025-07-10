extends Node2D
class_name Character

onready var animator = get_node("AnimationPlayer")
onready var stats = get_node("Stats")
onready var inventory = get_node("Inventory")
onready var spells = get_node("Spells")
onready var skills = get_node("Skills")
onready var shortcuts = get_node("Shortcuts")
onready var fatigue = get_node("Fatigue")
onready var status = ""

var currentVision: Array = []
var charClass: int = 0
var statuses: Dictionary = {}
var enchants: Dictionary = {}
var pos = Vector2(0, 0)

func _ready():
	Ref.character = self

func init(newCharClass: int, isCreation: bool = true):
	charClass = newCharClass
	stats.init(charClass)
	fatigue.init()
	if isCreation:
		skills.init(charClass)
		inventory.init(charClass)

func setPosition(newPos):
	pos = newPos
	Ref.currentLevel.refresh_view()
	refreshMapPosition()
	Ref.ui.write(Ref.currentLevel.getLootMessage(pos))
	if GLOBAL.trapsByPos.has(pos):
		var trap = GLOBAL.getTrapByPos(pos)
		if trap.hidden:
			TrapEngine.trigger(trap, self)

func move(movement):
	pos += movement
	animator.play("walk")
	GeneralEngine.newTurn()
	refreshMapPosition()
	Ref.ui.write(Ref.currentLevel.getLootMessage(pos))
	if GLOBAL.trapsByPos.has(pos):
		var trap = GLOBAL.getTrapByPos(pos)
		if trap.hidden:
			TrapEngine.trigger(trap, self)

func moveAsync(movement):
	var cellState = Ref.currentLevel.isCellFree(pos + movement)
	if cellState[0]:
		if statuses.has(Data.STATUS_IMMOBILE):
			Ref.ui.writeCannotMove()
			return
		move(movement)
		return
	match cellState[1]:
		"door": 
			if GLOBAL.lockedDoors.has(pos + movement):
				GLOBAL.testDoor(pos + movement)
				if inventory.lockpicks == 0:
					Ref.ui.noLockpicksDoor()
					return
				Ref.ui.askToPickDoor(3)
				Ref.ui.askForYesNo(Ref.game)
				var coroutineReturn = yield(Ref.ui, "coroutine_signal")
				if (coroutineReturn):
					if attemptLockpick(3):
						GLOBAL.lockedDoors.erase(pos + movement)
						Ref.currentLevel.openDoor(pos + movement)
						GeneralEngine.newTurn()
			else:
				Ref.currentLevel.openDoor(pos + movement)
				GeneralEngine.newTurn()
		"monster":
			if cellState[2].status == "help":
				cellState[2].setPosition(pos)
				cellState[2].skipNextTurn = true
				move(movement)
				return
			hit(cellState[2])
			GeneralEngine.newTurn()
		"npc":
			cellState[2].speak()
			GeneralEngine.newTurn()
		"pass": 
			Ref.ui.askToChangeFloor()
			Ref.ui.askForYesNo(Ref.game)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if (coroutineReturn):
				StatusEngine.removeFloorStatuses(self)
				Ref.game.nextFloor()
				GeneralEngine.newTurn()
		"chest": 
			var lock = GLOBAL.chests[cellState[2]][GLOBAL.CH_LOCKED]
			if lock == 0:
				Ref.ui.askToOpenChest()
				Ref.ui.askForYesNo(Ref.game)
				var coroutineReturn = yield(Ref.ui, "coroutine_signal")
				if (coroutineReturn):
					Ref.game.chestMenu.open(cellState[2])
			else:
				if inventory.lockpicks == 0:
					Ref.ui.noLockpicksChest()
					return
				Ref.ui.askToPickChest(lock)
				Ref.ui.askForYesNo(Ref.game)
				var coroutineReturn = yield(Ref.ui, "coroutine_signal")
				if (coroutineReturn):
					if attemptLockpick(lock):
						GLOBAL.chests[cellState[2]][GLOBAL.CH_LOCKED] = 0
						Ref.game.chestMenu.open(cellState[2])
		"entry":
			Ref.ui.writeNoGoingBack()
		"passage":
			if Ref.currentLevel.levelBuffer.currentLevel == "main":
				Ref.game.merchantFloor()
			else:
				Ref.currentLevel.levelBuffer.saveLevel()
				Ref.currentLevel.levelBuffer.loadLevel("main")

func hit(entity):
	if entity == null:
		return
	if entity.is_in_group("Monster"):
		fatigue.fightCost()
		SpellEngine.breakSanctuary(self, SpellEngine.SANCT_ATTACK)
		var isSlaying = false
		if statuses.has(Data.STATUS_GOBLIN_WP) and Data.hasTag(entity, Data.TAG_GOBLIN):
			isSlaying = true
		var result = stats.hitDices.roll(self)
		if isSlaying:
			result += 1
		if result >= entity.stats.ca:
			Ref.ui.writeCharacterStrike(entity.stats.entityName, result, entity.stats.ca)
			if statuses.has(Data.STATUS_MIRROR_IMAGES) and randf() < 0.5:
				StatusEngine.decreaseStatusRanks(self, 1, Data.STATUS_MIRROR_IMAGES)
				Ref.ui.writeMonsterHitImage(entity.stats.entityName)
				return
			var dmgDices = stats.dmgDices.duplicate()
			var bypassProt = 0
			if Data.hasTag(entity, Data.TAG_EVIL):
				if StatusEngine.getStatusRank(self, Data.STATUS_DETECT_EVIL) > 0:
					bypassProt = max(bypassProt, 9999)
				if statuses.has(Data.STATUS_HOLY_WP):
					dmgDices.append(GeneralEngine.DmgDice.new(1, 4, 0, Data.DMG_RADIANT))
			var dmg = GeneralEngine.computeDamages(self, stats.dmgDices, entity.stats.resists)
			if isSlaying:
				dmg += 1
			if statuses.has(Data.STATUS_ENCHANT + Data.ENCH_PIERCING):
				bypassProt = max(bypassProt, 2)
			entity.takeHit(dmg, bypassProt)
			StatusEngine.applyWeaponEffects(self, entity)
		else:
			Ref.ui.writeCharacterMiss(entity.stats.entityName, result, entity.stats.ca)

func takeHit(dmg: int, bypassProt: int = 0):
	var isCritical = stats.hpPercent() < 0.25
	if stats.hasStatus(Data.STATUS_VULNERABLE):
		bypassProt = 9999
	var realDmg = max(1, dmg - max(0, stats.prot - bypassProt))
	realDmg = StatusEngine.decreaseStatusRanks(self, realDmg, Data.STATUS_SHIELD)
	stats.hp -= realDmg
	Ref.ui.writeCharacterTakeHit(realDmg)
	if !isCritical and stats.hpPercent() < 0.25:
		if statuses.has(Data.STATUS_ENCHANT + Data.ENCH_ESCAPE):
			var s = SpellEngine.createSpellStatus(Data.STATUS_INVISIBLE, 1, 5)
			StatusEngine.addStatus(self, s)
	return realDmg

func heal(amount: int):
	var oldHp = stats.hp
	stats.updateHp(stats.hp + amount)
	Ref.ui.writeCharacterHeal(stats.hp - oldHp)

func pickItem(items: Array, price: int = 0):
	var item = GLOBAL.items[items[0]]
	for idx in items:
		GLOBAL.removeItemFromFloor(idx)
		match item[GLOBAL.IT_TYPE]:
			GLOBAL.WP_TYPE: inventory.weapons.append(idx)
			GLOBAL.AR_TYPE: inventory.armors.append(idx)
			GLOBAL.PO_TYPE: inventory.potions.append(idx)
			GLOBAL.SC_TYPE: inventory.scrolls.append(idx)
			GLOBAL.TH_TYPE: inventory.throwings.append(idx)
			GLOBAL.TA_TYPE: inventory.talismans.append(idx)
			GLOBAL.LO_TYPE: inventory.lockpicks += item[GLOBAL.IT_SPEC]
			GLOBAL.GO_TYPE: inventory.golds += item[GLOBAL.IT_SPEC]
	if price > 0:
		inventory.pay(price)
		if item[GLOBAL.IT_TYPE] == GLOBAL.LO_TYPE or item[GLOBAL.IT_TYPE] == GLOBAL.GO_TYPE:
			Ref.ui.writeBuyLoot(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC], price)
		else:
			Ref.ui.writeBuyLoot(item[GLOBAL.IT_NAME], items.size(), price)
	else:
		if item[GLOBAL.IT_TYPE] == GLOBAL.LO_TYPE or item[GLOBAL.IT_TYPE] == GLOBAL.GO_TYPE:
			Ref.ui.writePickupLoot(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC])
		else:
			Ref.ui.writePickupLoot(item[GLOBAL.IT_NAME], items.size())

func dropItem(idx):
	var item = GLOBAL.items[idx]
	unequipItem(idx)
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			inventory.weapons.erase(idx)
		GLOBAL.AR_TYPE:
			inventory.armors.erase(idx)
		GLOBAL.TA_TYPE:
			inventory.talismans.erase(idx)
		GLOBAL.PO_TYPE:
			inventory.potions.erase(idx)
		GLOBAL.SC_TYPE:
			inventory.scrolls.erase(idx)
		GLOBAL.TH_TYPE:
			inventory.throwings.erase(idx)
	GLOBAL.dropItemOnFloor(idx, pos)
	Ref.ui.write("You dropped " + Utils.addArticle(item[GLOBAL.IT_NAME]) + ".")

func unequipItem(idx):
	var item = GLOBAL.items[idx]
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			inventory.unequipWeapon(idx)
		GLOBAL.AR_TYPE:
			inventory.unequipArmor(idx)

func switchItem(idx):
	var item = GLOBAL.items[idx]
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			inventory.switchWeapon(idx)
		GLOBAL.AR_TYPE:
			inventory.switchArmor(idx)
		GLOBAL.TA_TYPE:
			inventory.switchTalisman(idx)

func equipItem(idx):
	var item = GLOBAL.items[idx]
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			inventory.equipWeapon(idx)
		GLOBAL.AR_TYPE:
			inventory.equipArmor(idx)

func quaffPotion(idx):
	var potion = GLOBAL.items[idx]
	inventory.potions.erase(idx)
	PotionEngine.applyEffect(self, potion[GLOBAL.IT_SPEC])
	Ref.ui.writeQuaffedPotion(potion[GLOBAL.IT_NAME])
	GLOBAL.items.erase(idx)
	SpellEngine.breakSanctuary(self, SpellEngine.SANCT_POTION)

func attemptLockpick(dc: int) -> bool:
	var roll = GeneralEngine.dice(1, 6, Skills.getLockpickBonus()).roll(self)
	if roll >= dc:
		Ref.ui.writeLockpickSuccess(roll)
		return true
	Ref.ui.writeLockpickFailure(roll)
	inventory.lockpicks -= 1
	return false

func search():
	Ref.ui.writeSearch()
	fatigue.searchCost()
	for i in range(-4, 5):
		for j in range(-4, 5):
			var cell = pos + Vector2(i, j)
			if Ref.currentLevel.fog.get_cellv(cell) != 0:
				continue
			if pow(i, 2) + pow(j, 2) <= 16:
				rollPerception(cell)
	GeneralEngine.newTurn()

func rollPerception(cell: Vector2):
	var perceptionRoll = stats.perception.roll(self)
	if perceptionRoll > 4:
		# Detect traps
		if GLOBAL.trapsByPos.has(cell):
			TrapEngine.reveal(cell)
	if perceptionRoll > 5:
		# Detect doors
		Ref.currentLevel.discoverDoor(cell)

func rest():
	inventory.rests -= 1
	for a in Ref.currentLevel.allies.get_children():
		a.queue_free()
	StatusEngine.clearStatuses(self)
	stats.updateHp(stats.hpMax)
	fatigue.refresh()
	for s in spells.spellsUses.keys():
		var school = Data.spells[s][Data.SP_SCHOOL]
		var rank = spells.getSpellRank(school)
		spells.spellsUses[s] = Data.spells[s][Data.SP_USES][rank]

func refreshMapPosition():
	position = 9 * pos

func getRandomCloseCell():
	if currentVision.empty():
		return null
	var result = Utils.chooseRandom(currentVision)
	while randf() > (1.0 / float(Utils.dist(pos, result))):
		result = Utils.chooseRandom(currentVision)
	return result

func getDisplaYStatusList() -> Array:
	var result = []
	for type in statuses.keys():
		var statusId = statuses[type][0]
		if not GLOBAL.statuses[statusId][GLOBAL.ST_HIDDEN]:
			result.append(statusId)
	return result

func ignore(entity) -> bool:
	return false
