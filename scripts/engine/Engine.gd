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
		var result = String(n) + "d" + String(d)
		if b > 0:
			result += "+" + String(b)
		return result

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

func basicDice(v: Vector2):
	return GeneralEngine.Dice.new(v.x, v.y, 0)

func dmgDice(n: int, d: int, b: int, t: int):
	return GeneralEngine.DmgDice.new(n, d, b, t)

func dmgFromDice(dice: Dice, type: int):
	return GeneralEngine.DmgDice.new(dice.n, dice.d, dice.b, type)

func newTurn():
	turn += 1
	for m in Ref.currentLevel.monsters.get_children():
		m.takeTurn()
	for s in Ref.ui.statusBar.icons.get_children():
		s.turns -= 1
	Ref.ui.statusBar.refreshStatuses()

func computeDamages(dmgDices: Array, resist: Array):
	var result = 0
	for dice in dmgDices:
		var dmg = dice.roll()
		if resist[dice.type] > 0:
			dmg /= pow(2, resist[dice.type])
		result += dmg
	return result

func dmgDicesToString(dmgDices: Array, rich: bool = false):
	var result = ""
	var count = 0
	for dmgDice in dmgDices:
		if rich:
			result += "[color=#" + Data.DMG_COLORS[dmgDice.type].to_html(false) + "]"
			if count > 0:
				result += "+"
			result += dmgDice.toString() + "[/color]"
		else:
			if count > 0:
				result += "+"
			result += dmgDice.toString()
		count += 1
	return result
