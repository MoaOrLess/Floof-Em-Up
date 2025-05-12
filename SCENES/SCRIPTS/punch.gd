extends Node2D

var direction: Vector2 
var damage: float = 5
var speed: float = 100
@onready var punch: Area2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var health: float:
	set(value):
		health = value


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	punch_attack()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		body.knockback = direction * 500
	health -= 1

func punch_attack():
	animation_player.play("Punch")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Punch":
		queue_free()
