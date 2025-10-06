class_name SpellDescription extends Node2D

onready var spellName = get_node("TextContainer/Name")
onready var spellSave = get_node("TextContainer/Saving")
onready var spellUses = get_node("TextContainer/Uses")
onready var spellSchool = get_node("TextContainer/School")
onready var description = get_node("TextContainer/Description")
onready var empty = get_node("TextContainer/Empty")
onready var icon = get_node("Icon")

var spellId: int

func selectSpell(idx: int, rank: int = 0, saveCap: int = 0):
	generateDescription(idx, rank)
	spellName.text = Data.spells[idx][Data.SP_NAME]
	spellUses.text = getSpellUses(Data.spells[idx][Data.SP_USES][rank])
	spellSave.text = getSpellSave(Data.spells[idx][Data.SP_SAVE], saveCap)
	spellSchool.text = getSpellSchool(idx)
	icon.frame = Data.spells[idx][Data.SP_ICON]
	icon.visible = true
	empty.visible = false

func generateDescription(idx: int, rank: int = 0, saveCap: int = 0):
	spellId = idx
	var d: String = "[fill]" + Data.spellDescriptions[spellId][0] + "\n"
	for i in range(Data.spells[spellId][Data.SP_LVL], 4):
		var color = Colors.white.to_html(false)
		if i < (rank + 1):
			color = Colors.shade3.to_html(false)
		elif i == (rank + 1):
			color = Colors.yellow.to_html(false)
		d += "\n[color=#" + color + "]Rank " + String(i) + ": "
		d += Data.spellDescriptions[spellId][i]
		d += "[/color]"
	d += "[/fill]"
	description.bbcode_text = replacePlaceholders(d, spellId)

func blank():
	spellName.text = ""
	spellUses.text = ""
	spellSave.text = ""
	spellSchool.text = ""
	icon.visible = false
	description.bbcode_text = ""
	empty.visible = true

static func replacePlaceholders(toReplace: String, id: int) -> String:
	var d = toReplace
	if Data.spellDamages.has(id):
		d = d.replace("%%DMG_1", dmgToStr(Data.spellDamages[id][0]))
		d = d.replace("%%DMG_2", dmgToStr(Data.spellDamages[id][1]))
		d = d.replace("%%DMG_3", dmgToStr(Data.spellDamages[id][2]))
		d = d.replace("%%DMGN_1", dmgToStr(Data.spellDamages[id][0], false))
		d = d.replace("%%DMGN_2", dmgToStr(Data.spellDamages[id][1], false))
		d = d.replace("%%DMGN_3", dmgToStr(Data.spellDamages[id][2], false))
		d = d.replace("%%D_DMG_1", dmgDescription(Data.spellDamages[id][0]))
		d = d.replace("%%D_DMG_2", dmgDescription(Data.spellDamages[id][1]))
		d = d.replace("%%D_DMG_3", dmgDescription(Data.spellDamages[id][2]))
		d = d.replace("%%INC_DMG_2", dmgIncrease(Data.spellDamages[id][1]))
		d = d.replace("%%INC_DMG_3", dmgIncrease(Data.spellDamages[id][2]))
	if Data.spellTurns.has(id):
		d = d.replace("%%TURNS_1", turns(Data.spellTurns[id][0]))
		d = d.replace("%%TURNS_2", turns(Data.spellTurns[id][1]))
		d = d.replace("%%TURNS_3", turns(Data.spellTurns[id][2]))
	d = d.replace("%%USES_1", uses(Data.spells[id][Data.SP_USES][0]))
	d = d.replace("%%USES_2", uses(Data.spells[id][Data.SP_USES][1]))
	d = d.replace("%%USES_3", uses(Data.spells[id][Data.SP_USES][2]))
	d = d.replace("%%CONTACT", rangeContact())
	d = d.replace("%%LINE", rangeLine())
	d = d.replace("%%TARGET", rangeTarget())
	d = d.replace("%%TARGET_AREA", rangeTargetArea(Data.spells[id][Data.SP_AREA]))
	d = d.replace("%%AREA", rangeArea(Data.spells[id][Data.SP_AREA]))
	d = d.replace("%%SELF", rangeSelf())
	d = d.replace("%%SAVE_HALF", saveHalf())
	d = d.replace("%%SAVE_NO", saveNegates())
	return d

static func replace(string: String, from: String, to: String):
	if from in string:
		string = string.replace(from, to)
	return string

static func dmgToStr(array: Array, showType: bool = true):
	var bonus = ""
	if array[2] > 0:
		bonus = "+" + String(array[2])
	elif array[2] < 0:
		bonus = String(array[2])
	var type = ""
	if showType and array.size() >= 4:
		type = " " + Data.DMG_NAMES[array[3]]
	return String(array[0]) + "d" + String(array[1]) + bonus + type

static func rangeContact():
	return "a creature at melee"

static func rangeLine():
	return "all creatures on a line"

static func rangeTarget():
	return "to a creature at range"

static func rangeTargetArea(area: int):
	return "to a target and all creatures at range " + String(area)

static func rangeArea(area: int):
	return "to all creatures at range " + String(area)

static func rangeSelf():
	return "to yourself"

static func dmgDescription(dmg: Array):
	var dmgStr = dmgToStr(dmg)
	return "Deals " + dmgStr + " damages"

static func dmgIncrease(dmg: Array):
	var dmgStr = dmgToStr(dmg, false)
	return "Increases damages to " + dmgStr

static func saveHalf():
	return "A succeded saving throw halves the damages."

static func saveNegates():
	return "A succeded saving throw negates all effects."

static func turns(turns: int):
	return String(turns) + " turns"

static func uses(uses: int):
	return String(uses) + " uses"

static func getSpellUses(uses: int):
	return String(uses) + " uses per rest"

static func getSpellSave(type: int, saveCap: int):
	match type:
		Data.SAVE_NO:
			return "No saving throw"
		Data.SAVE_PHY:
			return "PHY save DD " + String(saveCap)
		Data.SAVE_WIL:
			return "WIL save DD " + String(saveCap)

static func getSpellSchool(spell: int):
	var level = Data.spells[spell][Data.SP_LVL]
	match Data.spells[spell][Data.SP_SCHOOL]:
		Data.SC_EVOCATION:
			return "Evocation spell level " + String(level)
		Data.SC_ENCHANTMENT:
			return "Enchantment spell level " + String(level)
		Data.SC_ABJURATION:
			return "Abjuration spell level " + String(level)
		Data.SC_DIVINATION:
			return "Divination spell level " + String(level)
		Data.SC_CONJURATION:
			return "Conjuration spell level " + String(level)
