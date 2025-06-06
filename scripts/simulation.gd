extends Node2D

@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var mapManager = preload("res://scenes/mapManager.tscn")
@onready var simulationUI = preload("res://scenes/SimulationUi.tscn")
@onready var antHill : Anthill = $antHill
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

var lastUIFoodSize := 50


func _ready():
	Engine.time_scale = 1.0
	UI = simulationUI.instantiate()
	var layer = CanvasLayer.new()
	layer.add_child(UI)
	add_child(layer)
	
	UI.ant_button_pressed.connect(_on_ant_button_pressed)
	antTimer = Timer.new()

	antTimer.connect("timeout", _on_timer_check)	
	antTimer.set_timer_process_callback(Timer.TIMER_PROCESS_PHYSICS)
	add_child(antTimer)

	var instMapManager= mapManager.instantiate()
	add_child(instMapManager)
	
	var mapSettings := Settings.getMapSettings()
	if mapSettings == []:
		antHill.position = Settings.antHillPos
	else:
		antHill.position =	mapSettings[0]
		for i in range(1,mapSettings.size()):
			spawnFoodSource(mapSettings[i],Settings.defaultFoodSize)
	
	antTimer.start(antSpawnTime)

func _on_timer_check():
	var numberToSpawn : int
	if antHill.foodNumber - lastFoodNumber > 10:
		numberToSpawn = (antHill.foodNumber - int(lastFoodNumber))/ Settings.numberOfFoodToSpawnAnts
		
	if  Settings.antReproduction:
		ants_around_anthill(antHill.global_position, 25.0,ant,numberToSpawn, randf_range(-PI, + PI))
	
	lastFoodNumber = antHill.foodNumber
	for a in toBeDeadAnts:
		if !a.hasFood && a.get_parent() == self: # a.hasFood ou lastFood != null?
			ants.erase(a)
			remove_child(a)
			a.queue_free()
	toBeDeadAnts = []


func _on_ant_button_pressed(value):
	if startTime == 0:
		startTime = Time.get_unix_time_from_system()

	ants_around_anthill(antHill.global_position, 25.0,ant,value,0.0)

func _input(event):
	if event.is_action_pressed("restart_map"):
		get_tree().reload_current_scene()
		Settings.isZoomed = false

	if !Settings.isZoomed:
		if event is InputEventMouseButton and event.is_pressed():
			var mousePos = get_global_mouse_position()
			if mousePos.x < 1280 and mousePos.y < 720:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if canPlaceFood:
						for f in foods:
							if f.global_position.distance_to(mousePos) <= f.radius:
								f.queue_free()
								remove_child(f)
								foods.erase(f)
								return
						spawnFoodSource(mousePos, lastUIFoodSize)



func followAnt(antId: int) -> void:
	if followedAnt:
		# Nettoyage si une caméra existe déjà
		for child in followedAnt.get_children():
			if child is Camera2D:
				$Camera2D.enabled = true
				child.queue_free()
		Settings.isZoomed = false

	if antId >= 0 and antId < ants.size():
		var antToFollow = ants[antId]
		
		var camera = Camera2D.new()
		camera.enabled = true
		$Camera2D.enabled = false

		camera.zoom = Vector2(3.0, 3.0) 
		antToFollow.add_child(camera)
		followedAnt = antToFollow
		Settings.isZoomed = true

func spawnFoodSource(pos : Vector2, v : float):
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
