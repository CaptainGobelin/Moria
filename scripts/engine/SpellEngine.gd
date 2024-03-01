extends Node

onready var effectScene = preload("res://scenes/Effect.tscn")

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

func magicMissile(entity):
	entity.takeHit(GeneralEngine.rollDices(Vector2(2, 1)))

func heal(entity):
	var result:float = entity.stats.hpMax * 0.5
	entity.stats.hp += ceil(result)

func bless(entity):
	if entity is Character:
		Ref.ui.statusBar.addStatus(Data.STATUS_BLESSED, Data.statuses[Data.STATUS_BLESSED][Data.ST_TURNS])

func fireball(entity):
	for i in range(-1, 2):
		for j in range(-1, 2):
			var pos = entity.pos + Vector2(i, j)
			var effect = effectScene.instance()
			Ref.currentLevel.effects.add_child(effect)
			effect.play(pos, 0, 5)
			if GLOBAL.monstersByPosition.has(pos):
				var target = instance_from_id(GLOBAL.monstersByPosition[pos])
				target.takeHit(GeneralEngine.rollDices(Vector2(3, 1)))
