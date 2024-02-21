extends Node

func pickupLoot():
	var loots = Ref.currentLevel.checkForLoot(Ref.character.pos)
	if loots.size() == 0:
		Ref.ui.writeNoLoot()
	elif loots.size() == 1:
		if loots[0].size() == 1:
			Ref.character.pickItem(loots[0][0])
		else:
			Ref.ui.askForNumber(loots[0].size())
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn != null and coroutineReturn is int:
				for c in range(coroutineReturn):
					Ref.character.pickItem(loots[0][c])
	else:
		Ref.ui.write(Ref.currentLevel.getLootChoice(loots))
		Ref.ui.askForChoice(loots)
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		if coroutineReturn > 0:
			var newLoot = loots[coroutineReturn-1]
			if newLoot.size() == 1:
				Ref.character.pickItem(newLoot[0])
			else:
				Ref.ui.askForNumber(newLoot.size())
				coroutineReturn = yield(Ref.ui, "coroutine_signal")
				if coroutineReturn != null and coroutineReturn is int:
					for c in range(coroutineReturn):
						Ref.character.pickItem(newLoot[c])
