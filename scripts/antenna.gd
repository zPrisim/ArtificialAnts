extends Area2D

func sensor() -> Array[Area2D]: 
	var value = get_overlapping_areas()
	return value
	
func _draw():
	draw_circle(Vector2(0,0),$CollisionShape2D.shape.radius,Color.VIOLET,0)
