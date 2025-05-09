extends Label
func _process(_delta):
	set("theme_override_colors/font_color", Color.WHITE)
	text = ""
	text += "FPS : " + str(Engine.get_frames_per_second())
	text += "\nAnts : " + str( get_tree().get_root().get_node("Simulation").ants.size())
	text += "\nPheromones : " + str(get_tree().get_root().get_node("Simulation").pheromones.size()) 
	
	
	var sumFood = 0;
	for f in get_tree().get_root().get_node("Simulation").foods:
		if f:
			sumFood += f.foodValue
	text += "\nFood : " + str(sumFood)
	text += "\nTime elapsed : " + str("%0.2f" % (Time.get_unix_time_from_system() -  get_tree().get_root().get_node("Simulation").startTime))
