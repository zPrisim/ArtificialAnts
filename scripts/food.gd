extends StaticBody2D
@onready var foodCollision = $foodCollision

var radius : float
var foodValue : int


func _ready():
	add_to_group("foodRessource")
	foodCollision.shape = foodCollision.shape.duplicate()
	foodCollision.shape.radius = radius -3

func _draw():
	draw_circle(Vector2(0,0),foodCollision.shape.radius + 3,Color.GREEN,true)
