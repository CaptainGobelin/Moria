extends Node

const REPORT_SIZE = 1

var filePath = "res://doc/reports/"
var reportMode: bool = false
var report: Dictionary = {}

const LI_BIOME = 0
const LI_CR = 1
const LI_DIFF_CR = 2
const LI_MONST = 3
const LI_REPORTS = 4
var titleLine = ["LEVEL", "CR", "DIFF CR", "MONSTERS", "REPORTS"]
var emptyLine = ["", 0, 0, {}, 0]

# Generate a report with: retries, items, locked/hidden doors
func generateReport():
	reportMode = true
	displayProgress(0, 1)
	for i in range(REPORT_SIZE):
		var level = 0
		Ref.game.startGame()
		yield(get_tree(), "idle_frame")
		storeLevel(level)
		while Ref.game.nextFloor():
			if Ref.currentLevel.isBossRoom:
				continue
			yield(get_tree(), "idle_frame")
			level += 1
			storeLevel(level)
		displayProgress((i+1), REPORT_SIZE)
	processReport()
	printReport()
	get_tree().quit()

func storeLevel(level: int):
	if not report.has(level):
		report[level] = emptyLine.duplicate(true)
	report[level][LI_BIOME] = String(WorldHandler.currentBiome+1) + "-" + String(WorldHandler.currentFloor)
	report[level][LI_CR] += Ref.game.dungeonGenerator.encountersCR
	report[level][LI_DIFF_CR] += WorldHandler.diffCR
	for m in Ref.currentLevel.monsters.get_children():
		if report[level][LI_MONST].has(m.type):
			report[level][LI_MONST][m.type] += 1
		else:
			report[level][LI_MONST][m.type] = 1
	report[level][LI_REPORTS] += 1

func processReport():
	for r in report:
		report[r][LI_CR] /= report[r][LI_REPORTS]
		report[r][LI_DIFF_CR] = Utils.to2dec(report[r][LI_DIFF_CR]/report[r][LI_REPORTS])
		var monsters = ""
		var mIndex = report[r][LI_MONST].keys()
		mIndex.sort()
		for m in mIndex:
			monsters += Data.monsters[m][Data.MO_NAME] + ": " + String(Utils.to2dec(report[r][LI_MONST][m])/report[r][LI_REPORTS]) + " "
		report[r][LI_MONST] = monsters

func printReport():
	var file = File.new()
	file.open(filePath + "levels_analysis" + ".csv", File.WRITE)
	file.store_csv_line(titleLine)
	for l in report.values():
		file.store_csv_line(l)
	file.close()

func displayProgress(current: int, maximum: int):
	var progress = float(current)/float(maximum)
	var msg: String = ""
	for i in range(50):
		if progress > float(i)/50.0: 
			msg += "█"
		else:
			msg += "▒"
	print(msg + " " + String(int(progress*100)) + "%")
