extends CharacterBody2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var PUNCH = preload("res://SCENES/punch.tscn")
@onready var node_2d: Node2D = $Node2D
const FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER = preload("res://ART/Floof Player_One Arm_Place holder.png")
const FLOOF_PLAYER_PLACE_HOLDER = preload("res://ART/Floof Player_Place holder.png")



var knockback: Vector2
var speed: float = 200
var health: float = 100:
	set(value):
		health = value
		%Health.value = value

var nearest_enemy: CharacterBody2D
var nearest_enemy_distance: float = INF

var XP: int = 0:
	set(value):
		XP = value
		%XP.value = value

var total_XP: int = 0
var level: int = 1:
	set(value):
		level = value
		%Level.text = str(value)
		
		if level >= 3:
			%XP.max_value = 10
		elif level >= 7:
			%XP.max_value = 25

#MELE ATTACK
var attack_direction: Vector2 
var attack_damage: float = 5
var attack_speed: float = 100


func _ready() -> void:
	$"Mele Attacks/Fist Punch Area/First Punch".visible = false

func _physics_process(delta):
	camera_zoom()
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.separation
	else:
		nearest_enemy_distance = INF
	
	
	velocity = Input.get_vector("left","right","up","down") * speed
	move_and_collide(velocity * delta)
	#move_and_slide()
	check_XP()
	#punch_attack_inst()
	punch_attack()
	
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	elif velocity.x > 0:
		$Sprite2D.flip_h = true
	


func punch_attack():
	if Input.is_action_just_pressed("click"):
		var animation_time =  $AnimationPlayer.get_playing_speed()
		$"Mele Attacks/Fist Punch Area/First Punch".visible = true
		$AnimationPlayer.play("Punch 1")
		
		if $AnimationPlayer.is_playing():
			$Sprite2D.texture = FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER
		if $Sprite2D.flip_h == true:
			$"Mele Attacks/Fist Punch Area".scale.x = -1
		else: 
			$"Mele Attacks/Fist Punch Area".scale.x = 1
		await get_tree().create_timer(0.3).timeout
		$Sprite2D.texture = FLOOF_PLAYER_PLACE_HOLDER
	
func punch_attack_inst():
	if Input.is_action_just_pressed("click"):
		$Sprite2D.texture = FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER
		var punch_attack = PUNCH.instantiate()
		var offset =  Vector2(150,150)
		if $Sprite2D.flip_h == true:
			punch_attack.set_scale(Vector2(-1, 1))
			punch_attack.position = position + offset
		punch_attack.position = position + offset
		add_child(punch_attack)     
		#print(punch_attack.position)
		await get_tree().create_timer(0.3).timeout
		$Sprite2D.texture = FLOOF_PLAYER_PLACE_HOLDER

func take_damage(amount):
	health -= amount
	

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled",true)
	%Collision.set_deferred("disabled",false)

func _on_self_damage_body_entered(body):
	take_damage(body.damage)

func gain_XP(amount):
	XP += amount
	total_XP += amount

func check_XP():
	if XP > %XP.max_value:
		XP -= %XP.max_value
		level += 1

func camera_zoom():
	var camera_zoom_scale = 0.05
	if Input.is_action_just_pressed("scroll up") and camera_2d.zoom <= Vector2(1.5,1.5):
		camera_2d.zoom += Vector2(camera_zoom_scale,camera_zoom_scale)
	if Input.is_action_just_pressed("scroll down")and camera_2d.zoom >= Vector2(0.5,0.5):
		camera_2d.zoom -= Vector2(camera_zoom_scale,camera_zoom_scale)
	print(camera_2d.zoom)


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(self)


func _on_fist_punch_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
		body.knockback = attack_direction * 500
