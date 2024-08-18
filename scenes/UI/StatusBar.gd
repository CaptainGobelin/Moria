extends Node2D

onready var statusScene = preload("res://scenes/Status.tscn")

export var MAX_DISPLAYED = 10
export var SPACING = 12

func _ready():
	for i in range(MAX_DISPLAYED):
		var status = statusScene.instance()
		add_child(status)
		status.position.x = i * SPACING
		status.visible = false

func refreshStatuses(entity):
	for s in get_children():
		s.visible = false
	var count = 0
	for type in entity.statuses.values():
		if GLOBAL.statuses[type[0]][GLOBAL.ST_HIDDEN]:
			continue
		get_child(count).init(type[0])
		count += 1
		if count == MAX_DISPLAYED:
			return
