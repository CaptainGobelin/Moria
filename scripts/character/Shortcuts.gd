extends Node

var shortcuts: Dictionary
var shortcutsType: Dictionary

func assign(key: int, category: int, item: int):
	for k in shortcuts.keys():
		if shortcuts[k] == item:
			shortcuts.erase(k)
			shortcutsType.erase(k)
	match category:
		GLOBAL.WP_TYPE:
			shortcuts[key] = item
		GLOBAL.PO_TYPE:
			shortcuts[key] = GLOBAL.items[item][GLOBAL.IT_STACK]
		GLOBAL.SC_TYPE:
			shortcuts[key] = GLOBAL.items[item][GLOBAL.IT_STACK]
		GLOBAL.TH_TYPE:
			shortcuts[key] = GLOBAL.items[item][GLOBAL.IT_STACK]
		GLOBAL.SP_TYPE:
			shortcuts[key] = item
	shortcutsType[key] = category
	setUIHsortcutList()

func getKey(item: int):
	for k in shortcuts.keys():
		if shortcuts[k] == item:
			return k
	return null

func getItem(key: int):
	if !shortcuts.has(key):
		return null
	match shortcutsType[key]:
		GLOBAL.WP_TYPE:
			if shortcuts.has(key):
				var item = shortcuts[key]
				if Ref.character.inventory.weapons.has(item):
					return item
		GLOBAL.PO_TYPE:
			if shortcuts.has(key):
				var stackId = shortcuts[key]
				for p in Ref.character.inventory.potions:
					if GLOBAL.items[p][GLOBAL.IT_STACK] == stackId:
						return p
		GLOBAL.SC_TYPE:
			if shortcuts.has(key):
				var stackId = shortcuts[key]
				for s in Ref.character.inventory.scrolls:
					if GLOBAL.items[s][GLOBAL.IT_STACK] == stackId:
						return s
		GLOBAL.TH_TYPE:
			if shortcuts.has(key):
				var stackId = shortcuts[key]
				for t in Ref.character.inventory.throwings:
					if GLOBAL.items[t][GLOBAL.IT_STACK] == stackId:
						return t
		GLOBAL.SP_TYPE:
			if shortcuts.has(key):
				return shortcuts[key]
	return null

func getShortcutList() -> String:
	var result = ""
	for key in range(1, 10):
		if key != 1:
			result += '\n'
		result += String(key) + ":"
		var item = getItem(key)
		var itemName = ""
		if item != null:
			if shortcutsType[key] == GLOBAL.SP_TYPE:
				itemName = Data.spells[item][Data.SP_NAME]
			else:
				itemName = GLOBAL.items[item][GLOBAL.IT_NAME]
		if itemName.length() > 21:
			itemName.substr(0, 21)
			itemName[18] = "."
			itemName[19] = "."
			itemName[20] = "."
		result += itemName
	return result

func setUIHsortcutList():
	Ref.ui.shortcuts.text = getShortcutList()
