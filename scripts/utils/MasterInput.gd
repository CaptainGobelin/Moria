extends Node

var masterInput = null
var oldMasters: Array = []

func setMaster(node: Node):
	if is_instance_valid(masterInput):
		masterInput.set_process_input(false)
	oldMasters.append(masterInput)
	masterInput = node
	masterInput.set_process_input(true)

func cancelInput():
	if is_instance_valid(masterInput):
		masterInput.set_process_input(false)
	var inputer = oldMasters.pop_back()
	while inputer != null:
		if is_instance_valid(inputer):
			masterInput = inputer
			masterInput.set_process_input(true)
			return
		inputer = oldMasters.pop_back()
	eraseInputStack()

func eraseInputStack():
	if is_instance_valid(masterInput):
		masterInput.set_process_input(false)
	masterInput = null
	oldMasters.clear()
