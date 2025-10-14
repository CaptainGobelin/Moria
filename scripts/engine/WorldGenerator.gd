extends Node

const LVL_ENC = 0
const LVL_FEAT = 1
const LVL_CURSE = 2
const LVL_SPEC = 3
const LVL_LOOT = 4
const LVL_TREASURE = 5

const FEAT_NORMAL = 0
const FEAT_MERCHANT = 1
const FEAT_CHALLENGE = 2

const LVL_DEFAULT = [0, FEAT_NORMAL, false, false, [], []]

var levels: Array = []

func _ready():
	generate()
	print("========================================")
	var l = {}
	l["Generated run:"] = levels
	Utils.printDict(l)
	print("========================================")

func generate():
	levels.clear()
	for _i in range(30):
		levels.append(LVL_DEFAULT.duplicate(true))
	var rnd = 5 + (randi() % 5)
	levels[rnd][LVL_FEAT] = FEAT_MERCHANT
	rnd = 10 + (randi() % 5)
	levels[rnd][LVL_FEAT] = FEAT_CHALLENGE
	rnd = 15 + (randi() % 5)
	levels[rnd][LVL_FEAT] = FEAT_MERCHANT
	rnd = 20 + (randi() % 5)
	levels[rnd][LVL_FEAT] = FEAT_CHALLENGE
	levels[25][LVL_FEAT] = FEAT_MERCHANT
	var curse1 = 5 + (randi() % 25)
	var curse2 = 5 + (randi() % 25)
	while curse1 == curse2:
		curse2 = 5 + (randi() % 25)
	var curse3 = 5 + (randi() % 25)
	while curse1 == curse3 or curse2 == curse3:
		curse3 = 5 + (randi() % 25)
	levels[curse1][LVL_CURSE] = true
	levels[curse2][LVL_CURSE] = true
	levels[curse3][LVL_CURSE] = true
	for i in range(30):
		if randf() < 0.16:
			levels[i][LVL_SPEC] = true
		levels[i][LVL_ENC] = 3 + (randi() % 4)
		rnd = 6 + (randi() % 5)
		for _j in range(rnd):
			if randf() < 0.65:
				var dRar = 0
				var prob = randf()
				if prob < 0.1:
					dRar = -1
				elif prob >= 0.7:
					dRar = 1
				levels[i][LVL_TREASURE].append((i % 5) + dRar)
			else:
				var dRar = 0
				var prob = randf()
				if prob < 0.3:
					dRar = -1
				elif prob >= 0.9:
					dRar = 1
				levels[i][LVL_LOOT].append((i % 5) + dRar)
