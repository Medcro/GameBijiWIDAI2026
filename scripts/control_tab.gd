extends Control

@onready var input_button_scn = preload("res://scenes/input_bind_button.tscn")
@onready var action_list: GridContainer = $MarginContainer/VBoxContainer/Container/ActionList
@onready var confirmation_dialog: ConfirmationDialog = $"../ConfirmationDialog"

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var pending_event: InputEvent = null
var conflicting_action: String = ""

func _ready() -> void:
	create_action_list()
	
func create_action_list():
	for item in action_list.get_children():
		item.queue_free()
	
	for action in ControlSettings.input_actions:
		var button = input_button_scn.instantiate()
		var action_label = button.find_child("ActionName")
		var input_label = button.find_child("ActionKey")
		
		action_label.text = ControlSettings.input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("ActionKey").text = "Press Key to bind"
		

func _input(event: InputEvent) -> void:
	if is_remapping:
		if (event is InputEventKey || event.is_pressed()):
			var conflict = _find_conflicting_action(event)
			
			if conflict != "":
				# 2a. ADA KONFLIK! Tahan proses dan munculkan dialog
				conflicting_action = conflict
				pending_event = event
				
				var action_name = ControlSettings.input_actions[conflict]
				confirmation_dialog.dialog_text = "Keybind ini sudah dipakai untuk '" + action_name + "'.\nApakah kamu ingin menimpanya?"
				confirmation_dialog.popup_centered()
			else:
				# 2b. AMAN! Langsung simpan
				pending_event = event
				_finalize_remapping()
			
			# Hentikan mode remapping agar input selanjutnya tidak terdeteksi ganda
			is_remapping = false
			accept_event()
			
func _update_action_list(button, event):
	button.find_child("ActionKey").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	create_action_list()

func _find_conflicting_action(new_event: InputEvent) -> String:
	for action in ControlSettings.input_actions:
		# Jangan cek action yang sedang kita remap sendiri
		if action == action_to_remap:
			continue 
			
		var existing_events = InputMap.action_get_events(action)
		for existing_event in existing_events:
			# is_match() adalah cara akurat membandingkan 2 tombol di Godot
			if existing_event.is_match(new_event): 
				return action
	return ""
	
func _finalize_remapping() -> void:
	# Hapus tombol lama di action yang mau diganti
	InputMap.action_erase_events(action_to_remap)
	# Masukkan tombol baru
	InputMap.action_add_event(action_to_remap, pending_event)
	
	if conflicting_action != "":
		# Jika ada konflik, hapus keybind dari action lawan (bikin jadi Unbound)
		InputMap.action_erase_events(conflicting_action)
		# Karena ada lebih dari 1 tombol yang berubah di UI, refresh total list-nya
		create_action_list()
	else:
		# Kalau aman, cukup perbarui teks di tombol yang dipencet aja biar efisien
		_update_action_list(remapping_button, pending_event)
		
	_reset_remapping_state()

func _reset_remapping_state() -> void:
	action_to_remap = null
	remapping_button = null
	pending_event = null
	conflicting_action = ""

# --- SIGNAL DARI CONFIRMATION DIALOG ---
func _on_confirmation_dialog_confirmed() -> void:
	# Pemain klik "Yes" -> Timpa!
	_finalize_remapping()

func _on_confirmation_dialog_canceled() -> void:
	# Pemain klik "No" -> Batal. Refresh UI untuk membuang teks "Press Key to bind..."
	create_action_list()
	_reset_remapping_state()
