extends Node

var turn = 0
var isFaking = false
var fakedValue = 4
var canAct = true

# nDd+b
class Dice:
	var n: int
	var d: int
	var b: int
	
	func _init(number: int, dice: int, bonus: int):
		n = number
		d = dice
		b = bonus
	
	func roll():
		if (GeneralEngine.isFaking):
			return GeneralEngine.fakedValue
		var result = self.b
		for _d in range(self.n):
			result += (randi() % self.d)
		return result
	
	func toString():
		var result = String(n) + "d" + String(d)
		if b > 0:
			result += "+" + String(b)
		return result
	
	func duplicate() -> Dice:
		return Dice.new(n, d, b)
	
	func toVec() -> Array:
		return [n, d, b]
	
	static func fromVec(v: Array) -> Dice:
		return Dice.new(v[0], v[1], v[2])

class DmgDice:
	var dice: Dice
	var type: int
	
	func _init(n: int, d: int, b: int, dmgType: int):
		self.dice = Dice.new(n, d, b)
		type = dmgType
	
	func roll():
		return self.dice.roll()
	
	func toString():
		return dice.toString()
	
	func duplicate() -> DmgDice:
		return DmgDice.new(dice.n, dice.d, dice.b, type)

	func toVec() -> Array:
		return [dice.n, dice.d, dice.b, type]

	static func fromVec(v: Array) -> DmgDice:
		return DmgDice.new(v[0], v[1], v[2], v[3])

func dice(n: int, d: int, b: int):
	return GeneralEngine.Dice.new(n, d, b)

func basicDice(v: Vector2):
	return GeneralEngine.Dice.new(v.x, v.y, 0)

func dmgDice(n: int, d: int, b: int, t: int):
	return GeneralEngine.DmgDice.new(n, d, b, t)

func diceFromArray(array: Array) -> Dice:
	return dice(array[0], array[1], array[2])

func dmgDiceFromArray(array: Array) -> DmgDice:
	return dmgDice(array[0], array[1], array[2], array[3])

func dmgFromDice(dice: Dice, type: int):
	return GeneralEngine.DmgDice.new(dice.n, dice.d, dice.b, type)

func newTurn():
	turn += 1
	for m in Ref.currentLevel.monsters.get_children():
		m.takeTurn()
	for m in Ref.currentLevel.allies.get_children():
		m.takeTurn()
	for m in Ref.currentLevel.monsters.get_children():
		StatusEngine.decreaseStatusesTime(m)
	for m in Ref.currentLevel.allies.get_children():
		StatusEngine.decreaseStatusesTime(m)
	StatusEngine.decreaseStatusesTime(Ref.character)
	Ref.currentLevel.refresh_view()
	Ref.ui.monsterPanelList.fillList()
	if !canCharacterAct():
		canAct = false
		passTurn()
	elif !canAct:
		Ref.ui.writeFreeToAct()
		canAct = true
	else:
		canAct = true

func canCharacterAct() -> bool:
	if Ref.character.statuses.has(Data.STATUS_SLEEP):
		if Skills.isImmuneToSleep():
			StatusEngine.removeStatusType(Ref.character, Data.STATUS_SLEEP)
		else:
			Ref.ui.writeCannotAct(Ref.ui.ST_SLEEP)
			return false
	if Ref.character.statuses.has(Data.STATUS_TERROR):
		if Skills.isImmuneToTerror():
			StatusEngine.removeStatusType(Ref.character, Data.STATUS_TERROR)
		else:
			Ref.ui.writeCannotAct(Ref.ui.ST_TERROR)
			return false
	if Ref.character.statuses.has(Data.STATUS_PARALYZED):
		Ref.ui.writeCannotAct(Ref.ui.ST_PARALYSIS)
		return false
	return true

func passTurn():
	Ref.ui.askForContinue(Ref.game)
	var coroutineReturn = yield(Ref.ui, "coroutine_signal")
	if coroutineReturn:
		newTurn()

func computeDamages(dmgDices: Array, resist: Array, byPassResists: bool = false):
	var result = 0
	for dice in dmgDices:
		var dmg = dice.roll()
		if !byPassResists and resist[dice.type] > 0:
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
