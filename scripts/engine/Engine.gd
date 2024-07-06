extends Node

var turn = 0
var isFaking = false

func newTurn():
	turn += 1
	for m in Ref.currentLevel.monsters.get_children():
		m.takeTurn()
	for s in Ref.ui.statusBar.icons.get_children():
		s.turns -= 1
	Ref.ui.statusBar.refreshStatuses()

func rollDices(dices: Vector2):
	if (isFaking):
		return 4
	var result = 0
	for _d in range(int(dices.x)):
		result += (randi() % int(dices.y)) + 1
	return result

func dicesToString(dices: Vector2):
	return String(dices.x) + "d" + String(dices.y)
