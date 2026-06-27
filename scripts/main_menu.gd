extends Control
@onready var settings: Panel = $Settings
@onready var button_box: VBoxContainer = $VBoxContainer
@onready var continuebtn: Button = $VBoxContainer/continue
@onready var startbtn: Button = $VBoxContainer/start
@onready var reset_confirm: ConfirmationDialog = $resetConfirm

@export var default_position: Vector2

const FIRST_LEVEL_PATH = "res://scenes/main.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings.hide()
	if SaveManager.has_save():
		continuebtn.show()
		startbtn.text = "NEW DREAM"
	else:
		continuebtn.hide()
		startbtn.text = "DREAM"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if settings.visible:
		button_box.hide()
	else:
		button_box.show()

func _on_start_pressed() -> void:
	$Click.play()
	if typeof(SaveManager) != TYPE_NIL and SaveManager.has_save():
		reset_confirm.popup_centered()
	else:
		new_level()

func _on_settings_pressed() -> void:
	$Click.play()
	button_box.hide()
	settings.show()

func _on_exit_pressed() -> void:
	$Click.play()
	get_tree().quit()

func _on_continue_pressed() -> void:
	$Click.play()
	if SaveManager.load_game():
		# Ambil jalur scene yang tersimpan, jika tidak ada, pakai default level 1
		var target_scene = SaveManager.game_data.get("current_scene_path", FIRST_LEVEL_PATH)
		get_tree().change_scene_to_file(target_scene)


func _on_reset_confirm_confirmed() -> void:
	if typeof(SaveManager) != TYPE_NIL:
		SaveManager.delete_save()
	
	new_level()

func _on_reset_confirm_canceled() -> void:
	reset_confirm.hide()

func new_level() -> void:
	SaveManager.game_data = {
		"player_position": default_position, 
		"player_health": 5, # Darah maksimal awal
		"collected_essences": [],
		"current_scene_path": FIRST_LEVEL_PATH
	}
	SaveManager.save_game() # Kunci data baru ini ke dalam memori
	get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
	#LevelManager.current_level_num = 1
	#LevelManager.generate_new_level()
#
	## 2. Get the room data for the spawn room
	#var spawn_coords = LevelManager.current_room_coords
	#var spawn_room = LevelManager.current_map[spawn_coords]
#
	## 3. Transition to the scene file chosen for the spawn room!
	#if spawn_room and spawn_room.scene_path != "":
		#get_tree().change_scene_to_file(spawn_room.scene_path)
	#else:
		#push_error("Failed to find a valid scene path for the Spawn room!")
