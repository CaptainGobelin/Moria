extends Node2D

onready var selected = get_node("Selected")
onready var nameLabel = get_node("TextContainer/Name")
onready var icon = get_node("Icon")

var status = null

func setSimpleContent(statusId: int):
	status = statusId
	nameLabel.text = GLOBAL.statuses[statusId][GLOBAL.ST_NAME]
	icon.frame = GLOBAL.statuses[statusId][GLOBAL.ST_ICON]
