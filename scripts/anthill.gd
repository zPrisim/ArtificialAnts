class_name Anthill
extends StaticBody2D

@onready var antHillCollision = $antHillCollision
var foodNumber := 0

func _ready():
	add_to_group("antHill")
	antHillCollision.shape.radius = 22

func _draw():
	draw_circle(Vector2(0,0),antHillCollision.shape.radius + 3,Color.BLUE,true)
	
