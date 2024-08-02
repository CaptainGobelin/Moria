extends Node

func trigger(trap: Trap, entity):
	Ref.ui.writeTriggerTrap(trap.trapName)
	match trap.type:
		Data.TR_DART:
			entity.takeHit(GeneralEngine.dice(1, 4, 0).roll())
	GLOBAL.trapsByPos.erase(trap.pos)
	trap.disable()

func reveal(cell: Vector2):
	if !GLOBAL.trapsByPos.has(cell):
		return
	var trap = GLOBAL.getTrapByPos(cell)
	if !trap.hidden:
		return
	trap.reveal()
	Ref.ui.writeHiddenTrapDetected(trap.trapName)
