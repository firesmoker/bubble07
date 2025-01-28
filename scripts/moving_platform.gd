extends AnimatableBody2D

@export var speed: float = 200.0
@export var left_limit: float = -400
@export var right_limit: float = 400.0

@export var direction: int = 1
var previous_position:Vector2 = Vector2.ZERO 

@onready var detector: Area2D = $Area2D

func _ready() -> void:
	left_limit = position.x + left_limit
	right_limit = position.x + right_limit
	previous_position = position
	
func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

	if position.x > right_limit:
		direction = -1
	elif position.x < left_limit:
		direction = 1
		
	previous_position = position
