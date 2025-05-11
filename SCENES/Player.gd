extends CharacterBody2D

@onready var camera_2d: Camera2D = $Camera2D


var knockback: Vector2
var speed: float = 200
var health: float = 100:
	set(value):
		health = value
		%Health.value = value

var nearest_enemy: CharacterBody2D
var nearest_enemy_distance: float = INF

func _physics_process(delta):
	camera_zoom()
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.separation
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

func camera_zoom():
	var camera_zoom_scale = 0.05
	if Input.is_action_just_pressed("scroll up"):
		camera_2d.zoom += Vector2(camera_zoom_scale,camera_zoom_scale)
	if Input.is_action_just_pressed("scroll down"):
		camera_2d.zoom -= Vector2(camera_zoom_scale,camera_zoom_scale)
