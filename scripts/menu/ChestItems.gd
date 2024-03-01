extends Node2D

var currentItems: Array = []
var maxIndex: int = 6
var currentIndex: int = 0

func init(items: Array, row: int):
	maxIndex = items.size()
	currentItems = items
	for i in range(0, 3):
		var itemRow = get_child(i)
		itemRow.extended.visible = false
		if i < maxIndex:
			itemRow.setContent(items[i], items[i][0])
			itemRow.visible = true
			itemRow.selected.visible = false
		else:
			itemRow.visible = false
	if maxIndex > 0:
		row = min(row, maxIndex-1)
		select(row)

func getSelected():
	for i in get_children():
		if i.visible and i.selected.visible:
			return i.item
	return null

func select(index):
	if maxIndex == 0:
		return
	get_child(currentIndex).selected.visible = false
	currentIndex = posmod(index, maxIndex)
	get_child(currentIndex).selected.visible = true

func selectNext():
	select(currentIndex + 1)

func selectPrevious():
	select(currentIndex - 1)
