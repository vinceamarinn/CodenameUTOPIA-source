extends Node

@onready var TrialScripts = $TrialScripts

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueModule.InitModule(self)
	
	var CurrentScript = TrialScripts.get_node("Trial" + str(DataModule.Chapter))
	for i in CurrentScript.get_children():
		var LineResource = i.Lines
		
		for j in LineResource:
			await DialogueModule.DialogueLine(j)
	
	DialogueModule.EndSession()
