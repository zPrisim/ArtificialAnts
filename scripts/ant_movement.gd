extends CharacterBody2D

@onready var collision_raycast = $RayCastCollision
@onready var left_raycast = $RayCastPosLeft
@onready var face_raycast = $RayCastPosFront
@onready var right_raycast = $RayCastPosRight

func _ready():
	velocity = Vector2(100, 100)
func _process(_delta): 
	if(collision_raycast.is_colliding()):
		print(collision_raycast.is_colliding())
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())

	
