extends Node2D

@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var antHill = $antHill

enum types {HOME, FOOD}



var antHillPos = Vector2(640,360)

var ants : Array
var foods : Array

var antNumber : int = 1


func _ready():
	antHill.position = antHillPos
	var instFood = food.instantiate()
	instFood.radius = 25.0
	instFood.position = Vector2(500,500)
	add_child(instFood)
	foods.append(instFood)
	
	var instFood2 = food.instantiate()
	instFood2.radius = 50.0
	instFood2.position = Vector2(200,200)
	add_child(instFood2)
	foods.append(instFood2)
	
	ants_around_anthill(antHill.position,25.0,ant,antNumber,0.0)

	# Gerer quand plusieurs phéromones au même endroit : somme des valeur, modification de la couleur etc


func ants_around_anthill(circle_center : Vector2, circle_radius : float, object : PackedScene, count : int, base_rotation : float):
	var radial_offset = Vector2.RIGHT.rotated(base_rotation) * circle_radius
	var radial_increment = (2.0 * PI) / float(count)
	for i in count:
		var instance = object.instantiate()
		instance.id = i
		instance.position = circle_center + radial_offset
		instance.rotation = radial_offset.angle()
		add_child(instance)
		ants.append(instance)
		radial_offset = radial_offset.rotated(radial_increment)


func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)
