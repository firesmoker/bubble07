class_name CatPlayer extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 900.0
const JUMP_VELOCITY = -900.0
@onready var axis: Node2D = $Axis
var platform_velocity : Vector2
var attacking: bool = false


func _ready() -> void:
	axis.visible = false
	axis.process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
	# Handle jump.
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		
	if Input.is_action_just_pressed("attack"):
		attack()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		animated_sprite_2d.play("run")
		velocity.x = direction * SPEED
	elif not attacking:
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
	attacking = true
	animated_sprite_2d.play("attack")
	var ready_timer: SceneTreeTimer = get_tree().create_timer(0.55)
	await ready_timer.timeout
	var timer: SceneTreeTimer = get_tree().create_timer(0.3)
	axis.visible = true
	axis.process_mode = Node.PROCESS_MODE_INHERIT
	await timer.timeout
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
	queue_free()
