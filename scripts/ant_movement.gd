extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")

@onready var rightSensor = $rightAntenna
@onready var centreSensor = $centre
@onready var leftSensor = $leftAntenna


@export var id: int

enum types {HOME, FOOD}

var maxSpeed = 80.0
var steerStrength = 20.0 # force changement de direction : augmente grandement la vitesse aussi
var wanderStrength = 0.1 # force de l'aléatoire
var desiredDirection: Vector2



var pheromoneSpawnTimeDelay = 0.2
var pheromoneSpawnTimer: Timer
var hasFood: bool

func _ready():
	hasFood = false
	pheromoneSpawnTimer = Timer.new()
	pheromoneSpawnTimer.connect("timeout", _onTimerPheromoneSpawnTime)
	add_child(pheromoneSpawnTimer)
	
	pheromoneSpawnTimer.start(pheromoneSpawnTimeDelay)
	
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
	if t == types.FOOD :
		desiredDirection = (desiredDirection + handlePheromoneSensors(t) + (randomPoint * wanderStrength)).normalized()
	else:
		desiredDirection = (desiredDirection + handlePheromoneSensors(t) + (randomPoint * wanderStrength)/10).normalized()

	var desiredVelocity = desiredDirection * maxSpeed

	var desiredSteeringForce = (desiredVelocity - velocity) * steerStrength
	var acceleration = desiredSteeringForce.limit_length(steerStrength)
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
		
		
	if t == types.FOOD:
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
		var allPheromones = leftPheromones + rightPheromones + centrePheromones
		var selfPheromoneId = allPheromones.find_custom(is_self.bind())
		if selfPheromoneId != -1:
			return (allPheromones[selfPheromoneId].global_position - global_position).normalized()
	return Vector2(0,0)

func handleFood(f):
	f.foodValue -= f.foodRatio/10
	f.foodCollision.shape.radius -= f.foodRatio / f.foodRatio /10
	hasFood = true

func is_self(p):
	if p.id == id:
		return true
	return false

func _physics_process(delta):
	if !hasFood:
		move(delta, types.FOOD)
		if move_and_slide() :
			var collider = get_last_slide_collision().get_collider()
			if collider.is_in_group("foodRessource"):
				handleFood(collider)
			TurnAround()
	elif hasFood:
		move(delta, types.HOME)
		if move_and_slide() :
			var collider = get_last_slide_collision().get_collider()
			if collider.is_in_group("antHill"):
				hasFood = false
				collider.foodNumber+=1
			TurnAround()


func _draw() -> void:
	draw_circle(Vector2(0,0),$CollisionShape2D.shape.radius,Color.DARK_BLUE,0)

	# implémenter le cas ou la fourmis à de la nourriture : retour a la fourmillière
