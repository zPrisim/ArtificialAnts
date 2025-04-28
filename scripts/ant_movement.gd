extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var rightSensor = $rightAntenna
@onready var centreSensor = $centre
@onready var leftSensor = $leftAntenna
@onready var vision = $antVision
@onready var frontObstacleRay = $frontRayCast2D

@export var id: int

var maxSpeed = 80.0
var steerStrength = 100.0
var wanderStrength = 0.1
var desiredDirection: Vector2
var desiredVelocity
var desiredSteeringForce
var acceleration
var wallAvoidanceStrength = 1.5

var anthill: Node2D
var pheromoneSpawnTimeDelay = 0.3
var pheromoneSpawnTimer: Timer
var hasFood: bool
var hadFood: bool
var lastFood: Node2D

const TIME_TO_UPDATE = 0.05
var updateTimer: Timer
var distMax = 1000

var sensor_direction : Vector2 = Vector2.ZERO

func _ready():
	add_to_group("ant")
	hadFood = false
	hasFood = false
	
	pheromoneSpawnTimer = Timer.new()
	pheromoneSpawnTimer.wait_time = pheromoneSpawnTimeDelay
	pheromoneSpawnTimer.one_shot = false
	pheromoneSpawnTimer.autostart = true
	pheromoneSpawnTimer.connect("timeout", _onTimerPheromoneSpawnTime)
	add_child(pheromoneSpawnTimer)

	updateTimer = Timer.new()
	updateTimer.wait_time = TIME_TO_UPDATE
	updateTimer.one_shot = false
	updateTimer.autostart = true
	updateTimer.connect("timeout", _on_timer_update)
	add_child(updateTimer)

func _onTimerPheromoneSpawnTime():
	if hasFood:
		get_parent().instMapPheromoneFood.addPheromones(position, Settings.types.FOOD)
	else:
		get_parent().instMapPheromoneHome.addPheromones(position, Settings.types.HOME)

func _on_timer_update():
	if !hasFood:
		sensor_direction = handlePheromoneSensors(Settings.types.FOOD)
	else:
		sensor_direction = handlePheromoneSensors(Settings.types.HOME)

func move(delta : float):
	var randomAngle = randf() * TAU
	var randomRadius = sqrt(randf())
	var randomPoint = Vector2(randomRadius * cos(randomAngle), randomRadius * sin(randomAngle))

	desiredDirection =  (desiredDirection + sensor_direction + (randomPoint * wanderStrength)).normalized()
	desiredVelocity = desiredDirection * maxSpeed
	desiredSteeringForce = (desiredVelocity - velocity) * steerStrength
	acceleration = desiredSteeringForce.limit_length(steerStrength)
	velocity = (velocity + acceleration * delta).limit_length(maxSpeed)
	rotation = atan2(velocity.y, velocity.x) + PI / 2

func turn() -> void:
	velocity = -velocity * 0.5  # on ralenti la vitesse
	desiredDirection = velocity 

func sumArray(a : Array):
	var sum = 0
	for i in a.size():
		sum += a[i].value
	return sum

func handlePheromoneSensors(t : Settings.types) -> Vector2:
	var map
	if t == Settings.types.FOOD:
		map = get_parent().instMapPheromoneFood
	else:
		map = get_parent().instMapPheromoneHome

	var leftPheromones = map.getPheromones(leftSensor.global_position)
	var centrePheromones = map.getPheromones(centreSensor.global_position)
	var rightPheromones = map.getPheromones(rightSensor.global_position)
	print(leftPheromones)
	if t == Settings.types.FOOD:
		set_collision_mask_value(2, true)
		set_collision_mask_value(5, false)
		var v = vision.sensor("foodRessource")
		if v != null:
			return (v.global_position - global_position).normalized()
		hadFood = false
	elif t == Settings.types.HOME:
		set_collision_mask_value(2, false)
		set_collision_mask_value(5, true)
		var v = vision.sensor("antHill")
		if v != null:
			return (v.global_position - global_position).normalized()

	var sumLeft = sumArray(leftPheromones)
	var sumCentre = sumArray(centrePheromones)
	var sumRight = sumArray(rightPheromones)

	if sumCentre > max(sumLeft, sumRight):
		return (centreSensor.global_position - global_position).normalized()
	elif sumLeft > sumRight:
		return (leftSensor.global_position - global_position).normalized()
	elif sumRight > sumLeft:
		return (rightSensor.global_position - global_position).normalized()
	return Vector2.ZERO

func handleFood(f):
	f.foodValue -= f.foodRatio / 10
	if f.foodValue < 1:
		f.queue_free()
	hasFood = true

func isNear(pA : Array, n : Node2D) -> Vector2:
	var minDist = 5000
	var minVec = Vector2.ZERO
	var dist
	for p in pA:
		dist = p.pos.distance_to(n.global_position)
		if dist < minDist:
			minDist = dist
			minVec = p.pos
	if minVec != Vector2.ZERO:
		return (minVec - global_position).normalized()
	return Vector2.ZERO

func _physics_process(delta: float) -> void:
	move(delta)


	var result = move_and_slide()
	if result:
		var collider = get_last_slide_collision().get_collider()
		if collider.is_in_group("foodRessource") and !hasFood:
			handleFood(collider)
			if !hadFood:
				lastFood = collider
				hadFood = true
		elif collider.is_in_group("antHill") and hasFood:
			hasFood = false
			collider.foodNumber += 1
		turn()
	queue_redraw()

func _draw() -> void:
	if hasFood:
		draw_circle(Vector2(0, -5), 2.5, Color.GREEN, 10)
