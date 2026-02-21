class_name StringKeys
extends RefCounted

const FILE_MOD_STATE_PATH = "user://string_keys_modification_state.skms"

var _files_to_search:= []
var _file_hashes:= {} # used to check if a file is modified
var _keys_by_file:= {} # keys grouped by source file path
var _removed_keys:= []

func generate_translation_file(options: StringKeysOptions):
	if not _is_translation_file_path_valid(options.translation_file):
		print("\nStringKeys ERROR: translation file path invalid")
		return
	
	var file_finder:= SkFileFinder.new("res://", options.file_types_to_search, options.directories_to_ignore)
	_files_to_search = file_finder.find_files()
	
	var modified_file_tracker:= SkModifiedFileTracker.new(FILE_MOD_STATE_PATH)
	modified_file_tracker.check_for_modifications(_files_to_search)
	if options.modified_files_only:
		_files_to_search = modified_file_tracker.modified_files
	
	var key_finder:= SkKeyFinder.new(options.require_tag, options.tag_seperator)
	key_finder.compile_patterns(options.patterns_to_search)
	_keys_by_file = key_finder.get_keys_in_files(_files_to_search)
	
	# Flatten for debug output and empty-check
	var all_keys:= []
	for file_path in _keys_by_file:
		for key in _keys_by_file[file_path]:
			if not all_keys.has(key):
				all_keys.append(key)
	
	if options.print_debug_output:
		print("\nStringKeys files searched", " (modified only): " if options.modified_files_only else ": ", _files_to_search)
		print("\nStringKeys keys found by file: ", _keys_by_file)
	
	if all_keys.size() > 0 or options.remove_unused:
		var csv_writer:= SkCsvWriter.new(options.translation_file, options.tag_seperator)
		csv_writer.read_old_csv_file()
		csv_writer.write_keys_to_csv_file(_keys_by_file, options.locales, options.remove_unused)
		if csv_writer.write_successful:
			modified_file_tracker.save_modification_state() # Only run this if there were no errors, otherwise file will be incorrect
			if options.remove_unused and options.print_debug_output:
				print("\nStringKeys removed keys: ", csv_writer.removed_keys)
			print("\nStringKeys successful")
	else:
		modified_file_tracker.save_modification_state()
		print("StringKeys no changes to add")


func _is_translation_file_path_valid(path: String) -> bool:
	return path.get_file() != "" and path.ends_with(".csv")
