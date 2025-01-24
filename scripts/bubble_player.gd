extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var axis: Node2D = $Axis
@export var bubble_projectile: PackedScene
@onready var bubble_spawn: Sprite2D = $Axis/BubbleSpawn
@onready var game: Game = $".."
var dying: bool = false
@onready var bubble_sprite: AnimatedSprite2D = $BubbleSprite


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot_bubble"):
		create_projectile()

func _ready() -> void:
	velocity = Vector2(0,0)

func _physics_process(delta: float) -> void:
	
	velocity.x = move_toward(velocity.x,0,20)
	velocity.y = move_toward(velocity.y,-50,20)
	axis.rotation = seek_mouse()
	move_and_slide()
	if velocity.x > 10 or velocity.x < -10:
		bubble_sprite.play("shoot")
	else:
		bubble_sprite.play("default")

func create_projectile() -> void:
	var new_projectile := bubble_projectile.instantiate()
	#print(bubble_spawn.global_position)
	new_projectile.global_position = bubble_spawn.global_position
	var new_velocity: Vector2 = get_global_mouse_position() - self.global_position
	new_velocity = new_velocity.normalized() * 1000
	print(new_velocity)
	new_projectile.velocity = new_velocity
	get_parent().add_child(new_projectile)
	repel_self(new_velocity)
	

func repel_self(new_velocity: Vector2) -> void:
	velocity.x = -new_velocity.x
	velocity.y = -new_velocity.y

func seek_mouse() -> float:
	var angle = self.get_angle_to(get_global_mouse_position())
	#print(angle)
	return angle

func get_damage() -> void:
	if not dying:
		game.update_wins("cat")
		dying = true
		print("ouch")
		#queue_free()
		respawn()

func respawn() -> void:
	if not game.game_over_state:
		global_position = Vector2(0,0)
		dying = false
