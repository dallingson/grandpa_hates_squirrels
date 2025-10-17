extends CharacterBody2D

@export var health = 20
@export var speed = 50
@export var patrol_distance = 100
@export var gravity = 30

var start_position: Vector2
var direction = 1

func _ready():
	add_to_group("enemies")
	start_position = global_position

func take_damage(amount):
	health -= amount
	print("Squirrel took ", amount, " damage! Health: ", health)
	
	if health <= 0:
		die()

func die():
	print("Squirrel defeated!")
	queue_free()

func _physics_process(delta):
	# Patrol back and forth
	velocity.x = direction * speed
	
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	
	# Check if reached patrol limit
	if abs(global_position.x - start_position.x) > patrol_distance:
		direction *= -1
	
	move_and_slide()
