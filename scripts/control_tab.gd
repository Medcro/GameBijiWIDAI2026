extends Control

@onready var input_button_scn = preload("res://scenes/input_bind_button.tscn")
@onready var action_list: GridContainer = $MarginContainer/VBoxContainer/Container/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

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
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()
			
func _update_action_list(button, event):
	button.find_child("ActionKey").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	create_action_list()
