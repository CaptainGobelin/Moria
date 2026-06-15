extends Node2D

onready var fragmentScene = preload("res://scenes/UI/BossBarFragment.tscn")

onready var nameLabel = get_node("TextContainer/Label")
onready var lifeBar = get_node("HSlider")
onready var fragmentsContainer = get_node("FragmentsContainer")
onready var statuses = get_node("Statuses")
onready var animator = get_node("AnimationPlayer")

const MAX_DISPLAYED = 10
var bossEntity
var isActive: bool = false

func _ready():
	visible = false

func init(entity):
	bossEntity = entity
	isActive = true
	var bossId = entity.type
	var boss = Data.monsters[bossId]
	nameLabel.text = boss[Data.MO_NAME]
	lifeBar.max_value = boss[Data.MO_HP]
	lifeBar.value = boss[Data.MO_HP]
	lifeBar.tick_count = 1 + (boss[Data.MO_HP] / 10)
	fragmentsContainer.scale.x = float(lifeBar.rect_size.x) / float(boss[Data.MO_HP])
	animator.play("Init")
	visible = true
	refreshStatuses()

func disable():
	isActive = false
	visible = false
	bossEntity = null

func unhide():
	visible = isActive

func hide():
	visible = false

func damage(amount: int):
	var oldValue = lifeBar.value
	lifeBar.value -= amount
	BossBarFrangment.create(oldValue, lifeBar.value, fragmentsContainer)

func refreshStatuses():
	if not visible or not is_instance_valid(bossEntity):
		return
	for s in statuses.get_children():
		s.visible = false
	var count = 0
	for type in bossEntity.statuses.values():
		if GLOBAL.statuses[type[0]][GLOBAL.ST_HIDDEN]:
			continue
		statuses.get_child(count).init(type[0])
		count += 1
		if count == MAX_DISPLAYED:
			return
	statuses.position.x = 5.5 - 10 * count
