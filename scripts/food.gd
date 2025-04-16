extends StaticBody2D
@onready var foodCollision = $foodCollision

var radius : float
var foodValue : float
var foodRatio : float = 10


func _ready():
	add_to_group("foodRessource")
	foodCollision.shape = foodCollision.shape.duplicate()
	foodCollision.shape.radius = radius
	foodValue = radius * foodRatio

func _physics_process(_delta):
	if foodValue < 0:
		queue_free()
	queue_redraw()

func _draw():
	draw_circle(Vector2(0,0),foodCollision.shape.radius,Color.GREEN,true)
