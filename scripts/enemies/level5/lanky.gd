extends CharacterBody2D
class_name ResolveEnemy

@export var player : CharacterBody2D
@export var max_health: int = 33
@export var patrol_speed: float = 40.0
@export var patrol_distance: float = 150.0
@export var attack_range: float = 140.0
@export var damage: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var lankyslash: Sprite2D = $Lankyslash
@onready var collision: CollisionShape2D = $CollisionShape2D

var initial_spawn_x: float
var current_health: int
var gravity: float = 980.0
var facing_dir: int = -1

enum States { IDLE, PATROL, ATTACK, DEATH }
var current_state: States = States.IDLE
var state_timer: float = 1.0

func _ready() -> void:
	current_health = max_health
	initial_spawn_x = global_position.x # spawn awal sesuai scene editor
	
	lankyslash.visible = false
	animated_sprite.play("default")

	ray_cast.add_exception(self)

	attack_hitbox.add_to_group("enemy_attack") 
	attack_hitbox.set_meta("is_unparryable", true) # unparryable

	_set_hitbox_active(false)
	if not attack_hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered):
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

	if not animated_sprite.frame_changed.is_connected(_on_frame_changed):
		animated_sprite.frame_changed.connect(_on_frame_changed)
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if current_state == States.DEATH:
		velocity.x = 0
		velocity.y += gravity * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		States.IDLE:
			_idle_behavior(delta)
		States.PATROL:
			_patrol_behavior(delta)
		States.ATTACK:
			velocity.x = move_toward(velocity.x, 0, 800 * delta)

	move_and_slide()


func _idle_behavior(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 800 * delta)

	if animated_sprite.animation != "default":
		animated_sprite.play("default")

	_look_for_player()
	if current_state == States.ATTACK: return

	state_timer -= delta
	if state_timer <= 0:
		current_state = States.PATROL
		state_timer = randf_range(1.0, 2.0)
		animated_sprite.play("walk")


func _patrol_behavior(delta: float) -> void:
	velocity.x = facing_dir * patrol_speed

	_look_for_player()
	if current_state == States.ATTACK: return
	
	var reached_boundary = false
	if facing_dir == 1 and global_position.x >= initial_spawn_x + patrol_distance:
		reached_boundary = true
	elif facing_dir == -1 and global_position.x <= initial_spawn_x - patrol_distance:
		reached_boundary = true

	if is_on_wall() or reached_boundary:
		_flip_direction()
		current_state = States.IDLE
		state_timer = 1.0 # Pause for a moment after turning around
		return
		
	state_timer -= delta
	if state_timer <= 0:
		current_state = States.IDLE
		state_timer = randf_range(0.8, 1.5) # berhenti bbrp detik sebelum putar balik


func _look_for_player() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not is_instance_valid(player): return

	var dist = global_position.distance_to(player.global_position)
	var dir_to_player = sign(player.global_position.x - global_position.x)

	if dist <= attack_range and dir_to_player == facing_dir: # biar nyerangnya di depan aja
		ray_cast.target_position = ray_cast.to_local(player.global_position)
		ray_cast.force_raycast_update()
		
		if ray_cast.is_colliding() and ray_cast.get_collider() == player:
			_start_attack()


func _flip_direction() -> void:
	facing_dir *= -1
	animated_sprite.flip_h = (facing_dir > 0)

	var target_scale = -1 if facing_dir > 0 else 1

	if attack_hitbox:
		attack_hitbox.scale.x = target_scale
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * facing_dir
	if lankyslash:
		lankyslash.scale.x = target_scale
		lankyslash.position.x = abs(lankyslash.position.x) * facing_dir


func _start_attack() -> void:
	current_state = States.ATTACK
	velocity.x = 0
	lankyslash.visible = false
	_set_hitbox_active(false)

	animated_sprite.position.x = -facing_dir * 195
	lankyslash.position.x = abs(lankyslash.position.x) * facing_dir + (-facing_dir * 195)
	
	animated_sprite.play("strike")


func _on_frame_changed() -> void:
	if current_state == States.ATTACK and animated_sprite.animation == "strike":
		if animated_sprite.frame == 4:
			lankyslash.visible = true
			lankyslash.modulate.a = 1.0
			_set_hitbox_active(true)
			# visual hack shi biar slash nya kayak ke-animate gitu
			var dir_sign = sign(lankyslash.scale.x)
			if dir_sign == 0: dir_sign = 1

			lankyslash.rotation_degrees = 45.0
			lankyslash.scale = Vector2(0.5 * dir_sign, 0.5)

			var tween = create_tween().set_parallel(true)

			tween.tween_property(lankyslash, "rotation_degrees", -30.0, 0.15).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(lankyslash, "scale", Vector2(1.2 * dir_sign, 1.2), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

			tween.chain().tween_property(lankyslash, "modulate:a", 0.0, 0.1)
			#might look jank tpi mendingan dripd suruh bikin animasi baru
		elif animated_sprite.frame == 6:
			lankyslash.visible = false
			_set_hitbox_active(false)


func _on_animation_finished() -> void:
	if current_state == States.ATTACK and animated_sprite.animation == "strike":
		lankyslash.visible = false
		_set_hitbox_active(false)
		animated_sprite.position.x = 0
		lankyslash.position.x = abs(lankyslash.position.x) * facing_dir # TS PART MIGHT BE CAUSING THE SLASH EFFECT OFFSET TO GESER2

	current_state = States.IDLE
	state_timer = 1.5
	animated_sprite.play("default")


func _set_hitbox_active(active: bool) -> void:
	for child in attack_hitbox.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not active)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int) -> void:
	if current_state == States.DEATH: return

	current_health -= amount
	_hit_flash()

	if current_health <= 0:
		_die()


func _hit_flash() -> void:
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(10, 10, 10, 1), 0.05)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.05)

func _die() -> void:
	current_state = States.DEATH

	collision.set_deferred("disabled", true)
	_set_hitbox_active(false)
	lankyslash.visible = false
	ray_cast.enabled = false
	
	await get_tree().create_timer(0.1).timeout
	queue_free()
