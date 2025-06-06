class_name MapManager
extends Node2D

var right_click_held := false

@export var mapArray : Array[TileMapLayer]
var activeMapPreset : TileMapLayer 

func _ready() -> void:
	for map in mapArray:
		if map:
			map.enabled = false
	activeMapPreset = mapArray[Settings.mapPresetIndex]
	activeMapPreset.enabled = true
	get_parent().UI.map_changed.connect(_on_map_changed)


func _on_map_changed(index):
	Settings.mapPresetIndex = index
	get_tree().reload_current_scene()
	
	

func _input(event: InputEvent) -> void:
	if !Settings.isZoomed && Settings.isPaint:
		if !get_tree().get_root().get_node("Simulation").canPlaceFood:	
			var mouse_pos = get_global_mouse_position()
			var cell : Vector2i = activeMapPreset.local_to_map(mouse_pos)
			var width = Settings.mapPaintSize  

			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and mouse_pos.x < 1280 and mouse_pos.y < 720:
				Settings.paintMode = not Settings.paintMode
				return  

			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_pos.x < 1280 and mouse_pos.y < 720:
				paint(cell, width)

			if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouse_pos.x < 1280 and mouse_pos.y < 720:
				paint(cell, width)


func paint(cell: Vector2i, width: int) -> void:
	var radius_squared = width * width
	for i in range(-width, width + 1):
		for j in range(-width, width + 1):
			if i * i + j * j <= radius_squared:
				var target_cell = cell + Vector2i(i, j)
				if Settings.paintMode:
					activeMapPreset.set_cell(target_cell, 0, Vector2i(0, 0))
				else:
					activeMapPreset.erase_cell(target_cell)
