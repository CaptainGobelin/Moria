extends Node

signal end_coroutine

var currentChoice = ""
var currentSuffix = ""
var currentMax = 0

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_accept")):
		currentSuffix = currentChoice
		if currentChoice == "":
			currentChoice = String(currentMax)
		rewriteLastLine()
		returnNumber()
	elif (event.is_action_released("ui_cancel")):
		currentSuffix = ""
		rewriteLastLine()
		currentChoice = ""
		returnNumber()
	elif (event.is_action_released("ui_backspace")):
		if currentChoice.length() == 0:
			return
		currentChoice.erase(currentChoice.length() - 1, 1)
		if currentChoice.length() < String(currentMax).length():
			currentSuffix = currentChoice + "_"
		rewriteLastLine()
	for i in range(0, 10):
		if (event.is_action_released("shortcut" + String(i))):
			currentChoice += String(i)
			if int(currentChoice) > currentMax:
				currentChoice = String(currentMax)
			if currentChoice.length() < String(currentMax).length():
				currentSuffix = currentChoice + "_"
			else:
				currentSuffix = currentChoice
			rewriteLastLine()

func rewriteLastLine():
	Ref.ui.diary.remove_line(Ref.ui.diary.get_line_count()-1)
	Ref.ui.write("How much? (1-" + String(currentMax) + ") " + currentSuffix)

func startCoroutine(maxNb: int):
	currentMax = maxNb
	get_parent().set_process_input(false)
	currentChoice = ""
	currentSuffix = "_"
	Ref.ui.write("How much? (1-" + String(maxNb) + ") _")
	set_process_input(true)

func returnNumber():
	var result = 0
	if currentChoice.length() == 0:
		Ref.ui.writeOk()
		result = null
	else:
		result = int(currentChoice)
	if result == 0:
		Ref.ui.writeOk()
		result = null
	set_process_input(false)
	emit_signal("end_coroutine", result)
