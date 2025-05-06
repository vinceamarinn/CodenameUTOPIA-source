extends Node

func _ready() -> void:
	ServiceLocator.register_service("CameraModule", self) # registers module in service locator automatically
