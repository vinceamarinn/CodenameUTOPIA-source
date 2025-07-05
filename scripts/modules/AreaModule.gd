extends Node

# This module handles all the loading & unloading of areas and processing of its state data.
# It is also used to load 2D scenes and create the characters that get placed in the environment.

#game tree goodies we need
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var char_group = get_node("/root/GameMain/3DScenes/Characters")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

#templates
@onready var char_template = load("res://sub_scenes/templates/Character.tscn")
@onready var player_template = load("res://sub_scenes/templates/Player.tscn")

func create_character(char_info): ## Creates a character from the base template using the given information, and places them in the map.
	var char_name = GeneralModule.get_character_name(char_info.Name)
	var char_sprites = load("res://sub_scenes/sprite_frames/" + char_name + "_sprites.tres")
	var new_char = char_template.instantiate()
	new_char.name = char_name
	
	for side in new_char.get_children():
		side.sprite_frames = char_sprites
	
	char_group.add_child(new_char)
	new_char.position = char_info.Position
	new_char.rotation_degrees = char_info.Rotation
	
	# create any attached interactables
	if char_info.Interaction:
		var new_interactable = load("res://sub_scenes/templates/Interactable.tscn").instantiate()
		new_interactable.interactable_data = char_info.Interaction
		new_char.add_child(new_interactable)

func load_player(player_char): ## Loads the player character during overworld sections.
	var new_player = player_template.instantiate()
	char_group.add_child(new_player)
	
	var player_name = GeneralModule.get_character_name(player_char)
	var char_sprites = load("res://sub_scenes/sprite_frames/" + player_name + "PLAYER_sprites.tres")
	new_player.get_node("Sprite").sprite_frames = char_sprites

func unload_characters(): ## Unloads any currently loaded characters.
	for chars in char_group.get_children():
		chars.queue_free()

func unload_area(area:Node): ## Deletes the provided area. Also wipes any currently loaded characters.
	area.queue_free() # deletes the current area

func load_area(area_name:String, state:String, player:GeneralModule.PlayableChars) -> void: ## Handles the loading & processing of areas and the area's data based on the given state.
	#get the area's supposed path, end the code if the area doesn't exist
	var area_path = "res://main_scenes/maps/" + area_name + ".tscn"
	if not ResourceLoader.exists(area_path): return
	
	UIModule.trans("in", 0.85, Color.BLACK, false)
	await UIModule.transition_ended
	
	#unload any already existing areas
	for children in scenes_3D.get_children():
		if children == char_group: continue
		unload_area(children)
	unload_characters()
	
	#load, clone & insert the new area
	var new_area = load(area_path).instantiate()
	scenes_3D.add_child(new_area)
	new_area.position.y -= 5
	
	var state_dict = new_area.area_states
	if state_dict.get(state):
		#create the characters from the state
		var area_state = state_dict[state].character_state_array
		for char_state in area_state:
			create_character(char_state)
	
	#after loading, create the characters based on the given data
	#create the player
	load_player(player)
	UIModule.trans("out", 1, Color.BLACK, false)

func _ready() -> void:
	ServiceLocator.register_service("AreaModule", self) # registers module in service locator automatically
