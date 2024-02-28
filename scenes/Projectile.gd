extends Sprite

signal end_coroutine

var pos: Vector2
var startFrame = 0

func init(path: Array, type: int, color: Color):
	startFrame = type
	self_modulate = color
	pos = path[0] - (path[1] - path[0])
	setOrientation(path[0], path[1])
	for p in path:
		var speed = 0.04
		if p.x != pos.x and p.y != pos.y:
			speed *= 1.4
		pos = p
		position = pos * 9
		yield(get_tree().create_timer(speed), "timeout")
	emit_signal("end_coroutine", true)
	queue_free()

func setOrientation(start: Vector2, end: Vector2):
	if end.x == start.x:
		frame = startFrame + 1
	elif end.y == start.y:
		frame = startFrame + 2
	else:
		frame = startFrame
	if end.y < start.y:
		flip_v = true
	else:
		flip_v = false
	if end.x < start.x:
		flip_h = true
	else:
		flip_h = false
