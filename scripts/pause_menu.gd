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
