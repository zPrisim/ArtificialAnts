extends Area2D
@onready var foodCollision = $foodCollision

var radius : float
var pos : Vector2

func _ready():
	monitoring = true
	foodCollision.shape.radius = radius
	position = pos


func _physics_process(_delta):
	if foodCollision.shape.radius < 1:
		queue_free()
	if get_overlapping_bodies() != []:
		foodCollision.shape.radius -= 0.1
		queue_redraw() 


func _draw():
	draw_circle(Vector2(get_parent().position.x,get_parent().position.y),foodCollision.shape.radius,Color.GREEN,true)
