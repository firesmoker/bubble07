class_name CatPlayer extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_animation: AnimatedSprite2D = $Axis/SlashAnimation
@onready var game: Node2D = $".."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

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

func _ready() -> void:
	slash_animation.visible = false
	axis.visible = false
	axis.process_mode = Node.PROCESS_MODE_DISABLED


func move(direction: float) -> void:
	
	if direction and not attacking:
		velocity.x = direction * SPEED
	elif not attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0 and direction:
		axis.rotation = deg_to_rad(180)
	elif velocity.x == 0:
		pass
	elif direction:
		axis.rotation = 0
	
	velocity += platform_velocity
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
	
	if velocity.x > 0 and direction:
		animated_sprite_2d.flip_h = true
	elif velocity.x == 0:
		pass
	elif direction:
		animated_sprite_2d.flip_h = false

func _physics_process(delta: float) -> void:
	if not dying:
		if not is_on_floor():
			velocity += get_gravity() * 2 * delta
		else:
			pushed = false
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
		handle_movement_animations(direction)
	else:
		collision_shape_2d.disabled = true
		velocity += get_gravity() * 2 * delta
		move_and_slide()


func attack() -> void:
	if is_on_floor():
		velocity.x = 0
	attacking = true
	if is_on_floor():
		animated_sprite_2d.play("attack")
	else:
		animated_sprite_2d.play("attack_in_air")
	var ready_timer: SceneTreeTimer = get_tree().create_timer(0.55)
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
	if not dying:
		velocity.y += JUMP_VELOCITY
		game.update_wins("bubble")
		dying = true
		await get_tree().create_timer(3).timeout
		respawn()


func _on_slash_animation_animation_finished() -> void:
	slash_animation.visible = false

func respawn() -> void:
	if not game.game_over_state:
		global_position = Vector2(0,0)
		velocity = Vector2(0,0)
		dying = false
		collision_shape_2d.disabled = false
