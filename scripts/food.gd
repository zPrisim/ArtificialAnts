extends Area2D
@onready var foodCollision = $foodCollision

var radius : float
var foodValue : float
var foodRatio : float = 100

func _ready():
	monitoring = true
	foodCollision.shape.radius = radius
	foodValue = radius * foodRatio


func _physics_process(_delta):
	if foodValue < 1:
		queue_free()
	if get_overlapping_bodies() != []:
		foodValue -= foodRatio/10
		foodCollision.shape.radius -= foodRatio / foodRatio /10
		queue_redraw() 


func _draw():
	draw_circle(Vector2(0,0),foodCollision.shape.radius,Color.GREEN,true)
