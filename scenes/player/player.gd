extends CharacterBody2D

func _ready():
	add_to_group("player")
	# Adjust camera to zoom in and fill screen
	$Camera2D.zoom = Vector2(2.0, 2.0)
	$Camera2D.position = Vector2(0, -100)

# === MOVEMENT SETTINGS ===
@export var speed = 300
@export var gravity = 30
@export var jump_force = 700

# === COMBAT SETTINGS ===
@export var attack_cooldown = 0.2
var can_attack = true

# === ITEM VARIABLES ===
var nearby_item = null
var inventory = []
var equipped_weapon = null


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
	
	# Handle animations
	var anim_sprite = get_node_or_null("AnimatedSprite2D")
	if anim_sprite:
		if horizontal_direction != 0:
			anim_sprite.play("run")
			anim_sprite.flip_h = horizontal_direction < 0
		else:
			anim_sprite.play("idle")
	
	move_and_slide()

	# Handle item pickup/drop
	if Input.is_action_just_pressed("interact"):
		handle_item_pickup_or_drop()

	# Handle attacking
	if Input.is_action_just_pressed("attack"):
		attack()


# === ITEM PICKUP ===
func handle_item_pickup_or_drop():
	if nearby_item:
		# Add to inventory
		var item_name = nearby_item.name
		inventory.append(item_name)
		nearby_item.queue_free()
		nearby_item = null
		
		# Auto-equip cane
		if item_name == "Cane":
			equip_cane()
			print("Cane equipped!")

func equip_cane():
	equipped_weapon = "Cane"
	# Create visual cane attached to player
	var cane_sprite = Sprite2D.new()
	cane_sprite.name = "EquippedCane"
	cane_sprite.texture = load("res://scenes/items/cane.png")
	cane_sprite.position = Vector2(35, -35)
	cane_sprite.rotation_degrees = -90
	cane_sprite.scale = Vector2(0.08, 0.08)
	add_child(cane_sprite)


# === ATTACK FUNCTION ===
func attack():
	if not can_attack:
		return

	can_attack = false
	
	# Play swing animation if cane equipped
	if equipped_weapon == "Cane":
		swing_cane()
	
	$AttackArea.monitoring = true

	await get_tree().create_timer(0.2).timeout
	$AttackArea.monitoring = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func swing_cane():
	var cane = get_node_or_null("EquippedCane")
	if cane:
		# Create overhead swing animation
		var tween = create_tween()
		tween.tween_property(cane, "rotation_degrees", 90, 0.2)
		tween.tween_property(cane, "rotation_degrees", -45, 0.1)


# === SIGNALS ===ddddddddd

# When something enters the pickup detection area
func _on_pickup_area_body_entered(body):
	if body.is_in_group("items"):
		nearby_item = body
		print("Near item: ", body.name)

# When something leaves the pickup detection area
func _on_pickup_area_body_exited(body):
	if body == nearby_item:
		nearby_item = null
		print("Left item area")

# When your attack area collides with something (like an enemy)
func _on_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		print("Attacking enemy: ", body.name)
		# If equipped with cane, use it
		if equipped_weapon == "Cane":
			if body.has_method("take_damage"):
				body.take_damage(10)
				print("Cane hit for 10 damage!")
		else:
			# Bare-handed attack damage
			if body.has_method("take_damage"):
				body.take_damage(5)
				print("Bare-handed attack for 5 damage!")
