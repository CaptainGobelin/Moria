extends Node2D
class_name Character

onready var animator = get_node("AnimationPlayer")
onready var stats = get_node("Stats")
onready var inventory = get_node("Inventory")
onready var spells = get_node("Spells")
onready var shortcuts = get_node("Shortcuts")

var pos = Vector2(0, 0)

func _ready():
	Ref.character = self

func init():
	stats.init()
	inventory.init()

func setPosition(newPos):
	pos = newPos
	Ref.currentLevel.refresh_view()
	refreshMapPosition()

func moveAsync(movement):
	var cellState = Ref.currentLevel.isCellFree(pos + movement)
	if cellState[0]:
		pos += movement
		animator.play("walk")
		GeneralEngine.newTurn()
		Ref.currentLevel.refresh_view()
		refreshMapPosition()
		Ref.ui.write(Ref.currentLevel.getLootMessage(pos))
		if GLOBAL.traps.has(pos):
			var trap = GLOBAL.traps[pos]
			if trap[GLOBAL.TR_HIDDEN]:
				TrapEngine.triggerTrap(trap[GLOBAL.TR_INSTANCE], self)
		return
	match cellState[1]:
		"door": 
			if GLOBAL.lockedDoors.has(pos + movement):
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
						Ref.currentLevel.refresh_view()
			else:
				Ref.currentLevel.openDoor(pos + movement)
				GeneralEngine.newTurn()
				Ref.currentLevel.refresh_view()
		"monster":
			hit(cellState[2])
			GeneralEngine.newTurn()
		"pass": 
			Ref.ui.askToChangeFloor()
			Ref.ui.askForYesNo(Ref.game)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if (coroutineReturn):
				Ref.game.newFloor()
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
			GeneralEngine.newTurn()

func hit(entity):
	if entity == null:
		return
	if entity.is_in_group("Monster"):
		var result = GeneralEngine.rollDices(stats.hitDices)
		if result >= entity.stats.ca:
			var rolledDmg = GeneralEngine.rollDices(stats.dmgDices)
			var dmg = entity.checkDmg(rolledDmg)
			Ref.ui.writeCharacterStrike(entity.stats.entityName, result, entity.stats.ca)
			entity.takeHit(dmg)
		else:
			Ref.ui.writeCharacterMiss(entity.stats.entityName, result, entity.stats.ca)

func takeHit(dmg):
	var totalDmg = dmg - stats.prot
	stats.hp -= totalDmg
	Ref.ui.writeCharacterTakeHit(totalDmg)
	return totalDmg

func pickItem(items: Array):
	var item = GLOBAL.items[items[0]]
	for idx in items:
		GLOBAL.removeItemFromFloor(idx)
		match item[GLOBAL.IT_TYPE]:
			GLOBAL.WP_TYPE: inventory.weapons.append(idx)
			GLOBAL.AR_TYPE: inventory.armors.append(idx)
			GLOBAL.PO_TYPE: inventory.potions.append(idx)
			GLOBAL.TH_TYPE: inventory.throwings.append(idx)
			GLOBAL.TA_TYPE: inventory.talismans.append(idx)
			GLOBAL.LO_TYPE: inventory.lockpicks += item[GLOBAL.IT_SPEC]
			GLOBAL.GO_TYPE: inventory.golds += item[GLOBAL.IT_SPEC]
	if item[GLOBAL.IT_TYPE] == GLOBAL.LO_TYPE or item[GLOBAL.IT_TYPE] == GLOBAL.GO_TYPE:
		Ref.ui.write("You picked " + Utils.addArticle(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC]) + ".")
	else:
		Ref.ui.write("You picked " + Utils.addArticle(item[GLOBAL.IT_NAME], items.size()) + ".")

func dropItem(idx):
	var item = GLOBAL.items[idx]
	unequipItem(idx)
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE:
			inventory.weapons.erase(idx)
		GLOBAL.AR_TYPE:
			inventory.armors.erase(idx)
		GLOBAL.PO_TYPE:
			inventory.potions.erase(idx)
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

func attemptLockpick(dd: int):
	var roll = GeneralEngine.rollDices(Vector2(1, 6))
	if roll >= dd:
		Ref.ui.writeLockpickSuccess(roll)
		return true
	Ref.ui.writeLockpickFailure(roll)
	inventory.lockpicks -= 1
	return false

func search():
	Ref.ui.writeSearch()
	for i in range(-4, 5):
		for j in range(-4, 5):
			var cell = pos + Vector2(i, j)
			if Ref.currentLevel.fog.get_cellv(cell) != 0:
				continue
			if pow(i, 2) + pow(j, 2) <= 16:
				rollPerception(cell)

func rollPerception(cell: Vector2):
	var perceptionRoll = GeneralEngine.rollDices(Vector2(1, 6))
	if perceptionRoll > 3:
		# Detect traps
		if GLOBAL.traps.has(cell):
			var trap = GLOBAL.traps[cell]
			if trap[GLOBAL.TR_HIDDEN]:
				trap[GLOBAL.TR_HIDDEN] = false
				instance_from_id(trap[GLOBAL.TR_INSTANCE]).visible = true
				var trapData = Data.traps[trap[GLOBAL.TR_TYPE]]
				Ref.ui.writeHiddenTrapDetected(trapData[Data.TR_NAME])
	if perceptionRoll > 5:
		# Detect doors
		if GLOBAL.hiddenDoors.has(cell):
			GLOBAL.hiddenDoors.erase(cell)
			Ref.currentLevel.dungeon.set_cellv(cell, GLOBAL.DOOR_ID, false, false, false, Vector2(0,1))
			Ref.ui.writeHiddenDoorDetected()

func refreshMapPosition():
	position = 9 * pos
