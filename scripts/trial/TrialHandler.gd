extends Minigame

@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")

@onready var char_group = scenes_3D.get_node("Characters")

# MINIGAME SPECIFIC VARIABLES
var trial_script_node:Node = null ## References the trial script to read through.
var start_point:Dictionary[String, Variant] = {} ## References which stage, key and line to start reading from.

func setup() -> bool: ## Initiates the provided trial.
	var valid_data = validate_required_keys(["trial_ID"])
	if not valid_data:
		return false
	
	# load minigame specific data
	var trial_ID:int = minigame_data["trial_ID"]
	var skip_prep:bool = false
	if minigame_data.has("skip_prep"):
		skip_prep = minigame_data["skip_prep"]
	
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
	var courtroom = await AreaModule.load_area("Courtroom", "TRIAL", false, true, true)
	
	# get the saved death registry, go through every character, and delete them if they are registered as dead
	# !!!EDIT THIS LATER SO THAT FOR CHARACTERS WHO ARE DEAD IT SPAWNS A PORTRAIT INSTEAD!!!
	var saved_registry = DataStateModule.game_data.StoryFlags.DeathRegistry
	
	for characters in char_group.get_children():
		var char_name = characters.name
		if GeneralModule.get_character_ID(char_name) and saved_registry.has(char_name):
			characters.queue_free()
	
	# now, check for any mismatches between the internal registry & the save data
	var internal_registry = []
	
	# get the internal registry
	for chapter in GeneralModule.DEATH_REGISTRY:
		# we've checked all the chapters thus far, so break the loop!
		if trial_ID < chapter: break
		
		# add the 'meant to be dead' characters to the registry
		internal_registry.append_array(GeneralModule.DEATH_REGISTRY[chapter])
	
	# sort the two lists
	saved_registry.sort()
	internal_registry.sort()
	
	# if the two are not equal, then find the missing characters from the saved registry, and log them into the minigame data
	if saved_registry != internal_registry:
		# filter the internal registry and return characters that are missing in saved registry
		var revived_characters = internal_registry.filter(
			func(chars): return chars in saved_registry
		)
		
		# add them to the revived registry
		minigame_data["revived_characters"] = revived_characters
	
	# load spectator portraits
	
	
	# setup is done!
	# i believe here we can now load the preparations!
	UIModule.trans("out", 0.01, Color.BLACK, false)
	
	if not skip_prep:
		pass
	
	# ok! let's cleanup the preparations & get straight into it
	# load trial script
	trial_script_node = load("res://scripts/trial/trial_scripts/TrialScript" + str(trial_ID) + ".tscn").instantiate()
	add_child(trial_script_node)
	
	return true

func main() -> void: ## Reads through the provided trial script. You are able to provide it with a specific array & line combo so it starts reading from there.
	# execute preset sequence for when the player tries to revive somebody!
	
	
	
	# ok lets actually run the trial now
	var trial_script_data = trial_script_node.TrialScript
	
	# determine where to start from
	var stage_start = 0
	if start_point.has("stage"):
		stage_start = start_point["stage"]
	
	var current_area = DataStateModule.game_data.CurrentArea
	print("Current Area: ", current_area)
	
	for i in range(stage_start, trial_script_data.size(), 1):
		var trial_stage = trial_script_data[i]
		var stage_dialogue = trial_stage.Dialogue
		await DialogueModule.read_dialogue(stage_dialogue, start_point)

func end() -> void:
	# cleanup minigame specific assets and data
	trial_script_node.queue_free()
	start_point = {}
	
	# call super to cleanup default stuff
	super.end()
