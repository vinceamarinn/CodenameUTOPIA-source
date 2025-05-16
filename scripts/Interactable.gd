extends Area3D

@export_enum("ON_INTERACT", "ON_TOUCH") var interactable_type:String = "ON_INTERACT"

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	print(body.name, " entered interaction range")
	
	if interactable_type == "ON_TOUCH":
		print("should trigger interaction event")
	elif interactable_type == "ON_INTERACT":
		print("should create popup to trigger event on interaction")

func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	print(body.name, " left interaction range")
	
	if interactable_type == "ON_TOUCH":
		print("uhhhhhg")
	elif interactable_type == "ON_INTERACT":
		print("should destroy popup")
