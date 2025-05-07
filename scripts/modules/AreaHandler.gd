extends Node

#game tree goodies we need
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var char_group = get_node("/root/GameMain/3DScenes/Characters")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

@onready var char_template = load("res://subScenes/templates/Character.tscn")

func create_character(char_info):
	var char_sprites = load("res://subScenes/spriteFrames/" + char_info.Name + "Sprites.tres")
	var new_char = char_template.instantiate()
	new_char.name = char_info.Name
	
	for side in new_char.get_children():
		side.sprite_frames = char_sprites
	
	char_group.add_child(new_char)
	new_char.position = char_info.Position
	new_char.rotation_degrees = char_info.Rotation

#function used to delete any areas that are given to it, also wipes loaded characters
func unload_area(area:Node):
	area.queue_free() # deletes the current area
	
	# delete any existing characters
	for chars in char_group.get_children():
		chars.queue_free()

#function that handles the loading of areas & processing of area data based on state
func load_area(area_name:String, state:String) -> void:
	#get the area's supposed path, end the code if the area doesn't exist
	var area_path = "res://mainScenes/maps/" + area_name + ".tscn"
	if not ResourceLoader.exists(area_path): return # if we can't find the area in the files, stop execution
	
	#unload any already existing areas
	for children in scenes_3D.get_children():
		if children == char_group: continue
		unload_area(children)
	
	#load, clone & insert the new area
	var new_area = load(area_path).instantiate()
	scenes_3D.add_child(new_area)
	new_area.position.y -= 5
	
	#process loading state data
	var state_dict = new_area.AreaStates
	if not state_dict[state]: return
	
	var area_state = state_dict[state].CharacterStateArray
	for char_state in area_state:
		create_character(char_state)

func _ready() -> void:
	ServiceLocator.register_service("AreaModule", self) # registers module in service locator automatically
	
	await get_tree().create_timer(1).timeout
	load_area("TestArea", "testdemo")
	await get_tree().create_timer(3).timeout
	load_area("TestArea", "sigmund")
