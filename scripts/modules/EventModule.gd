extends Node
@onready var UI = get_node("/root/GameMain/UI")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")


func process_event(event:EventData): ## Processes the provided event.
	var event_id = event.event_type
	var event_data = event.event_data
	
	var event_type:String = GeneralModule.get_enum_string(EventData.EventType, event_id)
	
	match event_type:
		pass
	
	print("hello! i am an EVENT!")
	print("my name is: ", event_type, " with the id: ", event_id)
	print("my data is: ", event_data)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServiceLocator.register_service("EventModule", self) # registers module in service locator automatically
