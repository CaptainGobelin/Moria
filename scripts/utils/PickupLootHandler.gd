extends Node

func pickupLootAsync():
	var loots = GLOBAL.getItemList(Ref.character.pos)
	chooseLoot(loots)

func chooseLoot(loots: Dictionary):
	if loots.keys().size() == 0:
		Ref.ui.writeNoLoot()
	elif loots.keys().size() == 1:
		var idx = loots.keys()[0]
		if loots[idx].size() == 1:
			Ref.character.pickItem([loots[idx][0]])
		else:
			Ref.ui.askForNumber(loots[idx].size(), Ref.game)
			var coroutineReturn = yield(Ref.ui, "coroutine_signal")
			if coroutineReturn != null and coroutineReturn is int:
				Ref.character.pickItem(loots[idx].slice(0, coroutineReturn-1))
	else:
		Ref.ui.write(Ref.currentLevel.getLootChoice(loots))
		Ref.ui.askForChoice(loots.keys(), Ref.game)
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		if coroutineReturn > 0:
			chooseLoot({ 0: loots[loots.keys()[coroutineReturn-1]] })
