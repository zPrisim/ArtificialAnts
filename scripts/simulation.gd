extends Node2D

@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var antHill = $antHill

enum types {HOME, FOOD}

var antHillPos = Vector2(640,360)


var ants : Array
var foods : Array
var pheromones : Array

var antNumber : int = 200

var startTime = 0

func _ready():
	startTime = Time.get_unix_time_from_system()
	SimulationUi.ant_button_pressed.connect(_on_ant_button_pressed)
	#Engine.set_time_scale(2)
	#Engine.max_physics_steps_per_frame = 1;
	antHill.position = antHillPos
	
	#spawn_food_source(Vector2(500,500), 25)
	#spawn_food_source(Vector2(50,50), 25)
	#spawn_food_source(Vector2(900,300), 25)
	#spawn_food_source(Vector2(1100,600), 25)

	#ants_around_anthill(25.0,ant,antNumber,0.0)


func _on_ant_button_pressed():
	ants_around_anthill(25.0,ant,10,0.0)


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.position.x < 1280:
			if event.button_index == MOUSE_BUTTON_LEFT:
				spawn_food_source(event.position, 25.0)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				print("ttt")


		
func spawn_food_source(pos : Vector2, r : float):
	var instFood = food.instantiate()
	instFood.radius = r
	instFood.position = pos
	add_child(instFood)
	foods.append(instFood)

func ants_around_anthill(circle_radius : float, object : PackedScene, count : int, base_rotation : float):
	var radial_offset = Vector2.RIGHT.rotated(base_rotation) * circle_radius
	var radial_increment = (2.0 * PI) / float(count)
	var instance
	for i in count:
		instance = object.instantiate()
		instance.id = ants.size()
		instance.position = antHill.global_position + radial_offset
		instance.rotation = radial_offset.angle()
		instance.anthill = antHill
		add_child(instance)
		ants.append(instance)
		radial_offset = radial_offset.rotated(radial_increment)

func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)
