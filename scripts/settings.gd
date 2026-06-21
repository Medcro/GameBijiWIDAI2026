extends Panel
@onready var audio_tab: VBoxContainer = $audioTab
@onready var control_tab: Control = $controlTab
@onready var master_slider: HSlider = $audioTab/MasterSlider
@onready var music_slider: HSlider = $audioTab/MusicSlider
@onready var sfx_slider: HSlider = $audioTab/SFXSlider

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
	hide()

func _on_apply_pressed() -> void:
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
	
	hide()

func _on_audio_set_pressed() -> void:
	audio_tab.show()
	control_tab.hide()

func _on_control_set_pressed() -> void:
	control_tab.show()
	audio_tab.hide()
