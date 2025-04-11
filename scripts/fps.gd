extends Label
func _process(_delta):
	text = ""
	text += "fps: " + str(Engine.get_frames_per_second())
	text += "\nNumber of ants : " + str(get_parent().ants.size())
	var sumFood = 0;
	for f in get_parent().foods:
		if f:
			sumFood += f.foodValue
	text += "\nFood on map : " + str(sumFood)
