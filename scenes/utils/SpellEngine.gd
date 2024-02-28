extends Node

func applyEffect(entity, spell):
	match spell:
		Data.SP_MAGIC_MISSILE:
			magicMissile(entity)
		Data.SP_HEAL:
			heal(entity)

func magicMissile(entity):
	entity.takeHit(Engine.rollDices(Vector2(2, 4)))

func heal(entity):
	var result:float = entity.stats.hpMax * 0.5
	entity.stats.hp += ceil(result)
