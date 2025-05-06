extends Node2D

@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var map = preload("res://scenes/map.tscn")
@onready var antHill = $antHill


var antHillPos = Vector2(640,360)

var ants : Array
var toBeDeadAnts : Array
var foods : Array
var pheromones : Array

var lastFoodNumber : float

var antNumber : int = 200

var startTime = 0 # pour l'affichage -> infos

var antTimer : Timer
var antSpawnTime: float = Settings.antSpawnCheckDelay

var canPlaceFood := false

func _ready():
	startTime = Time.get_unix_time_from_system()
	SimulationUi.ant_button_pressed.connect(_on_ant_button_pressed)
	SimulationUi.food_button_pressed.connect(_on_food_button_pressed)
	antTimer = Timer.new()

	antTimer.connect("timeout", _on_timer_check)	
	
	add_child(antTimer)

	
	var instMap = map.instantiate()
	add_child(instMap)
	antHill.position =antHillPos
	
	antTimer.start(antSpawnTime)
	
"""
	instMapPheromoneHome = pheromoneMap.instantiate()
	instMapPheromoneHome.type = Settings.types.HOME

	add_child(instMapPheromoneHome)
	
	instMapPheromoneFood = pheromoneMap.instantiate()
	instMapPheromoneFood.type = Settings.types.FOOD
	add_child(instMapPheromoneFood)
"""
	#spawn_food_source(Vector2(500,500), 25)
	#spawn_food_source(Vector2(50,50), 25)
	#spawn_food_source(Vector2(900,300), 25)
	#spawn_food_source(Vector2(1100,600), 25)

	#ants_around_anthill(25.0,ant,antNumber,0.0)

func _on_timer_check():
	print_orphan_nodes()
	if  antHill.foodNumber - lastFoodNumber >= 5:
		ants_around_anthill(antHill.global_position, 25.0,ant,(antHill.foodNumber - int(lastFoodNumber))%10,0.0)
		lastFoodNumber = antHill.foodNumber
	for a in toBeDeadAnts:
		if !a.hasFood:
			toBeDeadAnts.erase(a)
			remove_child(a)
			a.queue_free()


func _on_ant_button_pressed():
	ants_around_anthill(antHill.global_position, 25.0,ant,SimulationUi.antSlider.value,0.0)


func _on_food_button_pressed():
	canPlaceFood = !canPlaceFood

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.position.x < 1280 and event.position.y < 720:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if canPlaceFood:
					for f in foods:
						if f.global_position.distance_to(event.position) <= f.radius:
							f.queue_free()
							remove_child(f)
							foods.erase(f)
							return
					spawn_food_source(event.position, SimulationUi.foodSlider.value)
				#elif event.button_index == MOUSE_BUTTON_RIGHT:
				


		
func spawn_food_source(pos : Vector2, v : float):
	var instFood = food.instantiate()
	instFood.radius = 25.0
	instFood.position = pos
	instFood.foodValue = v
	add_child(instFood)
	foods.append(instFood)

func ants_around_anthill(centre : Vector2, circle_radius : float, object : PackedScene, count : int, base_rotation : float):
	var radial_offset = Vector2.RIGHT.rotated(base_rotation) * circle_radius
	var radial_increment = (2.0 * PI) / float(count)
	var instance
	for i in count:
		instance = object.instantiate()
		instance.id = ants.size()
		instance.position = centre + radial_offset
		instance.rotation = radial_offset.angle()
		instance.anthill = antHill
		add_child(instance)
		ants.append(instance)
		radial_offset = radial_offset.rotated(radial_increment)


func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)	
