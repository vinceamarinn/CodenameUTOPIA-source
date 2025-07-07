@tool
extends EditorScript

@export var state_name:String = "CH0_sigmund"
@export var overwrite_existing_characters:bool = true
@export var cleanup_character_node:bool = true

func print_error(message:String): ## Just an easy convenient way to print an error message of the script.
	print("ERROR! ", message)

func create_area_state(): ## Creates an area state out of the current Characters node.
	print("Executing ", get_script().resource_path.get_file(), "!")
	print("STAGE 1: Verifying fundamentals")
	print("Detecting if script is running in-editor...")
	if not Engine.is_editor_hint(): # prevents tool script from running in the game
		print_error("The code tried to run in-game.")
		return
	
	print("Done!")
	print("Verifying if scene's root possesses a holder script...")
	
	var scene_root = EditorInterface.get_edited_scene_root() # get the root node of the scene
	if not "area_states" in scene_root: # if the node doesn't have area states, it means it has no holder script, so we should abort
		print_error("Could not find a holder script.")
		return
	
	print("Done!")
	print("Verifying if the temporary character node exists...")
	
	var character_node = scene_root.get_node_or_null("Characters") # get the character node to convert
	if not character_node:
		print_error("Could not find the character template node to copy over.")
		return
	
	print("Done!")
	print("STAGE 2: Creating character states")
	
	var state_temp:Array[CharState] = [] # temporary array to store newly made character states to store later
	for character in character_node.get_children(): # let's create the states!
		print("Creating a character state for ", character.name, "...")
		var new_state = CharState.new()
		state_temp.append(new_state) # add it to the temp thing
		
		var character_ID = GeneralModule.Characters.keys().find(character.name.to_upper()) # copied over from the general module because  icant run the fucking method from a tool script......
		# set all the stuff
		print("Setting state information...")
		new_state.Name = character_ID
		new_state.Position = character.position
		new_state.Rotation = character.rotation_degrees
		print("Success! Finished creating character: ", character.name)
	
	print("Done!")
	print("STAGE 3: Area state handling")
	
	# let's start applying the stuff
	print("Checking for pre-existing state...")
	var area_states = scene_root.area_states
	if area_states.keys().find(state_name) != -1: # if an array exists
		print("State exists!")
		for character in state_temp: # for every character:
			
			# for every character state in the considered area state's character array, we will check if the currently considered character exists
			# if they do exist, and overwrite is enabled, we will overwrite the information
			# otherwise, we just add it in
			var found_existing = false # tracks whether a previous character exists
			var existing_array = area_states[state_name].character_state_array # just defines the existing array so i dont have to write this thing like 6 times
			
			for i in range(existing_array.size()): # iterate through character states
				var state = existing_array[i]
				if state.Name == character.Name: # if the names match, it means there's an existing character
					found_existing = true
					print(character.name, " is already in the state, overwrite: ", overwrite_existing_characters)
					if overwrite_existing_characters: # if overwriting is on, then overwrite data, otherwise do nothing
						existing_array[i] = character
						print(character.name, " successfully overwritten!")
					break # we found a pre existing character, no need to keep running this
			
			if not found_existing: # there is no pre existing character, we can just add it in no problem
				print(character.name, " not found in state.")
				existing_array.append(character)
				print(character.name, " added to state!")
		
		print("State updated!")
		
	else: # if no state array exists, just make a new one!
		print("State doesn't exist!")
		print("Creating new state from scratch...")
		
		var new_state_array = CharStateArray.new()
		new_state_array.character_state_array = state_temp.duplicate()
		area_states[state_name] = new_state_array
		print("State created!")
	
	print("STAGE 4: Cleanup")
	print("Cleaning up...")
	state_temp.clear() # clear the temporary state array
	if cleanup_character_node:
		character_node.queue_free() # cleanup the temporary character node, we dont need it no more
	
	print("Done!")
	print("Execution complete!")

func _run():
	create_area_state()
