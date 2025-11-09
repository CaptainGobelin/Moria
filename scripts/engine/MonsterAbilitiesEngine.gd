extends Node

func applyEffect(caster, entity, spellId: int, fromCharacter: bool, rank: int, savingCap: int, direction: Vector2 = Vector2(0, 0)):
	get_parent().saveType = Data.spells[spellId][Data.SP_SAVE]
	get_parent().fromChar = fromCharacter
	get_parent().saveCap = savingCap
	match spellId:
		Data.SP_ZOMBIE_SCREAM:
			zombieScream(caster)
		Data.SP_SPIDER_BITE:
			spiderBite(caster, entity)
		Data.SP_SNAKE_CONSTRICT:
			snakeConstrict(caster, entity)
		Data.SP_LEECH_BITE:
			leechBite(caster, entity)
		Data.SP_TROLL_NET:
			trollNet(caster, entity)
		Data.SP_TROLL_STUN:
			trollStun(caster, entity)
		Data.SP_TROLL_RAGE:
			trollRage(caster)

func zombieScream(caster):
	var spellRange = Data.spells[Data.SP_ZOMBIE_SCREAM][Data.SP_AREA]
	var targetedCells = get_parent().getArea(caster.pos, spellRange)
	for cell in targetedCells:
		var pos = caster.pos + cell
		var target = get_parent().getValidTarget(pos)
		if target == null:
			continue
		get_parent().playEffect(target.pos, Effect.SKULL, 5, 0.45)
		if not get_parent().rollsavingThrow(caster, target):
			get_parent().applySpellStatus(target, Data.STATUS_TERROR, 0, 4)

func spiderBite(caster, target):
	if not get_parent().rollsavingThrow(caster, target):
		get_parent().applySpellStatus(target, Data.STATUS_POISON, 1, 11)
		var dmg = GeneralEngine.computeDamages(caster, [GeneralEngine.dmgDiceFromArray([1, 4, 0, Data.DMG_SLASH])], target.stats.resists)
		target.takeHit(dmg)

func snakeConstrict(caster, target):
	if not get_parent().rollsavingThrow(caster, target):
		get_parent().applySpellStatus(target, Data.STATUS_PARALYZED, 0, 2)

func leechBite(caster, target):
	if not get_parent().rollsavingThrow(caster, target):
		var dmg = GeneralEngine.computeDamages(caster, [GeneralEngine.dmgDiceFromArray([1, 4, 0, Data.DMG_SLASH])], target.stats.resists)
		var heal = target.takeHit(dmg)
		if heal > 0:
			caster.heal(heal)
			get_parent().playEffect(caster.pos, Effect.HEAL, 5, 0.6)

func trollNet(caster, target):
	get_parent().applySpellStatus(target, Data.STATUS_IMMOBILE, 0, 11)

func trollStun(caster, target):
	if not get_parent().rollsavingThrow(caster, target):
		get_parent().applySpellStatus(target, Data.STATUS_PARALYZED, 0, 3)
		var dmg = GeneralEngine.computeDamages(caster, [GeneralEngine.dmgDiceFromArray([1, 8, 0, Data.DMG_BLUNT])], target.stats.resists)
		target.takeHit(dmg)

func trollRage(caster):
	get_parent().applySpellStatus(caster, Data.STATUS_TROLL_RAGE, 0, 15)
