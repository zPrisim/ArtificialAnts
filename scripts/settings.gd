extends Node

enum types {HOME, FOOD}
var antHillPos = Vector2(640,360)



var pheromoneSpawnTimeDelay : float = 0.3
var pheromoneLifTime : float = 20.0
var antLifeTime : int = 120
var antSpawnCheckDelay : float = 1.0
var numberOfFoodToSpawnAnts : int = 10
