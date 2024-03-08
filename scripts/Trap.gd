extends Sprite
class_name Trap

var type: int
var trapName: String
var pos: Vector2

func init(trapType: int, trapPos: Vector2):
	type = trapType
	pos = trapPos
	trapName = Data.traps[type][Data.TR_NAME]
	position = pos * 9
	frame = Data.traps[type][Data.TR_ICON]
	visible = false
	GLOBAL.traps[pos] = [true, type, get_instance_id()]
