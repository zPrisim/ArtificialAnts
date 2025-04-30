extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")

@onready var rightSensor = $rightAntenna
@onready var centreSensor = $centre
@onready var leftSensor = $leftAntenna


@onready var closePheromone = $closePheromone
@onready var vision = $antVision

@export var id: int


enum STATE{SEARCHING,RETURNING}
var currentState : STATE


var maxSpeed = 80.0
var steerStrength = 100.0 # force changement de direction : augmente grandement la vitesse aussi
var wanderStrength = 0.2 # force de l'aléatoire
var desiredDirection: Vector2
var desiredVelocity
var desiredSteeringForce
var acceleration

var anthill: Node2D
var pheromoneSpawnTimeDelay = 0.3
var pheromoneSpawnTimer: Timer
var hasFood: bool
var hadFood: bool
var lastFood : Node2D

const TIME_TO_UPDATE = 0.10
var updateTimer : Timer

var distMax = 1000

var sensor_direction : Vector2 = Vector2(0,0)


func _ready():
	add_to_group("ant")
	currentState = STATE.SEARCHING
	updateTimer = Timer.new()
	
	updateTimer.connect("timeout", _on_timer_update)
	
	hasFood = false
	pheromoneSpawnTimer = Timer.new()
	pheromoneSpawnTimer.connect("timeout", _onTimerPheromoneSpawnTime)
	add_child(pheromoneSpawnTimer)
	add_child(updateTimer)
	pheromoneSpawnTimer.start(pheromoneSpawnTimeDelay)
	updateTimer.start(TIME_TO_UPDATE)
	
	

func _on_timer_update():
	if !hasFood:
		sensor_direction = handlePheromoneSensors(Settings.types.FOOD)
	else:
		sensor_direction = handlePheromoneSensors(Settings.types.HOME)

func _onTimerPheromoneSpawnTime():
	var distance
	var normalized_distance 
	
	var p = pheromone.instantiate()
	
	var existingPheromone = null
	if currentState == STATE.SEARCHING:
		closePheromone.set_collision_mask_value(5, false)
		closePheromone.set_collision_mask_value(6, true)
	elif currentState == STATE.RETURNING:
		closePheromone.set_collision_mask_value(6, false)
		closePheromone.set_collision_mask_value(5, true)		
	
	var pheromones = closePheromone.get_overlapping_areas()
	for ph in pheromones:
		var dist = global_position.distance_to(ph.global_position)
		if dist <= randi() % 4 + 2: 
			existingPheromone = ph
			break
	
	if existingPheromone:
		if hasFood:
			if lastFood != null:
				distance = global_position.distance_to(lastFood.global_position)
			else:
				distance = 0			
			normalized_distance = distance / distMax
			existingPheromone.value += existingPheromone.foodValue * (1.0 - normalized_distance)
		else:
			distance = global_position.distance_to(anthill.global_position)
			normalized_distance = distance / distMax
			existingPheromone.value += existingPheromone.homeValue * (1.0 - normalized_distance)

		existingPheromone.reset_timer()  

	else:
		if hasFood:
			if lastFood != null:
				distance = global_position.distance_to(lastFood.global_position)
			else:
				distance = 0			
			normalized_distance = distance / distMax
			p.type = Settings.types.FOOD
			p.value = p.foodValue * (1.0 - normalized_distance)
		else:
			distance = global_position.distance_to(anthill.global_position)
			normalized_distance = distance / distMax
			p.type = Settings.types.HOME
			p.value = p.homeValue * (1.0 - normalized_distance)
		p.id = id
		get_parent().pheromones.append(p)
		get_parent().add_child(p)
		p.global_position = global_position
	
func move(delta : float):
	var randomAngle = randf() * TAU
	var randomRadius = sqrt(randf())
	var randomPoint = Vector2(randomRadius * cos(randomAngle), randomRadius * sin(randomAngle))
	
	
	
	if currentState == STATE.SEARCHING && lastFood == null:
		desiredDirection =  (desiredDirection + sensor_direction + (randomPoint * wanderStrength)).normalized()
	elif currentState == STATE.SEARCHING && lastFood != null:
		desiredDirection =  (desiredDirection + sensor_direction).normalized()
	elif currentState == STATE.RETURNING:
		desiredDirection =  (desiredDirection + sensor_direction).normalized()

	desiredVelocity = desiredDirection * maxSpeed
	desiredSteeringForce = (desiredVelocity - velocity) * steerStrength
	acceleration = desiredSteeringForce.limit_length(steerStrength)
	velocity = (velocity + acceleration * delta).limit_length(maxSpeed)
	rotation = atan2(velocity.y, velocity.x) + PI / 2



func TurnAround() -> void: # A modifier, les fourmis se bloquent
	velocity = -velocity * 0.2 # on ralenti la vitesse
	desiredDirection = velocity 
	 

func sumArray(a : Array):
	var sum = 0
	for i in a.size():
		if a[i].type == Settings.types.FOOD:
			sum += a[i].value
	return sum


func handlePheromoneSensors( t : Settings.types) -> Vector2:
	if t == Settings.types.FOOD:
		leftSensor.set_collision_mask_value(5, true)
		leftSensor.set_collision_mask_value(6, false)
		centreSensor.set_collision_mask_value(5, true)
		centreSensor.set_collision_mask_value(6, false)
		rightSensor.set_collision_mask_value(5, true)
		rightSensor.set_collision_mask_value(6, false)
	else:
		leftSensor.set_collision_mask_value(5, false)
		leftSensor.set_collision_mask_value(6, true)
		centreSensor.set_collision_mask_value(5, false)
		centreSensor.set_collision_mask_value(6, true)
		rightSensor.set_collision_mask_value(5, false)
		rightSensor.set_collision_mask_value(6, true)		


	var leftPheromones = leftSensor.sensor()
	var centrePheromones = centreSensor.sensor()
	var rightPheromones = rightSensor.sensor()
	var allPheromones = leftPheromones + rightPheromones + centrePheromones

	if currentState == STATE.SEARCHING:
		set_collision_mask_value(3, true)
		set_collision_mask_value(2, false)

		var v = vision.sensor("foodRessource") 
		if v != null:
			return (v.global_position  - global_position).normalized()

			#return (lastFood.global_position  - global_position).normalized()
		elif lastFood != null:
			return isNear(allPheromones, lastFood)
		hadFood = false
		var sumLeft = sumArray(leftPheromones)
		var sumCentre = sumArray(centrePheromones)
		var sumRight = sumArray(rightPheromones)
		if sumCentre > max(sumLeft,sumRight):
			return (centreSensor.global_position - global_position).normalized()
		elif sumLeft > sumRight:
			return (leftSensor.global_position - global_position).normalized()
		elif sumRight > sumLeft:
			return (rightSensor.global_position - global_position).normalized()
	elif currentState == STATE.RETURNING:
		set_collision_mask_value(3, false)
		set_collision_mask_value(2, true)

		var v = vision.sensor("antHill") 
		if v != null:
			return (v.global_position  - global_position).normalized()
		return isNear(allPheromones, anthill)
	return Vector2(0,0)

func handleFood(f):
	if(f.foodValue > 1):
		currentState = STATE.RETURNING
		f.foodValue -= 1
		hasFood = true
	else:
		f.queue_free()

func isNear(pA : Array, n : Node2D) -> Vector2:
	var minDist = 5000
	var minVec = Vector2.ZERO
	var dist
	for p in pA:
		dist = p.global_position.distance_to(n.global_position)
		if dist < minDist:
			minDist = dist
			minVec = p.global_position
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
				queue_redraw()
		elif collider.is_in_group("antHill") and hasFood:
			hasFood = false
			currentState = STATE.SEARCHING
			collider.foodNumber += 1
		TurnAround()
		queue_redraw()



func _draw() -> void:
	if hasFood:
		draw_circle(Vector2(0, -5), 2.5, Color.GREEN, 5)
"""
	draw_circle(rightSensor.position,$CollisionShape2D.shape.radius,Color.VIOLET,0)
	draw_circle(centreSensor.position,$CollisionShape2D.shape.radius,Color.VIOLET,0)
	draw_circle(leftSensor.position,$CollisionShape2D.shape.radius,Color.VIOLET,0)
"""	
