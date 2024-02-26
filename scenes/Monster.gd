extends Node2D
class_name Monster

onready var type = -1
onready var stats = get_node("Stats")
onready var status = "sleep"

var pos = Vector2(0, 0)

func spawn(monsterType: int):
	type = monsterType
	stats.init(type)

func takeTurn():
	match status:
		"sleep":
			return
		"awake":
			if Ref.game.pathfinder.checkRange(pos, Ref.character.pos) <= stats.atkRange:
				hit(Ref.character)
			else:
				return
				moveTo(Ref.character)
			return

func hit(entity):
	if entity == null:
		return
	if entity.is_in_group("Character"):
		var result = Engine.rollDices(stats.hitDices)
		if result >= entity.stats.ca:
			var rolledDmg = Engine.rollDices(stats.dmgDices)
			var dmg = entity.takeHit(rolledDmg)
			Ref.ui.writeMonsterStrike(stats.entityName, dmg, result, entity.stats.ca)
		else:
			Ref.ui.writeMonsterMiss(stats.entityName, result, entity.stats.ca)

func moveTo(entity):
	var path = Ref.game.pathfinder.a_star(pos, entity.pos, 1000)
	if path == null:
		return
	setPosition(path[1])

func setPosition(newPos: Vector2):
	pos = newPos
	refreshMapPosition()

func refreshMapPosition():
	position = 9 * pos

func checkDmg(dmg):
	return dmg - stats.prot

func takeHit(dmg):
	stats.currentHp -= dmg
	if stats.currentHp <= 0:
		die()

func die():
	status = "dead"
	Ref.ui.write("The Skeleton dies.")
	queue_free()

func awake():
	if status == "sleep":
		status = "awake"
