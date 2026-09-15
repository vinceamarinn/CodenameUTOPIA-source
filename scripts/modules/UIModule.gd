extends Node

##### UI MODULE #####
# Handles everything related to loading UI assets & 2D environments.

# game tree goodies
@onready var UI = get_node("/root/GameMain/UI")
@onready var transition = get_node("/root/GameMain/UI/Transition")

# variables
var loading_screen:Minigame = null ## Stores a reference to the loading screen minigame, so it can be deleted later.

# signals
signal transition_ended ## Fires whenever a transition tween finishes.

func trans(in_out:String, time:float, color:Color, tween_color:bool) -> void: ## Basic transition tween. Supports fading in, fading out and even color changing.
	if transition.visible == false: transition.visible = true # make transition visible if it's not visible already
	
	var goal_table = {
		"in": 1,
		"out": 0,
		"none": transition.modulate.a
	}
	
	#get end goal, set end goal color immediately
	var end_goal = Color(color, goal_table.get(in_out, 0))
	
	# check if we're already at the endpoint, in which case just immediately return and say it finished
	if transition.modulate.is_equal_approx(end_goal):
		emit_signal("transition_ended")
		return
	
	if tween_color == false: # set color immediately if tween is not required
		transition.modulate = Color(color, goal_table["none"])
	
	#make the tween, set transition types yadda yadda
	var trans_tween = create_tween().set_parallel(true)
	trans_tween.set_ease(Tween.EASE_IN)
	trans_tween.set_trans(Tween.TRANS_QUAD)
	
	trans_tween.tween_property(transition, "modulate", end_goal, time)
	await trans_tween.finished
	emit_signal("transition_ended")

func loading_in(fade_time:float) -> void: ## Causes the loading screen to fade in, and loads the loading screen minigame.
	await trans("in", fade_time, Color.BLACK, false)
	
	loading_screen = GeneralModule.load_minigame("minigames/LoadingScreens.gd", UI)
	loading_screen.init({})

func loading_out(fade_time:float) -> void: ## Causes the loading screen to fade out, and destroys the loading screen minigame.
	loading_screen.end()
	loading_screen = null
	
	trans("out", fade_time, Color.BLACK, false)

func remove_ui_element(ui_element) -> void:
	pass

func add_ui_element(ui_element) -> void:
	pass

func _ready() -> void:
	# initialize transition UI
	transition.visible = false
	transition.modulate.a = 0
