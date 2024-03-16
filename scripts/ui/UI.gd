extends Node2D

class_name Ui

signal coroutine_signal

onready var numberHandler = get_node("Utils/NumberHandler")
onready var choiceHandler = get_node("Utils/ChoiceHandler")
onready var yesNoHandler = get_node("Utils/YesNoHandler")
onready var targetHandler = get_node("Utils/TargetHandler")

onready var diary = get_node("TextBox/TextContainer/DiaryPanel")
onready var hpMaxLabel = get_node("SideMenu/HPContainer/Label/Max")
onready var hpLabel = get_node("SideMenu/HPContainer/Label/Current")
onready var caLabel = get_node("SideMenu/CAContainer/Label/Current")
onready var protLabel = get_node("SideMenu/ProtContainer/Label/Current")
onready var dmgLabel = get_node("SideMenu/DmgContainer/Label/Current")
onready var hitLabel = get_node("SideMenu/HitContainer/Label/Current")
onready var lockLabel = get_node("SideMenu/LockContainer/Label/Current")
onready var goldLabel = get_node("SideMenu/GoldContainer/Label/Current")
onready var statusBar = get_node("StatusBar")

var currentChoice = ""
var currentSuffix = ""
var currentMax = 0

func _ready():
	Ref.ui = self

func askForNumber(maxNb: int, inputer, msg = "How much?"):
	inputer.set_process_input(false)
	numberHandler.startCoroutine(maxNb, msg)
	var result = yield(numberHandler, "end_coroutine")
	inputer.set_process_input(true)
	emit_signal("coroutine_signal", result)

func askForChoice(list: Array, inputer):
	inputer.set_process_input(false)
	choiceHandler.startCoroutine(list)
	var result = yield(choiceHandler, "end_coroutine")
	if result == -1:
		writeOk()
	inputer.set_process_input(true)
	emit_signal("coroutine_signal", result)

func askForYesNo(inputer):
	inputer.set_process_input(false)
	yesNoHandler.startCoroutine()
	var result = yield(yesNoHandler, "end_coroutine")
	if !result:
		writeOk()
	inputer.set_process_input(true)
	emit_signal("coroutine_signal", result)

func askForTarget(targets: Array, inputer):
	inputer.set_process_input(false)
	targetHandler.startCoroutine(targets)
	var result = yield(targetHandler, "end_coroutine")
	if result == -1:
		writeOk()
	inputer.set_process_input(true)
	emit_signal("coroutine_signal", result)

func write(text):
	if text == null:
		return
	text = '\n' + '<' + String(GeneralEngine.turn) + '> ' + text
	diary.append_bbcode(text)

func simpleWrite(text):
	if text == null:
		return
	diary.append_bbcode(text)

func color(text: String, color: String):
	match color:
		"red": return "[color=#c13137]" + text + "[/color]"
		"green": return "[color=#24b537]" + text + "[/color]"
		"yellow": return "[color=#d7b537]" + text + "[/color]"
	return text

func writeOk():
	write("Ok then.")

func writeAssignedKey(key: int, item: String):
	item[0] = item[0].capitalize()
	write(item + " assigned to key " + color(String(key), "yellow") + ".")

func writeNoScrollAssigned():
	write("You don't have any scroll assigned.")

func writeWhichScroll(choices: Array):
	var msg = "Read which scroll?"
	msg += listToChoices(choices)
	write(msg)

func writeNoThrowingAssigned():
	write("You don't have any throwing weapon assigned.")

func writeWhichThrowing(choices: Array):
	var msg = "Throw what?"
	msg += listToChoices(choices)
	write(msg)

func writeNoSpellAssigned():
	write("You don't have any spell assigned.")

func writeWhichSpell(choices: Array):
	var msg = "Cast which spell?"
	msg += listToChoices(choices)
	write(msg)

func writeCastSpell(spell: String):
	write("You casted " + color(spell, "yellow") + ".")

func writeNoSpell(spell: String):
	write("You cannot cast " + spell + " anymore until you rest.")

func writeNoGoingBack():
	write("A shadow force blocks the way. There is no going back...")

func askToChangeFloor():
	write("Do you want to go to the next floor? (Y/n)")

func askToOpenChest():
	write("Do you want to open the chest? (Y/n)")

func askToPickChest(dd: int):
	var msg = "The chest is locked. Do you want to pick the lock? (DC "
	msg += String(dd) + ") (Y/n)"
	write(color(msg, "yellow"))

func askToPickDoor(dd: int):
	var msg = "The door is locked. Do you want to pick the lock? (DC "
	msg += String(dd) + ") (Y/n)"
	write(color(msg, "yellow"))

func writeLockpickSuccess(rolled: int):
	var msg = "You successfully picked the lock ! (rolled "
	msg +=  String(rolled) + ")"
	write(color(msg, "green"))

func writeLockpickFailure(rolled: int):
	var msg = "You failed your atempt and the lockpick broke ! (rolled "
	msg +=  String(rolled) + ")"
	write(color(msg, "red"))

func noLockpicksChest():
	write("The chest is locked and you don't have any lockpicks to pick it.")

func noLockpicksDoor():
	write("The door is locked and you don't have any lockpicks to pick it.")

func writeSearch():
	write("You look for hidden secrets around you...")

func writeHiddenDoorDetected():
	write(color("You detected a hidden door !", "yellow"))

func writeHiddenTrapDetected(name: String):
	write(color("You detected " + Utils.addArticle(name) + " !", "yellow"))

func writeNoLoot():
	write("Nothing to pick here.")

func writeNoSkp():
	write("You don't have any remaining skill point.")

func writeNoMastery():
	write("You don't have enough mastery to improve that skill.")

func writeTriggerTrap(name: String):
	write(color("You trigger " + Utils.addArticle(name) + " !", "yellow"))

func writeCharacterStrike(name: String, hit: int, ca: int):
	var msg = "You strike the " + name
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(color(msg, "yellow"))

func writeCharacterMiss(name: String, hit: int, ca: int):
	var msg = "You miss the " + name
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(msg)

func writeCharacterTakeHit(dmg: int):
	write(color("You suffer " + String(dmg) + " damages.", "red"))

func writeMonsterStrike(name: String, hit: int, ca: int):
	var msg = "The " + name + " strikes you "
	msg += "(rolled " + String(hit) + " vs " + String(ca) + ")."
	write(color(msg, "red"))

func writeMonsterMiss(name: String, hit: int, ca: int):
	var msg = "The " + name + " misses you"
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(msg)

func writeMonsterTakeHit(name: String, dmg: int):
	var msg = "The " + name + " suffers " + String(dmg) + " damages."
	write(color(msg, "yellow"))

func writeMonsterDie(name: String):
	write(color("The " + name + " dies.", "yellow"))

func writeQuaffedPotion(potion: String):
	write("You quaffed the " + potion + ".")

func noTarget():
	write("There is no targets at range for this.")

func diceToString(dice: Vector2) -> String:
	return String(dice.x) + "d" + String(dice.y)

func listToChoices(list: Array) -> String:
	var msg = ""
	var count = 0
	for item in list:
		count += 1
		if item != null:
			msg += " [" + Ref.ui.color(String(count), "yellow") + "] "
			msg += item
	return msg

func updateStat(stat: int, value):
	match stat:
		Data.ST_HPMAX:
			hpMaxLabel.text = String(value)
		Data.ST_HP:
			hpLabel.text = String(value)
		Data.ST_CA:
			caLabel.text = String(value)
		Data.ST_PROT:
			protLabel.text = String(value)
		Data.ST_DMG:
			dmgLabel.text = diceToString(value)
		Data.ST_HIT:
			hitLabel.text = diceToString(value)
		Data.ST_LOCK:
			lockLabel.text = String(value)
		Data.ST_GOLD:
			goldLabel.text = String(value)
