extends Node

onready var projScene = preload("res://scenes/Projectile.tscn")

func castSpellAsync(spellId: int):
	var spell = Data.spells[spellId]
	if GLOBAL.targets.size() == 0:
		return
	Ref.game.set_process_input(false)
	Ref.ui.askForTarget(GLOBAL.targets.keys())
	var coroutineReturn = yield(Ref.ui, "coroutine_signal")
	if coroutineReturn == -1:
		return
	var targetId = GLOBAL.targets.keys()[coroutineReturn]
	yield(castProjectile(GLOBAL.targets[targetId], spell[Data.SP_PROJ]), "completed")
	SpellEngine.applyEffect(instance_from_id(targetId), Data.SP_MAGIC_MISSILE)
	Ref.game.set_process_input(true)

func castProjectile(path: Array, projInfo):
	var p = projScene.instance()
	Ref.currentLevel.effects.add_child(p)
	p.init(path, projInfo[Data.PROJ_TYPE], projInfo[Data.PROJ_COLOR])
	yield(p, "end_coroutine")
