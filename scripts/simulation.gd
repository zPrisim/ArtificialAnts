extends Node2D

@onready var ant = preload("res://scenes/ant.tscn")
@onready var food = preload("res://scenes/food.tscn")
@onready var pheromone = preload("res://scenes/pheromone.tscn")
@onready var antHill = $antHill

enum types {HOME, FOOD}


var WSX = DisplayServer.window_get_size().x
var WSY = DisplayServer.window_get_size().y

var pheromones = PackedVector2Array()
var foodPheromones = PackedVector2Array()
var ants : Array
var foods : Array

func _ready():
	init_grid()
	antHill.position = Vector2(640,360)
	var instFood = food.instantiate()
	instFood.radius = 25.0
	instFood.position = Vector2(500,500)
	add_child(instFood)
	foods.append(instFood)
	
	
	var instFood2 = food.instantiate()
	instFood2.radius = 50.0
	instFood2.position = Vector2(200,200)
	add_child(instFood2)
	foods.append(instFood2)
	
	
	for i in range (0,200):
		var instAnt = ant.instantiate()
		instAnt.id = i 
		instAnt.position = antHill.position
		add_child(instAnt)
		ants.append(instAnt)

	var p = pheromone.instantiate()
	p.global_position = pheromones[80/8.0 + 80/8.0 * WSY/8.0] # acces a la case 10 10
	p.type = types.FOOD 
	add_child(p)
	# Gerer quand plusieurs phéromones au même endroit : somme des valeur, modification de la couleur etc


func init_grid():
	pass
	for x in WSX/8.0: # 1280/8
		for y in WSY/8.0: # 720/8
			pheromones.append(Vector2(x*8,y*8))
	
func _draw():
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color.GRAY, true)
	
	
	#for i in (WSX/8)*(WSY/8):
	#	var p = pheromone.instantiate()
	#	if i % 3 == 0:
	#		p.modulate = Color(255, 0, 0) # modulate pour mettre en rouge
	#		p.type = types.HOME
	#	p.global_position = pheromones[i]
	#	add_child(p)
