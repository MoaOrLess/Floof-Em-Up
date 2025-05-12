extends Node2D

@export var player_reference: CharacterBody2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Player/AudioStreamPlayer2D

func _process(delta: float) -> void:
	if player_reference.health <= 0:
			get_tree().quit()
	
