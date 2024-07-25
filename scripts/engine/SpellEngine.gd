extends Node

onready var effectScene = preload("res://scenes/Effect.tscn")

onready var throwings = get_node("Throwings")

func applyEffect(entity, spell):
	match spell:
		Data.SP_MAGIC_MISSILE:
			magicMissile(entity)
		Data.SP_HEAL:
			heal(entity)
		Data.SP_BLESS:
			bless(entity)
		Data.SP_FIREBALL:
			fireball(entity)
		Data.SP_TH_FIREBOMB:
			throwings.firebomb(entity)
		Data.SP_TH_POISON:
			throwings.poisonFlask(entity)
		Data.SP_TH_SLEEP:
			throwings.sleepFlask(entity)

func magicMissile(entity):
	entity.takeHit(GeneralEngine.dice(2, 1, 1).roll())

func heal(entity):
	var result:float = entity.stats.hpMax * 0.5
	entity.stats.hp += ceil(result)

func bless(entity):
	if entity is Character:
#		Ref.ui.statusBar.addStatus(Data.STATUS_BLESSED, Data.statuses[Data.STATUS_BLESSED][Data.ST_TURNS])
		pass

func fireball(entity):
	var targetedCells = getArea(entity.pos, 4)
	targetedCells.append(Vector2(0, 0))
	for cell in targetedCells:
		var pos = entity.pos + cell
		var effect = effectScene.instance()
		Ref.currentLevel.effects.add_child(effect)
		effect.play(pos, 0, 5, 0.1)
		if GLOBAL.monstersByPosition.has(pos):
			var target = instance_from_id(GLOBAL.monstersByPosition[pos])
			target.takeHit(GeneralEngine.dice(3, 6, 0).roll())

func getArea(pos: Vector2, size: int):
	var result = []
	var toCheck = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	var cells = {
		Vector2(-1, 0): [[2, Vector2(-1, -1)], [2, Vector2(-1, 1)], [3, Vector2(-2, 0)]],
		Vector2(1, 0): [[2, Vector2(1, -1)], [2, Vector2(1, 1)], [3, Vector2(2, 0)]],
		Vector2(0, -1): [[2, Vector2(-1, -1)], [2, Vector2(1, -1)], [3, Vector2(0, -2)]],
		Vector2(0, 1): [[2, Vector2(-1, 1)], [2, Vector2(1, 1)], [3, Vector2(0, 2)]],
		Vector2(-1, -1): [[4, Vector2(-2, -1)], [4, Vector2(-1, -2)]],
		Vector2(-1, 1): [[4, Vector2(-2, 1)], [4, Vector2(-1, 2)]],
		Vector2(1, -1): [[4, Vector2(2, -1)], [4, Vector2(1, -2)]],
		Vector2(1, 1): [[4, Vector2(2, 1)], [4, Vector2(1, 2)]]
	}
	for c in toCheck:
		if Ref.currentLevel.isCellFree(c + pos)[4]:
			continue
		if !result.has(c):
			result.append(c)
		if !cells.has(c):
			continue
		for cell in cells[c]:
			if cell[0] > size:
				continue
			toCheck.append(cell[1])
	return result
