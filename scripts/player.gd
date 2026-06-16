extends CharacterBody2D

# Base Attribute
@export var hp : int = 5
@export var speed : float = 500
@export var jump : float = -300
@export var gravity : float = 980 

# Dash Attribute
@export var dash_speed : float = 1200.0
@export var dash_duration : float = 0.2
var dash_timer : float = 0.0
var is_dashing : bool = false
var facing_direction : float = 1.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump
	
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
	else:
		velocity.x = lerp(velocity.x, direction*speed, delta * 2.0)
		
	move_and_slide()
