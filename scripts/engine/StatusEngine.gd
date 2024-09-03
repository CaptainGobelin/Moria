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
	entity.statuses.erase(type)

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

func getStatusRank(entity, type: int) -> int:
	if not entity.statuses.has(type):
		return -1
	return GLOBAL.statuses[entity.statuses[type][0]][GLOBAL.ST_RANK]

func decreaseStatusesTime(entity):
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
		var rank = GLOBAL.statuses[status][GLOBAL.ST_RANK]
		match GLOBAL.statuses[status][GLOBAL.ST_TYPE]:
			Data.STATUS_SLEEP:
				pass
			Data.STATUS_TERROR:
				pass
			Data.STATUS_BLIND:
				addToHit(entity, -1)
				addToRange(entity, -3)
			Data.STATUS_PARALYZED:
				pass
			Data.STATUS_VULNERABLE:
				pass
			Data.STATUS_LIGHT:
				addToRange(entity, 1)
				if rank > 0:
					addToPerception(entity, 1)
			Data.STATUS_DETECT_EVIL:
				pass
			Data.STATUS_REVEAL_TRAPS:
				pass
			Data.STATUS_BLESSED:
				addToSaves(entity, 1, 1)
			Data.STATUS_SHIELD:
				pass
			Data.STATUS_MAGE_ARMOR:
				pass
			Data.STATUS_ARMOR_FAITH:
				addToAC(entity, 1)
				if rank > 0:
					addToProt(entity, 1)
			Data.STATUS_PROTECT_EVIL:
				pass
			Data.STATUS_SANCTUARY:
				pass
			Data.STATUS_FIRE_WEAPON:
				dmgWeapon(entity, rank, 6, Data.DMG_FIRE)
			Data.STATUS_FROST_WEAPON:
				dmgWeapon(entity, rank, 4, Data.DMG_ICE)
			Data.STATUS_POISON_WEAPON:
				dmgWeapon(entity, rank, 4, Data.DMG_POISON)
			Data.STATUS_SHOCK_WEAPON:
				dmgWeapon(entity, rank, 4, Data.DMG_LIGHTNING)
			Data.STATUS_HOLY_WEAPON:
				dmgWeapon(entity, rank, 8, Data.DMG_RADIANT)
			Data.STATUS_PRECISE_WEAPON:
				addToHit(entity, rank)
			Data.STATUS_VORPAL_WEAPON:
				increaseDmgDices(entity, 2)

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
