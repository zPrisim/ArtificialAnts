extends Label

	
func _process(_delta):
	text = str( "%5.2f" % get_parent().foodValue )
