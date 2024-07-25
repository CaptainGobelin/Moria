extends Node

var id = -1

class StatusSorter:
	static func sort_by_rank(a, b):
		if GLOBAL.statuses[a][GLOBAL.ST_RANK] == GLOBAL.statuses[b][GLOBAL.ST_RANK]:
			if GLOBAL.statuses[a][GLOBAL.ST_TURNS] > GLOBAL.statuses[b][GLOBAL.ST_TURNS]:
				return true
			return false
		if GLOBAL.statuses[a][GLOBAL.ST_RANK] > GLOBAL.statuses[b][GLOBAL.ST_RANK]:
			return true
		return false

func addStatus(entity, status: Array):
	id += 1
	status[GLOBAL.ST_ID] = id
	var idx = status[GLOBAL.ST_TYPE]
	if entity.statuses.has(idx):
		entity.statuses[idx].append(id)
		entity.statuses[idx].sort_custom(StatusSorter, "sort_by_rank")
	else:
		entity.statuses[idx] = [id]
	GLOBAL.statuses[id] = status
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

func decreaseStatusesTime(statuses: Dictionary):
	for type in statuses:
		for st in type:
			if st[GLOBAL.ST_TIMING] == GLOBAL.TIMING_TIMER:
				st[GLOBAL.ST_TURNS] -= 1
				if st[GLOBAL.ST_TURNS] <= 0:
					type.erase(st)
					if type.empty():
						statuses.erase(type)

func applyEffect(entity):
	for type in entity.statuses.values():
		for status in type:
			match GLOBAL.statuses[status][GLOBAL.ST_TYPE]:
				Data.STATUS_BLESSED:
					blessed(entity, GLOBAL.statuses[status][GLOBAL.ST_RANK])
				Data.STATUS_FIRE_WEAPON:
					fireWeapon(entity, GLOBAL.statuses[status][GLOBAL.ST_RANK])

func blessed(entity, rank: int):
	pass

func fireWeapon(entity, rank: int):
	entity.stats.addDmg(GeneralEngine.dmgDice(1, 4, 0, Data.DMG_FIRE))
