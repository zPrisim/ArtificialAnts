extends Area2D

enum types {HOME, FOOD}

var tabPheromone = []


func pheromoneSensor() -> float: 
	var pheromones = get_overlapping_areas()
	if  pheromones != []:
		var sum : float = 0
		for p in pheromones:
			if tabPheromone.find(p,0) == -1:
				sum+= p.value
			tabPheromone.append(p)
		return sum
	return 0.0
