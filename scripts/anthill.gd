extends StaticBody2D

@onready var antHillCollision = $antHillCollision
var foodNumber := 0

func _ready():
	add_to_group("antHill")
	antHillCollision.shape.radius = 25


func _draw():
	draw_circle(Vector2(0,0),antHillCollision.shape.radius,Color.BLUE,true)
	
