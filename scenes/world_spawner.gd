extends Node

func _ready():
	spawn_enemies()

func spawn_enemies():
	# Spawn regular squirrels
	spawn_squirrel(Vector2(200, 0))
	spawn_squirrel(Vector2(-200, 0))
	
	# Spawn buff squirrel
	spawn_buff_squirrel(Vector2(0, -100))

func spawn_squirrel(pos):
	var squirrel = preload("res://enemies/Squirrel.tscn").instantiate()
	squirrel.position = pos
	get_parent().add_child(squirrel)

func spawn_buff_squirrel(pos):
	var buff_squirrel = preload("res://enemies/BuffSquirrel.tscn").instantiate()
	buff_squirrel.position = pos
	get_parent().add_child(buff_squirrel)