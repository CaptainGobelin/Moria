extends Node2D

var maxIndex: int  = 0
var currentIndex: int = 0

func init(spells: Array, index = 0):
	maxIndex = spells.size()
	var count = 0
	for s in get_children():
		if count < maxIndex:
			s.setContent(spells[count])
			s.visible = true
		else:
			s.visible = false
		count += 1
	if maxIndex > 0:
		if maxIndex > index:
			select(index)
		else:
			select(maxIndex - 1)

func getSelected():
	for s in get_children():
		if s.visible and s.selected.visible:
			return s.spell
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
