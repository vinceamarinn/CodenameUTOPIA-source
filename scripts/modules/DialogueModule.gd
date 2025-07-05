extends Node
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")

func process_dialogue_line(line_info:DialogueLine): ## Processes the given dialogue line using its provided information.
	print(GeneralModule.get_character_name(line_info.Speaker) + ": " + line_info.Line)

func read_dialogue(tree_data:DialogueTree): ## Iterates through a given dialogue tree.
	var dialogue_tree = tree_data.dialogue_tree # get dialogue tree
	var loop_tree = tree_data.loop_tree # get loop value
	
	var dialogue_array = dialogue_tree[tree_data.array_tracker].dialogue_array # get selected dialogue array to iterate
		
	for dialogue_line in dialogue_array: #iterate through every dialogue line in the dialogue array and process it
		process_dialogue_line(dialogue_line)
	
	#handle array tracker logic
	#if the array tracker is not at the last array of the tree, increment it
	#if the array tracker is at the last array of the tree, set it to 0 if looping is enabled, do nothing if looping is disabled
	if tree_data.array_tracker < dialogue_tree.size() - 1:
		tree_data.array_tracker += 1
	else:
		if loop_tree == true:
			tree_data.array_tracker = 0

func _ready() -> void:
	ServiceLocator.register_service("DialogueModule", self) # registers module in service locator automatically
