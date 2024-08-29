extends ColorRect

signal fadeIn
signal fadeOut

onready var label = get_node("TextContainer/Label")
onready var animator = get_node("AnimationPlayer")

func _ready():
	visible = false

func setText(text: String):
	label.text = text

func fadeIn():
	animator.play("FadeIn")

func fadeOut():
	animator.play("FadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeIn":
			emit_signal("fadeIn")
		"FadeOut":
			emit_signal("fadeOut")
