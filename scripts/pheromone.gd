extends Area2D

@onready var sprite = $pheromoneSprite


var id
var type : Settings.types
var value : float

const homeValue = 10.0
const foodValue = 20.0

var baseOpacity = 1.0

var deathTimer : Timer
var lifeTimer : Timer

var lifeTime = Settings.pheromoneLifTime

func _ready():
	add_to_group("pheromone")
	if type == Settings.types.FOOD:
		value = foodValue
		sprite.self_modulate = Color(255,0,0)
	else:
		value = homeValue
		sprite.self_modulate = Color(0,0,255)

	if type == Settings.types.FOOD:
		set_collision_layer_value(5,true)
	else:
		set_collision_layer_value(6,true)


	lifeTimer = Timer.new()
	deathTimer = Timer.new()
	deathTimer.one_shot = true;
	
	lifeTimer.connect("timeout", _on_timer_lifeTime, 0)
	deathTimer.connect("timeout", _on_timer_deathTime, 4)

	add_child(lifeTimer)
	add_child(deathTimer)
	
	lifeTimer.start(lifeTime/4)
	deathTimer.start(lifeTime)
	sprite.self_modulate.a = baseOpacity

func _on_timer_lifeTime():
	sprite.self_modulate.a -= 0.25
	value -= (lifeTime/10)
	
	
func reset_timer():
	if deathTimer.is_inside_tree():
		deathTimer.start()

	
func _on_timer_deathTime():
	if is_inside_tree():
		if self in get_parent().pheromones:
			get_parent().pheromones.erase(self)
		get_parent().remove_child(self)
		queue_free()
