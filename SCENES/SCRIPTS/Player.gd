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

#CAMERA
@export var randomStrength: float = 5
@export var shakeFade: float = 2.5

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0

var can_attack: bool = true
var can_combo: bool = false

var kill_count = 0

func _ready() -> void:
	$"Mele Attacks/Fist Punch Area/First Punch".visible = false
	$"Mele Attacks/Fist Punch Area 2/First Punch 2".visible = false

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
	punch_attack_2()
	$UI/Kills.text = str(kill_count)
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		$Camera2D.offset = randomOffset()
	
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	elif velocity.x > 0:
		$Sprite2D.flip_h = true
	

func apply_shake():
	shake_strength = randomStrength

func randomOffset()-> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),rng.randf_range(-shake_strength, shake_strength))

func punch_attack():
	if Input.is_action_just_pressed("click"):
		if can_attack == true and can_combo == false:
			can_attack = false
			can_combo = true
			#var animation_time =  $AnimationPlayer.get_playing_speed()
			$AudioStreamPlayer2D.play()
			$"Mele Attacks/Fist Punch Area/First Punch".visible = true
			$AnimationPlayer.play("Punch 1")
			if $AnimationPlayer.is_playing():
				$Sprite2D.texture = FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER
			if $Sprite2D.flip_h == true:
				$"Mele Attacks/Fist Punch Area".scale.x = -1
			else: 
				$"Mele Attacks/Fist Punch Area".scale.x = 1
			$"Node/Mele Timer".start()
			$"Node/Mele Combo Cooldown".start()



func punch_attack_2():
	if Input.is_action_just_pressed("click"):
		if can_attack == true and can_combo == true:
			can_attack = false
			can_combo = true
			#var animation_time =  $AnimationPlayer.get_playing_speed()
			$AudioStreamPlayer2D.play()
			$"Mele Attacks/Fist Punch Area 2/First Punch 2".visible = true
			$AnimationPlayer.play("Punch 2")
			if $AnimationPlayer.is_playing():
				$Sprite2D.texture = FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER
			if $Sprite2D.flip_h == true:
				$"Mele Attacks/Fist Punch Area 2".scale.x = -1
			else: 
				$"Mele Attacks/Fist Punch Area 2".scale.x = 1
			$"Node/Mele Timer".start()
			$"Node/Mele Combo Cooldown".start()

func punch_attack_instance():
	if Input.is_action_just_pressed("click"):
		$Sprite2D.texture = FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER
		var punch_attack_inst = PUNCH.instantiate()
		var offset =  Vector2(150,150)
		if $Sprite2D.flip_h == true:
			punch_attack_inst.set_scale(Vector2(-1, 1))
			punch_attack_inst.position = position + offset
		punch_attack_inst.position = position + offset
		add_child(punch_attack_inst)     
		#print(punch_attack.position)
		await get_tree().create_timer(0.3).timeout
		$Sprite2D.texture = FLOOF_PLAYER_PLACE_HOLDER
		$AnimationPlayer.play("RESET")

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
		apply_shake()


func _on_fist_punch_area_2_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(floor(attack_damage/2))
		body.knockback = attack_direction * 500
		apply_shake()


func _on_mele_timer_timeout() -> void:
	can_attack = true
	$Sprite2D.texture = FLOOF_PLAYER_PLACE_HOLDER
	$AnimationPlayer.play("RESET")


func _on_mele_combo_cooldown_timeout() -> void:
	can_combo = false
