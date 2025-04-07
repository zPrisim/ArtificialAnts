extends Area2D

@onready var antHillCollision = $antHillCollision

func _ready():
	antHillCollision.shape.radius = 25
	monitoring = true

func _draw():
	draw_circle(Vector2(0,0),antHillCollision.shape.radius,Color.BLUE,true)
