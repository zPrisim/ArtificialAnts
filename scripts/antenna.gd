extends Area2D

func sensor() -> Array[Area2D]: 
	var value = get_overlapping_areas()
	return value
	
