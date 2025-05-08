extends Node

func process_dialogue_line(line_info): ## Processes the given dialogue line using its provided information.
	pass

func read_dialogue(dialogue_tree): ## Iterates through a given dialogue tree.
	pass

func _ready() -> void:
	ServiceLocator.register_service("DialogueModule", self) # registers module in service locator automatically
