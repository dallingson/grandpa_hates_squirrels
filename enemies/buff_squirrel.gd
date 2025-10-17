extends CharacterBody2D

@export var health = 50
@export var speed: int = 30
@export var patrol_distance: int = 80
@export var gravity = 30

var start_position: Vector2
var direction: int = 1

func _ready():
	add_to_group("enemies")
	start_position = global_position

func take_damage(amount):
	health -= amount
	print("Buff Squirrel took ", amount, " damage! Health: ", health)
	
	if health <= 0:
		die()

func die():
	print("Buff Squirrel defeated!")
	queue_free()

func _physics_process(delta):
	# Apply gravity
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	else:
		velocity.y = 0
	
	# Patrol back and forth
	velocity.x = direction * speed
	
	# Check if reached patrol limit
	if abs(global_position.x - start_position.x) > patrol_distance:
		direction *= -1
	
	move_and_slide()
