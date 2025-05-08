extends CharacterBody2D

var speed: float = 150
var health: float = 100:
	set(value):
		health = value
		%Health.value = value

func _physics_process(delta):
	velocity = Input.get_vector("left","right","up","down") * speed
	move_and_collide(velocity * delta)
	#move_and_slide()

func take_damage(amount):
	health -= amount
	print(amount)

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled",true)
	%Collision.set_deferred("disabled",false)

func _on_self_damage_body_entered(body: Node2D) -> void:
	take_damage(body.damage)
