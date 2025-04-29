extends TileMapLayer

var fnl := FastNoiseLite.new()
var right_click_held := false
var paint_mode := true

func _ready() -> void:
	randomize()
	fnl.seed = randi()
	fnl.frequency = 0.01
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 1
	fnl.domain_warp_type = FastNoiseLite.DOMAIN_WARP_BASIC_GRID
	fnl.domain_warp_amplitude = 50.0
	fnl.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT
	fnl.domain_warp_fractal_lacunarity = 1

	generateMap()

func is_edge(x: int, y: int, noise: FastNoiseLite) -> bool:
	var current = noise.get_noise_2d(x, y)
	if current <= 0.1:
		return false
	
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbor_val = noise.get_noise_2d(x + offset.x, y + offset.y)
		if neighbor_val <= 0.1:
			return true
	return false

func generateMap():
	var center = Vector2(160, 90)
	var radius = 20

	for x in 320:
		for y in 180:
			var pos = Vector2(x, y)
			var shapeNoise = fnl.get_noise_2d(x , y)
			var dist = pos.distance_to(center) / radius

			if dist + shapeNoise < 1.0:
				erase_cell(Vector2i(x, y))
			else:
				if is_edge(x, y, fnl):
					set_cell(Vector2i(x, y), 0, Vector2i(0, 0))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_map"):
		get_parent().get_tree().reload_current_scene()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.position.x < 1280:
		if event.pressed:
			right_click_held = true
			paint_mode = not paint_mode
		else:
			right_click_held = false

	var width = 1
	if event is InputEventMouseMotion and right_click_held and event.position.x < 1280 - width:
		var cell : Vector2i = local_to_map(event.position)
		if width == 1:
			if paint_mode:
				set_cell(cell, 0, Vector2i(0, 0))
			else:
				erase_cell(cell)
		else:
			for i in range(-width, width):
				for j in range(-width, width):
					var target_cell = cell + Vector2i(i, j)
					if paint_mode:
						set_cell(target_cell, 0, Vector2i(0, 0))
					else:
						erase_cell(target_cell)
