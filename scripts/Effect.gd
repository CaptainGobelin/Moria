tool
extends Sprite
class_name Effect

signal completed

export(int, "Fire", "Light", "Desintegrate", "PoisonGas", 
"SleepGas", "Shock", "Smite", "Buff", "Arcane", "Ice",
"Sparkles", "Dark", "Skull", "Transmut") var type = 0 setget setType

const FIRE = 0
const LIGHT = 1
const DESTROY = 2
const POISON = 3
const GAS = 4
const SHOCK = 5
const SMITE = 6
const BUFF = 7
const ARCANE = 8
const ICE = 9
const SPARK = 10
const DARK = 11
const SKULL = 12
const TRANSMUT = 13

func setType(value):
	type = value
	# re-assign coords to update the sprite in the editor
	coords = coords

export var coords = Vector2(0, 0) setget setCoord

func setCoord(value):
	coords = value
	# Update the correct frame_coords values
	frame_coords = Vector2(coords.x, type)

func play(pos: Vector2, effectType: int, length: int, speed = 1.0):
	position = pos * 9
	type = effectType
	get_node("AnimationPlayer").play("play" + String(length), -1, speed)

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("completed")
	if not Engine.is_editor_hint():
		queue_free()
