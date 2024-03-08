extends Node

func triggerTrap(trapId: int, entity):
	var trap = instance_from_id(trapId) as Trap
	Ref.ui.writeTriggerTrap(trap.trapName)
	match trap.type:
		Data.TR_DART:
			entity.takeHit(GeneralEngine.rollDices(Vector2(1,4)))
	GLOBAL.traps.erase(trap.pos)
	trap.queue_free()
