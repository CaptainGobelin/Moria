extends Node2D

onready var icon = get_node("Icon")
onready var timer = get_node("Timer")

var status: int = 0
var turns: int = 0 setget setTurn

func init(type: int, totalTurns):
	status = type
	icon.frame = Data.statuses[type][Data.ST_ICON]
	setTurn(totalTurns)

func setTurn(value):
	turns = value
	if turns == 0:
		free()
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
