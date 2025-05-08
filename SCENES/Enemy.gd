extends CharacterBody2D

@export var player_reference: CharacterBody2D
var direction: Vector2
var speed: float = 75
var damage: float

var type: Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		damage = value.damage


func _physics_process(delta):
	velocity = (player_reference.position - position).normalized()*speed
	move_and_collide(velocity*delta)
