extends Node

func _ready() -> void:
	ServiceLocator.register_service("DataModule", self) # registers module in service locator automatically
