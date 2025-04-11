extends Area2D

@onready var sprite = $pheromoneSprite

enum types {HOME, FOOD}

var id
var type : types
var value : float


var deathTimer : Timer
var lifeTimer : Timer

var lifeTime = 40.0

func _ready():
	if type == types.FOOD:
		value = 10.0
		sprite.self_modulate = Color(255,0,0)
	else:
		value = 5.0
		sprite.self_modulate = Color(0,0,255)

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
	value -= (lifeTime/100)
	
func _on_timer_deathTime():
	queue_free()
