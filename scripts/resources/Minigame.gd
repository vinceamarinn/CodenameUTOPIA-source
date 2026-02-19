extends Node
class_name Minigame

@onready var GameMain = get_node("/root/GameMain")

var minigame_data:Dictionary = {}

func init(data:Dictionary) -> void: ## Loads the minigame data and calls the minigame's specific setup.
	# set given data to minigame data
	minigame_data = data
	
	# do whatever else you want...
	var success = await setup()
	
	# at the end, run main() if setup was successful
	if success:
		main()
	else: # otherwise, abort and cleanup
		GeneralModule.debug_message("Minigame (" + name + ") - main()", "error", "Minigame failed to load!", "Something went wrong during setup.")
		end()

func validate_required_keys(required_keys:Array) -> bool: ## Checks if the minigame data is missing any valuable information. If it's missing anything, it will abort the setup and end the minigame.
	# store any data that's missing for debugging
	var missing_keys:Array = []
	
	# check if there's any missing data
	for key in required_keys:
		if not minigame_data.has(key):
			missing_keys.append(key)
	
	# error message and abort the setup if required data is missing
	if not missing_keys.is_empty():
		GeneralModule.debug_message("Minigame (" + name + ") - validate_required_keys()", "error", "Minigame data didn't load!", "Missing required data: " + str(missing_keys))
		return false
	
	# all data loaded! we good bruh
	return true

func setup() -> bool: ## Basic setup function. Must be overwritten by individual minigames.
	# do whatever the fuck you want...
	# ...
	
	# if not overwritten, do an error! it has to be overwritten
	GeneralModule.debug_message("Minigame (" + name + ") - setup()", "error", "Setup method was not overwritten!", "Aborting minigame...")
	return false

func main() -> void: ## The 'main' function of the minigame. This is where the logic happens.
	# do whatever the fuck you want...
	# ...
	
	# if not overwritten, do an error! it has to be overwritten
	GeneralModule.debug_message("Minigame (" + name + ") - main()", "error", "Main minigame code was not overwritten!", "You gotta do that if you want to code a minigame, dude!")

func end() -> void: ## Ends and cleans up the minigame assets.
	# delete any minigame specific assets and cleanup garbage...
	
	# clear minigame data reference
	minigame_data.clear()
	
	# delete the minigame holder node
	queue_free()
