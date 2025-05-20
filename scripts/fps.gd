extends Label

var counter: float = 0

func _process(delta):
	var timePassed = get_tree().get_root().get_node("Simulation").startTime
	if timePassed != 0:
		counter += delta

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
	if timePassed == 0: 
		text += "\nReal Time : " + str("%0.2f" % (timePassed ))
	else:
		text += "\nReal Time : " + str("%0.2f" % (Time.get_unix_time_from_system() - timePassed ))
	text += "\nSimulation Time: " + str("%0.2f" % counter)
