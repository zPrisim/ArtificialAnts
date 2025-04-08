extends Area2D

@onready var sprite = $pheromoneSprite

enum types {HOME, FOOD}

var type 
var value : float

func _ready():
	if type == types.FOOD:
		value = 1.0
		sprite.self_modulate = Color(255,0,0)
	else:
		value = 0.5

func _process(_delta):
	if sprite.self_modulate.a <= 0.01:
		queue_free()
	sprite.self_modulate.a -= 0.001
