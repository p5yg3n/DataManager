# Godot 4 Data Manager

A robust, secure, and thread-safe data management utility for Godot 4. This static helper class handles saving, loading, listing, and deleting game save files with built-in **atomic writes** (to prevent corruption during crashes) and **optional file encryption**.

## Features

* **Atomic File Writes:** Writes data to a temporary `.tmp` file first and swaps it atomically on completion, ensuring players never get stuck with a broken 0-byte save file.
* **Optional AES Encryption:** Secures save files using Godot's built-in password encryption (`FileAccess.open_encrypted_with_pass`).
* **Built-in Compression:** Automatically compresses variable payloads to keep save file sizes lightweight.
* **Graceful Fallbacks:** `load()` automatically attempts decryption if a key is provided, with a safe fallback reader for backward compatibility.
* **Handy Utilities:** Built-in helper methods to list all active saves, check existence, delete files, and instantly query the most recently modified save slot.


## Installation & Setup

1. Place `DataManager.gd` into your project scripts folder (e.g., `res://scripts/core/DataManager.gd`).
2. Because it uses static methods and acts as a global utility, you can call its methods directly from anywhere in your project without needing an Autoload singleton instance (though you can register it as one if preferred).


## Usage Guide

### 1. Setting an Encryption Key (Optional)
If you want to encrypt your save files, set the static `encryption_key` property early in your game's lifecycle (such as in your main menu or global game singleton):

```func _ready() -> void:
	DataManager.encryption_key = "your_secure_password_here"

```

### 2. Saving Data

Pass a string identifier (the save name without extension) and a `Dictionary` payload:

```func save_player_game() -> void:
	var player_data: Dictionary = {
		"health": 100,
		"score": 1450,
		"position": Vector2(250, 400)
	}
	
	var success := DataManager.save("slot_1", player_data)
	if success:
		print("Game saved successfully!")

```

### 3. Loading Data

Load the dictionary back. If the file is missing, corrupted, or not a dictionary, it safely returns an empty dictionary `{}`.

```func load_player_game() -> void:
	var data := DataManager.load("slot_1")
	if data.is_empty():
		return # No save found or error occurred
		
	print("Loaded score: ", data.get("score", 0))

```

### 4. Managing Saves

```gdscript
# Get an array of all save basenames (e.g., ["slot_1", "slot_2"])
var all_saves := DataManager.list_saves()

# Find the most recently modified save file name
var latest_save := DataManager.get_latest()

# Check if a specific save exists
if DataManager.exists("slot_1"):
	print("Save slot 1 exists.")

# Delete a save file
DataManager.delete("slot_1")

```


## Script Reference

### Constants & Variables

| Property | Type | Description |
| --- | --- | --- |
| `DIR` | `String` | Target save directory (defaults to `"user://data/"`). |
| `EXT` | `String` | File extension used for save files (`".dat"`). |
| `encryption_key` | `String` | Global static password string used for encryption and decryption. |

### Static Methods

| Method | Return Type | Description |
| --- | --- | --- |
| `save(filename, data)` | `bool` | Writes a dictionary atomically with optional compression and encryption. |
| `load(filename)` | `Dictionary` | Reads and returns save data, handling decryption and type validation. |
| `list_saves()` | `Array[String]` | Returns an array of all save file names (without extensions). |
| `delete(filename)` | `bool` | Deletes the specified save file. |
| `exists(filename)` | `bool` | Returns `true` if the save file exists on disk. |
| `get_latest()` | `String` | Returns the basename of the most recently modified save file. |


## License

Distributed under the MIT License. Feel free to use and adapt this system for your Godot projects.
