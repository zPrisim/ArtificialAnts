extends Area2D

@onready var antHillCollision = $antHillCollision
var foodNumber := 0

func _ready():
	antHillCollision.shape.radius = 25
	monitoring = true

func _physics_process(_delta):
	var antTab = get_overlapping_bodies()
	if  antTab != []:
		for a in antTab:
			if a.hasFood:
				a.velocity = -a.velocity * 0.5  # on ralenti la vitesse
				a.desiredDirection = a.velocity 
				a.hasFood = false
				foodNumber+=1



func _draw():
	draw_circle(Vector2(0,0),antHillCollision.shape.radius,Color.BLUE,true)
	
