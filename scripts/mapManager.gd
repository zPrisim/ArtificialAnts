class_name MapManager
extends Node2D

var right_click_held := false
var paint_mode := true

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and get_global_mouse_position().x < 1280:
		if event.pressed:
			right_click_held = true
			paint_mode = not paint_mode
		else:
			right_click_held = false

	var width = 1.5
	if event is InputEventMouseMotion and right_click_held and get_global_mouse_position().x < 1280 - width:
		var mouse_pos = get_global_mouse_position()
		var cell : Vector2i = activeMapPreset.local_to_map(mouse_pos)
		
		if width == 1:
			if paint_mode:
				activeMapPreset.set_cell(cell, 0, Vector2i(0, 0))
			else:
				activeMapPreset.erase_cell(cell)
		else:
			for i in range(-width, width):
				for j in range(-width, width):
					var target_cell = cell + Vector2i(i, j)
					if paint_mode:
						activeMapPreset.set_cell(target_cell, 0, Vector2i(0, 0))
					else:
						activeMapPreset.erase_cell(target_cell)
