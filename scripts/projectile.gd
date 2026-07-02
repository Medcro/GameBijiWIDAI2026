extends Area2D

class_name BossProjectile

@export var speed: float = 200
@export var damage: int = 1

@export var spin_speed: float = 100

var direction: Vector2 = Vector2.ZERO

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed
	
	rotation_degrees += spin_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(1)
		
	if body is not Enemy:
		queue_free()

func _on_screen_exited() -> void:
	queue_free()
