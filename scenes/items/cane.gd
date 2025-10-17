extends RigidBody2D

@export var damage = 10

func _ready():
	gravity_scale = 1

func use(target):
	if target and target.is_in_group("enemies"):
		if target.has_method("take_damage"):
			target.take_damage(damage)
			print("Cane hit enemy for ", damage, " damage!")
