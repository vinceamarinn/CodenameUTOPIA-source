extends Resource
class_name CameraMovementData

@export_group("Movement Settings")
@export var CameraTime:float = 5 ## Time it takes for the camera movement to conclude. Default is 5 seconds.

## Type of camera movement.
##[br][br]
##[b]None:[/b] the camera doesn't do anything. This is useful for when you want a character to continue speaking without running another camera movement.
##[br][br][b]Pan:[/b] the camera pans in a certain direction to the character. Panning right means the camera starts at the left and pans right to frame the character into view.
##[br][br][b]Zoom:[/b] the camera zooms in and out to or from the character.
##[br][br][b]Snap:[/b] the camera instantly snaps to the character.
@export_enum("None", "Pan", "Zoom", "Snap") var CameraType:String = "None"
@export_enum("Left", "Right", "Up", "Down", "In", "Out") var CameraDirection:String ## Direction of camera movement. Some camera directions are unique to specific camera movement types.

@export_group("Rotation Settings")
@export_range(-360, 360, 1) var InitialRotation:int = 0 ## Initial rotation of the camera during the camera movement. Works in degrees.
@export var TweenRotation:bool = false ## If set to true, the camera rotation will tween from the initial rotation up to the final rotation.
@export_range(-360, 360, 1) var FinalRotation:int = 0 ## Sets the final rotation of the rotation tween, if Tween Rotation is enabled.

@export_group("Intro Transition")
@export var StartTransition:bool = false ## Quickly tweens the camera into the start position for the tween before it happens.
@export var TransitionTime:float = 0.5 ## Time it takes for the intro transition. Unused if Start Transition is false.
