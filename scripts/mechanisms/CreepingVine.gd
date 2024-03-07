extends TileMap

var rootPos = Vector2(0, 0)
var growingCells = {}

func _ready():
	init(Vector2(20, 10))

func init(pos: Vector2):
	rootPos = pos
	addGrowingCells(pos)
	set_cellv(pos, 0)
	set_process_input(true)

func _input(event):
	if event.is_action_released("debug_new_floor"):
		grow()

func addGrowingCells(pos: Vector2):
	var newCellTile = [2, 8, 4, 1]
	var oldCellOffset = [8, 2, 1, 4]
	var cells = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	for i in range(4):
		if get_cellv(cells[i] + pos) != -1:
			continue
		if !growingCells.has(cells[i] + pos) or randi() % 2 == 0:
			growingCells[cells[i] + pos] = [newCellTile[i], pos, oldCellOffset[i]]

func grow():
	if growingCells.size() == 0:
		return
	var cell = growingCells.keys()[randi() % growingCells.size()]
	set_cellv(cell, growingCells[cell][0])
	var oldCellTile = get_cellv(growingCells[cell][1])
	if (oldCellTile != 0):
		set_cellv(growingCells[cell][1], oldCellTile + growingCells[cell][2])
	addGrowingCells(cell)
	growingCells.erase(cell)
