extends Node

func createItemEnchant(type: int, rank: int):
	var status: Array = []
	status.resize(GLOBAL.ST_HIDDEN + 1)
	status[GLOBAL.ST_TIMING] = GLOBAL.TIMING_UNDEF
	status[GLOBAL.ST_TYPE] = type
	status[GLOBAL.ST_RANK] = rank
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
			id = fireWeapon(entity, 1)
	if id == -1:
		return
	if entity.enchants.has(item):
		entity.enchants[item].append(id)
	else:
		entity.enchants[item] = [id]

func fireWeapon(entity, rank: int):
	var status = createItemEnchant(Data.STATUS_FIRE_WEAPON, rank)
	return StatusEngine.addStatus(entity, status)
