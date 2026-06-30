extends Panel
@onready var audio_tab: MarginContainer = $VBoxContainer/MarginContainer
@onready var control_tab: Control = $VBoxContainer/controlTab
@onready var master_slider: HSlider = $VBoxContainer/MarginContainer/audioTab/MasterSlider
@onready var music_slider: HSlider = $VBoxContainer/MarginContainer/audioTab/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/MarginContainer/audioTab/SFXSlider

@export var styleBoxEmpty: StyleBoxEmpty = preload("res://assets/UI/styleboxEmpty.tres")
@export var styleBoxNotPressed: StyleBoxFlat = preload("res://assets/UI/styleboxNotPressed.tres")

var masterVol
var musicVol
var sfxVol 	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	control_tab.hide()
	audio_tab.show()
	
	master_slider.value = ConfigHandler.config.get_value("audio", "master", 0.5)
	music_slider.value = ConfigHandler.config.get_value("audio", "music", 0.5)
	sfx_slider.value = ConfigHandler.config.get_value("audio", "sfx", 0.5)

func _on_back_pressed() -> void:
	$"../Click".play()
	hide()

func _on_apply_pressed() -> void:
	$"../Click".play()
	# masukin buat save config gitu2
	masterVol = master_slider.value
	musicVol = music_slider.value
	sfxVol = sfx_slider.value
	ConfigHandler.config.set_value("audio", "master", masterVol)
	ConfigHandler.config.set_value("audio", "music", musicVol)
	ConfigHandler.config.set_value("audio", "sfx", sfxVol)
	
	for action in ControlSettings.input_actions.keys():
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigHandler.config.set_value("keybinding", action, events[0])
	
	ConfigHandler.config.save(ConfigHandler.SETTINGS_FILE_PATH)
	hide()

func _on_audio_set_pressed() -> void:
	$"../Click".play()
	audio_tab.show()
	control_tab.hide()
	$"VBoxContainer/tabButtons/Audio set".add_theme_stylebox_override("normal", styleBoxEmpty) 
	$"VBoxContainer/tabButtons/control set".add_theme_stylebox_override("normal", styleBoxNotPressed)

func _on_control_set_pressed() -> void:
	$"../Click".play()
	control_tab.show()
	audio_tab.hide()
	$"VBoxContainer/tabButtons/control set".add_theme_stylebox_override("normal", styleBoxEmpty) 
	$"VBoxContainer/tabButtons/Audio set".add_theme_stylebox_override("normal", styleBoxNotPressed)
