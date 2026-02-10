extends Node

var currentBiome: int
var currentFloor: int
var currentCR: int = 1
var diffCR: float = 0.0

func init(biome: int = Data.BIOME_DUNGEON, level: int = 1):
	setLocation(level, biome)

func setLocation(newFloor: int, newBiome = currentBiome):
	currentFloor = newFloor
	currentBiome = newBiome
	Ref.ui.updateLocation(currentBiome, currentFloor)

func getNextLocation() -> bool:
	if currentFloor < Data.biomes[currentBiome][Data.BI_FLOORS]:
		setLocation(WorldHandler.currentFloor + 1)
	else:
		if Data.biomes[currentBiome][Data.BI_CONNECT].empty():
			return false
		else:
			setLocation(1, Data.biomes[currentBiome][Data.BI_CONNECT][0])
			currentCR += 1
	return true

func getLevelNormalCR() -> int:
	return 5 * Data.biomes[currentBiome][Data.BI_CR] + currentFloor

func getGlobalDc() -> int:
	return int(floor((currentCR - 1)/2))
