extends Node

func _ready() -> void:
	ServiceLocator.register_service("GeneralModule", self) # registers module in service locator automatically
