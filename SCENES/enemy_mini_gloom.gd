extends CharacterBody2D

@export var player_reference: CharacterBody2D
var direction: Vector2
var speed: float = 75

func _physics_process(delta):
	velocity = (player_reference.position - position).normalized()*speed
	move_and_collide(velocity*delta)
