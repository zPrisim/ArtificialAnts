extends Area2D
@onready var foodCollision = $foodCollision

var radius : float
var foodValue : float
var foodRatio : float = 10


func _ready():
	monitoring = true
	foodCollision.shape.radius = radius
	foodValue = radius * foodRatio


func _physics_process(_delta):
	if foodValue < 1:
		queue_free()
	
	var antTab = get_overlapping_bodies()
	if  antTab != []:
		for a in antTab:

			if !a.hasFood:
				foodValue -= foodRatio/10
				foodCollision.shape.radius -= foodRatio / foodRatio /10
				a.hasFood = true

				queue_redraw()
				

func _draw():
	draw_circle(Vector2(0,0),foodCollision.shape.radius,Color.GREEN,true)
