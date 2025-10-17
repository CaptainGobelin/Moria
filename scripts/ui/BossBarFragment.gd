extends Node2D
class_name BossBarFrangment

onready var colorRect = get_node("ColorRect")
onready var animator = get_node("AnimationPlayer")

static func create(oldValue: int, newValue: int, container: Node2D):
	if oldValue == newValue:
		return
	var scene = container.get_parent().fragmentScene as PackedScene
	var fragment = scene.instance()
	container.add_child(fragment)
	fragment.init(oldValue, newValue)

func init(oldValue: int, newValue: int):
	var delta = newValue - oldValue
	colorRect.rect_position.x = min(newValue, oldValue)
	colorRect.rect_size.x = abs(delta)
	if delta < 0:
		colorRect.self_modulate = Colors.white
		animator.play("Fade")
	else:
		colorRect.self_modulate = Colors.green
		animator.play("Fade")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "RESET":
		queue_free()
