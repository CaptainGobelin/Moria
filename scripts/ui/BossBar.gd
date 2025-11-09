extends Node2D

onready var fragmentScene = preload("res://scenes/UI/BossBarFragment.tscn")

onready var nameLabel = get_node("TextContainer/Label")
onready var lifeBar = get_node("HSlider")
onready var fragmentsContainer = get_node("FragmentsContainer")
onready var statuses = get_node("Statuses")

func _ready():
	init(Data.MO_BO_TROLL)

func init(bossId: int):
	var boss = Data.monsters[bossId]
	nameLabel.text = boss[Data.MO_NAME]
	lifeBar.max_value = boss[Data.MO_HP]
	lifeBar.value = boss[Data.MO_HP]
	lifeBar.tick_count = 1 + (boss[Data.MO_HP] / 10)
	fragmentsContainer.scale.x = float(lifeBar.rect_size.x) / float(boss[Data.MO_HP])

func damage(amount: int):
	var oldValue = lifeBar.value
	lifeBar.value -= amount
	BossBarFrangment.create(oldValue, lifeBar.value, fragmentsContainer)

func addStatus(status: Node2D):
	statuses.add_child(status)
	statuses.position.x -= 5
