extends Node

onready var projScene = preload("res://scenes/Projectile.tscn")

func castSpellAsync(spellId: int, scrollId = null):
	var spell = Data.spells[spellId]
	if scrollId == null:
		if Ref.character.spells.spellsUses[spellId] == 0:
			Ref.ui.writeNoSpell(spell[Data.SP_NAME])
			return
	match spell[Data.SP_TARGET]:
		Data.SP_TARGET_TARGET:
			if GLOBAL.targets.size() == 0:
				Ref.ui.noTarget()
				return
			Ref.game.set_process_input(false)
			Ref.ui.askForTarget(GLOBAL.targets.keys(), Ref.game)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn == -1:
				return
			var targetId = GLOBAL.targets.keys()[coroutineReturn]
			Ref.ui.writeCastSpell(spell[Data.SP_NAME])
			yield(castProjectile(GLOBAL.targets[targetId], spell[Data.SP_PROJ]), "completed")
			SpellEngine.applyEffect(instance_from_id(targetId), spellId)
			if scrollId == null:
				Ref.character.spells.spellsUses[spellId] -= 1
			else:
				Ref.character.inventory.scrolls.erase(scrollId)
			Ref.game.set_process_input(true)
		Data.SP_TARGET_SELF:
			Ref.ui.writeCastSpell(spell[Data.SP_NAME])
			SpellEngine.applyEffect(Ref.character, spellId)
			Ref.character.spells.spellsUses[spellId] -= 1
	GeneralEngine.newTurn()

func castProjectile(path: Array, projInfo):
	var p = projScene.instance()
	Ref.currentLevel.effects.add_child(p)
	p.init(path, projInfo[Data.PROJ_TYPE], projInfo[Data.PROJ_COLOR])
	yield(p, "end_coroutine")
