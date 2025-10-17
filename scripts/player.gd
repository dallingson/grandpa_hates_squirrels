extends CharacterBody2D

# === MOVEMENT SETTINGS ===
@export var speed = 300
@export var gravity = 30
@export var jump_force = 700

# === COMBAT SETTINGS ===
@export var attack_cooldown = 0.5
var can_attack = true

# === ITEM VARIABLES ===
var nearby_item = null
var holding_item = null


# === MAIN LOOP ===
func _physics_process(delta):
	# Apply gravity
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	# Horizontal movement
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * horizontal_direction
	move_and_slide()

	# Handle item pickup/drop
	if Input.is_action_just_pressed("interact"):
		handle_item_pickup_or_drop()

	# Handle attacking
	if Input.is_action_just_pressed("attack"):
		attack()


# === ITEM PICKUP / DROP ===
func handle_item_pickup_or_drop():
	if holding_item:
		# Drop the item
		holding_item.reparent(get_parent())
		holding_item.position = position + Vector2(0, 16)
		holding_item = null
	elif nearby_item:
		# Pick up the item
		nearby_item.reparent(self)
		nearby_item.position = Vector2(0, -16)
		holding_item = nearby_item
		nearby_item = null


# === ATTACK FUNCTION ===
func attack():
	if not can_attack:
		return

	can_attack = false
	$AttackArea.monitoring = true  # Turn on attack area briefly

	await get_tree().create_timer(0.2).timeout
	$AttackArea.monitoring = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# === SIGNALS ===

# When something enters the pickup detection area
func _on_PickupArea_body_entered(body):
	if body.is_in_group("items"):
		nearby_item = body

# When something leaves the pickup detection area
func _on_PickupArea_body_exited(body):
	if body == nearby_item:
		nearby_item = null

# When your attack area collides with something (like an enemy)
func _on_AttackArea_body_entered(body):
	if body.is_in_group("enemies"):
		# If holding a weapon, use it
		if holding_item and holding_item.has_method("use"):
			holding_item.use(body)
		else:
			# Bare-handed attack damage
			if body.has_method("take_damage"):
				body.take_damage(5)
