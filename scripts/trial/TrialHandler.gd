extends Minigame

@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var char_group = scenes_3D.get_node("Characters")

# MINIGAME SPECIFIC VARIABLES
var trial_script_node:Node = null ## References the trial script to read through.
var start_point:Dictionary[String, int] = {} ## References which stage and line to start reading from.

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
	UIModule.trans("out", 0.01, Color.BLACK, false)
	
	if not skip_prep:
		pass
	
	# fade back in, finally
	
	
	# ok! let's cleanup the preparations & get straight into it
	# load trial script
	trial_script_node = load("res://scripts/trial/TrialScript" + str(trial_ID) + ".tscn").instantiate()
	add_child(trial_script_node)
	
	return true

func main() -> void: ## Reads through the provided trial script. You are able to provide it with a specific array & line combo so it starts reading from there.
	var trial_script_data = trial_script_node.TrialScript
	
	# determine where to start from
	var stage_start = 0
	if start_point.has("stage"):
		stage_start = start_point["stage"]
	
	for i in range(stage_start, trial_script_data.size(), 1):
		var trial_stage = trial_script_data[i]
		await DialogueModule.read_dialogue(trial_stage.Dialogue, start_point)

func end() -> void:
	# cleanup minigame specific assets and data
	trial_script_node.queue_free()
	start_point = {}
	
	# call super to cleanup default stuff
	super.end()
