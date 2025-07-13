extends Button



func _on_pressed() -> void:
	var err = DataStateModule.save_data(DataStateModule.game_data)
	print("successfully saved game? ->", err)
