extends Node
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")

func process_dialogue_line(line_info:DialogueLine): ## Processes the given dialogue line using its provided information.
	print(GeneralModule.get_character_name(line_info.Speaker) + ": " + line_info.Line)

func read_dialogue(dialogue:DialogueTree): ## Iterates through a given dialogue tree.
	var dialogue_tree = dialogue.dialogue_tree
	var loop_tree = dialogue.loop_tree
	
	var dialogue_array = dialogue_tree[dialogue.array_tracker].DialogueArray
		
	for dialogue_line in dialogue_array:
		process_dialogue_line(dialogue_line)
	
	print(dialogue_tree.size())
	if dialogue.array_tracker < dialogue_tree.size() - 1:
		dialogue.array_tracker += 1
	else:
		if loop_tree == true:
			dialogue.array_tracker = 0
	
	print(dialogue.array_tracker)
	print("---------")

func _ready() -> void:
	ServiceLocator.register_service("DialogueModule", self) # registers module in service locator automatically
	#just basic testing commands
	await get_tree().create_timer(4).timeout
	read_dialogue(scenes_3D.get_node("TestArea/dialogue tree test").dialogue)
	await get_tree().create_timer(3).timeout
	read_dialogue(scenes_3D.get_node("TestArea/dialogue tree test").dialogue)
	await get_tree().create_timer(3).timeout
	read_dialogue(scenes_3D.get_node("TestArea/dialogue tree test").dialogue)
	await get_tree().create_timer(3).timeout
	read_dialogue(scenes_3D.get_node("TestArea/dialogue tree test").dialogue)
	await get_tree().create_timer(3).timeout
	read_dialogue(scenes_3D.get_node("TestArea/dialogue tree test").dialogue)
	await get_tree().create_timer(3).timeout
	read_dialogue(scenes_3D.get_node("TestArea/dialogue tree test").dialogue)
