class_name Game extends Node2D

@export var cat_wins: int = 0
@export var bubble_wins: int = 0
@onready var cat_wins_label: Label = $UI/CatWins
@onready var bubble_wins_label: Label = $UI/BubbleWins
@onready var game_over_label: Label = $UI/GameOver
static var game_over_state: bool = false
@onready var button: Button = $UI/Button
@onready var ui: CanvasLayer = $UI
@onready var audio: AudioStreamPlayer = $Audio
var CORNELIUS_WINS_1: AudioStream = preload("res://audio/cornelius_wins1.ogg")
var FIFIN_WINS_1: AudioStream = preload("res://audio/fifin_wins1.ogg")
var START_SOUND_1: AudioStream = preload("res://audio/start_sound1.ogg")
var num_wins_to_finish: int = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio.stream = START_SOUND_1
	audio.play()
	button.visible = false
	button.connect("button_up",_on_button_button_up)
	game_over_label.visible = false
	ui.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cat_wins >= num_wins_to_finish and not game_over_state:
		game_over("cat")
	elif bubble_wins >= num_wins_to_finish  and not game_over_state:
		game_over("bubble")

func update_wins(player: String) -> void:
	if player.to_lower() == "cat":
		cat_wins += 1
		#cat_wins_label.text = "Cat Wins: " + str(cat_wins)
		cat_wins_label.text = str(cat_wins)
	else:
		bubble_wins += 1
		#bubble_wins_label.text = "Bubble Wins: " + str(bubble_wins)
		bubble_wins_label.text = str(bubble_wins)

func game_over(player_who_won: String) -> void:
	game_over_state = true
	button.visible = true
	if player_who_won.to_lower() == "cat":
		audio.stream = FIFIN_WINS_1
		audio.play()
		game_over_label.text = "FIFIN WINS"
		print("cat rocks")
	else:
		audio.stream = CORNELIUS_WINS_1
		audio.play()
		game_over_label.text = "CORNELIUS WINS"
		print("bubbles are better")
	game_over_label.visible = true


func _on_button_button_up() -> void:
	game_over_state = false
	get_tree().reload_current_scene()
