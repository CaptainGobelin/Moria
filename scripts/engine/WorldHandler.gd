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
	currentCR = Data.biomes[newBiome][Data.BI_CR]
	Ref.ui.updateLocation(currentBiome, currentFloor)

func getNextLocation() -> bool:
	if currentFloor < Data.biomes[currentBiome][Data.BI_FLOORS]:
		setLocation(WorldHandler.currentFloor + 1)
	else:
		if Data.biomes[currentBiome][Data.BI_CONNECT].empty():
			return false
		else:
			setLocation(1, Data.biomes[currentBiome][Data.BI_CONNECT][0])
	return true

func getLevelNormalCR() -> float:
	var floorMod = 0.1 * currentFloor
	return 4 * (Data.biomes[currentBiome][Data.BI_CR] + floorMod)

func getGlobalDc() -> int:
	return int(floor((currentCR - 1)/2))
