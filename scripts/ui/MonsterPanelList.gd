extends Node2D

class TargetSorter:
	static func sort_by_hp(a, b):
		var mA = instance_from_id(a)
		var mB = instance_from_id(b)
		if mA.stats.currentHp < mB.stats.currentHp:
			return true
		return false

func fillList():
	for row in get_children():
		row.visible = false
	var data = GLOBAL.targets.keys().duplicate()
#	data.sort_custom(TargetSorter, "sort_by_hp")
	var count = 0
	for id in data:
		if count >= get_child_count():
			return
		var row = get_child(count)
		if row.setData(id):
			count += 1
