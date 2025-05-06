extends Resource
class_name DialogueRESOURCE

@export_group("General Settings")
@export var Speaker:String ## Name of the character speaking.
@export_multiline var Line:String
@export var Sprite:String ## Name of the sprite intended for the character.

@export_group("Text Settings")
@export var HideCharacterName:bool = false ## If true, the character's name will show up as "???".
@export var TextColor:Color = Color.WHITE ## Color of the dialogue text when the character speaks.
@export var SkipScrolling:bool = false ## If enabled, skips the text scrolling and immediately displays it.

@export_group("Camera Settings")
@export var CameraSubject:String ## Whoever the camera focuses on during a dialogue line. If left blank, the camera focuses on whoever's speaking.
@export var CameraTime:float = 5 ## Time it takes for the camera movement to conclude. Default is 5 seconds. Only works in Trials.
@export var OverrideTransition:bool = false ## Behavior depends on current setting - if currently in-trial, turning it on makes the camera smoothly move from the previous position. If not in-trial, turning it on makes the camera snap from the previous position. Leaving it off does the opposite in both cases.
@export_subgroup("Camera Movement Settings")
@export_enum("Pan", "Zoom", "Snap") var CameraType:String ## Type of camera movement. Only works in Trials. If left blank, no camera movement takes place, no matter if other options are selected.
@export_enum("Left", "Right", "Up", "Down", "In", "Out") var CameraDirection:String ## Direction of camera movement. Only works in Trials.
@export_subgroup("Camera Rotation Settings")
@export_range(-360, 360, 1) var CameraRotation = 0 ## Rotation of the camera during the camera movement. Only works in Trials.
@export var TweenRotation:bool = false ## Determine whether the rotation is passive (false) or if it's part of the camera movement (true).

@export_group("Audio Settings")
@export_subgroup("Sound Settings")
#sfx
#voices

@export_subgroup("Music Settings")
@export var MuteMusic:bool = false ## If enabled, the music fades out on this line. Muting the music takes priority over changing the music.
@export var MutingSpeed:float = 1.5 ## Determines the speed at which the music fades out.

@export_group("Misc Settings")
@export var CharacterLeaves:bool = false ## If true, the character will leave the scene upon speaking their line.
#initiate sequence (flashback, nonstop debate...)
