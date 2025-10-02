extends Node

var shortcuts: Dictionary
var shortcutsType: Dictionary

func assign(key: int, category: int, item: int):
	for k in shortcuts.keys():
		if shortcuts[k] == item:
			if shortcutsType.has(k) and shortcutsType[k] == category:
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

func getKey(item: int, category: int):
	for k in shortcuts.keys():
		if shortcuts[k] == item:
			if shortcutsType.has(k) and shortcutsType[k] == category:
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
		result += String(key) + ": "
		var itemName = ""
		if shortcuts.has(key):
			var item = shortcuts[key]
			if shortcutsType[key] == GLOBAL.SP_TYPE:
				var n = Ref.character.spells.spellsUses[shortcuts[key]]
				itemName = String(n) + "x " + Data.spells[item][Data.SP_NAME]
			elif shortcutsType[key] == GLOBAL.PO_TYPE:
				var n = Ref.character.inventory.getItemAmount(GLOBAL.PO_TYPE, shortcuts[key])
				itemName = String(n) + "x " + Data.potions[Data.itemByStack[item]][Data.PO_NAME]
			elif shortcutsType[key] == GLOBAL.SC_TYPE:
				var n = Ref.character.inventory.getItemAmount(GLOBAL.SC_TYPE, shortcuts[key])
				itemName = String(n) + "x " + Data.scrolls[Data.itemByStack[item]][Data.SC_NAME]
			elif shortcutsType[key] == GLOBAL.TH_TYPE:
				var n = Ref.character.inventory.getItemAmount(GLOBAL.TH_TYPE, shortcuts[key])
				itemName = String(n) + "x " + Data.throwings[Data.itemByStack[item]][Data.TH_NAME]
			else:
				itemName = GLOBAL.items[item][GLOBAL.IT_NAME]
		if itemName.length() > 20:
			itemName = itemName.substr(0, 20)
			itemName[19] = "…"
		result += itemName
	return result

func refreshShortcuts(base: int):
	if shortcuts.values().has(base):
		setUIHsortcutList()

func setUIHsortcutList():
	Ref.ui.shortcuts.text = getShortcutList()
