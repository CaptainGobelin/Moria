extends Node

signal end_coroutine

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_cancel")):
		endCoroutine(true)
		return
	elif (event.is_action_released("ui_accept")):
		endCoroutine(true)
		return

func startCoroutine():
	Ref.ui.simpleWrite('\n' + Ref.ui.color("Press [ENTER] to continue...", "green"))
	MasterInput.setMaster(self)

func endCoroutine(result: bool):
	emit_signal("end_coroutine", result)
