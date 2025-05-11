extends Area2D

var direction: Vector2
var Speed: float = 175

@export var type: Pickups
@export var player_reference: CharacterBody2D:
	set(value):
		player_reference = value
		type.player_reference = value

var can_follow: bool = false

func _ready():
	$Sprite2D.texture = type.icon
	$Sprite2D.scale = Vector2(0.1,0.1)
	
func _physics_process(delta):
	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * Speed * delta

func follow(_target: CharacterBody2D):
	can_follow = true

func _on_body_entered(body: Node2D) -> void:
	type.activate()
	queue_free()
