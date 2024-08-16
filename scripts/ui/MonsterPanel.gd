extends Node2D

onready var nameLabel = get_node("TextContainer/Name")
onready var hp = get_node("TextContainer/HP")
onready var stats = get_node("TextContainer/Stats")
onready var hpBar = get_node("LifeTotal/LifeBar")
onready var statuses = get_node("Statuses")
onready var selected = get_node("Selected")

func _ready():
	visible = false

func setData(id: int):
	var monster = instance_from_id(id) as Monster
	setName(monster.stats.entityName)
	setHp(monster.stats.currentHp, monster.stats.maxHp)
	setStats(monster.stats.ca, monster.stats.prot, monster.stats.saveBonus[0], monster.stats.saveBonus[1])
	setStatuses()
	visible = true

func setName(value: String):
	nameLabel.text = value

func setHp(current: int, total: int):
	hp.text = String(current) + "/" + String(total)
	hpBar.margin_right = 1 + (111 * current/total)

func setStats(ac: int, prot: int, phy: int, wil: int):
	stats.text = "AC:" + String(ac)
	stats.text += " Pr:" + String(prot)
	stats.text += " PH:" + String(phy)
	stats.text += " WI:" + String(wil)

func setStatuses():
	for s in statuses.get_children():
		s.visible = false
