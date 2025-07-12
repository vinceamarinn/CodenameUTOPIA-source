extends Node
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")

# dialogue box component storage
var dialogue_box:Control = null
var box_actives:Control = null
var box_textures:Control = null

var reading_in_progress:bool = false ## Tracks whenever dialogue processing is already in progress. This prevents two calls from overlapping.

func load_dialogue_box(box_name:String) -> void:
	if dialogue_box != null: return
	dialogue_box = load("res://sub_scenes/UI/" + box_name + ".tscn").instantiate()
	UI.add_child(dialogue_box)
	
	# intro stuff
	box_actives = dialogue_box.get_node("Actives")
	box_textures = dialogue_box.get_node("Textures")
	var line_text = box_actives.get_node("Line")
	var name_text = box_actives.get_node("Name")
	var continue_arrow = box_actives.get_node("Arrow")
	
	dialogue_box.position.y += 300
	line_text.text = ""
	name_text.text = ""
	continue_arrow.visible = false
	
	# tweening stuff
	var position_tween = create_tween()
	position_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	position_tween.tween_property(dialogue_box, "position", Vector2(0, 0), .5)
	await position_tween.finished

func unload_dialogue_box() -> void:
	if dialogue_box == null: return
	
	var line_text = box_actives.get_node("Line")
	var name_text = box_actives.get_node("Name")
	var continue_arrow = box_actives.get_node("Arrow")
	line_text.text = ""
	name_text.text = ""
	continue_arrow.visible = false
	
	var leave_tween = create_tween()
	leave_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	leave_tween.tween_property(dialogue_box, "position", Vector2(0, 300), .35)
	await leave_tween.finished
	
	dialogue_box.queue_free()
	dialogue_box = null
	box_actives = null
	box_textures = null

func process_dialogue_line(line_info:DialogueLine) -> void: ## Processes the given dialogue line using its provided information.
	var line_text = box_actives.get_node("Line")
	var name_text = box_actives.get_node("Name")
	var continue_arrow = box_actives.get_node("Arrow")
	continue_arrow.visible = false
	
	# handle character name setting
	if line_info.HideCharacterName:
		name_text.text = "???"
	else:
		name_text.text = tr(GeneralModule.get_character_known_name(line_info.Speaker))
	
	# hide text and pre-set it
	line_text.visible_ratio = 0
	line_text.text = tr(line_info.Line)
	
	# show text tween
	var line_length = line_info.Line.length()
	var scroll_speed = .025 - (.01 * (DataStateModule.option_data.TextScrollSpeed - 3))
	#baseline is 0.025 per character, increasing scroll speed adds +0.01 per increase, decreasing subtracts -0.01
	#meaning:
	#1 - 0.045, 2 - 0.035, 3 - 0.025, 4 - 0.015, 5 - 0.005
	
	var line_tween = create_tween().set_parallel(true)
	line_tween.set_trans(Tween.TRANS_LINEAR)
	line_tween.tween_property(line_text, "visible_ratio", 1, scroll_speed * line_length)
	await line_tween.finished
	
	line_text.visible_ratio = 1
	continue_arrow.visible = true
	
func read_dialogue_array(array_data:DialogueArray) -> void:
	var dialogue_array = array_data.dialogue_array
	for dialogue_line in dialogue_array: #iterate through every dialogue line in the dialogue array and process it
		await process_dialogue_line(dialogue_line)
		await get_tree().create_timer(2).timeout

func read_dialogue_tree(tree_data:DialogueTree) -> void: ## Iterates through a given dialogue tree.
	var dialogue_tree = tree_data.dialogue_tree # get dialogue tree
	var loop_tree = tree_data.loop_tree # get loop value
	
	var array_data = dialogue_tree[tree_data.array_tracker] # get selected dialogue array to iterate
	await read_dialogue_array(array_data)
	
	#handle array tracker logic
	#if the array tracker is not at the last array of the tree, increment it
	#if the array tracker is at the last array of the tree, set it to 0 if looping is enabled, do nothing if looping is disabled
	if tree_data.array_tracker < dialogue_tree.size() - 1:
		tree_data.array_tracker += 1
	else:
		if loop_tree == true:
			tree_data.array_tracker = 0

func read_dialogue(dialogue_data):
	if reading_in_progress: return
	reading_in_progress = true
	
	await load_dialogue_box("DialogueBox")
	if dialogue_data is DialogueArray:
		await read_dialogue_array(dialogue_data)
	elif dialogue_data is DialogueTree:
		await read_dialogue_tree(dialogue_data)
	
	reading_in_progress = false
	await unload_dialogue_box()

func _ready() -> void:
	ServiceLocator.register_service("DialogueModule", self) # registers module in service locator automatically
