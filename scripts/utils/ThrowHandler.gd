extends Node

onready var projScene = preload("res://scenes/Projectile.tscn")

func throwAsync(itemId: int):
	var item = Data.throwings[GLOBAL.items[itemId][GLOBAL.IT_BASE]]
	if GLOBAL.targets.size() == 0:
		Ref.ui.noTarget()
		return
	Ref.game.set_process_input(false)
	Ref.ui.askForTarget(GLOBAL.targets.keys(), Ref.game)
	var coroutineReturn = yield(Ref.ui, "coroutine_signal")
	if coroutineReturn == -1:
		return
	var targetId = GLOBAL.targets.keys()[coroutineReturn]
	yield(castProjectile(GLOBAL.targets[targetId], item[Data.TH_PROJ]), "completed")
	if item[Data.TH_DMG] != null:
		var entity = instance_from_id(targetId)
		var result = GeneralEngine.rollDices(Ref.character.stats.hitDices)
		if result >= entity.stats.ca:
			Ref.ui.writeCharacterStrike(entity.stats.entityName, result, entity.stats.ca)
			entity.takeHit(GeneralEngine.rollDices(item[Data.TH_DMG]))
		else:
			Ref.ui.writeCharacterMiss(entity.stats.entityName, result, entity.stats.ca)
	if item[Data.TH_EFFECT] != null:
		SpellEngine.applyEffect(instance_from_id(targetId), item[Data.TH_EFFECT])
	Ref.character.inventory.throwings.erase(itemId)
	Ref.game.set_process_input(true)
	GeneralEngine.newTurn()

func castProjectile(path: Array, projInfo):
	var p = projScene.instance()
	Ref.currentLevel.effects.add_child(p)
	p.init(path, projInfo[Data.PROJ_TYPE], projInfo[Data.PROJ_COLOR])
	yield(p, "end_coroutine")
