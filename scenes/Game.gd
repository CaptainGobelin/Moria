extends Node2D

class_name Game

onready var inventoryMenu = get_node("InventoryMenu")
onready var characterMenu = get_node("CharacterMenu")
onready var dungeonGenerator = get_node("Utils/DungeonGenerator_v2")
onready var pathfinder = get_node("Utils/Pathfinder")
onready var itemGenerator = get_node("Utils/ItemGenerator") as ItemGenerator

var coroutineReturn
var mode = ""
var choiceList = []

func _ready():
	Ref.game = self
	pathfinder.init()
	dungeonGenerator.newFloor()
	Ref.currentLevel.initShadows()
	Ref.currentLevel.placeCharacter()
	for _i in range(5):
		Ref.currentLevel.spawnMonster()
	for _i in range(15):
		Ref.currentLevel.dropItem()
	set_process_input(true)

func _input(event):
	if (event.is_action_pressed("ui_up")):
		cancelMode()
		Ref.character.move(Vector2(0,-1))
	elif (event.is_action_pressed("ui_down")):
		cancelMode()
		Ref.character.move(Vector2(0,1))
	elif (event.is_action_pressed("ui_left")):
		cancelMode()
		Ref.character.move(Vector2(-1,0))
	elif (event.is_action_pressed("ui_right")):
		cancelMode()
		Ref.character.move(Vector2(1,0))
	elif (event.is_action_released("inventory")):
		cancelMode()
		inventoryMenu.open()
		return
	elif (event.is_action_released("characterMenu")):
		cancelMode()
		characterMenu.open()
		return
	elif (event.is_action_released("pickLoot")):
		cancelMode()
		var loots = Ref.currentLevel.checkForLoot(Ref.character.pos)
		if loots.size() == 0:
			Ref.ui.writeNoLoot()
		elif loots.size() == 1:
			if loots[0].size() == 1:
				Ref.character.pickItem(loots[0][0])
			else:
				Ref.ui.askForNumber(loots[0].size())
				yield(Ref.ui, "coroutine_signal")
				if coroutineReturn != null and coroutineReturn is int:
					for c in range(coroutineReturn):
						Ref.character.pickItem(loots[0][c])
				else:
					Ref.ui.write("Ok then.")
				coroutineReturn = null
		else:
			Ref.ui.write(Ref.currentLevel.getLootChoice(loots))
			mode = "pickItem"
			choiceList = loots
	else:
		for i in range(0, 9):
			if (event.is_action_released("shortcut" + String(i))):
				if choiceList.size() < i:
					return
				match mode:
					"pickItem":
						if choiceList[i-1].size() == 1:
							Ref.character.pickItem(choiceList[i-1][0])
						else:
							Ref.ui.askForNumber(choiceList[i-1].size())
							yield(Ref.ui, "coroutine_signal")
							if coroutineReturn != null and coroutineReturn is int:
								for c in range(coroutineReturn):
									Ref.character.pickItem(choiceList[i-1][c])
							else:
								Ref.ui.write("Ok then.")
							coroutineReturn = null
						mode = ""
						cancelMode()
				return

func cancelMode():
	if mode != "":
		Ref.ui.write("Ok then.")
	mode = ""
	choiceList = []

func getReturnedNumber(result):
	coroutineReturn = result
