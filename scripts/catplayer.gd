class_name CatPlayer extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 900.0
const JUMP_VELOCITY = -900.0
@onready var axis: Node2D = $Axis


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
	else:
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

	move_and_slide()

func attack() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(0.4)
	axis.visible = true
	axis.process_mode = Node.PROCESS_MODE_INHERIT
	await timer.timeout
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
