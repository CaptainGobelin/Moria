extends Node2D

var maxIndex: int  = 0
var currentIndex: int = 0

func init(spells: Array):
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
		select(0)

func getSelected():
	for s in get_children():
		if s.visible and s.selected.visible:
			return s.spell
	return null

func select(index):
	if index >= 0 and index < maxIndex:
		get_child(currentIndex).selected.visible = false
		currentIndex = index
		get_child(index).selected.visible = true

func selectNext():
	select(currentIndex + 1)

func selectPrevious():
	select(currentIndex - 1)
