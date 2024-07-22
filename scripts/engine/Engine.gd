extends Node

var turn = 0
var isFaking = false
var fakedValue = 4

# nDd+b
class Dice:
	var n: int
	var d: int
	var b: int
	
	func _init(n: int, d: int, b: int):
		self.n = n
		self.d = d
		self.b = b
	
	func roll():
		if (GeneralEngine.isFaking):
			return GeneralEngine.fakedValue
		var result = 0
		for _d in range(int(self.n)):
			result += (randi() % int(self.d)) + self.b
		return result
	
	func toString():
		return String(n) + "d" + String(d) + "+" + String(b)

class DmgDice:
	var dice: Dice
	var type: int
	
	func _init(n: int, d: int, b: int, type: int):
		self.dice = Dice.new(n, d, b)
		self.type = type
	
	func roll():
		return self.dice.roll()
	
	func toString():
		return dice.toString()

func dice(n: int, d: int, b: int):
	return GeneralEngine.Dice.new(n, d, b)

func dmgDice(n: int, d: int, b: int, t: int):
	return GeneralEngine.DmgDice.new(n, d, b, t)

func newTurn():
	turn += 1
	for m in Ref.currentLevel.monsters.get_children():
		m.takeTurn()
	for s in Ref.ui.statusBar.icons.get_children():
		s.turns -= 1
	Ref.ui.statusBar.refreshStatuses()

func rollDices(dice: Dice):
	if (isFaking):
		return fakedValue
	var result = 0
	for _d in range(int(dice.n)):
		result += (randi() % int(dice.d)) + dice.b
	return result

func dicesToString(dices: Vector2):
	return String(dices.x) + "d" + String(dices.y)
