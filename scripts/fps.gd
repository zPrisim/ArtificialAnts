extends Label
func _process(_delta):
	set("theme_override_colors/font_color", Color.BLACK)
	text = ""
	text += "fps: " + str(Engine.get_frames_per_second())
	text += "\nNumber of ants : " + str(get_parent().ants.size())
	text += "\nNumber of pheromones : " + str(get_parent().pheromones.size()) 
	
	
	var sumFood = 0;
	for f in get_parent().foods:
		if f:
			sumFood += f.foodValue
	text += "\nFood on map : " + str(sumFood)
	text += "\nTime elapsed : " + str("%0.2f" % (Time.get_unix_time_from_system() - get_parent().startTime))
