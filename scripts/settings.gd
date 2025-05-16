extends Node

enum types {HOME, FOOD}


var antHillPos = Vector2(640,360)



var pheromoneSpawnTimeDelay : float = 0.3
var pheromoneLifeTime : float = 20.0
var pheromoneBaseValue : float = 10.0

var antLifeTime : int = 100000 # à changer
var antSpawnCheckDelay : float = 1.0
var numberOfFoodToSpawnAnts : int = 10

var mapPresetIndex := 0
