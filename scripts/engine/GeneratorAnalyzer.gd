extends Node

const REPORT_SIZE = 50

var reportMode: bool = false

# Generate a report with: retries, items, locked/hidden doors
func generateReport():
	reportMode = true
	displayProgress(0, 1)
	for biome in Data.biomes.keys():
		for i in range(REPORT_SIZE):
			Ref.game.dungeonGenerator.newFloor(biome)
			Ref.game.cleanFloor()
			GLOBAL.items.clear()
			displayProgress((i+1) + biome*REPORT_SIZE, Data.biomes.keys().size() * REPORT_SIZE)
			yield(get_tree(), "idle_frame")
	get_tree().quit()

func displayProgress(current: int, maximum: int):
	var progress = float(current)/float(maximum)
	var msg: String = ""
	for i in range(50):
		if progress > float(i)/50.0: 
			msg += "█"
		else:
			msg += "▒"
	print(msg + " " + String(int(progress*100)) + "%")
