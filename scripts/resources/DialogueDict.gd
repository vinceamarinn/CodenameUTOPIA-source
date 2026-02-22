extends Resource
class_name DialogueDict

@export var Condition:DialogueCondition ## Details the condition required for this to be processed by the Dialogue Module.
@export var DictData:Dictionary[String, DialogueArray] ## Array of dialogue lines, representing a single dialogue string.

@export_group("Developer Extras")
@export_multiline var DeveloperNote:String = "" ## Just a holder for any necessary developer notes. Does nothing in practice.
