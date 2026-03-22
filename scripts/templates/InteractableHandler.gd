extends Node

##### INTERACTABLE HANDLER #####
# Not a real module, moreso a tracking & registry system - handles priority interactable tracking for multiple On Interact interactables.

# important stuff
var interactables_in_range: Array[Interactable] = [] ## Contains the registry for all currently active interactables that are in range of the player.
var closest_interactable: Interactable = null ## Contains the closest Interact interactable
var tracked_player: PlayerOverworld = null ## References the player character.

func update_closest_interactable() -> void: ## Updates to check what the current closest registered interactable to the player is.
	var prev_closest = closest_interactable
	closest_interactable = null
	
	# if the player is unable to interact, hide prompt and return
	if tracked_player == null or not is_instance_valid(tracked_player) or not tracked_player.can_interact:
		if prev_closest != null and is_instance_valid(prev_closest):
			prev_closest.show_prompt(false)
		return
	
	# if there is only one interactable, it is automatically the closest
	if interactables_in_range.size() == 1:
		var single_interactable = interactables_in_range[0]
		if is_instance_valid(single_interactable):
			closest_interactable = single_interactable
	elif interactables_in_range.size() >= 2:
		var closest_dist = INF
		
		for interactable in interactables_in_range:
			if is_instance_valid(interactable):
				var dist = tracked_player.global_position.distance_to(interactable.global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest_interactable = interactable
	
	# update prompts if there is a new closest one
	if prev_closest != closest_interactable:
		if prev_closest != null and is_instance_valid(prev_closest):
			prev_closest.show_prompt(false)
		
		if closest_interactable != null and is_instance_valid(closest_interactable):
			closest_interactable.show_prompt(true)

func add_to_registry(interactable: Interactable, player: PlayerOverworld) -> void: ## Adds the interactable to the registry.
	# add interactable to registry if it's not already there
	if not interactables_in_range.has(interactable):
		interactables_in_range.append(interactable)
	
	# set up tracking the player if this is the first interactable
	if tracked_player == null:
		tracked_player = player
	
	update_closest_interactable()

func remove_from_registry(interactable: Interactable) -> void: ## Removes the interactable from the registry.
	# wipe interactable from registry if it's there
	if interactables_in_range.has(interactable):
		interactables_in_range.erase(interactable)
	
	# if there are no more interactables active, cleanup refs
	if interactables_in_range.is_empty():
		tracked_player = null
		closest_interactable = null
	else:
		# otherwise update the check
		update_closest_interactable()

func _process(_delta: float) -> void: ## Fires every frame.
	# run ONLY if we have 2+ interactables in the registry
	if interactables_in_range.size() < 2: return
	
	# if the player has been deleted or is invalid, don't run
	if tracked_player == null or not is_instance_valid(tracked_player) or not tracked_player.is_inside_tree(): return
	
	# update interactable distance
	update_closest_interactable()
