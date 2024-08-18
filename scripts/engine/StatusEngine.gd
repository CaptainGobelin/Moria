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

func applyEffect(entity):
	for type in entity.statuses.values():
		var status = type[0]
		var rank = GLOBAL.statuses[status][GLOBAL.ST_RANK]
		match GLOBAL.statuses[status][GLOBAL.ST_TYPE]:
			Data.STATUS_BLESSED:
				blessed(entity, rank)
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
				increaseDmgDices(entity, rank)

func blessed(entity, rank: int):
	entity.stats.hitDices.b += 1

func dmgWeapon(entity, rank: int, dice: int, type: int):
	entity.stats.addDmg(GeneralEngine.dmgDice(rank, dice, 0, type))

func addToHit(entity, rank: int):
	entity.stats.hitDices.b += 1
	entity.stats.updateHit(entity.stats.hitDices)

func increaseDmgDices(entity, rank: int):
	entity.stats.dmgDices[0].dice.d += 1
	entity.stats.updateDmg(entity.stats.dmgDices)
