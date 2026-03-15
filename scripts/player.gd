extends CharacterBody2D

enum PlayerState { SPIRIT, BODY }

@export var state: PlayerState = PlayerState.SPIRIT
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var spirit_speed: float = 500.0
@export var projectile_scene: PackedScene = null

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int = 1
var is_invincible: bool = false
var has_shield: bool = false
var can_double_jump: bool = false
var spawn_protection: bool = false
var _coyote_timer: float = 0.0
const COYOTE_TIME: float = 0.1
var _anim_time: float = 0.0
var _playing_fireball_anim: bool = false
var _fireball_anim_time: float = 0.0
var _current_texture: Texture2D = null

signal player_died

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _idle_texture: Texture2D = preload("res://resources/idle.png")
var _fireball_texture: Texture2D = preload("res://resources/buyu.png")
var _run_texture: Texture2D = preload("res://resources/run.png")
var _spirit_run_texture: Texture2D = preload("res://resources/ruh_run.png")

func _ready() -> void:
	# Start in Spirit state with collision disabled
	state = PlayerState.SPIRIT
	collision_shape.disabled = true
	sprite.modulate = Color(0.5, 0.8, 1.0, 0.6)
	velocity = Vector2.ZERO

func set_state(new_state: PlayerState) -> void:
	state = new_state
	if state == PlayerState.SPIRIT:
		collision_shape.set_deferred("disabled", true)
		sprite.modulate = Color(0.5, 0.8, 1.0, 0.6)
		velocity = Vector2.ZERO
		is_invincible = false
		spawn_protection = false
	else:
		# Important: Move to start marker occurs in GameManager BEFORE this is called
		collision_shape.set_deferred("disabled", false)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		health = 1
		start_spawn_protection(0.1)

func start_spawn_protection(duration: float) -> void:
	spawn_protection = true
	is_invincible = true
	
	var loops = max(1, int(duration / 0.2))
	var tween = create_tween()
	tween.set_loops(loops)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(duration).timeout
	spawn_protection = false
	is_invincible = false
	tween.kill() # Ensure tween stops
	sprite.modulate.a = 1.0

func _is_moving() -> bool:
	return abs(velocity.x) > 10.0

func _set_anim_texture(tex: Texture2D, hframes: int) -> void:
	if _current_texture != tex:
		_current_texture = tex
		sprite.texture = tex
		sprite.hframes = hframes
		_anim_time = 0.0

func _process(delta: float) -> void:
	if _playing_fireball_anim:
		_fireball_anim_time += delta
		var frame_idx = int(_fireball_anim_time * 10.0)
		if frame_idx >= 6:
			_playing_fireball_anim = false
			_current_texture = null  # Force refresh on next frame
		else:
			sprite.frame = frame_idx
		return

	_anim_time += delta
	if state == PlayerState.SPIRIT:
		_set_anim_texture(_spirit_run_texture, 3)
		sprite.frame = int(_anim_time * 8.0) % 3
	elif _is_moving():
		_set_anim_texture(_run_texture, 7)
		sprite.frame = int(_anim_time * 10.0) % 7
	else:
		_set_anim_texture(_idle_texture, 3)
		sprite.frame = int(_anim_time * 5.0) % 3

func _physics_process(delta: float) -> void:
	if state == PlayerState.SPIRIT:
		handle_spirit_movement(delta)
	else:
		handle_body_movement(delta)

func handle_spirit_movement(_delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * spirit_speed
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
	move_and_slide()

func handle_body_movement(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer -= delta
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept"):
		if _coyote_timer > 0:
			velocity.y = jump_velocity
			_coyote_timer = 0.0
		elif can_double_jump:
			# If already moving up fast from a boost, add to it instead of capping
			velocity.y = min(velocity.y, 0.0) + jump_velocity
			can_double_jump = false
	
	var direction = Input.get_axis("ui_left", "ui_right")
	var accel = speed * 10.0 # Fast acceleration
	var friction = speed * 5.0 # Slower friction to allow momentum
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

func activate_skill(skill_type: String, trail_direction: Vector2 = Vector2.RIGHT) -> void:
	# Block skills during spawn protection to prevent accidental collection of the 3rd trail
	if spawn_protection:
		return

	match skill_type:
		"double_jump":
			# Instant boost in the trail's direction - make it significantly stronger
			# to ensure it's felt immediately and can overcome current momentum
			var boost_velocity = trail_direction.normalized() * abs(jump_velocity) * 1.5
			velocity = boost_velocity
			
			# Re-enable jumping so the user can actually use this boost effectively in air
			can_double_jump = true
			
			# Reset coyote timer to prevent mixing with ground jump logic
			_coyote_timer = 0
			
			# Force a small position update to ensure we leave the ground/walls if aimed away
			global_position += trail_direction.normalized() * 2.0
			
			print("Double Jump boost! Velocity: ", velocity)
		"shield":
			activate_shield(3.0)
		"fireball":
			shoot_fireball(trail_direction)

func activate_shield(duration: float) -> void:
	has_shield = true
	sprite.modulate = Color(1.0, 1.0, 0.5)
	await get_tree().create_timer(duration).timeout
	has_shield = false
	if state == PlayerState.BODY:
		sprite.modulate = Color(1.0, 1.0, 1.0)

func play_fireball_anim() -> void:
	_playing_fireball_anim = true
	_fireball_anim_time = 0.0
	sprite.texture = _fireball_texture
	sprite.hframes = 6
	sprite.frame = 0

func shoot_fireball(direction: Vector2 = Vector2.RIGHT) -> void:
	play_fireball_anim()
	if not projectile_scene: return

	var fireball = projectile_scene.instantiate()

	# Pass shooter reference to the fireball
	fireball.shooter = self

	# Spawn far enough away to avoid collision, in the trail's aimed direction
	fireball.global_position = global_position + direction * 60
	fireball.velocity = direction * fireball.speed
	get_parent().call_deferred("add_child", fireball)

func take_damage(amount: int) -> void:
	if is_invincible or state == PlayerState.SPIRIT:
		return
		
	if has_shield:
		has_shield = false
		sprite.modulate = Color(1.0, 1.0, 1.0)
		start_invincibility(0.5)
		return
	
	health -= amount
	if health <= 0:
		die()
	else:
		start_invincibility(1.0)

func start_invincibility(duration: float) -> void:
	is_invincible = true
	var loops = max(1, int(duration / 0.2))
	var tween = create_tween()
	tween.set_loops(loops)
	tween.tween_property(sprite, "modulate:a", 0.2, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(duration).timeout
	if not spawn_protection:
		is_invincible = false
		tween.kill() # Ensure tween stops
		sprite.modulate.a = 1.0 if state == PlayerState.BODY else 0.6

func die() -> void:
	player_died.emit()
