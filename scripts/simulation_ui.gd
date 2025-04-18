extends Control

signal ant_button_pressed

@onready var antButton = $MarginContainer/Button

func _ready():
	antButton.pressed.connect(_on_ant_button_pressed)

func _on_ant_button_pressed():
	emit_signal("ant_button_pressed")
