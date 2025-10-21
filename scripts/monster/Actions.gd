extends Node

var throwings: Dictionary = {}
var spells: Dictionary = {}
var buffs: Dictionary = {}
var debuffs: Dictionary = {}
var abilities: Dictionary = {}
var heals: Dictionary = {}
var selfBuffs: Dictionary = {}
var selfHeals: Dictionary = {}

func init(type: int):
	for action in Data.monsters[get_parent().type][Data.MO_ACTIONS]:
		match action[Data.ACT_TYPE]:
			Data.ACT_THROW:
				throwings[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
			Data.ACT_SPELL:
				spells[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
			Data.ACT_BUFF:
				if action[Data.ACT_SUBTYPE] == Data.ACT_SUBTYPE_POTION:
					selfBuffs[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
				else:
					buffs[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
			Data.ACT_DEBUFF:
				debuffs[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
			Data.ACT_ABILITY:
				abilities[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
			Data.ACT_HEAL:
				if action[Data.ACT_SUBTYPE] == Data.ACT_SUBTYPE_POTION:
					selfHeals[action[Data.ACT_ID]] = action[Data.ACT_COUNT]
				else:
					heals[action[Data.ACT_ID]] = action[Data.ACT_COUNT]

func initAbilitiesCD():
	for a in abilities.keys():
		get_parent().abilitiesCD[a] = randi() % Data.spells[a][Data.SP_USES]

func getAction(dict: Dictionary, type: String, dist: int = 99):
	if dict.empty():
		return null
	return [Utils.chooseRandom(dict.keys()), type]

func getAbility(dist: int, cooldowns: Array):
	if abilities.empty():
		return null
	var size = abilities.keys().size()
	var shift = randi() % size
	for i in range(size):
		var id = abilities.keys()[(i + shift) % size]
		if cooldowns.has(id):
			continue
		var ability = Data.spells[id]
		if ability[Data.SP_AREA] == null:
			return [id, "ability"]
		if ability[Data.SP_AREA] >= (dist-1):
			return [id, "ability"]
	return null

func getDistanceAttack():
	var action = null
	if randf() < 0.5:
		action = getAction(spells, "spell")
		if action != null:
			return action
		return getAction(throwings, "throwing")
	else:
		action = getAction(throwings, "throwing")
		if action != null:
			return action
		return getAction(spells, "spell")

func getSelfBuff():
	if randf() < 0.5:
		var action = getAction(selfBuffs, "selfBuff")
		if action != null:
			return action
		return getAction(buffs, "buff")
	var action = getAction(buffs, "buff")
	if action != null:
		return getAction(selfBuffs, "selfBuff")

func getSelfHeal():
	if randf() < 0.5:
		var action = getAction(selfHeals, "selfHeal")
		if action != null:
			return action
		return getAction(heals, "heal")
	var action = getAction(heals, "heal")
	if action != null:
		return getAction(selfHeals, "selfHeal")

func consumeAction(id: int, type: String):
	match type:
		"throwing":
			reduceActionCount(id, throwings)
		"spell":
			reduceActionCount(id, spells)
		"buff":
			reduceActionCount(id, buffs)
		"selfBuff":
			reduceActionCount(id, selfBuffs)
		"heal":
			reduceActionCount(id, heals)
		"selfHeal":
			reduceActionCount(id, selfHeals)

func reduceActionCount(id: int, dict: Dictionary):
	dict[id] -= 1
	if dict[id] == 0:
		dict.erase(id)
