class_name randomMap
extends TileMapLayer

var fnl := FastNoiseLite.new()


func _ready() -> void:
	if Settings.seedChange:
		var x = randi_range(30,1250)
		var y =  randi_range(30,690)
		Settings.antHillPos = Vector2i(x, y)
	initMapRandom()

func initMapRandom():   
	clear()
	if Settings.seedChange:
		randomize()
		fnl.seed = randi()
		Settings.lastSeed = fnl.seed
	else:
		fnl.seed = Settings.lastSeed
	fnl.frequency = 0.01
	fnl.noise_type = FastNoiseLite.TYPE_PERLIN
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 1
	fnl.domain_warp_type = FastNoiseLite.DOMAIN_WARP_BASIC_GRID
	fnl.domain_warp_amplitude = 50.0
	fnl.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT
	fnl.domain_warp_fractal_lacunarity = 1
	generateRandomMap()

func is_edge(x: int, y: int, noise: FastNoiseLite) -> bool:
	var current = noise.get_noise_2d(x, y)
	if current <= 0.1:
		return false
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbor_val = noise.get_noise_2d(x + offset.x, y + offset.y)
		if neighbor_val <= 0.20:
			return true
	return false

func generateRandomMap():
	var radius = 10

	for x in range(320):
		for y in range(180):
			var pos = Vector2(x, y)
			var shapeNoise = fnl.get_noise_2d(x , y)
			var dist = pos.distance_to(Settings.antHillPos/4) / radius

			if dist + shapeNoise < 1.5:
				erase_cell(Vector2i(x, y))
			else:
				if is_edge(x, y, fnl):
					set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
					
