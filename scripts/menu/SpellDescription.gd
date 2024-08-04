extends RichTextLabel

var spellId: int

func generateDescription(idx: int, rank: int = 0, saveCap: int = 0):
	spellId = idx
	var description: String = "[fill]" + Data.spellDescriptions[spellId][0] + "\n"
	for i in range(Data.spells[spellId][Data.SP_LVL], 4):
		var color = Colors.white.to_html(false)
		if i < rank:
			color = Colors.shade3.to_html(false)
		elif i == rank:
			color = Colors.yellow.to_html(false)
		description += "\n[color=#" + color + "]Rank " + String(i) + ": "
		description += Data.spellDescriptions[spellId][i]
		description += "[/color]"
	description += "[/fill]"
	if Data.spellDamages.has(spellId):
		description = description.replace("%%DMG_1", dmgToStr(Data.spellDamages[spellId][0]))
		description = description.replace("%%DMG_2", dmgToStr(Data.spellDamages[spellId][1]))
		description = description.replace("%%DMG_3", dmgToStr(Data.spellDamages[spellId][2]))
		description = description.replace("%%DMGN_1", dmgToStr(Data.spellDamages[spellId][0], false))
		description = description.replace("%%DMGN_2", dmgToStr(Data.spellDamages[spellId][1], false))
		description = description.replace("%%DMGN_3", dmgToStr(Data.spellDamages[spellId][2], false))
		description = description.replace("%%D_DMG_1", dmgIncrease(Data.spellDamages[spellId][0]))
		description = description.replace("%%D_DMG_2", dmgIncrease(Data.spellDamages[spellId][1]))
		description = description.replace("%%D_DMG_3", dmgIncrease(Data.spellDamages[spellId][2]))
		description = description.replace("%%INC_DMG_2", dmgIncrease(Data.spellDamages[spellId][1]))
		description = description.replace("%%INC_DMG_3", dmgIncrease(Data.spellDamages[spellId][2]))
	if Data.spellTurns.has(spellId):
		description = description.replace("%%TURNS_1", turns(Data.spellTurns[spellId][0]))
		description = description.replace("%%TURNS_2", turns(Data.spellTurns[spellId][1]))
		description = description.replace("%%TURNS_3", turns(Data.spellTurns[spellId][2]))
	description = description.replace("%%USES_1", uses(Data.spells[spellId][Data.SP_USES][0]))
	description = description.replace("%%USES_2", uses(Data.spells[spellId][Data.SP_USES][1]))
	description = description.replace("%%USES_3", uses(Data.spells[spellId][Data.SP_USES][2]))
	description = description.replace("%%CONTACT", rangeContact())
	description = description.replace("%%LINE", rangeLine())
	description = description.replace("%%TARGET", rangeTarget())
	description = description.replace("%%TARGET_AREA", rangeTargetArea(Data.spells[spellId][Data.SP_AREA]))
	description = description.replace("%%AREA", rangeArea(Data.spells[spellId][Data.SP_AREA]))
	description = description.replace("%%SELF", rangeSelf())
	description = description.replace("%%SAVE_HALF", saveHalf())
	description = description.replace("%%SAVE_NO", saveNegates())
	bbcode_text = description

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
