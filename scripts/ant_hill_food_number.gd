extends Label

func _process(_delta):
	text = ""
	text +=str(get_parent().foodNumber)
