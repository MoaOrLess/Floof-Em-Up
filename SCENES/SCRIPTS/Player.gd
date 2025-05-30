extends CharacterBody2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var node_2d: Node2D = $Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var self_damage: Area2D = $SelfDamage
@onready var shadow_floof_player: Sprite2D = $ShadowFloofPlayer

@onready var PUNCH = preload("res://SCENES/punch.tscn")
const FLOOF_PLAYER_ONE_ARM_PLACE_HOLDER = preload("res://ART/Floof Player_One Arm_Place holder.png")
const FLOOF_PLAYER_PLACE_HOLDER = preload("res://ART/Floof Player_Place holder.png")

#ON SCREEN LABELS
@onready var info_1: Label = $"UI/Control/Info 1"
@onready var info_2: Label = $"UI/Control/Info 2"
@onready var info_3: Label = $"UI/Control/Info 3"
@onready var info_4: Label = $"UI/Control/Info 4"
@onready var info_5: Label = $"UI/Control/Info 5"
@onready var info_6: Label = $"UI/Control/Info 6"

#MOVEMENT 
var grav = 100
var z_pos= 0
var z_move = 0
var z = 0

var speed_calcu: float
const speed_walk: float = 200
const speed_sprint: float = 600
const speed_dodge: float = 2000
var state_move  = STATES2.IDLE
var direction: Vector2
var jumpState

var knockback: Vector2
var isDodging = false
@onready var Shadow_default_pos = shadow_floof_player.position.y

#NEW MERLING STATEMACHINE-LIKE THING
enum STATES {NOT_JUMPING, JUMPING}
enum STATES2 {IDLE, WALKING, SPRINTING, DODGING, JUMPING, DIVING}
var tracker_states

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

var kill_count: float

func _ready() -> void:
	$"Mele Attacks/Fist Punch Area/First Punch".visible = false
	$"Mele Attacks/Fist Punch Area 2/First Punch 2".visible = false

func _physics_process(delta):
	camera_zoom()
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.separation
	else:
		nearest_enemy_distance = INF
	
	#floof_Jump(delta)
	movement(delta)
	floof_shadow(delta)
	move_and_collide(velocity * delta)
	
	check_XP()
	punch_attack()
	secondary_punch_attack()
	$UI/Kills.text = str(kill_count)
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		$Camera2D.offset = randomOffset()
	
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	elif velocity.x > 0:
		$Sprite2D.flip_h = true
	
	info_1.text = "STATE: " + str(STATES2.find_key(state_move))
	info_2.text = "Z: " + str(z)
	info_3.text = "DIRECTION " + str(direction)
	info_4.text = "VELOCITY: " + str(velocity)
	info_5.text = "z: " + str(z)
	info_6.text = "DASH TIMER " + str($"Node/Dodge Timer".time_left)


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

func floof_shadow(delta):
	if z > 0:
		shadow_floof_player.position.y += z_move * delta * 2
		#shadow_floof_player.scale *= Vector2(0.99,0.99) 
		#shadow_floof_player.modulate.a -= 0.01
		
	else:
		shadow_floof_player.position.y = Shadow_default_pos
		#shadow_floof_player.scale = Vector2(1,1)
		shadow_floof_player.modulate.a = 0.4

func floof_Jump(delta):
	jumpState = STATES.NOT_JUMPING
	$GroundSlam/GroundSlamCol.disabled = true
	
	if not isDodging and Input.is_action_just_pressed("Dodge"):
		isDodging = true
		speed_calcu = speed_dodge
		$"Node/Dash Timer".start(0.3)
		dodge_effect()
	
	if z > 0:
		collision_shape_2d.disabled = true
		%Collision.disabled = true
		z_index = 1
		jumpState = STATES.JUMPING
		z_move -= grav
		z += z_move
		run()
		if Input.is_action_just_pressed("Dodge"):
			$GroundSlam/GroundSlamCol.disabled = false
			z_move -= 2000
			#z = z_move
			velocity.y += 2000
			#apply_shake()
			print(">>>>> BOOTY BOUNCE ")
		else:
			$GroundSlam/GroundSlamCol.disabled = true
			velocity.y += grav
			floof_shadow(delta)
		

	else:
		jumpState = STATES.NOT_JUMPING
		z = 0
		if isDodging == true:
			collision_shape_2d.disabled = true
			%Collision.disabled = true
		else:
			collision_shape_2d.disabled = false
			%Collision.disabled = false
		z_index = 0
		if Input.is_action_pressed("jump"):
			jumpState = STATES.JUMPING
			z_move += 2000
			z = z_move
			velocity.y -= 2000
		else:
			z_move = 0
			direction = Input.get_vector("left","right","up","down")
			run()
			velocity = direction * speed_calcu
		floof_shadow(delta)

func movement(delta): #Redo of Floof_Jump()
	direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed_calcu
	
	if Input.is_action_pressed("jump") and z == 0: #from Idle to Jump
			z_move += 2000
			z = z_move
	if not Input.is_action_pressed("jump") and z == 0:
			z_move = 0
	if z > 0 and not state_move in [STATES2.DODGING, STATES2.DIVING]:  # NOT on Ground
		state_move = STATES2.JUMPING
		z_move -= grav
		z += z_move
	if z <= 0:
		z = 0 
		z_move = 0
	if state_move == STATES2.JUMPING and z == 0:
		state_move = STATES2.IDLE
	if state_move == STATES2.IDLE and z == 0: 
		if direction != Vector2.ZERO: #from Idle to Walking
			state_move = STATES2.WALKING
			speed_calcu = speed_walk
		if  Input.is_action_just_pressed("Dodge") and direction != Vector2.ZERO:
			state_move = STATES2.DODGING
	elif state_move == STATES2.WALKING and z == 0: # On Ground
		if Input.is_action_pressed("run"): #from Walking to Sprinting
			state_move = STATES2.SPRINTING
		if  Input.is_action_just_pressed("Dodge"):
			state_move = STATES2.DODGING
		else:
			if direction == Vector2.ZERO: #from Walking to Idle
				state_move = STATES2.IDLE
			speed_calcu = speed_walk
	elif state_move == STATES2.SPRINTING and z == 0: # On Ground
		if not Input.is_action_pressed("run"):#from Sprinting to Walking
			state_move = STATES2.WALKING
			speed_calcu = speed_walk
		if  Input.is_action_just_pressed("Dodge")and z == 0:#from Sprinting to Dodging
			state_move = STATES2.DODGING
		else:
			speed_calcu = speed_sprint
	elif state_move == STATES2.DODGING and $"Node/Dodge Timer".time_left <= 0: #On dodge enter
		$"Node/Dodge Timer".start(0.3) #From any State to Dodge
		speed_calcu = speed_dodge
	elif state_move == STATES2.JUMPING:
		$"Node/Can Dive Timer".start(0.3)
		if  Input.is_action_just_pressed("Dodge") and direction != Vector2.ZERO: #From Jump to Dodge
			state_move = STATES2.DODGING
		#if $"Node/Can Dive Timer".time_left > 0:
		if Input.is_action_pressed("Dodge") and Input.is_action_pressed("down") and $"Node/Can Dive Timer".time_left > 0:
			state_move = STATES2.DIVING
		
	elif state_move == STATES2.DIVING: 
		z_move -= 2000
		if Input.is_action_just_released("Dodge"):
			state_move = STATES2.IDLE
			apply_shake()
	velocity.y -= z_move
	

func movement2(delta):
	# Update direction and velocity
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed_calcu

# Handle Jump Input
	if Input.is_action_just_pressed("jump") and z == 0:
		z_move = 2000
		z = z_move

# Gravity and Z movement
	if z > 0:
		z_move -= grav
		z += z_move
	else:
		z_move = 0
		z = 0

# Finite State Machine
	match state_move:
		STATES2.IDLE:
			if z > 0:
				state_move = STATES2.JUMPING
			elif direction != Vector2.ZERO:
				state_move = STATES2.WALKING
				speed_calcu = speed_walk
			elif Input.is_action_just_pressed("Dodge") and direction != Vector2.ZERO:
				state_move = STATES2.DODGING

		STATES2.WALKING:
			if z > 0:
				state_move = STATES2.JUMPING
			elif Input.is_action_pressed("run"):
				state_move = STATES2.SPRINTING
			elif direction == Vector2.ZERO:
				state_move = STATES2.IDLE
			elif Input.is_action_just_pressed("Dodge"):
				state_move = STATES2.DODGING
			speed_calcu = speed_walk

		STATES2.SPRINTING:
			if z > 0:
				state_move = STATES2.JUMPING
			elif not Input.is_action_pressed("run"):
				state_move = STATES2.WALKING
			elif Input.is_action_just_pressed("Dodge"):
				state_move = STATES2.DODGING
			speed_calcu = speed_sprint

		STATES2.DODGING:
			if $"Node/Dodge Timer".time_left <= 0:
				$"Node/Dodge Timer".start(0.3)
				speed_calcu = speed_dodge
			if z > 0:
				state_move = STATES2.JUMPING

		STATES2.JUMPING:
			if z <= 0:
				state_move = STATES2.IDLE
			else:
				$"Node/Can Dive Timer".start(0.3)
			if Input.is_action_just_pressed("Dodge") and direction != Vector2.ZERO:
				state_move = STATES2.DODGING
			elif Input.is_action_pressed("Dodge") and Input.is_action_pressed("down") and $"Node/Can Dive Timer".time_left > 0:
				state_move = STATES2.DIVING
		STATES2.DIVING:
			z_move -= 2000
			if Input.is_action_just_released("Dodge"):
				state_move = STATES2.IDLE
				apply_shake()

# Apply vertical motion to velocity
	velocity.y -= z_move

func boiler():
	match tracker_states:
		STATES.JUMPING:
			print("param3 is 3!")
		STATES.JUMPING:
			print("param3 is 3!")
		_:
			print("param3 is not 3!")

func run():
	if Input.is_action_pressed("run"):
		#jumpState = STATES2.SPRINTING
		speed_calcu = speed_walk + speed_sprint
		if isDodging == false:
			speed_calcu = speed_walk + speed_sprint
		else: 
			speed_calcu = speed_dodge
		
	else:
		if isDodging == false:
			speed_calcu = speed_walk
		else: 
			speed_calcu = speed_dodge

func dodge_effect():
	var newSprite = sprite_2d.duplicate()
	var animation_time = $"Node/Dash Timer".wait_time / speed_dodge
	var fade_steps = 3
	var fade_amount = 0.2
	newSprite.scale = Vector2(0.5,0.5)
	newSprite.z_index = -1
	get_parent().add_child(newSprite)
	newSprite.global_position = sprite_2d.global_position
	
	for i in range(fade_steps):
		await get_tree().create_timer((animation_time)).timeout
		newSprite.modulate.r = 1
		newSprite.modulate.a -= fade_amount
	newSprite.queue_free()

func secondary_punch_attack():
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


func _on_ground_slam_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if body.is_in_group("Enemy"):
			body.knockback = attack_direction * 1000
			body.take_damage(attack_damage)


func _on_can_dive_timer_timeout() -> void:
	$"Node/Can Dive Timer".stop()


func _on_dodge_timer_timeout() -> void:
	$"Node/Dodge Timer".stop()
	isDodging = false
	speed_calcu = speed_walk
	state_move = STATES2.IDLE
