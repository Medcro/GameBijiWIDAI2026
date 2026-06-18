extends Panel
@onready var audio_tab: VBoxContainer = $audioTab
@onready var control_tab: VBoxContainer = $controlTab


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	control_tab.hide()
	audio_tab.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	hide()

func _on_apply_pressed() -> void:
	# masukin buat save config gitu2
	hide()

func _on_audio_set_pressed() -> void:
	audio_tab.show()
	control_tab.hide()

func _on_control_set_pressed() -> void:
	control_tab.show()
	audio_tab.hide()
