extends Label

func _process(_delta):
	if(get_parent().id ==0):
		text = str(get_parent().id)
