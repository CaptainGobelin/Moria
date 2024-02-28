extends Node2D

onready var statusScene = preload("res://scenes/Status.tscn")
onready var icons = get_node("StatusIcons")

func refreshStatuses():
	var count = 0
	for s in icons.get_children():
		if !s.visible:
			continue
		s.position.x = count * 12
		count += 1
		if count == 10:
			return

func addStatus(type: int, turns: int):
	var status = statusScene.instance()
	icons.add_child(status)
	status.init(type, turns)
	refreshStatuses()
