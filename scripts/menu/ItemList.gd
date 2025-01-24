extends Node2D

signal itemSelected

var currentItems: Array = []
var currentType: int = 0
var maxIndex: int = 6
var currentIndex: int = 0
var currentStartRow: int = 0

func init(items: Array, row: int, type: int, startRow = 0):
	maxIndex = items.size()
	currentItems = items
	currentType = type
	currentStartRow = max(0, min(startRow, maxIndex-6))
	for i in range(currentStartRow, currentStartRow + 6):
		var itemRow = get_child(i-currentStartRow)
		if i < maxIndex:
			itemRow.setContent(items[i], type)
			itemRow.visible = true
			itemRow.selected.visible = false
		else:
			itemRow.visible = false
	if maxIndex > 0:
		row = min(row, maxIndex-1)
		select(row, false)
	else:
		get_parent().scroller.setArrows(0, 0)
		emit_signal("itemSelected", getSelected())

func getSelected():
	for i in get_children():
		if i.visible and i.selected.visible:
			return i.item
	return null

func select(index, erasePrevious = true):
	if maxIndex == 0:
		return
	if index == -1:
		init(currentItems, maxIndex - 1, currentType, maxIndex - 6)
	else:
		if erasePrevious:
			get_child(currentIndex).selected.visible = false
		currentIndex = posmod(index, maxIndex)
		get_child(currentIndex).selected.visible = true
		get_parent().scroller.setArrows(currentStartRow, maxIndex)
		emit_signal("itemSelected", getSelected())

func selectNext():
	# Scroll down
	if currentIndex == 5 and maxIndex > currentStartRow + 6:
		init(currentItems, currentIndex, currentType, currentStartRow + 1)
	# Loop to begining
	elif currentStartRow + currentIndex == maxIndex -1:
		init(currentItems, 0, currentType, 0)
	# Just move cursor
	else:
		select(currentIndex + 1)

func selectPrevious():
	# Scroll up
	if currentIndex == 0 and currentStartRow > 0:
		init(currentItems, currentIndex, currentType, currentStartRow - 1)
	# Loop to end
	elif currentIndex == 0:
		init(currentItems, 5, currentType, maxIndex - 6)
	# Just move cursor
	else:
		select(currentIndex - 1)
