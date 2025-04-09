extends Line2D

func _ready():
	
	var hitBox = CollisionShape2D.new()
	var segment = SegmentShape2D.new()
	segment.a = points.get(0) 
	segment.b = points.get(1) 
	hitBox.shape = segment


	var body = StaticBody2D.new()
	body.add_child(hitBox)
	body.set_collision_layer_value(1,true)
	body.set_collision_mask_value(3,true)
	add_child(body) 
