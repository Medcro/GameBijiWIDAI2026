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
	LevelManager.current_level_num = 1
	LevelManager.generate_new_level()

	# 2. Get the room data for the spawn room
	var spawn_coords = LevelManager.current_room_coords
	var spawn_room = LevelManager.current_map[spawn_coords]

	# 3. Transition to the scene file chosen for the spawn room!
	if spawn_room and spawn_room.scene_path != "":
		get_tree().change_scene_to_file(spawn_room.scene_path)
	else:
		push_error("Failed to find a valid scene path for the Spawn room!")

func _on_settings_pressed() -> void:
	$Click.play()
	button_box.hide()
	settings.show()

func _on_exit_pressed() -> void:
	$Click.play()
	get_tree().quit()
	
