extends Node

var actual: int
var total: int

func init():
	total = Data.FA_INITIAL
	actual = Data.FA_INITIAL
	Ref.ui.updateStat(Data.CHAR_FATIGUEMAX, total)
	Ref.ui.updateStat(Data.CHAR_FATIGUE, actual)

func refresh(value: int = total):
	actual = min(actual + value, total)
	Ref.ui.updateStat(Data.CHAR_FATIGUE, actual)

func fightCost():
	actual -= Data.FA_FIGHT_COST
	actual = max(0, actual)
	Ref.ui.updateStat(Data.CHAR_FATIGUE, actual)

func spellCost():
	actual -= Data.FA_SPELL_COST
	actual = max(0, actual)
	Ref.ui.updateStat(Data.CHAR_FATIGUE, actual)

func searchCost():
	actual -= Data.FA_SEARCH_COST
	actual = max(0, actual)
	Ref.ui.updateStat(Data.CHAR_FATIGUE, actual)
