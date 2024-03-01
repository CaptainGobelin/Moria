extends Node2D
class_name Character

onready var animator = get_node("AnimationPlayer")
onready var stats = get_node("Stats")
onready var inventory = get_node("Inventory")
onready var spells = get_node("Spells")

var pos = Vector2(0, 0)

func _ready():
	Ref.character = self

func init():
	stats.init()

func setPosition(newPos):
	pos = newPos
	Ref.currentLevel.refresh_view()
	refreshMapPosition()

func moveAsync(movement):
	var cellState = Ref.currentLevel.isCellFree(pos + movement)
	if cellState[0]:
		pos += movement
		animator.play("walk")
		Ref.currentLevel.refresh_view()
		refreshMapPosition()
		GeneralEngine.newTurn()
		Ref.ui.write(Ref.currentLevel.getLootMessage(pos))
		return
	match cellState[1]:
		"door": 
			Ref.currentLevel.openDoor(pos + movement)
			Ref.currentLevel.refresh_view()
			GeneralEngine.newTurn()
		"monster":
			hit(cellState[2])
			GeneralEngine.newTurn()
		"pass": 
			Ref.ui.askToChangeFloor()
			Ref.ui.askForYesNo()
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if (coroutineReturn):
				Ref.game.newFloor()
				GeneralEngine.newTurn()
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
			Ref.ui.writeCharacterStrike(entity.stats.entityName, dmg, result, entity.stats.ca)
			entity.takeHit(dmg)
		else:
			Ref.ui.writeCharacterMiss(entity.stats.entityName, result, entity.stats.ca)

func takeHit(dmg):
	var totalDmg = dmg - stats.prot
	stats.hp -= totalDmg
	return totalDmg

func pickItem(idx):
	var item = GLOBAL.items[idx]
	instance_from_id(GLOBAL.itemsOnFloor[idx][1]).queue_free()
	match item[GLOBAL.IT_TYPE]:
		GLOBAL.WP_TYPE: inventory.weapons.append(idx)
		GLOBAL.AR_TYPE: inventory.armors.append(idx)
		GLOBAL.PO_TYPE: inventory.potions.append(idx)
	Ref.ui.write("You picked " + Utils.addArticle(item[GLOBAL.IT_NAME]) + ".")

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
	var loot = Ref.currentLevel.lootScene.instance()
	Ref.currentLevel.loots.add_child(loot)
	loot.init(idx, pos)
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

func refreshMapPosition():
	position = 9 * pos
