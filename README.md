# Godot 4 Data Management Utility (`DataManager`)

A robust, high-performance, and atomic data persistence utility for Godot 4. Designed with static methods for clean global access (`DataManager.save("slot_1", data)`), it features atomic write safeguards against save corruption, built-in variable compression, optional encryption, and file management helpers.

---

## ✨ Features

* **Global Static API:** Clean, intuitive syntax accessible from anywhere in your project without needing references or instantiation.
* **Atomic Writes:** Writes saves to a temporary file (`.tmp`) first before safely renaming them to the final path, completely protecting players against save file corruption if the game crashes or loses power mid-save.
* **Optional Encryption:** Seamlessly supports password-encrypted saves via `encryption_key`, with fallback handling for unencrypted or legacy saves.
* **Built-in Compression:** Automatically compresses stored variables using Godot's built-in serialization compression.
* **Fully Decoupled:** Operates as a self-contained module with zero hard dependencies on external singletons or custom utilities.
* **Comprehensive File Management:** Includes helper utilities to list save slots, delete files, check existence, and automatically find the most recently modified save.

---

## 📦 Installation & Setup

1. Create a folder in your project directory (e.g., `res://scripts/utils/`).
2. Add the core script file: `data_manager.gd`.

---

## 🚀 Usage Guide

### 1. Saving and Loading Data

Call the data manager globally using a save filename (without extension) and a `Dictionary` payload:

```gdscript
# Prepare your save data
var player_data := {
	"level": 3,
	"health": 85.5,
	"inventory": ["sword", "shield", "potion"]
}

# Save data atomically to user://data/save_slot_1.dat
if DataManager.save("save_slot_1", player_data):
	print("Game saved successfully!")

# Load data back (returns an empty dictionary if missing or corrupted)
var loaded_data = DataManager.load("save_slot_1")
if not loaded_data.is_empty():
	print("Loaded player level: %d" % loaded_data.level)

```

### 2. Enabling Encryption

You can globally secure your save files by assigning a password string to `encryption_key` before saving or loading:

```gdscript
func _ready() -> void:
	DataManager.encryption_key = "super_secret_game_password_123"

```

### 3. Managing Save Files

Easily query your directory for existing save slots or cleanup old files:

```gdscript
# Get an array of all save basenames (e.g., ["save_slot_1", "autosave"])
var saves := DataManager.list_saves()

# Check if a specific save file exists
if DataManager.exists("save_slot_1"):
	print("Save slot 1 exists.")

# Find the most recently modified save file
var latest_save := DataManager.get_latest()
print("Resuming latest save: %s" % latest_save)

# Delete a save file
DataManager.delete("save_slot_1")

```

---

## 📚 Script Reference

### `DataManager.gd`

The global static data persistence utility class.

| Property / Constant | Type | Default | Description |
| --- | --- | --- | --- |
| `DIR` | `String` | `"user://data/"` | The root directory where data files are stored. |
| `EXT` | `String` | `".dat"` | The standard file extension appended to save files. |
| `encryption_key` | `String` | `""` | Optional global encryption password used for secure storage. |

| Method | Description |
| --- | --- |
| `DataManager.save(filename, data)` | Atomically saves a dictionary to disk with compression and optional encryption. Returns `true` on success. |
| `DataManager.load(filename)` | Loads and decodes data from disk. Returns an empty dictionary if missing or corrupted. |
| `DataManager.list_saves()` | Returns an array of strings containing all save basenames without extensions. |
| `DataManager.delete(filename)` | Deletes a specified save file. Returns `true` on success. |
| `DataManager.exists(filename)` | Returns `true` if the given save file exists on disk. |
| `DataManager.get_latest()` | Returns the basename of the most recently modified save file. |

---

## 📝 License

Distributed under the MIT License. Feel free to use this in your own personal or commercial Godot projects.