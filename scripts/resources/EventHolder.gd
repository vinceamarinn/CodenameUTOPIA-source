extends Node

@export var event:EventData ## Exported event.

func _ready() -> void: ## Fires the event once the Node has entered the tree.
	EventModule.process_event(event)
