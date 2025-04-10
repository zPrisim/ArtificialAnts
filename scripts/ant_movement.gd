extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")

@onready var rightSensor = $rightAntenna
@onready var centreSensor = $centre
@onready var leftSensor = $leftAntenna


@export var id: int

enum types {HOME, FOOD}

var maxSpeed = 100.0
var steerStrength = 5.0 # force changement de direction : augmente grandement la vitesse aussi
var wanderStrength = 0.05 # force de l'aléatoire
var desiredDirection: Vector2

var target
var lastTarget


var pheromoneSpawnTimeDelay = 0.2
var pheromoneSpawnTimer: Timer
var hasFood: bool

func _ready():
	motion_mode = MOTION_MODE_FLOATING # mieux pour la vue du dessus (à vérifier)
	hasFood = false
	target = null
	lastTarget = global_position

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
	p.global_position = global_position
	get_parent().add_child(p)

func move():
	# random point
	var randomAngle = randf() * TAU # TAU = 2*PI 
	var randomRadius = sqrt(randf())  # Distribution uniforme dans le cercle
	var randomPoint = Vector2(randomRadius * cos(randomAngle), randomRadius * sin(randomAngle)) 

	# choix direction
	desiredDirection = (desiredDirection + randomPoint * wanderStrength).normalized()
	
	var desiredVelocity = desiredDirection * maxSpeed

	var desiredSteeringForce = (desiredVelocity - velocity) * steerStrength
	var acceleration = desiredSteeringForce.limit_length(steerStrength)
	velocity = (velocity + acceleration).limit_length(maxSpeed)
	var angle = atan2(velocity.y, velocity.x) 
	rotation = angle

	$antSprite.rotation = PI/2




func handlePheromoneSensors() -> Vector2:
	var leftValue = leftSensor.pheromoneSensor()
	var centreValue = centreSensor.pheromoneSensor()
	var rightValue = rightSensor.pheromoneSensor()
		
	if centreValue > max(leftValue,rightValue):
		return (centreSensor.global_position - global_position).normalized()
	elif leftValue > rightValue:
		return (leftSensor.global_position - global_position).normalized()
	elif rightValue > leftValue:
		return (rightSensor.global_position - global_position).normalized()
	return Vector2(0,0)

func _physics_process(_delta):
	move()
	
	var isCollision = move_and_slide()


	if isCollision :
		velocity = -velocity * 0.5  # on ralenti la vitesse
		desiredDirection = velocity 
	# implémenter le cas ou la fourmis à de la nourriture : retour a la fourmillière
