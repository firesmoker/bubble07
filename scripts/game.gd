class_name Game extends Node2D

@export var cat_wins: int = 0
@export var bubble_wins: int = 0
@onready var cat_wins_label: Label = $UI/CatWins
@onready var bubble_wins_label: Label = $UI/BubbleWins
@onready var game_over_label: Label = $UI/GameOver
var game_over_state: bool = false
@onready var button: Button = $UI/Button

var num_wins_to_finish: int = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.visible = false
	button.connect("button_up",_on_button_button_up)
	game_over_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cat_wins >= num_wins_to_finish:
		game_over("cat")
	elif bubble_wins >= num_wins_to_finish:
		game_over("bubble")

func update_wins(player: String) -> void:
	if player.to_lower() == "cat":
		cat_wins += 1
		cat_wins_label.text = "Cat Wins: " + str(cat_wins)
	else:
		bubble_wins += 1
		bubble_wins_label.text = "Bubble Wins: " + str(bubble_wins)

func game_over(player_who_won: String) -> void:
	game_over_state = true
	button.visible = true
	if player_who_won.to_lower() == "cat":
		game_over_label.text = "CAT WINS"
		print("cat rocks")
	else:
		game_over_label.text = "BUBBLE WINS"
		print("bubbles are better")
	game_over_label.visible = true


func _on_button_button_up() -> void:
	get_tree().reload_current_scene()
