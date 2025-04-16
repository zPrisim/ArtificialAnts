extends Area2D

@onready var sprite = $pheromoneSprite

enum types {HOME, FOOD}

var id
var type : types
var value : float
var valueDecrement

var deathTimer : Timer
var lifeTimer : Timer

var lifeTime = 15.0

func _ready():
	if type == types.FOOD:
		value = 20.0
		sprite.self_modulate = Color(255,0,0)
	else:
		value = 10.0
		sprite.self_modulate = Color(0,0,255)

	lifeTimer = Timer.new()
	deathTimer = Timer.new()
	deathTimer.one_shot = true;
	
	lifeTimer.connect("timeout", _on_timer_lifeTime, 0)
	deathTimer.connect("timeout", _on_timer_deathTime, 4)

	add_child(lifeTimer)
	add_child(deathTimer)
	
	lifeTimer.start(lifeTime/10)
	deathTimer.start(lifeTime)

func _on_timer_lifeTime():
	sprite.self_modulate.a -= 0.1
	value -= (lifeTime/10)
	
func _on_timer_deathTime():
	get_parent().remove_child(self)
	queue_free()
