extends Enemy

@export var projectile_scene : PackedScene
@export var charge_speed : float = 800.0
@export var spin_attack_range : float = 135.0 
@export var preferred_distance : float = 130.0

@onready var charge_hitbox: CollisionShape2D = $AttackHitbox/ChargeHitbox
@onready var spin_hitbox: CollisionShape2D = $AttackHitbox/SpinHitbox
@onready var charge_hitbox_2: CollisionShape2D = $AttackHitbox/ChargeHitbox2

@onready var tentacle: AnimatedSprite2D = $Sprite2D/AnimatedSprite2D

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
	tentacle.flip_h = anim.flip_h
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
	var distance_to_target = global_position.distance_to(target_pos)
	
	if distance_to_target > preferred_distance + 20:
		direction = global_position.direction_to(target_pos)
	elif distance_to_target < preferred_distance - 20:
		direction = -global_position.direction_to(target_pos)
	else:
		direction = Vector2.ZERO
	
	var dir_to_player = sign(player.global_position.x - global_position.x)
	set_facing(dir_to_player)

func handle_movement(delta : float, target_speed : int):
	velocity = velocity.move_toward(direction * target_speed, acceleration * delta)

func execute_random_attack():
	is_attacking = true
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= spin_attack_range: # Jika terlalu dekat, gunakan attack 3
		perform_attack_three() 
	else:
		var random_attack = randi() % 2
		if random_attack == 0:
			perform_attack_one()
		else:
			perform_attack_two()

func perform_attack_one():
	velocity = Vector2.ZERO 
	
	anim.play("attack_one") 
	
	await get_tree().create_timer(0.5).timeout 
	if current_state == States.DEATH: return
	
	# 3 kali tembak, sesuai dengan animasi
	for j in range(0, 3):
		await get_tree().create_timer(0.4).timeout
		for i in range(randi_range(1, 2)): # tiap satu sesi tembakan, bisa menembak 1 atau 2 kali
			if current_state == States.DEATH: return
			shoot_projectile()
			await get_tree().create_timer(0.2).timeout
		
	await get_tree().create_timer(1.0).timeout
	finish_attack()

func perform_attack_two():
	velocity = Vector2.ZERO
	
	anim.play("charge")
	await get_tree().create_timer(0.8).timeout 
	anim.play("attack_two")
	await get_tree().create_timer(0.4).timeout
	charge_hitbox.set_deferred("disabled", false)
	tentacle.visible = true
	tentacle.play("tentacle") 
	
	var charge_dir = global_position.direction_to(player.global_position)
	await get_tree().create_timer(0.8).timeout 
	if current_state == States.DEATH: return
	
	velocity = charge_dir * charge_speed
	
	await get_tree().create_timer(0.1).timeout
	charge_hitbox_2.set_deferred("disabled", false)
	
	await get_tree().create_timer(0.4).timeout 
	
	charge_hitbox.set_deferred("disabled", true)
	charge_hitbox_2.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	await get_tree().create_timer(1.0).timeout
	
	finish_attack()

func perform_attack_three():
	velocity = Vector2.ZERO
	
	anim.play("attack_three") 
	
	await get_tree().create_timer(0.3).timeout
	if current_state == States.DEATH: return
	
	spin_hitbox.set_deferred("disabled", false)
	
	await get_tree().create_timer(0.8).timeout 
	
	spin_hitbox.set_deferred("disabled", true)
	await get_tree().create_timer(0.5).timeout
	
	finish_attack()

func shoot_projectile():
	if projectile_scene and player:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = self.global_position
		
		var dir = global_position.direction_to(player.global_position)
		proj.set_direction(dir)
		
func take_damage(amount: int):
	if current_state == States.DEATH:
		return
		
	current_health -= amount
	hit_flash()
	
	if current_health <= 0:
		die()
	else:
		if current_state == States.WANDER:
			chase_player()

func hit_flash():
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color(10, 10, 10, 1), 0.05)
	tween.tween_property(anim, "modulate", Color.WHITE, 0.05)
	
	if tentacle.visible:
		var tentacle_tween = create_tween()
		tentacle_tween.tween_property(tentacle, "modulate", Color(10, 10, 10, 1), 0.05)
		tentacle_tween.tween_property(tentacle, "modulate", Color.WHITE, 0.05)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body == player or body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(1)

func die():
	super.die()
	# Add level transition in here
	
	
