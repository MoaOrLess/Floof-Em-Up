extends CharacterBody2D

var knockback: Vector2
var speed: float = 200
var health: float = 100:
	set(value):
		health = value
		%Health.value = value

var nearest_enemy: CharacterBody2D
var nearest_enemy_distance: float = INF

func _physics_process(delta):
	if nearest_enemy:
		nearest_enemy_distance = nearest_enemy.separation
		print(nearest_enemy.name)
	else:
		nearest_enemy_distance = INF
	
	
	velocity = Input.get_vector("left","right","up","down") * speed
	move_and_collide(velocity * delta)
	#move_and_slide()
	
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	elif velocity.x > 0:
		$Sprite2D.flip_h = true

func take_damage(amount):
	health -= amount
	

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled",true)
	%Collision.set_deferred("disabled",false)

func _on_self_damage_body_entered(body):
	take_damage(body.damage)
