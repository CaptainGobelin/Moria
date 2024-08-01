extends Node

onready var projScene = preload("res://scenes/Projectile.tscn")

var wishableItems = [0, 1, 4, 5, 7]

func castSpellAsync(spellId: int, scrollId = null):
	var spellCasted = false
	var spell = Data.spells[spellId]
	var savingCap = 0
	if spell[Data.SP_SAVE] != Data.SAVE_NO:
		savingCap = Data.SAVING_BASE + Ref.character.spells.getSavingThrow(spell[Data.SP_SCHOOL])
	var spellRank = Ref.character.spells.getSpellRank(spell[Data.SP_SCHOOL])
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
			if spell[Data.SP_PROJ] != null:
				yield(castProjectile(GLOBAL.targets[targetId], spell[Data.SP_PROJ]), "completed")
			SpellEngine.applyEffect(instance_from_id(targetId), spellId, true, spellRank, savingCap)
			spellCasted = true
		Data.SP_TARGET_DIRECT:
			Ref.ui.writeSpellDirection()
			Ref.ui.askForDirection(Ref.game)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn == Vector2(0, 0):
				return
			# Special case for unlock spell
			if spellId == Data.SP_UNLOCK:
				var doorPos = Ref.character.pos + coroutineReturn
				var chest = GLOBAL.getChestByPos(doorPos)
				if (not GLOBAL.lockedDoors.has(doorPos)) or GLOBAL.hiddenDoors.has(doorPos):
					if chest == null or chest[GLOBAL.CH_LOCKED] <= 0:
						Ref.ui.writeNoLockedDoor()
						return
			Ref.ui.writeCastSpell(spell[Data.SP_NAME])
			SpellEngine.applyEffect(Ref.character, spellId, true, spellRank, savingCap, coroutineReturn)
			spellCasted = true
		Data.SP_TARGET_SELF:
			Ref.ui.writeCastSpell(spell[Data.SP_NAME])
			SpellEngine.applyEffect(Ref.character, spellId, true, spellRank, savingCap)
			spellCasted = true
		Data.SP_TARGET_ITEM_CHOICE:
			Ref.ui.writeWishChoice()
			Ref.ui.askForChoice(wishableItems, self)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn > 0:
				SpellEngine.applyEffect(Ref.character, spellId, true, spellRank, wishableItems[coroutineReturn-1])
				spellCasted = true
	if (spellCasted):
		if scrollId == null:
			Ref.character.spells.spellsUses[spellId] -= 1
		else:
			Ref.character.inventory.scrolls.erase(scrollId)
		GeneralEngine.newTurn()

func castProjectile(path: Array, projInfo):
	var p = projScene.instance()
	Ref.currentLevel.effects.add_child(p)
	p.init(path, projInfo[Data.PROJ_TYPE], projInfo[Data.PROJ_COLOR])
	yield(p, "end_coroutine")
