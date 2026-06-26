extends Node

@onready var keybind_resource : ControlSettings = preload("res://resource/PlayerKeyBind.tres")

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://Settings.cfg"

func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding", keybind_resource.MOVE_LEFT, keybind_resource.default_left)
		config.set_value("keybinding", keybind_resource.MOVE_RIGHT, keybind_resource.default_right)
		config.set_value("keybinding", keybind_resource.MOVE_DOWN, keybind_resource.default_down)
		config.set_value("keybinding", keybind_resource.JUMP, keybind_resource.default_jump)
		config.set_value("keybinding", keybind_resource.MELEE, keybind_resource.default_melee)
		config.set_value("keybinding", keybind_resource.RANGED, keybind_resource.default_ranged)
		config.set_value("keybinding", keybind_resource.HEAL, keybind_resource.default_heal)
		config.set_value("keybinding", keybind_resource.SP1, keybind_resource.default_sp1)
		config.set_value("keybinding", keybind_resource.SP2, keybind_resource.default_sp2)
		config.set_value("keybinding", keybind_resource.PARRY, keybind_resource.default_parry)
		config.set_value("keybinding", keybind_resource.DASH, keybind_resource.default_dash)
		
		config.set_value("audio", "master", 0.5)
		config.set_value("audio", "music", 0.5)
		config.set_value("audio", "sfx", 0.5)
		config.save(SETTINGS_FILE_PATH)
	else:
		# Jika file ada, load datanya
		config.load(SETTINGS_FILE_PATH)
		
	# Terapkan input dari ConfigFile yang sudah di-load ke InputMap
	apply_keybinds_to_inputmap()

func apply_keybinds_to_inputmap():
	# Loop untuk setiap action yang ada di dictionary input_actions [cite: 3]
	for action in ControlSettings.input_actions.keys():
		# Ambil event InputEventKey dari config file
		var saved_event = config.get_value("keybinding", action, null)
		
		if saved_event != null:
			# Bersihkan event bawaan Godot dan masukkan yang dari file Save
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, saved_event)
