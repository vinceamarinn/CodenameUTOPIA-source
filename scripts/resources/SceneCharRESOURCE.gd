extends Resource
class_name SceneCharRESOURCE

@export_group("General")
@export var Name:String ## Name of the character to pull.
@export var Position:Vector3 = Vector3(0, 0, 0) ## Where to place the character.
@export var Rotation:Vector3 = Vector3(0, 0, 0) ## Rotation the character will have.
@export_group("Dialogue")
@export var AttachedDialogue:Array[DialogueRESOURCE] ## Interaction dialogue attached to the character.
