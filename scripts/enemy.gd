extends CharacterBody2D

class_name Enemy

@export var player : CharacterBody2D
@export var wander_speed : int = 50
@export var chase_speed : int = 150
@export var acceleration : int = 300
@export var attack_range : float = 175.0 
@export var max_health : int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $Sprite2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var current_health : int = max_health
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var attack_cooldown: Timer = $AttackCooldown 

@onready var right_bounds : Vector2 = self.position + Vector2(125, 0)
@onready var left_bounds : Vector2 = self.position + Vector2(-125, 0)

var gravity : float = 980
var direction : Vector2
var is_attacking : bool = false

enum States {
	WANDER,
	CHASE,
	ATTACK,
	DEATH
}
var current_state = States.WANDER

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	
	match current_state:
		States.WANDER:
			look_for_player()
			change_direction()
			handle_movement(delta, wander_speed)
		States.CHASE:
			look_for_player()
			check_attack_range() 
			change_direction()
			handle_movement(delta, chase_speed)
		States.ATTACK:
			handle_movement(delta, 0) 
			if not is_attacking:
				execute_random_attack()
				
	move_and_slide()

func look_for_player():
	if ray_cast.is_colliding() and ray_cast.get_collider() == player:
		if current_state == States.WANDER:
			chase_player()
	elif current_state == States.CHASE:
		stop_chase()

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

func change_direction():
	if current_state == States.WANDER:
		if sprite.flip_h:
			# moving right
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				# flip to moving left
				sprite.flip_h = false
				ray_cast.target_position = Vector2(-125, 0)
		else:
			# moving left
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				# flip to moving right
				sprite.flip_h = true
				ray_cast.target_position = Vector2(125, 0)
	elif current_state == States.CHASE:
		var dir_to_player = sign(player.position.x - self.position.x)
		direction = Vector2(dir_to_player, 0)
		
		if direction.x == 1:
			# flip to moving right
			sprite.flip_h = true
			ray_cast.target_position = Vector2(125, 0)
		elif direction.x == -1:
			# flip to moving left
			sprite.flip_h = false
			ray_cast.target_position = Vector2(-125, 0)

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
	
	await get_tree().create_timer(2.0).timeout # ganti dengan animasi attack 1
	finish_attack()

func perform_attack_two():
	print("Attack 2")
	
	await get_tree().create_timer(2.0).timeout # ganti dengan animasi attack 2
	finish_attack()

func perform_attack_three():
	print("Attack 3")
	
	await get_tree().create_timer(2.0).timeout # ganti dengan animasi attack 3
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
			chase_player()

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
