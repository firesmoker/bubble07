extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var axis: Node2D = $Axis
@export var bubble_projectile: PackedScene
@onready var bubble_spawn: Sprite2D = $Axis/BubbleSpawn
@onready var game: Game = $".."
var dying: bool = false
@onready var bubble_sprite: AnimatedSprite2D = $BubbleSprite
@onready var fish_sprite: AnimatedSprite2D = $FishSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var falling: bool = false
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var BUBBLE_001: AudioStream = preload("res://audio/bubble-001.ogg")
var BIG_BUBBLE_001: AudioStream = preload("res://audio/big_bubble1.ogg")
var FISH_DEATH_1: AudioStream = preload("res://audio/fish_death1.ogg")
@onready var fish_audio: AudioStreamPlayer2D = $FishAudio

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot_bubble") and not dying:
		create_projectile()

func _ready() -> void:
	velocity = Vector2(0,0)

func move() -> void:
	velocity.x = move_toward(velocity.x,0,20)
	velocity.y = move_toward(velocity.y,-50,20)
	axis.rotation = seek_mouse()
	move_and_slide()

func handle_animations() -> void:
	if velocity.x > 10 or velocity.x < -10:
		bubble_sprite.play("shoot")
		fish_sprite.play("shoot")
		if velocity.x > 0:
			fish_sprite.flip_h = false
		else:
			fish_sprite.flip_h = true
	else:
		bubble_sprite.play("default")
		fish_sprite.play("default")

func _physics_process(delta: float) -> void:
	if not dying:
		move()
		handle_animations()
	else:
		collision_shape_2d.disabled = true
		velocity += get_gravity() * 2 * delta
		fish_sprite.rotation += 0.5
		move_and_slide()

func create_projectile() -> void:
	audio_stream_player_2d.stream = BUBBLE_001
	audio_stream_player_2d.play()
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
		fish_audio.stream = FISH_DEATH_1
		fish_audio.play()
		bubble_spawn.visible = false
		falling = true
		collision_shape_2d.disabled = true
		bubble_sprite.play("death")
		fish_sprite.play("death")
		game.update_wins("cat")
		dying = true
		print("ouch")
		await get_tree().create_timer(3).timeout
		#queue_free()
		respawn()
	

func respawn() -> void:
	if not game.game_over_state:
		bubble_spawn.visible = true
		collision_shape_2d.disabled = false
		velocity = Vector2(0,0)
		global_position = Vector2(0,0)
		fish_sprite.rotation = 0
		dying = false
		falling = false
		#collision_shape_2d.disabled = false
