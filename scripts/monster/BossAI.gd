extends Node

onready var boss = get_parent()

var oldCharDist: int = 99

var trollHasMoved: bool = false
var trollRageCharges: int = 2

# Return true if a special action is executed
func execute(target) -> bool:
	match boss.type:
		Data.MO_BO_TROLL:
			return trollExecute(target)
	return false

# Action to prevent cheesing boss due to their size
func cannotReach():
	match boss.type:
		Data.MO_BO_TROLL:
			if randf() < 0.25:
				trollSummon()

# TROLL
func trollExecute(target) -> bool:
	if (trollRageCharges == 2 and boss.stats.hpPercent() < 75) or\
		(trollRageCharges == 1 and boss.stats.hpPercent() < 25):
		trollRage()
		return true
	if target == null:
		return false
	var losToTarget = Ref.currentLevel.canTarget(boss.pos, target.pos)
	if randf() < 0.5 and (losToTarget.size() > oldCharDist or\
		(trollHasMoved and (losToTarget.size() == oldCharDist))):
		if trollNet(target, losToTarget):
			return true
	oldCharDist = losToTarget.size()
	return false

func trollSummon() -> bool:
	if not boss.abilitiesCD.has(Data.SP_TROLL_SUMMON):
		print("troll summon")
		boss.abilitiesCD[Data.SP_TROLL_SUMMON] = Data.spells[Data.SP_TROLL_SUMMON][Data.SP_USES]
		return true
	return false

func trollRage():
	Ref.game.spellHandler.useMonsterAbility(Data.SP_TROLL_RAGE, boss, null, [])

func trollNet(target, los) -> bool:
	print("troll net")
	if los.size() < 9 and not boss.abilitiesCD.has(Data.SP_TROLL_NET):
		Ref.game.spellHandler.useMonsterAbility(Data.SP_TROLL_NET, boss, target, los)
		boss.abilitiesCD[Data.SP_TROLL_NET] = Data.spells[Data.SP_TROLL_NET][Data.SP_USES]
		return true
	return false
