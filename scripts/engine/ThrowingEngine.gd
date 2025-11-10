extends Node

func firebomb(entity):
	var targetedCells = get_parent().getArea(entity, 2, true)
	var dmgDice = GeneralEngine.dmgDiceFromArray(Data.spellDamages[Data.SP_TH_FIREBOMB][0])
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = get_parent().effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, Effect.FIRE, 5)
		if GLOBAL.monstersByPosition.has(pos):
			var target = instance_from_id(GLOBAL.monstersByPosition[pos])
			target.takeHit(dmgDice.roll())

func holyWater(entity):
	var targetedCells = get_parent().getArea(entity, 2, true)
	var dmgDice = GeneralEngine.dmgDiceFromArray(Data.spellDamages[Data.SP_TH_HOLY][0])
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = get_parent().effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, Effect.SPARK, 5)
		if GLOBAL.monstersByPosition.has(pos):
			var target = instance_from_id(GLOBAL.monstersByPosition[pos])
			if Data.hasTag(target, Data.TAG_EVIL):
				target.takeHit(dmgDice.roll())

func sleepFlask(entity):
	var targetedCells = get_parent().getArea(entity, 3, true)
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = get_parent().effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, 4, 5)
		if GLOBAL.monstersByPosition.has(pos):
			var target = instance_from_id(GLOBAL.monstersByPosition[pos])
			target.takeHit(GeneralEngine.dice(1, 6, 0).roll())
