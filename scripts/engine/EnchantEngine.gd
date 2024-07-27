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
	var id = -1
	match enchant:
		Data.ENCH_FIRE_DMG:
			id = weaponEnch(entity, Data.STATUS_FIRE_WEAPON, 1)
		Data.ENCH_FROST_DMG:
			id = weaponEnch(entity, Data.STATUS_FROST_WEAPON, 1)
		Data.ENCH_POISON_DMG:
			id = weaponEnch(entity, Data.STATUS_POISON_WEAPON, 1)
		Data.ENCH_SHOCK_DMG:
			id = weaponEnch(entity, Data.STATUS_SHOCK_WEAPON, 1)
		Data.ENCH_HOLY_WP:
			id = weaponEnch(entity, Data.STATUS_HOLY_WEAPON, 1)
		Data.ENCH_PRECISE_WP:
			id = weaponEnch(entity, Data.STATUS_PRECISE_WEAPON, 1)
		Data.ENCH_VORP_WP:
			id = weaponEnch(entity, Data.STATUS_VORPAL_WEAPON, 1)
	if id == -1:
		return
	if entity.enchants.has(item):
		entity.enchants[item].append(id)
	else:
		entity.enchants[item] = [id]

func weaponEnch(entity, type: int, rank: int):
	var status = createItemEnchant(type, rank)
	return StatusEngine.addStatus(entity, status)
