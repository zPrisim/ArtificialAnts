extends Control

signal ant_button_pressed
signal food_button_pressed


@onready var antButton = %antButton
@onready var antSlider = %antHSlider
@onready var antLabel = %antLabel

@onready var foodButton = %foodButton
@onready var foodSlider = %foodHSlider
@onready var foodLabel = %foodLabel

@onready var antLifetime = %antLifetime
@onready var antToFollow = %antToFollow

var foodButtonActive := false

func _ready():
	antButton.pressed.connect(_on_ant_button_pressed)
	antSlider.value_changed.connect(_on_ant_slider_slide)
	foodButton.pressed.connect(_on_food_button_pressed)
	foodSlider.value_changed.connect(_on_food_slider_slide)
	antLabel.text = str(antSlider.value)
	foodLabel.text = str(foodSlider.value)
	foodButton.button_pressed = false
	
	antLifetime.text_changed.connect(_on_antLifeTime_changed)
	antLifetime.text = str(Settings.antLifeTime)
	
	antToFollow.text_changed.connect(_on_antToFollow_changed)


func _on_ant_slider_slide(value):
	antLabel.text = str(value)
func _on_ant_button_pressed():
	emit_signal("ant_button_pressed")


func _on_food_slider_slide(value):
	foodLabel.text = str(value)

func _on_food_button_pressed():
	foodButtonActive = true
	emit_signal("food_button_pressed")

func _on_antLifeTime_changed(text :String):
	if text.is_empty() or text.is_valid_int():
		Settings.antLifeTime = int(text)
		print(text)
	else:
		antLifetime.text = str(Settings.antLifeTime)	

func _on_antToFollow_changed(text :String):
	if !text.is_empty() and text.is_valid_int():
		get_tree().get_root().get_node("Simulation").followAnt(int(text))
	elif text.is_empty():
		get_tree().get_root().get_node("Simulation").followAnt(-1)

func _draw() -> void:
	draw_rect(Rect2(1276, 0, 204.0, 720.0), Color.DIM_GRAY, true)	
