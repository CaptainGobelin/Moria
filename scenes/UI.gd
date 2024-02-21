extends Node2D

signal coroutine_signal

onready var diary = get_node("TextBox/TextContainer/DiaryPanel")
onready var hpMax = get_node("SideMenu/HPContainer/Label/Max")
onready var hp = get_node("SideMenu/HPContainer/Label/Current")
onready var ca = get_node("SideMenu/CAContainer/Label/Current")
onready var prot = get_node("SideMenu/ProtContainer/Label/Current")
onready var dmg = get_node("SideMenu/DmgContainer/Label/Current")
onready var hit = get_node("SideMenu/HitContainer/Label/Current")

var currentChoice = ""
var currentSuffix = ""
var currentMax = 0

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_accept")):
		diary.text = diary.text.trim_suffix("_")
		returnNumber()
	elif (event.is_action_released("ui_cancel")):
		diary.text = diary.text.rstrip(currentSuffix)
		currentChoice = ""
		returnNumber()
	elif (event.is_action_released("ui_backspace")):
		if currentChoice.length() == 0:
			return
		diary.text = diary.text.rstrip(currentSuffix)
		currentChoice.erase(currentChoice.length() - 1, 1)
		if currentChoice.length() < String(currentMax).length():
			currentSuffix = currentChoice + "_"
		diary.text += (currentSuffix)
	for i in range(0, 10):
		if (event.is_action_released("shortcut" + String(i))):
			diary.text = diary.text.rstrip(currentSuffix)
			currentChoice += String(i)
			if int(currentChoice) > currentMax:
				currentChoice = String(currentMax)
			if currentChoice.length() < String(currentMax).length():
				currentSuffix = currentChoice + "_"
			else:
				currentSuffix = currentChoice
			diary.text += (currentSuffix)

func askForNumber(maxNb: int):
	currentMax = maxNb
	get_parent().set_process_input(false)
	currentChoice = ""
	currentSuffix = "_"
	write("How much? (1-" + String(maxNb) + ") _")
	set_process_input(true)

func returnNumber():
	var result = 0
	if currentChoice.length() == 0:
		write("Ok then.")
		result = null
	else:
		result = int(currentChoice)
	if result == 0:
		write("Ok then.")
		result = null
	set_process_input(false)
	get_parent().set_process_input(true)
	get_parent().getReturnedNumber(result)
	emit_signal("coroutine_signal")

func write(text):
	if text == null:
		return
	text = '\n' + '<' + String(Engine.turn) + '> ' + text
	diary.append_bbcode(text)

func color(text: String, color: String):
	match color:
		"red": return "[color=#c13137]" + text + "[/color]"
		"green": return "[color=#24b537]" + text + "[/color]"
		"yellow": return "[color=#d7b537]" + text + "[/color]"
	return text

func writeNoLoot():
	write("Nothing to pick here.")

func writeNoSkp():
	write("You don't have any remaining skill point.")

func writeNoMastery():
	write("You don't have enough mastery to improve that skill.")

func writeCharacterStrike(name: String, dmg: int, hit: int, ca: int):
	var msg = "You strike the " + name + " for " + String(dmg)
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(color(msg, "yellow"))

func writeCharacterMiss(name: String, hit: int, ca: int):
	var msg = "You miss the " + name
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(msg)

func writeMonsterStrike(name: String, dmg: int, hit: int, ca: int):
	var msg = "The " + name + " strikes you for " + String(dmg)
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(color(msg, "red"))

func writeMonsterMiss(name: String, hit: int, ca: int):
	var msg = "The " + name + " misses you"
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(msg)

func writeQuaffedPotion(potion: String):
	write("You quaffed the " + potion + ".")

func diceToString(dice: Vector2):
	return String(dice.x) + "d" + String(dice.y)

func updateStat(stat: int, value):
	match stat:
		Data.ST_HPMAX:
			hpMax.text = String(value)
		Data.ST_HP:
			hp.text = String(value)
		Data.ST_CA:
			ca.text = String(value)
		Data.ST_PROT:
			prot.text = String(value)
		Data.ST_DMG:
			dmg.text = diceToString(value)
		Data.ST_HIT:
			hit.text = diceToString(value)
