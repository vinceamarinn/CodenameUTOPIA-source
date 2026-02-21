extends Button

## temp basic test script that lets you save the game with a button

func _on_pressed() -> void:
	var err = DataStateModule.save_data(DataStateModule.game_data)
	print("successfully saved game? ->", err)
	
	var err2 = DataStateModule.save_data(DataStateModule.option_data)
	print("successfully saved game? ->", err2)
