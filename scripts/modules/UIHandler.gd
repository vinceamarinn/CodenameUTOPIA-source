extends Node

func _ready() -> void:
	ServiceLocator.register_service("UIModule", self) # registers module in service locator automatically
