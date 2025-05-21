extends Node

enum types {HOME, FOOD}

var antHillPos := Vector2(640,360)
var defaultFoodSize := 1000


var pheromoneSpawnTimeDelay : float = 0.3
var pheromoneLifeTime : float = 30.0
var pheromoneBaseValue : float = 10.0

var antLifeTime : int = 100000 # à changer
var antSpawnCheckDelay : float = 1.0
var antReproduction := false
var numberOfFoodToSpawnAnts : int = 10

var seedChange := true
var lastSeed := 0

var mapPresetIndex := 5
var mapPaintSize := 1.5
var paintMode := true

var isPaint := false
var isZoomed := false

func getMapSettings() -> Array[Vector2]: # 1280 * 720
	var mapSettings : Array[Vector2] = []
	match mapPresetIndex:
		1:
			mapSettings.append(Vector2(640,35))
			mapSettings.append(Vector2(240,620))
			mapSettings.append(Vector2(1040,620))
		2:
			mapSettings.append(Vector2(640,35))
			mapSettings.append(Vector2(240,620))
			mapSettings.append(Vector2(1040,620))
		3:
			mapSettings.append(Vector2(640,35))
			mapSettings.append(Vector2(240,310))
			mapSettings.append(Vector2(1040,620))
		4:
			mapSettings.append(Vector2(240,35))
			mapSettings.append(Vector2(240,310))
			mapSettings.append(Vector2(1040,620))
		5:
			mapSettings.append(Vector2(600,35))
			mapSettings.append(Vector2(820,500))
		_:
			pass
	return mapSettings
