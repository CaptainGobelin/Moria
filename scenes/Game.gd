extends Node2D

class_name Game

onready var inventoryMenu = get_node("InventoryMenu")
onready var characterMenu = get_node("CharacterMenu")
onready var dungeonGenerator = get_node("Utils/DungeonGenerator_v2")
onready var pathfinder = get_node("Utils/Pathfinder")
onready var itemGenerator = get_node("Utils/ItemGenerator") as ItemGenerator
onready var pickupLootHandler = get_node("Utils/PickupLootHandler")

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
		Ref.character.move(Vector2(0,-1))
	elif (event.is_action_pressed("ui_down")):
		Ref.character.move(Vector2(0,1))
	elif (event.is_action_pressed("ui_left")):
		Ref.character.move(Vector2(-1,0))
	elif (event.is_action_pressed("ui_right")):
		Ref.character.move(Vector2(1,0))
	elif (event.is_action_released("inventory")):
		inventoryMenu.open()
	elif (event.is_action_released("characterMenu")):
		characterMenu.open()
	elif (event.is_action_released("pickLoot")):
		pickupLootHandler.pickupLoot()
