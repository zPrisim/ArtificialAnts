extends Control

signal ant_button_pressed

@onready var antButton = $MarginContainer/HSplitContainer/Button
@onready var antSlider = $MarginContainer/HSplitContainer/VSplitContainer/HSlider
@onready var antLabel = $MarginContainer/HSplitContainer/VSplitContainer/Label




func _ready():
	antButton.pressed.connect(_on_ant_button_pressed)
	antSlider.value_changed.connect(_on_ant_slider_slide)
	
func _process(_delta: float) -> void:
	antLabel.text = str(antSlider.value)


func _on_ant_slider_slide(value):
	antLabel.text = str(value)

func _on_ant_button_pressed():
	emit_signal("ant_button_pressed")
