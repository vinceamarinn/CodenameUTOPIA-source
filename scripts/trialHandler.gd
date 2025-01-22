extends Node3D

@onready var TrialScripts = $TrialScripts
@export var Trial = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueModule.InitModule(self)
	
	var CurrentScript = TrialScripts.get_node("Trial" + str(Trial))
	for i in CurrentScript.get_children():
		var LineResource = i.Lines
		
		for j in LineResource:
			await DialogueModule.DialogueLine(j)
