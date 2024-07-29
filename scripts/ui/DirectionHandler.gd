extends Node

signal end_coroutine

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_cancel")):
		endCoroutine(Vector2(0, 0))
		return
	elif (event.is_action_released("ui_up")):
		endCoroutine(Vector2(0, -1))
		return
	elif (event.is_action_released("ui_right")):
		endCoroutine(Vector2(1, 0))
		return
	elif (event.is_action_released("ui_down")):
		endCoroutine(Vector2(0, 1))
		return
	elif (event.is_action_released("ui_left")):
		endCoroutine(Vector2(-1, 0))
		return

func startCoroutine():
	set_process_input(true)

func endCoroutine(result: Vector2):
	set_process_input(false)
	if result == Vector2(0, 0):
		Ref.ui.writeOk()
	emit_signal("end_coroutine", result)
