extends TileMapLayer

var fnl := FastNoiseLite.new()

func _ready() -> void:
	randomize()
	fnl.seed = randi()
	fnl.frequency = 0.02
	fnl.noise_type =FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 1
	fnl.domain_warp_type = FastNoiseLite.DOMAIN_WARP_BASIC_GRID
	fnl.domain_warp_amplitude = 50.0
	fnl.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT
	fnl.domain_warp_fractal_lacunarity = 1
	
	generateMap()
	
func generateMap():
	var center = Vector2(160, 90)
	var radius = 20

	for x in 320:
		for y in 180:
			var pos = Vector2(x, y)
			var noiseVal = fnl.get_noise_2d(x, y)
			
			# Forme aléatoire centrée basée sur la distance 
			var shapeNoise = fnl.get_noise_2d(x , y)
			var dist = pos.distance_to(center) / radius

			if dist + shapeNoise < 1.0:
				# Zone pour la fourmillière 
				set_cell(Vector2i(x, y), 0, Vector2i(4, 0))
			else:
				# Reste de la map 
				if noiseVal > 0.1:
					set_cell(Vector2i(x, y), 0, Vector2i(0, 0)) # murs
				else:
					set_cell(Vector2i(x, y), 0, Vector2i(4, 0))



var right_click_held := false
var lastType : Vector2i = Vector2i(0,0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_map"):
		get_tree().reload_current_scene()

	elif event is InputEventMouseButton and event.position.x < 1280 :
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_click_held = event.pressed
			var cell : Vector2i = local_to_map(event.position)
			if get_cell_atlas_coords(cell) == Vector2i(0, 0):
				lastType = Vector2i(4, 0)
			else:
				lastType = Vector2i(0, 0)
	var width = 2

	if event is InputEventMouseMotion and right_click_held and event.position.x < 1280 - width:
		var cell : Vector2i = local_to_map(event.position)
		set_cell(cell, 0, lastType)

	if event is InputEventMouseMotion and right_click_held and event.position.x < 1280 - width:
		var cell : Vector2i = local_to_map(event.position)
		for i in range (-width,width):
			for j in range (-width,width):
				set_cell(cell + Vector2i(i,j),0, lastType)
