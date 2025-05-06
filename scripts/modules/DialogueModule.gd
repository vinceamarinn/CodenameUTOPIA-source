extends Node

func process_dialogue_line(line_info):
	pass

func read_dialogue(dialogue_tree):
	pass

func _ready() -> void:
	ServiceLocator.register_service("DialogueModule", self) # registers module in service locator automatically
