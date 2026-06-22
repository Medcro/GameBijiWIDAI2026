extends CharacterBody2D

# Base Attribute
@export var hp : int = 5
@export var speed : float = 500
@export var jump : float = -500
@export var gravity : float = 980 

# Dash Attribute
@export var dash_speed : float = 1200.0
@export var dash_duration : float = 0.15
@export var dash_cooldown : float = 0.25 # Variabel bebas (boleh diganti angkanya kalo rasanya kelamaan)
var dash_timer : float = 0.0 
var dash_cooldown_timer : float = 0.0 # init
var is_dashing : bool = false
var facing_direction : float = 1.0 # positif -> kanan, negatif -> kiri
var hearts_list : Array[TextureRect]
var health = 5
var alive : bool = true

# Essence Attributes
@export var has_agility_essence : bool = false 
@export var has_flight_essence : bool = true 

var is_invincible : bool = false 
var can_double_jump : bool = false 

func _ready() -> void:
	var hearts_parents= $CanvasLayer/HBoxContainer
	for child in hearts_parents.get_children():
		hearts_list.append(child)
	print(hearts_list)
	
func take_damage():
	if health>0:
		health -=1
		#$node.play("damage")
		update_heart_display()
		
func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i<health
		
	if health == 1:
		hearts_list[0].get_child(0).play("")
	elif health > 1:
		hearts_list[0].get_child(0).play("")
	if health <= 0:
		alive = false
		death()

func heal():
	# harusnya ada if dream bar disini si
	health += 1
	update_heart_display()
	#$node.play("heal")
	
func death():
	health == 0
	#trigger game over scene

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
