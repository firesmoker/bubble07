extends AnimatableBody2D

var velocity: Vector2 = Vector2(0,0)
@export var burst_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_collide(velocity * delta)
	

func get_damage() -> void:
	burst()
	queue_free()

func burst() -> void:
	var new_burst = burst_scene.instantiate()
	new_burst.repel_velocity = velocity * 4
	new_burst.global_position = global_position
	get_parent().add_child(new_burst)
