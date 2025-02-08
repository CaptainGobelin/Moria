extends Node

func createItemEnchant(type: int, rank: int):
	var status: Array = []
	status.resize(GLOBAL.ST_HIDDEN + 1)
	status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_UNDEF
	status[GLOBAL.ST_TYPE] = type
	status[GLOBAL.ST_RANK] = rank
	status[GLOBAL.ST_HIDDEN] = true
	return status

func removeEnchant(entity, item: int):
	if not entity.enchants.has(item):
		return
	for s in entity.enchants[item]:
		StatusEngine.removeStatus(entity, s)
	entity.enchants.erase(item)

func applyEffect(entity, enchant: int, item: int):
	var id = []
	match enchant:
		Data.ENCH_FIRE_RESIST_1:
			id = createStatus(entity, Data.STATUS_RESIST + Data.DMG_FIRE, 1)
		Data.ENCH_POIS_RESIST_1:
			id = createStatus(entity, Data.STATUS_RESIST + Data.DMG_POISON, 1)
		Data.ENCH_VISION:
			id = createStatus(entity, Data.STATUS_LIGHT, 2)
		Data.ENCH_BLESSED:
			id = createStatus(entity, Data.STATUS_PROTECT_EVIL, 1)
		Data.ENCH_PROTECTION:
			id = createStatus(entity, Data.STATUS_PROTECTION, 1)
		Data.ENCH_FLAMING_1:
			id = createStatus(entity, Data.STATUS_FIRE_WP, 1)
		Data.ENCH_VENOM_1:
			id = createStatus(entity, Data.STATUS_POIS_WP, 1)
		Data.ENCH_SHOCK_1:
			id = createStatus(entity, Data.STATUS_SHOCK_WP, 1)
		Data.ENCH_HOLY_1:
			id = createStatus(entity, Data.STATUS_HOLY_WP, 1)
		Data.ENCH_PRECISION:
			id = createStatus(entity, Data.STATUS_PRECISION, 1)
		Data.ENCH_MIND:
			id = createStatus(entity, Data.STATUS_WILLPOWER, 1)
		Data.ENCH_RESISTANCE:
			id = createStatus(entity, Data.STATUS_PHYSICS, 1)
		_:
			id = createStatus(entity, enchant + Data.STATUS_ENCHANT, 1)
	if id.empty():
		return
	if entity.enchants.has(item):
		entity.enchants[item].append_array(id)
	else:
		entity.enchants[item] = id

func createStatus(entity, type: int, rank: int):
	var status = createItemEnchant(type, rank)
	return [StatusEngine.addStatus(entity, status)]
