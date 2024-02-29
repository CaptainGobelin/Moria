extends Node2D

onready var up = get_node("Up")
onready var down = get_node("Down")
onready var elevator = get_node("Elevator")

func setArrows(startIndex: int, maxIndex: int):
	if startIndex + 6 < maxIndex:
		down.frame = 6
	else:
		down.frame = 7
	if startIndex > 0:
		up.frame = 4
	else:
		up.frame = 5
	if down.frame == 7 and up.frame == 5:
		elevator.color = Colors.shade5
	else:
		elevator.color = Colors.shade3
		elevator.margin_top = 53 + 92*(float(startIndex)/float(maxIndex))
		elevator.margin_bottom = 53 + 92*(float(startIndex+6)/float(maxIndex))
