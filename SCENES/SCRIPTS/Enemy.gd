extends CharacterBody2D

@export var player_reference: CharacterBody2D
var damage_popup_node = preload("res://SCENES/damage.tscn")
var direction: Vector2
var speed: float = 75
var damage: float
var knockback: Vector2
var separation: float
var kill_count: float

var drop = preload("res://SCENES/pickups.tscn")

var health: float:
	set(value):
		health = value
		if health <= 0:
			kill_count_up()
			print(kill_count)
			drop_item()
			queue_free()
			

var elite:bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://SHADERS/rainbow_border.tres")
			scale = Vector2(0.75,0.75)
			health *= 4

var type: Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		damage = value.damage
		health = value.health


func _physics_process(delta):
	check_separation(delta)
	knockback_update(delta)
	enemy_facing()

func kill_count_up():
	player_reference.kill_count += 1

func check_separation(_delta):
	separation = (player_reference.position - position).length()
	if separation >= 2500 and not elite:
		queue_free()
	
	if separation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self

	

func  knockback_update(delta):
	velocity = (player_reference.position - position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 1)
	velocity += knockback
	var collider = move_and_collide(velocity * delta)
	
	if collider:
		collider.get_collider().knockback = (collider.get_collider().global_position - global_position).normalized() * 50

func enemy_facing():
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	elif velocity.x > 0:
		$Sprite2D.flip_h = true

func damage_popup(amount):
	var popup = damage_popup_node.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2 (-50, -100)
	get_tree().current_scene.add_child(popup)

func take_damage(amount):
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3,0.25,1,1), 0.2)
	tween.tween_property($Sprite2D, "modulate", Color(1,1,1), 0.2)
	tween.bind_node(self)
	
	damage_popup(amount)
	health -= amount

func drop_item():
	if type.drops.size()==0:
		return
	var item = type.drops.pick_random()
	var item_to_drop = drop.instantiate()
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
