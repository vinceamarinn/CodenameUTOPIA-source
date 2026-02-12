extends Node

func initialize_trial(trial_ID:int) -> void: ## Initiates the provided trial.
	print("trial loaded! omfg we're so back")
	print("trial handler received ID: ", trial_ID)
	
	# fade screen to black (or begin immediately if the screen is already black)

func end_trial() -> void:
	queue_free()
