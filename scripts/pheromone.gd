extends Area2D

@onready var sprite = $pheromoneSprite

enum types {HOME, FOOD}

var type 
var value : float
var deathTimer : Timer
var lifeTimer : Timer

var lifeTime = 10.0

func _ready():
	if type == types.FOOD:
		value = 1.0
		sprite.self_modulate = Color(255,0,0)
	else:
		value = 0.5
	
	lifeTimer = Timer.new()
	deathTimer = Timer.new()
	deathTimer.one_shot = true;
	
	lifeTimer.connect("timeout", _on_timer_lifeTime, 0)
	deathTimer.connect("timeout", _on_timer_deathTime, 4)

	add_child(lifeTimer)
	add_child(deathTimer)
	
	lifeTimer.start(lifeTime/100)
	deathTimer.start(lifeTime)

func _on_timer_lifeTime():
	sprite.self_modulate.a -= 0.01
	
func _on_timer_deathTime():
	queue_free()
