extends Node

signal end_coroutine

var choiceList: Array = []

func _ready():
	set_process_input(false)

func _input(event):
	if (event.is_action_released("ui_cancel")):
		endCoroutine(-1)
		return
	for i in range(1, 10):
		if (event.is_action_released("shortcut" + String(i))):
			if choiceList.size() < i:
				return
			if choiceList[i-1] == null:
				return
			endCoroutine(i)
			return

func startCoroutine(list: Array):
	choiceList = list
	set_process_input(true)

func endCoroutine(result: int):
	set_process_input(false)
	emit_signal("end_coroutine", result)
