extends Node

func triggerTrap(trapId: int, entity):
	var trap = instance_from_id(trapId) as Trap
	Ref.ui.writeTriggerTrap(trap.trapName)
	match trap.type:
		Data.TR_DART:
			entity.takeHit(GeneralEngine.dice(1, 4, 0).roll())
	GLOBAL.traps.erase(trap.pos)
	trap.frame += 1
	trap.visible = true
