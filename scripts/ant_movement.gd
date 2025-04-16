extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")

@onready var rightSensor = $rightAntenna
@onready var centreSensor = $centre
@onready var leftSensor = $leftAntenna

@onready var vision = $antVision


@export var id: int

enum types {HOME, FOOD}

var maxSpeed = 80.0
var steerStrength = 100.0 # force changement de direction : augmente grandement la vitesse aussi
var wanderStrength = 0.1 # force de l'aléatoire
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

const TIME_TO_UPDATE = 0.005
var updateTimer : Timer


func _ready():
	#updateTimer = Timer.new()
	
	#updateTimer.connect("timeout", _on_timer_update)
	
	hadFood = false
	hasFood = false
	pheromoneSpawnTimer = Timer.new()
	pheromoneSpawnTimer.connect("timeout", _onTimerPheromoneSpawnTime)
	add_child(pheromoneSpawnTimer)
	#add_child(updateTimer)
	pheromoneSpawnTimer.start(pheromoneSpawnTimeDelay)
	#updateTimer.start(TIME_TO_UPDATE)
	
func _onTimerPheromoneSpawnTime():
	var p = pheromone.instantiate()
	if hasFood:
		p.type = types.FOOD
	else:
		p.type = types.HOME
	p.id = id
	get_parent().add_child(p)
	p.global_position = global_position 

func move(delta : float, t : types):
	# random point
	var randomAngle = randf() * TAU # TAU = 2*PI 
	var randomRadius = sqrt(randf())  # Distribution uniforme dans le cercle
	var randomPoint = Vector2(randomRadius * cos(randomAngle), randomRadius * sin(randomAngle)) 

	# choix direction
	if t == types.FOOD && lastFood == null: # si recherche de nourriture , sans déja voir trouvé de source
		desiredDirection = (desiredDirection + handlePheromoneSensors(t) + (randomPoint * wanderStrength)).normalized()
	elif t == types.FOOD && lastFood != null:# si recherche de nourriture , avec une source déja mémorisée
		desiredDirection = (desiredDirection + handlePheromoneSensors(t) + (randomPoint * wanderStrength/100)).normalized()
	elif t == types.HOME: # Si retour à la fourmillière avec de la nourriture
		desiredDirection = (desiredDirection + handlePheromoneSensors(t)+ (randomPoint * wanderStrength/100)).normalized()

	desiredVelocity = desiredDirection * maxSpeed
	desiredSteeringForce = (desiredVelocity - velocity) * steerStrength
	acceleration = desiredSteeringForce.limit_length(steerStrength)
	velocity = (velocity + acceleration* delta).limit_length(maxSpeed)
	rotation = atan2(velocity.y, velocity.x) + PI/2


func TurnAround() -> void: # A modifier, les fourmis se bloquent
	velocity = -velocity * 0.5  # on ralenti la vitesse
	desiredDirection = velocity 


func sumArray(a : Array):
	var sum = 0
	for i in a.size():
		if a[i].type == types.FOOD:
			sum += a[i].value
	return sum


func handlePheromoneSensors( t : types) -> Vector2:
	var leftPheromones = leftSensor.sensor()
	var centrePheromones = centreSensor.sensor()
	var rightPheromones = rightSensor.sensor()
	var allPheromones = leftPheromones + rightPheromones + centrePheromones

	if t == types.FOOD:
		var v = vision.sensor("foodRessource") 
		if v != null:
			return (v.global_position  - global_position).normalized()
		if lastFood != null:
			return isNear(allPheromones, lastFood)
			#return (lastFood.global_position  - global_position).normalized()
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
	elif t == types.HOME:
		var v = vision.sensor("antHill") 
		if v != null:
			return (v.global_position  - global_position).normalized()
		return isNear(allPheromones, anthill)
	return Vector2(0,0)

func handleFood(f):
	if(f.foodCollision.shape.radius > 1):
		f.foodValue -= f.foodRatio/10
		f.foodCollision.shape.radius -= f.foodRatio / f.foodRatio /10
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

func _physics_process(delta: float) -> void: #(delta = get_physics_process_delta_time()):
	if !hasFood:
		move(delta, types.FOOD)
		if move_and_slide() :
			var collider = get_last_slide_collision().get_collider()
			if collider.is_in_group("foodRessource"):
				handleFood(collider)
				if !hadFood:
					lastFood = collider
					hadFood = true
			TurnAround()
	elif hasFood:
		move(delta, types.HOME)
		if move_and_slide() :
			var collider = get_last_slide_collision().get_collider()
			if collider.is_in_group("antHill"):
				hasFood = false
				collider.foodNumber+=1
			elif !collider.is_in_group("foodRessource"):
				TurnAround()

"""
func _draw() -> void:

	draw_circle(Vector2(0,0),$CollisionShape2D.shape.radius,Color.DARK_BLUE,0)

	draw_circle(rightSensor.position,$CollisionShape2D.shape.radius,Color.VIOLET,0)
	draw_circle(centreSensor.position,$CollisionShape2D.shape.radius,Color.VIOLET,0)
	draw_circle(leftSensor.position,$CollisionShape2D.shape.radius,Color.VIOLET,0)
"""	
