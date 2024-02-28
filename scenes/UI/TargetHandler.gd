extends Node

signal end_coroutine

var choices: Array = []
var currentChoice: int = 0
var lastTarget: int = -1

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_cancel")):
		endCoroutine(-1)
		return
	if (event.is_action_released("ui_accept")):
		endCoroutine(currentChoice)
		return
	elif (event.is_action_released("ui_right")):
		currentChoice = posmod(currentChoice+1, choices.size())
		lastTarget = choices[currentChoice]
		Ref.currentLevel.target(instance_from_id(lastTarget).pos)
		return
	elif (event.is_action_released("ui_left")):
		currentChoice = posmod(currentChoice-1, choices.size())
		lastTarget = choices[currentChoice]
		Ref.currentLevel.target(instance_from_id(lastTarget).pos)
		return

func startCoroutine(targets: Array):
	choices = targets
	selectLastTarget()
	Ref.currentLevel.target(instance_from_id(lastTarget).pos)
	set_process_input(true)

func endCoroutine(result: int):
	set_process_input(false)
	Ref.currentLevel.untarget()
	choices = []
	currentChoice = 0
	emit_signal("end_coroutine", result)

func selectLastTarget():
	var find = choices.find(lastTarget)
	if find > 0:
		currentChoice = find
	else:
		currentChoice = 0
		lastTarget = choices[currentChoice]
