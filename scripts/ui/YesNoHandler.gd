extends Node

signal end_coroutine

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_cancel")):
		endCoroutine(false)
		return
	elif (event.is_action_released("no")):
		endCoroutine(false)
		return
	elif (event.is_action_released("ui_accept")):
		endCoroutine(true)
		return
	elif (event.is_action_released("yes")):
		endCoroutine(true)
		return

func startCoroutine():
	set_process_input(true)

func endCoroutine(result: bool):
	set_process_input(false)
	emit_signal("end_coroutine", result)
