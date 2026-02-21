extends CharacterBody3D
class_name PlayerOverworld

@onready var anim_player = $Sprite

const SPEED = 7.5
@export var can_move:bool = false
@export var can_interact:bool = false

func update_movement(value:bool) -> void: ## Updates the player's movement lock based on the value.
	can_move = value

func update_interact(value:bool) -> void:## Updates the player's interaction lock based on the value.
	can_interact = value

func update_locks(value:bool) -> void: ## Updates both the player's movement and interaction locks based on the value.
	can_move = value
	can_interact = value

func _physics_process(delta: float) -> void:
	# Add the gravity.wa
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not can_move: 
		anim_player.play("idle")
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# 1,0,0 = right
		# 0,0,1 = down
		# 0,0,-1 = up
		# -1,0,0 = left
		
		# animation player
		if direction.x != 0:
			anim_player.play("moveSides")
			anim_player.flip_h = (direction.x < 0) # flip if going left, don't flip otherwise
		else:
			if direction.z > 0:
				anim_player.play("moveDown")
			elif direction.z < 0:
				anim_player.play("moveUp")
	else:
		anim_player.play("idle") # stop playing moving animations
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
