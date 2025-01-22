extends Node3D

@export var knownName:String ## Name that shows up in the dialogue boxes.
@onready var frontSprite = $front
@onready var backSprite = $back

func ChangeSprite(Sprite):
	print("my sprite is supposed to change here LOL")
