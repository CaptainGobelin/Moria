extends Node2D

onready var icon = get_node("Icon")
onready var timer = get_node("Timer")

func init(status: int):
	visible = true
	icon.frame = GLOBAL.statuses[status][GLOBAL.ST_ICON]
	var turns = 99
	if GLOBAL.statuses[status][GLOBAL.ST_TIMING] == GLOBAL.TIMING_TIMER:
		turns = GLOBAL.statuses[status][GLOBAL.ST_TURNS]
		setTurn(turns)
	else:
		timer.visible = false

func setTurn(turns: int):
	if turns == 0:
		visible = false
		queue_free()
	elif turns > 20:
		timer.frame = 0
	elif turns > 10:
		timer.frame = 1
	elif turns > 5:
		timer.frame = 2
	elif turns == 5:
		timer.frame = 3
	elif turns == 4:
		timer.frame = 4
	elif turns == 3:
		timer.frame = 5
	elif turns == 2:
		timer.frame = 6
	elif turns == 1:
		timer.frame = 7
