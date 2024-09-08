extends Node2D

onready var npcScene = preload("res://scenes/Npc.tscn")

onready var map = get_node("Walls")
onready var masks = get_node("Masks")

onready var dungeon: TileMap

var array:Array = []

const ENTRY = 0
const MERCHANT = 1
const GAMBLER = 2
const SHOPS = 3
const GAMES = 4
const SPAWN = 5
const CELLS = 6
const roomOffset = Vector2(10, 5)

func newFloor():
	dungeon = Ref.currentLevel.dungeon as TileMap
	array = []
	for i in range(GLOBAL.FLOOR_SIZE_X):
		array.append([])
		for _j in range(GLOBAL.FLOOR_SIZE_Y):
			array[i].append(GLOBAL.WALL_ID)
	for c in map.get_used_cells():
		array[c.x+roomOffset.x][c.y+roomOffset.y] = map.get_cellv(c)
		#Spawn shopkeeper
	var merchant = npcScene.instance()
	merchant.type = merchant.MERCHANT_TYPE
	Ref.currentLevel.npcs.add_child(merchant)
	merchant.setPosition(masks.get_used_cells_by_id(MERCHANT+1)[0] + roomOffset)
	merchant.welcome()
	for c in masks.get_used_cells_by_id(SHOPS+1):
		generateArticle(c + roomOffset)
	#Todo generate shops
	get_parent().drawFloor(array)
	var entry = masks.get_used_cells_by_id(ENTRY+1)[0] + roomOffset
	dungeon.set_cellv(entry, GLOBAL.PASS_ID, false, false, false, Vector2(1, 0))
	return masks.get_used_cells_by_id(SPAWN+1)[0] + roomOffset

func generateArticle(cell: Vector2):
	var rarity = (randi() % 3) + 1
	var items = Ref.game.itemGenerator.generateItem(rarity, -1, true)
	var price = rarity * 5 + (randi() % 20)
	price = int(ceil(price / items.size()))
	for item in items:
		GLOBAL.dropItemOnFloor(item, cell, true, price, false)
