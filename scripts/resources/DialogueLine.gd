extends Resource
class_name DialogueLine

@export_group("General Settings")
@export var Speaker:GeneralModule.Characters ## Name of the character speaking. Borrows from the [b]General Module[/b]'s list of available names.
@export_multiline var Line:String ## It's the dialogue line. Self-explanatory.
@export var Sprite:String ## Name of the sprite intended for the character.

@export_group("Text Settings")
@export var HideCharacterName:bool = false ## If enabled, the character's name will show up as "???".
@export var TextColor:Color = Color.WHITE ## Color of the dialogue text when the character speaks.
@export var SkipScrolling:bool = false ## If enabled, skips the text scrolling and immediately displays it.

@export_group("Camera Settings")
@export var CameraSubject:GeneralModule.Characters = Speaker ## Whoever the camera focuses on during a dialogue line. If left blank, the camera focuses on whoever's speaking.
@export var CameraTime:float = 5 ## Time it takes for the camera movement to conclude. Default is 5 seconds. Only works in Trials.
@export var OverrideTransition:bool = false ## Overrides the default camera transition for the current camera mode and sets it to the other.[br][br]During regular gameplay, the camera transitions smoothly by default to the next speaker, but in trials, the camera snaps immediately. Turning this option off allows you to swap which transition is chosen.

## Type of camera movement. Only works in Trials.
##[br][br]
##[b]None:[/b] the camera doesn't do anything. This is useful for when you want a character to continue speaking without running another camera movement.
##[br][br][b]Pan:[/b] the camera pans in a certain direction to the character. Panning right means the camera starts at the left and pans right to frame the character into view.
##[br][br][b]Zoom:[/b] the camera zooms in and out to or from the character. 
##[br][br][b]Snap:[/b] the camera instantly snaps to the character.
@export_enum("None", "Pan", "Zoom", "Snap") var CameraType:String = "None"
@export_enum("Left", "Right", "Up", "Down", "In", "Out") var CameraDirection:String ## Direction of camera movement. Only works in Trials. Some camera directions are unique to specific camera movement types.
@export_subgroup("Camera Rotation Settings")
@export_range(-360, 360, 1) var CameraRotation = 0 ## Rotation of the camera during the camera movement. Only works in Trials. Works in degrees.
@export var TweenRotation:bool = false ## If set to true, the camera rotation will tween from its symmetrical value to its chosen value instead of just being simply tilted.

@export_group("Audio Settings")
@export_subgroup("Sound Settings")
#sfx
#voices

@export_subgroup("Music Settings")
@export var MuteMusic:bool = false ## If enabled, the music fades out on this line.
@export var MutingSpeed:float = 2 ## Determines the speed at which the music fades out, if muting is enabled.
@export var PlayMusic:AudioStreamOggVorbis ## If muting is not enabled, the currently playing music will change to the one selected here.

@export_subgroup("SFX Settings")

@export_group("Misc. Settings")
@export var CharacterLeaves:bool = false ## If true, the character will leave the scene upon speaking their line.
#initiate sequence (flashback, nonstop debate...)
