extends Control
@onready var settings: Panel = $Settings
@onready var button_box: VBoxContainer = $VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if settings.visible:
		button_box.hide()
	else:
		button_box.show()



func _on_start_pressed() -> void:
	$Click.play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	$Click.play()
	button_box.hide()
	settings.show()

func _on_exit_pressed() -> void:
	$Click.play()
	get_tree().quit()
	
