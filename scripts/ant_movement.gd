extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var leftRaycast = $RayCastPosLeft
@onready var faceRaycast = $RayCastPosFront
@onready var rightRaycast = $RayCastPosRight
@export var id: int

var maxSpeed = 100000.0
var steerStrength = 50.0 # force changement de direction
var wanderStrength = 0.3 # force de l'aléatoire
var desiredDirection: Vector2


enum types {HOME, FOOD}
var pheromoneSpawnTimeDelay = 0.3
var pheromoneSpawnTimer: Timer
var hasFood: bool

func _ready():
	motion_mode = MOTION_MODE_FLOATING # mieux pour la vue du dessus (à vérifier)
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
	p.global_position = global_position
	get_parent().add_child(p)

func search(delta):
	var randomAngle = randf() * TAU # TAU = 2*PI 
	var randomRadius = sqrt(randf())  # Distribution uniforme dans le cercle
	var randomPoint = Vector2(randomRadius * cos(randomAngle), randomRadius * sin(randomAngle))
	desiredDirection = (desiredDirection + randomPoint * wanderStrength).normalized()
	var desiredVelocity = desiredDirection * maxSpeed

	var desiredSteeringForce = (desiredVelocity - velocity) * steerStrength

	var acceleration = desiredSteeringForce.limit_length(steerStrength)
	velocity = (velocity + acceleration * delta).limit_length(maxSpeed)
	var angle = atan2(velocity.y, velocity.x) 
	rotation = angle

	$antSprite.rotation = PI/2
		
func _physics_process(delta):
		search(delta) # méthode à complémenter : prise en compte des phéromones
		if move_and_slide():
			var collision = move_and_slide()
			if collision: # rebond temporaire : a changer
				velocity = -velocity * 0.5  # on ralenti la vitesse
				desiredDirection = velocity 
	# implémenter le cas ou la fourmis à de la nourriture : retour a la fourmillière
