extends Control

var is_continuing: bool = false
@onready var pressany: Label = $pressany
@onready var quote: Label = $quote

@export var default_position: Vector2

const FIRST_LEVEL_PATH = "res://scenes/rooms/level1/spawn_var_1.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Transition.play_transition_backwards()
	start_pulse()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		if event is InputEventKey or event is InputEventMouseButton:
			if is_continuing:
				return
			is_continuing = true
			continue_next()
			
func continue_next() -> void:
	new_level()
	
func start_pulse() -> void:
	if pressany == null: 
		return
	# Start it at a low opacity
	pressany.modulate.a = 0.2 
	
	# Create a tween and set it to loop infinitely
	var tween = create_tween().set_loops() 
	
	# Fade up to 0.8 opacity over 1.5 seconds using a smooth Sine wave
	tween.tween_property(pressany, "modulate:a", 0.8, 1.5).set_trans(Tween.TRANS_SINE)
	
	# Fade back down to 0.2 opacity over 1.5 seconds
	tween.tween_property(pressany, "modulate:a", 0.2, 1.5).set_trans(Tween.TRANS_SINE)

func new_level() -> void:
	SaveManager.game_data = {
		"player_position": default_position, 
		"player_health": 5, # Darah maksimal awal
		"collected_essences": [],
		"current_scene_path": FIRST_LEVEL_PATH
	}
	SaveManager.save_game() # Kunci data baru ini ke dalam memori
	#get_tree().change_scene_to_file(FIRST_LEVEL_PATH)
	LevelManager.current_level_num = 1
	LevelManager.generate_new_level()
