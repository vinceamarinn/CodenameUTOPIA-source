extends Node

@onready var GameMain = get_node("/root/GameMain")
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var char_group = scenes_3D.get_node("Characters")

func initialize_trial(trial_ID:int) -> void: ## Initiates the provided trial.
	# lock player & reset camera
	var player:PlayerOverworld = char_group.get_node_or_null("Player")
	if player:
		player.update_locks(false)
	
	CameraModule.reset_camera()
	
	# get required game state information
	var story_flags = DataStateModule.game_data.StoryFlags
	
	# toggle on trial flag
	story_flags.IsTrial = true
	
	# fade screen to black (or begin immediately if the screen is already black)
	UIModule.trans("in", 2.25, Color.BLACK, false)
	await UIModule.transition_ended
	
	# load courtroom
	var courtroom = await AreaModule.load_area("Courtroom", "TRIAL", false, false, true)
	
	# load non dead characters
	var trial_state = courtroom.area_states["TRIAL"].character_state_array # get trial seating arrangement
	
	# go through every character, and only load them if they are not registered as dead
	# !!!EDIT THIS LATER SO THAT FOR CHARACTERS WHO ARE DEAD IT SPAWNS A PORTRAIT INSTEAD!!!
	
	for char_state in trial_state:
		var char_name = GeneralModule.get_character_name(char_state.Name)
		if char_name in story_flags.DeathRegistry: continue
		AreaModule.create_character(char_state)
	
	# load spectator portraits
	
	
	# setup is done!
	# i believe here we can now load the preparations!
	UIModule.trans("out", 3, Color.BLACK, false) # fade back in, finally

func end_trial() -> void:
	queue_free()
