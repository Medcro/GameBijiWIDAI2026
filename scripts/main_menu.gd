extends Control
@onready var settings: Panel = $Settings
@onready var button_box: VBoxContainer = $VBoxContainer
@onready var continuebtn: Button = $VBoxContainer/continue
@onready var startbtn: Button = $VBoxContainer/start
@onready var reset_confirm: ConfirmationDialog = $resetConfirm
@onready var title: Label = $Title

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
func _process(_delta: float) -> void:
	if settings.visible:
		button_box.hide()
		title.hide()
	else:
		button_box.show()
		title.show()

func _on_start_pressed() -> void:
	$Click.play()
	if typeof(SaveManager) != TYPE_NIL and SaveManager.has_save():
		reset_confirm.popup_centered()
	else:
    DialogueBox.tutorial1()
		SaveManager.reset_and_delete_save()
		LevelManager.current_level_num = 1
		LevelManager.generate_new_level()

func _on_settings_pressed() -> void:
	$Click.play()
	button_box.hide()
	settings.show()
	title.hide()

func _on_exit_pressed() -> void:
	$Click.play()
	get_tree().quit()

func _on_continue_pressed() -> void:
	$Click.play()
	if not SaveManager.load_game():
		print("tidak ada save yang terbaca")
		return
		
	var saved_level = SaveManager.game_data["current_level_num"]
	var saved_coords = SaveManager.game_data["current_room_coords"]
	var saved_map = SaveManager.game_data["level_map_data"]
	
	# Peta dibangun ulang secara instan di latar belakang, 
	# dan enter_room() akan langsung memindahkan scene ke room tersebut
	LevelManager.load_map_from_save(saved_level, saved_coords, saved_map)
	
func _on_reset_confirm_confirmed() -> void:
	if typeof(SaveManager) != TYPE_NIL:
		SaveManager.delete_save()
	
	SaveManager.reset_and_delete_save()
	LevelManager.current_level_num = 1
	LevelManager.generate_new_level()

func _on_reset_confirm_canceled() -> void:
	reset_confirm.hide()
