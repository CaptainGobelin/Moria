extends Node

signal end_coroutine

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_cancel")):
		Ref.ui.writeOk()
		endCoroutine(false)
		return
	elif (event.is_action_released("no")):
		Ref.ui.writeOk()
		endCoroutine(false)
		return
	elif (event.is_action_released("yes")):
		endCoroutine(true)
		return

func startCoroutine(choice: String):
	set_process_input(true)

func endCoroutine(result: bool):
	set_process_input(false)
	emit_signal("end_coroutine", result)
