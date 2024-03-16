extends Node

var weapons: Dictionary
var scrolls: Dictionary
var potions: Dictionary
var throwings: Dictionary
var spells: Dictionary

func assign(key: int, category: int, item: int):
	match category:
		GLOBAL.WP_TYPE:
			weapons[key] = item
		GLOBAL.PO_TYPE:
			potions[key] = GLOBAL.items[item][GLOBAL.IT_STACK]
		GLOBAL.TH_TYPE:
			throwings[key] = GLOBAL.items[item][GLOBAL.IT_STACK]
		GLOBAL.SP_TYPE:
			spells[key] = item

func getKey(item: int, category: int):
	match category:
		GLOBAL.WP_TYPE:
			for k in weapons.keys():
				if weapons[k] == item:
					return k
		GLOBAL.PO_TYPE:
			var stackId = GLOBAL.items[item][GLOBAL.IT_STACK]
			for k in potions.keys():
				if potions[k] == stackId:
					return k
		GLOBAL.TH_TYPE:
			var stackId = GLOBAL.items[item][GLOBAL.IT_STACK]
			for k in throwings.keys():
				if throwings[k] == stackId:
					return k
		GLOBAL.SP_TYPE:
			for k in spells.keys():
				if spells[k] == item:
					return k
	return null

func getItem(key: int, category: int):
	match category:
		GLOBAL.WP_TYPE:
			if weapons.has(key):
				var item = weapons[key]
				if Ref.character.inventory.weapons.has(item):
					return item
		GLOBAL.PO_TYPE:
			if potions.has(key):
				var stackId = potions[key]
				for p in Ref.character.inventory.potions:
					if GLOBAL.items[p][GLOBAL.IT_STACK] == stackId:
						return p
		GLOBAL.TH_TYPE:
			if throwings.has(key):
				var stackId = throwings[key]
				for t in Ref.character.inventory.throwings:
					if GLOBAL.items[t][GLOBAL.IT_STACK] == stackId:
						return t
		GLOBAL.SP_TYPE:
			if spells.has(key):
				return spells[key]
	return null

func getShortcutList(category: int):
	var count = 1
	var msg = ""
	for key in range(1, 10):
		var item = getItem(key, category)
		msg += " [" + Ref.ui.color(String(count), "yellow") + "] "
		if category == GLOBAL.SP_TYPE:
			msg += item[Data.SP_NAME]
		else:
			msg += item[GLOBAL.IT_NAME]
		count += 1
	return msg
