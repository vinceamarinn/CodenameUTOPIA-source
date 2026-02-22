extends Resource
class_name DialogueLine

@export var Condition:DialogueCondition ## Details the condition required for this to be processed by the Dialogue Module.

@export var Speaker:GeneralModule.Characters ## Name of the character speaking. Borrows from the [b]General Module[/b]'s list of available names.
@export_multiline var Line:String ## It's the dialogue line. Self-explanatory.
@export var Sprite:String ## Name of the sprite intended for the character.

@export_group("Text Settings")
@export var HideCharacterName:bool = false ## If enabled, the character's name will show up as "???".
@export var TextColor:Color = Color.WHITE ## Color of the dialogue text when the character speaks.
@export var SkipScrolling:bool = false ## If enabled, skips the text scrolling and immediately displays it.

@export_group("Camera Settings")
@export var CameraMovement:CameraMovementData ## Container for the data used in the Camera Movement for this line.
@export var CameraSubject:GeneralModule.Characters = Speaker ## Whoever the camera focuses on during a dialogue line. If left blank, the camera focuses on whoever's speaking.

@export_group("Audio Settings")
@export_subgroup("Music Settings")
@export var MuteMusic:bool = false ## If enabled, the music fades out on this line.
@export var MutingSpeed:float = 3 ## Determines the time it takes, in seconds, at which the music fades out, if muting is enabled.
@export var PlayMusic:AudioStreamOggVorbis ## The currently playing music will change to the one selected here. If muting is enabled, then it will take priority over this.

@export_subgroup("SFX & Voice Settings")
@export var PlaySoundEffect:AudioStreamOggVorbis ## Play the chosen sound effect.
@export var PlayVoiceline:AudioStreamOggVorbis ## Play the chosen voiceline.

@export_group("Event Settings")
@export var EventList:Array[EventData] ## List of events to trigger during this dialogue.

@export_group("Developer Extras")
@export_multiline var DeveloperNote:String = "" ## Just a holder for any necessary developer notes. Does nothing in practice.
