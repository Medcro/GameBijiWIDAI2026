extends Area2D
class_name VoidZone

@export var safe_spawn: Node2D # Assign a Marker2D to this in the Inspector
@export var damage_on_fall: int = 1 # biar ada konsek klo skill issue

func _ready() -> void:
	# auto connect sinyal _on_body_entered
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity = Vector2.ZERO
		
		body.global_position = safe_spawn.global_position
		
		body.take_damage(damage_on_fall)
