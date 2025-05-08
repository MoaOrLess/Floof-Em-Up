extends Node2D

@export var player: CharacterBody2D
@export var enemy: PackedScene

#Distance from player to spawn
var distance: float = 400

#to store an array of enemies
@export var enemy_types: Array[Enemy]

#Minute setter var will update the minute label
var minute: int:
	set(value):
		minute = value
		%Minute.text = str(value)

#Second setter var will update the second label
var second: int:
	set(value):
		second = value
		if second >=10:
			second -=10
			minute+=1
		%Second.text = str(second).lpad(2,"0")

func spawn(pos:Vector2):
	var enemy_instance = enemy.instantiate()
	
	#each minute a new enemy wave
	enemy_instance.type = enemy_types[min(minute, enemy_types.size()-1)]
	
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	
	get_tree().current_scene.add_child(enemy_instance)
	
func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 *PI))

func amount(number: int = 1):
	for i in range(number):
		spawn(get_random_position())

func _on_timer_timeout() -> void:
	second += 1
	amount(second % 10)
