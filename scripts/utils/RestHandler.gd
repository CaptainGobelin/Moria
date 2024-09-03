extends Node

func _ready():
	set_process_input(false)

func _input(event):
	if event.is_action_released("ui_accept"):
		wakeUp()
	elif event.is_action_released("ui_cancel"):
		wakeUp()

func askrForRest():
	MasterInput.setMaster(self)
	set_process_input(false)
	if Ref.character.inventory.rests <= 0:
		Ref.ui.noMoreRest()
		close()
		return
	Ref.ui.askForRest(Ref.character.inventory.rests)
	Ref.ui.askForYesNo(self)
	var coroutineReturn = yield(Ref.ui, "coroutine_signal")
	set_process_input(false)
	if (coroutineReturn):
		if Ref.currentLevel.monsters.get_child_count() == 0:
			rest()
		else:
			Ref.ui.writeNoSafeRest()
			close()

func rest():
	Ref.character.rest()
	Ref.ui.fadePanel.connect("fadeIn", self, "waitForInput", [], CONNECT_ONESHOT)
	Ref.ui.fadePanel.fadeIn()

func wakeUp():
	Ref.ui.fadePanel.connect("fadeOut", self, "close", [], CONNECT_ONESHOT)
	Ref.ui.fadePanel.fadeOut()

func waitForInput():
	MasterInput.setMaster(self)

func close():
	MasterInput.setMaster(Ref.game)
