extends Node

@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var char_group = get_node("/root/GameMain/3DScenes/Characters")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

func create_character():
	pass

func load_area():
	pass

func unload_area():
	pass

func _ready() -> void:
	ServiceLocator.register_service("AreaModule", self) # registers module in service locator automatically
