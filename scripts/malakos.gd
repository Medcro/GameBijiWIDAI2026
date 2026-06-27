extends Enemy

@export var projectile_scene : PackedScene
@export var charge_speed : float = 800.0
@export var spin_attack_range : float = 140.0 

@onready var charge_hitbox: CollisionShape2D = $AttackHitbox/ChargeHitbox
@onready var spin_hitbox: CollisionShape2D = $AttackHitbox/SpinHitbox


@onready var anim = $Sprite2D

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_animation()

func update_animation():
	if is_attacking:
		return 
		
	# Cek pergerakan berdasarkan sumbu X
	if velocity.x > 0:
		anim.play("moving_right")
	elif velocity.x < 0:
		anim.play("moving_left")
	else:
		anim.play("idle")

# Overwrite fungsi gravity karena terbang
func handle_gravity(delta: float):
	pass 

func chase_behavior():
	var target_pos = player.global_position + Vector2(0, -60)
	direction = global_position.direction_to(target_pos)
	
	set_facing(sign(direction.x))

func handle_movement(delta : float, target_speed : int):
	velocity = velocity.move_toward(direction * target_speed, acceleration * delta)

func execute_random_attack():
	is_attacking = true
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= spin_attack_range:
		perform_attack_three() 
	else:
		var random_attack = randi() % 2
		if random_attack == 0:
			perform_attack_one()
		else:
			perform_attack_two()

func perform_attack_one():
	velocity = Vector2.ZERO 
	
	anim.play("idle") # ganti dengan animasi menembak projektile
	
	await get_tree().create_timer(0.5).timeout 
	if current_state == States.DEATH: return
	
	for i in range(randi_range(4, 5)):
		if current_state == States.DEATH: return
		shoot_projectile()
		await get_tree().create_timer(0.2).timeout
		
	await get_tree().create_timer(1.0).timeout
	finish_attack()

func shoot_projectile():
	if projectile_scene and player:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = self.global_position
		
		var dir = global_position.direction_to(player.global_position)
		proj.set_direction(dir)

func perform_attack_two():
	velocity = Vector2.ZERO
	
	anim.play("idle") # ganti dengan animasi charge
	
	var charge_dir = global_position.direction_to(player.global_position)
	await get_tree().create_timer(0.8).timeout 
	if current_state == States.DEATH: return
	
	charge_hitbox.set_deferred("disabled", false)
	velocity = charge_dir * charge_speed
	
	await get_tree().create_timer(0.4).timeout 
	
	charge_hitbox.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	await get_tree().create_timer(1.0).timeout
	
	finish_attack()

func perform_attack_three():
	velocity = Vector2.ZERO
	
	anim.play("idle") # ganti dengan animasi spin
	
	await get_tree().create_timer(0.3).timeout
	if current_state == States.DEATH: return
	
	spin_hitbox.set_deferred("disabled", false)
	
	await get_tree().create_timer(0.8).timeout 
	
	spin_hitbox.set_deferred("disabled", true)
	await get_tree().create_timer(0.5).timeout
	
	finish_attack()
