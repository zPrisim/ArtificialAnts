extends Node2D
var ant = preload("res://scenes/ant.tscn")
var food = preload("res://scenes/food.tscn")
var homePheromones : Array 
var foodPheromones : Array 
var ants : Array
@onready var anthill = $anthill


func _ready():
	
	anthill.monitoring = true
	var instFood = food.instantiate()
	instFood.radius = 50.0
	instFood.pos = Vector2(500,500)
	add_child(instFood)

	
	
	for i in range (0,30):
		var instAnt = ant.instantiate()
		instAnt.id = i 
		instAnt.position = anthill.position
		add_child(instAnt)
		ants.append(instAnt)
	
func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)
