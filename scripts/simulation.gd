extends Node2D

func _ready():
	var ant = preload("res://scenes/ant.tscn") 
	for i in range (0,100):
		var instAnt = ant.instantiate()
		var x = randi() % 600 
		var y = randi() % 600
		instAnt.position = Vector2(x, y) 
		add_child(instAnt)
	
func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)
	
