extends Resource
class_name CharState

@export_group("General")
@export var Name:GeneralModule.Characters ## Selected character.
@export var Position:Vector3 = Vector3(0, 0, 0) ## Where to place the character.
@export var Rotation:Vector3 = Vector3(0, 0, 0) ## Rotation the character will have (in degrees).
