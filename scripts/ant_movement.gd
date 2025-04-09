extends CharacterBody2D

@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var leftRaycast = $RayCastPosLeft
@onready var faceRaycast = $RayCastPosFront
@onready var rightRaycast = $RayCastPosRight
@export var id: int

var maxSpeed = 50.0
var steerStrength = 50.0 # force changement de direction
var wanderStrength = 0.3 # force de l'aléatoire
var desiredDirection: Vector2
var WSX = DisplayServer.window_get_size().x
var WSY = DisplayServer.window_get_size().y

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
	if !hasFood:
		search(delta)
		if move_and_slide():
			var collision = move_and_slide()
			if collision:
				# Inverse la direction pour rebondir
				velocity = -velocity * 0.5  # on ralenti la vitesse
				desiredDirection = velocity 
	else:
		pass
