extends Node

var masterInput = null
var oldMaster = null

func setMaster(node: Node):
	if masterInput != null:
		masterInput.set_process_input(false)
	oldMaster = masterInput
	masterInput = node
	masterInput.set_process_input(true)
