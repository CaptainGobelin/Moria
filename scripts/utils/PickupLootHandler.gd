extends Node

func pickupLootAsync():
	var loots = GLOBAL.getItemList(Ref.character.pos)
	if loots.keys().size() == 0:
		Ref.ui.writeNoLoot()
		return
	if GLOBAL.isForSell(Ref.character.pos):
		var price = GLOBAL.itemsOnFloor[Ref.character.pos][GLOBAL.FLOOR_PRICE]
		buyLoot(loots, price)
	else:
		chooseLoot(loots)

func chooseLoot(loots: Dictionary):
	if loots.keys().size() == 1:
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

func buyLoot(loots: Dictionary, price: int):
	if Ref.character.inventory.golds < price:
		Ref.ui.writeNoMoney()
		return
	Ref.ui.writeAskToBuy(price)
	Ref.ui.askForYesNo(Ref.game)
	var coroutineReturnChoice = yield(Ref.ui, "coroutine_signal")
	if (not coroutineReturnChoice):
		return
	var idx = loots.keys()[0]
	if loots[idx].size() == 1:
		Ref.character.pickItem([loots[idx][0]], price)
	else:
		Ref.ui.askForNumber(loots[idx].size(), Ref.game)
		var coroutineReturn = yield(Ref.ui, "coroutine_signal")
		if coroutineReturn != null and coroutineReturn is int:
			if Ref.character.inventory.golds < (coroutineReturn * price):
				Ref.ui.writeNoMoney()
			else:
				Ref.character.pickItem(loots[idx].slice(0, coroutineReturn-1), (coroutineReturn * price))
