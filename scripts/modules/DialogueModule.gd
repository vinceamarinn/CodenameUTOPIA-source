extends Node
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var char_group = scenes_3D.get_node("Characters")

# dialogue box component storage
var dialogue_box:Control = null # holds the dialogue box reference
var box_actives:Control = null # holds the folder node to the active components of the dialogue box
var box_textures:Control = null # holds the folder node to the texture components of the dialogue box

# current tween holders
var current_scroll_tween:Tween = null
var current_camera_tween:Tween = null
var current_autoscroll_tween:Tween = null

# functionality stuff
var reading_in_progress:bool = false ## Tracks whenever dialogue processing is already in progress. This prevents two calls from overlapping.
var line_in_process:bool = false ## Tracks whether a dialogue line is being processed.
var dialogue_logs:Array = [] ## Stores the past 100 dialogue lines in speaker: text format. Gets displayed in its own UI.

# signals
signal continue_dialogue_signal ## Fires whenever I want to continue the dialogue.

func _input(event:InputEvent) -> void: ## Input stuff.
	if not reading_in_progress: return
	
	if event.is_action_pressed("ui_confirm"):
		if current_scroll_tween != null and line_in_process: # if a tween is in progress, pressing enter will skip it.
			current_scroll_tween.emit_signal("finished")
			current_scroll_tween.kill()
			
		elif not line_in_process:
			continue_dialogue_signal.emit()

func autoscroll() -> void: ## Handles autoscrolling, if autoscrolling is active.
	if not DataStateModule.option_data.Autoscroll: return # cancel if autoscrolling is disabled, just in case
	
	# cancel previous tween if it exists
	if current_autoscroll_tween:
		current_autoscroll_tween.kill()
	
	# create countdown tween
	var autoscroll_tween = create_tween()
	autoscroll_tween.tween_interval(DataStateModule.option_data.AutoscrollTimer)
	current_autoscroll_tween = autoscroll_tween
	
	# wait for timer to finish
	await autoscroll_tween.finished
	
	if not DataStateModule.option_data.Autoscroll: return # cancel at the end if autoscrolling was disabled before the timer ran out if you're a moron and decided to switch it in the settings
	if not line_in_process: # actually continue the dialogue automatically
		continue_dialogue_signal.emit()

func load_dialogue_box(box_name:String) -> void: ## Provisory temp function to load the default testing dialogue box.
	if dialogue_box != null: return
	dialogue_box = load("res://sub_scenes/UI/" + box_name + ".tscn").instantiate()
	UI.add_child(dialogue_box)
	
	# intro stuff
	box_actives = dialogue_box.get_node("Actives")
	box_textures = dialogue_box.get_node("Textures")
	var line_text = box_actives.get_node("Line")
	var name_text = box_actives.get_node("Name")
	var continue_arrow = box_actives.get_node("Arrow")
	
	dialogue_box.position.y += 300
	line_text.text = ""
	name_text.text = ""
	continue_arrow.visible = false
	
	# tweening stuff
	var position_tween = create_tween()
	position_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	position_tween.tween_property(dialogue_box, "position", Vector2(0, 0), .5)
	await position_tween.finished

func unload_dialogue_box() -> void: ## Provisory temp function to unload the default testing dialogue box.
	if dialogue_box == null: return
	
	var line_text = box_actives.get_node("Line")
	var name_text = box_actives.get_node("Name")
	var continue_arrow = box_actives.get_node("Arrow")
	line_text.text = ""
	name_text.text = ""
	continue_arrow.visible = false
	
	var leave_tween = create_tween()
	leave_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	leave_tween.tween_property(dialogue_box, "position", Vector2(0, 300), .35)
	await leave_tween.finished
	
	dialogue_box.queue_free()
	dialogue_box = null
	box_actives = null
	box_textures = null

func process_events(sorted_event_list:Dictionary, key:String) -> void: ## Processes the triggering of automatic events.
	var chosen_event_list = sorted_event_list[key] # gets the list of events to trigger at this point
	
	# triggers said events
	for event in chosen_event_list:
		EventModule.process_event(event)

func trigger_event_flag(char_pos:int, event_ID:int, trigger_time:float, event_list:Array[EventData], flag_list:Dictionary) -> void: ## Processes the list of event flags and triggers them as the dialogue progresses.
	# wait until it's time to trigger the event flag
	await get_tree().create_timer(trigger_time).timeout
	
	# check if the line is still being processed and that the ID is valid
	if event_ID < event_list.size() and line_in_process:
		# get the event and process it
		var event = event_list[event_ID]
		EventModule.process_event(event)
		
		# remove flag from flag list
		flag_list.erase(char_pos)

func extract_event_flags(raw_line:String) -> Dictionary: ## Extracts any event flags from the dialogue line. Returns the cleaned up dialogue line, alongside the processed event flags in the format 'character position : ID'.
	# create results
	var flag_list := {}
	var cleaned_line := raw_line
	
	# set up regex for flag detection
	var flag_pattern := r"\[!event(\d+)\]"
	var regex = RegEx.new()
	regex.compile(flag_pattern)
	
	while true:
		# get next flag in the text
		var result := regex.search(cleaned_line)
		if result == null: break # if no flags, break and return
		
		# get flag's event ID
		var event_ID := int(result.get_string(1))
		
		# get flag's starting character position & store the flag into a list
		var char_index := result.get_start()
		flag_list[char_index] = event_ID
		
		# clean string of flag
		cleaned_line = cleaned_line.substr(0, result.get_start()) + cleaned_line.substr(result.get_end(), cleaned_line.length() - result.get_end())
	
	# return the newly created flag
	return {"cleaned_line" = cleaned_line, "event_flags" = flag_list}

func process_dialogue_line(line_info:DialogueLine) -> void: ## Processes the given dialogue line using its provided information.
	# first things first, get the global components of the dialogue box UI
	var line_text = box_actives.get_node("Line")
	var name_text = box_actives.get_node("Name")
	var continue_arrow = box_actives.get_node("Arrow")
	
	# hide continue arrow and set processing flag to true
	continue_arrow.visible = false
	line_in_process = true
	
	# create event list for the main 3 trigger conditions
	var event_list = line_info.EventList
	var auto_event_list = {
		"On Start" : [],
		"On End" : [],
		"On Continue" : [],
	}
	
	# put every automatic trigger event in the list
	for events:EventData in event_list:
		var key = events.EventTriggerCondition
		if not key in auto_event_list: continue # ignore 'None' events
		auto_event_list[key].append(events)
	
	# run on start events
	process_events(auto_event_list, "On Start")
	
	# handle character name setting
	if line_info.HideCharacterName:
		name_text.text = "???"
	else:
		name_text.text = tr(GeneralModule.get_character_known_name(line_info.Speaker))
	
	# hide the text on the label and set text color
	line_text.visible_ratio = 0
	if line_text.modulate != line_info.TextColor: # change text color
		line_text.modulate = line_info.TextColor
	
	# LOADING DONE! TIME TO PROCESS LINE
	# play sfx & voices
	if line_info.PlaySoundEffect:
		GeneralModule.play_sfx(line_info.PlaySoundEffect)
	if line_info.PlayVoiceline:
		GeneralModule.play_voiceline(line_info.PlayVoiceline)
	
	# playing and stopping music
	if line_info.MuteMusic:
		GeneralModule.stop_music(line_info.MutingSpeed)
	else:
		if line_info.PlayMusic != null:
			GeneralModule.play_music(line_info.PlayMusic)
	
	# tell character to leave the room (to add later)
	if line_info.CharacterLeaves:
		pass
	
	# process event flags and get the line without any flags
	var raw_line = line_info.Line # extract raw line
	# create holders in memory
	var dialogue_line:String
	var event_flags:Dictionary
	
	# check dialogue line for event flags & process them
	var sweep_result = extract_event_flags(raw_line)
	
	# get line cleaned of flags, and the list of flags
	dialogue_line = sweep_result["cleaned_line"]
	event_flags = sweep_result["event_flags"]
	
	# set the text to the cleaned up dialogue line!
	line_text.text = tr(dialogue_line)
	
	# just add the name and text to the dialogue logs rq...
	dialogue_logs.append(name_text.text + ": " + dialogue_line)
	# if the log amount goes over the limit, delete the oldest line
	if len(dialogue_logs) > DataStateModule.option_data.DialogueLogLimit:
		dialogue_logs.remove_at(0)
	
	# HANDLE CAMERA STUFF
	# get camera subject
	var cam_subject = null
	var subject_name = null
	
	# run basic camera subject determination
	if line_info.CameraSubject:
		subject_name = GeneralModule.get_character_name(line_info.CameraSubject)
	else:
		subject_name = GeneralModule.get_character_name(line_info.Speaker)
	cam_subject = char_group.get_node_or_null(subject_name)
	
	# if not in a trial, check if the camera subject happens to be the player character, and reset the camera subject accordingly
	if subject_name == GeneralModule.get_character_name(DataStateModule.game_data.PlayerCharacter) and not DataStateModule.game_data.StoryFlags.IsTrial:
		cam_subject = char_group.get_node_or_null("Player")
	
	# run the camera movement
	if DataStateModule.game_data.StoryFlags.IsTrial:
		var cam_movement_info = line_info.CameraMovement
		
		if cam_movement_info != null:
			CameraModule.trial_tween(cam_movement_info, cam_subject)
			await CameraModule.transition_finished
	else:
		CameraModule.dialogue_tween(cam_subject)
	
	# show text tween, if skip scrolling isn't on (because that just means skip the text scroll)
	if not line_info.SkipScrolling:
		# get the length, scroll speed & calculate total process time
		var line_length = dialogue_line.length()
		var scroll_speed = .025 - (.01 * (DataStateModule.option_data.TextScrollSpeed - 3))
		# baseline is 0.025 per character, increasing scroll speed adds +0.01 per increase, decreasing subtracts -0.01
		# meaning:
		# 1 - 0.045, 2 - 0.035, 3 - 0.025, 4 - 0.015, 5 - 0.005
		# the equation displayed was obtained through a graphical calculator to perfectly adjust to the correct speed
		
		# get total tween length
		var line_duration = scroll_speed * line_length
		
		# create text scroll tween and run it
		var line_tween = create_tween().set_parallel(true)
		current_scroll_tween = line_tween
		line_tween.set_trans(Tween.TRANS_LINEAR)
		line_tween.tween_property(line_text, "visible_ratio", 1, line_duration)
		
		# trigger event flag events on the correct time
		for char_pos in event_flags.keys():
			var event_ID = event_flags[char_pos]
			var trigger_time = char_pos * scroll_speed
			
			trigger_event_flag(char_pos, event_ID, trigger_time, line_info.EventList, event_flags)
		
		await line_tween.finished
		
		# trigger any untriggered flags, if dialogue was skipped
		for time_pos in event_flags.keys():
			var event_id = event_flags[time_pos]
			if event_id < line_info.EventList.size():
				var event = line_info.EventList[event_id]
				EventModule.process_event(event)
	
	# finish the line & set it to the end result
	line_text.visible_ratio = 1
	line_in_process = false
	continue_arrow.visible = true
	
	# if event is at the end, process it now
	process_events(auto_event_list, "On End")
	
	# turn on autoscroll timer
	if DataStateModule.option_data.Autoscroll:
		autoscroll()
	
	# wait for continuation signal
	await continue_dialogue_signal
	
	# if event is after continuing, process it now
	process_events(auto_event_list, "On Continue")

func determine_line_start(start_point_dict:Dictionary[String, int]) -> int: ## Given a certain start point dictionary, returns whether the array should be read in full or from the start provided in the start point dictionary.
	var start = 0
	if start_point_dict.has("line"):
		start = start_point_dict["line"]
	
	return start

func read_dialogue_array(array_data:DialogueArray, line_start:int) -> void: ## Iterates through a given dialogue array.
	var dialogue_array = array_data.dialogue_array
	
	# iterate through every dialogue line in the dialogue array and process it in order
	for i in range(line_start, dialogue_array.size(), 1):
		var dialogue_line = dialogue_array[i]
		await process_dialogue_line(dialogue_line)

func read_dialogue_tree(tree_data:DialogueTree, start_point_dict:Dictionary[String, int]) -> void: ## Iterates through a given dialogue tree.
	var dialogue_tree = tree_data.dialogue_tree # get dialogue tree
	var loop_tree = tree_data.loop_tree # get loop value
	
	# set array tracker to start point["array"]
	if start_point_dict.has("array"):
		tree_data.array_tracker = start_point_dict["array"]
	
	# get selected dialogue array to iterate
	var array_data = dialogue_tree[tree_data.array_tracker]
	
	# determine start point
	var line_start = determine_line_start(start_point_dict)
	await read_dialogue_array(array_data, line_start) # read dialogue array
	
	#handle array tracker logic
	#if the array tracker is not at the last array of the tree, increment it
	#if the array tracker is at the last array of the tree, set it to 0 if looping is enabled, do nothing if looping is disabled
	if tree_data.array_tracker < dialogue_tree.size() - 1:
		tree_data.array_tracker += 1
	else:
		if loop_tree == true:
			tree_data.array_tracker = 0

func read_dialogue(dialogue_data:Variant, start_point_dict:Dictionary[String, int]): ## Read through the provided dialogue. Handles both trees & arrays.
	# prevent two dialogues from being read at once
	if reading_in_progress: return
	reading_in_progress = true
	
	# lock player interaction if they exist
	var player:PlayerOverworld = char_group.get_node_or_null("Player")
	if player:
		player.update_locks(false)
	
	# load dialogue box (to do for later, provisory function)
	await load_dialogue_box("DialogueBox")
	
	# switch camera mode to the appropriate mode
	if DataStateModule.game_data.StoryFlags.IsTrial:
		CameraModule.set_mode(CameraModule.CameraModes.TRIAL)
	else:
		CameraModule.set_mode(CameraModule.CameraModes.DIALOGUE)
	
	# detect the kind of dialogue to read & process it
	if dialogue_data is DialogueArray:
		# determine start point
		var line_start = determine_line_start(start_point_dict)
		await read_dialogue_array(dialogue_data, line_start)
	elif dialogue_data is DialogueTree:
		await read_dialogue_tree(dialogue_data, start_point_dict)
	reading_in_progress = false
	
	# cleanup tween refs
	current_scroll_tween = null
	current_autoscroll_tween = null
	
	# unload dialogue box
	await unload_dialogue_box()
	
	# unlock player & make camera follow them back again if they exist
	if player != null and not DataStateModule.game_data.StoryFlags.IsTrial:
		CameraModule.set_mode(CameraModule.CameraModes.FOLLOW_PLAYER)
		player.update_locks(true)
		player = null

func _ready() -> void:
	ServiceLocator.register_service("DialogueModule", self) # registers module in service locator automatically
