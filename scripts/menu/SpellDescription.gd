extends Node2D

onready var spellName = get_node("TextContainer/Name")
onready var spellSave = get_node("TextContainer/Saving")
onready var spellUses = get_node("TextContainer/Uses")
onready var spellSchool = get_node("TextContainer/School")
onready var description = get_node("TextContainer/Description")
onready var icon = get_node("Icon")

var spellId: int

func selectSpell(idx: int, rank: int = 1, saveCap: int = 0):
	generateDescription(idx, rank-1)
	spellName.text = Data.spells[idx][Data.SP_NAME]
	spellUses.text = spellUses(Data.spells[idx][Data.SP_USES][rank-1])
	spellSave.text = spellSave(Data.spells[idx][Data.SP_SAVE], saveCap)
	spellSchool.text = spellSchool(idx)
	icon.frame = Data.spells[idx][Data.SP_ICON]

func generateDescription(idx: int, rank: int = 0, saveCap: int = 0):
	spellId = idx
	var d: String = "[fill]" + Data.spellDescriptions[spellId][0] + "\n"
	for i in range(Data.spells[spellId][Data.SP_LVL], 4):
		var color = Colors.white.to_html(false)
		if i < rank:
			color = Colors.shade3.to_html(false)
		elif i == rank:
			color = Colors.yellow.to_html(false)
		d += "\n[color=#" + color + "]Rank " + String(i) + ": "
		d += Data.spellDescriptions[spellId][i]
		d += "[/color]"
	d += "[/fill]"
	if Data.spellDamages.has(spellId):
		d = d.replace("%%DMG_1", dmgToStr(Data.spellDamages[spellId][0]))
		d = d.replace("%%DMG_2", dmgToStr(Data.spellDamages[spellId][1]))
		d = d.replace("%%DMG_3", dmgToStr(Data.spellDamages[spellId][2]))
		d = d.replace("%%DMGN_1", dmgToStr(Data.spellDamages[spellId][0], false))
		d = d.replace("%%DMGN_2", dmgToStr(Data.spellDamages[spellId][1], false))
		d = d.replace("%%DMGN_3", dmgToStr(Data.spellDamages[spellId][2], false))
		d = d.replace("%%D_DMG_1", dmgIncrease(Data.spellDamages[spellId][0]))
		d = d.replace("%%D_DMG_2", dmgIncrease(Data.spellDamages[spellId][1]))
		d = d.replace("%%D_DMG_3", dmgIncrease(Data.spellDamages[spellId][2]))
		d = d.replace("%%INC_DMG_2", dmgIncrease(Data.spellDamages[spellId][1]))
		d = d.replace("%%INC_DMG_3", dmgIncrease(Data.spellDamages[spellId][2]))
	if Data.spellTurns.has(spellId):
		d = d.replace("%%TURNS_1", turns(Data.spellTurns[spellId][0]))
		d = d.replace("%%TURNS_2", turns(Data.spellTurns[spellId][1]))
		d = d.replace("%%TURNS_3", turns(Data.spellTurns[spellId][2]))
	d = d.replace("%%USES_1", uses(Data.spells[spellId][Data.SP_USES][0]))
	d = d.replace("%%USES_2", uses(Data.spells[spellId][Data.SP_USES][1]))
	d = d.replace("%%USES_3", uses(Data.spells[spellId][Data.SP_USES][2]))
	d = d.replace("%%CONTACT", rangeContact())
	d = d.replace("%%LINE", rangeLine())
	d = d.replace("%%TARGET", rangeTarget())
	d = d.replace("%%TARGET_AREA", rangeTargetArea(Data.spells[spellId][Data.SP_AREA]))
	d = d.replace("%%AREA", rangeArea(Data.spells[spellId][Data.SP_AREA]))
	d = d.replace("%%SELF", rangeSelf())
	d = d.replace("%%SAVE_HALF", saveHalf())
	d = d.replace("%%SAVE_NO", saveNegates())
	description.bbcode_text = d

func blank():
	spellName.text = ""
	spellUses.text = ""
	spellSave.text = ""
	spellSchool.text = ""
	icon.frame = 29
	description.bbcode_text = ""

func replace(description: String, from: String, to: String):
	if description.find(from) > 0:
		description = description.replace(from, to)
	return description

func dmgToStr(array: Array, showType: bool = true):
	var bonus = ""
	if array[2] > 0:
		bonus = "+" + String(array[2])
	elif array[2] < 0:
		bonus = String(array[2])
	var type = ""
	if showType:
		type = " " + Data.DMG_NAMES[array[3]]
	return String(array[0]) + "d" + String(array[1]) + bonus + type

func rangeContact():
	return "a creature at melee"

func rangeLine():
	return "all creatures on a line"

func rangeTarget():
	return "to a creature at range"

func rangeTargetArea(area: int):
	return "to a target and all creatures at range " + String(area) + "."

func rangeArea(area: int):
	return "to all creatures at range " + String(area)

func rangeSelf():
	return "to yourself"

func dmgDescription(dmg: Array):
	var dmgStr = dmgToStr(dmg)
	return "Deals " + dmgStr + " damages."

func dmgIncrease(dmg: Array):
	var dmgStr = dmgToStr(dmg, false)
	return "Increases damages to " + dmgStr + "."

func saveHalf():
	return "A succeded saving throw halves the damages."

func saveNegates():
	return "A succeded saving throw negates all effects."

func turns(turns: int):
	return String(turns) + " turns"

func uses(uses: int):
	return String(uses) + " uses"

func spellUses(uses: int):
	return String(uses) + " uses per rest"

func spellSave(type: int, saveCap: int):
	match type:
		Data.SAVE_NO:
			return "No saving throw"
		Data.SAVE_PHY:
			return "PHY save DD " + String(saveCap)
		Data.SAVE_WIL:
			return "WIL save DD " + String(saveCap)

func spellSchool(spell: int):
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
