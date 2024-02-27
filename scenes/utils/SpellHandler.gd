extends Node

onready var projScene = preload("res://scenes/Projectile.tscn")

func castSpellAsync():
	if GLOBAL.targets.size() == 0:
		return
	Ref.game.set_process_input(false)
	Ref.ui.askForTarget(GLOBAL.targets.keys())
	var coroutineReturn = yield(Ref.ui, "coroutine_signal")
	if coroutineReturn == -1:
		return
	var targetId = GLOBAL.targets.keys()[coroutineReturn]
	yield(castProjectile(GLOBAL.targets[targetId]), "completed")
	Ref.game.set_process_input(true)

func castProjectile(path: Array):
	var p = projScene.instance()
	Ref.currentLevel.effects.add_child(p)
	p.init(path, 6, Colors.red)
	yield(p, "end_coroutine")
