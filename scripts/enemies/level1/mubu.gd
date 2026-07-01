extends CharacterBody2D
class_name FlyingEnemy

@export var player : CharacterBody2D
@export var charge_speed : float = 900.0
@export var return_speed : float = 150.0
@export var lock_on_duration : float = 5.0 # How long it telegraphs before charging
@export var charge_duration : float = 1.0 # Max time spent charging before returning
@export var vision_range : float = 400.0
@export var max_health : int = 8
@export var float_speed: float = 5.0
@export var float_amount: float = 20.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var charge_effect: AnimatedSprite2D = $Chargeeffect
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var attack_hitbox: Node2D = get_node_or_null("AttackHitbox")
@onready var collision: CollisionShape2D = $CollisionShape2D

enum States { IDLE, LOCK_ON, ANTICIPATION, CHARGE, RETURN, DEATH }
var current_state = States.IDLE

var current_health : int = max_health
var origin_y : float
var gravity : float = 980
var time_passed : float = 0.0
var state_timer : float = 0.0
var charge_direction : Vector2 = Vector2.ZERO

var ghost_spawn_time : float = 0.04
var ghost_timer : float = 0.0

const Essence = preload("res://scenes/collectible.tscn")

func _ready() -> void:
	# Save the Y height it spawned at so it knows where to return to
	origin_y = global_position.y

	# Set default visuals
	charge_effect.visible = false
	animated_sprite.play("default")

	# Setup RayCast exception
	if ray_cast:
		ray_cast.add_exception(self)
		
	# Setup Attack Hitbox for Parrying & Damage
	if attack_hitbox:
		attack_hitbox.add_to_group("enemy_attack") # Enables player parries!
		_set_hitbox_active(false)
		
		# Connect signal to detect hitting the player
		if attack_hitbox is Area2D and not attack_hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered):
			attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	match current_state:
		States.IDLE:
			idle_behavior(delta)
		States.LOCK_ON:
			lock_on_behavior(delta)
		States.ANTICIPATION:
			anticipation_behavior(delta)
		States.CHARGE:
			charge_behavior(delta)
		States.RETURN:
			return_behavior(delta)
		States.DEATH:
			velocity.x = 0
			velocity.y += gravity * delta
			move_and_slide()

	move_and_slide()

func idle_behavior(delta: float):
	time_passed += delta
	# Smooth bobbing up and down
	velocity.y = sin(time_passed * float_speed) * float_amount
	velocity.x = move_toward(velocity.x, 0, 800 * delta)

	# Make sure sprite is centered (resetting from lock-on shake)
	animated_sprite.position = Vector2.ZERO

	look_for_player()


func look_for_player():
	var dist = global_position.distance_to(player.global_position)
	if dist <= vision_range:
		if ray_cast:
			# Use to_local directly on the raycast to fix math offsets
			ray_cast.target_position = ray_cast.to_local(player.global_position)
			ray_cast.force_raycast_update()
			
			if ray_cast.is_colliding() and ray_cast.get_collider() == player:
				start_lock_on()

func start_lock_on():
	current_state = States.LOCK_ON
	state_timer = lock_on_duration
	animated_sprite.play("default")

func lock_on_behavior(delta: float):
	state_timer -= delta
	time_passed += delta

	# Keep bobbing slightly
	velocity.y = sin(time_passed * float_speed) * float_amount
	velocity.x = move_toward(velocity.x, 0, 800 * delta)

	# Shake sprite intensely to telegraph the incoming charge!
	var shake_intensity = 2.0
	animated_sprite.position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))

	# Face the player while locking on
	if player:
		var dir_to_player = sign(player.global_position.x - global_position.x)
		if dir_to_player != 0:
			animated_sprite.flip_h = (dir_to_player > 0)
			charge_effect.flip_h = (dir_to_player > 0) # Flip the effect too
			if attack_hitbox:
				attack_hitbox.scale.x = sign(dir_to_player)
			
	if state_timer <= 0:
		start_anticipation()


func start_anticipation():
	current_state = States.ANTICIPATION
	velocity = Vector2.ZERO # Stop bobbing, freeze in mid-air

	# Reset sprite shake from the lock-on phase
	animated_sprite.position = Vector2.ZERO

	# Play the wind-up/rearing animation
	animated_sprite.play("charge")

	# Lock the trajectory toward exactly where the player is right NOW
	if player:
		charge_direction = global_position.direction_to(player.global_position)
	else:
		charge_direction = Vector2(-1 if not animated_sprite.flip_h else 1, 0)
		
	# Wait for the "charge" rearing animation to finish before actually moving
	await animated_sprite.animation_finished

	# Safety check: if the enemy was killed while rearing up, don't charge!
	if current_state != States.DEATH:
		start_charge()


func anticipation_behavior(_delta: float):
	# Just wait patiently while the animation plays out
	velocity = Vector2.ZERO

func start_charge():
	current_state = States.CHARGE
	state_timer = charge_duration

	# Start looping the charge visuals
	animated_sprite.play("during_charge")
	charge_effect.visible = true
	charge_effect.play("effect")
		
	# Turn hitbox ON during the charge
	_set_hitbox_active(true)

func charge_behavior(delta: float):
	state_timer -= delta
	velocity = charge_direction * charge_speed

	# Spawn Ghost Trail for Motion Blur
	ghost_timer -= delta
	if ghost_timer <= 0:
		spawn_ghost()
		ghost_timer = ghost_spawn_time

	# If we hit a wall/floor/ceiling, or time runs out, stop charging and retreat
	if state_timer <= 0 or is_on_wall() or is_on_floor() or is_on_ceiling():
		start_return()


func spawn_ghost():
	# Create a clone of the AnimatedSprite to act as a fading trail
	var ghost = AnimatedSprite2D.new()
	ghost.z_index = animated_sprite.z_index - 1
	ghost.sprite_frames = animated_sprite.sprite_frames
	ghost.animation = animated_sprite.animation
	ghost.frame = animated_sprite.frame
	ghost.global_position = animated_sprite.global_position
	ghost.flip_h = animated_sprite.flip_h
	ghost.global_scale = animated_sprite.global_scale
	ghost.modulate.a = 0.5

	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
		shader_type canvas_item;
		void fragment() {
			COLOR = vec4(1.0, 0.969, 0.659, texture(TEXTURE, UV).a * COLOR.a);
		}
	"""
	mat.shader = shader
	ghost.material = mat

	# Add it independently to the main scene so it doesn't move with the enemy
	ghost.top_level = true
	get_tree().current_scene.add_child(ghost)

	# Tween the alpha to 0 over a fraction of a second, then delete it
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_callback(ghost.queue_free)


func start_return():
	current_state = States.RETURN
	_set_hitbox_active(false)

	# Hide effects and return to idle animation
	charge_effect.visible = false
	charge_effect.stop()
	animated_sprite.play("default")


func return_behavior(delta: float):
	# Move smoothly back to original Y level
	var dir_y = sign(origin_y - global_position.y)
	velocity.y = move_toward(velocity.y, dir_y * return_speed, 800 * delta)

	# Decelerate X movement completely so it hovers in place
	velocity.x = move_toward(velocity.x, 0, 800 * delta)

	# Reached the original height? Go back to idle (and instantly try to lock on again!)
	if abs(global_position.y - origin_y) < 5.0:
		current_state = States.IDLE


func take_damage(amount: int):
	if current_state == States.DEATH:
		return

	current_health -= amount
	hit_flash()
	if current_health <= 0:
		die()

func hit_flash():
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(10, 10, 10, 1), 0.05)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.05)

func die():
	var newEssence = Essence.instantiate()
	newEssence.global_position = global_position
	get_tree().current_scene.add_child(newEssence)
	current_state = States.DEATH

	collision.set_deferred("disabled", true)
	if ray_cast:
		ray_cast.enabled = false
	
	_set_hitbox_active(false)
	charge_effect.visible = false

	# Reset visual
	animated_sprite.position = Vector2.ZERO
	# animated_sprite.play("death") # nnti ig ganti jdi poof effect?
	await get_tree().create_timer(1.0).timeout 
	queue_free()


func _set_hitbox_active(active: bool):
	if attack_hitbox:
		for child in attack_hitbox.get_children():
			child.set_deferred("disabled", not active)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body == player:
		if body.has_method("take_damage"):
			body.take_damage(1)

		# Whether the player took damage or successfully parried us, end the charge and bounce back up!
		if current_state == States.CHARGE:
			start_return()
