extends Control

signal ant_button_pressed
signal food_button_pressed

@onready var antButton = $MarginContainer/VSplitContainer/HSplitContainerAnt/antButton
@onready var antSlider = $MarginContainer/VSplitContainer/HSplitContainerAnt/VSplitContainer/antHSlider
@onready var antLabel = $MarginContainer/VSplitContainer/HSplitContainerAnt/VSplitContainer/antLabel



@onready var foodButton = $MarginContainer/VSplitContainer/HSplitContainerFood/foodButton
@onready var foodSlider = $MarginContainer/VSplitContainer/HSplitContainerFood/VSplitContainer/foodHSlider
@onready var foodLabel = $MarginContainer/VSplitContainer/HSplitContainerFood/VSplitContainer/foodLabel

var foodButtonActive := false

func _ready():
	antButton.pressed.connect(_on_ant_button_pressed)
	antSlider.value_changed.connect(_on_ant_slider_slide)
	foodButton.pressed.connect(_on_food_button_pressed)
	foodSlider.value_changed.connect(_on_food_slider_slide)
	antLabel.text = str(antSlider.value)
	foodLabel.text = str(foodSlider.value)



func _on_ant_slider_slide(value):
	antLabel.text = str(value)
func _on_ant_button_pressed():
	emit_signal("ant_button_pressed")


func _on_food_slider_slide(value):
	foodLabel.text = str(value)

func _on_food_button_pressed():
	foodButtonActive = true
	emit_signal("food_button_pressed")
