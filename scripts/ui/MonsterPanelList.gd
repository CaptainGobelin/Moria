extends Node2D

class TargetSorter:
	static func sort_by_hp(a, b):
		var mA = instance_from_id(a)
		var mB = instance_from_id(b)
		if mA.stats.currentHp < mB.stats.currentHp:
			return true
		return false

func fillList():
	var data = GLOBAL.targets.keys().duplicate()
#	data.sort_custom(TargetSorter, "sort_by_hp")
	var count = 0
	for row in get_children():
		if count < data.size():
			row.setData(data[count])
		else:
			row.visible = false
		count += 1
