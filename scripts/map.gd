extends StaticBody2D

@onready var polygon2D = $Polygon2D
@onready var collisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	collisionPolygon2D.polygon = polygon2D.polygon
	polygon2D.color = Color.SADDLE_BROWN
