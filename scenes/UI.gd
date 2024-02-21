extends Node2D

class_name Ui

signal coroutine_signal

onready var numberHandler = get_node("Utils/NumberHandler")
onready var choiceHandler = get_node("Utils/ChoiceHandler")

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
	Ref.ui = self

func askForNumber(maxNb: int):
	Ref.game.set_process_input(false)
	numberHandler.startCoroutine(maxNb)
	var result = yield(numberHandler, "end_coroutine")
	Ref.game.set_process_input(true)
	emit_signal("coroutine_signal", result)

func askForChoice(list: Array):
	Ref.game.set_process_input(false)
	choiceHandler.startCoroutine(list)
	var result = yield(choiceHandler, "end_coroutine")
	if result == -1:
		writeOk()
	Ref.game.set_process_input(true)
	emit_signal("coroutine_signal", result)

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

func writeOk():
	write("Ok then.")

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
