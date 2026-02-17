extends Node
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")

#region General category events

func print_text(event_data:Dictionary) -> void: ## Prints the provided text message in the console.
	var message = event_data.get("text")
	print(message)

#endregion

#region Area category events

func load_area(event_data:Dictionary) -> void: ## Loads the provided area according to current state and character.
	var area_name = event_data.get("area")
	var state_name = DataStateModule.get_chapter_state_name()
	AreaModule.load_area(area_name, state_name, true, true, false)

#endregion

#region Dialogue category events

func read_dialogue(event_data:Dictionary) -> void: ## Reads the provided dialogue array/tree.
	var dialogue_data = event_data.get("dialogue")
	DialogueModule.read_dialogue(dialogue_data, {})

#endregion

#region Audio category events

func play_music(event_data:Dictionary) -> void: ## Plays the provided song.
	var music = event_data.get("music")
	GeneralModule.play_music(music)

func stop_music(event_data:Dictionary) -> void: ## Stops the currently playing song.
	var speed = event_data.get("speed")
	GeneralModule.stop_music(speed)

func play_sfx(event_data:Dictionary) -> void: ## Plays the provided sound effect.
	var sfx = event_data.get("sfx")
	GeneralModule.play_sfx(sfx)

func play_voiceline(event_data:Dictionary) -> void: ## Plays the provided voiceline.
	var voiceline = event_data.get("voiceline")
	GeneralModule.play_sfx(voiceline)

#endregion

#region Trial events

func start_trial(event_data:Dictionary): ## Calls the Data/State Module to begin the provided trial. If the trial number is '0', it will automatically load the trial of the current chapter instead of a specific one.
	var trial_ID = event_data.get("trial_ID")
	DataStateModule.start_trial(trial_ID)

#endregion

func process_event(event:EventData): ## Processes the provided event.
	# get event stuff
	var event_id = event.event_type
	var event_data = event.event_data
	
	# remove category prefix
	var event_type:String = GeneralModule.get_enum_string(EventData.EventType, event_id)
	var underscore_index := event_type.find("_")
	if underscore_index != -1:
		event_type = event_type.substr(underscore_index + 1)
	
	# find if function bound to event exists, and then call it
	var func_name = event_type.to_lower()
	if has_method(func_name):
		call(func_name, event_data)
	else:
		push_error("[ERROR] Event function '", func_name, "' not found in event module!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServiceLocator.register_service("EventModule", self) # registers module in service locator automatically
