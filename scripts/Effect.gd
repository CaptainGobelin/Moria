tool
extends Sprite
class_name Effect

signal completed

export(int, "Fire", "Light", "Desintegrate", "PoisonGas", 
"SleepGas", "Shock", "Smite", "Buff", "Arcane", "Ice",
"Sparkles", "Dark", "Skull", "Transmut", "Circle", "Heal") var type = 0 setget setType

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
const CIRCLE = 14
const HEAL = 15

const EF_LENGTH = 0
const EF_SPEED = 1
const effects = {
	FIRE : [5, 0.6],
	LIGHT : [5, 0.6],
	DESTROY : [5, 0.8],
	POISON : [5, 0.6],
	GAS : [5, 0.6],
	SHOCK : [5, 1.1],
	SMITE : [5, 0.8],
	BUFF : [5, 0.6],
	ARCANE : [5, 0.6],
	ICE : [5, 0.6],
	SPARK : [5, 0.6],
	DARK : [5, 0.6],
	SKULL : [5, 0.45],
	TRANSMUT : [5, 1.1],
	CIRCLE : [5, 0.6],
	HEAL : [5, 0.6],
}

func setType(value):
	type = value
	# re-assign coords to update the sprite in the editor
	coords = coords

export var coords = Vector2(0, 0) setget setCoord

func setCoord(value):
	coords = value
	# Update the correct frame_coords values
	frame_coords = Vector2(coords.x, type)

func play(pos: Vector2, effectType: int, isBoss: bool = false):
	position = pos * 9
	if isBoss:
		scale = Vector2(2, 2)
	type = effectType
	get_node("AnimationPlayer").play("play" + String(effects[type][EF_LENGTH]), -1, effects[type][EF_SPEED])

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("completed")
	if not Engine.is_editor_hint():
		queue_free()
