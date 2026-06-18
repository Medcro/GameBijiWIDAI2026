extends Control

var is_continuing: bool = false
@onready var pressany: Label = $pressany
@onready var quote: Label = $quote

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pulse()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		if event is InputEventKey or event is InputEventMouseButton:
			if is_continuing:
				return
			is_continuing = true
			continue_next()
			
func continue_next() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn") #bebas nih diubah kemana
	
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
