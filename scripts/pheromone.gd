class_name Pheromone
extends Area2D

@onready var sprite = $pheromoneSprite


var id
var type : Settings.types
var value : float = Settings.pheromoneBaseValue


var baseOpacity := 1.0

var deathTimer := Timer.new()
var lifeTimer := Timer.new()

var lifeTime := Settings.pheromoneLifeTime

var lastPheromonePos := Vector2(0,0)

func _ready():
	visible = Settings.pheromoneVisible
	add_to_group("pheromone")
	if type == Settings.types.FOOD:
		sprite.self_modulate = Color(255,0,0)
	else:
		sprite.self_modulate = Color(0,0,255)

	if type == Settings.types.FOOD:
		set_collision_layer_value(5,true)
	else:
		set_collision_layer_value(6,true)


	_setup_timers()
	
	lifeTimer.start()
	deathTimer.start(lifeTime)
	sprite.self_modulate.a = baseOpacity


func _setup_timers():
	deathTimer.one_shot = true
	lifeTimer.wait_time = lifeTime / 4

	deathTimer.connect("timeout", _on_timer_deathTime)
	lifeTimer.connect("timeout", _on_timer_lifeTime)

	add_child(lifeTimer)
	add_child(deathTimer)

func _on_timer_lifeTime():
	sprite.self_modulate.a -= 0.25
	value -= (lifeTime/10)
	
func reset_timer():
	if not is_inside_tree():
		await ready
	if lifeTimer and deathTimer:
		sprite.self_modulate.a = baseOpacity
		lifeTimer.start()
		deathTimer.start(lifeTime)

	
func _on_timer_deathTime():
	get_parent().pheromones.erase(self)
	get_parent().remove_child(self)
	queue_free()

"func _draw() -> void:
	var from = Vector2.ZERO
	var to = to_local(lastPheromonePos)
	draw_line(from, to, Color.INDIGO, 1)"
