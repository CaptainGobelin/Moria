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
		Data.SP_TARGET_RANDOM:
			if GLOBAL.targets.size() == 0:
				Ref.ui.noTarget()
				return
			if spellId == Data.SP_MAGIC_MISSILE:
				Ref.ui.writeCastSpell(spell[Data.SP_NAME])
				var targets = []
				for _i in (1 + spellRank):
					var targetId = Utils.chooseRandom(GLOBAL.targets.keys())
					targets.append(targetId)
					yield(castProjectile(GLOBAL.targets[targetId], spell[Data.SP_PROJ], "launched"), "completed")
				var targetId = Utils.chooseRandom(GLOBAL.targets.keys())
				targets.append(targetId)
				yield(castProjectile(GLOBAL.targets[targetId], spell[Data.SP_PROJ]), "completed")
				for target in targets:
					SpellEngine.applyEffect(Ref.character, instance_from_id(target), spellId, true, spellRank, savingCap)
			spellCasted = true
			SpellEngine.breakSanctuary(Ref.character, SpellEngine.SANCT_ATTACK)
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
			SpellEngine.applyEffect(Ref.character, instance_from_id(targetId), spellId, true, spellRank, savingCap)
			if spellId == Data.SP_LIGHT_BOLT:
				var rebound = spellRebound(spellId, Ref.character, instance_from_id(targetId), spellRank, savingCap, spellRank-1)
				if rebound is GDScriptFunctionState:
					yield(rebound, "completed")
			spellCasted = true
			SpellEngine.breakSanctuary(Ref.character, SpellEngine.SANCT_ATTACK)
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
			SpellEngine.applyEffect(Ref.character, Ref.character, spellId, true, spellRank, savingCap, coroutineReturn)
			spellCasted = true
			SpellEngine.breakSanctuary(Ref.character, SpellEngine.SANCT_ATTACK)
		Data.SP_TARGET_SELF:
			Ref.ui.writeCastSpell(spell[Data.SP_NAME])
			SpellEngine.applyEffect(Ref.character, Ref.character, spellId, true, spellRank, savingCap)
			spellCasted = true
			if Data.spells[spellId][Data.SP_SCHOOL] == Data.SC_ABJURATION:
				if Ref.character.statuses.has(Data.STATUS_ENCHANT + Data.ENCH_REJUVENATION):
					Ref.character.heal(3)
			SpellEngine.breakSanctuary(Ref.character, SpellEngine.SANCT_BUFF)
		Data.SP_TARGET_ITEM_CHOICE:
			Ref.ui.writeWishChoice()
			Ref.ui.askForChoice(wishableItems, Ref.game)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn > 0:
				SpellEngine.applyEffect(Ref.character, Ref.character, spellId, true, spellRank, wishableItems[coroutineReturn-1])
				spellCasted = true
				SpellEngine.breakSanctuary(Ref.character, SpellEngine.SANCT_BUFF)
	if (spellCasted):
		if scrollId == null:
			Ref.character.spells.spellsUses[spellId] -= 1
			Ref.character.shortcuts.refreshShortcuts(spellId)
		else:
			Ref.character.inventory.scrolls.erase(scrollId)
			Ref.character.shortcuts.refreshShortcuts(GLOBAL.items[scrollId][GLOBAL.IT_STACK])
			GLOBAL.items.erase(scrollId)
		Ref.character.fatigue.spellCost()
		GeneralEngine.newTurn()

func castProjectile(path: Array, projInfo, yieldFor: String = "end_coroutine"):
	var p = projScene.instance()
	Ref.currentLevel.effects.add_child(p)
	p.init(path, projInfo[Data.PROJ_TYPE], projInfo[Data.PROJ_COLOR])
	yield(p, yieldFor)

func castSpellMonster(spellId: int, caster, target, path: Array):
	var spell = Data.spells[spellId]
	Ref.ui.writeMonsterCastSpell(caster.stats.entityName, spell[Data.SP_NAME])
	if spell[Data.SP_PROJ] != null:
		castProjectile(path, spell[Data.SP_PROJ])
	var savingCap = caster.stats.spellcasterLevel + 3
	var spellRank = max(1, min(caster.stats.spellcasterLevel, 3))
	SpellEngine.applyEffect(caster, target, spellId, true, spellRank, savingCap)
	if target is Character:
		SpellEngine.breakSanctuary(caster, SpellEngine.SANCT_ATTACK)
	else:
		SpellEngine.breakSanctuary(caster, SpellEngine.SANCT_BUFF)

func spellRebound(spellId: int, caster, initial, spellRank: int, savingCap: int, n: int):
	var targets = [Ref.currentLevel.allies.get_children()]
	targets.append(Ref.character)
	if caster is Character:
		targets = Ref.currentLevel.monsters.get_children()
	elif caster is Monster and caster.status == "help":
		targets = Ref.currentLevel.monsters.get_children()
	targets.shuffle()
	for m in targets:
		if m == initial:
			continue
		if m.status == "dead" or m.status == "help":
			continue
		var los = Ref.currentLevel.canTarget(initial.pos, m.pos)
		if los.empty():
			continue
		if los.size() > 5:
			continue
		yield(castProjectile(los, Data.spells[spellId][Data.SP_PROJ]), "completed")
		SpellEngine.applyEffect(caster, m, spellId, true, spellRank, savingCap)
		if n > 1:
			yield(spellRebound(spellId, caster, m, spellRank, savingCap, n - 1), "completed")
		return
