extends Node2D
class_name PheromoneMap

@onready var tex = load("res://assets/images/pheromone.png")
@onready var cleanup_timer = Timer.new()

var sizeX : int
var sizeY : int
var lifeTime : float = 5.0
var pheromoneSize : float
var baseOpacity : float = 1.0
var cells : Array[Cell]
var perceptionRadius = 6.0

var type : Settings.types


var halfSize
var perceptionRadiusReciprocal

func _ready() -> void:
	sizeX = ceil(1280 / perceptionRadius)
	sizeY = ceil(720 / perceptionRadius)
	cells = []
	cells.resize(sizeX * sizeY)
	halfSize = Vector2 (sizeX * perceptionRadius, sizeY * perceptionRadius) * 0.5
	perceptionRadiusReciprocal = 1/ perceptionRadius
	for i in range(cells.size()):
		cells[i] = Cell.new()
	
	cleanup_timer.one_shot = false  # Make it repeat
	cleanup_timer.connect("timeout",_on_cleanup_timer_timeout)
	add_child(cleanup_timer)
	cleanup_timer.start(1.0)

	addPheromones(Vector2(200,200))

func _on_cleanup_timer_timeout() -> void:
	var now = Time.get_ticks_msec() / 1000.0
	for cell in cells:
		cell.cleanup_pheromones(now)

func initParticle(pos : Vector2) -> CPUParticles2D:
	var pa = CPUParticles2D.new()
	pa.texture = tex

	pa.amount = 1
	pa.lifetime = lifeTime
	pa.one_shot = true
	pa.emitting = true
	
	pa.amount = 1
	pa.gravity = Vector2(0,0)
	if type == Settings.types.FOOD:
		pa.color = Color(1, 0, 0, 1)
	pa.position = pos
	add_child(pa)
	return pa

func addPheromones(pos : Vector2):
	var cellCoord = posToCell(pos)
	var p = Pheromone.new()
	p.pos = pos
	p.value = 10.0
	p.creationTime = Time.get_ticks_msec() / 1000.0
	cells[cellCoord.x + cellCoord.y * sizeX].pheromones.append(p)

func getPheromones(sensorCentre : Vector2) -> Array[Pheromone]:
	var cellCoord = posToCell(sensorCentre)
	var res: Array[Pheromone] = []
	var perceptionRadiusSquared = perceptionRadius * perceptionRadius
	for x in range(-1, 2):
		for y in range(-1, 2):
			var cellX = cellCoord.x + x
			var cellY = cellCoord.y + y
			if cellX >= 0 and cellX < sizeX and cellY >= 0 and cellY < sizeY:
				var cell = cells[cellX + cellY * sizeX]
				for phero in cell.pheromones:
					if (phero.pos - sensorCentre).length_squared() < perceptionRadiusSquared:
						res.append(phero)
	return res


func posToCell(pos : Vector2) -> Vector2i:
	var x = int((pos.x + halfSize.x) * perceptionRadiusReciprocal)
	var y = int((pos.y + halfSize.y) * perceptionRadiusReciprocal)
	return Vector2i(clamp(x, 0, sizeX - 1), clamp(y, 0, sizeY - 1))
	
func _draw() -> void:
	for c in cells:
		for p in c.pheromones:
			if type == Settings.types.FOOD:
				draw_rect(Rect2(p.pos,Vector2(2,2)),Color.RED,true)
			else:
				draw_rect(Rect2(p.pos,Vector2(2,2)),Color.BLUE,true)
	pass

func _physics_process(delta: float) -> void:
	queue_redraw()
# --- Classes internes propres ---

class Cell:
	var pheromones : Array[Pheromone]
	func _init():
		pheromones = []

	func cleanup_pheromones(now: float):
		for i in range(pheromones.size() - 1, -1, -1):
			if now - pheromones[i].creationTime > 10.0:  # 10 secondes de durée
				pheromones.remove_at(i)

class Pheromone:
	var pos : Vector2
	var value : float
	var creationTime : float
	func _init():
		pos = Vector2(0, 0)
		value = -1.0
		creationTime = 0.0
