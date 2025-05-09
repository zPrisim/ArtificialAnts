extends Node2D

@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var map = preload("res://scenes/map.tscn")
@onready var simulationUI = preload("res://scenes/SimulationUi.tscn")
@onready var antHill = $antHill
var UI : Control

var ants : Array
var toBeDeadAnts : Array
var foods : Array
var pheromones : Array # utilisations dans ant_movement

var lastFoodNumber : float

var antNumber : int = 200

var startTime = 0 # pour l'affichage -> infos

var antTimer : Timer
var antSpawnTime: float = Settings.antSpawnCheckDelay

var canPlaceFood := false

var followedAnt: Node2D



func _ready():
	Engine.time_scale = 1.0
	UI = simulationUI.instantiate()
	var layer = CanvasLayer.new()
	layer.add_child(UI)
	add_child(layer)
	
	startTime = Time.get_unix_time_from_system()
	UI.ant_button_pressed.connect(_on_ant_button_pressed)
	UI.food_button_pressed.connect(_on_food_button_pressed)
	antTimer = Timer.new()

	antTimer.connect("timeout", _on_timer_check)	
	
	add_child(antTimer)

	var instMap = map.instantiate()
	add_child(instMap)
	antHill.position =	Settings.antHillPos
	
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
	#print_orphan_nodes()
	if  antHill.foodNumber - lastFoodNumber > 10:
		var numberToSpawn = (antHill.foodNumber - int(lastFoodNumber))/ Settings.numberOfFoodToSpawnAnts
		ants_around_anthill(antHill.global_position, 25.0,ant,numberToSpawn,0.0)
		lastFoodNumber = antHill.foodNumber
	for a in toBeDeadAnts:
		if !a.hasFood && a.get_parent() == self: # a.hasFood ou lastFood != null?
			ants.erase(a)
			remove_child(a)
			a.queue_free()
	toBeDeadAnts = []


func _on_ant_button_pressed():
	ants_around_anthill(antHill.global_position, 25.0,ant,UI.antSlider.value,0.0)


func _on_food_button_pressed():
	canPlaceFood = !canPlaceFood

func _input(event):
	if event.is_action_pressed("restart_map"):
		get_tree().reload_current_scene()

	if event is InputEventMouseButton and event.is_pressed():
		var mouse_pos = get_global_mouse_position()
		if mouse_pos.x < 1280 and mouse_pos.y < 720:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if canPlaceFood:
					for f in foods:
						if f.global_position.distance_to(mouse_pos) <= f.radius:
							f.queue_free()
							remove_child(f)
							foods.erase(f)
							return
					spawn_food_source(mouse_pos, UI.foodSlider.value)

				#elif event.button_index == MOUSE_BUTTON_RIGHT:
				



func followAnt(antId: int) -> void:
	if followedAnt:
		# Nettoyage si une caméra existe déjà
		for child in followedAnt.get_children():
			if child is Camera2D:
				$Camera2D.enabled = true
				child.queue_free()
	if antId >= 0 and antId < ants.size():
		var antToFollow = ants[antId]
		
		var camera = Camera2D.new()
		camera.enabled = true
		$Camera2D.enabled = false

		camera.zoom = Vector2(2.5, 2.5) 
		antToFollow.add_child(camera)
		followedAnt = antToFollow



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
