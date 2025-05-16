class_name Ant
extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")

@onready var rightSensor = $rightAntenna
@onready var centreSensor = $centre
@onready var leftSensor = $leftAntenna

@onready var leftRayCast = $leftRayCast 
@onready var rightRayCast = $rightRayCast
@onready var frontRayCast = $frontRayCast

@onready var animatedAntSprite = %antSprite

@onready var closePheromone = $closePheromone
@onready var vision = $antVision

@onready var id: int

var pathStartPosition: Vector2

enum STATE{SEARCHING,RETURNING}
var currentState : STATE


var maxSpeed = 80.0
var steerStrength = 100.0 # force changement de direction : augmente grandement la vitesse aussi
var wanderStrength = 0.2 # force de l'aléatoire
var desiredDirection: Vector2
var desiredVelocity : Vector2
var desiredSteeringForce 
var acceleration : Vector2

var anthill: Node2D
var pheromoneSpawnTimeDelay = 0.3
var pheromoneSpawnTimer: Timer
var lastPheromone : Pheromone

var hasFood: bool
var hadFood: bool
var lastFood : Food

const TIME_TO_UPDATE = 0.05
var updateTimer : Timer

var lifeTime = Settings.antLifeTime
var lifeTimer : Timer


var distMax = 1000

var sensor_direction : Vector2 = Vector2(0,0)

func _ready():
	add_to_group("ant")
	animatedAntSprite.play("movement")
	currentState = STATE.SEARCHING
	lifeTimer = Timer.new()
	updateTimer = Timer.new()
	pheromoneSpawnTimer = Timer.new()

	lifeTimer.connect("timeout", _on_timer_life)
	updateTimer.connect("timeout", _on_timer_update)
	pheromoneSpawnTimer.connect("timeout", _onTimerPheromoneSpawnTime)

	hasFood = false
	add_child(lifeTimer)
	add_child(pheromoneSpawnTimer)
	add_child(updateTimer)
	lifeTimer.start(lifeTime)
	pheromoneSpawnTimer.start(pheromoneSpawnTimeDelay)
	updateTimer.start(TIME_TO_UPDATE)

func _on_timer_life():
	get_parent().toBeDeadAnts.append(self)

func _on_timer_update():
	if !hasFood:
		sensor_direction = handlePheromoneSensors(Settings.types.FOOD)
	else:
		sensor_direction = handlePheromoneSensors(Settings.types.HOME)

func _onTimerPheromoneSpawnTime():
	var distance
	var normalized_distance 
	
	var existingPheromone : Pheromone = null
	if currentState == STATE.SEARCHING:
		closePheromone.set_collision_mask_value(5, false)
		closePheromone.set_collision_mask_value(6, true)
	elif currentState == STATE.RETURNING:
		closePheromone.set_collision_mask_value(6, false)
		closePheromone.set_collision_mask_value(5, true)		
	
	var pheromones = closePheromone.get_overlapping_areas()
	for ph in pheromones:
		var dist = global_position.distance_to(ph.global_position)
		var minDistToPlace : int = 4
		var maxDistToPlace : int = 8
				
		
		if dist <= randi() % maxDistToPlace + minDistToPlace: 
			existingPheromone = ph
			break

	distance = pathStartPosition.distance_to(global_position)
	normalized_distance = clamp(distance / distMax, 0.0, 1.0)
	if existingPheromone:
		if hasFood:
			existingPheromone.value += Settings.pheromoneBaseValue * (1.0 - normalized_distance)
		else:
			existingPheromone.value += Settings.pheromoneBaseValue * (1.0 - normalized_distance)

		if lastPheromone != null:
			existingPheromone.lastPheromonePos = lastPheromone.global_position
		lastPheromone = existingPheromone


	else:
		var p  : Pheromone = pheromone.instantiate()
		if hasFood:
			p.type = Settings.types.FOOD
			p.value = Settings.pheromoneBaseValue* (1.0 - normalized_distance)
		else:
			p.type = Settings.types.HOME
			p.value = Settings.pheromoneBaseValue * (1.0 - normalized_distance)

		p.id = id
		if lastPheromone == null:
			p.lastPheromonePos = anthill.global_position
		else:
			p.lastPheromonePos = lastPheromone.global_position
		lastPheromone = p
		get_parent().pheromones.append(p)
		get_parent().add_child(p)
		p.global_position = global_position



func avoidObstacles() -> Vector2:
	var avoidForce = Vector2.ZERO

	if leftRayCast.is_colliding() and !rightRayCast.is_colliding():
		avoidForce += transform.x * 0.1
	elif rightRayCast.is_colliding() and !leftRayCast.is_colliding():
		avoidForce -= transform.x * 0.1
	elif rightRayCast.is_colliding() and leftRayCast.is_colliding():
		avoidForce -= transform.y * 0.1

	return avoidForce

func alignParallelToFrontWall():
	if frontRayCast.is_colliding():
		var normal = frontRayCast.get_collision_normal()
		# calcul d' un vecteur parallèle à l'obstacle
		var parallelDirection = normal.rotated(PI / 2)  # ratation à 90° pour obtenir une direction parallèle
		velocity = (parallelDirection * maxSpeed).limit_length(maxSpeed) 
		rotation = get_angle_to(parallelDirection) 



	
func move(delta : float):
	alignParallelToFrontWall()
	var randomAngle = randf() * TAU
	var randomRadius = sqrt(randf())
	var randomPoint = Vector2(randomRadius * cos(randomAngle), randomRadius * sin(randomAngle))

	var avoidance = avoidObstacles()
	
	if currentState == STATE.SEARCHING && lastFood == null:
		desiredDirection =  (desiredDirection + sensor_direction + avoidance + (randomPoint * wanderStrength)).normalized()
	elif currentState == STATE.SEARCHING && lastFood != null:
		desiredDirection =  (desiredDirection + sensor_direction *5+ avoidance + (randomPoint * 0.05)).normalized()
	elif currentState == STATE.RETURNING:
		desiredDirection =  (desiredDirection + sensor_direction *5+ avoidance + (randomPoint * 0.05)).normalized()

	desiredVelocity = desiredDirection * maxSpeed
	desiredSteeringForce = (desiredVelocity - velocity) * steerStrength
	acceleration = desiredSteeringForce.limit_length(steerStrength)
	velocity = (velocity + acceleration * delta).limit_length(maxSpeed)
	rotation = atan2(velocity.y, velocity.x) + PI / 2



func sumArray(a : Array):
	return a.filter(func(p): return p.type == Settings.types.FOOD).reduce(func(acc, p): return acc + p.value, 0.0)


func handlePheromoneSensors( t : Settings.types) -> Vector2:
	updateSensorCollisionMasks(t)	

	var leftPheromones = leftSensor.sensor()
	var centrePheromones = centreSensor.sensor()
	var rightPheromones = rightSensor.sensor()
	var allPheromones = leftPheromones + rightPheromones + centrePheromones

	if currentState == STATE.SEARCHING:
		set_collision_mask_value(3, true)
		set_collision_mask_value(2, false)
		var dir : Vector2 = Vector2(0,0)
		var visibleObj = vision.sensor("foodRessource") 
		if visibleObj != null:
			return (visibleObj.global_position  - global_position).normalized()
		if lastFood != null:
			dir += isNear(allPheromones,lastFood)
		
		hadFood = false
		var sumLeft = sumArray(leftPheromones)
		var sumCentre = sumArray(centrePheromones)
		var sumRight = sumArray(rightPheromones)
		if sumCentre > max(sumLeft,sumRight):
			return (centreSensor.global_position - global_position).normalized() + dir
		elif sumLeft > sumRight:
			return (leftSensor.global_position - global_position).normalized() + dir
		elif sumRight > sumLeft:
			return (rightSensor.global_position - global_position).normalized() + dir
	elif currentState == STATE.RETURNING:
		set_collision_mask_value(3, false)
		set_collision_mask_value(2, true)

		var visibleObj = vision.sensor("antHill") 
		if visibleObj != null:
			return (visibleObj.global_position  - global_position).normalized()
		return isNear(allPheromones,anthill)
	return Vector2(0,0)

func updateSensorCollisionMasks(t: Settings.types):
	leftSensor.set_collision_mask_value(5, t)
	leftSensor.set_collision_mask_value(6, !t)
	centreSensor.set_collision_mask_value(5, t)
	centreSensor.set_collision_mask_value(6, !t)
	rightSensor.set_collision_mask_value(5, t)
	rightSensor.set_collision_mask_value(6, !t)

func isNear(pA : Array, n : Node2D) -> Vector2:
	var minDist = 5000
	var tmpPheromone : Pheromone = null
	var dist
	for p in pA:
		dist = p.global_position.distance_to(n.global_position)
		if dist < minDist:
			minDist = dist
			tmpPheromone = p
	if tmpPheromone != null:
		return (tmpPheromone.lastPheromonePos - global_position).normalized()
	return Vector2.ZERO


func handleFood(food : Food):
	if(food.foodValue > 0):
		currentState = STATE.RETURNING
		food.foodValue -= 1
		lastFood = food
		hasFood = true
		pathStartPosition = global_position  # Démarrage du trajet de retour
	else:
		get_parent().foods.erase(food)
		get_parent().remove_child(food)
		food.queue_free()
		hadFood = false



func handleAnthill(hill : Node2D):
	hasFood = false
	currentState = STATE.SEARCHING
	hill.foodNumber += 1
	pathStartPosition = global_position  # Démarrage du trajet vers nourriture


func TurnAround() -> void: # A modifier, les fourmis se bloquent
	# Inverse la direction avec une force marquée
	desiredDirection = -desiredDirection.normalized()
	velocity = desiredDirection * maxSpeed * 0.5  # redémarre à moitié de la vitesse max


func _physics_process(delta: float) -> void:
	move(delta)
	
	if  move_and_slide():
		var collider = get_last_slide_collision().get_collider()
		if collider.is_in_group("foodRessource") and !hasFood:
			handleFood(collider)
			TurnAround()
		elif collider.is_in_group("antHill") and hasFood:
			handleAnthill(collider)
			TurnAround()
		queue_redraw()


func _draw() -> void:
	if currentState == STATE.SEARCHING and lastFood == null:
		animatedAntSprite.modulate = Color("black")
	elif currentState == STATE.RETURNING:
		animatedAntSprite.modulate = Color("green")
		draw_circle(Vector2(0, -5), 2.5, Color.GREEN, 0.1)
	elif currentState == STATE.SEARCHING and lastFood != null:
		animatedAntSprite.modulate = Color("yellow")

	# debug
"""
	var left_to = leftRayCast.target_position
	draw_line(leftRayCast.position, leftRayCast.position + left_to.rotated(leftRayCast.rotation), Color.RED, 1)

	var right_to = rightRayCast.target_position
	draw_line(rightRayCast.position, rightRayCast.position + right_to.rotated(rightRayCast.rotation), Color.RED, 1)

	var front_to = frontRayCast.target_position
	draw_line(frontRayCast.position, frontRayCast.position + front_to.rotated(frontRayCast.rotation), Color.YELLOW, 1)

	draw_circle(leftSensor.position, 4, Color.VIOLET)
	draw_circle(centreSensor.position, 4, Color.VIOLET)
	draw_circle(rightSensor.position, 4, Color.VIOLET)
"""	
