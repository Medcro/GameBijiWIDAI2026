extends CharacterBody2D

class_name Enemy

@export var player : CharacterBody2D
@export var wander_speed : int = 50
@export var chase_speed : int = 150
@export var acceleration : int = 300
@export var attack_range : float = 175.0
@export var vision_range : float = 250.0 
@export var max_health : int = 1


@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $Sprite2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var current_health : int = max_health
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var attack_cooldown: Timer = $AttackCooldown 

@onready var right_bounds : Vector2 = self.position + Vector2(125, 0)
@onready var left_bounds : Vector2 = self.position + Vector2(-125, 0)

@onready var attack_hitbox = $AttackHitbox

var gravity : float = 980
var direction : Vector2 = Vector2.RIGHT 
var is_attacking : bool = false
var ledge_check: RayCast2D

enum States {
	WANDER,
	CHASE,
	ATTACK,
	DEATH
}
var current_state = States.WANDER

func _ready() -> void:
	#  ledge check biar ga jatuh - kaiser
	ledge_check = RayCast2D.new()
	ledge_check.target_position = Vector2(0, 100)
	add_child(ledge_check)
	ray_cast.add_exception(self)
	ledge_check.add_exception(self)

	# hitbox
	if attack_hitbox:
		attack_hitbox.add_to_group("enemy_attack") # parryable
		_set_hitbox_active(false)
		
		# deal damage
		if not attack_hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered):
			attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	# kena damage
	if body == player and body.has_method("take_damage"):
		body.take_damage(1)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	
	match current_state:
			States.WANDER:
				look_for_player()
				wander_behavior()
				handle_movement(delta, wander_speed)
			States.CHASE:
				look_for_player()
				check_attack_range() 
				chase_behavior()
				handle_movement(delta, chase_speed)
			States.ATTACK:
				handle_movement(delta, 0) # Stop moving while attacking
				if not is_attacking:
					execute_random_attack()
			States.DEATH:
				handle_movement(delta, 0)
				
	move_and_slide()

func _set_hitbox_active(active: bool):
	for child in attack_hitbox.get_children():
		child.set_deferred("disabled", not active)

func look_for_player():
	var dist = global_position.distance_to(player.global_position)
	if dist <= vision_range:
		ray_cast.target_position = ray_cast.to_local(player.global_position)
		ray_cast.force_raycast_update()
		
		if ray_cast.is_colliding() and ray_cast.get_collider() == player:
			if current_state == States.WANDER:
				chase_player()
			return
			
		if current_state == States.CHASE:
			stop_chase()

func wander_behavior():
	if direction.x == 0: direction.x = 1
	
	ledge_check.position.x = direction.x * 20 
	ledge_check.force_raycast_update()
	
	if is_on_wall() or (is_on_floor() and not ledge_check.is_colliding()):
		direction.x *= -1
		
	set_facing(direction.x)

func chase_behavior():
	if not player: return
	
	var dir_to_player = sign(player.global_position.x - global_position.x)
	direction.x = dir_to_player
	
	ledge_check.position.x = direction.x * 20
	ledge_check.force_raycast_update()
	
	if is_on_floor() and not ledge_check.is_colliding():
		direction.x = 0
		
	set_facing(dir_to_player)

func chase_player():
	timer.stop()
	current_state = States.CHASE

func stop_chase():
	if timer.time_left <= 0:
		timer.start()

func check_attack_range():
	var distance_to_player = self.global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and attack_cooldown.time_left <= 0:
		current_state = States.ATTACK

func handle_movement(delta : float, target_speed : int):
	velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)

func handle_gravity(delta:float):
	if not is_on_floor():
		velocity.y += gravity * delta

func set_facing(dir_x: float): # change_direction aku ganti jdi ini yh - kaiser
	if dir_x == 0: return

	sprite.flip_h = (dir_x > 0)
	
	if attack_hitbox:
		attack_hitbox.scale.x = sign(dir_x)

func execute_random_attack():
	is_attacking = true
	
	var random_attack = randi() % 3 
	
	match random_attack:
		0:
			perform_attack_one()
		1:
			perform_attack_two()
		2:
			perform_attack_three()

func perform_attack_one():
	print("Attack 1")
	
	await get_tree().create_timer(0.4).timeout # ganti dengan animasi attack 1
	if current_state == States.DEATH: return
	_set_hitbox_active(true) 
	await get_tree().create_timer(0.1).timeout # puncak animasinya di sini
	if current_state == States.DEATH: return
	_set_hitbox_active(false)
	await get_tree().create_timer(1.5).timeout
	if current_state == States.DEATH: return
	
	finish_attack()

func perform_attack_two():
	print("Attack 2")
	
	await get_tree().create_timer(0.4).timeout # ganti dengan animasi attack 2 (aku ganti jdi wind up dlu - kaiser)
	if current_state == States.DEATH: return
	_set_hitbox_active(true) 
	await get_tree().create_timer(0.1).timeout # puncak animasinya di sini - kaiser
	if current_state == States.DEATH: return
	_set_hitbox_active(false)
	await get_tree().create_timer(1.5).timeout
	if current_state == States.DEATH: return
	
	finish_attack()

func perform_attack_three():
	print("Attack 3")
	
	await get_tree().create_timer(0.4).timeout # ganti dengan animasi attack 3
	if current_state == States.DEATH: return
	_set_hitbox_active(true) 
	await get_tree().create_timer(0.1).timeout # puncak animasinya di sini
	if current_state == States.DEATH: return
	_set_hitbox_active(false)
	await get_tree().create_timer(1.5).timeout
	if current_state == States.DEATH: return
	
	finish_attack()

# hubungkan dengan signal attack dari player
func take_damage(amount: int):
	# Jika sudah mati, abaikan damage tambahan
	if current_state == States.DEATH:
		return
		
	current_health -= amount
	
	if current_health <= 0:
		die()
	else:
		if current_state == States.WANDER:
			chase_player() # ini buat aggro kn yah? - kaiser	

func die():
	current_state = States.DEATH
	print("ded")
	
	collision.set_deferred("disabled", true)
	ray_cast.enabled = false
	
	await get_tree().create_timer(1.0).timeout # ganti dengan animasi
	queue_free()

# Hubungkan dengan signal animasi finished
func finish_attack():
	is_attacking = false
	attack_cooldown.start()
	current_state = States.CHASE

func _on_timer_timeout() -> void:
	current_state = States.WANDER
