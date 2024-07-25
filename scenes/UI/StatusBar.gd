extends Node2D

onready var statusScene = preload("res://scenes/Status.tscn")
onready var icons = get_node("StatusIcons")

const MAX_DISPLAYED = 10

func _ready():
	for i in range(MAX_DISPLAYED):
		var status = statusScene.instance()
		icons.add_child(status)
		status.position.x = i * 12
		status.visible = false

func refreshStatuses():
	for s in icons.get_children():
		s.visible = false
	var count = 0
	for type in Ref.character.statuses.values():
		icons.get_child(count).init(type[0])
		count += 1
		if count == MAX_DISPLAYED:
			return

func addStatus(type: int, turns: int):
	var status = statusScene.instance()
	icons.add_child(status)
	status.init(type, turns)
	refreshStatuses()
