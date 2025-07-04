extends Node3D
class_name Character

@export var known_name:String ## Name that shows up in the dialogue boxes.
@onready var frontSprite = $Sprite
@onready var backSprite = $BackSprite

func change_sprite(sprite):
	print("my sprite is supposed to change here LOL")

func leave_room():
	var fade_timer:float = 1.25
	await get_tree().create_timer(.5).timeout
	
	for curr_sprite in self.get_children():
		if not curr_sprite is AnimatedSprite3D: continue
		
		var transp_tween = create_tween()
		transp_tween.tween_property(curr_sprite, "modulate:a", 0, fade_timer).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		transp_tween.play()
	
	await get_tree().create_timer(fade_timer + .5).timeout
	self.queue_free()
