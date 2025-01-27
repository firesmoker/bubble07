class_name CatPlayer extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_animation: AnimatedSprite2D = $Axis/SlashAnimation
@onready var game: Node2D = $".."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var CAT_ATTACK_1: AudioStream = preload("res://audio/cat_attack2.ogg")
var CAT_DEATH_1: AudioStream = preload("res://audio/cat_death1.ogg")
var CAT_GETS_HIT_1: AudioStream = preload("res://audio/cat_gets_hit1.ogg")
var CAT_JUMP_1: AudioStream = preload("res://audio/cat_jump1.ogg")
var played_win_animation: bool = false
@onready var colision_right_up: CollisionShape2D = $Axis/PlayerDamager/ColisionRightUp
@onready var colision_left_up: CollisionShape2D = $Axis/PlayerDamager/ColisionLeftUp

const SPEED = 900.0
@export var JUMP_VELOCITY = -1600.0
@onready var axis: Node2D = $Axis
var platform_velocity : Vector2
var attacking: bool = false
var dying: bool = false
var played_falling: bool = false
var played_jumping: bool = false
var jumping: bool = false
var pushed: bool = false
var push_recovery_counter: float = 0
var push_recovery_time: float = 0.5

func _ready() -> void:
	slash_animation.visible = false
	axis.visible = false
	axis.process_mode = Node.PROCESS_MODE_DISABLED


func move(direction: float) -> void:
	
	if direction and not attacking and not pushed:
		velocity.x = direction * SPEED
	elif not attacking and not pushed:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0 and direction:
		
		axis.rotation = deg_to_rad(180)
	elif velocity.x == 0:
		pass
	elif direction:
		axis.rotation = 0
	
	#velocity += platform_velocity
	move_and_slide()

func handle_movement_animations(direction: float) -> void:
	if not is_on_floor():
		if velocity.y > 0 and not played_jumping and not attacking:
			animated_sprite_2d.play("jump_down")
			played_jumping = true
		elif not played_falling and not attacking:
			animated_sprite_2d.play("jump_up")
			played_falling = true
	elif direction and not attacking:
		animated_sprite_2d.play("run")
	elif not attacking and is_on_floor():
		animated_sprite_2d.play("idle")
	
	if velocity.x > 0 and direction > 0:
		animated_sprite_2d.flip_h = true
		colision_right_up.disabled = false
		colision_left_up.disabled = true
	elif velocity.x == 0:
		pass
		#colision_right_up.disabled = false
		#colision_left_up.disabled = true
	elif direction < 0:
		colision_right_up.disabled = true
		colision_left_up.disabled = false
		animated_sprite_2d.flip_h = false

func _physics_process(delta: float) -> void:
	if not dying:
		
		recover_from_push(delta)
		
		if not is_on_floor():
			velocity += get_gravity() * 2 * delta
		else:
			#pushed = false
			jumping = false
			played_jumping = false
			played_falling = false
		
			
		if Input.is_action_just_pressed("attack"):
			attack()
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			jump()
		
		if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0 and jumping and not pushed:
			velocity.y -= clamp(velocity.y, JUMP_VELOCITY, 0)
		
		var direction := Input.get_axis("left", "right")
		
		move(direction)
		if not dying and Game.game_over_state:
			if not played_win_animation:
				animated_sprite_2d.play("win")
				played_win_animation = true
		else:
			handle_movement_animations(direction)
	else:
		collision_shape_2d.disabled = true
		velocity += get_gravity() * 2 * delta
		move_and_slide()

func recover_from_push(delta: float) -> void:
	if pushed:
		var recovery_modifier: float = 1
		if is_on_floor():
			recovery_modifier = 5
		push_recovery_counter += delta * recovery_modifier
	if push_recovery_counter >= push_recovery_time:
		pushed = false
		push_recovery_counter = 0
	if velocity == Vector2(0,0):
		pushed = false
		push_recovery_counter = 0


func attack() -> void:
	audio_stream_player_2d.stream = CAT_ATTACK_1
	audio_stream_player_2d.play()
	if is_on_floor():
		velocity.x = 0
	attacking = true
	if is_on_floor():
		animated_sprite_2d.play("attack")
	else:
		animated_sprite_2d.play("attack_in_air")
	var ready_timer: SceneTreeTimer = get_tree().create_timer(0.3)
	await ready_timer.timeout
	var timer: SceneTreeTimer = get_tree().create_timer(0.3)
	slash_animation.visible = true
	slash_animation.play()
	axis.visible = true
	axis.process_mode = Node.PROCESS_MODE_INHERIT
	await timer.timeout
	slash_animation.visible = false
	attacking = false
	axis.visible = false
	axis.process_mode = Node.PROCESS_MODE_DISABLED

func jump() -> void:
	audio_stream_player_2d.stream = CAT_JUMP_1
	audio_stream_player_2d.play()
	jumping = true
	print("jump")
	velocity.y = JUMP_VELOCITY

func detach_from_ground(time: float = 1) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(time)
	motion_mode = MOTION_MODE_FLOATING
	await timer.timeout
	motion_mode = MOTION_MODE_GROUNDED

func get_damage() -> void:
	animated_sprite_2d.play("death")
	audio_stream_player_2d.stream = CAT_DEATH_1
	audio_stream_player_2d.play()
	if not dying:
		velocity.y += JUMP_VELOCITY
		game.update_wins("bubble")
		dying = true
		await get_tree().create_timer(3).timeout
		respawn()


func get_pushed() -> void:
	pushed = true
	push_recovery_counter = 0
	audio_stream_player_2d.stream = CAT_GETS_HIT_1
	audio_stream_player_2d.play()

func _on_slash_animation_animation_finished() -> void:
	slash_animation.visible = false

func respawn() -> void:
	if not game.game_over_state:
		global_position = Vector2(0,0)
		velocity = Vector2(0,0)
		dying = false
		collision_shape_2d.disabled = false
