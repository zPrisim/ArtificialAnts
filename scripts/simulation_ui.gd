extends Control

signal ant_button_pressed
signal map_changed

@onready var antLabel = %antLabel
@onready var foodLabel = %foodLabel
@onready var antLifetime = %antLifetime
@onready var speedLabel = %speedLabel

@onready var paintBrushSize = %paintBrushSize

@onready var paintBrushLabel = %paintBrushLabel

@onready var reproductionCheckBox = %reproductionCheckBox
@onready var seedCheckBox = %seedCheckBox
@onready var viewPheromonesCheckBox = %viewPheromonesCheckBox
@onready var paintButton = %paintButton
@onready var mapMenu = %mapDropDownMenu

var foodButtonActive := false
var antNumber := 1
var foodSize := 100.0


func _ready():
	mapMenu.select(Settings.mapPresetIndex)
	antLabel.text = str(antNumber)
	foodLabel.text = str(foodSize)
	speedLabel.text = "Speed : " + str(1)
	paintBrushLabel.text =  "Paint size : " + str(Settings.mapPaintSize)
	antLifetime.text = str(Settings.antLifeTime)
	paintBrushSize.value = Settings.mapPaintSize

	reproductionCheckBox.button_pressed = Settings.antReproduction
	seedCheckBox.button_pressed = Settings.seedChange
	paintButton.button_pressed = Settings.isPaint
	viewPheromonesCheckBox.button_pressed = Settings.pheromoneVisible
	if Settings.mapPresetIndex != 0:
		seedCheckBox.visible = false
	
	Engine.time_scale = 1
	Engine.physics_ticks_per_second = 30;


func _on_ant_h_slider_value_changed(value: int) -> void:
	antLabel.text = str(value)
	antNumber = value
	
func _on_ant_button_pressed():
	emit_signal("ant_button_pressed", antNumber)

func _on_food_button_pressed():
	foodButtonActive = true
	Settings.isPaint = false
	paintButton.disabled = ! paintButton.disabled
	get_tree().get_root().get_node("Simulation").canPlaceFood = !get_tree().get_root().get_node("Simulation").canPlaceFood 

func _on_food_h_slider_value_changed(value: float) -> void:
	foodLabel.text = str(value)
	get_tree().get_root().get_node("Simulation").lastUIFoodSize = value

func _on_speed_slider_value_changed(value: float) -> void:
	speedLabel.text = "Speed : " + str(value)
	Engine.physics_ticks_per_second = int(value * 30);
	Engine.time_scale = value;

	

func _on_map_drop_down_menu_item_selected(index: int) -> void:
	emit_signal("map_changed",index)

func _on_ant_lifetime_text_changed(new_text: String) -> void:
	if new_text.is_empty() or new_text.is_valid_int():
		Settings.antLifeTime = int(new_text)
		print(new_text)
	else:
		antLifetime.new_text = str(Settings.antLifeTime)	

func _on_ant_to_follow_text_changed(new_text: String) -> void:
	if !new_text.is_empty() and new_text.is_valid_int():
		get_tree().get_root().get_node("Simulation").followAnt(int(new_text))
	elif new_text.is_empty():
		get_tree().get_root().get_node("Simulation").followAnt(-1)




func _on_seed_check_box_pressed() -> void:
	Settings.seedChange = !Settings.seedChange

func _on_reproduction_check_button_pressed() -> void:
	Settings.antReproduction = !Settings.antReproduction
	

func _on_view_pheromones_check_box_pressed() -> void:
	for p in get_tree().get_root().get_node("Simulation").pheromones:
		p.visible = !p.visible
	Settings.pheromoneVisible = ! Settings.pheromoneVisible

func _on_paint_brush_size_value_changed(value: float) -> void:
	paintBrushLabel.text = "Paint size : " + str(value)
	Settings.mapPaintSize = value


func _input(event: InputEvent) -> void:	
	if !Settings.isZoomed && Settings.isPaint:

		if Settings.mapPaintSize < 1:
			Settings.mapPaintSize = 1
		if Settings.mapPaintSize > 10:
			Settings.mapPaintSize = 10
		else:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed :
					Settings.mapPaintSize += 0.25
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed :
					Settings.mapPaintSize -= 0.25
		
		paintBrushLabel.text = "Paint size : " + str(Settings.mapPaintSize)
		paintBrushSize.value = Settings.mapPaintSize

func _on_paint_button_pressed() -> void:
	Settings.isPaint = !Settings.isPaint
	Settings.paintMode = true
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(1276, 0, 204.0, 720.0), Color.DIM_GRAY, true)	
	var mousePos = get_global_mouse_position()
	if !Settings.isZoomed && Settings.isPaint:
		if !get_tree().get_root().get_node("Simulation").canPlaceFood:
			var paintSize = Settings.mapPaintSize
			var tileSize = 4

			var radius = paintSize * tileSize
			if mousePos.x < 1280 - radius && mousePos.y < 720:
				if Settings.paintMode:
					draw_circle(mousePos, radius, Color("#8f563b"))
					draw_circle(mousePos, radius, Color.BLACK, false)
				else:
					draw_circle(mousePos, radius, Color.WHITE, false)
	if get_tree().get_root().get_node("Simulation").canPlaceFood && mousePos.x < 1280 - 25 && mousePos.y < 720:
		draw_circle(mousePos, 25, Color.GREEN, true)
