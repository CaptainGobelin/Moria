extends Node

func applyEffect(caster, entity, spellId: int, fromCharacter: bool, rank: int, savingCap: int, direction: Vector2 = Vector2(0, 0)):
	get_parent().saveType = Data.spells[spellId][Data.SP_SAVE]
	get_parent().fromChar = fromCharacter
	match spellId:
		Data.SP_ZOMBIE_SCREAM:
			zombieScream(caster)

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
