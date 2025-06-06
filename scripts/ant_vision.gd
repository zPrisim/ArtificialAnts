extends Area2D

func sensor(group : String) -> Node2D: 
	var value = get_overlapping_bodies()
	if value != []:
		for i in value.size():
			if value[i].is_in_group(group):
				return value[i]
	return null
	
