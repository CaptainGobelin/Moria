extends Node2D

onready var selected = get_node("Selected")
onready var nameLabel = get_node("TextContainer/Name")

var feat = null

func setSimpleContent(featId: int):
	feat = featId
	nameLabel.text = Data.feats[feat][Data.FE_NAME]
