extends AnimatableBody2D

# Movement speed
#var velocity: Vector2 = Vector2(0,0)
@export var speed: float = 200.0
# Left and right boundaries
@export var left_limit: float = -400
@export var right_limit: float = 400.0

# Direction of movement: 1 for right, -1 for left
@export var direction: int = 1
var previous_position:Vector2 = Vector2.ZERO 

# Area2D to detect overlapping bodies
@onready var detector: Area2D = $Area2D

func _ready() -> void:
	left_limit = position.x + left_limit
	right_limit = position.x + right_limit
	previous_position = position
	
func _physics_process(delta: float) -> void:
	# Move the StaticBody2D
	position.x += direction * speed * delta

	# Reverse direction if the body reaches the boundaries
	if position.x > right_limit:
		direction = -1
	elif position.x < left_limit:
		direction = 1
		var velocity = position - previous_position

	   # Notify overlapping bodies (e.g., player) about the platform's movement
	#for body in detector.get_overlapping_bodies():
		#if body.has_method("set_platform_velocity"):
			#body.set_platform_velocity(velocity / delta)
	previous_position = position
