extends Node

##### AREA MODULE #####
# Handles everything related to loading 3D areas, from creating/deleting maps to creating and placing characters.

#game tree goodies we need
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

# 3d groups
@onready var char_group = scenes_3D.get_node("Characters")
@onready var obj_group = scenes_3D.get_node("Objects")
@onready var active_group = scenes_3D.get_node("Actives")

#templates
@onready var char_template = load("res://scenes/templates/Character.tscn")
@onready var player_template = load("res://scenes/templates/Player.tscn")
@onready var interactable_template = load("res://scenes/templates/Interactable.tscn")

# default paths
const DEFAULT_AREA_PATH = "res://scenes/maps/" ## The default path for the map folder.

func create_character(char_name:String, char_position:Vector3, char_rotation:Vector3, char_interactable:InteractableData) -> void: ## Creates a character from the base template using the given information, and places them in the map.
	# if not a valid character, then DIE
	if not GeneralModule.get_character_ID(char_name): return
	
	# don't spawn them if they were flagged to have been previously removed
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
	new_char.position = char_position
	new_char.rotation = char_rotation
	
	# copy over any interactable data that the character had on them
	if char_interactable:
		var new_interactable = interactable_template.instantiate()
		new_interactable.interactable_data = char_interactable
		new_char.add_child(new_interactable)

func create_player(player_char:GeneralModule.PlayableChars) -> PlayerOverworld: ## Loads the player character during overworld sections.
	var new_player = player_template.instantiate()
	char_group.add_child(new_player)
	new_player.name = "Player"
	new_player.position.y += 5
	
	var player_name = GeneralModule.get_character_name(player_char)
	var char_sprites = load("res://images/characters/" + player_name + "/player/sprite_frames.tres")
	new_player.get_node("Sprite").sprite_frames = char_sprites
	
	CameraModule.set_mode(CameraModule.CameraModes.FOLLOW_PLAYER)
	return new_player

func unload_area_state() -> void: ## Unloads any currently loaded area state.
	# get all objects in the object group & delete them, and reset global offset
	for objects in obj_group.get_children():
		objects.queue_free()
	obj_group.transform = Transform3D.IDENTITY
	
	# get all actives in the active group & delete them, and reset global offset
	for actives in active_group.get_children():
		actives.queue_free()
	active_group.transform = Transform3D.IDENTITY
	
	# get all characters in the character group & delete them, and reset global offset
	for characters in char_group.get_children():
		characters.queue_free()
	char_group.transform = Transform3D.IDENTITY

func unload_area(area:Node) -> void: ## Deletes the provided area from the tree.
	area.queue_free() # deletes the current area

func get_area_state_path(area_name:String, state:String) -> String: ## Returns the area state path for the provided area state.
	# define base paths
	var base_path = DEFAULT_AREA_PATH + area_name + "/area_states/"
	var state_path = base_path + state + ".tscn"
	var chapter_path = base_path + "CH" + str(DataStateModule.game_data.CurrentChapter) + ".tscn"
	
	# check if the specific state exists
	if ResourceLoader.exists(state_path):
		return state_path
	# otherwise, get fallback
	if ResourceLoader.exists(chapter_path):
		return chapter_path
	
	# otherwise, return blank string
	return ""

func load_area(area_name:String, state:String, load_player:bool, load_characters:bool, skip_transition:bool) -> Node3D: ## Handles the loading & processing of areas and the area's data based on the given state.
	#get the area's supposed path, end the code if the area doesn't exist
	var area_path = DEFAULT_AREA_PATH + area_name + "/Map.tscn"
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
		# do not unload the gamemain groups! oh nononono!
		if children == char_group: continue
		if children == obj_group: continue
		if children == active_group: continue
		unload_area(children)
	unload_area_state()
	
	# wait to unload everything before starting to load things in
	await get_tree().process_frame
	
	# load, clone & insert the new area
	var new_area = load(area_path).instantiate()
	scenes_3D.add_child(new_area)
	new_area.name = area_name
	
	# load area state
	# verify if area state file exists & setup on enter event reference
	var state_path = get_area_state_path(area_name, state)
	var on_enter_event:EventData = null
	
	# if the file exists (path was obtained), then load area state
	if state_path != "":
		var area_state = load(state_path).instantiate()
		
		# check for any on enter events
		var state_event = area_state.get_node_or_null("OnEnterEvent")
		if state_event:
			on_enter_event = state_event.Event
		
		# simply copypaste the Objects group into 3DScenes/Objects and set the global offset
		var state_objects = area_state.get_node_or_null("Objects")
		if state_objects:
			obj_group.transform = state_objects.transform
			
			for objects in state_objects.get_children():
				objects.reparent(obj_group)
		
		# simply copypaste the Actives group into 3DScenes/Actives and set the global offset
		var state_actives = area_state.get_node_or_null("Actives")
		if state_actives:
			active_group.transform = state_actives.transform
			
			for actives in state_actives.get_children():
				actives.reparent(active_group)
		
		# DON'T actually copypaste the characters, instead copy their info when creating a new character! and set the global offset
		if load_characters:
			var state_characters = area_state.get_node_or_null("Characters")
			
			if state_characters:
				char_group.transform = state_characters.transform
				
				for characters in state_characters.get_children():
					var interactable = characters.get_node_or_null("Interactable")
					create_character(characters.name, characters.position, characters.rotation, interactable.interactable_data if interactable else null)
		
		# and now, at the end... delete the temp area state loaded file
		area_state.queue_free()
	else:
		GeneralModule.debug_message("AreaModule - load_area()", "warning", "Could not load the " + state + " area state for the " + area_name + " area!", "Could not find area state scene in the files.")
	
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
