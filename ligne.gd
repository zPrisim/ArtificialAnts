extends Line2D

func _ready():
	
	var hitBox = CollisionShape2D.new()
	var segment = SegmentShape2D.new()
	segment.a = points.get(0) 
	segment.b = points.get(1) 
	hitBox.shape = segment
	

	var body = StaticBody2D.new()
	body.add_child(hitBox)
	add_child(body) 
