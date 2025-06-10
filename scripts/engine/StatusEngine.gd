extends Node

var id = -1

class StatusSorter:
	static func sort_by_rank(a, b):
		if GLOBAL.statuses[a][GLOBAL.ST_RANK] == GLOBAL.statuses[b][GLOBAL.ST_RANK]:
			if GLOBAL.statuses[a][GLOBAL.ST_TIMING] != GLOBAL.TIMING_TIMER:
				return true
			if GLOBAL.statuses[b][GLOBAL.ST_TIMING] != GLOBAL.TIMING_TIMER:
				return false
			if GLOBAL.statuses[a][GLOBAL.ST_TURNS] > GLOBAL.statuses[b][GLOBAL.ST_TURNS]:
				return true
			return false
		if GLOBAL.statuses[a][GLOBAL.ST_RANK] > GLOBAL.statuses[b][GLOBAL.ST_RANK]:
			return true
		return false

func addStatus(entity, status: Array):
	id += 1
	status[GLOBAL.ST_ID] = id
	GLOBAL.statuses[id] = status
	var idx = status[GLOBAL.ST_TYPE]
	match idx:
		Data.STATUS_IMMOBILE:
			if getStatusRank(entity, Data.STATUS_FREED_MOVE) >= 0:
				return
		Data.STATUS_PARALYZED:
			if getStatusRank(entity, Data.STATUS_FREED_MOVE) >= 0:
				return
		Data.STATUS_TERROR:
			if getStatusRank(entity, Data.STATUS_FREED_MOVE) >= 1:
				return
	if entity.statuses.has(idx):
		entity.statuses[idx].append(id)
		entity.statuses[idx].sort_custom(StatusSorter, "sort_by_rank")
	else:
		entity.statuses[idx] = [id]
	if not status[GLOBAL.ST_HIDDEN] and entity is Character:
		Ref.ui.statusBar.refreshStatuses(Ref.character)
	return id

func removeStatusType(entity, type: int):
	if not entity.statuses.has(type):
		return
	for s in entity.statuses[type]:
		GLOBAL.statuses.erase(s)
	entity.statuses.erase(type)
	if entity is Character:
		Ref.ui.statusBar.refreshStatuses(Ref.character)

func removeStatus(entity, statusId: int):
	var type = GLOBAL.statuses[statusId][GLOBAL.ST_TYPE]
	if not entity.statuses.has(type):
		return
	for st in entity.statuses[type]:
		if st == statusId:
			GLOBAL.statuses.erase(statusId)
			entity.statuses[type].erase(statusId)
			if entity.statuses[type].empty():
				entity.statuses.erase(type)
			return

func removeRestStatuses(entity):
	var statusToRemove = []
	for type in entity.statuses:
		for s in entity.statuses[type]:
			var status = GLOBAL.statuses[s]
			if status[GLOBAL.ST_TIMING] == GLOBAL.TIMING_REST:
				statusToRemove.append(s)
	for s in statusToRemove:
		StatusEngine.removeStatus(entity, s)
	entity.stats.computeStats()
	if entity is Character:
		Ref.ui.statusBar.refreshStatuses(entity)

func removeFloorStatuses(entity):
	var statusToRemove = []
	for type in entity.statuses:
		for s in entity.statuses[type]:
			var status = GLOBAL.statuses[s]
			if status[GLOBAL.ST_TIMING] == GLOBAL.TIMING_FLOOR:
				statusToRemove.append(s)
	for s in statusToRemove:
		StatusEngine.removeStatus(entity, s)
	entity.stats.computeStats()
	if entity is Character:
		Ref.ui.statusBar.refreshStatuses(entity)

func clearStatuses(entity):
	var statusToRemove = []
	for type in entity.statuses:
		for s in entity.statuses[type]:
			var status = GLOBAL.statuses[s]
			if status[GLOBAL.ST_TIMING] != GLOBAL.TIMING_UNDEF:
				statusToRemove.append(s)
	for s in statusToRemove:
		StatusEngine.removeStatus(entity, s)
	entity.stats.computeStats()
	if entity is Character:
		Ref.ui.statusBar.refreshStatuses(entity)

func deleteStatus(statusId: int):
	GLOBAL.statuses.erase(statusId)
	for a in Ref.currentLevel.auras.get_children():
		if a.tiedStatus == statusId:
			a.queue_free()

func removeRandomBuff(entity) -> bool:
	var keys = entity.statuses.keys().duplicate()
	keys.shuffle()
	for type in keys:
		var s = entity.statuses[type][0]
		if !GLOBAL.statuses[s][GLOBAL.ST_DISPEL]:
			continue
		if !GLOBAL.statuses[s][GLOBAL.ST_BONUS]:
			continue
		removeStatusType(entity, type)
		entity.stats.computeStats()
		if entity is Character:
			Ref.ui.statusBar.refreshStatuses(entity)
		return true
	return false

func getStatusRank(entity, type: int) -> int:
	if not entity.statuses.has(type):
		return -1
	return GLOBAL.statuses[entity.statuses[type][0]][GLOBAL.ST_RANK]

func decreaseStatusesTime(entity):
	entity.stats.applyPoison()
	var toRefresh = false
	for type in entity.statuses.keys():
		for st in entity.statuses[type]:
			var status = GLOBAL.statuses[st]
			if status[GLOBAL.ST_TIMING] == GLOBAL.TIMING_TIMER:
				status[GLOBAL.ST_TURNS] -= 1
				if status[GLOBAL.ST_TURNS] <= 0:
					toRefresh = true
					entity.statuses[type].erase(st)
					GLOBAL.statuses.erase(st)
					if entity.statuses[type].empty():
						entity.statuses.erase(type)
	if entity is Character:
		Ref.ui.statusBar.refreshStatuses(Ref.character)
	if toRefresh:
		entity.stats.computeStats()

func decreaseStatusRank(entity, type: int, ranks: int) -> int:
	while ranks > 0:
		if not entity.statuses.has(type):
			return ranks
		var currentRank = getStatusRank(entity, type)
		if ranks > currentRank:
			ranks -= (currentRank + 1)
			removeStatus(entity, GLOBAL.statuses[entity.statuses[type][0]][GLOBAL.ST_ID])
		else:
			GLOBAL.statuses[entity.statuses[type][0]][GLOBAL.ST_RANK] -= ranks
			return 0
	return 0

func applyEffect(entity):
	for type in entity.statuses.values():
		var status = type[0]
		var statusItem = GLOBAL.statuses[status]
		var rank = statusItem[GLOBAL.ST_RANK]
		if statusItem[GLOBAL.ST_TYPE] >= Data.STATUS_ENCHANT:
			applyEnchantEffect(entity, statusItem, rank)
			continue
		if statusItem[GLOBAL.ST_TYPE] >= Data.STATUS_RESIST:
			addToResist(entity, statusItem[GLOBAL.ST_TYPE] - Data.STATUS_RESIST, rank)
			continue
		match GLOBAL.statuses[status][GLOBAL.ST_TYPE]:
			Data.STATUS_BLIND:
				addToHit(entity, -1)
			Data.STATUS_CURSE:
				addToSaves(entity, -2, -2)
			Data.STATUS_LIGHT:
				addToRange(entity, 1)
				if rank > 0:
					addToPerception(entity, 1)
			Data.STATUS_BLESSED:
				addToSaves(entity, 1, 1)
			Data.STATUS_PROTECTED:
				addToProt(entity, rank + 1)
			Data.STATUS_FIRE_WP:
				dmgWeapon(entity, rank, 4, Data.DMG_FIRE)
			Data.STATUS_SHOCK_WP:
				dmgWeapon(entity, rank, 4, Data.DMG_LIGHTNING)
			Data.STATUS_PRECISION:
				addToHit(entity, rank)
			Data.STATUS_WILLPOWER:
				addToSaves(entity, rank, 0)
			Data.STATUS_PHYSICS:
				addToSaves(entity, 0, rank)
			Data.STATUS_HOLY_BLADE:
				dmgWeapon(entity, 1, 4 + 2 * rank, Data.DMG_RADIANT)
			Data.STATUS_FIRE_BLADE:
				dmgWeapon(entity, 1, 4 + 2 * rank, Data.DMG_FIRE)
			Data.STATUS_FIRE_AURA:
				addToResist(entity, Data.DMG_FIRE, 1)
				if rank > 0:
					addToMaxResist(entity, Data.DMG_FIRE, 1)

func applyEnchantEffect(entity, status, rank: int):
	match (status[GLOBAL.ST_TYPE] - 1000):
		Data.ENCH_ARCANE_SHIELD:
			pass

func dmgWeapon(entity, rank: int, dice: int, type: int):
	entity.stats.addDmg(GeneralEngine.dmgDice(rank, dice, 0, type))

func addToHit(entity, rank: int):
	entity.stats.hitDices.b += rank
	if entity is Character:
		entity.stats.updateHit(entity.stats.hitDices)

func addToRange(entity, rank: int):
	entity.stats.atkRange += rank
	if entity is Character:
		Ref.currentLevel.refresh_view()

func addToPerception(entity, rank: int):
	if entity is Character:
		entity.stats.perception.b += rank

func addToSaves(entity, wil: int, phy: int):
	entity.stats.saveBonus[Data.SAVE_WIL] += wil
	entity.stats.saveBonus[Data.SAVE_PHY] += phy

func increaseDmgDices(entity, rank: int):
	entity.stats.dmgDices[0].dice.d += rank
	if entity is Character:
		entity.stats.updateDmg(entity.stats.dmgDices)

func addToAC(entity, rank: int):
	entity.stats.ca += rank
	if entity is Character:
		entity.stats.updateCA(entity.stats.ca)

func addToProt(entity, rank: int):
	entity.stats.prot += rank
	if entity is Character:
		entity.stats.updateProt(entity.stats.prot)

func addToResist(entity, dmgType: int, rank: int):
	entity.stats.resists[dmgType] += 1
	if rank == 2:
		entity.stats.maxResists[dmgType] += 1
	if entity is Character:
		entity.stats.updateResists()

func addToMaxResist(entity, dmgType: int, rank: int):
	entity.stats.maxResists[dmgType] += rank
	if entity is Character:
		entity.stats.updateResists()

func applyWeaponEffects(entity, target):
	if entity.statuses.has(Data.STATUS_POIS_WP):
		var rank = getStatusRank(entity, Data.STATUS_POIS_WP)
		SpellEngine.applyPoison(target, rank, 3)

func decreaseStatusRanks(entity, amount: int, type: int) -> int:
	if !entity.statuses.has(type):
		return amount
	var highestShield = GLOBAL.statuses[entity.statuses[type][0]]
	var result = max(0, amount - (highestShield[GLOBAL.ST_RANK] + 1))
	if result > 0:
		removeStatusType(entity, type)
		if entity is Character:
			Ref.ui.statusBar.refreshStatuses(Ref.character)
		return result
	for idx in entity.statuses[type]:
		var status = GLOBAL.statuses[idx]
		status[GLOBAL.ST_RANK] -= amount
		if status[GLOBAL.ST_RANK] < 0:
			entity.statuses[type].erase(idx)
			GLOBAL.statuses.erase(idx)
		else:
			status[GLOBAL.ST_NAME] = Data.statusPrefabs[type][0]
			status[GLOBAL.ST_NAME] += " " + Utils.toRoman(status[GLOBAL.ST_RANK] + 1)
	if entity.statuses[type].empty():
		entity.statuses.erase(type)
	return result

func createSimpleStatus(type: int, rank: int, turns: int):
	var status = Data.statusPrefabs[type].duplicate(true)
	if rank > 0:
		status[GLOBAL.ST_NAME] += " " + Utils.toRoman(rank + 1)
	status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_TIMER
	status[GLOBAL.ST_TURNS] = turns
	return status
