class_name DataManager

const DIR := "user://data/"
static var EXT := ".dat"


## Global encryption key used for secure storage.
static var encryption_key: String = ""


## Saves [param data] to a file with atomic write + optional encryption.
## Returns true on success.
static func save(filename: String, data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(DIR)
	var path := DIR.path_join(filename + EXT)
	var tmp := path + ".tmp"

	var file: FileAccess
	var payload := data.duplicate(true)

	# Open file with or without encryption from the start
	if not encryption_key.is_empty():
		file = FileAccess.open_encrypted_with_pass(tmp, FileAccess.WRITE, encryption_key)
	else:
		file = FileAccess.open(tmp, FileAccess.WRITE)

	if not file:
		push_error("DataManager: Failed to open temp file for writing: " + path)
		return false

	# Store variable with compression enabled (true)
	file.store_var(payload, true)
	file.close()

	# Atomic rename to final path
	if DirAccess.rename_absolute(tmp, path) != OK:
		push_error("DataManager: Failed to rename temp file to final location: " + tmp + " -> " + path)
		return false

	return true


## Loads data from [param filename]. Returns empty dictionary if missing,
## corrupted, or of wrong type.
static func load(filename: String) -> Dictionary:
	var path := DIR.path_join(filename + EXT)
	if not FileAccess.file_exists(path):
		push_warning("DataManager: File does not exist: " + path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DataManager: Failed to open file for reading: " + path)
		return {}

	# Try encrypted first if key is set
	if not encryption_key.is_empty():
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_key)
		if not file:
			push_warning("DataManager: Decryption failed for " + filename + ", falling back to unencrypted read")
			file = FileAccess.open(path, FileAccess.READ) # fallback

	var data = file.get_var(true)
	if not data is Dictionary:
		push_warning("DataManager: Loaded data is not a dictionary: " + path)
		return {}

	return data


## Returns list of save basenames without file extensions.
static func list_saves() -> Array[String]:
	var dir := DirAccess.open(DIR)
	if not dir:
		push_error("DataManager: Failed to open directory: " + DIR)
		return []

	return Array(dir.get_files()).filter(func(f): return f.ends_with(EXT)).map(func(f): return f.get_basename())


## Deletes the save file associated with [param filename].
static func delete(filename: String) -> bool:
	var path := DIR.path_join(filename + EXT)
	if not FileAccess.file_exists(path):
		push_warning("DataManager: File does not exist to delete: " + path)
		return false

	if DirAccess.remove_absolute(path) != OK:
		push_error("DataManager: Failed to delete file: " + path)
		return false

	return true


## Returns true if the save file exists.
static func exists(filename: String) -> bool:
	var path := DIR.path_join(filename + EXT)
	return FileAccess.file_exists(path)


## Returns the basename of the most recently modified save file.
static func get_latest() -> String:
	var files := list_saves()
	if files.is_empty(): return ""

	var latest := ""
	var max_time := -1

	for f in files:
		var full := DIR.path_join(f + EXT)
		var t := FileAccess.get_modified_time(full)
		if t > max_time:
			max_time = t
			latest = f

	return latest
