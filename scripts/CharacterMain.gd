extends Node3D
class_name Character

@export var known_name:String ## Name that shows up in the dialogue boxes.
@onready var front_sprite = $Sprite
@onready var back_sprite = $BackSprite

#just so i dont have to keep writing it
@onready var game_data = DataStateModule.game_data

func change_sprite(sprite) -> void:
	pass

func leave_area() -> void:
	var fade_timer:float = 1.25
	await get_tree().create_timer(.5).timeout
	
	for curr_sprite in self.get_children():
		if not curr_sprite is AnimatedSprite3D: continue
		
		var transp_tween = create_tween()
		transp_tween.tween_property(curr_sprite, "modulate:a", 0, fade_timer).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		transp_tween.play()
	
	await get_tree().create_timer(fade_timer + .5).timeout
	game_data.RemovedCharacters[game_data.CurrentMap].append(self.name)
	self.queue_free()

func _ready() -> void:
	var name_list = GeneralModule.known_name_list
	known_name = name_list[GeneralModule.get_character_ID(self.name)]
