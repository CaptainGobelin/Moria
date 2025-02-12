extends Node

var masterInput = null
var oldMaster = null

func setMaster(node: Node):
	if is_instance_valid(masterInput):
		masterInput.set_process_input(false)
	oldMaster = masterInput
	masterInput = node
	masterInput.set_process_input(true)

func cancelInput(node: Node):
	if is_instance_valid(node):
		node.set_process_input(false)
	if masterInput == node:
		masterInput = null
