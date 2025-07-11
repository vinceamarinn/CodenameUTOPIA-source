@tool
extends EditorPlugin

# Make sure these are created in the same order for the index to be correct:
enum Menu {GENERATE, AUTO_GEN_ON_SAVE, OPTIONS, GITHUB, DOCUMENTATION, TUTORIAL_VIDEO}
const OPTIONS_DIRECTORY = "res://addons/string_keys/.options"
const OPTIONS_FILE_PATH = OPTIONS_DIRECTORY + "/string_keys_options.tres"

var _menu_button: MenuButton
var _popup_menu: PopupMenu
var _options: StringKeysOptions

func _enter_tree():
	_menu_button = MenuButton.new()
	_menu_button.text = "StringKeys"
	
	_popup_menu = _menu_button.get_popup()
	_popup_menu.add_item("Generate Translation File")
	_popup_menu.add_check_item("Auto On Save")
	_popup_menu.add_item("Options")
	_popup_menu.add_item("GitHub")
	_popup_menu.add_item("Documentation")
	_popup_menu.add_item("Tutorial Video")
	
	_popup_menu.connect("index_pressed", Callable(self, "on_menu_item_pressed"))
	add_control_to_container(CONTAINER_TOOLBAR, _menu_button)
	_menu_button.get_parent().move_child(_menu_button, 1)
	
	_load_personal_options()
	connect("resource_saved", Callable(self, "auto_gen_on_save"))


func _exit_tree():
	_save_personal_options()
	remove_control_from_container(CONTAINER_TOOLBAR, _menu_button)
	if _options:
		ResourceSaver.save(_options, OPTIONS_FILE_PATH)


func on_menu_item_pressed(i: int):
	if i == Menu.GENERATE:
		generate_translation_file()
	
	elif i == Menu.AUTO_GEN_ON_SAVE:
		_popup_menu.toggle_item_checked(Menu.AUTO_GEN_ON_SAVE)
	
	elif i == Menu.OPTIONS:
		var options:= get_options()
		# options having a ref to the inspector allows it to interactively correct mistakes
		options.editor_inspector = get_editor_interface().get_inspector()
		get_editor_interface().inspect_object(options)
	
	elif i == Menu.GITHUB:
		OS.shell_open("https://github.com/mrtripie/godot-string-keys")
	
	elif i == Menu.DOCUMENTATION:
		OS.shell_open("https://docs.google.com/document/d/176WFKE-2SxA0uWEDP7c8vInO8wChC54EQKv-6F_xb8M/edit?usp=sharing")
	
	elif i == Menu.TUTORIAL_VIDEO:
		OS.shell_open("https://youtu.be/DUSQimX77qE")


func auto_gen_on_save(_resource: Resource):
	if _popup_menu.is_item_checked(Menu.AUTO_GEN_ON_SAVE):
		# resource_saved signal is BEFORE the save, waiting until the filesystem has changed
		# makes it run after the save. Just using the filesystem_changed signal alone wouldn't
		# work because when it changes the csv file, making it run again
		await get_editor_interface().get_resource_filesystem().filesystem_changed
		print("Running StringKeys on save")
		generate_translation_file()


func generate_translation_file():
	if _options:
		ResourceSaver.save(_options, OPTIONS_FILE_PATH)
	StringKeys.new().generate_translation_file(get_options())
	get_editor_interface().get_resource_filesystem().scan() # Triggers reimport of csv file


func get_options() -> StringKeysOptions:
	if _options:
		return _options
	if not FileAccess.file_exists(OPTIONS_FILE_PATH): 
		if not DirAccess.dir_exists_absolute(OPTIONS_DIRECTORY):
			DirAccess.make_dir_recursive_absolute(OPTIONS_DIRECTORY)
		ResourceSaver.save(StringKeysOptions.new(), OPTIONS_FILE_PATH)
	_options = load(OPTIONS_FILE_PATH)
	return _options


# certain options may be best to have saved personally, outside the project res folder
# (just auto_gen_on_save currently, as it will hurt performance for teammates not working
# on text that needs to be immediately translated (to get rid of any context info in text) 
func _save_personal_options():
	var file = FileAccess.open("user://string_keys_personal_options.skpo", FileAccess.WRITE)
	if file != null:
		file.store_var(_popup_menu.is_item_checked(Menu.AUTO_GEN_ON_SAVE))
		file.close()


func _load_personal_options():
	if FileAccess.file_exists("user://string_keys_personal_options.skpo"):
		var file = FileAccess.open("user://string_keys_personal_options.skpo", FileAccess.READ)
		if file != null:
			_popup_menu.set_item_checked(Menu.AUTO_GEN_ON_SAVE, file.get_var())
			file.close()
