extends Node2D

class_name Ui

signal coroutine_signal

onready var numberHandler = get_node("Utils/NumberHandler")
onready var choiceHandler = get_node("Utils/ChoiceHandler")
onready var yesNoHandler = get_node("Utils/YesNoHandler")
onready var directionHandler = get_node("Utils/DirectionHandler")
onready var targetHandler = get_node("Utils/TargetHandler")
onready var continueHandler = get_node("Utils/ContinueHandler")

onready var diary = get_node("TextBox/TextContainer/DiaryPanel")
onready var shortcuts = get_node("Shortcuts/TextContainer/Label")
onready var nameLabel = get_node("SideMenu/Name/Label")
onready var locationLabel = get_node("SideMenu/Location/Label")
onready var levelLabel = get_node("SideMenu/Level/Label/Level")
onready var xpLabel = get_node("SideMenu/Level/Label/CurrentXP")
onready var maxXpLabel = get_node("SideMenu/Level/Label/MaxXP")
onready var hpMaxLabel = get_node("SideMenu/HPContainer/Label/Max")
onready var hpLabel = get_node("SideMenu/HPContainer/Label/Current")
onready var caLabel = get_node("SideMenu/CAContainer/Label/Current")
onready var protLabel = get_node("SideMenu/ProtContainer/Label/Current")
onready var dmgLabel = get_node("SideMenu/DmgContainer/Label/Current")
onready var hitLabel = get_node("SideMenu/HitContainer/Label/Current")
onready var lockLabel = get_node("SideMenu/LockContainer/Label/Current")
onready var goldLabel = get_node("SideMenu/GoldContainer/Label/Current")
onready var rFire = get_node("SideMenu/rFire/Label/Current")
onready var rPois = get_node("SideMenu/rPoison/Label/Current")
onready var statusBar = get_node("StatusBar")
onready var fadePanel = get_node("FadePanel")
onready var fadeLabel = get_node("FadePanel/TextContainer/Label")
onready var monsterPanelList = get_node("MonsterPanelList")

var currentChoice = ""
var currentSuffix = ""
var currentMax = 0
var lastPrinted: String = ""
var previousMode: int = GLOBAL.MODE_NONE
var diaryContent: String = ""

func _ready():
	Ref.ui = self

func askForNumber(maxNb: int, inputer, msg = "How much?"):
	previousMode = GLOBAL.currentMode
	GLOBAL.currentMode = GLOBAL.MODE_NUMBER
	numberHandler.startCoroutine(maxNb, msg)
	var result = yield(numberHandler, "end_coroutine")
	GLOBAL.currentMode = previousMode
	MasterInput.setMaster(inputer)
	emit_signal("coroutine_signal", result)

func askForChoice(list: Array, inputer):
	previousMode = GLOBAL.currentMode
	GLOBAL.currentMode = GLOBAL.MODE_CHOICE
	choiceHandler.startCoroutine(list)
	var result = yield(choiceHandler, "end_coroutine")
	if result == -1:
		writeOk()
	GLOBAL.currentMode = previousMode
	MasterInput.setMaster(inputer)
	emit_signal("coroutine_signal", result)

func askForYesNo(inputer):
	previousMode = GLOBAL.currentMode
	GLOBAL.currentMode = GLOBAL.MODE_YESNO
	yesNoHandler.startCoroutine()
	var result = yield(yesNoHandler, "end_coroutine")
	if !result:
		writeOk()
	GLOBAL.currentMode = previousMode
	MasterInput.setMaster(inputer)
	emit_signal("coroutine_signal", result)

func askForDirection(inputer):
	previousMode = GLOBAL.currentMode
	directionHandler.startCoroutine()
	var result = yield(directionHandler, "end_coroutine")
	GLOBAL.currentMode = previousMode
	MasterInput.setMaster(inputer)
	emit_signal("coroutine_signal", result)

func askForTarget(targets: Array, inputer):
	previousMode = GLOBAL.currentMode
	GLOBAL.currentMode = GLOBAL.MODE_TARGET
	targetHandler.startCoroutine(targets)
	var result = yield(targetHandler, "end_coroutine")
	if result == -1:
		writeOk()
	GLOBAL.currentMode = previousMode
	MasterInput.setMaster(inputer)
	emit_signal("coroutine_signal", result)

func askForContinue(inputer):
	previousMode = GLOBAL.currentMode
	continueHandler.startCoroutine()
	var result = yield(continueHandler, "end_coroutine")
	GLOBAL.currentMode = previousMode
	MasterInput.setMaster(inputer)
	emit_signal("coroutine_signal", result)

func write(text):
	if text == null:
		return
	text = '\n' + '<' + String(GeneralEngine.turn) + '> ' + text
	diary.append_bbcode(text)
	diaryContent += text
	Ref.game.autoexplore = false

func simpleWrite(text):
	if text == null:
		return
	diary.append_bbcode(text)
	diaryContent += text

func color(text: String, color: String):
	match color:
		"red": return "[color=#c13137]" + text + "[/color]"
		"green": return "[color=#24b537]" + text + "[/color]"
		"yellow": return "[color=#d7b537]" + text + "[/color]"
	return text

func writeOk():
	write("Ok then.")
	lastPrinted = "writeOk"

func writeXpGain(xp: int):
	write("You earn " + color(String(xp), "yellow") + " XP.")
	lastPrinted = "writeXpGain"

func writeLevelUp(level: int, hp: int, skp: int, feat: int):
	write(color("You reach level " + String(level) + " !", "green"))
	var msg = "You gain " + String(hp) + " HP"
	if feat == 1:
		msg += ", " + String(skp) + " skill point and you can choose a feat."
	else:
		msg += " and " + String(skp) + " skill points."
	write(color(msg, "green"))
	write(color("Press [K] to spend your points.", "green"))
	lastPrinted = "writeLevelUp"
	

func writeAssignedKey(key: int, item: String):
	item[0] = item[0].capitalize()
	write(item + " assigned to key " + color(String(key), "yellow") + ".")
	lastPrinted = "writeAssignedKey"

func writeNoPotionAssigned():
	write("You don't have any potion assigned.")
	lastPrinted = "writeNoPotionAssigned"

func writeWhichPotion(choices: Array):
	var msg = "Quaff which potion?"
	msg += listToChoices(choices)
	write(msg)
	lastPrinted = "writeWhichPotion"

func writeNoScrollAssigned():
	write("You don't have any scroll assigned.")
	lastPrinted = "writeNoScrollAssigned"

func writeWhichScroll(choices: Array):
	var msg = "Read which scroll?"
	msg += listToChoices(choices)
	write(msg)
	lastPrinted = "writeWhichScroll"

func writeNoThrowingAssigned():
	write("You don't have any throwing weapon assigned.")
	lastPrinted = "writeNoThrowingAssigned"

func writeWhichThrowing(choices: Array):
	var msg = "Throw what?"
	msg += listToChoices(choices)
	write(msg)
	lastPrinted = "writeWhichThrowing"

func writeNoSpellAssigned():
	write("You don't have any spell assigned.")
	lastPrinted = "writeNoSpellAssigned"

func writeSpellDirection():
	write("Cast spell in which direction?")
	lastPrinted = "writeSpellDirection"

func writeWhichSpell(choices: Array):
	var msg = "Cast which spell?"
	msg += listToChoices(choices)
	write(msg)
	lastPrinted = "writeWhichSpell"

func writeCastSpell(spell: String):
	write("You cast " + color(spell, "yellow") + ".")
	lastPrinted = "writeCastSpell"

func writeMonsterCastSpell(entityName: String, spell: String):
	write(entityName + " casts " + color(spell, "yellow") + ".")
	lastPrinted = "writeMonsterCastSpell"

func writeNoSpell(spell: String):
	write("You cannot cast " + spell + " anymore until you rest.")
	lastPrinted = "writeNoSpell"

func writeSavingThrowSuccess(entityName: String):
	write(entityName + " succeed its saving throw.")
	lastPrinted = "writeSavingThrowSuccess"

func writeNoGoingBack():
	write("A shadow force blocks the way. There is no going back...")
	lastPrinted = "writeNoGoingBack"

func askToChangeFloor():
	write("Do you want to go to the next floor? (Y/n)")
	lastPrinted = "askToChangeFloor"

func askToOpenChest():
	write("Do you want to open the chest? (Y/n)")
	lastPrinted = "askToOpenChest"

func askToPickChest(dd: int):
	var msg = "The chest is locked. Do you want to pick the lock? (DC "
	msg += String(dd) + ") (Y/n)"
	write(color(msg, "yellow"))
	lastPrinted = "askToPickChest"

func askToPickDoor(dd: int):
	var msg = "The door is locked. Do you want to pick the lock? (DC "
	msg += String(dd) + ") (Y/n)"
	write(color(msg, "yellow"))
	lastPrinted = "askToPickDoor"

func writeDoorUnlocked():
	write("The door is unlocked.")
	lastPrinted = "writeDoorUnlocked"

func writeChestUnlocked():
	write("The chest is unlocked.")
	lastPrinted = "writeChestUnlocked"

func writeLockpickSuccess(rolled: int):
	var msg = "You successfully pick the lock ! (rolled "
	msg +=  String(rolled) + ")"
	write(color(msg, "green"))
	lastPrinted = "writeLockpickSuccess"

func writeLockpickFailure(rolled: int):
	var msg = "You fail your atempt and the lockpick broke ! (rolled "
	msg +=  String(rolled) + ")"
	write(color(msg, "red"))
	lastPrinted = "writeLockpickFailure"

func noLockpicksChest():
	write("The chest is locked and you don't have any lockpicks to pick it.")
	lastPrinted = "noLockpicksChest"

func noLockpicksDoor():
	write("The door is locked and you don't have any lockpicks to pick it.")
	lastPrinted = "noLockpicksDoor"

func writeNoLockedDoor():
	write("There is no locked door or chest to unlock there.")
	lastPrinted = "writeNoLockedDoor"

func writeSearch():
	write("You look for hidden secrets around you...")
	lastPrinted = "writeSearch"

func writeHiddenDoorDetected():
	write(color("You detect a hidden door !", "yellow"))
	lastPrinted = "writeHiddenDoorDetected"

func writeHiddenTrapDetected(name: String):
	write(color("You detect " + Utils.addArticle(name) + " !", "yellow"))
	lastPrinted = "writeHiddenTrapDetected"

func writeNoLoot():
	write("Nothing to pick here.")
	lastPrinted = "writeNoLoot"

func writePickupLoot(item: String, count: int):
	write("You pick " + Utils.addArticle(item, count) + ".")
	lastPrinted = "writePickupLoot"

func writeBuyLoot(item: String, count: int, price: int):
	write(color("You buy " + Utils.addArticle(item, count) + " for " + String(price) + " golds.", "yellow"))
	lastPrinted = "writeBuyLoot"

func writeNoMoney():
	write("You don't have enough golds for that.")
	lastPrinted = "writeNoMoney"

func writeAskToBuy(price: int):
	write("Do you want to buy that? (Y/n)")
	lastPrinted = "writeAskToBuy"

func writeNoSkp():
	write("You don't have any remaining skill point.")
	lastPrinted = "writeNoSkp"

func writeNoMastery():
	write("You don't have enough mastery to improve that skill.")
	lastPrinted = "writeNoMastery"

func writeTriggerTrap(name: String):
	write(color("You trigger " + Utils.addArticle(name) + " !", "yellow"))
	lastPrinted = "writeTriggerTrap"

func writeCharacterStrike(name: String, hit: int, ca: int):
	var msg = "You strike the " + name
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(color(msg, "yellow"))
	lastPrinted = "writeCharacterStrike"

func writeCharacterMiss(name: String, hit: int, ca: int):
	var msg = "You miss the " + name
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(msg)
	lastPrinted = "writeCharacterMiss"

func writeCharacterTakeHit(dmg: int):
	write(color("You suffer " + String(dmg) + " damages.", "red"))
	lastPrinted = "writeCharacterTakeHit"

func writeMonsterStrike(name: String, target: String, hit: int, ca: int):
	var msg = "The " + name + " strikes " + target + " "
	msg += "(rolled " + String(hit) + " vs " + String(ca) + ")."
	write(color(msg, "red"))
	lastPrinted = "writeMonsterStrike"

func writeMonsterMiss(name: String, target: String, hit: int, ca: int):
	var msg = "The " + name + " misses " + target + " "
	msg += " (rolled " + String(hit) + " vs " + String(ca) + ")."
	write(msg)
	lastPrinted = "writeMonsterMiss"

func writeMonsterTakeHit(name: String, dmg: int):
	var msg = "The " + name + " suffers " + String(dmg) + " damages."
	write(color(msg, "yellow"))
	lastPrinted = "writeMonsterTakeHit"

func writeMonsterDie(name: String):
	write(color("The " + name + " dies.", "yellow"))
	lastPrinted = "writeMonsterDie"

func writeQuaffedPotion(potion: String):
	write("You quaff the " + potion + ".")
	lastPrinted = "writeQuaffedPotion"

func writeMonsterQuaffedPotion(entityName: String, potion: String):
	write(entityName + " quaffes the " + potion + ".")
	lastPrinted = "writeMonsterQuaffedPotion"

func writeRemoveSleep():
	write("You are woken up by the attack.")
	lastPrinted = "writeRemoveSleep"

func writeMonsterRemoveSleep(entityName: String):
	write(entityName + " is woken up by the attack.")
	lastPrinted = "writeMonsterRemoveSleep"

func noTarget():
	write("There is no targets at range for this.")
	lastPrinted = "noTarget"

func writeWishChoice():
	var msg = "Ask for what?"
	msg += listToChoices(["Weapon", "Armor", "Scrolls", "Potions", "Gold"])
	write(msg)
	lastPrinted = "writeWishChoice"

func writeFreeToAct():
	write("You are free to move again.")
	lastPrinted = "writeFreeToAct"

const ST_SLEEP = "sleeping"
const ST_PARALYSIS = "paralyzed"
const ST_TERROR = "terrorized"

func writeCannotAct(status: String):
	var msg = "You are " + status + ", you cannot move."
	write(color(msg, "red"))

func askForRest(rests: int):
	var msg = "You can rest " + String(rests)
	if rests == 1:
		msg += " time."
	else:
		msg += " times."
	msg += " Do you want to rest here? (Y/n)"
	write(msg)
	lastPrinted = "askForRest"

func noMoreRest():
	write("You cannot rest anymore.")
	lastPrinted = "noMoreRest"

func writeNoSafeRest():
	write("Some hostile creatures lurk in the shadows. You cannot rest here.")
	lastPrinted = "writeNoSafeRest"

func writeRested():
	write("You wake up, fully rested.")
	lastPrinted = "writeRested"

func writeWishResult(items: Array):
	var msg = ""
	var list = []
	if items.empty():
		msg = "Nothing"
	else:
		var item = GLOBAL.items[items[0]]
		if item[GLOBAL.IT_TYPE] == GLOBAL.LO_TYPE or item[GLOBAL.IT_TYPE] == GLOBAL.GO_TYPE:
			list.append(Utils.addArticle(item[GLOBAL.IT_NAME], item[GLOBAL.IT_SPEC]))
		else:
			list.append(Utils.addArticle(item[GLOBAL.IT_NAME], items.size()))
	msg += Utils.makeList(list) + " appeared at your feet."
	write(msg)
	lastPrinted = "writeWishResult"

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
		Data.CHAR_NAME:
			nameLabel.text = value[0] + " the " + value[1]
		Data.CHAR_HPMAX:
			hpMaxLabel.text = String(value)
		Data.CHAR_HP:
			hpLabel.text = String(value)
		Data.CHAR_CA:
			caLabel.text = String(value)
		Data.CHAR_PROT:
			protLabel.text = String(value)
		Data.CHAR_DMG:
			dmgLabel.bbcode_text = "[right]"
			dmgLabel.bbcode_text += GeneralEngine.dmgDicesToString(value, true)
			dmgLabel.bbcode_text += "[/right]"
		Data.CHAR_HIT:
			hitLabel.text = value.toString()
		Data.CHAR_LOCK:
			lockLabel.text = String(value)
		Data.CHAR_GOLD:
			goldLabel.text = String(value)
		Data.CHAR_LVL:
			levelLabel.text = String(value)
		Data.CHAR_XP:
			xpLabel.text = String(value)
		Data.CHAR_XPMAX:
			maxXpLabel.text = String(value)
		Data.CHAR_R_FIRE:
			rFire.text = ""
			for _i in range(value[1]):
				rFire.text += "-"
			for i in range(value[0]):
				rFire.text[i] = "*"
		Data.CHAR_R_POISON:
			rPois.text = ""
			for _i in range(value[1]):
				rPois.text += "-"
			for i in range(value[0]):
				rPois.text[i] = "*"

func updateLocation(biome: int, currentFloor: int):
	locationLabel.text = "Currently in "
	match biome:
		Data.BIOME_DUNGEON:
			locationLabel.text += "Dungeon "
		Data.BIOME_CAVERN:
			locationLabel.text += "Cavern "
	locationLabel.text += Utils.toRoman(currentFloor)
