extends TileMapLayer

var fnl := FastNoiseLite.new()

func _ready() -> void:
	randomize()
	fnl.seed = randi()
	fnl.frequency = 0.06
	fnl.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
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
			
			# Forme aléatoire centrée basée sur la distance + une noise secondaire
			var shapeNoise = fnl.get_noise_2d(x * 0.2, y * 0.2)
			var dist = pos.distance_to(center) / radius

			if dist + shapeNoise < 1.0:
				# Zone spéciale centrale (organique)
				set_cell(Vector2i(x, y), 0, Vector2i(4, 0))
			else:
				# Reste de la map générée avec ta logique habituelle
				if noiseVal > 0.1:
					set_cell(Vector2i(x, y), 0, Vector2i(0, 0)) # murs
				else:
					set_cell(Vector2i(x, y), 0, Vector2i(4, 0))




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_map"):
		get_tree().reload_current_scene()
