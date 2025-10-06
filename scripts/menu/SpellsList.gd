tool
extends Node2D

export (bool) var isSimple = true
export (int) var size = 4 setget setSize

var spellList: Array = []
var maxIndex: int  = 0
var currentIndex: int = 0
var currentStartIndex: int = 0

func setSize(value: int):
	if value <= 0 or value == size:
		return
	size = value
	for c in get_children():
		c.free()
	for i in range(size):
		var scene = ResourceLoader.load("res://scenes/menu/SpellRow.tscn")
		var row = scene.instance()
		add_child(row)
		row.position.y = 18 * i

func init(spells: Array, index = 0):
	spellList = spells
	maxIndex = spells.size()
	setContent()
	if maxIndex > 0:
		if maxIndex > index:
			select(index)
		else:
			select(maxIndex - 1)

func setContent():
	var count = currentStartIndex
	for s in get_children():
		if count < maxIndex:
			if isSimple:
				s.setSimpleContent(spellList[count])
			else:
				s.setContent(spellList[count])
			s.visible = true
		else:
			s.visible = false
		count += 1
	get_parent().scroller.setArrows(currentStartIndex, maxIndex)

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
	if (currentIndex + currentStartIndex) >= (maxIndex - 1):
		currentStartIndex = 0
		setContent()
		select(0)
	elif currentIndex >= (size - 1):
		currentStartIndex += 1
		setContent()
		select(currentIndex)
	else:
		select(currentIndex + 1)

func selectPrevious():
	if currentIndex == 0:
		if currentStartIndex == 0:
			currentStartIndex = maxIndex - size
			setContent()
			select(size - 1)
		else:
			currentStartIndex -= 1
			setContent()
			select(currentIndex)
	else:
		select(currentIndex - 1)
