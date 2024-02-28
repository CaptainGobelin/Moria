extends Node

func applyEffect(entity, spell):
	match spell:
		Data.SP_MAGIC_MISSILE:
			magicMissile(entity)

func magicMissile(entity):
	entity.takeHit(Engine.rollDices(Vector2(2, 4)))
