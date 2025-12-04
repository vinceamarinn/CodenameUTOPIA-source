extends Node
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")

func process_event(event:EventData): ## Processes the provided event.
	var event_id = event.event_type
	var event_data = event.event_data
	
	var event_type:String = GeneralModule.get_enum_string(EventData.EventType, event_id)
	var underscore_index := event_type.find("_")
	if underscore_index != -1:
		event_type = event_type.substr(underscore_index + 1)
	
	match event_type:
		"READ_DIALOGUE":
			var dialogue_data = event_data.get("dialogue")
			DialogueModule.read_dialogue(dialogue_data)
		"LOAD_AREA":
			var area_name = event_data.get("area")
			var state_name = DataStateModule.get_chapter_state_name()
			var playable_char = DataStateModule.game_data.PlayerCharacter
			AreaModule.load_area(area_name, state_name, playable_char)
		"PRINT_TEXT":
			var print_text = event_data.get("text")
			print(print_text)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServiceLocator.register_service("EventModule", self) # registers module in service locator automatically
