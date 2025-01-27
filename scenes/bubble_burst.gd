extends Area2D

var repel_velocity: Vector2 = Vector2(0,0)
@onready var timer: Timer = $Timer
var repel_intensity: float = 3000
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(repel_velocity)
	timer.start()
	repel_velocity = repel_velocity * 2
	audio_stream_player_2d.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CatPlayer:
		audio_stream_player_2d.volume_db = clamp(audio_stream_player_2d.volume_db + 8,-1000,0)
		#body.jump()
		#body.detach_from_ground()
		body.velocity += (body.global_position - global_position).normalized() * repel_intensity
		body.get_pushed()
		print("body eneterd burst!")
