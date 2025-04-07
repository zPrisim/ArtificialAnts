extends Label

	
func _process(_delta):
	text = str( "%5.3f" % get_parent().get_child(0).shape.radius )
