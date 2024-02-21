extends Node

var turn = 0

func newTurn(game):
	turn += 1
	for m in Ref.currentLevel.monsters.get_children():
		m.takeTurn()

func rollDices(dices: Vector2):
	var result = 0
	for _d in range(int(dices.x)):
		result += (randi() % int(dices.y)) + 1
	return result

func dicesToString(dices: Vector2):
	return String(dices.x) + "d" + String(dices.y)
