extends Node

func firebomb(entity):
	var targetedCells = get_parent().getArea(entity, 2, true)
	var dmgDice = GeneralEngine.dmgDiceFromArray(Data.spellDamages[Data.SP_TH_FIREBOMB][0])
	var targets = GLOBAL.getAllTargets(entity.pos, targetedCells)
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = get_parent().effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, Effect.FIRE)
	for target in targets:
		target.takeHit(null, [dmgDice])

func holyWater(entity):
	var targetedCells = get_parent().getArea(entity, 2, true)
	var dmgDice = GeneralEngine.dmgDiceFromArray(Data.spellDamages[Data.SP_TH_HOLY][0])
	var targets = GLOBAL.getAllTargets(entity.pos, targetedCells)
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = get_parent().effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, Effect.SPARK)
	for target in targets:
		if Data.hasTag(target, Data.TAG_EVIL):
			target.takeHit(null, [dmgDice])

func sleepFlask(entity):
	var targetedCells = get_parent().getArea(entity, 3, true)
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = get_parent().effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, 4)
		# TODO
#		if GLOBAL.monstersByPosition.has(pos):
#			var target = instance_from_id(GLOBAL.monstersByPosition[pos])
#			target.takeHit(GeneralEngine.dice(1, 6, 0).roll())
