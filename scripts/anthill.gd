extends Area2D

@onready var antHillCollision = $antHillCollision

func _ready():
	antHillCollision.shape.radius = 25

func _draw():
	draw_circle(Vector2(get_parent().position.x,get_parent().position.y),antHillCollision.shape.radius,Color.BLUE,true)
