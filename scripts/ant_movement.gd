extends CharacterBody2D

@onready var collision_raycast = $RayCastCollision
@onready var left_raycast = $RayCastPosLeft
@onready var face_raycast = $RayCastPosFront
@onready var right_raycast = $RayCastPosRight
@export var id : int
var hasFood : bool

func _ready():
	motion_mode = MOTION_MODE_FLOATING; # mieux pour la vue du dessus (à vérifier)
	hasFood = false

func _physics_process(_delta):
	var rng = RandomNumberGenerator.new()
	move_and_collide(Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(-10.0, 10.0)))

	#var collision = move_and_collide(velocity * delta)
	#if(collision_raycast.is_colliding()):
	#	print(str(collision_raycast.is_colliding()) + str(id))
	#if collision:
	#	velocity = velocity.bounce(collision.get_normal())
