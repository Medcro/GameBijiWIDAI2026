extends Enemy

@export var preferred_distance : float = 170.0

@onready var laser_sprite: AnimatedSprite2D = $LaserSprite

func _ready() -> void:
	super._ready()
	laser_sprite.visible = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_animation()

func set_facing(dir_x: float):
	if dir_x == 0: return

	sprite.flip_h = (dir_x < 0)
	
	attack_hitbox.scale.x = sign(dir_x)
		
	laser_sprite.flip_h = (dir_x < 0)
		
	laser_sprite.position.x = abs(laser_sprite.position.x) * sign(dir_x)

func update_animation():
	if is_attacking:
		return 
		
	sprite.play("idle")

# Menimpa fungsi gravitasi
func handle_gravity(delta: float):
	pass 

func chase_behavior():
	var distance_x = abs(player.global_position.x - global_position.x)
	var dir_x = sign(player.global_position.x - global_position.x)
	
	if distance_x > preferred_distance + 20:
		direction = Vector2(dir_x, 0)
	elif distance_x < preferred_distance - 20:
		direction = Vector2(-dir_x, 0)
	else:
		direction = Vector2.ZERO 
	
	set_facing(dir_x)
	
	laser_sprite.flip_h = sprite.flip_h

func handle_movement(delta : float, target_speed : int):
	velocity = velocity.move_toward(direction * target_speed, acceleration * delta)

func execute_random_attack():
	is_attacking = true
	velocity = Vector2.ZERO 
		
	sprite.play("attack") 
	
	await get_tree().create_timer(0.5).timeout 
	if current_state == States.DEATH: return
	
	if laser_sprite:
		laser_sprite.visible = true
		laser_sprite.play("boom")
	
	_set_hitbox_active(true)
	
	await get_tree().create_timer(0.5).timeout 
	if current_state == States.DEATH: return
	
	_set_hitbox_active(false)
	if laser_sprite:
		laser_sprite.visible = false
	
	finish_attack()

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
	tween.tween_property(sprite, "modulate", Color(10, 10, 10, 1), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
