extends CharacterBody2D

# Base Attribute
@export var hp : int = 5
@export var speed : float = 300
@export var jump : float = -500
@export var gravity : float = 980 

# Dash Attribute
@export var dash_speed : float = 1200.0
@export var dash_duration : float = 0.07
@export var dash_cooldown : float = 0.25 # Variabel bebas (boleh diganti angkanya kalo rasanya kelamaan)
var dash_timer : float = 0.0 
var dash_cooldown_timer : float = 0.0 # init
var is_dashing : bool = false
var facing_direction : float = 1.0 # positif -> kanan, negatif -> kiri

## Melee Attack Attributes (belum implement)
#@export var combo_window_duration : float = 0.4 # window buat 2-hit
#var is_attacking : bool = false
#var combo_step : int = 0
#var combo_window_timer : float = 0.0

# Essence Attributes
@export var has_agility_essence : bool = false 
@export var has_flight_essence : bool = true 

var is_invincible : bool = false 
var can_double_jump : bool = false 

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0 and not is_dashing:
		facing_direction = sign(direction)
	
	# Dash delay
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			is_invincible = false 
			dash_cooldown_timer = dash_cooldown
			
	if Input.is_action_just_pressed("Dash") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = dash_duration
		
		if has_agility_essence:
			is_invincible = true
			pass # add visual later

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# can double jump
		can_double_jump = true
		
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		position.y += 1.2
		
	if Input.is_action_just_pressed("Jump") and not is_dashing:
		if is_on_floor():
			velocity.y = jump
		elif can_double_jump and has_flight_essence:
			velocity.y = jump
			can_double_jump = false 

	# Movement 
	if is_dashing:
		velocity.x = facing_direction * dash_speed
		velocity.y = 0 
	else:
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
	move_and_slide()
