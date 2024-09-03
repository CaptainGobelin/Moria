extends Node2D
class_name Trap

onready var sprite = get_node("Sprite")
onready var mask = get_node("Mask")

var hidden: bool = true
var disabled: bool = false
var type: int
var trapName: String
var pos: Vector2

func init(trapType: int, trapPos: Vector2):
	type = trapType
	pos = trapPos
	trapName = Data.traps[type][Data.TR_NAME]
	position = pos * 9
	sprite.frame = Data.traps[type][Data.TR_ICON]
	sprite.visible = false
	mask.visible = false
	GLOBAL.trapsByPos[pos] = get_instance_id()

func disable():
	sprite.frame += 1
	sprite.visible = true
	mask.visible = false
	disabled = true
	hidden = false

func reveal():
	hidden = false
	sprite.visible = true
	mask.visible = false
