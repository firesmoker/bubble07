class_name CatPlayer extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_animation: AnimatedSprite2D = $Axis/SlashAnimation
@onready var game: Node2D = $".."

const SPEED = 900.0
const JUMP_VELOCITY = -900.0
@onready var axis: Node2D = $Axis
var platform_velocity : Vector2
var attacking: bool = false
var dying: bool = false
var played_falling: bool = false
var played_jumping: bool = false
#var jumping: bool = false


func _ready() -> void:
	slash_animation.visible = false
	axis.visible = false
	axis.process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
	else:
		played_jumping = false
		played_falling = false
	# Handle jump.
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		
	if Input.is_action_just_pressed("attack"):
		attack()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if not is_on_floor():
		if velocity.y > 0 and not played_jumping and not attacking:
			animated_sprite_2d.play("jump_down")
			played_jumping = true
		elif not played_falling and not attacking:
			animated_sprite_2d.play("jump_up")
			played_falling = true
	elif direction and not attacking:
		animated_sprite_2d.play("run")
		velocity.x = direction * SPEED
	elif not attacking and is_on_floor():
		animated_sprite_2d.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0 and direction:
		axis.rotation = deg_to_rad(180)
		animated_sprite_2d.flip_h = true
	elif velocity.x == 0:
		pass
	elif direction:
		axis.rotation = 0
		animated_sprite_2d.flip_h = false
	
	velocity += platform_velocity
	move_and_slide()
	platform_velocity = get_platform_velocity()
	print(platform_velocity)

func attack() -> void:
	if is_on_floor():
		velocity.x = 0
	attacking = true
	animated_sprite_2d.play("attack")
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
		game.update_wins("bubble")
		dying = true
		#queue_free()
		respawn()


func _on_slash_animation_animation_finished() -> void:
	slash_animation.visible = false

func respawn() -> void:
	if not game.game_over_state:
		global_position = Vector2(0,0)
		dying = false
