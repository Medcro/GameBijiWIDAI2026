extends Control
@onready var settings: Panel = $Settings
@onready var reset_confirm: ConfirmationDialog = $resetConfirm

var open := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	settings.hide()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		var essenceTab = get_parent().find_child("SPEssence")
		if essenceTab!= null:
			if not essenceTab.visible:
				if open:
					if settings.visible:
						settings.hide()
					else:
						close_menu()
				else:
					open_menu()
					
	if not settings.visible:
		$Panel.show()
		$Label.show()
		$VBoxContainer.show()
		
func _on_resume_pressed() -> void:
	close_menu()

func _on_reset_pressed() -> void:
	reset_confirm.show()

func _on_settings_pressed() -> void:
	settings.show()
	$Panel.hide()
	$Label.hide()
	$VBoxContainer.hide()

func _on_exitmenu_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	print("Node yang ditangkap untuk di-save adalah: ", player.name, " | Class: ", player.get_class())
	if player != null:
		# 2. Tarik data terbaru dari player dan masukkan ke "keranjang" SaveManager
		SaveManager.game_data["player_position"] = player.global_position
		# (Sesuaikan "current_health" dengan nama variabel darah di skrip player kamu)
		if "health" in player:
			SaveManager.game_data["player_health"] = player.health 
		if "dream" in player:
			SaveManager.game_data["player_dream"] = player.dream
			
		SaveManager.game_data["current_level_num"] = LevelManager.current_level_num
		SaveManager.game_data["current_room_coords"] = LevelManager.current_room_coords
		SaveManager.game_data["current_scene_path"] = get_tree().current_scene.scene_file_path
		
		SaveManager.game_data["level_map_data"] = LevelManager.get_map_save_data()
		
		print(SaveManager.game_data["player_health"])
		SaveManager.save_game()
		print("Auto-save berhasil dilakukan!")
		
	else:
		push_warning("Gagal auto-save: Node Player tidak ditemukan di dalam scene!")
		
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func open_menu() -> void:
	open = true
	get_tree().paused = true
	show()
	
func close_menu() -> void:
	open = false
	get_tree().paused = false
	hide()

func _on_reset_confirm_confirmed() -> void:
	get_tree().reload_current_scene() #klo mau balik ke lvel paling awal tinggal ubah

func _on_reset_confirm_canceled() -> void:
	reset_confirm.hide()
