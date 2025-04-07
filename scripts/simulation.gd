extends Node2D
@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var antHill = $antHill
var homePheromones : Array 
var foodPheromones : Array 
var ants : Array

func _ready():
	
	antHill.position = Vector2(640,360)
	var instFood = food.instantiate()
	instFood.radius = 50.0
	instFood.position = Vector2(500,500)
	add_child(instFood)
	
	for i in range (0,200):
		var instAnt = ant.instantiate()
		instAnt.id = i 
		instAnt.position = antHill.position
		add_child(instAnt)
		ants.append(instAnt)
	
func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)
