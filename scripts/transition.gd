extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_transitioning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.visible = false

func play_transition() -> void:
	is_transitioning = true
	animation_player.play("fade")
	await animation_player.animation_finished

func play_transition_backwards() -> void:
	animation_player.play_backwards("fade")
	await  animation_player.animation_finished
	is_transitioning = false
