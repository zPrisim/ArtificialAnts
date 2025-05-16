extends Control

signal ant_button_pressed
signal food_button_pressed
signal map_changed

@onready var antLabel = %antLabel
@onready var foodLabel = %foodLabel
@onready var antLifetime = %antLifetime
@onready var speedLabel = %speedLabel

@onready var mapMenu = %mapDropDownMenu

var foodButtonActive := false
var antNumber := 0.0
var foodSize := 50.0


func _ready():
	mapMenu.select(Settings.mapPresetIndex)
	antLabel.text = str(0)
	foodLabel.text = str(50)
	speedLabel.text = "Speed : " + str(1)
	Engine.time_scale = 1
	Engine.physics_ticks_per_second = 30;
	antLifetime.text = str(Settings.antLifeTime)


func _on_ant_h_slider_value_changed(value: float) -> void:
	antLabel.text = str(value)
	antNumber = value
	
func _on_ant_button_pressed():
	emit_signal("ant_button_pressed", antNumber)

func _on_food_button_pressed():
	foodButtonActive = true
	emit_signal("food_button_pressed", foodSize)

func _on_food_h_slider_value_changed(value: float) -> void:
	foodLabel.text = str(value)
	foodSize = value

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


func _draw() -> void:
	draw_rect(Rect2(1276, 0, 204.0, 720.0), Color.DIM_GRAY, true)	
