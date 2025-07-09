extends Node

@onready var UI = get_node("/root/GameMain/UI")
@onready var transition = get_node("/root/GameMain/UI/Transition")

signal transition_ended

func trans(in_out:String, time:float, color:Color, tween_color:bool) -> void: ## Basic transition tween. Supports fading in, fading out and even color changing.
	if transition.visible == false: transition.visible = true # make transition visible if it's not visible already
	
	var goal_table = {
		"in": 1,
		"out": 0,
		"none": transition.modulate.a
	}
	
	#get end goal, set end goal color immediately
	var end_goal = Color(color, goal_table.get(in_out, 0))
	
	if tween_color == false: # set color immediately if tween is not required
		transition.modulate = Color(color, goal_table["none"])
	
	#make the tween, set transition types yadda yadda
	var trans_tween = create_tween().set_parallel(true)
	trans_tween.set_ease(Tween.EASE_IN)
	trans_tween.set_trans(Tween.TRANS_QUAD)
	
	trans_tween.tween_property(transition, "modulate", end_goal, time)
	await trans_tween.finished
	emit_signal("transition_ended")

func remove_ui_element(ui_element) -> void:
	pass

func add_ui_element(ui_element) -> void:
	pass

func _ready() -> void:
	# initialize transition UI
	transition.visible = false
	transition.modulate.a = 0
	ServiceLocator.register_service("UIModule", self) # registers module in service locator automatically
