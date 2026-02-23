extends Node

##### AREA MODULE #####
# Handles everything related to loading 3D areas, from creating/deleting maps to creating and placing characters.

#game tree goodies we need
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var char_group = get_node("/root/GameMain/3DScenes/Characters")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

#templates
@onready var char_template = load("res://scenes/templates/Character.tscn")
@onready var player_template = load("res://scenes/templates/Player.tscn")
@onready var interactable_template = load("res://scenes/templates/Interactable.tscn")

func create_character(char_info:CharState, global_offset:Vector3) -> void: ## Creates a character from the base template using the given information, and places them in the map.
	# get character name, don't spawn them if they were flagged to have been previously removed
	var char_name = GeneralModule.get_character_name(char_info.Name)
	if DataStateModule.game_data.RemovedCharacters.get(DataStateModule.game_data.CurrentMap):
		if char_name in DataStateModule.game_data.RemovedCharacters[DataStateModule.game_data.CurrentMap]: return
	
	# load character & their sprites
	var char_sprites = load("res://images/characters/" + char_name + "/sprite_frames.tres")
	var new_char = char_template.instantiate()
	new_char.name = char_name
	
	for side in new_char.get_children():
		side.sprite_frames = char_sprites
	
	# create the character physically in the area
	char_group.add_child(new_char)
	new_char.position = char_info.Position + global_offset
	new_char.rotation_degrees = char_info.Rotation
	new_char.position.y -= 5
	
	# create any attached interactables
	if char_info.Interaction:
		var new_interactable = interactable_template.instantiate()
		new_interactable.interactable_data = char_info.Interaction
		new_char.add_child(new_interactable)

func load_character_states(area_state:Array[CharState], global_offset:Vector3) -> void: ## Loads the character states in the given area state.
	# iterate through every character state & create the character based on it
	for char_state in area_state:
		create_character(char_state, global_offset)

func create_player(player_char:GeneralModule.PlayableChars) -> PlayerOverworld: ## Loads the player character during overworld sections.
	var new_player = player_template.instantiate()
	char_group.add_child(new_player)
	new_player.name = "Player"
	
	var player_name = GeneralModule.get_character_name(player_char)
	var char_sprites = load("res://images/characters/" + player_name + "/player/sprite_frames.tres")
	new_player.get_node("Sprite").sprite_frames = char_sprites
	
	CameraModule.set_mode(CameraModule.CameraModes.FOLLOW_PLAYER)
	return new_player

func unload_characters() -> void: ## Unloads any currently loaded characters.
	# get all characters in the character group & delete them
	for chars in char_group.get_children():
		chars.queue_free()

func unload_area(area:Node) -> void: ## Deletes the provided area. Also wipes any currently loaded characters.
	area.queue_free() # deletes the current area

func load_area(area_name:String, state:String, load_player:bool, load_characters:bool, skip_transition:bool) -> Node3D: ## Handles the loading & processing of areas and the area's data based on the given state.
	#get the area's supposed path, end the code if the area doesn't exist
	var area_path = "res://scenes/maps/" + area_name + ".tscn"
	if not ResourceLoader.exists(area_path):
		GeneralModule.debug_message("AreaModule - load_area()", "error", "Failed to load the " + area_name + " area!", "The area file doesn't exist!")
		return
	
	# activate player locks if there's a player
	var existing_player:PlayerOverworld = char_group.get_node_or_null("Player")
	if existing_player:
		existing_player.update_locks(false)
	
	# fade screen out
	if not skip_transition:
		UIModule.trans("in", 0.85, Color.BLACK, false)
		await UIModule.transition_ended
	
	#unload any already existing areas
	for children in scenes_3D.get_children():
		if children == char_group: continue
		unload_area(children)
	unload_characters()
	
	# wait to unload everything before starting to load things in
	await get_tree().process_frame
	
	#load, clone & insert the new area
	var new_area = load(area_path).instantiate()
	scenes_3D.add_child(new_area)
	new_area.position.y -= 5
	
	# load area state
	var state_dict = new_area.area_states
	var on_enter_event = null
	
	if state_dict.get(state):
		#create the characters from the state
		var area_state = state_dict[state].character_state_array
		var global_offset = state_dict[state].global_offset
		on_enter_event = state_dict[state].on_enter_event # stores the on enter event's reference for later
		
		if load_characters:
			load_character_states(area_state, global_offset)
	
	#clear removed character dictionary, add tag for current area
	DataStateModule.game_data.RemovedCharacters.clear()
	DataStateModule.game_data.RemovedCharacters.set(area_name, [])
	
	#create the player
	var new_player = null
	if load_player:
		new_player = create_player(DataStateModule.game_data.PlayerCharacter)
	
	# fade screen back in
	if not skip_transition:
		UIModule.trans("out", 1, Color.BLACK, false)
		await UIModule.transition_ended
	
	# change current area in the game state
	DataStateModule.game_data.CurrentMap = area_name
	
	# play on enter event if it exists
	if on_enter_event:
		EventModule.process_event(on_enter_event)
	
	# let player move now
	if new_player != null:
		new_player.update_locks(true)
	
	print(DataStateModule.game_data.CurrentMap)
	return new_area
