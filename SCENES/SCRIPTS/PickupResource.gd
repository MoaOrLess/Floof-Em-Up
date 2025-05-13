extends Resource
class_name  Pickups

@export var title: String
@export var icon: Texture2D
@export_multiline var description: String
@export var sfx: AudioStream

var player_reference: CharacterBody2D

func activate():
	pass
	#print(title+" picked up")
